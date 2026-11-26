setfenv(1, SpokenEnv)

-- Fixed Octo catalog. All indexes are built once; returned records/arrays
-- are shared read-only views. This service owns no UI or saved variables.
local Registry = {}
Registry.__index = Registry
local NATIVE = {areaTable=true, instanceMap=true, nativeUiMap=true, worldMapArea=true}
local CONTENT_SCOPE = "spoken_classic"
local OCTO_SCOPE = "octo_20261126"
local EMPTY = {}
local EXCLUDED = {[2482]=true,[2521]=true,[2524]=true,[2548]=true,[2652]=true}

local function Bucket(t,k)
    local v=t[k]
    if not v then v={}; t[k]=v end
    return v
end

local function Append(t,k,v)
    table.insert(Bucket(t,k),v)
end

local function AddSet(t,k,v)
    Bucket(t,k)[v]=true
end

local function Ordered(set)
    local result={}
    for k in pairs(set or EMPTY) do table.insert(result,k) end
    table.sort(result)
    return result
end

local function Choose(set)
    local ids=Ordered(set)
    local n=table.getn(ids)
    if n==1 then return ids[1],"resolved" end
    if n>1 then return nil,"ambiguous",ids end
    return nil,"unknown"
end

local function Integer(value)
    return type(value)=="number" and value==math.floor(value)
end

-- ASCII case folding only. Do not conflate punctuation, articles, accents
-- or distinct localized names; exact names take precedence.
local function Fold(name)
    name=string.gsub(name,"[A-Z]",string.lower)
    name=string.gsub(name,"%s+"," ")
    name=string.gsub(name,"^%s+","")
    return (string.gsub(name,"%s+$",""))
end

local function MapLess(a,b)
    if a.scope~=b.scope then return a.scope<b.scope end
    if a.namespace~=b.namespace then return a.namespace<b.namespace end
    return a.value<b.value
end

local function IndexNames(self,id,locale,name,preferred)
    if type(name)~="string" or name=="" then return end
    if preferred then AddSet(Bucket(self.exact,locale),name,id) end
    AddSet(Bucket(self.folded,locale),Fold(name),id)
end

local function Bind(index,scope,namespace,value,id)
    local values=Bucket(Bucket(index,scope),namespace)
    assert(not values[value] or values[value]==id,"conflicting geographical binding")
    values[value]=id
end

local function MapIndex(index,scope,namespace,value)
    return ((index[scope] or EMPTY)[namespace] or EMPTY)[value]
end

local function CheckRef(self,scope,namespace,value)
    if not self.ready then return false end
    if NATIVE[namespace] then return scope==self.scope end
    return namespace=="upstreamUiMap" and scope==CONTENT_SCOPE
end

local function AddMap(self,id,row,owned)
    local key=row.scope..":"..row.namespace..":"..row.value
    local refs=Bucket(self.mapSets,id)
    local existing=refs[key]
    if existing then
        if owned then existing.owned=true else existing.covered=true end
    else
        refs[key]={scope=row.scope,namespace=row.namespace,value=row.value,
                   subject=row.subject,owned=owned,covered=not owned}
    end
end

