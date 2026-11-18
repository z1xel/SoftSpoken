-- Quest Compendium detail pages for the shared 1.12 parchment. Upstream
-- Spoken Quests 3.4.0 supplies the text and the quest/speaker/voice rules.
-- NO narration engine or global Compendium layout changes are made here.
SSCQuestPage = SSCQuestPage or {}
local QuestPage=SSCQuestPage
local QuestDialogue=VoiceOver.QuestDialogue
local QuestState=SSCQuestState
local QuestCatalog=SSCQuestCatalog
local EVENTS={accept=1,progress=2,complete=3}
local MOMENTS={"accept","progress","complete"}
local NAMES={accept="Description",progress="Progress",complete="Completion"}
-- Use the same parchment ink as the shared Places reader.
local COLOR={0,0,0}
local ALT={.53,.24,.10}
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
local MULTIPLE_LABEL="Multiple speakers possible"
local function SpeakerLabel(id,stage)
    local resolver=VoiceOver and VoiceOver.SpeakerResolver
    local candidates=resolver and resolver:MultipleSpeakers(id,stage)
    if candidates then return MULTIPLE_LABEL,nil,nil,candidates end
    local kind,npc
    if resolver then kind,npc=resolver:ForQuest(id,stage) end
    local title=QuestCatalog:Title(id)
    return resolver and resolver:Name(kind,npc,title) or title,kind,npc
end
local function SoundData(id,stage)
    local v=VoiceOver
    local title=QuestCatalog:Title(id,true)
    local name,kind,npc,candidates=SpeakerLabel(id,stage)
    -- The placeholder is display-only. With no live NPC, let the sound pack
    -- try its shared quest-stage recording instead of inventing a speaker.
    if candidates then name=title end
    local e=v and v.Enums and v.Enums.GUID
    local guid
    if npc and kind and e and e.CanHaveID and e:CanHaveID(kind) then
        guid=v.Utils and API(v.Utils.MakeGUID,v.Utils,kind,npc)
    end
    return {event=EVENTS[stage],questID=id,title=title,name=name,
        unitGUID=guid,unitIsObjectOrItem=npc and kind and e and not e:IsCreature(kind) or false,
        text=QuestDialogue:Text(id,stage),origin="Azeroth's Compendium"}
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
-- Compatibility for consumers of the original Compendium text entrypoint.
-- This is a delegate only; the implementation now lives in QuestDialogue.
function QuestPage:Text(id,stage)
    return VoiceOver.QuestDialogue:Text(id,stage)
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
local function MatchFont(font,reference,sizeAdjust,fallback,asQuestTitle,fontFile,sizeScale)
    local path,size
    if reference and reference.GetFont then path,size=reference:GetFont() end
    if not path and fallback and fallback.GetFont then
        path,size=fallback:GetFont()
    end
    if fontFile then path=fontFile end
    if path and font.SetFont then
        font:SetFont(path,math.max(10,(tonumber(size) or 15)+(sizeAdjust or 0))*(sizeScale or 1),"")
    end
    if asQuestTitle then
        -- WoW 1.12 QuestTitleFont: black Morpheus with warm gold (1,-1) shadow.
        font:SetTextColor(0,0,0,1)
        if font.SetShadowColor then font:SetShadowColor(.49,.35,.05,1) end
        if font.SetShadowOffset then font:SetShadowOffset(1,-1) end
    else
        if font.SetShadowColor then font:SetShadowColor(0,0,0,0) end
        if font.SetShadowOffset then font:SetShadowOffset(0,0) end
    end
