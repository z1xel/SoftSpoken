-- Real Compendium, without any frames: all open paths must refuse to
-- construct UI until the unified persistence has been initialized.
SpokenEnv = { Persistence = {} }
SSCUI = {}
CreateFrame = function() error("UI constructed before persistence") end
dofile("SoftSpoken/Compendium/UI/Compendium.lua")
local c = SpokenCompendium
local checked, opened = 0, 0
c:Register("places", {
    enabled = function() checked = checked + 1; return true end,
    open = function() opened = opened + 1 end,
    store = {get = function() error("legacy layout read before persistence") end},
})
assert(not c:Available())
assert(c:Window() == nil)
assert(c:Select("places") == nil)
assert(c:Open("places") == nil)
assert(c:Open(1429, "goldshire") == nil)
c:Toggle()
assert(checked == 0 and opened == 0)
SpokenEnv.Persistence.root = {}
assert(not c:Available(), "root alone is not sufficient")
SpokenEnv.Persistence.character = {Places={heard={},visited={}}}
assert(c:Available(), "ready persistence must restore normal availability")
c:Toggle()
assert(opened == 1)
print("PASS: Compendium refuses pre-persistence opens without fake character data")
