-- Spoken Quests Phase 1 browser. UI adapter for the existing SSCCompendium
-- virtual list. Upstream's quest catalogue and its chain hierarchy are in
-- QuestCatalog.lua; gameplay state is in QuestState.lua.
SSCQuestsTab = SSCQuestsTab or {}
local QuestsTab=SSCQuestsTab
local Compendium=SSCCompendium
local QuestState=SSCQuestState
local QuestCatalog=SSCQuestCatalog
local Preload=SSCQuestPortraitPreload
local list,panel,page,details,tree
local treeRevision=-1
local selectedID
local opened={ ["continent:1414"]=true,["continent:1415"]=true,["section:other"]=true }
local filter=""
local searchClosed={}
local onlyVoiceCache={}

-- Recomputed when voice packs or the preferred language change. Without this,
-- a negative lookup made before deferred Quests data loaded remains stale.
function QuestsTab:InvalidateVoiceCache()
    onlyVoiceCache={}
    if Compendium and Compendium.IsOpen and Compendium:IsOpen("quests") then
        Compendium:Refresh()
    end
end
if Spoken and Spoken.RegisterCallback then
    Spoken:RegisterCallback("VOICE_PACKS_LOADED",function() QuestsTab:InvalidateVoiceCache() end)
    Spoken:RegisterCallback("VOICE_LANGUAGE_CHANGED",function() QuestsTab:InvalidateVoiceCache() end)
end
local function Lower(text)
    return string.lower(tostring(text or ""))
end
local function Settings(key,value)
    return QuestState:Setting(key,value)
end
local function EnsureCatalog()
    if not _G.SpokenQuestsCompendium then
        QuestsTab.loadError="Quest catalog data is unavailable. Reinstall SoftSpoken_Stories."
        return nil
    end
    QuestsTab.loadError=nil
    if not tree or treeRevision~=QuestState.revision then
        tree=QuestCatalog:BuildTree()
        QuestState:SeedActive(tree.idSet)
        -- Newly seeded collapsed quests may extend the tree with custom IDs.
        if treeRevision~=QuestState.revision then tree=QuestCatalog:BuildTree() end
        treeRevision=QuestState.revision
    end
    return tree
end
local function Status(id)
    if QuestState:IsCompleted(id) then return "Completed" end
    if QuestState:IsActive(id) then return "In progress" end
    if QuestState:IsSeen(id) then return "Previously encountered" end
    return "Not discovered"
end
local function HasVoice(id)
    if onlyVoiceCache[id]~=nil then return onlyVoiceCache[id] end
    local v=VoiceOver
    local d=v and v.DataModules
    local events=v and v.Enums and v.Enums.SoundEvent
    if not d or not d.PrepareSound or not events then return false end
    local result=false
    for _,kind in ipairs({events.QuestAccept,events.QuestProgress,events.QuestComplete}) do
        if kind then
            local ok,valid=pcall(d.PrepareSound,d,{event=kind,questID=id})
            if ok and valid then result=true;break end
        end
    end
    onlyVoiceCache[id]=result
    return result
end
local function IsVisible(id)
    if Settings("foundOnly") and not QuestState:IsSeen(id) then return false end
    if Settings("voicedOnly") and not HasVoice(id) then return false end
    return true
end
local function Match(str)
    return filter=="" or string.find(Lower(str),filter,1,true)~=nil
end
local function Matching(node,forced)
    if node.leaf then
        return IsVisible(node.id) and (forced or Match(QuestCatalog:Title(node.id)))
    end
    local full=forced or Match(node.label)
    for _,child in ipairs(node.children) do
        if Matching(child,full) then return true end
    end
    return false
end
local function Count(node)
    local found,total,completed=0,0,0
    for id in pairs(node.idSet or {}) do
        if IsVisible(id) then
            total=total+1
            if QuestState:IsSeen(id) then found=found+1 end
            if QuestState:IsCompleted(id) then completed=completed+1 end
        end
    end
    return found,total,completed
end
local function AddRow(rows,node,depth,forceMatch)
    if not Matching(node,forceMatch) then return end
    if node.leaf then
        table.insert(rows,{kind="quest",leaf=true,id=node.id,depth=depth,
            label=QuestCatalog:Title(node.id),locked=not QuestState:IsSeen(node.id) and not Settings("unlock"),
            missing=not QuestState:IsSeen(node.id)})
        return
    end
    local openedNow = (filter~="" and not searchClosed[node.key]) or
        (filter=="" and opened[node.key]==true)
    local found,total,completed=Count(node)
    if total==0 then return end
    table.insert(rows,{kind=node.kind,key=node.key,label=node.label,depth=depth,
        leaf=false,open=openedNow, count=completed,total=total, found=found,
        instanceType=node.instanceType,iconType=node.iconType})
    if openedNow then
        local all=forceMatch or Match(node.label)
        for _,child in ipairs(node.children) do AddRow(rows,child,depth+1,all) end
    end
end
function QuestsTab:BuildRows()
    local roots=EnsureCatalog()
    if not roots then return {} end
    local rows={}
    for _,node in ipairs(roots.children) do AddRow(rows,node,0,false) end
    return rows
end
function QuestsTab:IsSelected(item)
    return item.leaf and item.id==selectedID or false
