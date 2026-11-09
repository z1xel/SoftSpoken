-- Shared 1.12 UI helpers for the Compendium and lore views.
SSCUI = SSCUI or {}
local U = SSCUI
local function ScrollMax(sc,content)
    return math.max(0,(content:GetHeight() or 0)-(sc:GetHeight() or 0))
end
-- The Turtle 1.12 client may expose GetVerticalScroll while lacking
-- SetVerticalScroll on dynamically created scroll frames. Use native scrolling
-- when it exists; otherwise move the ScrollChild inside the clipped frame.
-- Keep the offset ourselves so list virtualization works on both clients.
local function ScrollOffset(sc)
    return sc and (sc.sz112ScrollOffset or 0) or 0
end
local function SetScrollOffset(sc,content,value)
    if not sc or not content then return end
    value=math.max(0,math.min(tonumber(value) or 0,ScrollMax(sc,content)))
    sc.sz112ScrollOffset=value
    if sc.SetVerticalScroll then
        sc:SetVerticalScroll(value)
    else
        content:ClearAllPoints()
        content:SetPoint("TOPLEFT",sc,"TOPLEFT",0,value)
    end
end
local function MouseWheelDelta(first,second)
    -- 1.12 passes wheel delta in the global arg1; newer clients pass arguments.
    if type(second)=="number" then return second end
    if type(arg1)=="number" then return arg1 end
    if type(first)=="number" then return first end
    return 0
end
local function AddBorder(frame,background)
    frame:SetBackdrop({
        bgFile=background or "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
        tile=true, tileSize=32, edgeSize=24,
        insets={left=8,right=8,top=8,bottom=8}
    })
end

U.ScrollMax = ScrollMax
U.ScrollOffset = ScrollOffset
U.SetScrollOffset = SetScrollOffset
U.MouseWheelDelta = MouseWheelDelta
U.AddBorder = AddBorder

-- A subdued 1.12 inset: the original uses InsetFrameTemplate, absent in Vanilla.
-- Use native 1.12 tooltip textures rather than a second ornate dialog border.
function U.AddInsetBorder(frame)
    frame:SetBackdrop({
        bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true,tileSize=16,edgeSize=12,
        insets={left=3,right=3,top=3,bottom=3}
    })
    if frame.SetBackdropColor then frame:SetBackdropColor(.10,.09,.07,.74) end
    if frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(.48,.43,.34,.78)
    end
end
