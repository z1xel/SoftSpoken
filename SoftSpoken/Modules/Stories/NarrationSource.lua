setfenv(1, VoiceOver)

-- This addon speaking through the Spoken player. The queue, the frame, the minimap
-- button and pause are the player's; this file is the one place that knows both what a
-- quest line is and what the player wants to be handed.
--
-- A prepared SoundData IS the clip: the player reads key, path, length, priority and
-- present from it and ignores the rest, and the dispatcher keeps reading event, questID,
-- name and unitGUID from the same table. One table, two readers, no copying.
-- Two sources, one per part of Spoken's page: quests, and gossip (what NPCs say in their gossip
-- and greeting windows). Spoken switches each on and off and shows each on its own; the queue
-- below them is shared.
StoriesNarrator = { source = nil, gossipSource = nil }

local TEXTURES = [[Interface\AddOns\SoftSpoken\Textures\]]
-- The packs that hold quests alone. Every other pack holds gossip too.
local QUEST_ONLY = {
    SpokenQuestsAudioAlliance = true,
    SpokenQuestsAudioHorde = true,
    SpokenQuestsAudioShared = true,
}

--- Whether a pack holds gossip.
function StoriesNarrator:HoldsGossip(module)
    return not QUEST_ONLY[module.AddonName]
end

local BULLETS = {
    [Enums.SoundEvent.QuestAccept]   = "quest-accept",
    [Enums.SoundEvent.QuestProgress] = "quest-progress",
    [Enums.SoundEvent.QuestComplete] = "quest-complete",
    [Enums.SoundEvent.QuestGreeting] = "gossip",
    [Enums.SoundEvent.Gossip]        = "gossip",
    [Enums.SoundEvent.QuestFollowup] = "quest-complete",
}

-- Explicit stages keep missing progress or reward text from being replaced
-- by the offer. Follow-up/gossip lines have no Compendium quest-text stage.
local QUEST_STAGES = {
    [Enums.SoundEvent.QuestAccept]   = "accept",
    [Enums.SoundEvent.QuestProgress] = "progress",
    [Enums.SoundEvent.QuestComplete] = "complete",
}

--------------------------------------------------------------------------------
-- Reading the queue back
--------------------------------------------------------------------------------

--- Whether a clip is this addon's, quests' or gossip's.
function StoriesNarrator:Owns(clip)
    return clip.source ~= nil and (clip.source == self.source or clip.source == self.gossipSource)
end

--- The source that plays a line: gossip's for what NPCs say, quests' for the rest.
function StoriesNarrator:SourceOf(soundData)
    if self.gossipSource and Enums.SoundEvent:IsGossipEvent(soundData.event) then
        return self.gossipSource
    end
    return self.source
end

--- This addon's clips, in queue order.
function StoriesNarrator:Queued()
    local list = {}
    if not self.source or not Spoken then
        return list
    end
    for _, clip in ipairs(Spoken:GetQueue()) do
        if self:Owns(clip) then
            table.insert(list, clip)
        end
    end
    return list
end

function StoriesNarrator:Contains(soundData)
    for _, clip in ipairs(self:Queued()) do
        if clip == soundData then
            return true
        end
    end
    return false
end

--- The head, if it is one of ours.
function StoriesNarrator:Current()
    local head = Spoken and Spoken:GetCurrent()
    if head and self:Owns(head) then
        return head
    end
    return nil
end

local function GossipClips()
    local list = {}
    for _, clip in ipairs(StoriesNarrator:Queued()) do
        if Enums.SoundEvent:IsGossipEvent(clip.event) then
            table.insert(list, clip)
        end
    end
    return list
end

--------------------------------------------------------------------------------
-- Presentation
--------------------------------------------------------------------------------

-- Speaker identity comes from Stories' shared resolver, not from the quest ID.
-- Only appearance lookup stays here; the core's model renderer remains unchanged.
local NOTICE = [[Interface\Icons\INV_Misc_Note_01]]
local ICON_CROP = { 0.08, 0.92, 0.08, 0.92 }

local function CrestFallback()
    local texture = SSCQuestFactionCrest.Resolve()
    return { kind = "texture", texture = texture, texCoord = {0,1,0,1} }
end

