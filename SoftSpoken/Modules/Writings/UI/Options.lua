-- Writings settings page: shares Core's native 1.12 frame and layout.
-- The reader and SavedVariables retain ownership of every behavior.
local Writings = SpokenWritings
local L = Writings.L or {}
local Layout = SpokenLayout
local page
local frame
local layout
local DOWNLOAD = "https://www.curseforge.com/wow/addons/spoken-books-audio"

local function S(key, fallback) return L[key] or fallback end
local function Settings()
    return Writings.db.profile
end
local function Refresh()
    if layout then layout:Refresh() end
end

function Writings:RefreshOptions()
    Refresh()
end

function Writings:SetupOptions()
    if frame then return frame end
    if not (Spoken and Spoken.AddSettingsPage and Layout) then return nil end
    frame = CreateFrame("Frame", nil, UIParent)
    frame:SetWidth(470)
    frame:SetHeight(1)
    frame:Hide()
    layout = Layout.New(frame, 25, -16)
    layout:Intro([[Interface\Icons\INV_Misc_Book_09]], "Writings")

    layout:Checkbox("Enable Writings", "Allow book and letter narration.",
        function() return Writings:IsPartOn() end,
        function(on) Spoken:SetPartOn("books", on) end, Refresh)
    layout:Section(S("OPT_SECTION_READING", "When to Read"))
    local autoplay = layout:Checkbox(S("OPT_AUTOPLAY", "Read Automatically"),
        L.OPT_AUTOPLAY_TIP,
        function() return Settings().autoplay end,
        function(on) Settings().autoplay = on end, Refresh)
    layout:Requires(autoplay, function() return Writings:IsPartOn() end,
        "Enable Writings to use automatic reading.")
    layout:Indent()
    local once = layout:Checkbox(S("OPT_READ_ONCE", "Read Only Once"), L.OPT_READ_ONCE_TIP,
        function() return Settings().readOnce end,
        function(on) Settings().readOnce = on end)
    layout:Outdent()
    layout:Requires(once, function() return Writings:IsPartOn() and Settings().autoplay end,
        "Enable Writings and automatic reading to use this.")
    local stopOnClose = layout:Checkbox(S("OPT_STOP_ON_CLOSE", "Stop When Book Closes"), L.OPT_STOP_ON_CLOSE_TIP,
        function() return Settings().stopOnClose end,
        function(on) Settings().stopOnClose = on end)
    layout:Requires(stopOnClose, function() return Writings:IsPartOn() end,
        "Enable Writings to use this.")
    local closeWhenRead = layout:Checkbox(S("OPT_CLOSE_WHEN_READ", "Close Book When Done Reading"), L.OPT_CLOSE_WHEN_READ_TIP,
        function() return Settings().closeWhenRead end,
        function(on) Settings().closeWhenRead = on end)
    layout:Requires(closeWhenRead, function() return Writings:IsPartOn() end,
        "Enable Writings to use this.")
    layout:Note("In the world, the narration follows your page turns. In the Compendium, it plays the whole book.", nil, 40)

    layout:Section(S("OPT_SECTION_PACKS", "Voice Packs"))
    -- This is the same compatible-pack registry used by Books playback.
    -- Metadata is cheap to read; page totals are computed on first expansion.
    layout:PackInventory(function()
        local result = {}
        for _, pack in ipairs(Writings:GetAudioPacks()) do
            local addon = pack.addon
            local version = addon and GetAddOnMetadata and GetAddOnMetadata(addon, "Version")
            local loaded = addon and IsAddOnLoaded and IsAddOnLoaded(addon)
            local demand = addon and IsAddOnLoadOnDemand and IsAddOnLoadOnDemand(addon)
            local fields = {
                { label = "Addon", value = addon },
                { label = "Pack Title", value = pack.title or addon },
                { label = "Content Version", value = version },
                { label = "Data Format", value = pack.version },
                { label = "Language", value = Writings:GetLanguageName(Writings:PackLanguage(pack)) },
                { label = "Registered", value = YES },
                { label = "Loaded", value = loaded and YES or NO },
            }
            if addon and IsAddOnLoadOnDemand then
                table.insert(fields, { label = "Load on Demand", value = demand and YES or NO })
            end
            table.insert(result, {
                id = addon, source = pack, name = pack.title or addon,
                version = version, status = "Registered", details = fields,
                extra = function()
                    local count = 0
                    for _, entry in pairs(pack.pages or {}) do
                        if type(entry) == "table" and entry.file then
                            count = count + 1
                        end
                    end
                    return { { label = "Recorded Pages", value = count } }
                end,
            })
        end
        return result
    end, "No compatible Writings voice packs installed.")
    layout:Note("Voice language is selected on Home. An installed pack may not have a recording for every book in that language.", nil, 38)
    layout:Button("Audio Download Address", 220, function()
        if Spoken and Spoken.ShowDiagnostics then
            Spoken:ShowDiagnostics("Writings Voice Pack", { "Download audio packs from:", DOWNLOAD })
        end
    end, "Show the Writings voice-pack download address in a copyable window.")

    layout:Section(S("OPT_SECTION_READ", "Reading History"))
    layout:Button("Forget What Was Read", 205, function()
        Layout.Confirm("Forget this character's Writings reading history?", "Forget", "Cancel", function()
            Writings:Print("Forgot " .. tostring(Writings:ForgetRead()) .. " readings (discoveries kept)")
            Refresh()
        end)
    end, "Clear read-once history without forgetting discovered books.")
    layout:Button("Open Writings Compendium", 205, function()
        if Writings.ShowReadables then Writings:ShowReadables() end
    end)

    layout:Section("Fix a Problem")
    layout:Button("Show Diagnostics", 205, function() Writings:ShowBooksStatus() end,
        "Open the Writings data, discovery and audio-pack report.")

    layout:Defaults(function()
        Layout.Confirm("Reset Writings preferences? Discoveries and reading history are kept.",
            "Reset", "Cancel", function()
                Writings:ResetOptions()
                Writings:Print("Writings settings reset; discoveries and reading history preserved")
                Refresh()
            end)
    end)

    -- Reading history, discovery, pack diagnostics and reset remain available
    -- when Books narration is off; only audio-dependent controls are disabled.
    frame:SetScript("OnShow", Refresh)
    page = Spoken:AddSettingsPage(frame, "Writings", 3, layout)
    Refresh()
    return frame
end

function Writings:ShowOptions()
    Writings:SetupOptions()
    if page and page.Open then page.Open() end
end

function Writings:BooksStatusLines()
    local books, pages, clips = 0, 0, 0
    local data = self:Data()
    for _ in pairs(data and data.books or {}) do books = books + 1 end
    for _ in pairs(data and data.pages or {}) do pages = pages + 1 end
    local packs = self:GetAudioPacks()
    for _, pack in ipairs(packs) do
        for _ in pairs(pack.pages or {}) do clips = clips + 1 end
    end
    local found, read = 0, 0
    for _ in pairs(Writings.character and Writings.character.found or {}) do found = found + 1 end
    for _ in pairs(Writings.character and Writings.character.read or {}) do read = read + 1 end
    return {
        tostring(books) .. " books / " .. tostring(pages) .. " pages",
        tostring(found) .. " discovered / " .. tostring(read) .. " read",
        tostring(table.getn(packs)) .. " compatible packs / " .. tostring(clips) .. " audio pages",
    }
end

function Writings:ShowBooksStatus()
    if Spoken and Spoken.ShowDiagnostics then
        Spoken:ShowDiagnostics("Writings Diagnostics", self:BooksStatusLines())
    end
end
