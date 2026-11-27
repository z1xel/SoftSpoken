setfenv(1, SpokenEnv)

-- Loaded last, after every controller and its settings helpers are defined.
-- SavedVariables are available at PLAYER_LOGIN. Phase D can prepare legacy
-- data before any controller consumes it; world-dependent work stays deferred.
-- Session-local coordinator. A pre-controller block is retryable explicitly;
-- once any controller has started, a failed initialization requires reload.
StartupController = {}
local state, reason = "pending", nil
local loginReady, worldReady = false, false

local function SetState(nextState, nextReason)
    state, reason = nextState, nextReason
end

function StartupController:GetState()
    return state, reason
end

local function Run(name, controller, method, arg)
    local ok, result = pcall(function()
        assert(controller and type(controller[method]) == "function",
            name .. " has no " .. method)
        return controller[method](controller, arg)
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
    if mode ~= "normal" and mode ~= "dev" then return false, "unknown-mode" end
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
    if mode == "normal" and not Run("Legacy migration", Persistence, "RecoverLegacy") then
        SetState("blocked", "migration")
        return false, reason
    end
    if not Run("Core", CoreController, "Initialize", mode) then
        SetState("failed", "core")
        return false, reason
    end
    -- Explicit startup can occur after the first world entry. Consumers that
    -- normally await that event must initialize their world-dependent work.
    local storiesReady = Run("Stories", VoiceOver and VoiceOver.StoriesAddon, "Initialize", worldReady)
    local placesReady = Run("Places", SpokenPlacesRuntime, "Initialize", worldReady)
    local writingsReady = Run("Writings", SpokenWritings, "Initialize")
    local coreReady = Run("Core finalization", CoreController, "FinalizeStartup")
    -- Import markers only describe imported data, not successful UI startup.
    -- Keep the latter session-local; never mark a failed controller as ready.
    Persistence.startupComplete = storiesReady and placesReady and writingsReady and coreReady
    if not Persistence.startupComplete then
        SetState("failed", "controllers")
        return false, reason
    end
    SetState(mode == "dev" and "dev" or "running")
    return true
end

-- The command must be available even when Core has never initialized.
local function Say(message)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd100SoftSpoken:|r " .. message)
    end
end

function StartupController:Describe()
    local mode = Persistence and Persistence.mode
    return "Startup: " .. state .. (reason and (" (" .. reason .. ")") or "") ..
        "; storage: " .. (mode == "dev" and "DEV (temporary, not saved)" or
            mode == "normal" and "normal (persistent)" or "not initialized")
end

function StartupController:Command(message)
    local command = string.lower(string.gsub(message or "", "^%s*(.-)%s*$", "%1"))
    if command == "dev" then
        if state == "dev" then
            Say("DEV session already active. Settings and progress are temporary.")
            return
        end
        local ok, why = self:Start("dev")
        if ok then
            Say("|cffffd100DEV SESSION ACTIVE|r — migration bypassed. Settings and progress will not be saved. /softspoken undev reloads the interface.")
        elseif why == "running" then
            Say("Normal session already running. Live database switching is disabled.")
        else
            Say("DEV startup unavailable (" .. tostring(why) .. ")." ..
                (state == "failed" and " Reload the interface before retrying." or ""))
        end
        return
    elseif command == "undev" then
        if state ~= "dev" and not (state == "failed" and Persistence.mode == "dev") then
            Say("No DEV session is active.")
            return
        end
        if not ReloadUI then
            Say("ReloadUI unavailable. Use /reload or relog to exit DEV.")
            return
        end
        Say("Exiting DEV. Temporary settings and progress will be discarded; normal startup will run again.")
        ReloadUI()
        return
    elseif command == "status" then
        Say(self:Describe())
        return
    end
    -- Preserve the existing settings command in initialized sessions.
    if state == "running" or state == "dev" then
        Options:Open()
    else
        Say(self:Describe() .. ". Use /softspoken dev for a temporary session, or /softspoken status.")
    end
end

_G.SLASH_SPOKEN1 = "/softspoken"
SlashCmdList.SPOKEN = function(message) StartupController:Command(message) end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function(_, firedEvent)
    local e = firedEvent or event
    if e == "PLAYER_ENTERING_WORLD" then
        worldReady = true
        loader:UnregisterEvent("PLAYER_ENTERING_WORLD")
        return
    end
    if e ~= "PLAYER_LOGIN" or loginReady then return end
    loader:UnregisterEvent("PLAYER_LOGIN")
    loginReady = true
    local ok, why = StartupController:Start("normal")
    if not ok and why == "migration" then
        Say("Normal startup blocked. /softspoken dev starts a temporary session without migration.")
    end
end)
