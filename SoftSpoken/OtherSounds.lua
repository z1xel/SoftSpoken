setfenv(1, SpokenEnv)

-- Vanilla 1.12 voice-first mixing. Unlike modern Spoken's Sound_SFXVolume,
-- original Vanilla uses SoundVolume for the Sound Effects slider.
-- Never toggle MasterSoundEffects, never lower MasterVolume, and never
-- lower the category carrying the actual narration file.
OtherSounds = {
    original = nil, applied = nil, lowered = false, restoring = false,
    voiceChannel = nil, fadeTimer = nil, settleTimer = nil, writing = false,
}

local CVAR = "SoundVolume"
local FADE_SECONDS, STEP_SECONDS = 0.8, 0.05
local SETTLE_SECONDS, EPSILON = 1.2, 0.006

local function Settings()
    local db = Addon and Addon.db
    local audio = db and db.profile and db.profile.Audio
    return audio and audio.SFXDucking
end

local function Read()
    if type(GetCVar) ~= "function" then return nil end
    local n = tonumber(GetCVar(CVAR))
    if not n or n < 0 or n > 1 then return nil end
    return n
end

local function Clamp(value)
    value = tonumber(value) or 1
    return math.max(0, math.min(1, value))
end

function OtherSounds:Persist()
    if not (Addon and Addon.db and Addon.db.global) then return end
    if self.original ~= nil then
        Addon.db.global.SFXDuckingRecovery = {
            original = self.original, applied = self.applied,
        }
    else
        Addon.db.global.SFXDuckingRecovery = nil
    end
end

function OtherSounds:IsAvailable()
    return type(SetCVar) == "function" and Read() ~= nil
        and Version and Version.IsLegacyVanilla
end

function OtherSounds:Cancel(field)
    if self[field] then
        Addon:CancelTimer(self[field])
        self[field] = nil
    end
end

-- A changed game slider belongs to the player, not us. Stop writing and
-- abandon our restore snapshot rather than reverting their new preference.
function OtherSounds:ReleaseIfChanged()
    if self.original == nil or self.applied == nil then return false end
    local current = Read()
    if current == nil or math.abs(current - self.applied) > EPSILON then
        self:Cancel("fadeTimer")
        self:Cancel("settleTimer")
        self.original, self.applied = nil, nil
        self.lowered, self.restoring, self.voiceChannel = false, false, nil
        self:Persist()
        return true
    end
    return false
end

function OtherSounds:Write(value)
    if self.original == nil or self:ReleaseIfChanged() then return false end
    local target = Clamp(value)
    self.applied = target -- protects synchronous CVAR_UPDATE in the client
    self:Persist()
    self.writing = true
    local ok = pcall(SetCVar, CVAR, target)
    self.writing = false
    local actual = Read()
    if not ok or actual == nil or math.abs(actual - target) > EPSILON then
        self:ReleaseIfChanged()
        return false
    end
    self.applied = actual
    self:Persist()
    return true
end

function OtherSounds:FadeTo(target, done)
    self:Cancel("fadeTimer")
    if self:ReleaseIfChanged() or self.original == nil then return end
    local start = Read()
    if start == nil then return end
    target = Clamp(target)
    if math.abs(target - start) < EPSILON then
        if done then done() end
        return
    end
    local progress = 0
    local function Step()
        if self.original == nil then return end
        progress = math.min(1, progress + STEP_SECONDS / FADE_SECONDS)
        if not self:Write(start + (target - start) * progress) then
            self:Cancel("fadeTimer")
            return
        end
        if progress >= 1 then
            self:Cancel("fadeTimer")
            if done then done() end
        end
    end
    self.fadeTimer = Addon:ScheduleRepeatingTimer(Step, STEP_SECONDS)
    Step()
end

function OtherSounds:Lower(channel)
    local cfg = Settings()
    if not cfg or not cfg.Enabled or not self:IsAvailable() then return end
    if channel == "SFX" then
        self:Restore(true)
        return
    end
    self:Cancel("settleTimer")
    if not self.lowered then
        self.original = Read()
        if self.original == nil then return end
        self.applied = self.original
        self.lowered = true
        self:Persist() -- record the baseline BEFORE any volume write
    end
    self.restoring = false
    self.voiceChannel = channel
    self:FadeTo(self.original * Clamp(cfg.Level))