local function Build(data,content)
    local self=setmetatable({ready=false,scope=OCTO_SCOPE},Registry)
    if data==nil and content==nil then return self end
    assert(type(data)=="table" and data.schemaVersion==1 and data.world=="octo"
        and data.scope==OCTO_SCOPE and type(data.view)=="table" and type(content)=="table",
        "invalid fixed Octo geographical data")
    local view=data.view
    self.entities=assert(view.entities)
    self.redirects=data.redirects or {}
    self.splits=data.splits or {}
    self.availability=view.availability or {}
    self.bindings={}; self.representations={}; self.identifiers={}; self.children={}
    self.relations={}; self.exact={}; self.folded={}; self.mapSets={}; self.maps={}
    self.content={}; self.legacy={}; self.contentByLocation={}
    for id,e in pairs(self.entities) do
        assert(type(e.name)=="string" and type(e.kind)=="string","invalid entity")
        if e.parent then
            assert(self.entities[e.parent] and e.parent~=id,"invalid parent")
            Append(self.children,e.parent,id)
        end
        IndexNames(self,id,"enUS",e.name,true)
        for locale,name in pairs(e.names or EMPTY) do IndexNames(self,id,locale,name,true) end
        for locale,names in pairs(e.aliases or EMPTY) do
            for _,name in ipairs(names) do IndexNames(self,id,locale,name,false) end
        end
    end
    for _,ids in pairs(self.children) do table.sort(ids) end
    for _,r in ipairs(view.bindings or EMPTY) do
        assert(self.entities[r.location] and Integer(r.value),"invalid geographical binding")
        assert((NATIVE[r.namespace] and r.scope==self.scope) or
            (r.namespace=="upstreamUiMap" and r.scope==CONTENT_SCOPE and not EXCLUDED[r.value]),
            "invalid binding scope")
        Bind(self.bindings,r.scope,r.namespace,r.value,r.location)
        Append(self.identifiers,r.location,r)
    end
    for _,list in pairs(self.identifiers) do table.sort(list,MapLess) end
    for _,r in ipairs(view.relations or EMPTY) do
        assert(self.entities[r.from] and self.entities[r.to] and r.from~=r.to,"invalid relation")
        assert(r.relation=="within" or r.relation=="associatedWith" or r.relation=="entranceIn","invalid relation type")
        AddSet(Bucket(self.relations,r.from),r.relation,r.to)
        if r.relation=="associatedWith" then AddSet(Bucket(self.relations,r.to),r.relation,r.from) end
    end
    for _,kinds in pairs(self.relations) do
        for kind,set in pairs(kinds) do kinds[kind]=Ordered(set) end
    end
    -- Detect invalid containment at initialization, not on each query.
    local seen,visiting={},{}
    local function Visit(id)
        assert(not visiting[id],"geographical containment cycle")
        if seen[id] then return end
        visiting[id]=true
        local e=self.entities[id]
        if e.parent then Visit(e.parent) end
        for _,parent in ipairs((self.relations[id] or EMPTY).within or EMPTY) do Visit(parent) end
        visiting[id]=nil; seen[id]=true
    end
    for id in pairs(self.entities) do Visit(id) end
    for _,r in ipairs(view.mapRepresentations or EMPTY) do
        assert(self.entities[r.subject] and Integer(r.value),"invalid map subject")
        assert(r.scope==self.scope or r.scope==CONTENT_SCOPE,"invalid map scope")
        local values=Bucket(Bucket(self.representations,r.scope),r.namespace)
        assert(not values[r.value],"duplicate map representation")
        values[r.value]=r
        AddMap(self,r.subject,r,true)
    end
    for _,r in ipairs(view.mapCoverage or EMPTY) do
        local m=r.map
        local rep=MapIndex(self.representations,m.scope,m.namespace,m.value)
        assert(self.entities[r.location] and rep,"invalid map coverage")
        AddMap(self,r.location,rep,false)
    end
    for id,set in pairs(self.mapSets) do
        local list={}
        for _,r in pairs(set) do table.insert(list,r) end
        table.sort(list,MapLess); self.maps[id]=list
    end
    self.mapSets=nil
    -- Exact content keys only. Never treat Tortoise snapshot or upstream
    -- instance IDs as native Octo IDs, even if the number happens to match.
    for _,r in ipairs(content) do
        assert(self.entities[r.location] and Integer(r.value),"invalid content target")
        assert(not (r.sourceScope==CONTENT_SCOPE and EXCLUDED[r.value] and
               (r.namespace=="legacyPlace" or r.namespace=="upstreamUiMap")),"excluded content")
        if r.namespace=="legacyPlace" then
            assert(r.sourceScope==CONTENT_SCOPE and type(r.area)=="string","invalid legacy key")
            local values=Bucket(self.legacy,r.value)
            assert(not values[r.area] or values[r.area]==r.location,"conflicting legacy key")
            values[r.area]=r.location
        else
            assert(r.area==nil,"unexpected content area key")
            Bind(self.content,r.sourceScope,r.namespace,r.value,r.location)
        end
        Append(self.contentByLocation,r.location,r)
    end
    for _,list in pairs(self.contentByLocation) do
        table.sort(list,function(a,b)
            if a.sourceScope~=b.sourceScope then return a.sourceScope<b.sourceScope end
            if a.namespace~=b.namespace then return a.namespace<b.namespace end
            if a.value~=b.value then return a.value<b.value end
            return (a.area or "")<(b.area or "")
        end)
    end
    self.ready=true
    return self
end

function Registry:IsReady() return self.ready end
function Registry:GetError() return self.error end

function Registry:ResolveCanonical(id)
    if not self.ready then return nil,"unavailable" end
    if type(id)~="string" then return nil,"unknown" end
    local seen={}
    while self.redirects[id] do
        if seen[id] then return nil,"unknown" end
        seen[id]=true; id=self.redirects[id]
    end
    if self.entities[id] then return id,"resolved" end
    if self.splits[id] then
        -- A retired split is not automatically resolvable, even with one survivor.
        local candidates={}
        for _,candidate in ipairs(self.splits[id]) do
            local resolved=self:Get(candidate)
            if resolved then candidates[candidate]=true end
        end
        return nil,"ambiguous",Ordered(candidates)
    end
    return nil,"unknown"
