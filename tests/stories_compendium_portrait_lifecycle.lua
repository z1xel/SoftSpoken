-- Run from repository root: lua5.1 tests/stories_compendium_portrait_lifecycle.lua
-- Exercise the REAL Stories quest page with a minimal Vanilla-style frame mock.
-- Cover reused holders, late ClassicAPI completions, stage visibility and reopen.
local function eq(actual,expected,label)
    assert(actual==expected,(label or "value")..": expected "..tostring(expected)..
        ", got "..tostring(actual))
end
local function Frame(kind,parent)
    local f={kind=kind or "Frame",parent=parent,shown=true,scripts={},height=400,width=400}
    local methods={}
    function methods:SetScript(name,fn) self.scripts[name]=fn end
    function methods:GetScript(name) return self.scripts[name] end
    function methods:CreateTexture() return Frame("Texture",self) end
    function methods:CreateFontString() return Frame("FontString",self) end
    function methods:SetTexture(value) self.texture=value end
    function methods:SetPoint(...) self.point={...} end
    function methods:SetTexCoord(...) self.texCoord={...} end
    function methods:SetText(text) self.text=text end
    function methods:SetWidth(v) self.width=v end
    function methods:SetHeight(v) self.height=v end
    function methods:GetWidth() return self.width end
    function methods:GetHeight() return self.height end
    function methods:GetStringHeight() return 20 end
    function methods:GetFont() return nil end
    function methods:IsShown()
        local parent=rawget(self,"parent")
        return self.shown and (not parent or parent:IsShown())
    end
    function methods:IsVisible() return self:IsShown() end
    function methods:Show()
        local was=self:IsShown()
        self.shown=true
        if not was and self:IsShown() and self.scripts.OnShow then self.scripts.OnShow(self) end
    end
    function methods:Hide()
        local was=self:IsShown()
        self.shown=false
        if was and self.scripts.OnHide then self.scripts.OnHide(self) end
    end
    setmetatable(f,{__index=function(_,key)
        if methods[key] then return methods[key] end
        -- Missing data fields must read nil, not a synthesized method.
        local prefix=string.sub(key,1,3)
        if prefix=="Set" or prefix=="Get" or prefix=="Cle" or
           prefix=="Ena" or prefix=="Dis" then return function() end end
        return nil
    end})
    return f
end
CreateFrame=function(kind,name,parent) return Frame(kind,parent) end
UnitName=function(unit) return unit=="player" and "Player" or nil end
UnitClass=function() return "Mage" end
UnitRace=function() return "Human" end
UnitSex=function() return 2 end
QuestFont=Frame("FontString")
QuestTitleFont=Frame("FontString")
SSCUI={ScrollMax=function() return 0 end,ScrollOffset=function() return 0 end}
-- Real TextView helpers and optional per-page callbacks are loaded below.
dofile("SoftSpoken/Compendium/UI/TextView.lua")
eq(SSCTextView.MeasureTextHeight({GetHeight=function() return 37 end}),37,
    "1.12 FontString uses GetHeight fallback")
eq(SSCTextView.MeasureTextHeight({GetStringHeight=function() return 21 end,
    GetHeight=function() return 37 end}),21,"newer client height API")
eq(SSCTextView.MeasureTextHeight(nil),0,"nil FontString")

-- The shared text view uses page-specific hooks without replacing its methods.
local sharedView=setmetatable({
    scroll=Frame("ScrollFrame"),child=Frame("Frame"),body=Frame("FontString"),
}, {__index=SSCTextView.View})
local resized
sharedView.onReflowContent=function(_,reset,previous,width)
    resized={reset,previous,width}
    return true
