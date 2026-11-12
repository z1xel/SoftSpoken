-- ClassicAPI v1.19 native StatusBar + duration progress, with a mocked 1.12 UI.
-- Run: lua5.1 tests/audio_progress_ui.lua
local style, visible, now = "classic", true, 3.5
local config = { Frame = { HidePortrait = false }, Transcript = { SubtitleProgress = true } }
local current = { key = "a", length = 10, playbackStartedAt = 0,
    playbackAttempt = 1, estimate = 0.35, speaking = true }
local scheduled = {}
local function eq(a, b) assert(a == b, tostring(a) .. " ~= " .. tostring(b)) end

local function Texture()
    local t = { shown = true, anchors = {} }
    function t:SetTexture(...) self.texture = {...} end
    function t:SetColorTexture(...) self.texture = {...} end
    function t:SetAllPoints(target) self.allPoints = target end
    function t:SetHeight(n) self.height = n end
    function t:SetWidth(n) self.width = n end
    function t:SetSize(w, h) self.width, self.height = w, h end
    function t:SetAlpha(n) self.alpha = n end
    function t:SetBlendMode(v) self.blend = v end
    function t:SetPoint(...) table.insert(self.anchors, {...}) end
    function t:ClearAllPoints() self.anchors = {} end
    function t:SetShown(v) self.shown = v end
    function t:Show() self.shown = true end
    function t:Hide() self.shown = false end
    return t
end

local frame = { scripts = {} }
function frame:SetScript(name, fn) self.scripts[name] = fn end
function frame:IsShown() return visible end
local created = {}
local function CreateFrame(kind)
    eq(kind, "StatusBar")
    local bar = { textures = {}, anchors = {}, shown = true, timerCount = 0 }
    function bar:CreateTexture()
        local t = Texture()
        table.insert(self.textures, t)
        return t
    end
    function bar:SetHeight(n) self.height = n end
    function bar:SetPoint(...) table.insert(self.anchors, {...}) end
    function bar:ClearAllPoints() self.anchors = {} end
    function bar:SetStatusBarTexture(t) self.statusBarTexture = t end
    function bar:SetMinMaxValues(min, max)
        self.min, self.max = min, max
        self.timer = nil
    end
    function bar:SetValue(v) self.value = v end
    function bar:SetTimerDuration(d, interpolation, direction)
        self.timer = d
        self.interpolation = interpolation
        self.direction = direction
        self.timerCount = self.timerCount + 1
    end
    function bar:SetShown(value) self.shown = value end
    table.insert(created, bar)
    return bar
end

local fonts = {}
local function Font()
    local f = {}
    function f:SetFont(path, size, flags)
        self.path, self.size, self.flags = path, size, flags
    end
    return setmetatable(f, {__index = function() return function() end end})
end

SpokenEnv = setmetatable({
    Addon = {
        Profile = function(self, name) return config[name] end,
        DisplayStyle = function() return style end,
        ScheduleTimer = function(self, fn, delay)
            local task = { fn = fn, delay = delay }
            table.insert(scheduled, task)
            return task
        end,
        CancelTimer = function(self, task)
            task.cancelled = true
        end
    },
    SoundQueue = {
        ProgressShare = function(self, clip) return clip.estimate end,
        IsPlaying = function(self, clip) return clip and clip.speaking or false end
    },
    Version = { IsLegacyVanilla = true },
    C_DurationUtil = {
        CreateDuration = function()
            local duration = {}
            function duration:SetTimeFromStart(start, total)
                self.start, self.total = start, total
            end
            return duration
        end
    },
    Enum = {
        StatusBarInterpolation = { Immediate = 0, ExponentialEaseOut = 1 },
        StatusBarTimerDirection = { ElapsedTime = 0, RemainingTime = 1 }
    },
    GetTime = function() return now end,
    CreateFrame = CreateFrame,
    CreateFont = function(name)
        local font = Font()
        fonts[name] = font
        return font
    end,
    GameFontNormal = { GetFont = function() return "Fonts\\FRIZQT__.TTF" end }
}, {__index = _G})

