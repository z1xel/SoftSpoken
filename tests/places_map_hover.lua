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
    local kind,key,source=compat.ResolveAt(1429,.5,.5)
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

-- Main's static fallback uses the same resolver with no dev dependencies.
SSZLore.subzones[1429]["northshire abbey"].short="Existing lore"
SSZLore.subzones[1429]["northshire valley"].short="Existing lore"
dofile("SoftSpoken_Places/UI/StaticPOI.lua")
local rows={{kind="subzone",id="northshire abbey",x=.5,y=.5,poi=1}}
SSZMapPOIData={[1429]=rows}
zone=1;nativeName="Elwynn Forest";preciseName=nil
local w,h,scale=1000,600,1
WorldMapButton.GetWidth=function() return w end
WorldMapButton.GetHeight=function() return h end
WorldMapButton.GetEffectiveScale=function() return scale end
expect("Northshire Abbey","static-poi","static fallback")
eq(click.HandleClick(.5,.5),true,"static click")
local function method(x,y) local _,_,m=compat.ResolveAt(1429,x,y);return m end
eq(method(.511,.5),"static-poi","11 pixels")
eq(method(.513,.5),nil,"13 pixels")
scale=2;eq(method(.5055,.5),"static-poi","scaled inside");eq(method(.5065,.5),nil,"scaled outside");scale=1
rows[2]={kind="subzone",id="northshire abbey",x=.506,y=.5,poi=2}
eq(method(.503,.5),"static-poi","same target duplicate")
rows[3]={kind="subzone",id="northshire valley",x=.516,y=.5,poi=3}
eq(method(.511,.5),"static-poi-ambiguous","different target tie")
eq(hover.Resolve(.511,.5),nil,"ambiguous hover")
eq(click.HandleClick(.511,.5),false,"ambiguous click")
rows[2]=nil;rows[3]=nil
nativeName="Northshire Valley"
local _,id,source=compat.ResolveAt(1429,.5,.5)
eq(id,"northshire valley","native wins");eq(source,"native","native method")
nativeName="Unmapped Landmark";eq(method(.5,.5),"native-unmapped","unmapped native blocks")
nativeName="Elwynn Forest";preciseName="Unmapped Precise";eq(method(.5,.5),"native-unmapped","unmapped precise blocks")
preciseName="Northshire Valley";eq(method(.5,.5),"precise","precise wins");preciseName=nil
poiName="Unmapped POI";eq(click.HandleClick(.5,.5),false,"native button blocks");poiName=nil
C_Map.GetAreaInfo=function() return "Northshire Valley" end
C_Map.GetMapOverlays=function() return {{areaID=1,hitRect={left=.4,right=.6,top=.4,bottom=.6}}} end
compat.ClearOverlayCache()
eq(method(.5,.5),"overlay","overlay wins")
C_Map.GetMapOverlays=function() return {} end
compat.ClearOverlayCache()
locked=true;eq(hover.Resolve(.5,.5),nil,"locked hover");eq(click.HandleClick(.5,.5),false,"locked click");locked=false
SSZLore.subzones[1429]["northshire abbey"].short=""
eq(method(.5,.5),nil,"empty lore excluded")
SSZLore.subzones[1429]["northshire abbey"].short="Existing lore"
SSZLore.subzones[1429]["northshire abbey"].pending=true
eq(method(.5,.5),nil,"pending excluded")
SSZLore.subzones[1429]["northshire abbey"].pending=nil
click.MouseDown("LeftButton",.48,.5);eq(click.MouseUp("LeftButton",.5,.5),false,"drag")
click.MouseDown("LeftButton",.5,.5);eq(click.MouseUp("LeftButton",.5,.5),true,"stationary click")
SSZCharacter.settings.showMapPanel=false
eq(hover.Resolve(.5,.5),nil,"disabled hover");eq(click.HandleClick(.5,.5),false,"disabled click")
print("PASS: main static fallback precedence, scaling, locks, overlaps and drag")

-- C3: only in-radius valid coordinates may cause a lore lookup.
SSZCharacter.settings.showMapPanel=true
local subs=SSZLore.subzones[1429]
local distantLookups=0
setmetatable(subs,{__index=function(_,key)
    if key=="distant place" then distantLookups=distantLookups+1 end
    return nil
end})
rows[2]={kind="subzone",id="distant place",x=.9,y=.9,poi=2}
rows[3]={kind="subzone",id="distant place",x=-.1,y=.5,poi=3}
rows[4]={kind="subzone",id="distant place",x=0/0,y=.5,poi=4}
rows[5]={kind="subzone",id="distant place",x=math.huge,y=.5,poi=5}
rows[6]={kind="subzone",id="distant place",x="bad",y=.5,poi=6}
rows[7]=false
local _,key,source=SSZStaticPOI.ResolveAt(1429,.5,.5,WorldMapButton)
eq(key,"northshire abbey","valid nearby target")
eq(source,"static-poi","nearby method")
eq(distantLookups,0,"distance and coordinate guards precede lore access")
rows[2].x=.505;rows[2].y=.5
_,key=SSZStaticPOI.ResolveAt(1429,.5,.5,WorldMapButton)
eq(key,"northshire abbey","nearby missing lore cannot replace valid hit")
eq(distantLookups,1,"only nearby valid coordinates consult lore")
for i=2,7 do rows[i]=nil end
setmetatable(subs,nil)