end
sharedView.scroll:SetWidth(310)
sharedView:Reflow(false)
eq(resized[1],false,"shared callback reset")
eq(resized[2],0,"shared callback previous scroll")
eq(resized[3],310,"shared callback width")
local typographyCalls=0
sharedView.onTypographyChanged=function() typographyCalls=typographyCalls+1 end
sharedView:ApplyTypography()
eq(typographyCalls,1,"shared typography callback")
SSCPlayButton={Create=function(parent) return Frame("Button",parent) end}
SSCQuestFactionCrest={Resolve=function() return "crest.tga","Faction crest" end}
local seen={ [101]=true,[102]=true,[103]=true }
local completed={ [101]=true,[102]=true }
SSCQuestState={
    IsSeen=function(self,id) return seen[id] or false end,
    IsCompleted=function(self,id) return completed[id] or false end,
    Setting=function() return false end,
}
SSCQuestCatalog={Title=function(self,id) return "Quest "..id end}
local speakers={
    [101]={accept=1001,progress=1002,complete=1002},
    [102]={accept=2001,progress=2002,complete=2002},
    [103]={accept=3001,progress=3002,complete=3002},
}
VoiceOver={
    Enums={GUID={
        Creature="Creature",GameObject="GameObject",
        IsCreature=function(self,kind) return kind==self.Creature end,
    }},
    SpeakerResolver={
        ForQuest=function(self,id,stage)
            local speaker=speakers[id] and speakers[id][stage]
            return speaker and "Creature",speaker
        end,
        Name=function(self,kind,id,title)
            return id and ("NPC "..id) or title
        end,
    },
    DataModules={PrepareSound=function() return nil end},
    Player={Queued=function() return {} end},
}
SpokenQuestsText={
    [101]={accept="Accept A",progress="Progress A",complete="Finish A"},
    [102]={accept="Accept B",progress="Progress B",complete="Finish B"},
    [103]={accept="Accept C",progress="Progress C",complete="Finish C"},
}
local known, requests, listeners, nativePaints = {}, {}, {}, {}
Spoken={
    GetCreatureDisplayID=function(self,id) return known[id] end,
    RequestCreatureAppearance=function(self,id)
        requests[id]=(requests[id] or 0)+1
        return true
    end,
    SubscribeCreatureAppearance=function(self,fn)
        listeners[fn]=true
        return true
    end,
    UnsubscribeCreatureAppearance=function(self,fn) listeners[fn]=nil end,
}
local function ListenerCount()
    local n=0
    for _ in pairs(listeners) do n=n+1 end
    return n
end
local function Load(id,displayID,success)
    if displayID then known[id]=displayID end
    for fn in pairs(listeners) do fn(id,displayID,success) end