dofile("SoftSpoken/UI/PlayerFrame.lua")
eq(fonts.SpokenNameFont.path, "Fonts\\MORPHEUS.TTF")
eq(fonts.SpokenNameFont.size, 22)
eq(fonts.SpokenNameFont.flags, "")
eq(fonts.SpokenRowFont.path, "Fonts\\FRIZQT__.TTF")
local p = SpokenEnv.PlayerFrame
p.frame = frame
p.Current = function() return current end
p:InitProgress()
local progress = p.progress
local bar = progress.bar
eq(#created, 1)
eq(#bar.textures, 3)
eq(bar.height, 2)
eq(bar.anchors[1][4], 135)
eq(bar.statusBarTexture, progress.fill)
eq(progress.track.allPoints, bar)
eq(progress.fill.texture[1], 1)
eq(progress.spark.texture[1], [[Interface\CastingBar\UI-CastingBar-Spark]])
eq(frame.scripts.OnUpdate, nil) -- native duration, not a Lua per-frame driver

p:UpdateProgress()
eq(bar.shown, true)
eq(bar.timerCount, 1)
eq(bar.timer.start, 0)
eq(bar.timer.total, 10)
eq(bar.interpolation, 0)
eq(bar.direction, 0)
eq(progress.spark.shown, true)
eq(#scheduled, 1)
assert(math.abs(scheduled[1].delay - 6.3) < 0.001)

-- Refreshing an active line must not restart the timer from zero.
p:UpdateProgress()
eq(bar.timerCount, 1)
eq(#scheduled, 1)

-- The timer is held below 100% before a short metadata estimate runs out.
now = 9.8
scheduled[1].fn()
eq(bar.timer, nil)
eq(bar.value, 0.985)
eq(progress.mode, "capped")
eq(progress.spark.shown, true)
p:UpdateProgress()
eq(bar.value, 0.985)
eq(bar.timerCount, 1)

-- Once native playback ends, a gap-state progress refresh is 100%.
current.speaking = false
current.estimate = 1
p:UpdateProgress()
eq(bar.value, 1)
eq(progress.spark.shown, false)

-- Replaying the same clip is a new attempt with a fresh clock and binding.
current.playbackAttempt = 2
current.playbackStartedAt = 11
current.estimate = 0.1
current.speaking = true
now = 12
p:UpdateProgress()
eq(bar.timerCount, 2)
eq(bar.timer.start, 11)

-- Paused or held audio freezes to the queue's estimated share.
current.speaking = false
current.estimate = 0.4
p:UpdateProgress()
eq(bar.timer, nil)
eq(bar.value, 0.4)
eq(progress.spark.shown, false)
assert(scheduled[2].cancelled)

-- Span progress binds the native timer to the whole Writings sequence.
current.playbackAttempt = 3
current.playbackStartedAt = 20
current.length = 4
current.span = { before = 3, total = 10 }
current.estimate = 0.31
current.speaking = true
now = 20.1
p:UpdateProgress()
eq(bar.timer.start, 17)
eq(bar.timer.total, 10)
eq(bar.timerCount, 3)
local oldGuard = scheduled[3]

-- Switching clips invalidates the old cap callback.
current = { key = "b", playbackAttempt = 1, playbackStartedAt = 25,
    length = 8, estimate = 0.05, speaking = true }
now = 25.4
p:UpdateProgress()
assert(oldGuard.cancelled)
eq(bar.timerCount, 4)
oldGuard.fn()
eq(bar.timerCount, 4)
eq(progress.mode, "native")

-- Missing duration: track remains, but no fabricated fill/spark.
current.length = nil
current.estimate = nil
p:UpdateProgress()
eq(bar.value, 0)
eq(progress.spark.shown, false)
eq(bar.timer, nil)

-- Toggle off, Voice Only, and hidden windows suppress all artwork.
current.length = 8
current.estimate = 0.4
config.Transcript.SubtitleProgress = false
p:UpdateProgress()
eq(bar.shown, false)
config.Transcript.SubtitleProgress = true
style = "none"
p:UpdateProgress()
eq(bar.shown, false)
style = "classic"
visible = false
p:UpdateProgress()
eq(bar.shown, false)

-- Original portrait/no-portrait geometry is unchanged.
visible = true
config.Frame.HidePortrait = true
p:LayoutProgress()
eq(bar.anchors[1][4], 20)
p:UpdateProgress()
eq(bar.shown, true)

-- Before 1.19, the audio backend can still play; this optional meter
-- uses a static estimate rather than attempting nonexistent timer APIs.
SpokenEnv.C_DurationUtil = nil
current.playbackAttempt = 2
current.estimate = 0.45
p:UpdateProgress()
eq(bar.timer, nil)
eq(bar.value, 0.45)

local file = assert(io.open("SoftSpoken/Transcript.lua", "r"))
local transcript = file:read("*a")
file:close()
assert(not transcript:find("seconds > self.duration"))
assert(transcript:find('Callbacks:Register%("CLIP_STOPPED"'))

-- Keep the baked Neutral Talking Heads textures loadable by the 1.12 client.
-- These are uncompressed 128x128, 32-bit, top-left-origin TGA files.
local function CheckTalkingHeadArt(path, isBorder)
    local file = assert(io.open(path, "rb"), "Missing packaged texture: " .. path)
    local data = file:read("*a")
    file:close()
    eq(#data, 18 + 128 * 128 * 4)
    eq(data:byte(3), 2)       -- Uncompressed true-color TGA
    eq(data:byte(13), 128)    -- Width (little-endian)
    eq(data:byte(14), 0)
    eq(data:byte(15), 128)    -- Height (little-endian)
    eq(data:byte(16), 0)
    eq(data:byte(17), 32)     -- BGRA
    eq(data:byte(18), 40)     -- 8 alpha bits, top-left origin
    local function AlphaAt(x, y)
        return data:byte(22 + (y * 128 + x) * 4)
    end
    if isBorder then
        eq(AlphaAt(64, 64), 0) -- Transparent aperture for the 3D model
        assert(AlphaAt(1, 64) > 0)
    else
        assert(AlphaAt(64, 64) > 0)
    end
end
CheckTalkingHeadArt("SoftSpoken/Textures/TalkingHeads/PortraitNeutral.tga", true)
CheckTalkingHeadArt("SoftSpoken/Textures/TalkingHeads/PortraitBg.tga", false)
local playerFile = assert(io.open("SoftSpoken/UI/PlayerFrame.lua", "r"))
local playerSource = playerFile:read("*a")
playerFile:close()
assert(playerSource:find([[TalkingHeads\\PortraitNeutral]], 1, true))
assert(playerSource:find('self.frame.portrait.background:SetTexture(TEXTURES .. "PortraitFrameBackground")', 1, true))
assert(playerSource:find('self.frame.portrait.pause.background:SetTexture(TEXTURES .. "PortraitFrameBackground")', 1, true))
assert(not playerSource:find('SetTexture(TEXTURES .. "TalkingHeads\\\\PortraitBg")', 1, true))
assert(playerSource:find('self.frame.portraitLine:SetTexture(TEXTURES .. "PortraitFrameAtlas")', 1, true))
assert(playerSource:find('self.frame.mover:SetNormalTexture(TEXTURES .. "PortraitFrameAtlas")', 1, true))

print("audio_progress_ui.lua: native duration StatusBar, lifecycle and UI assertions passed")
