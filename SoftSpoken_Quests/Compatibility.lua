setfenv(1, VoiceOver)

-- Quest-specific Turtle WoW 1.12 adapters. Shared Lua/FrameXML primitives
-- are installed in Environment.lua before any other Quests implementation
-- files load, so top-level frames also receive the Core wrappers.

if not GetQuestID then
    local source, text
    local selectedQuest -- ClassicAPI gossip selection, valid only for this quest conversation.
    local GetTitleText = GetTitleText -- Store original function before EQL3 overrides it

    -- VoiceOver.lua captures the selected quest while the gossip list and its
    -- authoritative ClassicAPI quest IDs are still available.
    function Addon:NoteClassicQuestSelection(id, title, npcName, kind)
        if not Version.IsLegacyVanilla or type(id) ~= "number" or id <= 0 or
           type(title) ~= "string" or title == "" then
            return
        end
        selectedQuest = { id = id, title = title, npcName = npcName or "", kind = kind }
    end

    function Addon:ClearClassicQuestSelection()
        selectedQuest = nil
    end

    -- Told by VoiceOver.lua's QuestIDFor just before it asks which quest this is.
    function Addon:NoteLegacyQuestEvent(eventSource, eventText)
        source = eventSource
        text = eventText
    end

    function GetQuestID()
        if not source then return 0 end
        local title = GetTitleText()
        if type(title) ~= "string" or title == "" then return 0 end
        local npcName = Utils:GetNPCName() or ""

        -- Exact selected quest from ClassicAPI, never inferred from an arbitrary
        -- gossip list. Verify title, NPC, and accept-vs-turn-in context.
        if selectedQuest and selectedQuest.title == title and
           (selectedQuest.npcName == "" or selectedQuest.npcName == npcName) and
           ((source == "accept" and selectedQuest.kind == "available") or
            (source ~= "accept" and selectedQuest.kind == "active")) then
            return selectedQuest.id
        end

        -- A progress/turn-in quest is already in the log. Only trust a title
        -- when exactly one distinct positive real ID matches; duplicated
        -- titles fall back to Spoken's existing NPC/text-aware resolver.
        if source ~= "accept" and C_QuestLog and
           type(C_QuestLog.GetQuestIDForLogIndex) == "function" and GetNumQuestLogEntries then
            local matchedID
            local entries = GetNumQuestLogEntries() or 0
            for i = 1, entries do
                local logTitle, _, _, isHeader = GetQuestLogTitle(i)
                if not isHeader and logTitle == title then
                    local id = C_QuestLog.GetQuestIDForLogIndex(i)
                    if type(id) == "number" and id > 0 then
                        if matchedID and matchedID ~= id then
                            matchedID = nil
                            break
                        end
                        matchedID = id
                    end
                end
            end
            if matchedID then return matchedID end
        end

        if Utils:IsNPCPlayer() then
            -- Shared quest: keep upstream's original handling.
            return 0
        end
        return DataModules:GetQuestID(source, title, npcName, text or "") or 0
    end
end

if not QUESTS_DISPLAYED then
    if QuestLogScrollFrame then
        QUESTS_DISPLAYED = getn(QuestLogScrollFrame.buttons)
    end
end

-- Turtle may expose UnitGUID through client extensions. Its legacy hexadecimal
-- GUID format is not the 4.x+ Player-... format; preserve the 1.12 resolver.
if not UnitGUID then
    Utils.GetGUIDType=nil
    Utils.GetIDFromGUID=nil
    Utils.MakeGUID=function() end
