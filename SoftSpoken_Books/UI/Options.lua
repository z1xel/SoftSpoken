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

    local switch = layout:Checkbox("Enable Books", "Allow book and letter narration.",
        function() return B:IsPartOn() end,
        function(on) Spoken:SetPartOn("books", on) end, Refresh)
    layout:Section(S("OPT_SECTION_READING", "When to Read"))
    local autoplay = layout:Checkbox(S("OPT_AUTOPLAY", "Read Automatically"),
        L.OPT_AUTOPLAY_TIP,
        function() return Settings().autoplay end,
        function(on) Settings().autoplay = on end, Refresh)
    layout:Indent()
    local once = layout:Checkbox(S("OPT_READ_ONCE", "Read Only Once"), L.OPT_READ_ONCE_TIP,
        function() return Settings().readOnce end,
        function(on) Settings().readOnce = on end)
    layout:Outdent()
    layout:Requires(once, function() return Settings().autoplay end,
        "Turn on automatic reading to use this.")
    layout:Checkbox(S("OPT_STOP_ON_CLOSE", "Stop When Book Closes"), L.OPT_STOP_ON_CLOSE_TIP,
        function() return Settings().stopOnClose end,
        function(on) Settings().stopOnClose = on end)
    layout:Checkbox(S("OPT_CLOSE_WHEN_READ", "Close Book When Done Reading"), L.OPT_CLOSE_WHEN_READ_TIP,
        function() return Settings().closeWhenRead end,
        function(on) Settings().closeWhenRead = on end)
    layout:Note("In the world, the narration follows your page turns. In the Compendium, it plays the whole book.", nil, 40)

    layout:Section(S("OPT_SECTION_PACKS", "Voice Packs"))
    local packNote = layout:Note("", nil, 28)
    layout:OnRefresh(function()
        local count = table.getn(B:GetAudioPacks())
        packNote:SetText(count == 0 and "No compatible Books voice pack installed."
            or tostring(count) .. " compatible Books voice pack(s) installed.")
    end)
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
    layout:Button("Show Diagnostics", 205, function() B:ShowBooksStatus() end)

    layout:Defaults(function()
        Layout.Confirm("Reset Books preferences? Discoveries and reading history are kept.",
            "Reset", "Cancel", function()
                B:ResetOptions()
                B:Print("Books settings reset; discoveries and reading history preserved")
                Refresh()
            end)
    end)

    layout:RequiresAll(function() return B:IsPartOn() end,
        "Enable Books to configure this module.", switch)
    frame:SetScript("OnShow", Refresh)
    page = Spoken:AddSettingsPage(frame, "Books", 2, layout)
    Refresh()
    return frame
end

function B:ShowOptions()
    B:SetupOptions()
    if page and page.Open then page.Open() end
end

function B:ShowBooksStatus()
    local books,pages,clips=0,0,0
    for _ in pairs(self:Data() and self:Data().books or {}) do books=books+1 end
    for _ in pairs(self:Data() and self:Data().pages or {}) do pages=pages+1 end
    local packs=self:GetAudioPacks()
    for _,p in ipairs(packs) do for _ in pairs(p.pages) do clips=clips+1 end end
    local found,read=0,0
    for _ in pairs(SSBCharacter and SSBCharacter.found or {}) do found=found+1 end
    for _ in pairs(SSBCharacter and SSBCharacter.read or {}) do read=read+1 end
    self:Print(tostring(books).." books / "..tostring(pages).." pages; "..tostring(found).." discovered / "..tostring(read).." read")
    self:Print(tostring(table.getn(packs)).." compatible packs / "..tostring(clips).." audio pages")
end
