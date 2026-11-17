-- Run from the repository root: lua5.1 tests/audio_pack_load_outcomes.lua
-- Test actual Stories DataModules.lua against simulated Vanilla 1.12 addon APIs.
local function eq(got, want, label)
    assert(got == want, (label or "value") .. ": expected " ..
        tostring(want) .. ", got " .. tostring(got))
end
local installed, byName, loadCalls, outcomes, loaded, writes = {}, {}, {}, {}, {}, {}
VoiceOver = setmetatable({
    format=string.format,
    Version={Interface=11200},
    Enums={SoundEvent={QuestAccept=1,QuestProgress=2,QuestComplete=3,QuestGreeting=4,Gossip=5}},
    Language={Normalize=function() return "enUS" end,
        ResolutionOrder=function() return {"enUS"} end},
    EasterEggs={Apply=function() end},
    Options={AddDataModule=function() end,AddAvailableDataModule=function() end},
}, {__index=_G})
local function install(name, outcome, demand, disabled)
    local pack={name=name, outcome=outcome, demand=demand ~= false, disabled=disabled}
    table.insert(installed, pack)
    byName[name]=pack
    outcomes[name]=outcome
end
function GetNumAddOns() return table.getn(installed) end
function GetAddOnInfo(id)
    local pack=type(id)=="number" and installed[id] or byName[id]
    if not pack then return nil,nil,nil,false,"MISSING" end
    return pack.name,pack.name,"test",not pack.disabled,
        pack.disabled and "DISABLED" or nil
end
function GetAddOnMetadata(id, key)
    local pack=type(id)=="number" and installed[id] or byName[id]
    if not pack then return nil end
    if key=="X-VoiceOver-DataModule-Version" then return "1" end
    if key=="X-VoiceOver-DataModule-Priority" then return "100" end
    if key=="Version" then return "2.2.0" end
end
function IsAddOnLoadOnDemand(name) return byName[name].demand end
function IsAddOnLoaded(name) return loaded[name] == true end
function GetCVar(name) eq(name,"checkAddonVersion"); return "1" end
function SetCVar(name,value)
    eq(name,"checkAddonVersion")
    table.insert(writes,tostring(value))
end
function UnitSex() return nil end
local data
function LoadAddOn(name)
    loadCalls[name]=(loadCalls[name] or 0)+1
    if outcomes[name]=="failure" then return nil,"MISSING" end
    loaded[name]=true
    if outcomes[name]~="no-registration" then
        data:Register(name,{SoundLengthLookupByFileName={}})
    end
    return true
end
dofile("SoftSpoken_Stories/DataModules.lua")
data=VoiceOver.DataModules
install("SpokenQuestsAudioShared","success")
install("SSS_VOFallback","failure")
install("AI_VoiceOverData_Turtle","no-registration")
install("AlreadyLoaded","success")
install("NotDemand","success",false)
install("DisabledPack","success",true,true)
loaded.AlreadyLoaded=true
data:EnumerateAddons(false)
local s=data:GetLoadSummary()
eq(s.detected,5,"disabled excluded")
eq(s.loaded,0);eq(s.failed,0);eq(s.notAttempted,5)
eq(data:GetModuleLoadStatus("SSS_VOFallback"),"not attempted")
eq(data:LoadPresentModules(),true,"partial success result")
s=data:GetLoadSummary()
eq(s.detected,5);eq(s.loaded,1);eq(s.failed,3);eq(s.notAttempted,1)
eq(data:GetModuleLoadStatus("SpokenQuestsAudioShared"),"loaded")
local state,reason=data:GetModuleLoadStatus("SSS_VOFallback")
eq(state,"failed");eq(reason,"MISSING")
state,reason=data:GetModuleLoadStatus("AI_VoiceOverData_Turtle")
eq(state,"failed");eq(reason,"DID_NOT_REGISTER")
state,reason=data:GetModuleLoadStatus("AlreadyLoaded")
eq(state,"failed");eq(reason,"LOADED_BUT_NOT_REGISTERED")
eq(data:GetModuleLoadStatus("NotDemand"),"not attempted")
eq(loadCalls.SpokenQuestsAudioShared,1,"successful pack once")
eq(loadCalls.SSS_VOFallback,1,"failed pack once")
eq(loadCalls.AI_VoiceOverData_Turtle,1,"no-registration once")
eq(loadCalls.AlreadyLoaded,nil,"no reload of already loaded")
eq(loadCalls.NotDemand,nil,"no attempt for non-LOD")
eq(loadCalls.DisabledPack,nil,"no attempt for disabled")
eq(table.concat(writes,","),"0,1,0,1,0,1","original CVar writes")

-- Successful single-pack load retains the original behavior and return value.
installed,byName,loadCalls,outcomes,loaded,writes={},{},{},{},{},{}
install("SpokenQuestsAudioAll","success")
data.presentModules,data.presentModulesOrdered={},{}
data.registeredModules,data.registeredModulesOrdered={},{}
data.loadErrors,data.loadAttempts={},{}
data:EnumerateAddons(false)
eq(data:LoadPresentModules(),true,"normal load return")
s=data:GetLoadSummary()
eq(s.detected,1);eq(s.loaded,1);eq(s.failed,0);eq(s.notAttempted,0)
eq(table.concat(writes,","),"0,1","unchanged CVar handling")

-- No packs is a valid state, and never attempts LoadAddOn.
installed,byName,loadCalls,outcomes,loaded,writes={},{},{},{},{},{}
data.presentModules,data.presentModulesOrdered={},{}
data.registeredModules,data.registeredModulesOrdered={},{}
data.loadErrors,data.loadAttempts={},{}
data:EnumerateAddons(false)
eq(data:LoadPresentModules(),false,"no-packs load result")
s=data:GetLoadSummary()
eq(s.detected,0);eq(s.loaded,0);eq(s.failed,0);eq(s.notAttempted,0)
eq(next(loadCalls),nil,"no loading calls")
print("PASS: voicepack loading status, partial failures, no retries and normal startup")
