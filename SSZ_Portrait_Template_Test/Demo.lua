-- Resizable outer template remains unchanged. Only its interior is added.
local window = CreateFrame("Frame", "SSZPortraitDemoWindow", UIParent, "SSZPortraitFrameTemplate")
-- Shorten only the right pane's default width, matching the Quest Log.
-- The navigation pane is fixed-width and the parchment's right edge follows
-- the window, so the outer frame closes in without an empty stone gutter.
-- The original design used 920 units. Keep that design's LEFT edge fixed
-- as we narrow the right pane, instead of shrinking symmetrically around the
-- screen center (which made each 3-10 unit adjustment hard to notice).
local ORIGINAL_WINDOW_WIDTH = 920
local DEFAULT_WINDOW_WIDTH = 670
window:SetWidth(DEFAULT_WINDOW_WIDTH)
window:SetHeight(600)
window:SetPoint("CENTER", UIParent, "CENTER", -(ORIGINAL_WINDOW_WIDTH - DEFAULT_WINDOW_WIDTH)/2, 0)
window:SetFrameStrata("DIALOG")
window:EnableMouse(true)
window:RegisterForDrag("LeftButton")
window:SetMovable(true)
window:SetScript("OnDragStart",function() this:StartMoving() end)
window:SetScript("OnDragStop",function() this:StopMovingOrSizing() end)
-- Drag resizing was absent from the interior test; the older +/- size buttons
-- were hidden behind /sszsize. Make resizing discoverable without that command.
window:SetResizable(true)
window:SetMinResize(670, 430)

SSZPortrait_BuildInterior(window)

-- Permanent 1.12-compatible bottom-right resize grip. Three diagonal strokes
-- require no external art and do not cover the title, book ring or panels.
local grip = CreateFrame("Button", nil, window)
grip:SetWidth(23)
grip:SetHeight(23)
grip:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -3, 3)
grip:SetFrameLevel(window:GetFrameLevel() + 8)
grip:EnableMouse(true)
for i = 1, 3 do
    -- Small stair-step diagonal markers make a visible grab corner in 1.12.
    for j = 0, 3 do
        local dot = grip:CreateTexture(nil, "OVERLAY")
        dot:SetTexture(0.68, 0.64, 0.54, 0.85)
        dot:SetWidth(2)
        dot:SetHeight(2)
        dot:SetPoint("BOTTOMRIGHT", grip, "BOTTOMRIGHT", -(i*5+j*2-5), i*2+j*2-2)
    end
end
grip:SetScript("OnMouseDown", function()
    if arg1 == "LeftButton" then window:StartSizing("BOTTOMRIGHT") end
end)
grip:SetScript("OnMouseUp", function() window:StopMovingOrSizing() end)
grip:SetScript("OnHide", function() window:StopMovingOrSizing() end)

-- Standalone size controls, outside the content panes (demo only).
local function sizeButton(label,x,action)
    local b=CreateFrame("Button",nil,window,"UIPanelButtonTemplate")
    b:SetWidth(38);b:SetHeight(21)
    b:SetPoint("BOTTOMRIGHT",window,"BOTTOMRIGHT",x,15)
    b:SetText(label)
    b:SetScript("OnClick",action)
    return b
end
-- Only width/height change. Window's OnSizeChanged reflows the outer shell and interior.
-- Controls intentionally occupy the bottom-right margin in this standalone demo.
-- Optional +/- buttons remain accessible with /sszsize; drag grip is always visible.
local plus=sizeButton("+",-12,function()
    window:SetWidth(window:GetWidth()+80)
    window:SetHeight(window:GetHeight()+40)
end)
local minus=sizeButton("-",-54,function()
    window:SetWidth(math.max(670,window:GetWidth()-80))
    window:SetHeight(math.max(430,window:GetHeight()-40))
end)
plus:Hide(); minus:Hide()
SLASH_SSZSIZE1="/sszsize"
SlashCmdList["SSZSIZE"]=function()
    if plus:IsShown() then plus:Hide();minus:Hide()
    else plus:Show();minus:Show() end
end
SLASH_SSZPORTRAIT1="/sszportrait"
SlashCmdList["SSZPORTRAIT"]=function()
    if window:IsShown() then window:Hide() else window:Show() end
end

-- Explicit opt-in data-connection test. The default prototype is untouched.
SLASH_SSZLIVEPLACES1="/sszliveplaces"
SlashCmdList["SSZLIVEPLACES"]=function()
    local enable=not window.SSZIsPreviewingRealPlaces()
    if window.SSZPreviewRealPlaces(enable) then
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage(enable and
                "SSZ prototype: real Places preview ON" or
                "SSZ prototype: demo Places restored")
        end
    elseif DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(
            "SSZ prototype: the real SSZLoreWindow source is not loaded. Demo unchanged.")
    end
end