end
-- Use normal 2D artwork inside the quest scroll child. Native models are
-- intentionally not created by this page: they were rendered outside their
-- parent ScrollFrame on Turtle WoW 1.12, and caused a crash on UI reload.
-- The same player-faction crest is also the Stories player portrait fallback.
-- One resolver owns these textures and their Turtle 1.12 race fallback.
local FactionCrest=SSCQuestFactionCrest
-- An item has no creature face. Use a native note icon until its item icon
-- becomes available; never show the player's faction crest for an item.
local ITEM_FALLBACK = "Interface\\Icons\\INV_Misc_Note_01"
local ITEM_ICON_CROP = { 0, 1, 0, 1 }
-- Generic GameObjects have no inventory icon; match upstream Spoken's notice.
local GAMEOBJECT_FALLBACK = "Interface\\Icons\\INV_Misc_Note_01"
-- Native Vanilla WoW icon displayed instead of choosing an arbitrary NPC.
local MULTIPLE_SPEAKERS_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

-- User-selected CharacterTab ring: 77x77 image pixels stored in a 128x128
-- power-of-two TGA for Vanilla 1.12. Its on-screen size is independent of
-- the 77x77 stored image: a 68-unit ring closely frames the 62-unit portrait.
-- Borrow upstream Spoken's layering: portrait underneath, ring above.
local PORTRAIT_RING = "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Art\\PortraitRing"
local PORTRAIT_MASK = "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Skin\\BookPortraitCircleMask"
-- Source: docs/artwork/compendium/PortraitRing-source.png (77x77 visible pixels).
-- Coordinates below are measured from the source's top-left PIXEL EDGE.
-- The main transparent opening is about 54 source px (47.7 UI units).
-- Its center is not exactly at the center of the full ring artwork.
-- The original 64x64 portrait mask keeps ~60/64 of the face visible; a
-- 54-unit image therefore puts ~50.6 units under the 47.7-unit opening,
-- retaining ~1.5 units of safe overlap beneath the rim on each side.
local RING_SOURCE_SIZE = 77
local RING_UI_SIZE = 68
local RING_SOURCE_CENTER = RING_SOURCE_SIZE / 2
local APERTURE_SOURCE_X, APERTURE_SOURCE_Y = 38.25, 36.5
local SOCKET_SOURCE_X, SOCKET_SOURCE_Y = 60, 58
local PORTRAIT_IMAGE_SIZE = 54
local function SourceUnits(v) return v * RING_UI_SIZE / RING_SOURCE_SIZE end
-- Use the same 14-unit quest bullets as the narration player.
local PORTRAIT_BADGES = {
    accept = "Interface\\AddOns\\SoftSpoken\\Textures\\SoundQueueBulletAccept",
    progress = "Interface\\AddOns\\SoftSpoken\\Textures\\SoundQueueBulletProgress",
    complete = "Interface\\AddOns\\SoftSpoken\\Textures\\SoundQueueBulletComplete",
}
-- Portraits are plain 2D Texture regions inside the scroll child: never
-- create Model/PlayerModel frames here (they break 1.12 scroll clipping).
local function Portrait(parent)
    local holder=CreateFrame("Frame",nil,parent)
    holder:SetWidth(62);holder:SetHeight(62)
    local icon=holder:CreateTexture(nil,"ARTWORK")
    -- Center the portrait on the artwork's actual opening, not the outer
    -- 77x77 image bounds. Keep the 62x62 holder/layout unchanged.
    icon:SetWidth(PORTRAIT_IMAGE_SIZE)
    icon:SetHeight(PORTRAIT_IMAGE_SIZE)
    icon:SetPoint("CENTER",holder,"CENTER",
        SourceUnits(APERTURE_SOURCE_X-RING_SOURCE_CENTER),
        SourceUnits(RING_SOURCE_CENTER-APERTURE_SOURCE_Y))
    -- ClassicAPI clips the 2D face/crest to a circle. The overlay is kept
    -- separate so ClassicAPI portrait repaints cannot replace the ring.
    if icon.SetMask then icon:SetMask(PORTRAIT_MASK) end
    holder.icon=icon
    local ring=holder:CreateTexture(nil,"OVERLAY")
    ring:SetTexture(PORTRAIT_RING)
    ring:SetWidth(RING_UI_SIZE);ring:SetHeight(RING_UI_SIZE)
    ring:SetTexCoord(0,RING_SOURCE_SIZE/128,0,RING_SOURCE_SIZE/128)
    -- Keep the ring centered on the 62x62 portrait.
    ring:SetPoint("CENTER",holder,"CENTER",0,0)
    holder.ring=ring
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
    -- Rebinding the same region to an ordinary texture detaches any previous
    -- native portrait. ClassicAPI owns its rendering jobs and display cache.
    local texture,label=FactionCrest.Resolve()
    holder.icon:SetTexCoord(0,1,0,1)
    holder.icon:SetTexture(texture)
    holder.affiliationLabel=label
    holder.creatureID=nil
    holder.pendingCreatureID=nil
    holder.pendingItemID=nil
    holder.binding=nil
