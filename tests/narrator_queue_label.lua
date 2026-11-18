-- Run from repository root: lua5.1 tests/narrator_queue_label.lua
-- Exercise the real shared narrator's row rendering with simulated Vanilla 1.12 UI.
-- Writings uses an alternate queued title, while Stories/Places keep their labels.

local function eq(got, want, label)
    assert(got == want, (label or "value") .. ": expected " ..
        tostring(want) .. ", got " .. tostring(got))
end

local function Widget(parent)
    local w = { parent=parent, scripts={}, shown=true, text="" }
    function w:SetScript(name, callback) self.scripts[name]=callback end
    function w:HookScript(name, callback) self.scripts[name]=callback end
    function w:SetHeight(height) self.height=height end
    function w:SetWidth(width) self.width=width end
    function w:SetSize(width,height) self.width=width;self.height=height end
    function w:GetWidth() return self.width or #self.text * 8 end
    function w:GetRight() return 440 end
    function w:GetLeft() return 0 end
    function w:SetID(id) self.id=id end
    function w:GetID() return self.id end
    function w:SetPoint() end
    function w:ClearAllPoints() end
    function w:SetAlpha(alpha) self.alpha=alpha end
    function w:EnableMouse() end
    function w:Show() self.shown=true end
    function w:Hide() self.shown=false end
    function w:GetParent() return self.parent end
    function w:SetWordWrap() end
    function w:SetText(text) self.text=text end
    function w:GetText() return self.text end
    function w:SetShadowColor() end
    function w:SetTextColor(r,g,b) self.color={r,g,b} end
    function w:SetTexture() end
    function w:SetDesaturated() return true end
    function w:SetVertexColor() end
    function w:CreateTexture() return Widget(self) end
    function w:CreateFontString() return Widget(self) end
    return w
end

local active
local queue = {
    GetCurrentSound=function() return active end,
    CanBePaused=function() return true end,
    GetClipState=function(self,clip) return clip==active and "playing" or "queued" end,
    GetHeldReason=function() return nil end,
}
local function CreateFont()
    return setmetatable({}, {__index=function() return function() end end})
end

SpokenEnv = setmetatable({
    Addon = {Profile=function() return {} end},
    Version = {IsLegacyVanilla=true},
    SoundQueue = queue,
    Bullets = {book={texture="BOOK",size=16}},
    RemoveColor = {1,0,0},
    CreateFont = CreateFont,
    CreateFrame = function(kind, name, parent) return Widget(parent) end,
    GameFontNormal = {GetFont=function() return "Fonts\\FRIZQT__.TTF" end},
}, {__index=_G})
dofile("SoftSpoken/UI/NarratorWindow.lua")
local player = SpokenEnv.PlayerFrame
local container = Widget()
container.buttons = {}
container.name = Widget(container)
player.frame = {container=container}

local row=player:CreateRow(1)
local writings={
    key="b:101",
    present={
        header="Rise of the Blood Elves",
        label="Book " .. string.char(194,183) .. " Discovered in Darnassus",
        queueLabel="Rise of the Blood Elves",
        bullet="book",
    }
}
active=writings
row:Configure(writings)
eq(row.textWidget:GetText(),writings.present.label,
    "active Writings row shows context in gold")
eq(row.textWidget.color[1],245/255,"active row retains original gold tint")

active={key="q:12"}
row:Configure(writings)
eq(row.textWidget:GetText(),writings.present.queueLabel,
    "queued Writings row shows title, not generic Book")

-- No new field is needed for Stories/Places. Their active and queued labels
-- are unchanged, even if the same row widget is reused between modules.
local stories={key="q:12",present={header="Moon Priestess Amara",
    label="The Road to Darnassus"}}
active=stories
row:Configure(stories)
eq(row.textWidget:GetText(),"The Road to Darnassus","active Stories label")
active=writings
row:Configure(stories)
eq(row.textWidget:GetText(),"The Road to Darnassus","queued Stories label")

local places={key="z:100",present={header="Teldrassil",label="Dolanaar"}}
active=places
row:Configure(places)
eq(row.textWidget:GetText(),"Dolanaar","active Places label")
active=writings
row:Configure(places)
eq(row.textWidget:GetText(),"Dolanaar","queued Places label")
eq(row.textWidget.color[1],123/255,"queued row retains standard muted tint")
print("PASS: shared narrator uses Writings queue titles without changing Stories/Places")
