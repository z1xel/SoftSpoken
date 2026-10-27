setfenv(1, VoiceOver)

-- Quests preserves its historical Language interface and VoiceOver environment.
-- Locale metadata and selection rules are shared with the core; quest pack
-- discovery and the client-locale gossip lookup stay here in Quests.
Language = {}
local Shared = Spoken.Language
Language.LOCALES = Shared.LOCALES
Language.BASE = Shared.BASE
Language.AUTO = Shared.AUTO

function Language:GetName(code)
    return Shared:GetName(code)
end

function Language:GetNativeName(code)
    return Shared:GetNativeName(code)
end

function Language:Normalize(code)
    return Shared:Normalize(code)
end

function Language:IsClientLanguage(code)
    return Shared:IsClientLanguage(code)
end

function Language:GetClientLanguage()
    return Shared:GetClientLanguage()
end

function Language:GetVoiceLanguage()
    local legacy = Addon and Addon.db and Addon.db.profile.Audio.VoiceLanguage
    return Shared:ResolveVoice(legacy)
end

function Language:GetFallbackLanguage()
    local legacy = Addon and Addon.db and Addon.db.profile.Audio.FallbackLanguage
    return Shared:ResolveFallback(legacy)
end

function Language:ResolutionOrder()
    local audio = Addon and Addon.db and Addon.db.profile.Audio
    return Shared:ResolutionOrder(audio and audio.VoiceLanguage,
                                  audio and audio.FallbackLanguage)
end