end
SetPortraitTextureFromCreatureDisplayID=function(texture,displayID)
    nativePaints[#nativePaints+1]={texture=texture,displayID=displayID}
    texture:SetTexture("portrait:"..displayID)
end
dofile("SoftSpoken_Stories/Compendium/QuestPage_112.lua")
local baseTypography=function() end
local baseReflow=function() end
local view={
    scroll=Frame("Frame"), slider=Frame("Slider"),
    lastWidth=350,range=0,
    ApplyTypography=baseTypography,
    Reflow=baseReflow,
    ScrollTo=function(self,offset) self.lastScrollValue=offset end,
}
local page={frame=Frame("Frame"),title=Frame("FontString")}
view.child=Frame("Frame",page.frame)
view.body=Frame("Frame",page.frame)
page.body=view
local details=SSCQuestPage.Create(page)
eq(view.ApplyTypography,baseTypography,"Stories preserves shared typography method")
eq(view.Reflow,baseReflow,"Stories preserves shared reflow method")
eq(type(view.onReflowContent),"function","page-local reflow callback")
eq(type(view.onTypographyChanged),"function","page-local typography callback")
eq(view.onReflowContent(view,false,19,310),false,
    "landing page still uses normal reader layout")
eq(ListenerCount(),0,"no subscription before selection")
local function face(stage) return details.parts[stage].face end
-- Every quest moment draws a single overlay, regardless of portrait updates.
local RING = [[Interface\AddOns\SoftSpoken\Compendium\Textures\Art\PortraitRing]]
for _,stage in ipairs({"accept","progress","complete"}) do
    local f=face(stage)
    eq(f.ring.texture,RING,stage.." gold portrait ring")
    eq(f.ring.width,68,stage.." ring width")
    eq(f.ring.height,68,stage.." ring height")
    eq(f.ring.texCoord[2],77/128,stage.." ring original-pixel UV")
    eq(f.ring.point[1],"CENTER",stage.." centered ring anchor")
    eq(f.ring.point[2],f,stage.." ring anchor target")
    eq(f.ring.point[3],"CENTER",stage.." centered target anchor")
    eq(f.ring.point[4],0,stage.." ring x offset")
    eq(f.ring.point[5],0,stage.." ring y offset")
    -- All three dialogue moments reuse their narration-player quest bullets.
    local expectedBadges = {
        accept = [[Interface\AddOns\SoftSpoken_Stories\Textures\SoundQueueBulletAccept]],
        progress = [[Interface\AddOns\SoftSpoken_Stories\Textures\SoundQueueBulletProgress]],
        complete = [[Interface\AddOns\SoftSpoken_Stories\Textures\SoundQueueBulletComplete]],
    }
    eq(f.badge.texture,expectedBadges[stage],stage.." quest bullet")
    eq(f.badge.width,14,stage.." badge width")
    eq(f.badge.height,14,stage.." badge height")
    eq(f.badge.point[1],"CENTER",stage.." badge anchor")
    eq(f.badge.point[2],f.ring,stage.." badge is anchored to the ring")
    eq(f.badge.point[3],"BOTTOMRIGHT",stage.." badge socket")
    eq(f.badge.point[4],-14,stage.." badge x offset")
    eq(f.badge.point[5],14,stage.." badge y offset")
end
local function assertPortrait(stage,creatureID,displayID)
    local f=face(stage)
    eq(f.creatureID,creatureID,stage.." creature")
    eq(f.icon.texture,"portrait:"..displayID,stage.." texture")
end
details:Show(101)
eq(view.onReflowContent(view,false,19,310),true,"active quest uses custom layout")
eq(details.parts.accept:GetWidth(),310,"quest section uses callback width")
eq(view.lastScrollValue,19,"quest reflow preserves scroll position")
eq(view.onReflowContent(view,true,33,310),true,"reset reflow handled")
eq(view.lastScrollValue,0,"new quest resets scroll")
local acceptText=details.parts.accept.content
acceptText.GetStringHeight=false -- WoW 1.12 intentionally lacks this method.
acceptText.GetHeight=function() return 24 end
details:Layout(false)
eq(details.parts.accept:GetHeight(),147,"Vanilla fallback measures live dialogue height")
acceptText.GetStringHeight=nil;acceptText.GetHeight=nil
eq(ListenerCount(),1,"subscribes on active page")
eq(face("accept").pendingCreatureID,1001,"accept pending")
eq(face("progress").pendingCreatureID,1002,"progress pending")
eq(face("complete").pendingCreatureID,1002,"complete pending")
eq(face("accept").icon.texture,"crest.tga","fallback until load")
eq(face("progress").icon.texture,"crest.tga","progress fallback")

Load(1001,5101,true)
assertPortrait("accept",1001,5101)
eq(face("progress").icon.texture,"crest.tga","unrelated stage cannot repaint")
Load(1002,5102,true)
assertPortrait("progress",1002,5102)
assertPortrait("complete",1002,5102)
eq(face("progress").icon==face("complete").icon,false,"independent Texture regions")
eq(face("accept").affiliationLabel,"NPC 1001","speaker tooltip label")

-- Reusing holders for another quest must clear both native binding and text.
details:Show(102)
eq(face("accept").icon.texture,"crest.tga","new quest wipes old portrait")
eq(face("accept").binding.questID,102,"new quest identity")
eq(face("accept").pendingCreatureID,2001,"new giver pending")
Load(1001,5101,true)
Load(1002,5102,true)
eq(face("accept").icon.texture,"crest.tga","old quest response ignored")
eq(face("progress").icon.texture,"crest.tga","old ender response ignored")
Load(2002,5202,true)
assertPortrait("progress",2002,5202)
assertPortrait("complete",2002,5202)
Load(2001,nil,false)
eq(face("accept").icon.texture,"crest.tga","failure retains faction crest")
eq(face("accept").pendingCreatureID,nil,"failure clears pending state")
local prevReq=requests[2001]
-- A rejected shared request must not leave a permanently pending holder.
local previousRequest=Spoken.RequestCreatureAppearance
Spoken.RequestCreatureAppearance=function() return false end
details:Show(102)
eq(face("accept").pendingCreatureID,nil,"rejected request is not left pending")
Spoken.RequestCreatureAppearance=previousRequest
details:Show(102)
eq(requests[2001],prevReq+1,"refresh may retry failed creature")
eq(face("progress").icon.texture,"portrait:5202","cached display paints immediately")

-- Parent tab/window hides unsubscribe; a late result is observed on reopening
-- through the core's cached display, with no stale callback to a hidden page.
page.frame:Hide()
eq(ListenerCount(),0,"unsubscribed on hide")
eq(face("accept").icon.texture,"crest.tga","hide detaches native texture")
eq(face("progress").binding,nil,"hide invalidates stage binding")
local before=#nativePaints
Load(2001,5201,true)
eq(#nativePaints,before,"hidden page never paints native textures")
page.frame:Show()
eq(ListenerCount(),1,"resubscribed on show")
assertPortrait("accept",2001,5201)
eq(requests[2001],prevReq+1,"reopened cached creature needs no new request")

-- Landing page and locked quest must clear bindings and release subscription.
details:Show(nil)
eq(ListenerCount(),0,"landing page unsubscribed")
eq(face("accept").binding,nil,"landing page clears old binding")
eq(face("accept").pendingCreatureID,nil,"landing page clears pending")
details:Show(999)
eq(ListenerCount(),0,"locked quest cannot subscribe")
eq(details.active,false,"locked quest not activated")

-- Unfinished quest's Completion stays hidden; it must never fetch its ender.
details:Show(103)
eq(details.parts.complete:IsShown(),false,"completion not unlocked")
eq(face("complete").binding,nil,"hidden completion unbound")
eq(requests[3002],1,"progress alone requests ender")
eq(ListenerCount(),1,"selection subscribes once")
local generation=details.generation
details:Show(101)
assertPortrait("accept",1001,5101)
eq(details.generation>generation,true,"page selection invalidates older generation")
Load(3001,5301,true)
eq(face("accept").creatureID,1001,"stale third quest ignored")
local beforeRequests=requests[1001]
SoftSpokenExperimentalStaticPortraits=false
details:Show(101)
eq(face("accept").icon.texture,"crest.tga","disabled native renderer fallback")
eq(requests[1001],beforeRequests,"disabled portraits do not request")
SoftSpokenExperimentalStaticPortraits=nil
SetPortraitTextureFromCreatureDisplayID=nil
details:Show(101)
eq(face("accept").icon.texture,"crest.tga","missing native renderer fallback")
eq(requests[1001],beforeRequests,"missing native renderer does not query")

-- The quarter-second ticker remains solely for audio buttons.
local source=assert(io.open("SoftSpoken_Stories/Compendium/QuestPage_112.lua","r")):read("*a")
assert(not string.find(source,"RefreshPendingPortraits",1,true),"no portrait polling")
assert(not string.find(source,"pendingChecks",1,true),"no retry ticker")
eq(type(details.events.scripts.OnUpdate),"function","buttons still refresh")
print("PASS: Compendium page portrait subscriptions, stale guards, visibility and fallback")