end

function Registry:Get(id)
    if not self.ready then return nil end
    -- Follow redirects but never resolve a split or recurse through it.
    local seen={}
    while type(id)=="string" and self.redirects[id] do
        if seen[id] then return nil end
        seen[id]=true; id=self.redirects[id]
    end
    return self.entities[id]
end

function Registry:GetAvailability(id)
    local canonical=self:ResolveCanonical(id)
    if not canonical then return "unknown" end
    return self.availability[canonical] or "unknown"
end

local function Live(self,id)
    if not id then return nil,"unknown" end
    if self.availability[id]=="absent" then return nil,"unavailable" end
    return id,"resolved"
end

function Registry:ResolveIdentifier(namespace,value,scope)
    if not self.ready then return nil,"unavailable" end
    if not scope then scope=namespace=="upstreamUiMap" and CONTENT_SCOPE or self.scope end
    if not CheckRef(self,scope,namespace,value) then return nil,"unavailable" end
    if not Integer(value) then return nil,"unknown" end
    if namespace=="worldMapArea" then
        local row=MapIndex(self.representations,scope,namespace,value)
        return Live(self,row and row.subject)
    end
    return Live(self,MapIndex(self.bindings,scope,namespace,value))
end

function Registry:ByAreaID(value,scope) return self:ResolveIdentifier("areaTable",value,scope) end
function Registry:ByUiMapID(value) return self:ResolveIdentifier("upstreamUiMap",value,CONTENT_SCOPE) end
function Registry:ByNativeMapID(value,scope) return self:ResolveIdentifier("nativeUiMap",value,scope) end
function Registry:ByInstanceMapID(value,scope) return self:ResolveIdentifier("instanceMap",value,scope) end
function Registry:ByWorldMapAreaID(value,scope) return self:ResolveIdentifier("worldMapArea",value,scope) end

function Registry:ResolveContentIdentifier(namespace,value,scope,area)
    if not self.ready then return nil,"unavailable" end
    if not Integer(value) then return nil,"unknown" end
    if namespace=="legacyPlace" then
        if scope and scope~=CONTENT_SCOPE then return nil,"unavailable" end
        if EXCLUDED[value] then return nil,"unavailable" end
        if area==nil then area="" end
        if type(area)~="string" then return nil,"unknown" end
        return Live(self,(self.legacy[value] or EMPTY)[area])
    end
    if type(scope)~="string" or not self.content[scope] then return nil,"unavailable" end
    if namespace=="upstreamUiMap" and scope==CONTENT_SCOPE and EXCLUDED[value] then return nil,"unavailable" end
    return Live(self,MapIndex(self.content,scope,namespace,value))
end

function Registry:ResolveLegacyPlace(mapID,areaKey)
    return self:ResolveContentIdentifier("legacyPlace",mapID,CONTENT_SCOPE,areaKey)
end

function Registry:GetContentBindings(id)
    id=self:ResolveCanonical(id)
    return id and self.contentByLocation[id] or EMPTY
end

function Registry:GetIdentifiers(id)
    id=self:ResolveCanonical(id)
    return id and self.identifiers[id] or EMPTY
end

function Registry:GetParent(id)
    local entity=self:Get(id)
    return entity and entity.parent
end

function Registry:GetChildren(id)
    id=self:ResolveCanonical(id)
    return id and self.children[id] or EMPTY
end

function Registry:GetAncestors(id)
    local result={}
    local parent=self:GetParent(id)
    while parent do
        table.insert(result,parent); parent=self:GetParent(parent)
    end
    return result
end

function Registry:GetRelations(id,relation)
    id=self:ResolveCanonical(id)
    return id and (self.relations[id] or EMPTY)[relation] or EMPTY
end

function Registry:GetMaps(id)
    id=self:ResolveCanonical(id)
    return id and self.maps[id] or EMPTY
end

function Registry:GetMapSubject(namespace,value,scope)
    if not self.ready then return nil,"unavailable" end
    scope=scope or self.scope
    if scope~=self.scope and scope~=CONTENT_SCOPE then return nil,"unavailable" end
    if not Integer(value) then return nil,"unknown" end
    local row=MapIndex(self.representations,scope,namespace,value)
    return Live(self,row and row.subject)
end

function Registry:GetName(id,locale)
    local e=self:Get(id)
    if not e then return nil end
    return (locale and e.names and e.names[locale]) or e.name
