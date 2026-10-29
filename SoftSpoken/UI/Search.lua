setfenv(1, SpokenEnv)

-- Search the existing SpokenLayout row index across all registered settings
-- pages. No settings data is stored or changed by this UI.
Search = {}

local MAX_RESULTS = 8
local ROW_HEIGHT = 21
local WIDTH = 470

-- Lua 5.0 uses string.gfind (newer Lua calls this string.gmatch).
local function Terms(value)
    value = string.lower(value or "")
    value = string.gsub(value, "|c%x%x%x%x%x%x%x%x", "")
    value = string.gsub(value, "|r", "")
    local words = {}
    local findWords = string.gmatch or string.gfind
    for word in findWords(value, "[%w\128-\255]+") do
        table.insert(words, word)
    end
    return words
end

local function Plain(value)
    return " " .. table.concat(Terms(value), " ")
end

local function Rank(term, label, section, tooltip, page)
    if string.find(label, " " .. term, 1, true) then return 4 end
    if string.find(label, term, 1, true) then return 3 end
    if string.find(section, term, 1, true) then return 2 end
    if string.find(tooltip, term, 1, true) then return 1 end
    if string.find(page, term, 1, true) then return 1 end
    return nil
end

function Search:Find(query)
    local words, found = Terms(query), {}
    if table.getn(words) == 0 then return found end
    -- Layouts maintain their row visibility whenever a setting changes.
    -- Do not refresh every module on each keystroke; that can invoke module
    -- callbacks and resize inactive pages while the search box has focus.
    for _, page in ipairs(Options:Pages()) do
        local pageName = Plain(page.name)
        for _, entry in ipairs(page.layout.entries or {}) do
            local row = entry.frame and entry.frame.layoutRow
            if row and row.shown ~= false then
                local label, section = Plain(entry.label), Plain(entry.section)
                local tooltip = Plain(entry.tooltip)
                local score = 0
                for _, term in ipairs(words) do
                    local value = Rank(term, label, section, tooltip, pageName)
                    if not value then score = nil; break end
                    score = score + value
                end
                if score then
                    table.insert(found, {page = page, entry = entry, score = score})
                end
            end
        end
    end
    table.sort(found, function(a, b)
        if a.score ~= b.score then return a.score > b.score end
        return tostring(a.entry.label) < tostring(b.entry.label)
    end)
    return found
end

function Search:Go(result)
    if not result then return end
    self.results:Hide()
    self.box:SetText("")
    self.box:ClearFocus()
    Options:ShowRow(result.page, result.entry.frame)
end

function Search:Row(index)
    local row = self.rows[index]
    if row then return row end
    row = CreateFrame("Button", nil, self.results)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("TOPLEFT", self.results, "TOPLEFT", 8, -6 - (index - 1) * ROW_HEIGHT)
    row:SetPoint("TOPRIGHT", self.results, "TOPRIGHT", -8, -6 - (index - 1) * ROW_HEIGHT)
    row:SetHighlightTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]], "ADD")
    row.text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    row.text:SetPoint("LEFT", row, "LEFT", 4, 0)
    row.text:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    row.text:SetJustifyH("LEFT")
    if row.text.SetWordWrap then row.text:SetWordWrap(false) end
    row:SetScript("OnClick", function()
        if row.result then Search:Go(row.result) end
    end)
    self.rows[index] = row
    return row
end

function Search:ShowResults(query)
    local found = self:Find(query)
    self.found = found
    if table.getn(Terms(query)) == 0 then
        self.results:Hide()
        return
    end
    local shown = math.min(MAX_RESULTS, table.getn(found))
    for index = 1, math.max(shown, 1) do
        local row = self:Row(index)
        local result = found[index]
        row.result = result
        if result then
            local where = result.entry.section and
                (result.page.name .. " > " .. result.entry.section) or result.page.name
            row.text:SetText(result.entry.label .. "  |cff999999" .. where .. "|r")
            row:Enable()
        else
            row.text:SetText("|cff999999" .. (L.SEARCH_NONE or "No matching setting") .. "|r")
            row:Disable()
        end
        row:Show()
    end
    for index = math.max(shown, 1) + 1, table.getn(self.rows) do
        self.rows[index]:Hide()
    end
    self.results:SetHeight(12 + math.max(shown, 1) * ROW_HEIGHT)
    self.results:Show()
end

function Search:Fit(width)
    if not self.row then return end
    self.row:SetWidth(width)
    self.results:SetWidth(width)
end

function Search:Build(parent)
    if self.row then return self.row end
    self.height = 26
    local row = CreateFrame("Frame", nil, parent)
    row:SetWidth(WIDTH)
    row:SetHeight(self.height)
    local caption = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    caption:SetPoint("LEFT", row, "LEFT", 4, 0)
    caption:SetText("Search")
    local box = CreateFrame("EditBox", "SpokenSettingsSearchBox", row, "InputBoxTemplate")
    box:SetWidth(330)
    box:SetHeight(20)
    box:SetPoint("LEFT", caption, "RIGHT", 12, 0)
    box:SetAutoFocus(false)
    -- A small native Blizzard close button acts as Clear Search. It belongs
    -- to the search row, not the settings window's close action.
    local clear = CreateFrame("Button", nil, row, "UIPanelCloseButton")
    clear:SetWidth(18)
    clear:SetHeight(18)
    clear:SetPoint("LEFT", box, "RIGHT", 4, 0)
    clear:SetScript("OnClick", function()
        box:SetText("")
        box:SetFocus()
    end)
    clear:Hide()
    local hint = box:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    hint:SetPoint("LEFT", box, "LEFT", 6, 0)
    hint:SetText(L.SEARCH_HINT or "Search settings")

    -- Results are parented to the outer window, never to the clipped scroll
    -- child. They overlay both the tabs and the scrollable content.
    local results = CreateFrame("Frame", nil, parent)
    results:SetPoint("TOPLEFT", row, "BOTTOMLEFT", 0, -5)
    results:SetWidth(WIDTH)
    results:SetFrameStrata("TOOLTIP")
    if results.SetBackdrop then
        results:SetBackdrop({
            bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
            edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
            tile = true, tileSize = 16, edgeSize = 12,
            insets = {left = 3, right = 3, top = 3, bottom = 3},
        })
        results:SetBackdropColor(0.05, 0.05, 0.05, 0.96)
    end
    results:Hide()
    self.box, self.results, self.rows, self.row = box, results, {}, row
    box:SetScript("OnTextChanged", function()
        local value = box:GetText() or ""
        if value == "" then
            hint:Show()
            clear:Hide()
        else
            hint:Hide()
            clear:Show()
        end
        Search:ShowResults(value)
    end)
    box:SetScript("OnEnterPressed", function()
        if Search.found and Search.found[1] then Search:Go(Search.found[1]) end
    end)
    box:SetScript("OnEscapePressed", function()
        box:SetText("")
        box:ClearFocus()
    end)
    return row
end

function Search:BuildLegacy(parent)
    local row = self:Build(parent)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 26, -37)
    row:Show()
    return row
end

function Search:Close()
    self.found = nil
    if self.results then self.results:Hide() end
    if self.box then
        if self.box:GetText() ~= "" then self.box:SetText("") end
        self.box:ClearFocus()
    end
end
