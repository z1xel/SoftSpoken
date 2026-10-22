setfenv(1, SpokenEnv)

-- Shared language identifiers and selection policy for every voice source.
-- A client's text language, the player's preferred voice, and a pack's
-- recorded language are separate concepts. Each feature resolves its OWN packs.
-- This table is public through Spoken.Language; it never touches module DBs.
local Language = {}
Spoken.Language = Language

Language.BASE = "enUS"
Language.AUTO = "auto"
Language.LOCALES = {
    { code = "enUS", name = "English", native = "English" },
    { code = "deDE", name = "German", native = "Deutsch" },
    { code = "esES", name = "Spanish (EU)", native = "Español (España)" },
    { code = "esMX", name = "Spanish (AL)", native = "Español (América Latina)" },
    { code = "frFR", name = "French", native = "Français" },
    { code = "itIT", name = "Italian", native = "Italiano", client = false },
    { code = "ptBR", name = "Portuguese", native = "Português" },
    { code = "ruRU", name = "Russian", native = "Русский" },
    { code = "koKR", name = "Korean", native = "한국어" },
    { code = "zhCN", name = "Chinese (S)", native = "简体中文" },
    { code = "zhTW", name = "Chinese (T)", native = "繁體中文" },
}

local byCode = {}
for _, locale in ipairs(Language.LOCALES) do
    byCode[locale.code] = locale
end

function Language:IsSupported(code)
    return code ~= nil and byCode[code] ~= nil
end

-- Unknown or undeclared pack languages mean English, including older packs.
function Language:Normalize(code)
    if self:IsSupported(code) then return code end
    return self.BASE
end

function Language:GetName(code)
    local locale = code and byCode[code]
    return locale and locale.name or tostring(code)
end

function Language:GetNativeName(code)
    local locale = code and byCode[code]
    return locale and (locale.native or locale.name) or tostring(code)
end

function Language:IsClientLanguage(code)
    local locale = code and byCode[code]
    return locale ~= nil and locale.client ~= false
end

function Language:GetClientLanguage()
    local code = GetLocale and GetLocale()
    -- Older English clients can report enGB. Voice packs use enUS.
    if code == "enGB" then return self.BASE end
    if self:IsClientLanguage(code) then return code end
    return self.BASE
end

-- An explicit core preference supersedes a module's legacy preference.
-- The core DB leaves each field nil until its own selection is made.
function Language:ResolveVoice(localPreference)
    local shared = Spoken.GetLanguageChoice and Spoken:GetLanguageChoice()
    local selected = shared or localPreference
    if selected == nil or selected == self.AUTO or not self:IsSupported(selected) then
        return self:GetClientLanguage()
    end
    return selected
end

function Language:ResolveFallback(localPreference)
    local shared
    if Spoken.GetLanguageChoice then
        local ignored
        ignored, shared = Spoken:GetLanguageChoice()
    end
    local selected = shared or localPreference
    if selected == nil then return self.BASE end
    if selected == "none" or not self:IsSupported(selected) then return nil end
    return selected
end

function Language:ResolutionOrder(voicePreference, fallbackPreference)
    local voice = self:ResolveVoice(voicePreference)
    local fallback = self:ResolveFallback(fallbackPreference)
    local order = { voice }
    if fallback and fallback ~= voice then table.insert(order, fallback) end
    return order
end