-- C4: actual tooltip, reader and highlight use the same native button
-- identity even when UpdateMapHighlight identifies different ground.
WorldMapDetailFrame={}
dofile("SoftSpoken_Places/UI/MapHighlight.lua")
local highlight=SSZMapHighlight
local valleyArt={areaID=1,hitRect={left=.4,right=.6,top=.4,bottom=.6},
    tiles={{file="Valley1.blp"}}}
local abbeyArt={areaID=2,hitRect={left=.4,right=.6,top=.4,bottom=.6},
    tiles={{file="Abbey1.blp"}}}
local art={valleyArt}
C_Map.GetAreaInfo=function(id) return id==1 and "Northshire Valley" or "Northshire Abbey" end
C_Map.GetMapOverlays=function() return art end
compat.ClearOverlayCache()
nativeName="Northshire Valley";poiName="Northshire Abbey"
expect("Northshire Abbey","poi","native button wins across consumers")
eq(click.HandleClick(.5,.5),true,"reader selects button")
eq(highlight.Target(.5,.5),nil,"button cannot highlight underlying valley")
art={valleyArt,abbeyArt};compat.ClearOverlayCache()
eq(highlight.Target(.5,.5),abbeyArt,"button highlights its own art")
locked=true
eq(hover.Resolve(.5,.5),nil,"button lock hides tooltip")
eq(click.HandleClick(.5,.5),false,"button lock blocks reader")
eq(highlight.Target(.5,.5),nil,"button lock blocks highlight")
locked=false
poiName="Unmapped POI"
eq(hover.Resolve(.5,.5),nil,"unknown button hides tooltip")
eq(click.HandleClick(.5,.5),false,"unknown button blocks reader")
eq(highlight.Target(.5,.5),nil,"unknown button blocks highlight")
-- Explicit event identity is authoritative even if another button is
-- hovered by the time the hooked callback runs.
eq(click.HandleClick(.5,.5,"Northshire Abbey"),true,"explicit native click wins")
local shown,over=false,true
getglobal=function(name)
    if name=="WorldMapFramePOI1" then
        return {name="Northshire Abbey",IsShown=function() return shown end,
            IsMouseOver=function() return over end}
    end
end
eq(hover.Resolve(.5,.5).id,"northshire valley","hidden button ignored")
eq(highlight.Target(.5,.5),valleyArt,"hidden button cannot affect art")
shown=true;over=false
eq(hover.Resolve(.5,.5).id,"northshire valley","nonhovered button ignored")
eq(highlight.Target(.5,.5),valleyArt,"nonhovered button cannot affect art")
print("PASS: distance-first lore checks and common native POI context")

-- C5: each consumer queries the displayed map exactly once during
-- resolution. The real reader intentionally rechecks at selection time.
local display=compat.GetDisplayedMapID
local mapReads=0
compat.GetDisplayedMapID=function() mapReads=mapReads+1;return display() end
local function once(fn,label)
    mapReads=0
    local result=fn()
    eq(mapReads,1,label.." map query count")
    return result
end
nativeName="Northshire Abbey";poiName=nil
eq(once(function() return hover.Resolve(.5,.5).id end,"hover"),"northshire abbey","hover target")
eq(once(function() return click.HandleClick(.5,.5) end,"click"),true,"click target")
eq(once(function() return highlight.Target(.5,.5) end,"highlight"),abbeyArt,"art target")
click.MouseDown("LeftButton",.5,.5)
eq(once(function() return click.MouseUp("LeftButton",.5,.5) end,"mouse up"),true,"stationary click")
click.MouseDown("LeftButton",.5,.5)
mapReads=0
eq(click.MouseUp("LeftButton",.48,.5),false,"drag rejected before lookup")
eq(mapReads,0,"drag no map query")
click.MouseDown("LeftButton",.5,.5)
compat.GetDisplayedMapID=function() mapReads=mapReads+1;return 1420,"Tirisfal Glades",2,1 end
eq(once(function() return click.MouseUp("LeftButton",.5,.5) end,"changed map"),false,"changed map rejected")
eq(once(function() return compat.ResolveAt(1429,.5,.5) end,"explicit stale map"),nil,"stale map rejected")
compat.GetDisplayedMapID=function() mapReads=mapReads+1;return display() end
zone=0
eq(once(function() return hover.Resolve(.5,.5) end,"continent hover"),nil,"continent rejected")
eq(once(function() return click.HandleClick(.5,.5) end,"continent click"),false,"continent rejected")
zone=1
nativeName="Elwynn Forest";preciseName="Northshire Abbey"
local k,id,m,a,mid=compat.ResolveAt(nil,.5,.5)
eq(k,"subzone","precise kind");eq(id,"northshire abbey","precise key")
eq(m,"precise","precise method");eq(mid,1429,"precise result map")
preciseName=nil
art={};compat.ClearOverlayCache()
k,id,m,a,mid=compat.ResolveAt(nil,.5,.5)
eq(m,"static-poi","static method");eq(mid,1429,"static result map")
art={abbeyArt};compat.ClearOverlayCache()
k,id,m,a,mid=compat.ResolveAt(nil,.5,.5)
eq(m,"overlay","overlay method");eq(mid,1429,"overlay result map")
compat.GetDisplayedMapID=display
print("PASS: one displayed-map read per resolution, native names and drag validation")
