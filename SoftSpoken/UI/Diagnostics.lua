setfenv(1, SpokenEnv)

-- A read-only, copyable in-game report. The diagnostics generators return text
-- instead of printing into chat; the viewer is built only on first use.
-- Everything here is compatible with the Turtle WoW 1.12 frame API.
DiagnosticsViewer = {}
local window, heading, scroll, content, edit

local function Build()
    if window then return end
    window = CreateFrame("Frame", "SoftSpokenDiagnosticsWindow", UIParent)
    window:SetWidth(570)
    window:SetHeight(440)
    window:SetPoint("CENTER", UIParent, "CENTER")
    window:SetFrameStrata("DIALOG")
    window:SetMovable(true)
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", function() window:StartMoving() end)
    window:SetScript("OnDragStop", function() window:StopMovingOrSizing() end)
    window:SetBackdrop({
        bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
        edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
        tile = true, tileSize = 32, edgeSize = 32,
        insets = {left = 10, right = 10, top = 10, bottom = 10},
    })
    window:SetBackdropColor(0.08, 0.08, 0.09, 1)

    heading = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOP", window, "TOP", 0, -20)
    heading:SetText("SoftSpoken Diagnostics")

    local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", window, "TOPRIGHT", -5, -5)
    close:SetScript("OnClick", function() window:Hide() end)

    local help = window:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    help:SetPoint("TOPLEFT", window, "TOPLEFT", 28, -49)
    help:SetText("Click the report, then press Ctrl+A and Ctrl+C to copy.")

    scroll = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", window, "TOPLEFT", 29, -78)
    scroll:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -49, 27)

    content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(480)
    content:SetHeight(1)
    scroll:SetScrollChild(content)

    edit = CreateFrame("EditBox", nil, content)
    edit:SetMultiLine(true)
    edit:SetMaxLetters(0) -- Full diagnostic reports can exceed the default input limit.
    edit:SetAutoFocus(false)
    edit:SetFontObject("ChatFontNormal")
    edit:SetWidth(470)
    edit:SetHeight(1)
    edit:SetPoint("TOPLEFT", content, "TOPLEFT", 2, -2)
    edit:SetTextColor(0.96, 0.94, 0.87)
    -- Reject edits but allow selection and normal Ctrl+C copying.
    edit:SetScript("OnTextChanged", function()
        if edit.settingText then return end
        if edit:GetText() ~= edit.reportText then
            edit.settingText = true
            edit:SetText(edit.reportText or "")
            edit.settingText = nil
        end
    end)
    edit:SetScript("OnEscapePressed", function()
        edit:ClearFocus()
        window:Hide()
    end)
    if UISpecialFrames then table.insert(UISpecialFrames, "SoftSpokenDiagnosticsWindow") end
    window:Hide()
end

function DiagnosticsViewer:Show(title, lines)
    Build()
    local text
    if type(lines) == "table" then
        local formatted = {}
        for _, line in ipairs(lines) do
            local plain = tostring(line)
            plain = string.gsub(plain, "|c%x%x%x%x%x%x%x%x", "")
            plain = string.gsub(plain, "|r", "")
            table.insert(formatted, plain)
        end
        text = table.concat(formatted, "\n")
    else
        text = tostring(lines or "No diagnostics available.")
        text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
        text = string.gsub(text, "|r", "")
    end
    if text == "" then text = "No diagnostics available." end
    heading:SetText(title or "SoftSpoken Diagnostics")
    edit.reportText = text
    edit.settingText = true
    edit:SetText(text)
    edit.settingText = nil
    -- Approximate wrapped height for long reports (1.12 has no automatic
    -- multiline scroll-child measurement that works on all clients).
    local count = 0
    local find = string.gfind or string.gmatch
    for line in find(text .. "\n", "(.-)\n") do
        count = count + math.max(1, math.ceil(string.len(line) / 75))
    end
    local height = math.max(scroll:GetHeight() or 330, count * 16 + 16)
    content:SetHeight(height)
    edit:SetHeight(height)
    if edit.SetCursorPosition then edit:SetCursorPosition(0) end
    scroll:SetVerticalScroll(0)
    window:Show()
    return true
end