end

-- Show a neutral question-mark portrait when more than one NPC could speak.
-- The tooltip retains every known starter/ender; no NPC is chosen for display.
local function PaintMultiple(holder,candidates)
    holder.icon:SetTexCoord(0,1,0,1)
    holder.icon:SetTexture(MULTIPLE_SPEAKERS_ICON)
    local resolver=VoiceOver and VoiceOver.SpeakerResolver
    local types=VoiceOver and VoiceOver.Enums and VoiceOver.Enums.GUID
    local creature=types and types.Creature
    local names={MULTIPLE_LABEL}
    for _,candidate in ipairs(candidates) do
        local id,kind=candidate,creature
        if type(candidate)=="table" then
            id,kind=candidate.id,candidate.kind
        end
        local fallback=(types and kind==types.GameObject and "Object " or "NPC ")..tostring(id)
        local name=resolver and resolver:Name(kind,id,fallback) or fallback
        table.insert(names,name.." ("..tostring(id)..")")
    end
    holder.affiliationLabel=table.concat(names,"\n")
end

local function ValidIcon(icon)
    return (type(icon)=="string" and icon~="") or
        (type(icon)=="number" and icon>0)
end

local function PaintItemIcon(holder,icon,speaker)
    holder.icon:SetTexCoord(unpack(ITEM_ICON_CROP))
    holder.icon:SetTexture(ValidIcon(icon) and icon or ITEM_FALLBACK)
    holder.affiliationLabel=speaker and speaker~="" and speaker or "Quest item"
end

-- ClassicAPI resolves the icon by item ID, even if the item isn't in the
-- player's bags. Its cache miss initiates a load; a bag icon is an optional
-- fallback for clients without this API (and while the data is still loading).
local function ResolveItemIcon(itemID,questID)
    local info=rawget(_G,"C_Item")
    local icon=info and API(info.GetItemIconByID,itemID)
    if ValidIcon(icon) then return icon end
    if Spoken and type(Spoken.QuestItemIcon)=="function" then
        icon=API(Spoken.QuestItemIcon,Spoken,questID)
        if ValidIcon(icon) then return icon end
    end
end

-- GameObjects are world models, not creatures. Preserve the existing ring
-- and badge while replacing the unrelated player faction crest.
local function PaintGameObject(holder,speaker)
    holder.icon:SetTexCoord(0,1,0,1)
    holder.icon:SetTexture(GAMEOBJECT_FALLBACK)
    holder.affiliationLabel=type(speaker)=="string" and speaker~="" and speaker or "Quest object"
end

local function CanDrawCreature(kind,npc)
    if type(rawget(_G,"SetPortraitTextureFromCreatureDisplayID"))~="function" then
        return nil
    end
    local e=VoiceOver and VoiceOver.Enums and VoiceOver.Enums.GUID
    if not (e and e.IsCreature and kind and e:IsCreature(kind)) then return nil end
    if not (Spoken and type(Spoken.GetCreatureDisplayID)=="function") then return nil end
    return Number(npc)
end

