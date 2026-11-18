-- Thin Books adapter over SoftSpoken's shared language rules.
-- The Books audio/index code keeps its existing method names and pack format.
local Writings = SSB
local Shared = Spoken.Language

Writings.LOCALES = Shared.LOCALES
Writings.BASE_LANGUAGE = Shared.BASE
Writings.AUTO_LANGUAGE = Shared.AUTO

function Writings:NormalizeLanguage(code)
    return Shared:Normalize(code)
end

function Writings:GetLanguageName(code)
    return Shared:GetNativeName(code)
end

function Writings:IsClientLanguage(code)
    return Shared:IsClientLanguage(code)
end

function Writings:GetClientLanguage()
    return Shared:GetClientLanguage()
end

function Writings:GetVoiceLanguage()
    return Shared:ResolveVoice(SSBSettings and SSBSettings.voiceLanguage)
end

function Writings:GetFallbackLanguage()
    return Shared:ResolveFallback(SSBSettings and SSBSettings.fallbackLanguage)
end

function Writings:LanguageOrder()
    return Shared:ResolutionOrder(SSBSettings and SSBSettings.voiceLanguage,
                                  SSBSettings and SSBSettings.fallbackLanguage)
end

function Writings:PackLanguage(pack)
    return Shared:Normalize(pack and pack.language)
end
