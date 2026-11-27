setfenv(1, SpokenEnv)

-- Loaded last, after every controller and its settings helpers are defined.
-- SavedVariables are available at PLAYER_LOGIN. Phase D can prepare legacy
-- data before any controller consumes it; world-dependent work stays deferred.
-- Session-local coordinator. A pre-controller block is retryable explicitly;
-- once any controller has started, a failed initialization requires reload.
StartupController = {}
local state, reason = "pending", nil
local loginReady = false

local function SetState(nextState, nextReason)
    state, reason = nextState, nextReason
end

function StartupController:GetState()
    return state, reason
end

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

function StartupController:Start(mode)
    mode = mode or "normal"
    if not loginReady then return false, "awaiting-login" end
    if state ~= "pending" and state ~= "blocked" then
        return false, state
    end
    -- DEV1 only establishes the startup boundary. Never skip migration
    -- until DEV2/DEV3 supply an isolated, fully initialized storage backend.
    if mode == "dev" then return false, "dev-storage-unavailable" end
    if mode ~= "normal" then return false, "unknown-mode" end
    if Persistence.root or Persistence.character then
        SetState("failed", "storage-already-initialized")
        return false, reason
    end

    -- Guard against reentrant Start calls during migration or controller init.
    SetState("initializing")
    if UpgradeGuard and not Run("Upgrade guard", UpgradeGuard, "CanStart") then
        SetState("blocked", "upgrade-guard")
        return false, reason
    end
    if not Run("Legacy migration", Persistence, "RecoverLegacy") then
        SetState("blocked", "migration")
        return false, reason
    end
    if not Run("Core", CoreController, "Initialize") then
        SetState("failed", "core")
        return false, reason
    end
    local storiesReady = Run("Stories", VoiceOver and VoiceOver.StoriesAddon, "Initialize")
    local placesReady = Run("Places", SpokenPlacesRuntime, "Initialize")
    local writingsReady = Run("Writings", SpokenWritings, "Initialize")
    local coreReady = Run("Core finalization", CoreController, "FinalizeStartup")
    -- Import markers only describe imported data, not successful UI startup.
    -- Keep the latter session-local; never mark a failed controller as ready.
    Persistence.startupComplete = storiesReady and placesReady and writingsReady and coreReady
    if not Persistence.startupComplete then
        SetState("failed", "controllers")
        return false, reason
    end
    SetState("running")
    return true
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(_, firedEvent)
    if (firedEvent or event) ~= "PLAYER_LOGIN" or loginReady then return end
    loader:UnregisterEvent("PLAYER_LOGIN")
    loginReady = true
    StartupController:Start("normal")
end)
