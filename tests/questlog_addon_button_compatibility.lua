-- Run from repository root: lua5.1 tests/questlog_addon_button_compatibility.lua
-- The ordinary quest log keeps its padded row; level-label addons get a left
-- gutter button and must not have their title rewritten by SoftSpoken.
local function eq(a,b,label)
    assert(a==b,(label or "value")..": expected "..tostring(b)..", got "..tostring(a))
end
string.trim=string.trim or function(s)
    return (string.gsub(string.gsub(s,"^%s+",""),"%s+$",""))
end
local loaded={}
IsAddOnLoaded=function(name) return loaded[name]==true end
local function Text(value)
    local t={value=value}
    function t:GetText() return self.value end
    function t:SetText(v) self.value=v end
    function t:GetStringWidth() return string.len(self.value or "")*8 end
    return t
end
QuestLogDummyText=Text("")
VoiceOver=setmetatable({AddonFolder="SoftSpoken_Stories",format=string.format},
    {__index=_G})
dofile("SoftSpoken_Stories/QuestOverlayUI.lua")
local overlay=VoiceOver.QuestOverlayUI
local function Check(title,offset,rewrites,which)
    local normal=Text(title)
    local button={}
    function button:ClearAllPoints() self.cleared=true end
    function button:SetPoint(_,_,_,x,y) self.x=x;self.y=y end
    local check={}
    function check:SetPoint(_,_,_,x,y) self.x=x;self.y=y end
    overlay:UpdateQuestTitle({},button,normal,check)
    eq(button.cleared,true,which.." clears prior position")
    eq(button.x,offset,which.." anchor")
    eq(button.y,0,which.." vertical")
    eq(normal.value==title,not rewrites,which.." title mutation")
    eq(QuestLogDummyText:GetText(),normal.value,which.." dummy text")
    eq(check.x,normal:GetStringWidth(),which.." completion mark")
end

-- The default Blizzard log retains upstream's 24px space prefix.
Check("Find Agmond",4,true,"plain log")
loaded.pfQuest=true
Check("[12] Find Agmond",-16,false,"pfQuest")
loaded.pfQuest=false; loaded["!Questie"]=true
Check("[12] Find Agmond",-16,false,"Vanilla !Questie")
loaded["!Questie"]=false; loaded.Questie=true
Check("[12] Find Agmond",-16,false,"Questie")
loaded.Questie=false
Check("A New Quest",4,true,"return to standard log")
IsAddOnLoaded=nil
Check("Fallback without IsAddOnLoaded",4,true,"missing addon API")
print("PASS: quest-log play-button positioning stays conditional on known quest addons")
