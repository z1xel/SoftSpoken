setfenv(1, SpokenEnv)

-- Loaded last, after every controller and its settings helpers are defined.
-- SavedVariables are available at PLAYER_LOGIN. Phase D can prepare legacy
-- data before any controller consumes it; world-dependent work stays deferred.
local started = false

local function Run(name, controller, method)
    local ok, result = pcall(function()
        assert(controller and type(controller[method]) == "function",
            name .. " has no " .. method)
        return controller[method](controller)
    end)
    if ok and result ~= false then return true end
    local message = "SoftSpoken startup: " .. name .. ": " ..
        tostring(ok and "initialization rejected" or result)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff4040" .. message .. "|r")
    end
    return false
end

local function Initialize()
    if started then return end
    started = true
    if UpgradeGuard and not UpgradeGuard:CanStart() then return end
    if not Run("Legacy migration", Persistence, "RecoverLegacy") then return end
    if not Run("Core", CoreController, "Initialize") then return end
    Run("Stories", VoiceOver and VoiceOver.StoriesAddon, "Initialize")
    Run("Places", SpokenPlacesRuntime, "Initialize")
    Run("Writings", SpokenWritings, "Initialize")
    Run("Core finalization", CoreController, "FinalizeStartup")
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(_, firedEvent)
    if (firedEvent or event) ~= "PLAYER_LOGIN" then return end
    loader:UnregisterEvent("PLAYER_LOGIN")
    Initialize()
end)
