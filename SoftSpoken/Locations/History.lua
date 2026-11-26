setfenv(1, SpokenEnv)

-- Character geography schema, independent of the D import ledger.
-- Canonical buckets contain exact context/recording evidence; a shared
-- physical identity never unlocks another independently authored entry.
LocationHistory={}
local H=LocationHistory
local function Copy(v,seen)
    local kind=type(v)
    if kind~="table" then
        assert(kind=="nil" or kind=="boolean" or kind=="string" or
            (kind=="number" and v-v==0),"invalid geography save value")
        return v
    end
    assert(not getmetatable(v),"saved geography metatable")
    seen=seen or {}
    assert(not seen[v],"cyclic geography save")
    seen[v]=true
    local out={}
    for k,value in pairs(v) do
        assert(type(k)=="string" or type(k)=="boolean" or
            (type(k)=="number" and k-k==0),"invalid geography save key")
        out[k]=Copy(value,seen)
    end
    seen[v]=nil
    return out
end
local function Tbl(v)
    if v==nil then return {} end
    assert(type(v)=="table","invalid geography table")
    return v
end
local function Bucket(t,k)
    if not t[k] then t[k]={} end
    return t[k]
end
local function Ready()
    assert(Locations and Locations:IsReady(),"geographical registry unavailable")
    return Locations
end
local function Canonical(id)
    local r=Ready()
    local resolved=r:ResolveCanonical(id)
    if resolved and r:GetAvailability(resolved)~="absent" then return resolved end
end
local function MapID(value)
    if type(value)=="number" then
        return Ready():ResolveContentIdentifier("upstreamUiMap",value,"spoken_classic")
    end
end
local function PlaceID(field,key)
    if type(key)~="string" then return nil end
    local _,_,map,area
    if field=="visited" then
        _,_,map,area=string.find(key,"^(%d+)/(.*)$")
        if not map then _,_,map=string.find(key,"^(%d+)$") end
    else
        _,_,map,area=string.find(key,"^s:(%d+):(.+)$")
        if not map then _,_,map=string.find(key,"^z:(%d+)$") end
    end
    if not map then return nil end
    return Ready():ResolveLegacyPlace(tonumber(map),area)
end
local function SetFlag(t,id,key)
    local set=Bucket(t,id)
    if set[key]==true then return false end
    set[key]=true
    return true
end
local function ValidCount(n)
    return type(n)=="number" and n-n==0 and n>0 and n==math.floor(n)
end

-- Holds keep the exact old key and value, under the original module/field;
-- scope is fixed to spoken_classic legacyPlace/upstreamUiMap in version 1.
function H:Transform(old)
    Ready()
    assert(old.geographyVersion==nil,"unexpected geography migration version")
    local result=Copy(old)
    local p,w=Tbl(result.Places),Tbl(result.Writings)
    result.Places,result.Writings=p,w
    assert(not p.locationHolds and not w.locationHolds,"unexpected pre-migration holds")
    local ph={version=1,visited={},heard={}}
    local wh={version=1,locations={},acquisitions={}}
    p.locationHolds,w.locationHolds=ph,wh
    for _,field in ipairs({"visited","heard"}) do
        local target={}
        for key,v in pairs(Tbl(p[field])) do
            local id=PlaceID(field,key)
            if id and v==true then SetFlag(target,id,key)
            else ph[field][key]=v end
        end
        p[field]=target
    end
    local origins,counters={},{}
    for book,locations in pairs(Tbl(w.locations)) do
        for key,method in pairs(Tbl(locations)) do
            local id=MapID(key)
            if id and type(method)=="string" then
                SetFlag(Bucket(origins,book),id,method)
            else Bucket(wh.locations,book)[key]=method end
        end
    end
    for item,locations in pairs(Tbl(w.acquisitions)) do
        for key,n in pairs(Tbl(locations)) do
            local id=MapID(key)
            if id and ValidCount(n) then
                local dest=Bucket(counters,item)
                dest[id]=(dest[id] or 0)+n
                assert(ValidCount(dest[id]),"acquisition quantity overflow")
            else Bucket(wh.acquisitions,item)[key]=n end
        end
    end
    w.locations,w.acquisitions=origins,counters
    result.geographyVersion=1
    self:Validate(result)
    return result
end
local function CheckSet(set)
    assert(type(set)=="table","invalid geography evidence set")
    for key,value in pairs(set) do
        assert(type(key)=="string" and value==true,"invalid geography evidence")
    end