else
    Enums.GUID.Player     = tonumber("0000", 16)
    Enums.GUID.Item       = tonumber("4000", 16)
    Enums.GUID.Creature   = tonumber("F130", 16)
    Enums.GUID.Vehicle    = tonumber("F150", 16)
    Enums.GUID.GameObject = tonumber("F110", 16)

    function Utils:GetGUIDType(guid)
        return guid and tonumber(guid:sub(3, 3 + 4 - 1), 16)
    end

    function Utils:GetIDFromGUID(guid)
        local type = assert(self:GetGUIDType(guid), format([[Failed to determine the type of GUID "%s"]], guid))
        assert(Enums.GUID:GetName(type), format([[Unknown GUID type %d]], type))
        assert(Enums.GUID:CanHaveID(type), format([[GUID "%s" does not contain ID]], guid))
        return tonumber(guid:sub(7, 7 + 6 - 1), 16)
    end

    function Utils:MakeGUID(type, id)
        assert(Enums.GUID:CanHaveID(type), format("GUID of type %d (%s) cannot contain ID", type, Enums.GUID:GetName(type) or "Unknown"))
        return format("0x%04X%06X%06X", type, id, 0)
    end
end

-- Native WoW 1.12 GetQuestLogTitle returns exactly six values:
-- title, level, questTag, isHeader, isCollapsed, isComplete.
-- There is no suggestedGroup or isDaily return in this client. The normalized
-- frequency is therefore always 1, exactly as the previous 1.12 adapter
-- returned; do not infer daily status from questTag or later-client APIs.
-- Recover IDs via ClassicAPI, then existing DataModules/title history.
-- A stable negative ID is only a UI placeholder for an unresolved quest.
local dummyQuestIDMap={NEXT=-1}
local oldGetQuestLogTitle=GetQuestLogTitle -- Capture before EQL3 changes the quest-log UI.
function GetQuestLogTitle(questIndex)
    local title,level,questTag,isHeader,isCollapsed,isComplete=oldGetQuestLogTitle(questIndex)
    local questID
    if not isHeader and C_QuestLog and
       type(C_QuestLog.GetQuestIDForLogIndex)=="function" then
        questID=C_QuestLog.GetQuestIDForLogIndex(questIndex)
    end
    if type(questID)~="number" or questID<=0 then
        questID=DataModules:GetQuestID("accept",title,"","")
    end
    if not questID and Addon.db and Addon.db.char then
        questID=Addon.db.char.RecentQuestTitleToID[title]
    end
    if not questID then
        questID=dummyQuestIDMap[title]
        if not questID then
            questID=dummyQuestIDMap.NEXT
            dummyQuestIDMap.NEXT=dummyQuestIDMap.NEXT-1
            dummyQuestIDMap[title]=questID
        end
    end
    return title,level,nil,isHeader,isCollapsed,isComplete,1,questID
end

-- Quest-specific 1.12 behavior is deliberately local to this module.
LibStub("AceConfig-3.0"):Embed(Addon)

local function getargn(...)
    return arg.n
end
function GetNumGossipActiveQuests()
    return getargn(GetGossipActiveQuests())
end
function GetNumGossipAvailableQuests()
    return getargn(GetGossipAvailableQuests())
end

function Utils:GetNPCName()
    return UnitName("npc")
end
function Utils:GetNPCGUID()
    return nil
end
function Utils:IsNPCObjectOrItem()
    return not UnitExists("npc")
end
function Utils:IsNPCPlayer()
    return UnitIsPlayer("npc")
end

-- Extended Quest Log 3 changes quest-log frames, not shared FrameXML methods.
function Addon.OnAddonLoad.EQL3() -- Extended Quest Log 3
    QUESTS_DISPLAYED = EQL3_QUESTS_DISPLAYED

    QuestLogFrame = EQL3_QuestLogFrame
    QuestLogListScrollFrame = EQL3_QuestLogListScrollFrame

    function Utils:GetQuestLogTitleFrame(index)
        return _G["EQL3_QuestLogTitle" .. index]
    end

    function Utils:GetQuestLogTitleNormalText(index)
        return _G["EQL3_QuestLogTitle" .. index .. "NormalText"]
    end

    function Utils:GetQuestLogTitleCheck(index)
        return _G["EQL3_QuestLogTitle" .. index .. "Check"]
    end

    -- Hook the new function created by EQL3
    hooksecurefunc("QuestLog_Update", function()
        QuestOverlayUI:Update()
    end)
end
