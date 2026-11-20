setfenv(1, SpokenEnv)

-- SoftSpoken's 1.12 audio transport requires ClassicAPI. The minimum is a
-- deliberately pinned, released sound-API baseline (see docs/audio-api.md).
-- A bare Vanilla PlaySoundFile result is not a playback handle.
SoundUtils = {}

local MIN_CLASSIC_API_VERSION = 11814  -- v1.18.14
local ownedHandles = setmetatable({}, { __mode = "k" })

function SoundUtils:BackendError()
    local version = tonumber(CLASSIC_API_VERSION)
    if not version then
        return "ClassicAPI v1.18.14 or newer is required for SoftSpoken narration"
    end
    if version < MIN_CLASSIC_API_VERSION then
        return "Update ClassicAPI to v1.18.14 or newer for SoftSpoken narration"
    end
    if type(PlaySoundFile) ~= "function" or type(StopSound) ~= "function"
        or type(C_Sound) ~= "table" or type(C_Sound.IsPlaying) ~= "function" then
        return "ClassicAPI sound functions are unavailable; check the loaded DLL"
    end
    return nil
end

-- No independent Dialog channel exists in the 1.12 engine. In particular,
-- toggling MasterSoundEffects to silence an NPC also stops unrelated game SFX.
-- We do not do that; targeted NPC handling belongs to issue #63.
-- Keep the no-op hook for the existing public Spoken:MuteChannel API.
function SoundUtils:MuteChannel(channel, muted, fadeOut)
end

function SoundUtils:WhyInaudible(channel)
    local errorMessage = self:BackendError()
    if errorMessage then return errorMessage end
    -- ClassicAPI's "Master" channel is not the SFX slider. A disabled SFX
    -- category only prevents narration if a source explicitly uses SFX.
    if (channel == "SFX" or channel == nil)
        and tonumber(GetCVar("MasterSoundEffects")) ~= 1 then
        return "sound effects are disabled"
    end
    return nil
end

function SoundUtils:IsSoundEnabled(channel)
    return self:WhyInaudible(channel) == nil
end

-- Never probe a file by playing it: start failure is ambiguous between
-- a missing recording and native sound-bus contention.

function SoundUtils:PlaySound(clip, channel)
    -- A second start on the same clip must not overwrite a live owned handle.
    if ownedHandles[clip] then return false, nil end
    clip.handle = nil
    if self:BackendError() then return false, nil end
    if type(clip.path) ~= "string" or clip.path == "" then return false, nil end

    -- ClassicAPI returns *two* values. Do not interpret Vanilla's one-value
    -- success as a handle and never invent a placeholder handle.
    local ok, willPlay, handle = pcall(PlaySoundFile, clip.path, channel or "Master")
    if not ok or willPlay ~= true or type(handle) ~= "number" or handle <= 0 then
        return false, nil
    end
    ownedHandles[clip] = handle
    clip.handle = handle
    return true, handle
end

-- A three-valued query: true (playing), false (ended), nil (native API
-- error / no ownership). Never query arbitrary, unowned or stale clip handles.
function SoundUtils:IsSoundPlaying(clip)
    local handle = ownedHandles[clip]
    if not handle or clip.handle ~= handle then return nil end
    if not C_Sound or type(C_Sound.IsPlaying) ~= "function" then return nil end
    local ok, playing = pcall(C_Sound.IsPlaying, handle)
    if not ok or type(playing) ~= "boolean" then return nil end
    return playing
end

function SoundUtils:PlayCue(channel)
    PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE)
end

-- Called only when playback is known to have completed naturally. Do not
-- stop the engine: just release the association with this clip.
function SoundUtils:ReleaseSound(clip)
    ownedHandles[clip] = nil
    clip.handle = nil
end

function SoundUtils:StopSound(clip, fadeMs)
    local handle = ownedHandles[clip]
    if not handle or clip.handle ~= handle then
        -- Never call the engine with an untracked, reused or placeholder handle.
        self:ReleaseSound(clip)
        return false
    end

    local ok = pcall(StopSound, handle, fadeMs or 0)
    self:ReleaseSound(clip)
    return ok
end
