-- Standalone migration contract test; no WoW client or ClassicAPI required.
GetRealmName = function() return "Realm" end
local player = "One"
UnitName = function() return player end
dofile("SoftSpoken/Environment.lua")
dofile("SoftSpoken/Persistence.lua")
dofile("SoftSpoken/Migration.lua")
SpokenPlacesRuntime = {Normalise=function(s) return string.gsub(string.lower(s), "^the ", "") end}
local P = SpokenEnv.Persistence
-- Representative schemas for the isolated migration test; production uses
-- the actual Core/Stories defaults, not a second hand-maintained schema.
SpokenEnv.Defaults = {profile = {Frame = {FrameScale=0.7}, Audio = {LowerOthers={Enabled=true}},
 Transcript={Enabled=true}, Parts={}}, char={IsPaused=false}}
VoiceOver = {StoriesProfileDefaults={Audio={Autoplay=true,DisabledVoicePacks={}},DebugEnabled=false}}
local core = {profileKeys={["One - Realm"]="Shared",["Two - Realm"]="Other"},
 profiles={Shared={Frame={FrameScale=1.2}},Other={Frame={FrameScale=0.8}},Unused={bad=true}},
 global={Layout={Narrator={left=42}}},char={["Two - Realm"]={IsPaused=true}}}
local story = {profileKeys={["One - Realm"]="A",["Two - Realm"]="B"},
 profiles={A={Audio={Autoplay=false}},B={DebugEnabled=true}},char={["Two - Realm"]={custom=true}}}
local function Import(addon)
 if addon=="SoftSpoken" then return {SpokenSettings=core},{} end
 if addon=="SoftSpoken_Stories" then return {SpokenQuestsSettings=story},{SSCQuestJournal={completed={[1]=true},settings={foundOnly=false},extra=7}} end
 if addon=="SoftSpoken_Places" then return {},{SSZCharacter={settings={holdCombat=true,captions=false},heard={["s:1:The Den"]=true},extra=8}} end
 return {SSBSettings={autoplay=false}},{SSBCharacter={read={[2]=true},extra=9}}
end
-- Missing native API or a later read failure must leave the old Core value
-- intact and must not publish unified data.
SpokenSettings=core
assert(not pcall(function() P:RecoverLegacy() end))
assert(not SoftSpokenDB and not SoftSpokenCharacterDB and SpokenSettings==core)
assert(not pcall(function() P:RecoverLegacy(function() return nil end) end))
assert(not SoftSpokenDB and not SoftSpokenCharacterDB and SpokenSettings==core)
assert(not pcall(function()
 P:RecoverLegacy(function(addon)
  if addon=="SoftSpoken_Stories" then error("unreadable legacy file") end
  return Import(addon)
 end)
end))
assert(not SoftSpokenDB and not SoftSpokenCharacterDB and SpokenSettings==core)
-- A malformed pending second-character preference must fail before publication.
story.profiles.B.Audio="bad"
assert(not pcall(function() P:RecoverLegacy(Import) end))
assert(not SoftSpokenDB and not SoftSpokenCharacterDB and SpokenSettings==core)
story.profiles.B.Audio=nil
-- Nested history and executable/unserializable data also fail.
for _, bad in ipairs({function() end, {seen="bad"}, {dialogue={[1]="bad"}}}) do
 assert(not pcall(function()
  P:RecoverLegacy(function(addon)
   if addon=="SoftSpoken_Stories" then return {SpokenQuestsSettings=story},{SSCQuestJournal=bad} end
   return Import(addon)
  end)
 end))
 assert(not SoftSpokenDB and not SoftSpokenCharacterDB and SpokenSettings==core)
