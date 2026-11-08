-- Prototype scroll chrome pilot for the real Turtle WoW Compendium (1.12).
-- Visual: copied from the approved SSZ_Portrait_Template_Test, including the
-- exact native atlas UVs, fixed caps, marble recess, 16-unit button sizes,
-- three-unit thumb shift, pressed-arrow correction, and the two-unit-left
-- right-page offset. Native sliders connect directly to the list/reader
-- offset controllers; no duplicate hidden scrollbar is constructed.
SSCPrototypeScrollSkin = SSCPrototypeScrollSkin or {}
local Skin = SSCPrototypeScrollSkin
local U = SSCUI
local MARBLE = "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Prototype\\UI-Background-Marble"
local SCROLL_ART = "Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar"
local SLOT_WIDTH = 31
-- The native 1.12 UIPanelScrollBarTemplate has a fixed 16x16 knob whose
-- center travels to the Slider's endpoints. Leave half a knob plus 2 units
-- at BOTH ends so it cannot overlap the fixed up/down arrows on resize.
-- Keep the approved arrow and housing positions unchanged.
local THUMB_SIZE, THUMB_EDGE_GAP = 16, 2
local TRACK_TOP = 20 + THUMB_SIZE/2 + THUMB_EDGE_GAP
local TRACK_BOTTOM = 18 + THUMB_SIZE/2 + THUMB_EDGE_GAP
local instance = 0

local function PressedArrow(button)
    if not button then return end
    local t=button:GetPushedTexture()
    if not t then return end
    t:ClearAllPoints()
    t:SetPoint("TOPLEFT",button,"TOPLEFT",2,0)
    t:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",2,0)
end

-- Use the original 1.12 slider and housing, leaving content scrolling to its owner.
local function Housing(host,location)
    local slot=CreateFrame("Frame",nil,host)
    slot:SetWidth(SLOT_WIDTH)
    slot:SetPoint("TOPRIGHT",host,"TOPRIGHT",location or 0,0)
    slot:SetPoint("BOTTOMRIGHT",host,"BOTTOMRIGHT",location or 0,0)
    slot:SetFrameLevel(host:GetFrameLevel()+2)
    slot:SetBackdrop({bgFile=MARBLE,tile=true,tileSize=256,
        insets={left=0,right=0,top=0,bottom=0}})

    local upper=slot:CreateTexture(nil,"ARTWORK")
    upper:SetTexture(SCROLL_ART)
    upper:SetWidth(31);upper:SetHeight(256)
    upper:SetTexCoord(0,0.484375,0,1)
    upper:SetPoint("TOPLEFT",slot,"TOPLEFT",0,0)

    local lower=slot:CreateTexture(nil,"ARTWORK")
    lower:SetTexture(SCROLL_ART)
    lower:SetWidth(31);lower:SetHeight(106)
    lower:SetTexCoord(0.515625,1,0,0.4140625)
    lower:SetPoint("BOTTOMLEFT",slot,"BOTTOMLEFT",0,0)

    local middle=slot:CreateTexture(nil,"ARTWORK")
    middle:SetTexture(SCROLL_ART)
    middle:SetWidth(31)
    middle:SetTexCoord(0,0.484375,0.75,1)
    middle:SetPoint("TOPLEFT",upper,"BOTTOMLEFT",0,0)

    local lastHeight=nil
    local function Reflow()
        local top,bottom=slot:GetTop(),slot:GetBottom()
        local h=(top and bottom) and (top-bottom) or slot:GetHeight()
        if not h or h<100 then return end
        if lastHeight and math.abs(lastHeight-h)<0.25 then return end
        lastHeight=h
        local gap=h-362
        if gap>0.5 then middle:SetHeight(gap);middle:Show()
        else middle:Hide() end
    end
    slot:SetScript("OnSizeChanged",function() Reflow() end)
    Reflow()
    return slot,Reflow
end

