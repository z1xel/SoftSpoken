-- Prototype scroll chrome pilot for the real Turtle WoW Compendium (1.12).
-- Visual: copied from the approved SSZ_Portrait_Template_Test, including the
-- exact native atlas UVs, fixed caps, marble recess, 16-unit button sizes,
-- three-unit thumb shift, pressed-arrow correction, and the two-unit-left
-- right-page offset. Behavior: the EXISTING Compendium scroll controllers own
-- all offsets, content ranges, wheel events, virtual rows and text reflows.
SSCPrototypeScrollSkin = SSCPrototypeScrollSkin or {}
local Skin = SSCPrototypeScrollSkin
local U = SSCUI
local MARBLE = "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Prototype\\UI-Background-Marble"
local SCROLL_ART = "Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar"
local SLOT_WIDTH = 31
-- The approved prototype placed the slider's BOTTOM at +18, exactly level
-- with the down arrow's TOP (+18). On real, fully scrollable content this lets
-- the native thumb visually run into the arrow. Reserve a small independent
-- clearance at maximum scroll; leave the top travel stop and both buttons
-- where the prototype placed them.
local THUMB_BOTTOM_CLEARANCE = 6
local instance = 0

local function PressedArrow(button)
    if not button then return end
    local t=button:GetPushedTexture()
    if not t then return end
    t:ClearAllPoints()
    t:SetPoint("TOPLEFT",button,"TOPLEFT",2,0)
    t:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",2,0)
end

-- Style only: do not replace or reimplement the Compendium scroll model.
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

local function Attach(host,owner,apply,offset,slotOffset)
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
    -- Keep the approved upper stop and native button coordinates. Move only
    -- the lower slider stop up, so the thumb does not crowd the down arrow.
    -- Clear possible inherited anchors to make the two travel limits explicit.
    bar:ClearAllPoints()
    bar:SetPoint("TOP",slot,"TOP",0,-23)
    bar:SetPoint("BOTTOM",slot,"BOTTOM",0,18+THUMB_BOTTOM_CLEARANCE)
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
    bar:SetMinMaxValues(0,0)
    bar:SetValueStep(24)
    bar:SetValue(0)
    syncing=false
    local lastMax,lastOffset=nil,nil
    local function Sync()
        reflow()
        local width=owner.scroll:GetWidth() or 0
        local height=owner.scroll:GetHeight() or 0
        if width<1 or height<1 then return end
        local maximum=math.max(0,U.ScrollMax(owner.scroll,owner.child))
        local value=math.max(0,math.min(maximum,U.ScrollOffset(owner.scroll)))
        if lastMax and math.abs(maximum-lastMax)<0.25 and
           lastOffset and math.abs(value-lastOffset)<0.25 then return end
        lastMax,lastOffset=maximum,value
        syncing=true
        bar:SetMinMaxValues(0,maximum)
        bar:SetValue(value)
        syncing=false
    end
    -- Synchronize following the real renderer's wheel scrolling, dynamic
    -- content changes, native page actions and virtual-list row updates.
    -- Poll only actual offset/range changes; do not allocate frames or textures.
    slot:SetScript("OnUpdate",function() Sync() end)
    owner.sszNativeScrollChrome={slot=slot,slider=bar,sync=Sync}
    Sync()
    return owner.sszNativeScrollChrome
end

function Skin.AttachList(list)
    if not list or not list.bar or not list.inset then return end
    -- Keep the full production scrolling contract (U.NewThinScrollBar).
    -- Hide only the original thin *art and hitboxes*, not its model.
    local thin=list.bar
    thin:SetAlpha(0)
    thin:EnableMouse(false)
    if thin.thumb then thin.thumb:EnableMouse(false) end
    -- Prototype: list inset x=4..307, native slot x=303..334.
    return Attach(list.inset,list,function(v) thin:SetValue(v) end,nil,27)
end

function Skin.AttachPage(pageInset,page)
    local view=page and page.body
    if not view or not view.slider then return end
    -- This is the right-side gutter reserved outside the parchment holder.
    local thin=view.slider
    thin:SetAlpha(0)
    thin:EnableMouse(false)
    if view.thumb then view.thumb:EnableMouse(false) end
    -- The approved page scrollbar was shifted two units left in its final pass.
    -- Prototype: parchment x=334..641; native page slot x=635..666.
    return Attach(pageInset,view,function(v) view:ScrollTo(v) end,nil,-4)
end
