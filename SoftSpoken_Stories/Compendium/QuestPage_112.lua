-- Quest Compendium detail pages for the shared 1.12 parchment. Upstream
-- Spoken Quests 3.4.0 supplies the text and the quest/speaker/voice rules.
-- NO narration engine or global Compendium layout changes are made here.
SSCQuestPage = SSCQuestPage or {}
local P=SSCQuestPage
local S=SSCQuestState
local M=SSCQuestCatalog
local EVENTS={accept=1,progress=2,complete=3}
local MOMENTS={"accept","progress","complete"}
local NAMES={accept="Description",progress="Progress",complete="Completion"}
-- Use the same parchment ink as the shared Places reader.
local COLOR={.25,.16,.08}
local ALT={.53,.24,.10}
local FALLBACK_ICON="Interface\\Icons\\INV_Misc_Book_11"
local function Number(id)
    id=tonumber(id)
    if id and id>0 and id==math.floor(id) then return id end
end
local function API(f,...)
    if type(f)~="function" then return nil end
    local ok,one,two=pcall(f,...)
    if ok then return one,two end
end
local function Data()
    return VoiceOver and VoiceOver.DataModules
end
local function Database(id)
    return _G.SpokenQuestsText and _G.SpokenQuestsText[id] or nil
end
local function Fill(text)
    if type(text)~="string" then return nil end
    local name=UnitName and UnitName("player") or ""
    local class=UnitClass and UnitClass("player") or ""
    local race=UnitRace and UnitRace("player") or ""
    local female=UnitSex and UnitSex("player")==3
    -- Spoken's original placeholder expansion, safe for the 1.12 Lua client.
    text=string.gsub(text,"%$[Gg]([^:;]*):([^;]*);",function(male,her)
        return (female and her or male):gsub("^%s+",""):gsub("%s+$","")
    end)
    text=string.gsub(text,"%$[Bb]","\n")
    text=string.gsub(text,"%$[Nn]",function() return name end)
    text=string.gsub(text,"%$[Cc]",function() return class end)
    text=string.gsub(text,"%$[Rr]",function() return race end)
    return text
end
local function Stored()
    if type(SSCQuestJournal)~="table" then return nil end
    SSCQuestJournal.dialogue=SSCQuestJournal.dialogue or {}
    return SSCQuestJournal.dialogue
end
local function SavedText(id,stage)
    local db=Stored()
    local r=db and db[id]
    return r and r[stage]
end
local function Speaker(id,stage)
    local v=VoiceOver
    local d=Data()
    local e=v and v.Enums and v.Enums.GUID
    if not d or not e then return end
    local quest=M:Entry(id)
    -- Original Spoken: progress and reward belong to the ENDING speaker.
    if stage~="accept" and quest then
        if Number(quest.ender) then return e.Creature,quest.ender end
        if Number(quest.enderObject) then return e.GameObject,quest.enderObject end
    end
    if type(d.GetQuestLogQuestGiverTypeAndID)=="function" then
        return API(d.GetQuestLogQuestGiverTypeAndID,d,id)
    end
end
local function SpeakerLabel(id,stage)
    local kind,npc=Speaker(id,stage)
    local d=Data()
    local name=kind and npc and d and API(d.GetObjectName,d,kind,npc)
    return name or M:Title(id),kind,npc
end
local function SoundData(id,stage)
    local v=VoiceOver
    local title=M:Title(id,true)
    local name,kind,npc=SpeakerLabel(id,stage)
    local e=v and v.Enums and v.Enums.GUID
    local guid
    if npc and kind and e and e.CanHaveID and e:CanHaveID(kind) then
        guid=v.Utils and API(v.Utils.MakeGUID,v.Utils,kind,npc)
    end
    return {event=EVENTS[stage],questID=id,title=title,name=name,
        unitGUID=guid,unitIsObjectOrItem=npc and kind and e and not e:IsCreature(kind) or false,
        text=P:Text(id,stage),origin="Azeroth's Compendium"}
end
local function HasVoice(id,stage)
    local d=Data()
    if not d or not d.PrepareSound then return false end
    local request=SoundData(id,stage)
    return API(d.PrepareSound,d,request) and true or false
