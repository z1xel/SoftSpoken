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

-- Shared ClassicAPI scroll-edge fade for both text readers and virtualized
-- list viewports. The viewport owns the clipping; headers, backgrounds,
-- borders and native scrollbar housings stay outside the gradient.
local EDGE_FADE_LENGTH = 18
function U.RefreshScrollEdgeFade(owner)
    if not (owner and owner.edgeFadeEnabled) then return end
    local scroll,child=owner.scroll,owner.child
    local maximum=ScrollMax(scroll,child)
    local offset=math.max(0,math.min(maximum,ScrollOffset(scroll)))
    local top=math.min(EDGE_FADE_LENGTH,offset)
    local bottom=math.min(EDGE_FADE_LENGTH,math.max(0,maximum-offset))
    if owner.edgeFadeTop==top and owner.edgeFadeBottom==bottom then return end
    local ok=pcall(function()
        if owner.edgeFadeTop~=top then
            scroll:SetAlphaGradient(0,{x=0,y=top})
        end
        if owner.edgeFadeBottom~=bottom then
            scroll:SetAlphaGradient(1,{x=0,y=bottom})
        end
    end)
    if not ok then
        -- Keep the scrollable content usable when optional ClassicAPI fails.
        owner.edgeFadeEnabled=false
        owner.edgeFadeTop=nil
        owner.edgeFadeBottom=nil
        if scroll.ClearAlphaGradient then pcall(scroll.ClearAlphaGradient,scroll) end
        pcall(scroll.SetClipsChildren,scroll,false)
        return
    end
    owner.edgeFadeTop=top
    owner.edgeFadeBottom=bottom
end

function U.EnableScrollEdgeFade(owner)
    local scroll=owner and owner.scroll
    if not scroll or owner.edgeFadeEnabled or not
            (scroll.SetClipsChildren and scroll.SetAlphaGradient) then return end
    -- The native ClassicAPI alpha gradient is effective only when the frame
    -- clips its children; unsupported clients retain their original reader.
    local ok=pcall(scroll.SetClipsChildren,scroll,true)
    if not ok then return end
    owner.edgeFadeEnabled=true
    U.RefreshScrollEdgeFade(owner)
end

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