local function Faceless(soundData)
    local icon, crop
    if Spoken and Spoken.QuestItemIcon then icon, crop = Spoken:QuestItemIcon(soundData.questID) end
    return { kind = "texture", texture = icon or NOTICE, texCoord = crop or ICON_CROP }
end

local function PortraitFor(soundData)
    -- Speaker resolution must never interrupt a narration clip.
    local ok, kind, speakerID = pcall(SpeakerResolver.ForSound, SpeakerResolver, soundData)
    if not ok then kind, speakerID = nil, nil end
    if soundData.unitIsObjectOrItem or (kind and not Enums.GUID:IsCreature(kind)) then
        return Faceless(soundData)
    end
    local creatureID = kind and Enums.GUID:IsCreature(kind) and speakerID or nil
    -- On unextended Vanilla, retain the legacy name-based model attempt.
    -- Never interpret a quest ID as a creature ID.
    local original = {
        kind = "model",
        creatureID = creatureID or soundData.name,
        animation = 60,
        fallback = CrestFallback(),
    }
    if rawget(_G, "SoftSpokenClassicPortraits") ~= false and creatureID and
       C_CreatureInfo and type(C_CreatureInfo.GetCreatureInfoByID) == "function" and
       Spoken and type(Spoken.GetCreatureDisplayID) == "function" then
        local okInfo, displayID = pcall(Spoken.GetCreatureDisplayID, Spoken, creatureID)
        if not okInfo then displayID = nil end
        return {
            kind = "creature", creatureID = creatureID,
            displayID = displayID,
            -- The renderer requests uncached data asynchronously; the
            -- same faction crest is used by the Compendium.
            fallback = CrestFallback(),
        }
    end
    return original
end

-- The Stop Gossip control, anchored to the header as it always was. The one place the
-- domain-agnostic frame is asked to host something quest-shaped.
local STOP_GOSSIP = {
    id = "stopGossip",
    anchor = "header",
    visible = function() return getn(GossipClips()) > 0 end,
    create = function(parent)
        local button = CreateFrame("Button", nil, parent)
        button:SetSize(32, 32)
        function button:SetGossipCount(gossipCount)
            local texture = gossipCount > 1 and (TEXTURES .. "StopGossipMore") or (TEXTURES .. "StopGossip")
            self:SetShown(gossipCount > 0)
            self:SetHighlightTexture(texture, "ADD")
            self:SetNormalTexture(texture)
            self:SetPushedTexture(texture)
            self.tooltip = gossipCount > 1 and L.OPT_NEXT_GOSSIP or L.OPT_STOP_GOSSIP
            if GameTooltip:GetOwner() == self then
                GameTooltip:SetText(self.tooltip)
                GameTooltip:Show()
            end
        end
        button:SetGossipCount(0)
        button:GetHighlightTexture():SetAlpha(0.5)
        button:GetPushedTexture():SetAlpha(0.5)
        button:HookScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:SetPoint("LEFT", self, "RIGHT")
            GameTooltip:SetText(self.tooltip)
            GameTooltip:Show()
        end)
        button:HookScript("OnLeave", GameTooltip_Hide)
        button:HookScript("OnClick", function()
            PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
            local head = StoriesNarrator:Current()
            if head and Enums.SoundEvent:IsGossipEvent(head.event) then
                StoriesNarrator:Remove(head)
            else
                for _, clip in ipairs(GossipClips()) do
                    StoriesNarrator:Remove(clip)
                end
            end
        end)
        return button
    end,
    onClipChanged = function(clip, button)
        button:SetGossipCount(getn(GossipClips()))
    end,
}

local REPORT = {
    id = "report",
    -- An icon in the corner rather than a word beside the line: the label never changed,
    -- and the strip it used to sit in pushed the queue up to make room for it. The bug
    -- icon is not guaranteed in Vanilla 1.12. The `text` fallback prevents
    -- an empty button when that texture is unavailable.
    icon = [[Interface\HelpFrame\HelpIcon-Bug]],
    label = L.OPT_REPORT_PROBLEM,
    text = "R",
    anchor = "topright",
    tooltip = function(tooltip)
        tooltip:SetText(L.OPT_REPORT_PROBLEM)
        tooltip:AddLine(L.OPT_REPORT_LINE_TIP, 1, 0.8, 0.2, true)
    end,
    onClick = function(clip)
        -- The line itself first: by the time Report is clicked the quest window may be shut.
        local target = ReportButton:TargetForClip(clip)
        target = target or ReportButton:CurrentTarget()
        if target then
            -- The language the clip was spoken in, which PrepareSound recorded: a fallback line
            -- is an English take even under a German selection, and its report is about that.
            ReportButton:ShowLink(target, clip.language)
        else
            StaticPopup_Show("VOICEOVER_ERROR", L.OPT_REPORT_NO_LINE)
        end
    end,
}

