-- The 1.12 Zones settings page. Presentation only: every option below is
-- already read by Zones' narration or map code. No new settings storage.
local R = SSZZonesRuntime
local Layout = SpokenLayout
local optionsPage
local optionsLayout

local function Settings()
    return R.CharDB().settings
end

local function Refresh()
    if optionsLayout then optionsLayout:Refresh() end
end

local function Build()
    if optionsPage or not (Spoken and Spoken.AddSettingsPage and Layout) then return end
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetWidth(470)
    frame:SetHeight(1)
    frame:Hide()
    local layout = Layout.New(frame, 25, -16)
    optionsLayout = layout
    layout:Intro([[Interface\Icons\INV_Misc_Map02]], "Places")

    layout:Checkbox("Enable Places", "Allow narrated zone lore to play.",
        function() return Spoken:IsPartOn("zones") end,
        function(on) Spoken:SetPartOn("zones", on) end, Refresh)

    layout:Section("Automatic Narration")
    local autoplay = layout:Checkbox("Narrate Automatically",
        "Narrate supported places while exploring Azeroth.",
        function() return Settings().auto end,
        function(on) Settings().auto = on end, Refresh)
    layout:Requires(autoplay, function() return Spoken:IsPartOn("zones") end,
        "Enable Places to use automatic narration.")
    layout:Indent()
    local subzones = layout:Checkbox("Include Subzones",
        "Narrate supported locations inside their parent zone.",
        function() return Settings().subzones end,
        function(on) Settings().subzones = on end)
    local mode = layout:Dropdown("Narrate When", "Choose the existing zone narration trigger.",
        { "discovery", "unheard" },
        function() return Settings().mode end,
        function(value) Settings().mode = value end,
        nil, function(value)
            return value == "unheard" and "Discoveries + Unheard Areas" or "Discoveries Only"
        end)
    layout:Outdent()
    -- Subzones also influence the one-time starting-area greeting, even if
    -- normal automatic narration is disabled; do not wrongly grey it out.
    layout:Requires(subzones, function() return Spoken:IsPartOn("zones") end,
        "Enable Places to configure narrated subzones.")
    layout:Requires(mode, function()
        return Spoken:IsPartOn("zones") and Settings().auto
    end, "Enable Places and automatic narration to use this.")
    local combat = layout:Checkbox("Hold During Combat",
        "Delay automatic Places narration while in combat.",
        function() return Settings().holdCombat end,
        function(on) Settings().holdCombat = on; if R.Recheck then R.Recheck() end end)
    layout:Requires(combat, function()
        return Spoken:IsPartOn("zones") and Settings().auto
    end, "Enable Places and automatic narration to use this.")
    local greeting = layout:Checkbox("Starting Character Greeting",
        "Narrate a starting-area introduction for a new level-one character.",
        function() return Settings().greeting end,
        function(on) Settings().greeting = on end)
    -- The starter greeting uses its own flag and may play when auto is off.
    layout:Requires(greeting, function() return Spoken:IsPartOn("zones") end,
        "Enable Places to use starting character greetings.")

    layout:Section("World Map")
    layout:Checkbox("Show Map Lore Panel",
        "Show the existing lore reader on the world map.",
        function() return Settings().showMapPanel ~= false end,
        function(on)
            if SSZMapPanel and SSZMapPanel.SetEnabled then
                SSZMapPanel.SetEnabled(on)
            else
                Settings().showMapPanel = on
            end
        end)

    -- World Map visibility is a display preference, not automatic audio
    -- narration. It remains configurable even when narration is switched off.
    layout:Section("Voice Packs")
    -- Same accepted registry entries as Zones playback, with extra read-only
    -- metadata. Coverage is counted only when a pack is expanded.
    layout:PackInventory(function()
        local result = {}
        for _, pack in ipairs(R.AudioPackDetails()) do
            local entry = pack
            local addon = entry.addon
            local source = entry.source
            local version = GetAddOnMetadata and GetAddOnMetadata(addon, "Version")
            local loaded = IsAddOnLoaded and IsAddOnLoaded(addon)
            local demand = IsAddOnLoadOnDemand and IsAddOnLoadOnDemand(addon)
            local fields = {
                { label = "Addon", value = addon },
                { label = "Pack Title", value = entry.title },
                { label = "Content Version", value = version },
                { label = "Data Format", value = entry.version },
                { label = "Registered", value = YES },
                { label = "Loaded", value = loaded and YES or NO },
            }
            -- Unlike Quests/Books, Zones does not always declare a language.
            if type(entry.language) == "string" and entry.language ~= "" then
                local language = entry.language
                if Spoken and Spoken.Language and Spoken.Language.GetNativeName then
                    language = Spoken.Language:GetNativeName(language)
                end
                table.insert(fields, { label = "Language", value = language })
            end
            if IsAddOnLoadOnDemand then
                table.insert(fields, { label = "Load on Demand", value = demand and YES or NO })
            end
            table.insert(result, {
                id = addon, source = source, name = entry.title,
                version = version, status = "Registered", details = fields,
                extra = function()
                    local zones, subzones = 0, 0
                    for _, recording in pairs(source.zones or {}) do
                        if type(recording) == "table" and recording.file and recording.len then
                            zones = zones + 1
                        end
                    end
                    for _, byZone in pairs(source.subzones or {}) do
                        if type(byZone) == "table" then
                            for _, recording in pairs(byZone) do
                                if type(recording) == "table" and recording.file and recording.len then
                                    subzones = subzones + 1
                                end
                            end
                        end
                    end
                    return {
                        { label = "Recorded Zones", value = zones },
                        { label = "Recorded Subzones", value = subzones },
                    }
                end,
            })
        end
        return result
    end, "No compatible Places voice packs installed.")
    layout:Note("Places reads from installed audio packs independently of the shared Stories/Writings voice-language preference.", nil, 42)

    -- Mirrors the Books Defaults action: a confirmation, a preference-only
    -- reset, and a refresh. Discovery and narration history are untouched.
    layout:Defaults(function()
        Layout.Confirm("Reset Places preferences? Discovered and heard areas are kept.",
            "Reset", "Cancel", function()
                R.ResetOptions()
                -- Apply the restored map preference immediately, not only
                -- after the next reload or map interaction.
                if SSZMapPanel and SSZMapPanel.SetEnabled then
                    SSZMapPanel.SetEnabled(true)
                end
                if R.Recheck then R.Recheck() end
                Refresh()
            end)
    end)

    frame:SetScript("OnShow", Refresh)
    optionsPage = Spoken:AddSettingsPage(frame, "Places", 3, layout)
    Refresh()
end

local onLogin = CreateFrame("Frame")
onLogin:RegisterEvent("PLAYER_LOGIN")
onLogin:SetScript("OnEvent", function()
    onLogin:UnregisterEvent("PLAYER_LOGIN")
    Build()
end)