end
local cyclic={}
cyclic.self=cyclic
assert(not pcall(function()
 P:RecoverLegacy(function(addon)
  if addon=="SoftSpoken_Stories" then return {},{SSCQuestJournal=cyclic} end
  return Import(addon)
 end)
end))
assert(not SoftSpokenDB and not SoftSpokenCharacterDB and SpokenSettings==core)
assert(P:RecoverLegacy(Import))
local root, char = SoftSpokenDB, SoftSpokenCharacterDB
local name=root.profileKeys["One - Realm"]
assert(root.profiles[name].Frame.FrameScale==1.2 and not root.profiles[name].Transcript.Enabled)
assert(not root.profiles.Unused and root.global.Layout.Narrator.left==42)
assert(root.namespaces.Stories.profiles[name].Compendium.foundOnly==false)
assert(root.namespaces.Places.profiles[name].stopCombat==true)
assert(char.Places.heard["s:1:den"] and char.Places.extra==8)
assert(char.Stories.journal.completed[1] and char.Stories.journal.extra==7 and not char.Stories.journal.settings)
assert(char.Writings.found[2] and char.Writings.extra==9)
assert(core.profiles.Shared.Transcript==nil and SpokenSettings==core)
assert(P:RecoverLegacy(function() error("must not reimport") end))
assert(SoftSpokenDB==root and SoftSpokenCharacterDB==char)
player="Two"
SoftSpokenCharacterDB=nil
core={} -- old Core file has been replaced
local oldImport = Import
Import = function(addon)
 assert(addon ~= "SoftSpoken", "already replaced Core file was read again")
 return oldImport(addon)
end
-- AceDB strips empty sections at logout; a namespace can lose its profiles.
root.namespaces.Writings.profiles = nil
assert(P:RecoverLegacy(Import))
root=SoftSpokenDB
name=root.profileKeys["Two - Realm"]
assert(root.profiles[name].Frame.FrameScale==0.8)
assert(root.char["Two - Realm"].IsPaused)
assert(root.namespaces.Stories.profiles[name].DebugEnabled)
assert(SoftSpokenCharacterDB.Stories.custom)
assert(root.namespaces.Writings.profiles[name].autoplay==false)
assert(root.profiles["One - Realm"].Frame.FrameScale==1.2)
-- New character with no legacy files must not inherit a retired character's profile.
player="Three"
SoftSpokenCharacterDB=nil
root.global=nil -- simulate cleanup of an empty section
assert(P:RecoverLegacy(function(addon)
 assert(addon ~= "SoftSpoken")
 return {},{}
end))
assert(SoftSpokenCharacterDB.Stories==nil and SoftSpokenCharacterDB.Writings==nil)
local third=SoftSpokenDB.profileKeys["Three - Realm"]
assert(not next(SoftSpokenDB.profiles[third]))
assert(not (SoftSpokenDB.namespaces.Writings.profiles or {})[third], "fresh character inherited old Writings settings")
assert(SoftSpokenDB.migration.characters["Three - Realm"]=="new")
assert(SoftSpokenDB.migration.characters["One - Realm"]=="legacy")
assert(SoftSpokenDB.migration.characters["Two - Realm"]=="legacy")
assert(not SoftSpokenDB.migration.pending.core["Two - Realm"])
assert(not SoftSpokenDB.migration.pending.storyChar["Two - Realm"])