local ACTIONS = { REPORT, STOP_GOSSIP }

--- Turn a prepared SoundData into a clip, in place.
function StoriesNarrator:Prepare(soundData)
    local event = soundData.event
    local gossip = Enums.SoundEvent:IsGossipEvent(event)
    -- Preserve live NPC dialogue. A clip without a dialog snapshot resolves
    -- the matching quest stage from the same service as the Compendium:
    -- captured -> Turtle -> original Spoken. Gossip/follow-ups stay separate.
    local stage = QUEST_STAGES[event]
    local dialogue = QuestDialogue
    if stage and (type(soundData.text) ~= "string" or not string.find(soundData.text, "%S"))
        and soundData.questID and dialogue and dialogue.Text then
        local ok, text = pcall(dialogue.Text, dialogue, soundData.questID, stage)
        if ok and type(text) == "string" and string.find(text, "%S") then
            soundData.text = text
        end
    end
    soundData.key = soundData.fileName
    soundData.path = soundData.filePath
    soundData.priority = gossip and "low" or "normal"
    soundData.present = {
        header = soundData.name or "",
        label = soundData.title or (event == Enums.SoundEvent.QuestGreeting and L.OPT_GREETING or (gossip and L.OPT_PACK_GOSSIP or "")),
        bullet = BULLETS[event],
        tint = gossip and { 1, 1, 1 } or nil,
        portrait = PortraitFor(soundData),
        transcript = soundData.text,
        actions = ACTIONS,
    }
    return soundData
end

--------------------------------------------------------------------------------
-- Queueing
--------------------------------------------------------------------------------

-- The windows a dispatched event stands for, as the debug log names them.
local WINDOWS = {
    QUEST_DETAIL = "the NPC's quest window (the offer)",
    QUEST_PROGRESS = "the NPC's quest window (progress)",
    QUEST_COMPLETE = "the NPC's quest window (the reward)",
    QUEST_GREETING = "the NPC's greeting window",
    GOSSIP_SHOW = "the NPC's gossip window",
}

--- Where a line comes from, as the debug log says it: the window an event stands for, and
--- whether it was read automatically or asked for (`dispatchOrigin`: the Play button, /spq read, ...).
function StoriesNarrator:Origin(event, dispatchOrigin, manual)
    local window = WINDOWS[event] or tostring(event)
    if manual then
        return window .. ", asked for with " .. tostring(dispatchOrigin or "a reader")
    end
    return window .. ", read automatically (" .. tostring(dispatchOrigin or "event") .. ")"
end

--- What a line says of where it came from, on the `queued` stage: the debug log's reader asks
--- which screen queued what.
local function From(soundData)
    if soundData and soundData.origin then return ", from " .. soundData.origin end
    return ""
end

--- Resolve a line through the packs and hand it to the player. Records the stage the
--- the event bridge and diagnostics use.
---@param soundData SoundData
---@param asked boolean? the player asked for it, so it is read in a battleground too
---@return boolean queued
function StoriesNarrator:Enqueue(soundData, asked)
    if not soundData.origin then soundData.origin = self.origin end
    if not self.source then
        Debug:Record("player-missing", "The shared narration source is not initialized")
        return false
    end

    local found, why = DataModules:PrepareSound(soundData)
    if not found then
        Debug:Record("data-lookup-failed", format("No sound entry for event %s, quest ID %s, title %q, language %s: %s",
            Enums.SoundEvent:GetName(soundData.event) or tostring(soundData.event),
            tostring(soundData.questID or "none"), soundData.title or soundData.name or "",
            table.concat(Language:ResolutionOrder(), " then "), tostring(why)))
        if Spoken.EndMuteGameDialogueAhead then
            Spoken:EndMuteGameDialogueAhead()
        end
        return false
    end

    return self:EnqueuePrepared(soundData, asked)
end

