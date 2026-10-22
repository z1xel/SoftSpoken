-- Spoken Quests Phase 1 browser. UI adapter for the existing SSCCompendium
-- virtual list. Upstream's quest catalogue and its chain hierarchy are in
-- QuestCatalog_112.lua; gameplay state is in QuestState_112.lua.
SSCQuestsTab = SSCQuestsTab or {}
local Q=SSCQuestsTab
local C=SSCCompendium
local S=SSCQuestState
local M=SSCQuestCatalog
local list,panel,page,details,tree
local treeRevision=-1
local selectedID
local opened={ ["continent:1414"]=true,["continent:1415"]=true,["section:other"]=true }
local filter=""
local searchClosed={}
local onlyVoiceCache={}

-- Recomputed when voice packs or the preferred language change. Without this,
-- a negative lookup made before deferred Quests data loaded remains stale.
function Q:InvalidateVoiceCache()
    onlyVoiceCache={}
    if C and C.IsOpen and C:IsOpen("quests") then
        C:Refresh()
    end
end
if Spoken and Spoken.RegisterCallback then
    Spoken:RegisterCallback("VOICE_PACKS_LOADED",function() Q:InvalidateVoiceCache() end)
    Spoken:RegisterCallback("VOICE_LANGUAGE_CHANGED",function() Q:InvalidateVoiceCache() end)
end
local function Lower(text)
    return string.lower(tostring(text or ""))
end
local function Settings(key,value)
    return S:Setting(key,value)
end
local function EnsureCatalog()
    if not _G.SpokenQuestsCompendium and type(LoadAddOn)=="function" then
        local ok,loaded=pcall(LoadAddOn,"SoftSpoken_QuestData")
        if not ok or loaded==false then
            Q.loadError="Could not load SoftSpoken_QuestData. Enable the companion addon in AddOns."
        end
    end
    if _G.SpokenQuestsCompendium and (not tree or treeRevision~=S.revision) then
        tree=M:BuildTree()
        S:SeedActive(tree.idSet)
        -- Newly seeded collapsed quests may extend the tree with custom IDs.
        if treeRevision~=S.revision then tree=M:BuildTree() end
        treeRevision=S.revision
    end
    return tree
end
local function Status(id)
    if S:IsCompleted(id) then return "Completed" end
    if S:IsActive(id) then return "In progress" end
    if S:IsSeen(id) then return "Previously encountered" end
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
    if Settings("foundOnly") and not S:IsSeen(id) then return false end
    if Settings("voicedOnly") and not HasVoice(id) then return false end
    return true
end
local function Match(str)
    return filter=="" or string.find(Lower(str),filter,1,true)~=nil
end
local function Matching(node,forced)
    if node.leaf then
        return IsVisible(node.id) and (forced or Match(M:Title(node.id)))
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
            if S:IsSeen(id) then found=found+1 end
            if S:IsCompleted(id) then completed=completed+1 end
        end
    end
    return found,total,completed
end
local function AddRow(rows,node,depth,forceMatch)
    if not Matching(node,forceMatch) then return end
    if node.leaf then
        table.insert(rows,{kind="quest",leaf=true,id=node.id,depth=depth,
            label=M:Title(node.id),locked=not S:IsSeen(node.id) and not Settings("unlock"),
            missing=not S:IsSeen(node.id)})
        return
    end
    local openedNow = (filter~="" and not searchClosed[node.key]) or
        (filter=="" and opened[node.key]==true)
    local found,total,completed=Count(node)
    if total==0 then return end
    table.insert(rows,{kind=node.kind,key=node.key,label=node.label,depth=depth,
        leaf=false,open=openedNow, count=completed,total=total, found=found})
    if openedNow then
        local all=forceMatch or Match(node.label)
        for _,child in ipairs(node.children) do AddRow(rows,child,depth+1,all) end
    end
end
function Q:BuildRows()
    local roots=EnsureCatalog()
    if not roots then return {} end
    local rows={}
    for _,node in ipairs(roots.children) do AddRow(rows,node,0,false) end
    return rows
end
function Q:IsSelected(item)
    return item.leaf and item.id==selectedID or false
end
local function PageEntry()
    if Q.loadError and not tree then
        return {title="Quests",subtitle="Missing companion data",text=Q.loadError,empty=true}
    end
    if not selectedID then
        return {title="Quests",subtitle="Azeroth's Compendium",
            text="Select a discovered quest on the left to read its dialogue and replay available recordings.",empty=true}
    end
    local entry=M:Entry(selectedID)
    local title=M:Title(selectedID,true)
    local status=Status(selectedID)
    local place=""
    if entry and type(entry.zones)=="table" and table.getn(entry.zones)>0 then
        local names={}
        for _,zone in ipairs(entry.zones) do table.insert(names,S:MapName(zone)) end
        place=table.concat(names,", ")
    elseif entry and entry.sort then
        place=M:SortName(entry.sort)
    else
        place="Place unknown (Turtle/uncatalogued quest)"
    end
    local chain=""
    if entry and entry.prev then chain="\nPrevious quest ID: "..entry.prev end
    return {title=title,subtitle=place.."  ·  "..status,key="quest:"..selectedID,
        text="",questStatus=status,questChain=chain}
end
function Q:Refresh()
    if not list then return end
    list:Render()
    if page then
        local entry=PageEntry()
        page:Show(entry)
        if details then details:Show(selectedID, entry) end
    end
end
function Q:Select(item)
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
    Q:Refresh()
end
local function Build(panelFrame)
    panel=panelFrame
    EnsureCatalog()
    list=C.NewList(panelFrame,{
        search="Search quests",
        none="No matching quests.",
        only="Discovered Only",
        onlyGet=function() return Settings("foundOnly") end,
        onlySet=function(on) Settings("foundOnly",on) end,
        checks={
            {label="Voiced Only",get=function() return Settings("voicedOnly") end,
                set=function(on) Settings("voicedOnly",on) end},
            {label="Unlock Undiscovered",get=function() return Settings("unlock") end,
                set=function(on) Settings("unlock",on) end},
        },
        build=function() return Q:BuildRows() end,
        isSelected=function(item) return Q:IsSelected(item) end,
        onClick=function(item) Q:Select(item) end,
        onSearch=function(text)
            filter=Lower(string.gsub(string.gsub(text or "","^%s+",""),"%s+$",""))
            searchClosed={}
            Q:Refresh()
        end,
    })
    panelFrame.Refresh=function() Q:Refresh() end
    panelFrame.listInset=list.inset
    -- Use the very same right-page construction as Places and Readables.
    -- The shared prototype skin owns parchment art, geometry and scroll
    -- chrome; Quests supplies only quest-specific content and actions.
    local pageInset
    pageInset, page = C.CreatePagePane(panelFrame, list, function(holder)
        return SSCLorePage.CreateLorePage(holder,"book")
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
if C and C.Register and not C:Tab("quests") then
    C:Register("quests",{
        label="Quests",order=0,title="Azeroth's Compendium",
        build=Build,
        onShow=function() S:ReadLog() end,
        enabled=function() return true end,
    })
end
