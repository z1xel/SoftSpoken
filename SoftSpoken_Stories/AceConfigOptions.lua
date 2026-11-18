setfenv(1, VoiceOver)
Options = { }

local AceGUI = LibStub("AceGUI-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

------------------------------------------------------------
-- Construction of the options table for AceConfigDialog --

-- Needed to preserve order (modern AceGUI has support for custom sorting of dropdown items, but old versions don't)
local FRAME_STRATAS =
{
    "BACKGROUND",
    "LOW",
    "MEDIUM",
    "HIGH",
    "DIALOG",
}

-- General Tab
---@type AceConfigOptionsTable
local GeneralTab =
{
    name = L.OPT_GROUP_GENERAL,
    type = "group",
    order = 10,
    args = {
        Audio = {
            type = "group",
            order = 4,
            inline = true,
            name = L.OPT_GROUP_AUDIO,
            args = {
                -- Named as the settings page names them.
                ToggleAutoplay = {
                    type = "toggle",
                    order = 1,
                    width = 2,
                    name = L.OPT_PANEL_AUTOPLAY,
                    get = function(info) return Addon:IsAutoplayOn() end,
                    set = function(info, value) Addon:SetAutoplay(value) end,
                },
                LineBreak1 = { type = "description", name = "", order = 2 },
                GossipFrequency = {
                    type = "select",
                    width = 1.1,
                    order = 3,
                    -- It decides which greetings autoplay reads, so with autoplay off it has
                    -- nothing to decide.
                    disabled = function(info) return not Addon:IsAutoplayOn() end,
                    name = L.OPT_PANEL_GREETINGS,
                    values = {
                        [Enums.GossipFrequency.Always] = L.OPT_GREETING_LABEL_ALWAYS,
                        [Enums.GossipFrequency.OncePerQuestNPC] = L.OPT_GREETING_LABEL_ONCE_QUEST,
                        [Enums.GossipFrequency.OncePerNPC] = L.OPT_GREETING_LABEL_ONCE_NPC,
                        [Enums.GossipFrequency.Never] = L.OPT_GREETING_LABEL_NEVER,
                    },
                    get = function(info) return Addon.db.profile.Audio.GossipFrequency end,
                    set = function(info, value)
                        Addon.db.profile.Audio.GossipFrequency = value
                        StoriesNarrator:RefreshConfig()
                    end,
                },
                LineBreak2 = { type = "description", name = "", order = 5 },
                ToggleSyncToWindowState = {
                    type = "toggle",
                    order = 6,
                    width = 2,
                    name = L.OPT_PANEL_STOP_ON_CLOSE,
                    get = function(info) return Addon.db.profile.Audio.StopAudioOnDisengage end,
                    set = function(info, value)
                        Addon.db.profile.Audio.StopAudioOnDisengage = value
                    end,
                },
                ToggleFollowupLines = {
                    type = "toggle",
                    order = 6.5,
                    width = 2,
                    name = L.OPT_PANEL_FOLLOWUP,
                    -- Follow-up lines read themselves, so autoplay off leaves this nothing to do.
                    disabled = function(info) return not Addon:IsAutoplayOn() end,
                    get = function(info) return Addon.db.profile.Audio.FollowupLines ~= false end,
                    set = function(info, value)
                        Addon.db.profile.Audio.FollowupLines = value
                    end,
                },
                OGThrall = {
                    type = "toggle",
                    order = 8,
                    width = 2,
                    name = L.OPT_OG_THRALL,
                    desc = L.OPT_OG_THRALL_TIP,
                    get = function(info) return Addon.db.profile.Audio.OGThrall end,
                    set = function(info, value)
                        Addon.db.profile.Audio.OGThrall = value
                    end,
                },
            }
        },
    }
}

---@type AceConfigOptionsTable
local DataModulesTab =
{
    name = function() return L.OPT_SECTION_PACKS .. (next(Options.table.args.DataModules.args.Available.args) and "|cFF00CCFF" .. L.OPT_NEW_SUFFIX .. "|r" or "") end,
    type = "group",
    childGroups = "tree",
    order = 20,
    args = {
        Available = {
            type = "group",
            name = L.OPT_AVAILABLE_GROUP,
            order = 100000,
            hidden = function(info) return not next(Options.table.args.DataModules.args.Available.args) end,
            args = {}
        }
    }
}

---@type AceConfigOptionsTable
Options.table = {
    name = "SoftSpoken Stories",
    type = "group",
    childGroups = "tab",
    args = {
        General = GeneralTab,
        DataModules = DataModulesTab,
        Profiles = nil, -- Filled in Options:OnInitialize, order is implicitly 100

    }
}
------------------------------------------------------------

-- Control data loading, not WoW's addon checkbox. A loaded Lua module cannot
-- be unloaded until /reload, so confirm that action before storing the choice.
-- Re-enabling an unloaded LOD pack uses the existing manual loader immediately.
function Options:SetDataModuleEnabled(module, enabled)
    if not module or not module.LoadOnDemand then return false end
    local name = module.AddonName
    if enabled == DataModules:IsPackEnabled(name) then return true end

    if not enabled and DataModules:GetModule(name) then
        SpokenLayout.Confirm(
            format('Disable voice pack "%s"? Its data is already loaded, so the UI must reload to release it.',
                module.Title or name),
            "Disable & Reload", "Cancel", function()
                DataModules:SetPackEnabled(name, false)
                ReloadUI()
            end)
        return false
    end

    DataModules:SetPackEnabled(name, enabled)
    if enabled then
        local loaded, reason = DataModules:LoadModule(module)
        if not loaded then
            local message = format('Failed to load voice pack "%s": %s', name, tostring(reason or "UNKNOWN"))
            if StaticPopup_Show then
                StaticPopup_Show("VOICEOVER_ERROR", message)
            else
                print(message)
            end
        end
    end
    if Spoken and Spoken.NotifyVoicePacksChanged then
        Spoken:NotifyVoicePacksChanged()
    end
    if SSCQuestsTab and SSCQuestsTab.InvalidateVoiceCache then
        SSCQuestsTab:InvalidateVoiceCache()
    end
    return true
end

---@param module DataModuleMetadata
---@param order number
function Options:AddDataModule(module, order)
    local descriptionOrder = 0
    local function GetNextOrder()
        descriptionOrder = descriptionOrder + 1
        return descriptionOrder
    end
    local function MakeDescription(header, text)
        return { type = "description", order = GetNextOrder(), name = function() return format("%s%s: |r%s", NORMAL_FONT_COLOR_CODE, header, type(text) == "function" and text() or text) end }
    end

    local name, title, notes, loadable, reason = DataModules:GetModuleAddOnInfo(module)
    -- The deferred loader can recover DISABLED packs by enabling them first.
    if reason == "DEMAND_LOADED" or reason == "INTERFACE_VERSION" or reason == "DISABLED" then
        reason = nil
    end
    DataModulesTab.args[module.AddonName] = {
        name = function()
            local isLoaded = DataModules:GetModule(module.AddonName)
            local loadFailed = DataModules:GetModuleLoadError(module.AddonName)
            return format("%d. %s%s%s|r",
                order,
                (reason or loadFailed) and RED_FONT_COLOR_CODE or isLoaded and HIGHLIGHT_FONT_COLOR_CODE or GRAY_FONT_COLOR_CODE,
                string.gsub(module.Title, "VoiceOver Data %- ", ""),
                isLoaded and "" or L.OPT_NOT_LOADED_SUFFIX)
        end,
        type = "group",
        order = order,
        args = {
            Enabled = {
                type = "toggle",
                order = GetNextOrder(),
                name = "Enable Voice Pack",
                desc = "Choose whether SoftSpoken loads this sound pack. Disabling a loaded pack requires a UI reload.",
                disabled = not module.LoadOnDemand,
                get = function() return DataModules:IsPackEnabled(module.AddonName) end,
                set = function(info, value) Options:SetDataModuleEnabled(module, value) end,
            },
            AddonName = MakeDescription(L.OPT_ROW_ADDON_NAME, module.AddonName),
            Title = MakeDescription(L.OPT_ROW_TITLE, module.Title),
            ModuleVersion = MakeDescription(L.OPT_ROW_FORMAT_VERSION, module.ModuleVersion),
            ModulePriority = MakeDescription(L.OPT_ROW_PRIORITY, module.ModulePriority),
            Language = MakeDescription(L.OPT_ROW_LANGUAGE, function() return Language:GetNativeName(module.Language) end),
            ContentVersion = MakeDescription(L.OPT_ROW_CONTENT_VERSION, module.ContentVersion),
            LoadOnDemand = MakeDescription(L.OPT_ROW_LOAD_ON_DEMAND, module.LoadOnDemand and YES or NO),
            Loaded = MakeDescription(L.OPT_ROW_LOADED, function() return DataModules:GetModule(module.AddonName) and YES or NO end),
            LoadFailure = {
                type = "description",
                order = GetNextOrder(),
                name = function()
                    local _, failure = DataModules:GetModuleLoadStatus(module.AddonName)
                    return format("%sLoad failure: |r%s", RED_FONT_COLOR_CODE, tostring(failure or "UNKNOWN"))
                end,
                hidden = function()
                    return DataModules:GetModuleLoadStatus(module.AddonName) ~= "failed"
                end,
            },
            NotLoadableReason = {
                type = "description",
                order = GetNextOrder(),
                name = format(L.OPT_ROW_REASON_FMT, NORMAL_FONT_COLOR_CODE, RED_FONT_COLOR_CODE, reason and _G["ADDON_"..reason] or ""),
                hidden = not reason,
            },
            Load = {
                type = "execute",
                order = GetNextOrder(),
                name = L.OPT_LOAD_BUTTON,
                hidden = function()
                    return reason or not module.LoadOnDemand
                        or not DataModules:IsPackEnabled(module.AddonName)
                        or DataModules:GetModule(module.AddonName) ~= nil
                end,
                func = function()
                    local loaded, reason = DataModules:LoadModule(module)
                    if not loaded then
                        StaticPopup_Show("VOICEOVER_ERROR", format([[Failed to load data module "%s". Reason: %s]], module.AddonName, reason and _G["ADDON_" .. reason] or "Unknown"))
                    end
                end,
            },
        }
    }
end

---@param module AvailableDataModule
---@param order number
---@param update boolean Data module has update
function Options:AddAvailableDataModule(module, order, update)
    local descriptionOrder = 0
    local function GetNextOrder()
        descriptionOrder = descriptionOrder + 1
        return descriptionOrder
    end
    local function MakeDescription(header, text)
        return { type = "description", order = GetNextOrder(), name = function() return format("%s%s: |r%s", NORMAL_FONT_COLOR_CODE, header, type(text) == "function" and text() or text) end }
    end

    DataModulesTab.args.Available.args[module.AddonName] = {
        name = Utils:ColorizeText(format(update and "%s" .. L.OPT_UPDATE_SUFFIX or "%s", DataModules:GetPackLabel(module)), "|cFF00CCFF"),
        type = "group",
        order = order,
        args = {
            AddonName = MakeDescription(L.OPT_ROW_ADDON_NAME, module.AddonName),
            Title = MakeDescription(L.OPT_ROW_TITLE, module.Title),
            ContentVersion = MakeDescription(L.OPT_ROW_CONTENT_VERSION, format(update and L.OPT_CONTENT_VERSION_UPDATE_FMT or L.OPT_CONTENT_VERSION_FMT, module.ContentVersion, update and DataModules:GetPresentModule(module.AddonName).ContentVersion)),
            URL = {
                type = "input",
                order = GetNextOrder(),
                width = "full",
                name = L.OPT_DOWNLOAD_URL,
                get = function(info) return module.URL end,
                set = function(info) end,
            },
        }
    }
end

---Initialization of opens panel
--- Play a known line the way a real one goes: through the player, on the configured
--- channel. Called by the Quests Settings self-test button.
function Options:RunSelfTest()
            local soundData = {
                event = Enums.SoundEvent.QuestAccept,
                questID = 3441,
                name = "SoftSpoken Stories self-test",
                title = "SoftSpoken Stories self-test",
                text = "SoftSpoken Stories self-test",
                origin = "Quests Settings: Test Voice Line",
            }
            if not DataModules:PrepareSound(soundData) then
                Debug:Record("self-test-data-failed", "The Vanilla Data module did not provide the known 3441-accept test sound")
                print("|cFFFF4040SoftSpoken Stories test failed: the known Vanilla test sound was not found in the loaded sound packs.|r")
                return
            end

            -- Through the player, the route every real line takes: on 2.4.3 and 3.3.5
            -- that means the music channel, and a self-test that went another way would
            -- answer a question nobody asked.
            local channel = StoriesNarrator.source and StoriesNarrator.source:GetChannel() or "unknown"
            if StoriesNarrator:Enqueue(soundData, true) then
                Debug:Record("self-test-playing", format("Self-test queued on %s: %s", channel, soundData.filePath))
                print(format("|cFF40FF40SoftSpoken Stories test started on %s.|r You should hear a short voice line.", channel))
            else
                local stage, message = Debug:GetRuntimeStatus()
                print(format("|cFFFF4040SoftSpoken Stories test failed: %s (%s).|r", message or "refused", stage or "unknown"))
            end
end

--- Build diagnostics as lines: no chat side effects, also usable by the Developer provider.
function Options:DiagnosticsLines()
    local lines = {}
    local function Add(line) table.insert(lines, tostring(line)) end
    local function AudioCVar(name)
        local ok, value = pcall(GetCVar, name)
        return ok and value ~= nil and tostring(value) ~= "" and tostring(value) or "unavailable"
    end
            Add(format("|cFF00CCFFSoftSpoken Stories %s|r - client %s, interface %d",
                AddonVersion, Version.Client or "unknown", Version.Interface or 0))
            Add("AddOn API: " .. (C_AddOns and "C_AddOns compatibility layer" or "legacy globals"))

            local channel = StoriesNarrator.source and StoriesNarrator.source:GetChannel() or "unknown"
            Add(format("Playback: channel=%s, paused=%s, queue=%d, player=%s", channel,
                tostring(Spoken and Spoken:IsPaused()), Spoken and Spoken:GetQueueSize() or 0,
                Spoken and Spoken.ADDON_VERSION or "missing"))
            Add("NPC greetings: " ..
                (Enums.GossipFrequency:GetName(Addon.db.profile.Audio.GossipFrequency) or "unknown"))
            if GreetingFirst and GreetingFirst.DescribeTiming then
                Add("NPC greeting timing: " .. GreetingFirst:DescribeTiming())
            end
            Add(format("Vanilla sound CVars: master=%s, effects=%s/%s, music=%s, ambience=%s",
                AudioCVar("MasterVolume"), AudioCVar("MasterSoundEffects"),
                AudioCVar("SoundVolume"), AudioCVar("MusicVolume"), AudioCVar("AmbienceVolume")))

            local summary = DataModules:GetLoadSummary()
            for _, module in DataModules:GetPresentModules() do
                local status, failure = DataModules:GetModuleLoadStatus(module.AddonName)
                if status == "not attempted" and Addon.dataModulesPending then
                    status = "waiting for deferred load"
                elseif status == "disabled" then
                    status = "disabled in SoftSpoken (not loaded)"
                elseif status == "reload required" then
                    status = "disabled in SoftSpoken (reload required)"
                elseif status == "failed" then
                    status = "failed: " .. tostring(failure)
                end
                Add(format("Data: %s (%s) - %s", module.AddonName,
                    module.ContentVersion or "unknown version", status))
            end
            if summary.detected == 0 then
                Add("Data: no sound packs were detected")
            else
                Add(format("Data modules: %d detected, %d loaded, %d disabled, %d failed, %d not attempted",
                    summary.detected, summary.loaded, summary.disabled, summary.failed,
                    summary.notAttempted))
            end
            local stage, message = Debug:GetRuntimeStatus()
            Add(format("Last runtime stage: %s - %s", stage or "none", message or "no details"))
            if Addon.eventBridgeErrors then
                for _, warning in ipairs(Addon.eventBridgeErrors) do
                    Add("Bridge warning: " .. warning)
                end
            end

            if Addon.optionsInitializationError then
                Add("Options startup warning: " .. Addon.optionsInitializationError)
            end
            if Addon.dataModulesPending then
                Add("Data startup: loading is deferred until one second after entering the world")
            elseif Addon.dataModulesDeferredError then
                Add("Data startup warning: " .. Addon.dataModulesDeferredError)
            end
            if Options.initializationErrors then
                for _, warning in ipairs(Options.initializationErrors) do
                    Add("Options warning: " .. warning)
                end
            end
    return lines
end



function Options:ShowDiagnostics()
    if Spoken and Spoken.ShowDiagnostics then
        Spoken:ShowDiagnostics("Stories Diagnostics", self:DiagnosticsLines())
    end
end
function Options:Initialize()
    self.initializationErrors = {}
    local function RunOptionalStep(name, callback)
        local succeeded, result = pcall(callback)
        if succeeded then
            return result
        end
        local message = name .. ": " .. tostring(result)
        table.insert(self.initializationErrors, message)
    end

    RunOptionalStep("profile options", function()
        self.table.args.Profiles = AceDBOptions:GetOptionsTable(Addon.db)
    end)

    -- Create options table
    Debug:Print("Registering options table...", "Options")
    local AceConfig = LibStub("AceConfig-3.0")
    if Addon.RegisterOptionsTable then
        -- Embedded version for 1.12
        AceConfig = Addon
    end
    RunOptionalStep("AceConfig table registration (no chat commands)", function()
        -- Keep the table for the old AceGUI emergency fallback, not for slash routing.
        AceConfig:RegisterOptionsTable("SpokenQuests", self.table)
    end)
    -- Turtle WoW 1.12 has no modern Settings canvas. Use the existing
    -- AceConfig/AceGUI window for settings, modules, and profiles.
    Debug:Print("Done!", "Options")

    -- Create the option frame
    ---@type AceGUIFrame|AceGUIWidget
    RunOptionalStep("AceGUI options frame", function()
        self.frame = AceGUI:Create("Frame")
        --AceConfigDialog:SetDefaultSize("VoiceOver", 640, 780) -- Let it be auto-sized
        AceConfigDialog:Open("SpokenQuests", self.frame)
        self.frame:SetLayout("Fill")
        self.frame:Hide()

        -- Enable the frame to be closed with Escape key
        _G["VoiceOverOptions"] = self.frame.frame
        tinsert(UISpecialFrames, "VoiceOverOptions")
    end)
    -- Register from the same AceAddon lifecycle as the Quests database.
    -- The deferred PLAYER_ENTERING_WORLD hook in SettingsPanel remains a
    -- fallback if the shared core has not finished setting up yet.
    RunOptionalStep("shared settings page", function()
        if StoriesSettingsPage and StoriesSettingsPage.Setup then StoriesSettingsPage:Setup() end
    end)
end

--- Turtle WoW 1.12 uses the AceConfig window for quest and gossip settings,
-- profiles, and the sound-pack manager.
function Options:OpenSettings()
    -- Prefer the shared Vanilla Quests tab. If its optional UI cannot build,
    -- preserve the original AceGUI window as an independent working fallback.
    if StoriesSettingsPage and StoriesSettingsPage.Open then
        local ok, opened = pcall(StoriesSettingsPage.Open, StoriesSettingsPage)
        if ok and opened then return end
        if not ok then StoriesSettingsPage.lastError = tostring(opened) end
    end
    self:OpenConfigWindow()
end

--- Gossip shares the Quests page, with its own enable toggle and
-- frequency control. Use the same fallback as Quests if that page fails.
function Options:OpenGossipSettings()
    self:OpenSettings()
end

function Options:OpenConfigWindow()
    if not self.frame then
        print("|cFFFF4040SoftSpoken Stories: neither settings view could be opened.|r")
        if StoriesSettingsPage and StoriesSettingsPage.lastError then
            print("Shared Stories settings: " .. SettingsPanel.lastError)
        end
        for _, warning in ipairs(self.initializationErrors or {}) do
            print("Legacy Stories settings: " .. tostring(warning))
        end
        return
    end
    if self.frame:IsShown() then
        PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
        self.frame:Hide()
    else
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
        self.frame:Show()
        AceConfigDialog:Open("SpokenQuests", self.frame)
    end
end
