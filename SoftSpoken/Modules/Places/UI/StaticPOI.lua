-- Octo static Places POIs: math only, no frames, no map artwork.
-- Only MapCompat may use this fallback, after authoritative native hits.
SSZStaticPOI = SSZStaticPOI or {}
local POI = SSZStaticPOI
local R = SpokenPlacesRuntime
local RADIUS_PX = 12
local AMBIGUITY_PX = 2

local function Finite(n)
    return type(n)=="number" and n==n and n>-math.huge and n<math.huge
end

-- Same physical-pixel coordinate space as SubzoneClick.Position.
local function Dimensions(button)
    if not (button and button.GetWidth and button.GetHeight and button.GetEffectiveScale) then return nil end
    local w,h,s=button:GetWidth(),button:GetHeight(),button:GetEffectiveScale()
    if not (Finite(w) and Finite(h) and Finite(s)) or w<=0 or h<=0 or s<=0 then return nil end
    w,h=w*s,h*s
    if not (Finite(w) and Finite(h)) then return nil end
    return w,h
end

-- No discovery eligibility here: hover and reader apply the same lock
-- AFTER geometry selection, so a locked target cannot reveal a neighbor.
local function ValidTarget(registry,mapID,row)
    if type(row)~="table" or type(row.location)~="string" or not registry:Get(row.location) then return false end
    if not (Finite(row.x) and Finite(row.y)) or row.x<0 or row.x>1 or row.y<0 or row.y>1 then return false end
    local lore=SSZLore
    if not lore then return false end
    if row.kind=="subzone" and type(row.id)=="string" then
        local entry=lore.subzones and lore.subzones[mapID] and lore.subzones[mapID][row.id]
        return entry and registry:ResolveLegacyPlace(mapID,row.id)==row.location
    end
    if row.kind=="city" and type(row.id)=="number" then
        local parents=R.CityParents()
        return parents and parents[row.id]==mapID and lore.zones and lore.zones[row.id]
            and registry:ResolveLegacyPlace(row.id,"")==row.location
    end
    return false
end

function POI.ResolveAt(mapID,x,y,button)
    if not (Finite(x) and Finite(y)) or x<0 or x>1 or y<0 or y>1 then return nil end
    if Spoken and Spoken.IsPartOn and not Spoken:IsPartOn("zones") then return nil end
    local registry=R and R.Registry()
    if not registry or registry.scope~="octo_20261126" or not R.IsMapSupported(mapID) then return nil end
    local data=SpokenEnv and SpokenEnv.SSZMapPOIData
    local rows=data and data[mapID]
    if not rows then return nil end
    local w,h=Dimensions(button or WorldMapButton)
    if not w then return nil end
    local bestByTarget={}
    for _,row in ipairs(rows) do
        if ValidTarget(registry,mapID,row) then
            local dx,dy=(x-row.x)*w,(y-row.y)*h
            local d2=dx*dx+dy*dy
            if d2<=RADIUS_PX*RADIUS_PX then
                -- Same contextual target at several positions is one candidate.
                -- Distinct content keys are not collapsed even if identities match.
                local key=row.kind.."|"..tostring(row.id).."|"..row.location
                local prev=bestByTarget[key]
                if not prev or d2<prev.d2 then bestByTarget[key]={row=row,d2=d2} end
            end
        end
    end
    local first,second
    for _,hit in pairs(bestByTarget) do
        if not first or hit.d2<first.d2 then second=first; first=hit
        elseif not second or hit.d2<second.d2 then second=hit end
    end
    if not first then return nil end
    if second and math.sqrt(second.d2)-math.sqrt(first.d2)<=AMBIGUITY_PX then
        return nil,nil,"static-poi-ambiguous"
    end
    return first.row.kind,first.row.id,"static-poi"
end