end
local function PageEntry()
    if QuestsTab.loadError and not tree then
        return {title="Stories",subtitle="Missing companion data",text=QuestsTab.loadError,empty=true}
    end
    if not selectedID then
        return {title="Stories",subtitle="Quest acceptance, progress and completion",
            text="Select a quest to read its dialogue and replay available recordings."}
    end
    local entry=QuestCatalog:Entry(selectedID)
    local title=QuestCatalog:Title(selectedID,true)
    local status=Status(selectedID)
    local place=""
    if entry and type(entry.zones)=="table" and table.getn(entry.zones)>0 then
        local names={}
        for _,zone in ipairs(entry.zones) do table.insert(names,QuestState:MapName(zone)) end
        place=table.concat(names,", ")
    elseif entry and type(entry.turtleArea)=="number" and entry.turtleArea>0 then
        -- Verified AreaTable links use the canonical UiMap name provider.
        local meta=_G.SSCTurtleAreaMeta and _G.SSCTurtleAreaMeta[entry.turtleArea]
        if meta and meta.uiMapID then
            place=QuestState:MapName(meta.uiMapID)
        elseif meta and meta.dungeonMapID then
            place=Compendium.DungeonName(meta.dungeonMapID)
        else
            place=meta and meta.name or ("Turtle Area "..entry.turtleArea)
        end
    elseif entry and entry.sort then
        place=QuestCatalog:SortName(entry.sort)
    else
        place="Place unknown (Turtle/uncatalogued quest)"
    end
    return {title=title,subtitle=place.."  ·  "..status,key="quest:"..selectedID,
        text=""}
end
function QuestsTab:Refresh()
    if not list then return end
    -- Turning off the Settings unlock checkbox must also revoke any
    -- previously selected undiscovered quest's detail page.
    if selectedID and not QuestState:IsSeen(selectedID) and not Settings("unlock") then
        selectedID=nil
    end
    -- Selected quest first; visible-row work starts only after the list redraw.
    if Preload then
        if Compendium and Compendium.IsOpen and Compendium:IsOpen("quests") then
            Preload:Start()
            Preload:Selected(selectedID)
        else
            Preload:Stop()
        end
    end
    list:Render()
    if page then
        local entry=PageEntry()
        page:Show(entry)
        if details then details:Show(selectedID) end
    end
end
function QuestsTab:Select(item)
    if item.leaf then
        if item.locked then return end
        selectedID=item.id
    else
        if filter~="" then
            -- Upstream allows closing a branch even when search opens it.
            searchClosed[item.key]=not searchClosed[item.key] or nil
        else
            opened[item.key]=not opened[item.key]
        end
    end
    QuestsTab:Refresh()
end
local function Build(panelFrame)
    panel=panelFrame
    EnsureCatalog()
    list=Compendium.NewList(panelFrame,{
        search="Search",
        none="No matching quests.",
        noneDiscovered="No quests discovered yet.",
        discoveryOnly=function()
            return not QuestsTab.loadError and Settings("foundOnly") and not Settings("voicedOnly")
        end,
        only="Discovered Only",
        onlyGet=function() return Settings("foundOnly") end,
        onlySet=function(on) Settings("foundOnly",on) end,
        checks={
            {label="Voiced Only",get=function() return Settings("voicedOnly") end,
                set=function(on) Settings("voicedOnly",on) end},
        },
        build=function() return QuestsTab:BuildRows() end,
        isSelected=function(item) return QuestsTab:IsSelected(item) end,
        onClick=function(item) QuestsTab:Select(item) end,
        onHover=function(item)
            if Preload and Compendium and Compendium.IsOpen and Compendium:IsOpen("quests") then Preload:Hover(item) end
        end,
        onVisibleRows=function(items,first,last)
            if Preload and Compendium and Compendium.IsOpen and Compendium:IsOpen("quests") then
                Preload:Visible(items,first,last)
            end
        end,
        onSearch=function(text)
            filter=Lower(string.gsub(string.gsub(text or "","^%s+",""),"%s+$",""))
            searchClosed={}
            QuestsTab:Refresh()
        end,
    })
    panelFrame.Refresh=function() QuestsTab:Refresh() end
    panelFrame.listInset=list.inset
    -- Use the very same right-page construction as Places and Readables.
    -- The shared prototype skin owns parchment art, geometry and scroll
    -- chrome; Quests supplies only quest-specific content and actions.
    local pageInset
    pageInset, page = Compendium.CreatePagePane(panelFrame, list, function(holder)
        return SSCLorePage.CreateLorePage(holder)
    end)
    if SSCQuestPage and SSCQuestPage.Create then
        details=SSCQuestPage.Create(page)
    end
    panelFrame.pageInset=pageInset
    panelFrame.page=page.frame
    page:Show(PageEntry())
end
-- Register before PLAYER_ENTERING_WORLD; zone tab can register before or
-- after this one without requiring a window rewrite.
if Compendium and Compendium.Register and not Compendium:Tab("quests") then
    Compendium:Register("quests",{
        label="Stories",order=0,title="Azeroth's Compendium",
        build=Build,
        onShow=function() QuestState:ReadLog() end,
        onHide=function() if Preload then Preload:Stop() end end,
        -- A second click on the currently selected tab returns to its landing
        -- page; switching away and back never clears the current quest.
        onReselect=function() selectedID=nil;QuestsTab:Refresh() end,
        -- The Quests module switch governs both audio and its Compendium page.
        -- Gossip has its own independent narration switch.
        enabled=function() return Spoken and Spoken.IsPartOn and Spoken:IsPartOn("quests") end,
        unlock={
            get=function() return Settings("unlock") end,
            set=function(on)
                Settings("unlock",on)
                QuestsTab:Refresh()
            end,
        },
    })
end
