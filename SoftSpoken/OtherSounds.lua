setfenv(1, SpokenEnv)

-- Ported from rusty-key/spoken-wow addons/Spoken/OtherSounds.lua.
-- Fade other audio categories down during actual native narration and restore
-- the player's baseline afterwards. Vanilla 1.12 has three volume controls:
-- SoundVolume, MusicVolume, AmbienceVolume. There is NO separate Dialog slider.
-- Never write MasterVolume or the MasterSoundEffects enable switch.
--
-- The volumes are client CVars, saved with the game's settings, so every value this file
-- lowers is written down first: at logout it is put back directly, and if the session ended
-- without a logout (a crash, a killed client) the next login puts it back from the copy.
OtherSounds = {}

local CHANNELS = { "Music", "Ambience", "SFX" }
local CVARS = { Music = "MusicVolume", Ambience = "AmbienceVolume", SFX = "SoundVolume" }
local FADE_SECONDS, STEP = .8, .05
-- How long the queue may sit silent before the volumes come back. Longer than the gap between
-- two queued lines, which would otherwise pump the music down and up again between them.
local SETTLE_SECONDS = 1.2
-- Below this a difference is the CVar's own rounding, not the player moving a slider.
local EPSILON = .005

local function Config()
    local audio = Addon.db and Addon.db.profile and Addon.db.profile.Audio
    return audio and audio.LowerOthers
end
local function CVar(channel) return CVARS[channel] end
local function Read(channel)
    if not CVar(channel) or type(GetCVar) ~= "function" then return nil end
    local ok, value = pcall(GetCVar, CVar(channel))
    local n = ok and tonumber(value) or nil
    if n and n >= 0 and n <= 1 then return n end
    return nil
end
local function Fraction(value)
    return math.max(0, math.min(1, tonumber(value) or 1))
end

function OtherSounds:IsAvailable()
    if not Version.IsLegacyVanilla or Config() == nil
        or type(SetCVar) ~= "function" then return false end
    for _, channel in ipairs(CHANNELS) do
        if Read(channel) ~= nil then return true end
    end
    return false
end

-- What each lowered channel goes back to, and what this file last set it to. A channel whose
-- volume no longer matches what was set has been moved by the player, and is theirs again.
OtherSounds.original, OtherSounds.applied = {}, {}
OtherSounds.manualClip = {} -- do not reacquire a channel the player just adjusted
OtherSounds.writing = false

local function Persist()
    local db = Addon.db and Addon.db.global
    if not db then return end
    local copy
    for channel, value in pairs(OtherSounds.original) do
        copy = copy or {}
        -- Save the last value WE applied, not just the baseline. This
        -- prevents recovering over a player change after a client crash.
        copy[channel] = { original = value, applied = OtherSounds.applied[channel] }
    end
    db.LoweredVolumes = copy
end

-- Forget any channel the player has moved since it was last set.
local function Release()
    local released = false
    for channel, value in pairs(OtherSounds.applied) do
        local current = Read(channel)
        if current == nil or math.abs(current - value) > EPSILON then
            OtherSounds.original[channel], OtherSounds.applied[channel] = nil, nil
            OtherSounds.manualClip[channel] = SoundQueue:GetCurrentSound()
            released = true
        end
    end
    if released then Persist() end
end

local function Set(channel, value)
    if not OtherSounds.original[channel] then return end
    local previous = OtherSounds.applied[channel]
    local current = Read(channel)
    if current == nil or (previous and math.abs(current - previous) > EPSILON) then
        Release()
        return
    end
    local target = Fraction(value)
    OtherSounds.applied[channel] = target
    Persist() -- save expected value before a possibly interrupted CVar write
    OtherSounds.writing = true
    local ok = pcall(SetCVar, CVar(channel), target)
    OtherSounds.writing = false
    if not ok then
        OtherSounds.applied[channel] = previous
        Release()
        return
    end
    local applied = Read(channel)
    if applied == nil or math.abs(applied - target) > EPSILON then
        Release()
    else
        OtherSounds.applied[channel] = applied
        Persist()
    end
end

local function CancelTimer(owner, field)
    if owner[field] then
        Addon:CancelTimer(owner[field])
        owner[field] = nil
    end
end

function OtherSounds:StopFade()
    CancelTimer(self, "fadeTimer")
end

--- Slide every channel that has an original towards `targets`, then call `done`.
function OtherSounds:FadeTo(targets, done)
    self:StopFade()
    Release()
    local from, progress = {}, 0
    for channel in pairs(self.original) do
        local start = Read(channel)
        -- A channel already where it is going -- the voice's own, or one left at 100% -- is not
        -- rewritten every step. It is still marked as set at this level, so the player moving it
        -- mid-line makes it theirs (Release) just as it would one that is fading.
        if start and targets[channel] ~= nil and math.abs(targets[channel] - start) > EPSILON then
            from[channel] = start
        else
            self.applied[channel] = start
        end
    end
    local function Step()
        progress = math.min(1, progress + STEP / FADE_SECONDS)
        Release()
        for channel, start in pairs(from) do
            if self.original[channel] then
                Set(channel, start + (targets[channel] - start) * progress)
            end
        end
        if progress >= 1 then
            self:StopFade()
            if done then done() end
        end
    end
    self.fadeTimer = Addon:ScheduleRepeatingTimer(Step, STEP)
    Step()
