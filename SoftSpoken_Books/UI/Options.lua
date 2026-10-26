-- Books settings page: shares SoftSpoken's native 1.12 frame and layout.
-- The reader and SavedVariables retain ownership of every behavior.
local B = SSB
local L = B.L or {}
local Layout = SpokenLayout
local page
local frame
local layout
local DOWNLOAD = "https://www.curseforge.com/wow/addons/spoken-books-audio"

local function S(key, fallback) return L[key] or fallback end
local function Settings()
    if not SSBSettings then B:InitDB() end
    return SSBSettings
end
local function Refresh()
    if layout then layout:Refresh() end
end

function B:RefreshOptions()
    Refresh()
end

function B:SetupOptions()
    if frame then return frame end
    if not (Spoken and Spoken.AddSettingsPage and Layout) then return nil end
    frame = CreateFrame("Frame", nil, UIParent)
    frame:SetWidth(470)
    frame:SetHeight(1)
    frame:Hide()
    layout = Layout.New(frame, 25, -16)
    layout:Intro([[Interface\Icons\INV_Misc_Book_09]], "Books")

    layout:Checkbox("Enable Books", "Allow book and letter narration.",
        function() return B:IsPartOn() end,
        function(on) Spoken:SetPartOn("books", on) end, Refresh)
    layout:Section(S("OPT_SECTION_READING", "When to Read"))
    local autoplay = layout:Checkbox(S("OPT_AUTOPLAY", "Read Automatically"),
        L.OPT_AUTOPLAY_TIP,
        function() return Settings().autoplay end,
        function(on) Settings().autoplay = on end, Refresh)
    layout:Requires(autoplay, function() return B:IsPartOn() end,
        "Enable Books to use automatic reading.")
    layout:Indent()
    local once = layout:Checkbox(S("OPT_READ_ONCE", "Read Only Once"), L.OPT_READ_ONCE_TIP,
        function() return Settings().readOnce end,
        function(on) Settings().readOnce = on end)
    layout:Outdent()
    layout:Requires(once, function() return B:IsPartOn() and Settings().autoplay end,
        "Enable Books and automatic reading to use this.")
    local stopOnClose = layout:Checkbox(S("OPT_STOP_ON_CLOSE", "Stop When Book Closes"), L.OPT_STOP_ON_CLOSE_TIP,
        function() return Settings().stopOnClose end,
        function(on) Settings().stopOnClose = on end)
    layout:Requires(stopOnClose, function() return B:IsPartOn() end,
        "Enable Books to use this.")
    local closeWhenRead = layout:Checkbox(S("OPT_CLOSE_WHEN_READ", "Close Book When Done Reading"), L.OPT_CLOSE_WHEN_READ_TIP,
        function() return Settings().closeWhenRead end,
        function(on) Settings().closeWhenRead = on end)
    layout:Requires(closeWhenRead, function() return B:IsPartOn() end,
        "Enable Books to use this.")
    layout:Note("In the world, the narration follows your page turns. In the Compendium, it plays the whole book.", nil, 40)

    layout:Section(S("OPT_SECTION_PACKS", "Voice Packs"))
    -- This is the same compatible-pack registry used by Books playback.
    -- Metadata is cheap to read; page totals are computed on first expansion.
    layout:PackInventory(function()
        local result = {}
        for _, pack in ipairs(B:GetAudioPacks()) do
            local source = pack
            local addon = source.addon
            local version = addon and GetAddOnMetadata and GetAddOnMetadata(addon, "Version")
            local loaded = addon and IsAddOnLoaded and IsAddOnLoaded(addon)
            local demand = addon and IsAddOnLoadOnDemand and IsAddOnLoadOnDemand(addon)
            local fields = {
                { label = "Addon", value = addon },
                { label = "Pack Title", value = source.title or addon },
                { label = "Content Version", value = version },
                { label = "Data Format", value = source.version },
                { label = "Language", value = B:GetLanguageName(B:PackLanguage(source)) },
                { label = "Registered", value = YES },
                { label = "Loaded", value = loaded and YES or NO },
            }
            if addon and IsAddOnLoadOnDemand then
                table.insert(fields, { label = "Load on Demand", value = demand and YES or NO })
            end
            table.insert(result, {
                id = addon, source = source, name = source.title or addon,
                version = version, status = "Registered", details = fields,
                extra = function()
                    local count = 0
                    for _, entry in pairs(source.pages or {}) do
                        if type(entry) == "table" and entry.file then
                            count = count + 1
                        end
                    end
                    return { { label = "Recorded Pages", value = count } }
                end,
            })
        end
        return result
    end, "No compatible Books voice packs installed.")
    layout:Note("Voice language is selected on Home. An installed pack may not have a recording for every book in that language.", nil, 38)
    layout:Button("Audio Download Address", 220, function()
        B:Print("Books audio: " .. DOWNLOAD)
    end, "Print the existing Books voice-pack download address.")

    layout:Section(S("OPT_SECTION_READ", "Reading History"))
    layout:Button("Forget What Was Read", 205, function()
        Layout.Confirm("Forget this character's Books reading history?", "Forget", "Cancel", function()
            B:Print("Forgot " .. tostring(B:ForgetRead()) .. " readings (discoveries kept)")
            Refresh()
        end)
    end, "Clear read-once history without forgetting discovered books.")
    layout:Button("Open Books Compendium", 205, function()
        if B.ShowReadables then B:ShowReadables() end
    end)

    layout:Section("Fix a Problem")
    layout:Button("Show Diagnostics", 205, function() B:ShowBooksStatus() end,
        "Open the Books data, discovery and audio-pack report.")

    layout:Defaults(function()
        Layout.Confirm("Reset Books preferences? Discoveries and reading history are kept.",
            "Reset", "Cancel", function()
                B:ResetOptions()
                B:Print("Books settings reset; discoveries and reading history preserved")
                Refresh()
            end)
    end)

    -- Reading history, discovery, pack diagnostics and reset remain available
    -- when Books narration is off; only audio-dependent controls are disabled.
    frame:SetScript("OnShow", Refresh)
    page = Spoken:AddSettingsPage(frame, "Books", 2, layout)
    Refresh()
    return frame
end

function B:ShowOptions()
    B:SetupOptions()
    if page and page.Open then page.Open() end
end

-- Create the shared Books page at login, not only when opened.
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    loader:UnregisterEvent("PLAYER_LOGIN")
    B:SetupOptions()
end)

function B:BooksStatusLines()
    local books, pages, clips = 0, 0, 0
    local data = self:Data()
    for _ in pairs(data and data.books or {}) do books = books + 1 end
    for _ in pairs(data and data.pages or {}) do pages = pages + 1 end
    local packs = self:GetAudioPacks()
    for _, pack in ipairs(packs) do
        for _ in pairs(pack.pages or {}) do clips = clips + 1 end
    end
    local found, read = 0, 0
    for _ in pairs(SSBCharacter and SSBCharacter.found or {}) do found = found + 1 end
    for _ in pairs(SSBCharacter and SSBCharacter.read or {}) do read = read + 1 end
    return {
        tostring(books) .. " books / " .. tostring(pages) .. " pages",
        tostring(found) .. " discovered / " .. tostring(read) .. " read",
        tostring(table.getn(packs)) .. " compatible packs / " .. tostring(clips) .. " audio pages",
    }
end

function B:ShowBooksStatus()
    if Spoken and Spoken.ShowDiagnostics then
        Spoken:ShowDiagnostics("Books Diagnostics", self:BooksStatusLines())
    end
end
