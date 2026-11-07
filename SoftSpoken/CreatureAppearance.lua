setfenv(1, SpokenEnv)

-- One ClassicAPI creature-data service for the narrator and Compendium.
-- The client owns the WDB and portrait caches; Lua tracks only in-flight IDs.
CreatureAppearance = {}
local A = CreatureAppearance
local pending, listeners, completed = {}, {}, {}
local eventFrame

local function PositiveID(value)
    local id = tonumber(value)
    if id and id > 0 and id == math.floor(id) then return id end
end

function A:GetDisplayID(creatureID)
    local id = PositiveID(creatureID)
    local api = C_CreatureInfo
    if not id or not api or type(api.GetCreatureInfoByID) ~= "function" then return nil end
    local ok, info = pcall(api.GetCreatureInfoByID, id)
    if ok and type(info) == "table" then return PositiveID(info.displayID) end
end

function A:Subscribe(callback)
    if type(callback) ~= "function" then return false end
    listeners[callback] = true
    return true
end

function A:Unsubscribe(callback)
    listeners[callback] = nil
end

-- The native API can complete synchronously inside Request(). Never invoke
-- presentation code there: deliver combined results on the next UI frame.
local function Flush(frame)
    frame = frame or eventFrame
    frame:SetScript("OnUpdate", nil)
    local ready = completed
    completed = {}
    for id, success in pairs(ready) do
        local displayID = success and A:GetDisplayID(id) or nil
        for callback in pairs(listeners) do
            pcall(callback, id, displayID, success)
        end
    end
end

local function OnEvent(frame, name, id, success)
    name = type(name) == "string" and name or _G.event
    if name ~= "CREATURE_DATA_LOAD_RESULT" then return end
    id = PositiveID(id or _G.arg1)
    if not id or not pending[id] then return end
    if success == nil then success = _G.arg2 end
    pending[id] = nil
    completed[id] = not (success == false or success == nil or success == 0)
    eventFrame:SetScript("OnUpdate", Flush)
end

local function EnsureEventFrame()
    if eventFrame then return true end
    local ok, frame = pcall(CreateFrame, "Frame", nil, UIParent)
    if not ok or not frame then return false end
    local okRegister, registered = pcall(frame.RegisterEvent, frame, "CREATURE_DATA_LOAD_RESULT")
    -- Vanilla RegisterEvent returns nil on success; some compatibility
    -- implementations return false for an unsupported custom event.
    if not okRegister or registered == false then return false end
    frame:SetScript("OnEvent", OnEvent)
    eventFrame = frame
    return true
end

-- Success means cached, already pending, or accepted by ClassicAPI. A failure
-- clears the pending mark so a later request may retry.
function A:Request(creatureID)
    local id = PositiveID(creatureID)
    if not id then return false end
    if self:GetDisplayID(id) then return true end
    local api = C_CreatureInfo
    if not api or type(api.GetCreatureInfoByID) ~= "function" or
       type(api.RequestLoadCreatureByID) ~= "function" then return false end
    if pending[id] then return true end
    if not EnsureEventFrame() then return false end
    pending[id] = true
    local ok, accepted = pcall(api.RequestLoadCreatureByID, id)
    -- ClassicAPI explicitly returns a boolean. Nil from a broken or older
    -- compatibility function is not proof of an accepted query.
    if not ok or (accepted ~= true and accepted ~= 1) then
        pending[id] = nil
        return false
    end
    return true
end