end
local function Clips(id,stage)
    local v=VoiceOver
    local out={}
    if not v or not v.Player or not v.Player.Queued then return out end
    local entries=v.Player:Queued()
    for _,clip in ipairs(entries or {}) do
        if clip.questID==id and (clip.event==1 or clip.event==2 or clip.event==3)
           and (not stage or clip.event==EVENTS[stage]) then
            table.insert(out,clip)
        end
    end
    return out
end
local function Play(id,stage)
    local v=VoiceOver
    if not (v and v.Player and v.Player.PlayNow) then return end
    local same=Clips(id,stage)
    local all=Clips(id)
    for _,clip in ipairs(all) do v.Player:Remove(clip) end
    if table.getn(same)>0 then return end -- upstream's play/stop behavior
    v.Player:PlayNow(SoundData(id,stage))
end
-- Text for an encountered Turtle quest can come from the live quest window.
-- Otherwise use the original Spoken corpus without modifying its source file.
function P:Text(id,stage)
    local captured=SavedText(id,stage)
    if type(captured)=="string" and captured~="" then return Fill(captured) end
    local english=Database(id)
    return english and Fill(english[stage]) or nil
end
-- Quest detail sections live inside SSCTextView's existing parchment reader.
-- Mirror the actual shared reader font rather than maintaining a different
-- fixed-size font for Quests.  Global Compendium text size then affects all
-- three modules consistently.
local function Font(parent,template)
    local fs=parent:CreateFontString(nil,"ARTWORK",template)
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    fs:SetTextColor(COLOR[1],COLOR[2],COLOR[3],1)
    if fs.SetShadowColor then fs:SetShadowColor(0,0,0,0) end
    if fs.SetShadowOffset then fs:SetShadowOffset(0,0) end
    if fs.SetWordWrap then fs:SetWordWrap(true) end
    return fs
end
local function MatchFont(font,reference,sizeAdjust,fallback)
    local path,size
    if reference and reference.GetFont then path,size=reference:GetFont() end
    if not path and fallback and fallback.GetFont then
        path,size=fallback:GetFont()
    end
    if path and font.SetFont then
        font:SetFont(path,math.max(10,(tonumber(size) or 15)+(sizeAdjust or 0)),"")
    end
    if font.SetShadowColor then font:SetShadowColor(0,0,0,0) end
    if font.SetShadowOffset then font:SetShadowOffset(0,0) end
end
-- Use normal 2D artwork inside the quest scroll child. Native models are
-- intentionally not created by this page: they were rendered outside their
-- parent ScrollFrame on Turtle WoW 1.12, and caused a crash on UI reload.
-- The same player-faction crest is also the Stories player portrait fallback.
-- One resolver owns these textures and their Turtle 1.12 race fallback.
local FactionCrest=SSCQuestFactionCrest
local function Portrait(parent)
    local holder=CreateFrame("Frame",nil,parent)
    holder:SetWidth(62);holder:SetHeight(62)
    -- The crest itself should read as a shield on parchment, not as an
    -- item icon inside a dark square. Keep it a normal scroll-child texture.
    local icon=holder:CreateTexture(nil,"ARTWORK")
    icon:SetAllPoints(holder)
    holder.icon=icon
    holder.creatureID=nil
    holder:EnableMouse(true)
    holder:SetScript("OnEnter",function()
        local h=this or holder
        local note=h.affiliationLabel or "Affiliation unknown"
        if GameTooltip and GameTooltip.SetOwner then
            GameTooltip:SetOwner(h,"ANCHOR_RIGHT")
            GameTooltip:SetText(note)
            GameTooltip:Show()
        end
    end)
    holder:SetScript("OnLeave",function()
        if GameTooltip then GameTooltip:Hide() end
    end)
    return holder
end
local function PaintCrest(holder)
    -- Repaint on every page view. The portrait and this page now share the
    -- exact same faction choice and full transparent 256x256 texture.
    local texture,label=FactionCrest.Resolve()
    holder.icon:SetTexCoord(0,1,0,1)
    holder.icon:SetTexture(texture)
    holder.affiliationLabel=label
