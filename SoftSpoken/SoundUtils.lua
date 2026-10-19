setfenv(1, SpokenEnv)

-- Turtle WoW 1.12 has no modern sound handles or independent narration channel.
-- Keep the SoundUtils interface used by SoundQueue and feature addons.
SoundUtils = {}

-- The queue handles Vanilla NPC interruption via MasterSoundEffects, not via
-- Sound_EnableDialog. No independent Dialog channel is available on 1.12.
function SoundUtils:MuteChannel(channel, muted, fadeOut)
    -- Intentionally unsupported on this client.
end
function SoundUtils:IsMutedByPlayer(channel)
    return false
end

function SoundUtils:WhyInaudible(channel)
    if tonumber(GetCVar("MasterSoundEffects")) ~= 1 then
        return "sound effects are disabled"
    end
    return nil
end
function SoundUtils:IsSoundEnabled(channel)
    return self:WhyInaudible(channel) == nil
end

-- Vanilla PlaySoundFile accepts arbitrary paths as successes, so a probe does
-- not establish existence; voice pack indexes are responsible for that.
function SoundUtils:TestSound(clip, channel)
    return true
end
function SoundUtils:PlaySound(clip, channel)
    PlaySoundFile(clip.path)
    clip.handle = 1
    return true, clip.handle
end
function SoundUtils:PlayCue(channel)
    PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE)
end

-- Vanilla can only interrupt all effects, not a single narration file. The
-- queue's existing behavior is intentionally preserved, including the caveat
-- that this also cuts unrelated in-game sound effects.
function SoundUtils:StopSound(clip, fadeMs)
    SetCVar("MasterSoundEffects", 0)
    SetCVar("MasterSoundEffects", 1)
    clip.handle = nil
end
