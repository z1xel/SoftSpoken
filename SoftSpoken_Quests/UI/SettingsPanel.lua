-- Vanilla-friendly Quests page. The existing AceConfig table still backs
-- slash commands; this page reads and writes exactly the same preferences.
setfenv(1, VoiceOver)

SettingsPanel = {}
local frame, layout, page
local UI = SpokenLayout

local function Audio() return Addon.db.profile.Audio end
local function Refresh()
    if layout then layout:Refresh() end
end

function SettingsPanel:Setup()
    if frame or not (Spoken and Spoken.AddSettingsPage and UI and Addon.db) then return end
    frame = CreateFrame("Frame", nil, UIParent)
    frame:SetWidth(470)
    frame:SetHeight(1)
    frame:Hide()
    layout = UI.New(frame, 25, -16)
    layout:Intro([[Interface\Icons\INV_Scroll_03]], "Quests & Gossip")

    local switch = layout:Checkbox("Enable Quests", "Allow quest narration to play.",
        function() return Spoken:IsPartOn("quests") end,
        function(on) Spoken:SetPartOn("quests", on) end, Refresh)

    layout:Section("Quest Narration")
    local autoplay = layout:Checkbox(L.OPT_PANEL_AUTOPLAY or "Read Automatically", nil,
        function() return Addon:IsAutoplayOn() end,
        function(on) Addon:SetAutoplay(on) end, Refresh)
    layout:Indent()
    local followup = layout:Checkbox(L.OPT_PANEL_FOLLOWUP or "Read Follow-up Lines", nil,
        function() return Audio().FollowupLines ~= false end,
        function(on) Audio().FollowupLines = on end)
    layout:Outdent()
    layout:Requires(followup, function() return Addon:IsAutoplayOn() end,
        "Turn on automatic narration to use this.")
    layout:Checkbox(L.OPT_PANEL_STOP_ON_CLOSE or "Stop When Window Closes", nil,
        function() return Audio().StopAudioOnDisengage end,
        function(on) Audio().StopAudioOnDisengage = on end)
    local afterClose = layout:Checkbox(L.OPT_PANEL_READ_AFTER_CLOSE or "Read When Window Closes",
        "Start an automatic quest reading when the quest window closes.",
        function() return Audio().ReadAfterClose end,
        function(on) Audio().ReadAfterClose = on end)
    layout:Requires(afterClose, function() return Addon:IsAutoplayOn() end,
        "Turn on automatic narration to use this.")
    local gameFirst = layout:Checkbox(L.OPT_PANEL_GAME_GREETING_FIRST or "Game Greeting First",
        "Allow the game's own NPC greeting before reading the line.",
        function() return Audio().GreetingFirst end,
        function(on)
            Audio().GreetingFirst = on
            if on and GreetingFirst and GreetingFirst.SetDialogApart then
                GreetingFirst:SetDialogApart()
            end
        end)
    layout:Requires(gameFirst, function() return Addon:IsAutoplayOn() end,
        "Turn on automatic narration to use this.")
    layout:Checkbox(L.OPT_OG_THRALL or "Original Thrall Voice", L.OPT_OG_THRALL_TIP,
        function() return Audio().OGThrall end,
        function(on) Audio().OGThrall = on end)

    layout:Section("NPC Gossip")
    local frequencies = {
        Enums.GossipFrequency.Always, Enums.GossipFrequency.OncePerQuestNPC,
        Enums.GossipFrequency.OncePerNPC, Enums.GossipFrequency.Never
    }
    local names = {
        [Enums.GossipFrequency.Always] = L.OPT_GREETING_LABEL_ALWAYS or "Always",
        [Enums.GossipFrequency.OncePerQuestNPC] = L.OPT_GREETING_LABEL_ONCE_QUEST or "Once per Quest NPC",
        [Enums.GossipFrequency.OncePerNPC] = L.OPT_GREETING_LABEL_ONCE_NPC or "Once per NPC",
        [Enums.GossipFrequency.Never] = L.OPT_GREETING_LABEL_NEVER or "Never",
    }
    local frequency = layout:Dropdown(L.OPT_PANEL_GREETINGS or "NPC Greetings", nil,
        frequencies,
        function() return Audio().GossipFrequency end,
        function(value)
            Audio().GossipFrequency = value
            Player:RefreshConfig()
        end, nil, function(value) return names[value] or tostring(value) end)
    layout:Requires(frequency, function()
        return Spoken:IsPartOn("gossip") and Addon:IsAutoplayOn()
    end, "Enable Gossip and automatic narration to use this.")

    layout:Section("Voice Packs")
    local note = layout:Note("", nil, 28)
    layout:OnRefresh(function()
        local count = 0
        for _, module in DataModules:GetPresentModules() do count = count + 1 end
        note:SetText(count == 0 and "No Quests voice packs installed."
            or tostring(count) .. " Quests voice pack(s) installed.")
    end)
    for _, module in DataModules:GetAvailableModules() do
        local info = module
        local name = DataModules:GetPackLabel(info)
        layout:Download(name, function()
            for _, installed in DataModules:GetPresentModules() do
                if installed.AddonName == info.AddonName then
                    return "ok", installed.ContentVersion or "Installed"
                end
            end
        end, "Get Pack", function()
            if info.URL and ReportButton and ReportButton.ShowAddress then
                ReportButton:ShowAddress(info.URL)
            end
        end)
    end
    layout:Button("Test Voice Line", 200, function() Options:RunSelfTest() end)
    layout:Button("Diagnostics", 200, function() Options:PrintDiagnostics() end)

    layout:RequiresAll(function() return Spoken:IsPartOn("quests") end,
        "Enable Quests to configure this module.", switch)
    frame:SetScript("OnShow", Refresh)
    page = Spoken:AddSettingsPage(frame, "Quests", 1, layout)
    Refresh()
end

function SettingsPanel:Open()
    self:Setup()
    return page and page.Open and page.Open() or false
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function()
    SettingsPanel:Setup()
    if page then
        loader:UnregisterEvent("PLAYER_LOGIN")
        loader:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)