-- A missing character file cannot resurrect retired history or select a new profile.
player="One"
SoftSpokenCharacterDB=nil
local currentRoot=SoftSpokenDB
currentRoot.profileKeys["One - Realm"]="Manually selected"
currentRoot.profiles["Manually selected"]={custom=true}
assert(P:RecoverLegacy(function() error("completed character must not import again") end))
assert(SoftSpokenDB==currentRoot)
assert(SoftSpokenDB.profileKeys["One - Realm"]=="Manually selected")
assert(SoftSpokenCharacterDB.migrationVersion==1 and not SoftSpokenCharacterDB.Stories)
-- The same protection applies to a previously new character.
player="Three"
SoftSpokenCharacterDB=nil
assert(P:RecoverLegacy(function() error("new character must not reimport") end))
assert(SoftSpokenDB.profileKeys["Three - Realm"]==third)
-- A legacy character known only through a character file still gets the
-- original account-wide Writings preferences, even after all known keys are consumed.
player="HistoryOnly"
SoftSpokenCharacterDB=nil
assert(P:RecoverLegacy(function(addon)
 if addon=="SoftSpoken_Places" then return {},{SSZCharacter={}} end
 return {},{}
end))
local late=SoftSpokenDB.profileKeys["HistoryOnly - Realm"]
assert(SoftSpokenDB.migration.characters["HistoryOnly - Realm"]=="legacy")
assert(SoftSpokenDB.namespaces.Writings.profiles[late].autoplay==false)
-- Unknown new character colliding with an existing profile name gets defaults.
player="Collision"
SoftSpokenCharacterDB=nil
SoftSpokenDB.profiles["Collision - Realm"]={custom=true}
assert(P:RecoverLegacy(function() return {},{} end))
local collision=SoftSpokenDB.profileKeys["Collision - Realm"]
assert(collision~="Collision - Realm" and not next(SoftSpokenDB.profiles[collision]))
assert(SoftSpokenDB.profiles["Collision - Realm"].custom)
-- A character-only marker without account completion is inconsistent, not a clean install.
player="Inconsistent"
SoftSpokenCharacterDB={migrationVersion=1,Stories={custom=true}}
local beforeRoot,beforeChar=SoftSpokenDB,SoftSpokenCharacterDB
assert(not pcall(function() P:RecoverLegacy(function() error("unexpected import") end) end))
assert(SoftSpokenDB==beforeRoot and SoftSpokenCharacterDB==beforeChar)
-- Corrupt history fails before publishing either table.
local savedRoot=SoftSpokenDB
player="Four"
SoftSpokenCharacterDB=nil
assert(not pcall(function()
 P:RecoverLegacy(function(addon)
  if addon=="SoftSpoken_Stories" then return {},{SSCQuestJournal={seen="bad"}} end
  return {},{}
 end)
end))
assert(SoftSpokenDB==savedRoot and not SoftSpokenCharacterDB)
-- Start with completely empty WTF: the first character is new, not legacy.
SoftSpokenDB,SoftSpokenCharacterDB,SpokenSettings=nil,nil,nil
player="Fresh"
-- Native recovery can populate the legacy retention slot even when the
-- client did not load it. This remains available after a later failure.
assert(not pcall(function()
 P:RecoverLegacy(function(addon)
  if addon=="SoftSpoken" then return {SpokenSettings={global={retained=true}}},{} end
  error("read failure")
 end)
end))
assert(SpokenSettings.global.retained and not SoftSpokenDB and not SoftSpokenCharacterDB)
SpokenSettings=nil
assert(P:RecoverLegacy(function() return {},{} end))
assert(SoftSpokenDB.migration.characters["Fresh - Realm"]=="new")
assert(not next(SoftSpokenDB.profiles["Fresh - Realm"]))
assert(not next(SoftSpokenDB.namespaces))
assert(SoftSpokenCharacterDB.migrationVersion==1)
print("PASS: migration, new/legacy classification, consumed ledger, collision and recovery")

-- Real D import followed by detached L10 conversion.
dofile("SoftSpoken/Locations/Data.lua")
dofile("SoftSpoken/Locations/Registry.lua")
dofile("SoftSpoken/Locations/History.lua")
local H=SpokenEnv.LocationHistory
local registry=SpokenEnv.Locations
player="Geo";SoftSpokenCharacterDB=nil
local placesSource={visited={["1411/southfury river"]=true,["1413/southfury river"]=true,
    ["1412/camp gevrek"]=true,["2482"]=true,[42]=false},
    heard={["s:1411:southfury river"]=true,["s:1413:southfury river"]=true,
        ["s:1412:camp gevrek"]=true},greeted=true}
local writingsSource={read={[17]=true},locations={[17]={[1429]="world",[616]="encounter",["1429"]="legacy-string"}},
    acquisitions={[123]={[1429]=2,[616]=3}}}