local function ApplyPortrait(holder,displayID)
    displayID=Number(displayID)
    if not displayID then return end
    local render=rawget(_G,"SetPortraitTextureFromCreatureDisplayID")
    if type(render)~="function" then return end
    -- The native function has no success return or completion callback. A
    -- successful Lua call only means the texture was submitted to ClassicAPI.
    local ok=pcall(render,holder.icon,displayID)
    if ok then
        holder.creatureID=holder.binding and holder.binding.creatureID or nil
        holder.affiliationLabel=holder.binding and holder.binding.speaker or "Creature portrait"
        holder.pendingCreatureID=nil
    end
end

-- Item portraits use the same masked 2D region, ring and quest-state badge
-- as creature portraits. No model or new texture asset is necessary.
function QuestPage:BindItemPortrait(part,questID,stage,itemID,speaker)
    local holder=part.face
    PaintItemIcon(holder,nil,speaker)
    itemID=Number(itemID)
    if not itemID then return end

    holder.binding={questID=questID,stage=stage,itemID=itemID,
        generation=self.generation,speaker=speaker}
    holder.pendingItemID=itemID
    local icon=ResolveItemIcon(itemID,questID)
    if ValidIcon(icon) then
        PaintItemIcon(holder,icon,speaker)
        holder.pendingItemID=nil
    end
end

function QuestPage:BindPortrait(part,questID,stage,kind,npc,speaker,candidates)
    local holder=part.face
    PaintCrest(holder)
    if candidates then
        PaintMultiple(holder,candidates)
        return
    end
    local enums=VoiceOver and VoiceOver.Enums and VoiceOver.Enums.GUID
    if enums and kind==enums.Item then
        self:BindItemPortrait(part,questID,stage,npc,speaker)
        return
    end
    if enums and kind==enums.GameObject then
        PaintGameObject(holder,speaker)
        return
    end
    npc=CanDrawCreature(kind,npc)
    if not npc then return end
    -- A reused holder must never accept an old page/stage/creature result.
    holder.binding={questID=questID,stage=stage,creatureID=npc,
        generation=self.generation,speaker=speaker}
    local displayID=Number(API(Spoken.GetCreatureDisplayID,Spoken,npc))
    if displayID then
        ApplyPortrait(holder,displayID)
    else
        holder.pendingCreatureID=npc
        local accepted=type(Spoken.RequestCreatureAppearance)=="function" and
            API(Spoken.RequestCreatureAppearance,Spoken,npc)
        if not accepted then holder.pendingCreatureID=nil end
    end
end

function QuestPage:OnCreatureAppearance(creatureID,displayID,success)
    if not self.active or not self.id or not self.page.frame:IsVisible() then return end
    creatureID=Number(creatureID)
    if not creatureID then return end
    for _,stage in ipairs(MOMENTS) do
        local part=self.parts[stage]
        local holder=part and part.face
        local bound=holder and holder.binding
        if part and part:IsShown() and bound and
           holder.pendingCreatureID==creatureID and
           bound.creatureID==creatureID and bound.questID==self.id and
           bound.stage==stage and bound.generation==self.generation then
            holder.pendingCreatureID=nil
            if success and Number(displayID) then ApplyPortrait(holder,displayID) end
        end
    end
end

-- Refresh only the specific currently-visible item that finished loading.
-- ClassicAPI reports implicit cache warms via GET_ITEM_INFO_RECEIVED and
-- explicit requests made by other addons via ITEM_DATA_LOAD_RESULT.
function QuestPage:OnItemInfoReceived(itemID,success)
    if success==false or success==0 or not self.active or not self.id or
       not self.page.frame:IsVisible() then return end
    itemID=Number(itemID)
    if not itemID then return end
    for _,stage in ipairs(MOMENTS) do
        local part=self.parts[stage]
        local holder=part and part.face
        local bound=holder and holder.binding
        if part and part:IsShown() and bound and
           holder.pendingItemID==itemID and bound.itemID==itemID and
           bound.questID==self.id and bound.stage==stage and
           bound.generation==self.generation then
            -- One-shot refresh: a failed/missing icon keeps the fallback.
            holder.pendingItemID=nil
            local icon=ResolveItemIcon(itemID,bound.questID)
            if ValidIcon(icon) then PaintItemIcon(holder,icon,bound.speaker) end
        end
    end
