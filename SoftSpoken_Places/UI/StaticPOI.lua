-- Octo static Places POIs: math only, no frames, no map artwork.
-- Only MapCompat may use this fallback, after authoritative native hits.
SSZStaticPOI = SSZStaticPOI or {}
local POI = SSZStaticPOI
local RADIUS_PX = 12
local AMBIGUITY_PX = 2

local function Finite(n)
    return type(n)=="number" and n==n and n-n==0
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
local function HasLore(entry)
    return type(entry)=="table" and not entry.pending and
        ((type(entry.short)=="string" and string.find(entry.short,"%S")) or
         (type(entry.full)=="string" and string.find(entry.full,"%S")))
end

local function ValidTarget(mapID,row)
    local lore=SSZLore
    if not (lore and lore.zones and lore.zones[mapID]) then return false end
    if row.kind=="subzone" and type(row.id)=="string" then
        return HasLore(lore.subzones and lore.subzones[mapID] and lore.subzones[mapID][row.id])
    end
    if row.kind=="city" and type(row.id)=="number" then
        local parents=SpokenCompendium and SpokenCompendium.CITY_IN
        return parents and parents[row.id]==mapID and HasLore(lore.zones[row.id])
    end
    return false
end

function POI.ResolveAt(mapID,x,y,button)
    if not (Finite(x) and Finite(y)) or x<0 or x>1 or y<0 or y>1 then return nil end
    local settings=SSZCharacter and SSZCharacter.settings
    if settings and settings.showMapPanel==false then return nil end
    local rows=SSZMapPOIData and SSZMapPOIData[mapID]
    if not rows then return nil end
    local w,h=Dimensions(button or WorldMapButton)
    if not w then return nil end
    local bestByTarget={}
    for _,row in ipairs(rows) do
        if type(row)=="table" and Finite(row.x) and Finite(row.y) and
                row.x>=0 and row.x<=1 and row.y>=0 and row.y<=1 then
            local dx,dy=(x-row.x)*w,(y-row.y)*h
            local d2=dx*dx+dy*dy
            if d2<=RADIUS_PX*RADIUS_PX and ValidTarget(mapID,row) then
                -- Same contextual target at several positions is one candidate.
                -- Distinct content keys are never collapsed.
                local key=row.kind.."|"..tostring(row.id)
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