end
local function NewPart(parent,stage)
    local f=CreateFrame("Frame",nil,parent)
    f.stage=stage
    f:SetHeight(100)
    local title=Font(f,"GameFontNormalLarge")
    title:SetText(NAMES[stage]); title:SetTextColor(ALT[1],ALT[2],ALT[3],1)
    title:SetPoint("TOPLEFT",f,"TOPLEFT",0,-2)
    f.title=title
    local face=Portrait(f)
    face:SetPoint("TOPLEFT",f,"TOPLEFT",1,-30)
    f.face=face
    local speaker=Font(f,"GameFontNormal")
    speaker:SetPoint("TOPLEFT",face,"TOPRIGHT",10,-9)
    speaker:SetPoint("TOPRIGHT",f,"TOPRIGHT",-38,-39)
    speaker:SetHeight(35)
    f.speaker=speaker
    face.speaker=speaker
    local btn=SSCPlayButton.Create(f)
    btn:ClearAllPoints()
    btn:SetPoint("TOPRIGHT",f,"TOPRIGHT",-4,-34)
    btn.stage=stage
    btn:SetScript("OnClick",function(self)
        local b=self or this
        if b and b.questID then Play(b.questID,b.stage) end
    end)
    f.button=btn
    local content=Font(f,"GameFontHighlight")
    if content.SetSpacing then content:SetSpacing(2) end
    content:SetPoint("TOPLEFT",f,"TOPLEFT",0,-106)
    f.content=content
    local divider=f:CreateTexture(nil,"ARTWORK")
    divider:SetTexture(.45,.28,.12,.24)
    divider:SetHeight(1)
    divider:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,1)
    divider:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-4,1)
    return f
end
-- The same client-side QuestFont and dynamic font size that the Places and
-- Books reader uses.  Don't replace those values with independently tuned
-- sizes (doing so makes Quest paragraphs look larger/heavier).
function P:ApplyTypography()
    local reference=self.view and self.view.body
    local heading=self.page and self.page.title
    for _,stage in ipairs(MOMENTS) do
        local part=self.parts[stage]
        MatchFont(part.content,reference,0,QuestFont)
        if part.content.SetSpacing then part.content:SetSpacing(2) end
        MatchFont(part.speaker,reference,-2,QuestFont)
        part.speaker:SetTextColor(.38,.23,.12,1)
        MatchFont(part.title,heading,-9,QuestTitleFont)
        part.title:SetTextColor(ALT[1],ALT[2],ALT[3],1)
    end
end
function P.Create(page)
    local view=page.body
    local self={page=page,view=view,parts={},id=nil,active=false,source=""}
    setmetatable(self,{__index=P})
    for _,stage in ipairs(MOMENTS) do self.parts[stage]=NewPart(view.child,stage) end

    local originalApplyTypography=view.ApplyTypography
    function view:ApplyTypography()
        originalApplyTypography(self)
        if P.current and P.current.view==self then
            P.current:ApplyTypography()
        end
    end
    local originalReflow=view.Reflow
    function view:Reflow(reset)
        originalReflow(self,reset)
        if P.current and P.current.view==self and P.current.active then
            P.current:Layout(reset)
        end
    end
    P.current=self
    self:ApplyTypography()
    -- Keep only the lightweight playback-button refresh. No model frames,
    -- model-load events, scroll polling, lighting, or camera state remain.
    self.events=CreateFrame("Frame",nil,page.frame)
    self.elapsed=0
    self.events:SetScript("OnUpdate",function(_,elapsed)
        if not self.active or not self.page.frame:IsShown() then return end
        self.elapsed=self.elapsed+(tonumber(elapsed) or tonumber(_G.arg1) or 0)
        if self.elapsed>=.25 then
            self.elapsed=0
            self:RefreshButtons()
        end
    end)
    for _,f in pairs(self.parts) do f:Hide() end
    return self
end
function P:RefreshButtons()
    for _,stage in ipairs(MOMENTS) do
        local part=self.parts[stage]
        if part:IsShown() then
            local active=self.id and Clips(self.id,stage)
            local btn=part.button
            local state=active and table.getn(active)>0 and "stop" or "play"
            if btn.state~=state then btn:SetState(state) end
        end
    end