end

function OtherSounds:Restore(immediate)
    self:Cancel("settleTimer")
    if not self.lowered then return end
    if self:ReleaseIfChanged() then return end
    self.restoring = true
    local function Done()
        self.lowered, self.restoring, self.voiceChannel = false, false, nil
        self.original, self.applied = nil, nil
        self:Persist()
    end
    if immediate then
        self:Cancel("fadeTimer")
        if self:Write(self.original) then Done() end
    else
        self:FadeTo(self.original, Done)
    end
end

function OtherSounds:Sync()
    local cfg = Settings()
    if not cfg or not cfg.Enabled then
        self:Restore(true)
        return
    end
    local clip = SoundQueue:GetCurrentSound()
    local speaking = clip and SoundQueue:IsPlaying(clip) and not clip.textOnly
    if speaking then
        -- Source channel can change while an MP3 is already speaking.
        -- The active handle's original category, not the new preference,
        -- is the one that must never be ducked.
        local channel = clip.playbackChannel or
            (clip.source and clip.source:GetChannel()) or "Master"
        if channel == "SFX" then
            self:Restore(true)
        else
            self:Cancel("settleTimer")
            if not self.lowered or self.restoring or self.voiceChannel ~= channel
                or self:ReleaseIfChanged() then
                self:Lower(channel)
            end
        end
    elseif self.lowered and not self.restoring and not self.settleTimer then
        -- Avoid volume pumping across the normal queue's short inter-line gap.
        self.settleTimer = Addon:ScheduleTimer(function()
            self.settleTimer = nil
            if self.lowered then self:Restore(false) end
        end, SETTLE_SECONDS)
    end
end

function OtherSounds:RefreshConfig()
    local cfg = Settings()
    if not cfg or not cfg.Enabled then
        self:Restore(true)
    elseif self.lowered and not self:ReleaseIfChanged() and not self.restoring then
        self:FadeTo(self.original * Clamp(cfg.Level))
    else
        self:Sync()
    end
end

function OtherSounds:RestoreLeftovers()
    local db = Addon and Addon.db and Addon.db.global
    local record = db and db.SFXDuckingRecovery
    if type(record) ~= "table" or self.lowered then return end
    local original, applied = tonumber(record.original), tonumber(record.applied)
    local current = Read()
    -- A crash/reload may leave SoundVolume lowered. Only restore if it
    -- STILL matches our most recent value; otherwise user edits win.
    if original and original >= 0 and original <= 1 and applied
        and current and math.abs(current - applied) <= EPSILON then
        pcall(SetCVar, CVAR, original)
    end
    db.SFXDuckingRecovery = nil
end

Callbacks:Register("CLIP_STARTED", function() OtherSounds:Sync() end)
Callbacks:Register("CLIP_STOPPED", function() OtherSounds:Sync() end)
Callbacks:Register("CLIP_DROPPED", function() OtherSounds:Sync() end)
Callbacks:Register("AUDIO_CHANGED", function() OtherSounds:Sync() end)
Callbacks:Register("QUEUE_EMPTY", function() OtherSounds:Sync() end)

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_LOGOUT")
events:RegisterEvent("CVAR_UPDATE")
events:SetScript("OnEvent", function(_, emitted, name)
    local e = emitted or event -- original 1.12 supplies global 'event'
    if e == "PLAYER_LOGOUT" then
        OtherSounds:Restore(true)
    elseif e == "PLAYER_LOGIN" then
        OtherSounds:RestoreLeftovers()
    elseif e == "CVAR_UPDATE" then
        local cvar = name or arg1
        -- Never seize control of a slider that someone adjusted mid-voice.
        if not OtherSounds.writing and
            type(cvar) == "string" and string.lower(cvar) == string.lower(CVAR) then
            OtherSounds:ReleaseIfChanged()
        end
    end
end)