--- A line asked for by hand: played at once when idle or stopped, else queued behind the line
--- speaking.
---@param soundData SoundData
---@return boolean queued
function StoriesNarrator:PlayNow(soundData)
    if not soundData.origin then soundData.origin = self.origin end
    if not self.source then
        Debug:Record("player-missing", "The shared narration source is not initialized")
        return false
    end
    local found, why = DataModules:PrepareSound(soundData)
    if not found then
        Debug:Record("data-lookup-failed", format("No sound entry for event %s, quest ID %s: %s",
            Enums.SoundEvent:GetName(soundData.event) or tostring(soundData.event), tostring(soundData.questID or "none"),
            tostring(why)))
        return false
    end
    self:Prepare(soundData)
    local queued = self:SourceOf(soundData):PlayNow(soundData)
    return queued and true or false
end

--- Hand the player a line whose file DataModules has already resolved.
---@param soundData SoundData
---@param asked boolean? as Enqueue's
---@return boolean queued
function StoriesNarrator:EnqueuePrepared(soundData, asked)
    if not self.source then
        Debug:Record("player-missing", "The shared narration source is not initialized")
        return false
    end

    self:Prepare(soundData)
    if self.playNow then
        return self:PlayPreparedNow(soundData)
    end
    local added, reason = self:SourceOf(soundData):Enqueue(soundData, asked)
    if not added then
        if reason == "duplicate" then
            -- Already queued counts as queued for diagnostics and event deduplication.
            Debug:Record("queued", format("Already queued: %s%s", soundData.fileName, From(soundData)))
        elseif reason == "missing" then
            Debug:Record("file-playback-failed", format([[The data entry exists, but PlaySoundFile rejected "%s" from module "%s"]],
                soundData.filePath, soundData.module.METADATA.AddonName))
        elseif reason == "outranked" then
            Debug:Record("queue-outranked", "Gossip yields to the quest line that is queued")
        else
            Debug:Record("sound-disabled", reason or "refused")
        end
        return false
    end

    if Spoken:IsPaused() then
        Debug:Record("queue-paused", "The voiceover is queued, but playback is stopped; use Replay or the playback keybinding")
    end
    return true
end

--- Plays a line asked for by a dialog's Play button at once, ahead of the queue, and skips what
--- was speaking rather than replaying it. Callers set `StoriesNarrator.playNow` around the read.
---@param soundData SoundData
---@return boolean playing
function StoriesNarrator:PlayPreparedNow(soundData)
    local interrupted = Spoken.GetCurrent and Spoken:GetCurrent()
    if interrupted and interrupted.key == soundData.key then
        interrupted = nil
    end
    -- The player's PlayNow queues behind a line already speaking, so that line stops first.
    local stopped = interrupted ~= nil and Spoken.Pause ~= nil and not Spoken:IsPaused() and Spoken:Pause()
    local playing, reason = self:SourceOf(soundData):PlayNow(soundData)
    if not playing then
        Debug:Record("sound-disabled", reason or "refused")
        if stopped and Spoken.Resume then
            Spoken:Resume()
        end
        return false
    end
    if interrupted then
        for _, clip in ipairs(Spoken:GetQueue()) do
            if clip == interrupted then
                Debug:Record("skipped", format("Skipped %s for the line asked for", tostring(interrupted.key)))
                interrupted.source:Remove(interrupted)
                break
            end
        end
    end
    return true
end

--- The queued clip reading the dialog's line, or nil. Matched by file rather than by the
--- SoundData the handler built, so a line started from the quest log counts too.
function StoriesNarrator:QueuedClipFor(line)
    for _, clip in ipairs(self:Queued()) do
        if clip.fileName == line.fileName then
            return clip
        end
    end
end

function StoriesNarrator:Remove(soundData)
    if not self.source then
        return false
    end
    return (soundData.source or self:SourceOf(soundData)):Remove(soundData)
end

--- After a setting changed something the player draws from.
function StoriesNarrator:RefreshConfig()
    if Spoken and Spoken.RefreshPlayer then
        Spoken:RefreshPlayer()
    end
end

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------

