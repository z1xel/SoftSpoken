-- Run at repository root: lua5.1 tests/creature_appearance_service.lua
-- Exercise the real ClassicAPI request coordinator against mock WoW frames.
local function equal(actual, expected, label)
    assert(actual==expected,(label or "value")..": expected "..tostring(expected)..
        ", got "..tostring(actual))
end
local known, requests, frames = {}, {}, {}
local behavior
local function Create()
    local frame={scripts={}}
    function frame:RegisterEvent(name) self.event=name end
    function frame:SetScript(name,fn) self.scripts[name]=fn end
    table.insert(frames,frame)
    return frame
end
local api={
    GetCreatureInfoByID=function(id)
        return known[id] and {displayID=known[id]} or nil
    end,
    RequestLoadCreatureByID=function(id)
        table.insert(requests,id)
        if behavior then return behavior(id) end
        return true
    end,
}
SpokenEnv=setmetatable({CreateFrame=Create,UIParent={},C_CreatureInfo=api},{__index=_G})
dofile("SoftSpoken/CreatureAppearance.lua")
local A=SpokenEnv.CreatureAppearance
local function Event(id,success)
    equal(#frames,1,"single event frame")
    equal(frames[1].event,"CREATURE_DATA_LOAD_RESULT","registered event")
    frames[1].scripts.OnEvent(frames[1],"CREATURE_DATA_LOAD_RESULT",id,success)
end
local function Flush()
    local frame=frames[1]
    if frame and frame.scripts.OnUpdate then frame.scripts.OnUpdate(frame,0) end
end
local first,second={},{}
local cb1=function(id,display,success) table.insert(first,{id,display,success}) end
local cb2=function(id,display,success) table.insert(second,{id,display,success}) end
equal(A:Subscribe(cb1),true,"subscribe first")
equal(A:Subscribe(cb2),true,"subscribe second")

equal(A:GetDisplayID(0),nil,"zero invalid")
equal(A:Request(-1),false,"negative invalid")
equal(A:Request(101),true,"first request")
equal(A:Request(101),true,"deduplicated request")
equal(#requests,1,"only one native query")
known[101]=501
Event(101,true)
equal(#first,0,"callbacks deferred")
Flush()
equal(#first,1,"first subscriber notified")
equal(#second,1,"second subscriber notified")
equal(first[1][1],101,"resolved creature")
equal(first[1][2],501,"resolved display")
equal(first[1][3],true,"result success")
equal(A:Request(101),true,"cached ID")
equal(#requests,1,"cached avoids requery")

equal(A:Request(102),true,"second creature")
equal(A:Request(103),true,"third creature")
known[102],known[103]=502,503
Event(102,true)
Event(103,true)
Flush()
equal(#first,3,"both completions delivered")
equal(#second,3,"both listeners notified")

equal(A:Request(104),true,"failure request")
Event(104,false)
Flush()
equal(first[4][1],104,"failed ID")
equal(first[4][2],nil,"no invalid display")
equal(first[4][3],false,"failure result")
equal(A:Request(104),true,"retry after failure")
equal(#requests,5,"retry actually sent")

behavior=function(id) if id==105 then return false end return true end
equal(A:Request(105),false,"rejected native request")
equal(A:Request(105),false,"rejected request retryable")
equal(#requests,7,"rejected reissued")
-- A nil return must not become a permanently pending request.
behavior=function(id) if id==109 then return nil end return true end
equal(A:Request(109),false,"nil native request is rejected")
equal(A:Request(109),false,"nil request does not latch pending ID")
equal(#requests,9,"nil request was actually retried")
behavior=nil

-- Native completion can arrive during the API call itself.
local count=#first
behavior=function(id)
    if id==106 then
        known[id]=506
        Event(id,true)
    end
    return true
end
equal(A:Request(106),true,"synchronous completion")
equal(#first,count,"no reentrant callback")
Flush()
equal(#first,count+1,"deferred sync completion")
equal(first[#first][2],506,"sync record resolved")
behavior=nil

local broken=function() error("a bad consumer") end
A:Subscribe(broken)
A:Unsubscribe(cb1)
equal(A:Request(107),true,"request with revoked listener")
known[107]=507
Event(107,true)
Flush()
equal(#first,count+1,"unsubscribed consumer not invoked")
equal(second[#second][2],507,"failure in one listener doesn't block others")
A:Unsubscribe(broken)
A:Unsubscribe(cb2)

SpokenEnv.C_CreatureInfo=nil
equal(A:GetDisplayID(108),nil,"no API cache")
equal(A:Request(108),false,"no API requests")
equal(#requests,11,"no extra request without API")
Event(101,true)
equal(frames[1].scripts.OnUpdate,nil,"unsolicited completion ignored")
-- Explicitly false event registration must not claim that a native request
-- was initiated, even if CreateFrame itself succeeded.
SpokenEnv.C_CreatureInfo=api
SpokenEnv.CreateFrame=function()
    local f={scripts={}}
    function f:RegisterEvent() return false end
    function f:SetScript(name,fn) self.scripts[name]=fn end
    return f
end
dofile("SoftSpoken/CreatureAppearance.lua")
equal(SpokenEnv.CreatureAppearance:Request(110),false,
    "unavailable custom event does not start a request")
equal(#requests,11,"no request without a registered completion event")

print("PASS: shared appearance service, deduplication, sync/async, failure and subscribers")
