-- Standalone migration contract test; no WoW client or ClassicAPI required.
GetRealmName = function() return "Realm" end
local player = "One"
UnitName = function() return player end
dofile("SoftSpoken/Environment.lua")
dofile("SoftSpoken/Persistence.lua")
dofile("SoftSpoken/Migration.lua")
SpokenPlacesRuntime = {Normalise=function(s) return string.gsub(string.lower(s), "^the ", "") end}
local P = SpokenEnv.Persistence
local core = {profileKeys={["One - Realm"]="Shared",["Two - Realm"]="Other"},
 profiles={Shared={Frame={FrameScale=1.2}},Other={Frame={FrameScale=0.8}},Unused={bad=true}},
 global={Layout={x=42}},char={["Two - Realm"]={IsPaused=true}}}
local story = {profileKeys={["One - Realm"]="A",["Two - Realm"]="B"},
 profiles={A={Audio={Autoplay=false}},B={DebugEnabled=true}},char={["Two - Realm"]={custom=true}}}
local function Import(addon)
 if addon=="SoftSpoken" then return {SpokenSettings=core},{} end
 if addon=="SoftSpoken_Stories" then return {SpokenQuestsSettings=story},{SSCQuestJournal={completed={[1]=true},settings={foundOnly=false},extra=7}} end
 if addon=="SoftSpoken_Places" then return {},{SSZCharacter={settings={holdCombat=true,captions=false},heard={["s:1:The Den"]=true},extra=8}} end
 return {SSBSettings={autoplay=false}},{SSBCharacter={read={[2]=true},extra=9}}
end
assert(not pcall(function() P:RecoverLegacy(function() return nil end) end))
assert(not SoftSpokenDB and not SoftSpokenCharacterDB)
assert(P:RecoverLegacy(Import))
local root, char = SoftSpokenDB, SoftSpokenCharacterDB
local name=root.profileKeys["One - Realm"]
assert(root.profiles[name].Frame.FrameScale==1.2 and not root.profiles[name].Transcript.Enabled)
assert(not root.profiles.Unused and root.global.Layout.x==42)
assert(root.namespaces.Stories.profiles[name].Compendium.foundOnly==false)
assert(root.namespaces.Places.profiles[name].stopCombat==true)
assert(char.Places.heard["s:1:den"] and char.Places.extra==8)
assert(char.Stories.journal.completed[1] and char.Stories.journal.extra==7 and not char.Stories.journal.settings)
assert(char.Writings.found[2] and char.Writings.extra==9)
assert(core.profiles.Shared.Transcript==nil)
assert(P:RecoverLegacy(function() error("must not reimport") end))
assert(SoftSpokenDB==root and SoftSpokenCharacterDB==char)
player="Two"
SoftSpokenCharacterDB=nil
core={} -- old Core file has been replaced
assert(P:RecoverLegacy(Import))
root=SoftSpokenDB
name=root.profileKeys["Two - Realm"]
assert(root.profiles[name].Frame.FrameScale==0.8)
assert(root.char["Two - Realm"].IsPaused)
assert(root.namespaces.Stories.profiles[name].DebugEnabled)
assert(SoftSpokenCharacterDB.Stories.custom)
assert(root.namespaces.Writings.profiles[name].autoplay==false)
assert(root.profiles["One - Realm"].Frame.FrameScale==1.2)
print("PASS: migration, failure isolation, idempotence and second character")
