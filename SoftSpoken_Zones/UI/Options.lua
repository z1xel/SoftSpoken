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
    layout:Intro([[Interface\Icons\INV_Misc_Map02]], "Zones")

    layout:Checkbox("Enable Zones", "Allow narrated zone lore to play.",
        function() return Spoken:IsPartOn("zones") end,
        function(on) Spoken:SetPartOn("zones", on) end, Refresh)
    layout:Status(function() return Spoken:PartStatus("zones") end)

    layout:Section("Automatic Narration")
    local autoplay = layout:Checkbox("Narrate Automatically",
        "Narrate supported places while exploring Azeroth.",
        function() return Settings().auto end,
        function(on) Settings().auto = on end, Refresh)
    layout:Requires(autoplay, function() return Spoken:IsPartOn("zones") end,
        "Enable Zones to use automatic narration.")
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
        "Enable Zones to configure narrated subzones.")
    layout:Requires(mode, function()
        return Spoken:IsPartOn("zones") and Settings().auto
    end, "Enable Zones and automatic narration to use this.")
    local combat = layout:Checkbox("Hold During Combat",
        "Delay automatic Zones narration while in combat.",
        function() return Settings().holdCombat end,
        function(on) Settings().holdCombat = on; if R.Recheck then R.Recheck() end end)
    layout:Requires(combat, function()
        return Spoken:IsPartOn("zones") and Settings().auto
    end, "Enable Zones and automatic narration to use this.")
    local greeting = layout:Checkbox("Starting Character Greeting",
        "Narrate a starting-area introduction for a new level-one character.",
        function() return Settings().greeting end,
        function(on) Settings().greeting = on end)
    -- The starter greeting uses its own flag and may play when auto is off.
    layout:Requires(greeting, function() return Spoken:IsPartOn("zones") end,
        "Enable Zones to use starting character greetings.")

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
    layout:Badge("Installed Audio", function()
        return Spoken:PartVoice("zones")
    end, "Count of valid Zones audio packs currently registered.")
    layout:Note("Zones reads from installed audio packs independently of the shared Quests/Books voice-language preference.", nil, 42)
    -- Keep discovery/heard history untouched: this module does not expose a
    -- reset action with established history-preservation semantics.
    frame:SetScript("OnShow", Refresh)
    optionsPage = Spoken:AddSettingsPage(frame, "Zones", 3, layout)
    Refresh()
end

local onLogin = CreateFrame("Frame")
onLogin:RegisterEvent("PLAYER_LOGIN")
onLogin:SetScript("OnEvent", function()
    onLogin:UnregisterEvent("PLAYER_LOGIN")
    Build()
end)