end

function QuestPage:SubscribePortraits()
    if self.portraitSubscribed or not self.active or
       not (Spoken and type(Spoken.SubscribeCreatureAppearance)=="function") then return end
    self.portraitSubscribed=API(Spoken.SubscribeCreatureAppearance,Spoken,self.portraitCallback)==true
end

function QuestPage:UnsubscribePortraits()
    if not self.portraitSubscribed then return end
    self.portraitSubscribed=false
    if Spoken and type(Spoken.UnsubscribeCreatureAppearance)=="function" then
        API(Spoken.UnsubscribeCreatureAppearance,Spoken,self.portraitCallback)
    end
end

-- Rebind on tab/window reopen: an NPC may have finished loading while the
-- page was hidden and its callback unsubscribed.
local function ShowSpeaker(self,part,speaker,candidates)
    part.multipleSpeakers=candidates and true or false
    part.speaker:SetText(speaker)
    MatchFont(part.speaker,self.page and self.page.title,0,QuestTitleFont,
        false,"Fonts\\MORPHEUS.TTF",part.multipleSpeakers and .72 or .85)
    if part.multipleSpeakers then
        part.speaker:SetTextColor(.43,.32,.20,1)
    else
        part.speaker:SetTextColor(0,0,0,1)
    end
end

function QuestPage:RebindPortraits()
    if not self.active or not self.id then return end
    self.generation=self.generation+1
    for _,stage in ipairs(MOMENTS) do
        local part=self.parts[stage]
        if part:IsShown() then
            local speaker,kind,npc,candidates=SpeakerLabel(self.id,stage)
            ShowSpeaker(self,part,speaker,candidates)
            self:BindPortrait(part,self.id,stage,kind,npc,speaker,candidates)
        end
    end
end

local function NewPart(parent,stage)
    local f=CreateFrame("Frame",nil,parent)
    f.stage=stage
    -- P:Layout supplies the actual size after the stage's dialogue is set.
    local title=Font(f,"QuestTitleFont")
    title:SetText(NAMES[stage]); title:SetTextColor(ALT[1],ALT[2],ALT[3],1)
    title:SetPoint("TOPLEFT",f,"TOPLEFT",0,-2)
    f.title=title
    local face=Portrait(f)
    local badgeTexture=PORTRAIT_BADGES[stage]
    if badgeTexture then
        -- A separate, higher-level frame guarantees the quest-state icon
        -- draws over both the ring and the portrait, even on Vanilla 1.12.
        -- Place the badge at the center of the SMALL socket measured from
        -- the source pixels, not an approximate offset from BOTTOMRIGHT.
        local badgeLayer=CreateFrame("Frame",nil,face)
        badgeLayer:SetWidth(14);badgeLayer:SetHeight(14)
        badgeLayer:SetPoint("CENTER",face.ring,"CENTER",
            18.5,
            SourceUnits(RING_SOURCE_CENTER-SOCKET_SOURCE_Y) - 1)
        badgeLayer:SetFrameLevel(face:GetFrameLevel()+1)
        badgeLayer:EnableMouse(false)
        local badge=badgeLayer:CreateTexture(nil,"OVERLAY")
        badge:SetAllPoints(badgeLayer)
        badge:SetTexture(badgeTexture)
        face.badgeLayer=badgeLayer
        face.badge=badge
    end
    -- Preserve the existing page clearance; the 68-unit ring centers on the face.
    face:SetPoint("TOPLEFT",f,"TOPLEFT",6,-30)
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
    if content.SetSpacing then content:SetSpacing(0) end
    content:SetPoint("TOPLEFT",f,"TOPLEFT",0,-106)
    f.content=content
    local divider=f:CreateTexture(nil,"ARTWORK")
    divider:SetTexture(.45,.28,.12,.24)
    divider:SetHeight(1)
    divider:SetPoint("BOTTOMLEFT",f,"BOTTOMLEFT",0,1)
    divider:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",0,1)
    return f