end

-- Containment context uses primary and explicit within edges only.
-- Associations/entrances and map artwork do not prove physical containment.
function Registry:IsWithin(id,parent)
    id=self:ResolveCanonical(id); parent=self:ResolveCanonical(parent)
    if not id or not parent or id==parent then return false end
    local seen={}
    local function Walk(key)
        if key==parent then return true end
        if seen[key] then return false end
        seen[key]=true
        local p=self.entities[key].parent
        if p and Walk(p) then return true end
        for _,v in ipairs((self.relations[key] or EMPTY).within or EMPTY) do
            if Walk(v) then return true end
        end
        return false
    end
    return Walk(id)
end

function Registry:ResolveName(name,context)
    if not self.ready then return nil,"unavailable" end
    if type(name)~="string" or Fold(name)=="" then return nil,"unknown" end
    context=context or EMPTY
    if context.scope and context.scope~=self.scope and context.scope~=CONTENT_SCOPE then return nil,"unavailable" end
    local parent=context.parent and self:ResolveCanonical(context.parent)
    if context.parent and not parent then return nil,"unknown" end
    local map=context.map
    local mapScope=map and (map.scope or self.scope)
    if map and mapScope~=self.scope and mapScope~=CONTENT_SCOPE then return nil,"unavailable" end
    local function Filter(set)
        local result={}
        for id in pairs(set or EMPTY) do
            local entity=self.entities[id]
            local matches=self.availability[id]~="absent" and (not context.kind or entity.kind==context.kind)
            if matches and parent then matches=self:IsWithin(id,parent) end
            if matches and context.instanceMapID then
                local instance=self:ByInstanceMapID(context.instanceMapID)
                matches=instance and (instance==id or self:IsWithin(id,instance))
            end
            if matches and map then
                matches=false
                for _,ref in ipairs(self:GetMaps(id)) do
                    if ref.scope==mapScope and ref.namespace==map.namespace and ref.value==map.value then
                        matches=true; break
                    end
                end
            end
            if matches then result[id]=true end
        end
        return result
    end
    local locale=context.locale or "enUS"
    local key=Fold(name)
    -- Requested locale first, then English fallback. Exact preferred
    -- spelling before folded preferred/alias lookup in each locale.
    local sets={Filter((self.exact[locale] or EMPTY)[name]),
                Filter((self.folded[locale] or EMPTY)[key])}
    if locale~="enUS" then
        table.insert(sets,Filter((self.exact.enUS or EMPTY)[name]))
        table.insert(sets,Filter((self.folded.enUS or EMPTY)[key]))
    end
    for _,set in ipairs(sets) do
        if next(set) then return Choose(set) end
    end
    return nil,"unknown"
end

-- ClassicAPI v1.23.9 returns the engine's native zone-level AreaTable ID,
-- despite the modern-looking API name. Never query or change map zoom.
function Registry:ResolvePlayerZone()
    if not self.ready then return nil,"unavailable" end
    if C_Map and type(C_Map.GetBestMapForUnit)=="function" then
        local ok,area=pcall(C_Map.GetBestMapForUnit,"player")
        if ok and Integer(area) and area>0 then return self:ByAreaID(area) end
    end
    if type(GetRealZoneText)=="function" then
        return self:ResolveName(GetRealZoneText(),{locale=type(GetLocale)=="function" and GetLocale() or "enUS"})
    end
    return nil,"unavailable"
end

function Registry:ResolvePlayerLocation()
    local zone,status,candidates=self:ResolvePlayerZone()
    if not zone then return nil,status,candidates end
    if type(GetSubZoneText)~="function" then return zone,"resolved" end
    local sub=GetSubZoneText()
    if type(sub)~="string" or Fold(sub)=="" then return zone,"resolved" end
    local locale=type(GetLocale)=="function" and GetLocale() or "enUS"
    if Fold(sub)==Fold(self:GetName(zone,locale)) then return zone,"resolved" end
    return self:ResolveName(sub,{parent=zone,locale=locale})
end

-- Missing or invalid generated data must not interrupt existing modules.
-- No public API additions; keep the service inside SpokenEnv.
local ok,result=pcall(Build,SoftSpokenLocationData,SoftSpokenLocationContentBindings)
if ok then Locations=result
else Locations=setmetatable({ready=false,scope=OCTO_SCOPE,error=tostring(result)},Registry) end
-- The indexes retain the data they need. Do not keep duplicate global entry points.
SoftSpokenLocationData=nil
SoftSpokenLocationContentBindings=nil
