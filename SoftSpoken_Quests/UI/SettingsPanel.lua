-- Vanilla-friendly Quests page. The existing AceConfig table still backs
-- slash commands; this page reads and writes exactly the same preferences.
setfenv(1, VoiceOver)

SettingsPanel = {}
local frame, layout, page
local UI = SpokenLayout

-- Options/VoiceOver initializes via AceAddon. Our settings tab must wait
-- until AceDB exists, and an optional UI failure must not affect quest audio
-- or the existing AceGUI settings window.
local function Ready()
    return Spoken and Spoken.AddSettingsPage and UI and
        Addon and Addon.db and Addon.db.profile and
        Addon.db.profile.Audio and DataModules and Player
end

local function Audio() return Addon.db.profile.Audio end
local function Refresh()
    if layout then layout:Refresh() end
end

function SettingsPanel:Build()
    frame = CreateFrame("Frame", nil, UIParent)
    frame:SetWidth(470)
    frame:SetHeight(1)
    frame:Hide()
    layout = UI.New(frame, 25, -16)
    layout:Intro([[Interface\Icons\INV_Scroll_03]], "Quests & Gossip")

    layout:Checkbox("Enable Quests", "Allow quest narration to play.",
        function() return Spoken:IsPartOn("quests") end,
        function(on) Spoken:SetPartOn("quests", on) end, Refresh)
    layout:Checkbox("Enable Gossip", "Allow NPC gossip narration independently of quests.",
        function() return Spoken:IsPartOn("gossip") end,
        function(on) Spoken:SetPartOn("gossip", on) end, Refresh)

    layout:Section("Quest Narration")
    local autoplay = layout:Checkbox(L.OPT_PANEL_AUTOPLAY or "Read Automatically", nil,
        function() return Addon:IsAutoplayOn() end,
        function(on) Addon:SetAutoplay(on) end, Refresh)
    layout:Requires(autoplay, function()
        return Spoken:IsPartOn("quests") or Spoken:IsPartOn("gossip")
    end, "Enable Quests or Gossip to use this.")
    layout:Indent()
    local followup = layout:Checkbox(L.OPT_PANEL_FOLLOWUP or "Read Follow-up Lines", nil,
        function() return Audio().FollowupLines ~= false end,
        function(on) Audio().FollowupLines = on end)
    layout:Outdent()
    layout:Requires(followup, function()
        return Spoken:IsPartOn("quests") and Addon:IsAutoplayOn()
    end, "Enable Quests and automatic narration to use this.")
    local stopOnClose = layout:Checkbox(L.OPT_PANEL_STOP_ON_CLOSE or "Stop When Window Closes", nil,
        function() return Audio().StopAudioOnDisengage end,
        function(on) Audio().StopAudioOnDisengage = on end)
    layout:Requires(stopOnClose, function() return Spoken:IsPartOn("quests") end,
        "Enable Quests to use this.")
    local afterClose = layout:Checkbox(L.OPT_PANEL_READ_AFTER_CLOSE or "Read When Window Closes",
        "Start an automatic quest reading when the quest window closes.",
        function() return Audio().ReadAfterClose end,
        function(on) Audio().ReadAfterClose = on end)
    layout:Requires(afterClose, function()
        return Spoken:IsPartOn("quests") and Addon:IsAutoplayOn()
    end, "Enable Quests and automatic narration to use this.")
    local gameFirst = layout:Checkbox(L.OPT_PANEL_GAME_GREETING_FIRST or "Game Greeting First",
        "Allow the game's own NPC greeting before reading the line.",
        function() return Audio().GreetingFirst end,
        function(on)
            Audio().GreetingFirst = on
            if on and GreetingFirst and GreetingFirst.SetDialogApart then
                GreetingFirst:SetDialogApart()
            end
        end)
    layout:Requires(gameFirst, function()
        return (Spoken:IsPartOn("quests") or Spoken:IsPartOn("gossip"))
            and Addon:IsAutoplayOn()
    end, "Enable Quests or Gossip and automatic narration to use this.")
    local originalThrall = layout:Checkbox(L.OPT_OG_THRALL or "Original Thrall Voice", L.OPT_OG_THRALL_TIP,
        function() return Audio().OGThrall end,
        function(on) Audio().OGThrall = on end)
    layout:Requires(originalThrall, function() return Spoken:IsPartOn("quests") end,
        "Enable Quests to use this.")

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
    -- Include every detected enabled pack, not just the five download choices.
    -- Its metadata comes from the same enumeration used by the original panel.
    layout:PackInventory(function()
        local packs = {}
        for _, module in DataModules:GetPresentModules() do
            local info = module
            local loaded = DataModules:GetModule(info.AddonName) ~= nil
            local errorCode = DataModules:GetModuleLoadError(info.AddonName)
            local reason
            if GetAddOnInfo then
                local _, _, _, _, failure = GetAddOnInfo(info.AddonName)
                if failure ~= "DEMAND_LOADED" and failure ~= "INTERFACE_VERSION" then
                    reason = failure
                end
            end
            local fields = {
                { label = "Addon", value = info.AddonName },
                { label = "Pack Title", value = info.Title },
                { label = "Content Version", value = info.ContentVersion },
                { label = "Data Format", value = info.ModuleVersion },
                { label = "Priority", value = info.ModulePriority },
                { label = "Language", value = Language:GetNativeName(info.Language) },
                { label = "Load on Demand", value = info.LoadOnDemand and YES or NO },
                { label = "Loaded", value = loaded and YES or NO },
            }
            if reason then
                table.insert(fields, { label = "Addon Status", value = _G["ADDON_" .. reason] or reason })
            end
            if errorCode then
                table.insert(fields, { label = "Load Error", value = tostring(errorCode) })
            end
            table.insert(packs, {
                id = info.AddonName, source = info,
                name = info.Title or info.AddonName,
                version = info.ContentVersion,
                status = loaded and "Loaded" or "Not loaded",
                details = fields,
            })
        end
        return packs
    end, "No Quests voice packs detected.")

    -- Keep the known download destinations visible for reference, but disable
    -- the entire section until downloading is supported here. Match Home's
    -- disabled Profiles controls: grey appearance, inert buttons and red note.
    -- Installed voice pack details above remain available and interactive.
    local downloadsAvailable = false
    local downloadsUnavailable = "* Voice pack downloads are currently disabled in Settings. Install or update packs manually."
    local function CanDownload() return downloadsAvailable end
    layout:Section("Voice Pack Downloads")
    local function AddPack(info)
        local name = DataModules:GetPackLabel(info)
        local control = layout:Download(name, function()
            for _, installed in DataModules:GetPresentModules() do
                if installed.AddonName == info.AddonName then
                    return "ok", installed.ContentVersion or "Installed"
                end
            end
        end, "Get Pack", function()
            if not downloadsAvailable then return end
            if info.URL and ReportButton and ReportButton.ShowAddress then
                ReportButton:ShowAddress(info.URL)
            end
        end)
        layout:Requires(control, CanDownload, downloadsUnavailable)
        if not downloadsAvailable then layout:BlockInteraction(control) end
    end
    for _, module in DataModules:GetAvailableModules() do
        AddPack(module)
    end
    local notice = layout:Note(downloadsUnavailable, nil, 40)
    notice:SetTextColor(1, 0.24, 0.24)
    notice:SetAlpha(1)
    notice.layoutBaseAlpha = 1

    -- These are existing Quests troubleshooting actions. Keep them together,
    -- separately from the installed-pack inventory and the reading options.
    layout:Section("Fix a Problem")
    layout:Columns(2)
    layout:Button("Test Voice Line", 200, function() Options:RunSelfTest() end,
        "Play the Quests module's existing audio self-test.")
    layout:Button("Diagnostics", 200, function() Options:ShowDiagnostics() end,
        "Print the existing Quests diagnostic report.")
    layout:Columns(nil)

    layout:Defaults(function()
        UI.Confirm("Reset Quests and Gossip preferences? Their profiles are reset; reading history is kept.",
            "Reset", "Cancel", function()
                Addon.db:ResetProfile()
                Refresh()
            end)
    end)
    frame:SetScript("OnShow", Refresh)
    -- Build/refresh every control before publishing the page to the core.
    -- A failed builder leaves the working AceGUI route untouched.
    Refresh()
    page = Spoken:AddSettingsPage(frame, "Quests", 1, layout)
end

function SettingsPanel:Setup()
    if page then return true end
    if not Ready() then return false end
    if self.building then return false end
    self.building = true
    local ok, err = pcall(self.Build, self)
    self.building = nil
    if not ok then
        self.lastError = tostring(err)
        if frame then frame:Hide() end
        frame, layout = nil, nil
        if Debug and Debug.Record then
            Debug:Record("quests-settings-page", self.lastError)
        end
        return false
    end
    return page ~= nil
end

function SettingsPanel:Open()
    if not self:Setup() then return false end
    return page and page.Open and page.Open() or false
end

-- PLAYER_ENTERING_WORLD runs after AceAddon initialises its database on
-- ADDON_LOADED. Do not rely on a competing PLAYER_LOGIN handler's ordering.
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function()
    if SettingsPanel:Setup() then
        loader:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)
