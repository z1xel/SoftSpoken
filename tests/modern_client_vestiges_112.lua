-- Vanilla 1.12 regression for removing modern-only portrait and minimap/UI code.
local function read(p)
    local f = assert(io.open(p, "r"))
    local contents = f:read("*a")
    f:close()
    return contents
end
local p = read("SoftSpoken/UI/Portrait.lua")
local m = read("SoftSpoken/UI/MinimapButton.lua")
local o = read("SoftSpoken/UI/Options.lua")
local l = read("SoftSpoken/UI/Layout.lua")
local c = read("SoftSpoken/Core.lua")
local function exists(s, t) assert(s:find(t, 1, true), "missing: " .. t) end
local function absent(s, t) assert(not s:find(t, 1, true), "obsolete: " .. t) end
for _, token in ipairs({"CAN_MODEL_LOAD_CACHE", "GetCurrentModelSet",
    '["HD"]', "IsRetailVanilla", "IsRetailOrAboveLegacyVersion"}) do absent(p, token) end
exists(p, 'Candidate(portrait, "creaturePlayerModel", "PlayerModel")')
exists(p, 'Candidate(portrait, "creatureLegacyModel", "Model")')
exists(p, "CreatureAppearance:Subscribe(OnCreatureAppearance)")
exists(p, 'animationDurations["Original"][119369][60] = 0')
for _, token in ipairs({"MenuUtil", "SettingsDropdownWithButtonsTemplate",
    "WowStyle1DropdownTemplate", "root:CreateRadio"}) do absent(l, token) end
exists(l, 'UIDropDownMenu_Initialize(control')
exists(l, 'return self:Cycle(label .. ": %s"')
for _, token in ipairs({"AddonCompartmentFrame", "ToggleCompartment",
    "showInCompartment", "C_Timer.After(", "GetMinimapButton"}) do absent(m, token) end
absent(o, "AddonCompartmentFrame")
absent(o, "showInCompartment")
absent(c, "showInCompartment")
exists(c, "LibDBIcon = { minimapPos = 204 }")
exists(m, "Minimap:HandleClick(button, mouseButton)")
exists(m, "UIDropDownMenu_Initialize(dropDown")
exists(m, "function Minimap:Refresh()")

-- Use the real minimap module with a minimal 1.12-style data broker.
local opened, compendium, registered, refreshed = 0, 0, 0, 0
local iconDB, launcher = {}, nil
local db = { profile = { Minimap = { LibDBIcon = iconDB,
    Commands = { LeftButton = "Settings", MiddleButton = "Compendium", RightButton = "Menu" } } } }
local icon = {
    Register = function(self, name, object, saved)
        assert(name == "Spoken" and saved == iconDB)
        registered = registered + 1
        launcher = object
    end,
    Refresh = function(self, name, saved)
        assert(name == "Spoken" and saved == iconDB)
        refreshed = refreshed + 1
    end,
    GetMinimapButton = function() error("modern compartment lookup called") end,
}
local broker = { NewDataObject = function(self, name, object)
    assert(name == "Spoken" and object.icon)
    return object
end }
local env = setmetatable({
    L = setmetatable({}, { __index = function(_, key) return key end }),
    Addon = { db = db },
    Sources = { Iterate = function() return function() end end,
        IsTurnedOff = function() return false end },
    SoundQueue = { TogglePauseQueue = function() end,
        RemoveAllSoundsFromQueue = function() end,
        GetCurrentSound = function() return nil end },
    Options = { Open = function() opened = opened + 1 end },
    Spoken = { ToggleCompendium = function() compendium = compendium + 1 end },
    LibStub = function(name)
        if name == "LibDataBroker-1.1" then return broker end
        if name == "LibDBIcon-1.0" then return icon end
    end,
}, { __index = _G })
_G.SpokenEnv = env
assert(loadfile("SoftSpoken/UI/MinimapButton.lua"))()
local minimap = assert(env.Minimap)
minimap:Setup()
assert(registered == 1 and launcher and iconDB.minimapPos == 204,
    "existing LibDBIcon registration/position changed")
minimap:Setup()
assert(registered == 1, "minimap registration no longer idempotent")
launcher.OnClick({}, "LeftButton")
assert(opened == 1, "left click must open Settings")
_G.SSCCompendium = { Available = function() return true end }
launcher.OnClick({}, "MiddleButton")
assert(compendium == 1, "middle click must open Compendium")
minimap:Refresh()
assert(refreshed == 1, "native minimap refresh changed")
local menu = minimap:BuildMenu()
assert(#menu >= 4 and menu[1].id == "PlayPause"
    and menu[2].id == "Stop" and menu[3].id == "Compendium"
    and menu[4].id == "Settings", "native minimap menu items changed")
_G.SSCCompendium = nil
print("PASS: ClassicAPI portrait and native minimap/menu behavior retained")