end
-- Match the native quest log: QuestFont body and QuestTitleFont section headings.
-- Reuse the shared reader's adjustable font size, so all three tabs still scale together.
function QuestPage:ApplyTypography()
    local reference=self.view and self.view.body
    local heading=self.page and self.page.title
    for _,stage in ipairs(MOMENTS) do
        local part=self.parts[stage]
        MatchFont(part.content,reference,0,QuestFont)
        if part.content.SetSpacing then part.content:SetSpacing(0) end
        -- Speaker name is 85% of the Description heading size;
        -- keep its black Morpheus face without the QuestTitleFont shadow.
        MatchFont(part.speaker,heading,0,QuestTitleFont,false,
            "Fonts\\MORPHEUS.TTF",part.multipleSpeakers and .72 or .85)
        if part.multipleSpeakers then
            part.speaker:SetTextColor(.43,.32,.20,1)
        else
            part.speaker:SetTextColor(0,0,0,1)
        end
        MatchFont(part.title,heading,0,QuestTitleFont,true)
    end
end
function QuestPage.Create(page)
    local view=page.body
    local self={page=page,view=view,parts={},id=nil,active=false,generation=0,portraitSubscribed=false}
    setmetatable(self,{__index=QuestPage})
    for _,stage in ipairs(MOMENTS) do self.parts[stage]=NewPart(view.child,stage) end

    -- Register page-local extensions, without replacing shared TextView
    -- methods or depending on a global 'current page' singleton.
    view.onTypographyChanged=function()
        self:ApplyTypography()
    end
    view.onReflowContent=function(_,reset,previous,width)
        if not self.active then return false end
        self:Layout(reset,previous,width)
        return true
    end
    self:ApplyTypography()
    self.portraitCallback=function(id,displayID,success)
        self:OnCreatureAppearance(id,displayID,success)
    end
    -- Preserve any pre-existing page skin handlers; our lifecycle hooks
    -- must not replace layout or other Compendium behavior.
    local priorShow=page.frame.GetScript and page.frame:GetScript("OnShow")
    local priorHide=page.frame.GetScript and page.frame:GetScript("OnHide")
    page.frame:SetScript("OnShow",function(frame)
        if priorShow then priorShow(frame) end
        if not self.active then return end
        self:SubscribePortraits()
        self:RebindPortraits()
    end)
    page.frame:SetScript("OnHide",function(frame)
        if priorHide then priorHide(frame) end
        self:UnsubscribePortraits()
        self.generation=self.generation+1
        for _,part in pairs(self.parts) do
            -- Detach baked native textures immediately on tab/window hide.
            PaintCrest(part.face)
        end
    end)
    -- The remaining 0.25s ticker updates playback buttons only. Creature
    -- portraits now respond to shared ClassicAPI completion notifications.
    self.events=CreateFrame("Frame",nil,page.frame)
    self.events:SetScript("OnEvent",function(_,eventName,itemID,success)
        -- Original WoW 1.12 supplies event/arg1/arg2 as globals.
        eventName=type(eventName)=="string" and eventName or _G.event
        if eventName~="GET_ITEM_INFO_RECEIVED" and
           eventName~="ITEM_DATA_LOAD_RESULT" then return end
        -- Keep an explicit false result; Lua's "and/or" idiom loses it.
        local result=success
        if result==nil then result=_G.arg2 end
        self:OnItemInfoReceived(Number(itemID) or Number(_G.arg1),result)
    end)
    for _,eventName in ipairs({"GET_ITEM_INFO_RECEIVED","ITEM_DATA_LOAD_RESULT"}) do
        -- Old clients without ClassicAPI may reject these custom events.
        pcall(self.events.RegisterEvent,self.events,eventName)
    end
    self.elapsed=0
    self.events:SetScript("OnUpdate",function(_,elapsed)
        if not self.active or not self.page.frame:IsVisible() then return end
        self.elapsed=self.elapsed+(tonumber(elapsed) or tonumber(_G.arg1) or 0)
        if self.elapsed>=.25 then
            self.elapsed=0
            self:RefreshButtons()
        end
    end)
    for _,f in pairs(self.parts) do f:Hide() end
    return self