end

--- The level each channel goes to while `voice` speaks: its original times its setting, and
--- the voice's own channel left alone. Master carries the voice itself, so it never moves.
function OtherSounds:Targets(voice)
    local cfg, targets = Config(), {}
    for channel, value in pairs(self.original) do
        targets[channel] = channel == voice and value or value * Fraction(cfg[channel])
    end
    return targets
end

function OtherSounds:Lower(voice)
    if not self.lowered then
        self.lowered = true
        self.original, self.applied = {}, {}
        for _, channel in ipairs(CHANNELS) do
            -- If the player overrode a channel during this same clip, leave it.
            if self.manualClip[channel] ~= SoundQueue:GetCurrentSound() then
                local value = Read(channel)
                if value ~= nil then
                    self.original[channel] = value
                    self.applied[channel] = value
                end
            end
        end
        Persist()
    end
    self.voice, self.restoring = voice, false
    self:FadeTo(self:Targets(voice))
end

function OtherSounds:Restore(immediately)
    if not self.lowered then return end
    CancelTimer(self, "settleTimer")
    self.restoring = true
    local function Finished()
        self.lowered, self.voice, self.restoring = false, nil, false
        self.original, self.applied = {}, {}
        Persist()
    end
    if immediately then
        self:StopFade()
        Release()
        for channel, value in pairs(self.original) do
            if self.applied[channel] and math.abs((Read(channel) or -1) - self.applied[channel]) <= EPSILON then
                Set(channel, value)
            end
        end
        Finished()
        return
    end
    self:FadeTo(self.original, Finished)
end

--- Lowered while something is actually speaking, so a pause, a line held for combat or a line of
--- words with no voice lets the game be heard. Called on every queue change.
function OtherSounds:Sync()
    local cfg = Config()
    if not cfg then return end
    local head = SoundQueue:GetCurrentSound()
    if cfg.Enabled and head and not head.textOnly and SoundQueue:IsPlaying() then
        CancelTimer(self, "settleTimer")
        -- Use the channel actually selected at native PlaySoundFile time:
        -- the settings can change while a recording is already playing.
        local voice = head.playbackChannel or (head.source and head.source:GetChannel()) or "Master"
        -- Also when the volumes are on their way back up: a line that starts then turns
        -- them down again from wherever the fade had reached.
        if not self.lowered or self.restoring or voice ~= self.voice then self:Lower(voice) end
    elseif self.lowered and not self.restoring and not self.settleTimer then
        -- Switched off mid-line: back at once, rather than after the line that is ending.
        if not cfg.Enabled then self:Restore(); return end
        self.settleTimer = Addon:ScheduleTimer(function()
            self.settleTimer = nil
            self:Restore()
        end, SETTLE_SECONDS)
    end
end

--- A level moved in the settings while a line speaks applies at once.
function OtherSounds:RefreshConfig()
    if self.lowered and Config() and Config().Enabled then
        self:FadeTo(self:Targets(self.voice))
    else
        self:Sync()
    end
end

--- Volumes a previous session lowered and never put back: it ended without a logout.
function OtherSounds:RestoreLeftovers()
    local leftover = Addon.db.global.LoweredVolumes
    if type(leftover) ~= "table" or self.lowered then return end
    for channel, entry in pairs(leftover) do
        local baseline = type(entry) == "table" and tonumber(entry.original) or nil
        local lastApplied = type(entry) == "table" and tonumber(entry.applied) or nil
        local current = Read(channel)
        if baseline and lastApplied and current
            and math.abs(current - lastApplied) <= EPSILON then
            pcall(SetCVar, CVar(channel), Fraction(baseline))
        end
    end
    -- Convert existing single-effects prototype recovery snapshots too.
    local old = Addon.db.global.SFXDuckingRecovery
    if type(old) == "table" and not leftover.SFX then
        local current = Read("SFX")
        local baseline = tonumber(old.original)
        local applied = tonumber(old.applied)
        if current and baseline and applied and math.abs(current - applied) <= EPSILON then
            pcall(SetCVar, CVar("SFX"), Fraction(baseline))
        end
    end
    Addon.db.global.SFXDuckingRecovery = nil
    Addon.db.global.LoweredVolumes = nil
end

Callbacks:Register("AUDIO_CHANGED", function() OtherSounds:Sync() end)
Callbacks:Register("CLIP_STARTED", function() OtherSounds:Sync() end)
Callbacks:Register("QUEUE_EMPTY", function() OtherSounds:Sync() end)

-- PLAYER_LOGOUT fires on /reload too, and the client writes its CVars after it: putting the
-- volumes back here is what keeps a reload mid-line from saving them lowered. Gated on what was
-- lowered, never on the settings: AceDB's own handler runs first and strips every setting still
-- at its default, so a player who never moved these levels has none left by now.
local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_LOGOUT")
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGOUT" then
        OtherSounds:Restore(true)
    elseif Addon.db then
        OtherSounds:RestoreLeftovers()
    end
end)
