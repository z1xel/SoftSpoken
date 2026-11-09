-- Run from repository root: lua5.1 tests/minimap_position_persistence.lua
-- Exercise the real minimap adapter against a LibDBIcon mock. Confirm drag
-- completion saves a stable angle, login restores it, and profile Refresh
-- reinstalls the drag observer without replacing LibDBIcon movement.
local function eq(a,b,label)
    assert(a==b,(label or "value")..": expected "..tostring(b)..", got "..tostring(a))
end
local function Session(globalState,profileState)
    local db={
        global=globalState or {},
        profile={Minimap={LibDBIcon=profileState or {}}},
    }
    local stops=0
    local function OriginalDrag() stops=stops+1 end
    local button={scripts={OnDragStop=OriginalDrag}}
    function button:SetScript(kind,fn) self.scripts[kind]=fn end
    function button:GetScript(kind) return self.scripts[kind] end
    local lib={}
    function lib:Register(_,_,iconDb) button.db=iconDb end
    function lib:GetMinimapButton() return button end
    function lib:Refresh(_,iconDb)
        button.db=iconDb
        -- LibDBIcon replaces scripts when the profile's lock state changes.
        button:SetScript("OnDragStop",iconDb.lock and nil or OriginalDrag)
    end
    local broker={NewDataObject=function(_,name,object) return object end}
    LibStub=function(which)
        if which=="LibDBIcon-1.0" then return lib end
        if which=="LibDataBroker-1.1" then return broker end
    end
    SpokenEnv=setmetatable({
        Addon={db=db},
        L={STOP_REPLAY="Pause",MIN_STOP_ALL="Stop",
            OPT_COMPENDIUM_OPEN="Compendium",SETTINGS="Settings"},
    },{__index=_G})
    dofile("SoftSpoken/UI/MinimapButton.lua")
    return SpokenEnv.Minimap,db,button,function() return stops end
end

-- An old profile without a position still starts at the existing 204 default.
local mm,db,button,stops=Session()
mm:Setup()
eq(db.profile.Minimap.LibDBIcon.minimapPos,204,"first-login default")
eq(db.global.MinimapPosition,nil,"default does not pollute saved global position")
button.db.minimapPos=73.5
button.scripts.OnDragStop()
eq(stops(),1,"library drag-stop script still executes")
eq(db.profile.Minimap.LibDBIcon.minimapPos,73.5,"profile saves final position")
eq(db.global.MinimapPosition,73.5,"account-wide fallback saves final position")

-- A profile switch should retain the user's minimap location.
db.profile.Minimap.LibDBIcon={}
mm:Refresh()
eq(db.profile.Minimap.LibDBIcon.minimapPos,73.5,"profile switch restores saved position")
button.db.minimapPos=119
button.scripts.OnDragStop()
eq(stops(),2,"refreshed LibDBIcon movement handler still works")
eq(db.global.MinimapPosition,119,"drag hook restored after Refresh")

-- Locking must not accidentally make a locked minimap icon draggable.
db.profile.Minimap.LibDBIcon.lock=true
mm:Refresh()
eq(button.scripts.OnDragStop,nil,"locked button remains locked")
db.profile.Minimap.LibDBIcon.lock=false
mm:Refresh()
assert(button.scripts.OnDragStop,"unlock restores drag observer")

-- Simulate a second login with a clean runtime and a different profile.
local mm2,db2,button2,stops2=Session(db.global,{})
mm2:Setup()
eq(db2.profile.Minimap.LibDBIcon.minimapPos,119,"new login restores angle")
button2.db.minimapPos=265
button2.scripts.OnDragStop()
eq(stops2(),1,"new session drag still works")
eq(db2.global.MinimapPosition,265,"new position overwrites saved angle")
print("PASS: minimap drag position persists, restores, and survives profile refresh")
