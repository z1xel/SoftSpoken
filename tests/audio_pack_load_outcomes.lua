-- Run from the repository root: lua5.1 tests/audio_pack_load_outcomes.lua
-- Test actual Stories DataModules.lua against simulated Vanilla 1.12 addon APIs.
local function eq(got, want, label)
    assert(got == want, (label or "value") .. ": expected " ..
        tostring(want) .. ", got " .. tostring(got))
end
local installed, byName, loadCalls, outcomes, loaded, writes, enableCalls = {}, {}, {}, {}, {}, {}, {}
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
function GetAddOnEnableState(character, name)
    eq(character,nil,"current character")
    return byName[name].disabled and 0 or 2
end
function EnableAddOn(name)
    enableCalls[name]=(enableCalls[name] or 0)+1
    byName[name].disabled=false
end
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
    if byName[name].disabled then return nil,"DISABLED" end
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
eq(s.detected,6,"disabled voicepack discovered")
eq(s.loaded,0);eq(s.failed,0);eq(s.notAttempted,6)
eq(data:GetModuleLoadStatus("SSS_VOFallback"),"not attempted")
eq(data:LoadPresentModules(),true,"partial success result")
s=data:GetLoadSummary()
eq(s.detected,6);eq(s.loaded,2);eq(s.failed,3);eq(s.notAttempted,1)
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
eq(loadCalls.DisabledPack,1,"disabled pack loaded after enabling")
eq(enableCalls.DisabledPack,1,"one enable attempt for disabled pack")
eq(enableCalls.SpokenQuestsAudioShared,nil,"already-enabled pack untouched")
eq(enableCalls.NotDemand,nil,"non-LOD addon not enabled")
eq(table.concat(writes,","),"0,1,0,1,0,1,0,1","original CVar writes")

-- A pfUI profile can disable the pack after loading; its registered data
-- remains accessible, and later lookups must not enable it again.
byName.DisabledPack.disabled=true
eq(data:GetModule("DisabledPack") ~= nil,true,"registered data retained after disable")
local loadedAgain=data:LoadModule(data:GetPresentModule("DisabledPack"))
eq(loadedAgain,true,"registered pack remains usable")
eq(enableCalls.DisabledPack,1,"no repeated enable after pfUI disable")
eq(loadCalls.DisabledPack,1,"no reload after pfUI disable")

-- Successful single-pack load retains the original behavior and return value.
installed,byName,loadCalls,outcomes,loaded,writes,enableCalls={},{},{},{},{},{},{}
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
installed,byName,loadCalls,outcomes,loaded,writes,enableCalls={},{},{},{},{},{},{}
data.presentModules,data.presentModulesOrdered={},{}
data.registeredModules,data.registeredModulesOrdered={},{}
data.loadErrors,data.loadAttempts={},{}
data:EnumerateAddons(false)
eq(data:LoadPresentModules(),false,"no-packs load result")
s=data:GetLoadSummary()
eq(s.detected,0);eq(s.loaded,0);eq(s.failed,0);eq(s.notAttempted,0)
eq(next(loadCalls),nil,"no loading calls")
-- Historical 1.12 GetAddOnInfo returns seven values, rather than the newer
-- six-value form. Exercise it without GetAddOnEnableState.
installed,byName,loadCalls,outcomes,loaded,writes,enableCalls={},{},{},{},{},{},{}
install("LegacyDisabled","success",true,true)
local modernInfo, modernState=GetAddOnInfo, GetAddOnEnableState
GetAddOnEnableState=nil
GetAddOnInfo=function(id)
    local pack=type(id)=="number" and installed[id] or byName[id]
    return pack.name,pack.name,"test",pack.disabled and 0 or 1,true,
        pack.disabled and "DISABLED" or nil,"INSECURE"
end
data.presentModules,data.presentModulesOrdered={},{}
data.registeredModules,data.registeredModulesOrdered={},{}
data.loadErrors,data.loadAttempts={},{}
data:EnumerateAddons(false)
local _,_,_,loadable,reason=data:GetModuleAddOnInfo(data:GetPresentModule("LegacyDisabled"))
eq(loadable,true,"Vanilla loadable result correctly selected")
eq(reason,"DISABLED","Vanilla reason result correctly selected")
eq(data:LoadPresentModules(),true,"Vanilla disabled pack loaded")
eq(enableCalls.LegacyDisabled,1,"Vanilla 7-value detection enabled exactly once")
eq(loadCalls.LegacyDisabled,1,"Vanilla 7-value registration")
GetAddOnInfo,GetAddOnEnableState=modernInfo,modernState

-- EnableAddOn errors do not crash startup or reach LoadAddOn.
installed,byName,loadCalls,outcomes,loaded,writes,enableCalls={},{},{},{},{},{},{}
install("EnableError","success",true,true)
data.presentModules,data.presentModulesOrdered={},{}
data.registeredModules,data.registeredModulesOrdered={},{}
data.loadErrors,data.loadAttempts={},{}
local realEnable=EnableAddOn
EnableAddOn=function() error("enable denied") end
data:EnumerateAddons(false)
eq(data:LoadPresentModules(),false,"failed enabling does not load")
local status,failure=data:GetModuleLoadStatus("EnableError")
eq(status,"failed","enable failure reported")
assert(string.find(failure,"ENABLE_FAILED:",1,true),"enable error preserved")
eq(loadCalls.EnableError,nil,"cannot load after enable error")
EnableAddOn=realEnable

print("PASS: disabled pack recovery, Vanilla API, failure diagnostics, no redundant enabling")