function StoriesNarrator:Setup()
    if self.source then
        return true
    end
    if not (Spoken and Spoken.IsCompatible and Spoken:IsCompatible(1)) then
        Debug:Record("player-missing", "The shared narration source is not initialized; nothing will be read aloud")
        return false
    end

    self.source = Spoken:RegisterSource("quests", {
        title = L.OPT_PAGE_TITLE,
        addon = AddonFolder,
        order = 1,
        -- Upstream's figure: quest durations come from a lookup that has drifted across
        -- transcodes, and the extra gap absorbs one that is slightly short.
        interClipGap = 0.55,
        -- Play-and-stop the file before admitting it, as the queue always did here.
        -- Its settings follow the profile chosen in Spoken's own settings.
        profiles = function() return StoriesAddon.db end,
        -- Printed after Spoken's own by its Show Diagnostics.
        diagnostics = function() Options:PrintDiagnostics() end,
        -- Quests' installed-pack inventory can include load-on-demand addons
        -- whose recordings failed to register. The core's startup warning
        -- must use the registered data, not the merely installed list.
        hasUsablePacks = function() return DataModules:HasRegisteredModules() end,
        voicePacksPending = function() return StoriesAddon.dataModulesPending end,
        -- What Spoken's settings show on this part's card: which voice packs are installed.
        packs = function()
            local names = {}
            for _, module in DataModules:GetPresentModules() do table.insert(names, module.Title) end
            return names
        end,
    })

    -- What NPCs say in their gossip and greeting windows is a part of its own on Spoken's page:
    -- switched on and off, and shown, apart from the quests.
    self.gossipSource = Spoken:RegisterSource("gossip", {
        title = L.OPT_GOSSIP_PAGE_TITLE,
        addon = AddonFolder,
        order = 2,
        interClipGap = 0.55,
        profiles = function() return StoriesAddon.db end,
        -- The voice packs that hold gossip.
        packs = function()
            local names = {}
            for _, module in DataModules:GetPresentModules() do
                if StoriesNarrator:HoldsGossip(module) then table.insert(names, module.Title) end
            end
            return names
        end,
    })

    -- Queue admission is reported for event deduplication and diagnostics.
    Spoken:RegisterCallback("CLIP_QUEUED", function(clip)
        if StoriesNarrator:Owns(clip) then
            Debug:Record("queued", format("Queued %s (%s)%s", clip.title or clip.name or clip.fileName, clip.path,
                From(clip)))
        end
    end)
    Spoken:RegisterCallback("CLIP_STARTED", function(clip)
        if not StoriesNarrator:Owns(clip) then
            return
        end
        Debug:Record("playing", format("Playing %s", clip.path or clip.fileName or "voiceover"))
    end)

    -- Switchable from the player's settings, named there by this addon. The zones addon
    -- declares the same id, so one setting covers whichever is speaking.
    if Spoken.RegisterOptionalAction then
        Spoken:RegisterOptionalAction("report", L.OPT_REPORT)
    end

    Spoken:RegisterBullet("quest-accept",   TEXTURES .. "SoundQueueBulletAccept", 14)
    Spoken:RegisterBullet("quest-progress", TEXTURES .. "SoundQueueBulletProgress", 14)
    Spoken:RegisterBullet("quest-complete", TEXTURES .. "SoundQueueBulletComplete", 14)
    Spoken:RegisterBullet("gossip",         TEXTURES .. "SoundQueueBulletGossip", 14)

    -- Switched off or on in Spoken's settings: the buttons on the log and the dialog follow, and
    -- so does the Compendium's Quests tab.
    if Spoken.RegisterCallback then
        Spoken:RegisterCallback("PART_SWITCHED", function(key)
            if key ~= "quests" and key ~= "gossip" then return end
            -- Each only where this client loads it.
            local overlay, dialog = rawget(VoiceOver, "QuestOverlayUI"),
                rawget(VoiceOver, "DialogPlayButton")
            if overlay and key == "quests" then
                if overlay.Update and (QuestLogFrame or QuestScrollFrame) then overlay:Update() end
                if overlay.UpdateDetailsPlayButton then overlay:UpdateDetailsPlayButton() end
            end
            if dialog and dialog.Refresh then dialog:Refresh() end
            local compendium = _G.SpokenCompendium
            if compendium and compendium.Relayout then compendium:Relayout() end
        end)
    end

    -- Quests is reached through its registered shared Settings page.
    -- No separate minimap link, Quests/Gossip menu entry or second window.
    return true
end