end
function QuestPage:RefreshButtons()
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
function QuestPage:Layout(reset,previous,width)
    if not self.active then return end
    local view=self.view
    -- Use the shared reader's text margins on every quest section.
    -- Only internal portrait/speaker/play-button geometry is specialized.
    width=width or view.scroll:GetWidth() or 0
    if width<155 then width=view.lastWidth or 330 end
    local y=SSCTextView.PAD_TOP
    local hasPrevious=false
    for _,stage in ipairs(MOMENTS) do
        local part=self.parts[stage]
        if part:IsShown() then
            if hasPrevious then y=y+10 end -- spacing between quest stages only
            part:SetWidth(width)
            part:ClearAllPoints()
            part:SetPoint("TOPLEFT",view.child,"TOPLEFT",0,-y)
            part.content:SetWidth(math.max(110,width))
            part.title:SetWidth(math.max(110,width))
            local th=SSCTextView.MeasureTextHeight(part.content)
            if th<16 then th=22 end
            local h=math.max(129,106+th+17)
            part:SetHeight(h)
            y=y+h
            hasPrevious=true
        end
    end
    view.child:SetHeight(math.max(y+SSCTextView.PAD_BOTTOM,view.scroll:GetHeight() or 1))
    if view.scroll.UpdateScrollChildRect then view.scroll:UpdateScrollChildRect() end
    local maximum=SSCUI.ScrollMax(view.scroll,view.child)
    view.range=maximum
    view:ScrollTo(reset and 0 or previous or SSCUI.ScrollOffset(view.scroll))
end
function QuestPage:Show(id)
    self.generation=self.generation+1
    if not id or not SSCQuestState:IsSeen(id) and not SSCQuestState:Setting("unlock") then
        self.active=false;self.id=nil
        self:UnsubscribePortraits()
        for _,part in pairs(self.parts) do
            PaintCrest(part.face)
            part.button.questID=nil
            part:Hide()
        end
        self.view.body:Show()
        self.view:Reflow(false)
        return
    end
    local changed=self.id~=id
    self.id=id
    self.active=true
    if self.page.frame:IsVisible() then self:SubscribePortraits() end
    self.view.body:Hide()
    local completed=QuestState:IsCompleted(id)
    local unlocked=QuestState:Setting("unlock")
    for _,stage in ipairs(MOMENTS) do
        local part=self.parts[stage]
        local allowed=stage~="complete" or completed or unlocked
        local text=allowed and QuestDialogue:Text(id,stage) or nil
        local voiced=allowed and HasVoice(id,stage)
        local visible=allowed and (stage~="progress" or text or voiced)
        if not visible then
            PaintCrest(part.face)
            part.button.questID=nil
            part:Hide()
        else
            part:Show()
            part.button.questID=id
            if voiced then
                part.button:Enable();part.button:Show()
            else
                part.button:Disable();part.button:Hide()
            end
            local speaker,kind,npc,candidates=SpeakerLabel(id,stage)
            ShowSpeaker(self,part,speaker,candidates)
            self:BindPortrait(part,id,stage,kind,npc,speaker,candidates)
            part.content:SetText(text or (voiced and "Audio available. Dialogue text not recorded." or "No dialogue text available."))
        end
    end
    self:Layout(changed)
    self:RefreshButtons()
end
-- Only the Compendium owns presentation refreshes after live dialogue capture.
-- The data service stays usable even when the Compendium is closed or absent.
QuestDialogue.onCaptured=function(id,stage)
    if QuestState:IsSeen(id) and SSCQuestsTab and SSCQuestsTab.Refresh then
        local C=SSCCompendium
        if C and C.Active and C:Active()=="quests" then SSCQuestsTab:Refresh() end
    end
end