end
function P:Layout(reset)
    if not self.active then return end
    local view=self.view
    local width=(view.scroll:GetWidth() or 0)-9
    if width<155 then width=view.lastWidth or 330 end
    local y=0
    for _,stage in ipairs(MOMENTS) do
        local part=self.parts[stage]
        if part:IsShown() then
            part:SetWidth(width)
            part:ClearAllPoints()
            part:SetPoint("TOPLEFT",view.child,"TOPLEFT",2,-y)
            part.content:SetWidth(math.max(110,width-4))
            part.title:SetWidth(math.max(110,width-34))
            local th=part.content:GetStringHeight() or 0
            if th<16 then th=22 end
            local h=math.max(129,106+th+17)
            part:SetHeight(h)
            y=y+h+10
        end
    end
    view.child:SetHeight(math.max(y+8,view.scroll:GetHeight() or 1))
    local maximum=SSCUI.ScrollMax(view.scroll,view.child)
    view.range=maximum
    view.slider:SetMinMaxValues(0,maximum)
    if maximum>0 then view.slider:Show() else view.slider:Hide() end
    view:ScrollTo(reset and 0 or SSCUI.ScrollOffset(view.scroll))
end
function P:Show(id,entry)
    if not id or not SSCQuestState:IsSeen(id) and not SSCQuestState:Setting("unlock") then
        self.active=false;self.id=nil
        for _,part in pairs(self.parts) do part:Hide() end
        self.view.body:Show()
        self.view:Reflow(false)
        return
    end
    local changed=self.id~=id
    self.id=id
    self.active=true
    self.view.body:Hide()
    local completed=S:IsCompleted(id)
    local unlocked=S:Setting("unlock")
    for _,stage in ipairs(MOMENTS) do
        local part=self.parts[stage]
        local allowed=stage~="complete" or completed or unlocked
        local text=allowed and self:Text(id,stage) or nil
        local voiced=allowed and HasVoice(id,stage)
        local visible=allowed and (stage~="progress" or text or voiced)
        if not visible then
            part:Hide()
        else
            part:Show()
            part.button.questID=id
            if voiced then
                part.button:Enable();part.button:Show()
            else
                part.button:Disable();part.button:Hide()
            end
            local speaker=SpeakerLabel(id,stage)
            part.speaker:SetText(speaker)
            PaintCrest(part.face)
            part.content:SetText(text or (voiced and "Audio available. Dialogue text not recorded." or "No dialogue text available."))
        end
    end
    self:Layout(changed)
    self:RefreshButtons()
end
-- Capture previously unseen Turtle dialogue from actual on-screen quest
-- windows; store per character. No automatic playback or quest status changes.
local capture=CreateFrame("Frame")
for _,eventName in ipairs({"QUEST_DETAIL","QUEST_PROGRESS","QUEST_COMPLETE"}) do
    pcall(capture.RegisterEvent,capture,eventName)
end
capture:SetScript("OnEvent",function(frame,eventName)
    eventName=type(eventName)=="string" and eventName or _G.event
    local stage=eventName=="QUEST_DETAIL" and "accept" or
        eventName=="QUEST_PROGRESS" and "progress" or
        eventName=="QUEST_COMPLETE" and "complete" or nil
    if not stage then return end
    local v=VoiceOver
    local id=Number((v and v.GetQuestID and API(v.GetQuestID)) or
        (_G.GetQuestID and API(_G.GetQuestID)))
    local title=_G.GetTitleText and API(_G.GetTitleText)
    local getText=stage=="accept" and _G.GetQuestText or
        stage=="progress" and _G.GetProgressText or _G.GetRewardText
    local text=getText and API(getText)
    if not id then
        local d=Data()
        if d and d.GetQuestID then
            local source=stage=="accept" and "accept" or stage=="progress" and "progress" or "complete"
            local npc=v and v.Utils and v.Utils.GetNPCName and API(v.Utils.GetNPCName,v.Utils)
            id=Number(API(d.GetQuestID,d,source,title or "",npc or "",text or ""))
        end
    end
    if not id or type(text)~="string" or text=="" then return end
    local db=Stored()
    db[id]=db[id] or {}
    db[id][stage]=text
    if S:IsSeen(id) and SSCQuestsTab and SSCQuestsTab.Refresh then
        local C=SSCCompendium
        if C and C.Active and C:Active()=="quests" then SSCQuestsTab:Refresh() end
    end
end)
