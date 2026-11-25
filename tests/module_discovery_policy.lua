-- Test actual source policy, persistence preference and notification contract.
local events, removed = {}, {}
local env=setmetatable({
    format=string.format,
    CoreController={db={profile={Parts={}}}},
    Callbacks={Fire=function(self,name,key,value)
        table.insert(events,{name,key,value})
    end},
    SoundQueue={RemoveSource=function(self,source) table.insert(removed,source.key) end},
}, {__index=_G})
env.SpokenEnv=env
local chunk=assert(loadfile("SoftSpoken/Sources.lua"))
setfenv(chunk,env)
chunk()
local S=assert(env.Sources)
for _,key in ipairs({"quests","zones","books"}) do
    S:Register(key,{title=key})
    assert(S:ShouldTrack(key))
    S:SetTurnedOff(key,true)
    assert(S:ShouldTrack(key),"default silent tracking")
    assert(removed[table.getn(removed)]==key)
    S:SetTrackWhileOff(key,false)
    assert(not S:ShouldTrack(key),"explicit opt-out")
    assert(events[table.getn(events)][1]=="DISCOVERY_POLICY_CHANGED")
    S:SetTurnedOff(key,false)
    assert(S:ShouldTrack(key),"enabled source always tracks")
    S:SetTurnedOff(key,true)
    assert(not S:ShouldTrack(key),"opt-out persists")
    S:SetTrackWhileOff(key,true)
    assert(S:ShouldTrack(key))
end
S:Register("gossip",{title="Gossip"})
S:SetTurnedOff("gossip",true)
assert(not S:ShouldTrack("gossip"))
env.CoreController.db.profile={Parts={books=false},SilentDiscovery={books=false}}
assert(not S:ShouldTrack("books"))
env.CoreController.db.profile={Parts={books=false}}
S:Apply("books")
assert(S:ShouldTrack("books"))
print("module discovery policy passed")