local function Attach(host,owner,apply,slotOffset)
    if not host or not owner or not owner.scroll or not owner.child then return end
    if owner.sszNativeScrollChrome then return owner.sszNativeScrollChrome end
    local slot,reflow=Housing(host,slotOffset)
    instance=instance+1
    local name="SSCPrototypeScrollBar"..instance
    local bar=CreateFrame("Slider",name,slot,"UIPanelScrollBarTemplate")
    -- The Blizzard 1.12 template inherits an OnValueChanged script that calls
    -- parent:SetVerticalScroll(). Our parent is a decorative housing Frame,
    -- so replace that script BEFORE setting the slider's initial range/value.
    -- A range/value initialization may itself fire OnValueChanged.
    local syncing=true
    bar:SetScript("OnValueChanged",function()
        if not syncing then
            local value=bar:GetValue() or 0
            apply(value)
        end
    end)
    -- The Slider positions its thumb at the track endpoints, not inset by
    -- half the knob size. The track therefore needs its own safe travel stops.
    bar:ClearAllPoints()
    bar:SetPoint("TOP",slot,"TOP",0,-TRACK_TOP)
    bar:SetPoint("BOTTOM",slot,"BOTTOM",0,TRACK_BOTTOM)
    bar:SetWidth(16)
    local up=getglobal(name.."ScrollUpButton")
    local down=getglobal(name.."ScrollDownButton")
    if up then
        up:ClearAllPoints()
        up:SetPoint("BOTTOM",slot,"TOP",0,-20)
    end
    if down then
        down:ClearAllPoints()
        down:SetPoint("TOP",slot,"BOTTOM",0,18)
        -- The Compendium resize grip owns the overlapping bottom-right
        -- corner. Leave the arrow at its native level rather than covering it.
    end
    PressedArrow(up);PressedArrow(down)
    -- Vanilla's ScrollFrame_OnScrollRangeChanged normally hides this knob at
    -- range zero and manages arrow states. Our standalone slider must do so.
    local thumb=getglobal(name.."ThumbTexture")
    bar:SetMinMaxValues(0,0)
    bar:SetValueStep(24)
    bar:SetValue(0)
    syncing=false
    local lastMax,lastOffset,lastTrackHeight=nil,nil,nil
    local inSync=false
    local function Sync()
        -- Resizing and clamping can trigger OnVerticalScroll synchronously.
        if inSync then return end
        inSync=true
        reflow()
        local width=owner.scroll:GetWidth() or 0
        local height=owner.scroll:GetHeight() or 0
        local trackHeight=bar:GetHeight() or 0
        if width<1 or height<1 or trackHeight<THUMB_SIZE+THUMB_EDGE_GAP*2 then
            -- A temporarily unresolved resize must never paint the knob
            -- outside the usable slider track.
            if thumb then thumb:Hide() end
            if up then up:Disable() end
            if down then down:Disable() end
            lastTrackHeight=nil
            inSync=false
            return
        end
        local maximum=math.max(0,U.ScrollMax(owner.scroll,owner.child))
        local raw=U.ScrollOffset(owner.scroll)
        local value=math.max(0,math.min(maximum,raw))
        -- When a viewport grows, its old offset may exceed the NEW range.
        -- Clamp the actual scroll model as well as the visual slider.
        if math.abs(raw-value)>0.25 then apply(value) end
        -- The old thin thumb recomputed its travel after every resize.
        -- A native Slider also needs a refresh when its physical track changes,
        -- even when the scroll range and selected value happen to stay equal.
        if lastMax==nil or math.abs(maximum-lastMax)>=0.25 or
           lastOffset==nil or math.abs(value-lastOffset)>=0.25 or
           lastTrackHeight==nil or math.abs(trackHeight-lastTrackHeight)>=0.25 then
            lastMax,lastOffset,lastTrackHeight=maximum,value,trackHeight
            syncing=true
            bar:SetMinMaxValues(0,maximum)
            bar:SetValue(value)
            syncing=false
        end
        -- Match the original 1.12 ScrollFrame_OnScrollRangeChanged behavior.
        -- A range-zero thumb isn't scrollable and must not remain visible.
        if thumb then
            if maximum>0.5 then thumb:Show() else thumb:Hide() end
        end
        if up then
            if value>0.5 then up:Enable() else up:Disable() end
        end
        if down then
            if maximum-value>0.5 then down:Enable() else down:Disable() end
        end
        inSync=false
    end
    -- A height-only change needs to revalidate the 16px knob travel; the
    -- OnUpdate fallback also catches delayed Vanilla frame layout.
    bar:SetScript("OnSizeChanged",function() Sync() end)
    slot:SetScript("OnUpdate",function() Sync() end)
    owner.sszNativeScrollChrome={slot=slot,slider=bar,sync=Sync}
    Sync()
    return owner.sszNativeScrollChrome
end

function Skin.AttachList(list)
    if not list or not list.inset or not list.scroll or not list.child then return end
    -- The native control now calls the list's scroll model directly.
    -- Prototype: list inset x=4..307, native slot x=303..334.
    return Attach(list.inset,list,function(v) list:ScrollTo(v) end,27)
end

function Skin.AttachPage(pageInset,page)
    local view=page and page.body
    if not view or not view.scroll or not view.child then return end
    -- The right-side gutter belongs to the independent native housing.
    -- Prototype: parchment x=334..641; native page slot x=635..666.
    return Attach(pageInset,view,function(v) view:ScrollTo(v) end,-4)
end
