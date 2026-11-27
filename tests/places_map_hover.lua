-- M2: actual MapCompat and MapHover, with no native overlay artwork.
-- Synthetic client API responses; does not claim to reproduce a live client hit.
local function eq(actual,expected,label)
    assert(actual==expected,label..": expected "..tostring(expected)..", got "..tostring(actual))
end

local nativeName, visibleName, preciseName, poiName
local locked, zone, mapVisible, overPanel = false, 1, true, false
local overlayCalls, clicks = 0, 0
SSZLore={
    zones={[1429]={name="Elwynn Forest"}},
    subzones={[1429]={
        ["northshire abbey"]={name="Northshire Abbey"},
        ["northshire valley"]={name="Northshire Valley"},
    }},
}
SpokenCompendium={CITY_IN={}}
SSZLoreWindow={IsLocked=function(id,key)
    eq(id,1429,"lock map")
    assert(SSZLore.subzones[id][key],"lock target is real lore")
    return locked
end}
SSZCharacter={settings={showMapPanel=true}}
WorldMapFrame={IsShown=function() return mapVisible end}
WorldMapButton={}
WorldMapFrameAreaLabel={GetText=function() return visibleName end}
GetCurrentMapContinent=function() return 2 end
GetCurrentMapZone=function() return zone end
GetMapZones=function() return "Elwynn Forest" end
GetMapInfo=function() return "Elwynn" end
UpdateMapHighlight=function() return nativeName end
MapUtil={FindBestAreaNameAtMouse=function() return preciseName end}
C_Map={GetMapOverlays=function() overlayCalls=overlayCalls+1;return {} end}
GetNumMapLandmarks=function() return poiName and 1 or 0 end
getglobal=function(name)
    if name=="WorldMapFramePOI1" and poiName then
        return {name=poiName,IsShown=function() return true end,IsMouseOver=function() return true end}
    end
end
CreateFrame=function() return {SetScript=function() end} end
SSZMapPanel={
    GetPanel=function() return {IsShown=function() return true end,IsMouseOver=function() return overPanel end} end,
    SelectSubzone=function(id,key)
        eq(id,1429,"click map")
        eq(key,"northshire abbey","click target")
        clicks=clicks+1
        return not SSZLoreWindow.IsLocked(id,key)
    end,
}
SpokenPlacesBridge={
    IsFound=function() error("hover should use reader eligibility") end,
    MarkFound=function() error("hover must not write discovery") end,
}

dofile("SoftSpoken_Places/UI/MapCompat.lua")
dofile("SoftSpoken_Places/UI/SubzoneClick.lua")
dofile("SoftSpoken_Places/UI/MapHover.lua")
local compat,hover,click=SSZMapCompat,SSZMapHover,SSZSubzoneClick
local function expect(name,method,label)
    local kind,key,source=compat.ResolveAt(1429,.5,.5,hover.HoveredPOI())
    eq(kind,"subzone",label.." kind")
    eq(key,"northshire abbey",label.." key")
    eq(source,method,label.." method")
    local item=assert(hover.Resolve(.5,.5),label.." tooltip target missing")
    eq(item.name,name,label.." tooltip title")
    eq(item.parent,"Elwynn Forest",label.." tooltip parent")
end

-- Native names and confirmed visible titles require no overlay APIs.
nativeName="Northshire Abbey"
C_Map=nil
expect("Northshire Abbey","native","native name without ClassicAPI map art")
visibleName="Northshire Abbey"
WorldMapFrame.areaName=visibleName
nativeName="Northshire Valley"
expect("Northshire Abbey","visible-title","confirmed specific title above broader region")
visibleName=nil; WorldMapFrame.areaName=nil
nativeName="Northshire Valley"
poiName="Northshire Abbey"
expect("Northshire Abbey","poi","POI without artwork")
poiName=nil
nativeName="Elwynn Forest"; preciseName="Northshire Abbey"
expect("Northshire Abbey","precise","precise name fallback without artwork")

-- A known name wins even when nearby artwork is unavailable.
C_Map={GetMapOverlays=function() overlayCalls=overlayCalls+1;return {} end}
nativeName="Northshire Abbey"; preciseName=nil
expect("Northshire Abbey","native","native name with empty overlay list")
eq(overlayCalls,0,"named resolution must not request overlays")
eq(compat.AreaAt(1429,.5,.5,"northshire abbey"),nil,"no matching highlight artwork")
eq(overlayCalls,1,"art lookup is independent")
eq(click.HandleClick(.5,.5),true,"same native name is clickable")
eq(clicks,1,"only explicit click selects the reader")

-- Reject stale unconfirmed labels and distinct unmapped names.
visibleName="Northshire Abbey"; WorldMapFrame.areaName="Elwynn Forest"
nativeName="Northshire Valley"
local item=assert(hover.Resolve(.5,.5))
eq(item.id,"northshire valley","stale unconfirmed label must not win")
nativeName="Unmapped Landmark"
local kind,key,method=compat.ResolveAt(1429,.5,.5)
eq(kind,nil,"unmapped native location")
eq(method,"native-unmapped","do not substitute neighboring artwork")
eq(hover.Resolve(.5,.5),nil,"unmapped native tooltip")
poiName="Unmapped POI"; nativeName="Northshire Abbey"
eq(hover.Resolve(.5,.5),nil,"unmapped POI must not select underlying location")
poiName=nil; visibleName=nil; WorldMapFrame.areaName=nil
locked=true
eq(hover.Resolve(.5,.5),nil,"reader lock blocks tooltip")
locked=false
expect("Northshire Abbey","native","reader unlock permits tooltip")
overPanel=true
eq(hover.Resolve(.5,.5),nil,"hover over reader")
overPanel=false; zone=0
eq(hover.Resolve(.5,.5),nil,"continent map")
eq(clicks,1,"hover never selects reader")
print("PASS: named map locations resolve for hover and click independently of overlay artwork")
