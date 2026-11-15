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

    -- Use the Compendium's native three-piece Common-Input-Border instead of
    -- InputBoxTemplate's larger border/shadow. The fallback is for clients
    -- where the shared Compendium skin has not been initialized.
    local ornate = SSCCompendiumInteriorSkin and SSCCompendiumInteriorSkin.ApplySearch
    local box
    if ornate then
        box = CreateFrame("EditBox", "SpokenSettingsSearchBox", row)
        box:SetFontObject(ChatFontNormal)
        ornate(box)
    else
        box = CreateFrame("EditBox", "SpokenSettingsSearchBox", row, "InputBoxTemplate")
    end
    box:SetHeight(21)
    box:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -2)
    box:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, -2)
    box:SetAutoFocus(false)
    box:SetMaxLetters(70)
    if box.SetTextInsets then box:SetTextInsets(21, 21, 0, 0) end

    -- Match the Compendium's bundled search glass, always-visible clear icon,
    -- inside-the-field hint, and contextual hover/focus tinting on Vanilla.
    local controlArt = "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Controls\\"
    local glass = box:CreateTexture(nil, "ARTWORK")
    glass:SetTexture(controlArt .. "UI-SearchBox-Icon")
    glass:SetWidth(14)
    glass:SetHeight(14)
    glass:SetPoint("LEFT", box, "LEFT", 3, -1)

    local hint = box:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("LEFT", box, "LEFT", 21, 0)
    hint:SetText("Search settings")

    local clear = CreateFrame("Button", nil, box)
    clear:SetWidth(17)
    clear:SetHeight(17)
    clear:SetPoint("RIGHT", box, "RIGHT", -3, 0)
    clear:SetNormalTexture(controlArt .. "UI-SearchBox-Clear")
    clear:SetPushedTexture(controlArt .. "UI-SearchBox-Clear")
    clear:SetHighlightTexture(controlArt .. "UI-SearchBox-Clear", "ADD")
    for _, getter in ipairs({ "GetNormalTexture", "GetPushedTexture", "GetHighlightTexture" }) do
        local texture = clear[getter](clear)
        if texture then
            texture:ClearAllPoints()
            texture:SetWidth(14)
            texture:SetHeight(14)
            if getter == "GetPushedTexture" then
                texture:SetPoint("CENTER", clear, "CENTER", 1, -1)
            else
                texture:SetPoint("CENTER", clear, "CENTER", 0, 0)
            end
        end
    end
    local highlight = clear:GetHighlightTexture()
    if highlight then highlight:SetAlpha(.25) end

    local focused, hovered, clearHovered = false, false, false
    local function PaintSearch()
        local nonempty = (box:GetText() or "") ~= ""
        if nonempty or focused then hint:Hide() else hint:Show() end
        local active = focused or hovered or clearHovered
        glass:SetAlpha(active and 1 or .6)
        local clearAlpha = clearHovered and 1 or
            (nonempty and .8 or (focused and .6 or .4))
        local normal = clear:GetNormalTexture()
        local pushed = clear:GetPushedTexture()
        if normal then normal:SetAlpha(clearAlpha) end
        if pushed then pushed:SetAlpha(clearAlpha) end
        local border = box.sszSearchBorder
        if border then
            local shade = active and 1 or .85
            for _, piece in ipairs(border) do
                piece:SetVertexColor(shade, shade, shade, 1)
            end
        end
    end

    -- Results still float above the tabs/content, outside the clipped viewport.
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

    clear:SetScript("OnEnter", function() clearHovered = true; PaintSearch() end)
    clear:SetScript("OnLeave", function() clearHovered = false; PaintSearch() end)
    clear:SetScript("OnClick", function()
        if (box:GetText() or "") ~= "" then box:SetText("") end
        box:SetFocus()
    end)
    box:SetScript("OnEnter", function() hovered = true; PaintSearch() end)
    box:SetScript("OnLeave", function() hovered = false; PaintSearch() end)
    box:SetScript("OnEditFocusGained", function() focused = true; PaintSearch() end)
    box:SetScript("OnEditFocusLost", function() focused = false; PaintSearch() end)
    box:SetScript("OnTextChanged", function()
        PaintSearch()
        Search:ShowResults(box:GetText() or "")
    end)
    box:SetScript("OnEnterPressed", function()
        if Search.found and Search.found[1] then Search:Go(Search.found[1]) end
    end)
    box:SetScript("OnEscapePressed", function()
        box:SetText("")
        box:ClearFocus()
    end)
    PaintSearch()
    return row
end
function Search:BuildLegacy(parent)
    local row = self:Build(parent)
    -- Match the full-width ornamental frame with balanced 18-unit margins.
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 15, -70)
    self:Fit(520)
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