end
local function CheckID(id)
    assert(type(id)=="string" and string.find(id,"^[a-z][a-z0-9_.]*$"),"invalid canonical location key")
end
function H:Validate(char)
    assert(char.geographyVersion==1,"unsupported geography version")
    local p,w=char.Places,char.Writings
    assert(type(p)=="table" and type(w)=="table","missing geography modules")
    for _,module in ipairs({p,w}) do
        assert(type(module.locationHolds)=="table" and module.locationHolds.version==1,"missing geography holds")
    end
    for _,field in ipairs({"visited","heard"}) do
        assert(type(p[field])=="table" and type(p.locationHolds[field])=="table","invalid Places geography")
        for id,set in pairs(p[field]) do CheckID(id);CheckSet(set) end
    end
    for _,field in ipairs({"locations","acquisitions"}) do
        assert(type(w[field])=="table" and type(w.locationHolds[field])=="table","invalid Writings geography")
        for _,locations in pairs(w[field]) do
            assert(type(locations)=="table","invalid Writings location map")
            for id,value in pairs(locations) do
                CheckID(id)
                if field=="locations" then CheckSet(value)
                else assert(ValidCount(value),"invalid canonical quantity") end
            end
        end
        for _,held in pairs(w.locationHolds[field]) do assert(type(held)=="table","invalid held location map") end
    end
end
function H:Upgrade()
    local old=rawget(_G,"SoftSpokenCharacterDB") or {}
    assert(type(old)=="table","invalid character geography")
    Ready()
    if old.geographyVersion~=nil then
        self:Validate(old)
        return old
    end
    local staged=self:Transform(old)
    -- All conversion and validation happen on detached tables. Commit
    -- history and its independent version with one root assignment.
    Persistence:ValidateCharacterHistory(staged)
    _G.SoftSpokenCharacterDB=staged
    return staged
end

-- Read/write adapters for exact Places context and recording keys.
-- Old fixture/standalone storage is not converted here.
function H:PlaceHas(p,field,key)
    local id=PlaceID(field,key)
    local set=id and p[field][id]
    local held=p.locationHolds[field][key]
    if field=="heard" then return (set and set[key]==true) or held==true end
    return (set and set[key]==true) or not not held
end
function H:PlaceMark(p,field,key)
    local id=PlaceID(field,key)
    if id then return SetFlag(p[field],id,key) end
    local held=p.locationHolds[field]
    if held[key]==true then return false end
    held[key]=true
    return true
end

-- Writings' canonical maps and method sets. Unresolved legacy values
-- remain in the exact original key namespace and can still be displayed.
function H:ResolveWritingsKey(key)
    if type(key)=="number" then return MapID(key) end
    if type(key)=="string" then return Canonical(key) end
end
function H:BookMark(w,book,key,method)
    local id=self:ResolveWritingsKey(key)
    if not id then return false end
    return SetFlag(Bucket(w.locations,book),id,method or "encounter")
end
function H:Acquire(w,item,key,n)
    local id=self:ResolveWritingsKey(key)
    if not id or not ValidCount(n) then return false end
    local dest=Bucket(w.acquisitions,item)
    local total=(dest[id] or 0)+n
    assert(ValidCount(total),"acquisition quantity overflow")
    dest[id]=total
    return true
end
local function Consume(raw,gone)
    if type(raw)~="table" then return gone end
    -- Stable order, rather than hash iteration order, for indistinguishable
    -- copies. Unresolved counters still participate in quantity removal.
    local keys={}
    for key,n in pairs(raw) do if ValidCount(n) then table.insert(keys,key) end end
    table.sort(keys,function(a,b)
        if type(a)~=type(b) then return type(a)<type(b) end
        return tostring(a)<tostring(b)
    end)
    for _,key in ipairs(keys) do
        if gone<=0 then break end
        local used=math.min(gone,raw[key])
        raw[key]=raw[key]-used;gone=gone-used
        if raw[key]==0 then raw[key]=nil end
    end
    return gone
end
function H:Consume(w,item,gone)
    local held=w.locationHolds.acquisitions
    gone=Consume(w.acquisitions[item],gone)
    Consume(held[item],gone)
    if w.acquisitions[item] and not next(w.acquisitions[item]) then w.acquisitions[item]=nil end
    if held[item] and not next(held[item]) then held[item]=nil end
end
