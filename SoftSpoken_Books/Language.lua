-- Thin Books adapter over SoftSpoken's shared language rules.
-- The Books audio/index code keeps its existing method names and pack format.
local SpokenBooks = SSB
local Shared = Spoken.Language

SpokenBooks.LOCALES = Shared.LOCALES
SpokenBooks.BASE_LANGUAGE = Shared.BASE
SpokenBooks.AUTO_LANGUAGE = Shared.AUTO

function SpokenBooks:NormalizeLanguage(code)
    return Shared:Normalize(code)
end

function SpokenBooks:GetLanguageName(code)
    return Shared:GetNativeName(code)
end

function SpokenBooks:IsClientLanguage(code)
    return Shared:IsClientLanguage(code)
end

function SpokenBooks:GetClientLanguage()
    return Shared:GetClientLanguage()
end

function SpokenBooks:GetVoiceLanguage()
    return Shared:ResolveVoice(SSBSettings and SSBSettings.voiceLanguage)
end

function SpokenBooks:GetFallbackLanguage()
    return Shared:ResolveFallback(SSBSettings and SSBSettings.fallbackLanguage)
end

function SpokenBooks:LanguageOrder()
    return Shared:ResolutionOrder(SSBSettings and SSBSettings.voiceLanguage,
                                  SSBSettings and SSBSettings.fallbackLanguage)
end

function SpokenBooks:PackLanguage(pack)
    return Shared:Normalize(pack and pack.language)
end