assert(P:RecoverLegacy(function(addon)
    if addon=="SoftSpoken_Places" then return {},{SSZCharacter=placesSource} end
    if addon=="SoftSpoken_Writings" then return {},{SSBCharacter=writingsSource} end
    if addon=="SoftSpoken_Stories" then return {},{SSCQuestJournal={completed={[88]=true}}} end
    return {},{}
end))
local pre=SoftSpokenCharacterDB
local account=SoftSpokenDB
assert(pre.geographyVersion==nil and pre.migrationVersion==1)
local migrated=H:Upgrade()
assert(migrated==SoftSpokenCharacterDB and migrated~=pre and migrated.geographyVersion==1)
assert(SoftSpokenDB==account and account.migration.characters["Geo - Realm"]=="legacy")
assert(migrated.migrationVersion==1 and migrated.Stories.journal.completed[88])
assert(migrated.Writings.read[17] and migrated.Writings.found[17] and migrated.Places.greeted)
local p,w=migrated.Places,migrated.Writings
assert(p.visited.southfury_river["1411/southfury river"] and p.visited.southfury_river["1413/southfury river"])
assert(p.heard.southfury_river["s:1411:southfury river"] and p.heard.southfury_river["s:1413:southfury river"])
assert(p.locationHolds.visited["2482"] and p.locationHolds.visited[42]==false)
assert(H:PlaceHas(p,"visited","1412/camp gevrek"))
assert(not H:PlaceHas(p,"visited","1440/southfury river"))
assert(w.locations[17].elwynn_forest.world and not w.locations[17][1429])
assert(w.locationHolds.locations[17][616]=="encounter" and w.locationHolds.locations[17]["1429"]=="legacy-string")
assert(w.acquisitions[123].elwynn_forest==2 and w.locationHolds.acquisitions[123][616]==3)
assert(pre.Places.visited["1411/southfury river"] and placesSource.visited["1411/southfury river"])
assert(writingsSource.locations[17][1429]=="world")
assert(H:Upgrade()==migrated)
assert(P:RecoverLegacy(function() error("must not reimport migrated character") end))
assert(SoftSpokenCharacterDB==migrated)
P:ValidateCharacterHistory(migrated)
local malformed={migrationVersion=1,Writings={locations={[1]="bad"}}}
SoftSpokenCharacterDB=malformed
assert(not pcall(function() H:Upgrade() end))
assert(SoftSpokenCharacterDB==malformed and not malformed.geographyVersion)
assert(SoftSpokenDB==account)
local good={migrationVersion=1,Writings={locations={[1]={[1429]="world"}}}}
SoftSpokenCharacterDB=good
local validate=P.ValidateCharacterHistory
P.ValidateCharacterHistory=function() error("injected validation failure") end
assert(not pcall(function() H:Upgrade() end))
assert(SoftSpokenCharacterDB==good and not good.geographyVersion)
P.ValidateCharacterHistory=validate
assert(H:Upgrade().Writings.locations[1].elwynn_forest.world)
-- Controlled aliases exercise union/sum even without actual current aliases.
SpokenEnv.Locations=setmetatable({
    ResolveContentIdentifier=function(self,ns,value,scope)
        assert(ns=="upstreamUiMap" and scope=="spoken_classic")
        if value==9001 or value==9002 then return "elwynn_forest","resolved" end
        return registry:ResolveContentIdentifier(ns,value,scope)
    end
},{__index=registry})
local alias=H:Transform({Writings={
    locations={[7]={[9001]="world",[9002]="acquired"}},
    acquisitions={[9]={[9001]=2,[9002]=3,[9003]=4}}
}})
assert(alias.Writings.locations[7].elwynn_forest.world)
assert(alias.Writings.locations[7].elwynn_forest.acquired)
assert(alias.Writings.acquisitions[9].elwynn_forest==5)
assert(alias.Writings.locationHolds.acquisitions[9][9003]==4)
SpokenEnv.Locations=registry
print("PASS: L10 migration after D, unified save, holds, union/sum, atomic failure and idempotence")
