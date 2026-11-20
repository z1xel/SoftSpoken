-- Run from repository root: lua5.1 tests/compendium_scroll_efficiency.lua
-- Tiny fake WoW frame graph: count fallback geometry queries at simulated 60fps.
-- This verifies Lua callback budgets, NOT GPU frame rate or ClassicAPI rendering.
local function eq(v, expected, message)
    assert(v == expected, (message or "mismatch") ..
        ": " .. tostring(v) .. " ~= " .. tostring(expected))
end

local function Texture()
    local t = {}
    function t:SetTexture() end
    function t:SetTexCoord() end
    function t:SetWidth(v) self.width=v end
    function t:SetHeight(v) self.height=v end
    function t:SetPoint() end
    function t:ClearAllPoints() end
    function t:SetAlpha() end
    function t:Show() self.shown=true end
    function t:Hide() self.shown=false end
    return t
end

local function Frame(kind, name, parent)
    local f = {
        name=name, parent=parent, scripts={}, shown=true,
        width=(parent and parent.width) or 300,
        height=(parent and parent.height) or 500,
        frameLevel=0, widthReads=0, boundReads=0,
    }
    function f:CreateTexture() return Texture() end
    function f:SetTexture() end
    function f:SetNormalTexture() self.normal=Texture() end
    function f:GetNormalTexture() return self.normal end
    function f:GetThumbTexture() return nil end
    function f:SetWidth(v) self.width=v end
    function f:SetHeight(v) self.height=v end
    function f:GetWidth() self.widthReads=self.widthReads+1;return self.width end
    function f:GetHeight() return self.height end
    function f:GetLeft() self.boundReads=self.boundReads+1;return 0 end
    function f:GetRight() return self.width end
    function f:GetTop() return self.height end
    function f:GetBottom() return 0 end
    function f:SetPoint() end
    function f:ClearAllPoints() end
    function f:SetFrameLevel(v) self.frameLevel=v end
    function f:GetFrameLevel() return self.frameLevel end
    function f:SetBackdrop() end
    function f:SetBackdropColor() end
    function f:SetScript(event, handler) self.scripts[event]=handler end
    function f:EnableMouse() end
    function f:Show() self.shown=true end
    function f:Hide() self.shown=false end
    function f:IsShown() return self.shown end
    function f:SetValueStep() end
    function f:SetMinMaxValues(low,high) self.low=low;self.high=high end
    function f:GetMinMaxValues() return self.low or 0,self.high or 0 end
    function f:SetValue(v)
        self.value=v
        if self.scripts.OnValueChanged then self.scripts.OnValueChanged(self,v) end
    end
    function f:GetValue() return self.value or 0 end
    return f
end

CreateFrame = Frame
getglobal = function() return nil end
SSCUI = {
    ScrollOffset = function(scroll) return scroll.offset or 0 end,
    ScrollMax = function(scroll, child)
        return math.max(0,(child.height or 0)-(scroll.height or 0))
    end,
}

dofile("SoftSpoken/Compendium/UI/InteriorSkin.lua")
dofile("SoftSpoken/Compendium/UI/NativeScrollbar.lua")

local inset=Frame("Frame","Inset")
SSCCompendiumInteriorSkin.ApplyList(inset)
local initialBounds=inset.boundReads
for i=1,60 do inset.scripts.OnUpdate(inset,1/60) end
local insetPolls=inset.boundReads-initialBounds
assert(insetPolls>=7 and insetPolls<=10,
    "inset bounds must be checked about 8 times/s, got "..insetPolls)
local oldBounds=inset.boundReads
inset.width=330
inset.scripts.OnSizeChanged(inset)
assert(inset.boundReads>oldBounds,"inset resize event must reflow immediately")

local scroll=Frame("ScrollFrame","Scroll")
scroll.width=200
scroll.height=300
local child=Frame("Frame","ScrollChild")
child.height=1000
local list={inset=inset,scroll=scroll,child=child}
function list:ScrollTo(value)
    scroll.offset=value
    if self.sszNativeScrollChrome then self.sszNativeScrollChrome.sync() end
end
local native=assert(SSCNativeScrollbar.AttachList(list))
assert(native.slot.scripts.OnUpdate,"native scrollbar must have compatibility poll")
local initialWidthReads=scroll.widthReads
for i=1,60 do native.slot.scripts.OnUpdate(native.slot,1/60) end
local scrollPolls=scroll.widthReads-initialWidthReads
assert(scrollPolls>=9 and scrollPolls<=11,
    "scrollbar fallback must sync about 10 times/s, got "..scrollPolls)
local beforeResize=scroll.widthReads
native.slider.scripts.OnSizeChanged(native.slider)
assert(scroll.widthReads>beforeResize,"scrollbar resize must sync immediately")
native.slider:SetValue(80)
eq(scroll.offset,80,"slider value must still update the scroll model immediately")
print(string.format(
    "PASS: simulated 60fps fallback budget: inset %d checks, scrollbar %d syncs; immediate events intact",
    insetPolls,scrollPolls))
