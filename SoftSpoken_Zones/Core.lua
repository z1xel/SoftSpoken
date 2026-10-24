-- SoftSpoken Zones C2: Lua 5.0-compatible module.
-- Extracted from the working Core.lua without changing its algorithms.

-- Lifecycle/wiring only. Content and player policies live in siblings.
local R = SSZZonesRuntime
local CharDB = R.CharDB
local Say = R.Say
local frame

frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
local locationPollElapsed = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    elapsed = elapsed or arg1 or 0
    if R.startupActive then
        R.StabilizeStartingLocation(elapsed)
    else
        locationPollElapsed = locationPollElapsed + elapsed
        if locationPollElapsed >= 1 then
            locationPollElapsed = 0
            -- Record actual movement even when the legacy client fails to
            -- emit ZONE_CHANGED for a subzone nested inside another.
            R.CheckLocation()
        end
    end
end)
frame:SetScript("OnEvent", function(self, firedEvent, a, b, c)
    local eventName = firedEvent or event
    if eventName == "PLAYER_LOGIN" then
        CharDB()
        if not Spoken or not Spoken.IsCompatible or not Spoken:IsCompatible(1) then
            Say("Compatible Spoken player not found.")
            return
        end
        -- Import a previous per-character setting once. After this, the global
        -- profile setting always wins, even when switching characters.
        if Spoken.ImportLegacyCaptionPreference then
            Spoken:ImportLegacyCaptionPreference(CharDB().settings.captions)
        end
        R.source = Spoken:GetSource("zones")
        if not R.source then
            R.source = Spoken:RegisterSource("zones", {
                title = "Spoken Zones",
                addon = "SoftSpoken_Zones",
                order = 2,
                queueLimit = 3,
                interClipGap = 0.25,
                -- Existing audio registries, exposed only as read-only
                -- metadata for the shared settings panel.
                packs = function() return R.AudioPackNames() end,
            })
        end
        if R.source.AddGate then R.source:AddGate(R.HoldAutoplay) end
        if Spoken.RegisterCallback then
            Spoken:RegisterCallback("AUDIO_CHANGED", function()
                SSZBridge:NotifyAudioChanged()
            end)
        end

        -- PLAYER_ENTERING_WORLD is the first safe baseline for spawn/reload.
        -- Ignore provisional ZONE_CHANGED notifications until it fires.
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
        frame:RegisterEvent("ZONE_CHANGED")
        frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        frame:RegisterEvent("ZONE_CHANGED_INDOORS")
        frame:RegisterEvent("PLAYER_REGEN_DISABLED")
        frame:RegisterEvent("PLAYER_REGEN_ENABLED")
        frame:RegisterEvent("CINEMATIC_START")
        frame:RegisterEvent("CINEMATIC_STOP")
        for name in pairs(R.discoveryEvents) do frame:RegisterEvent(name) end
        -- A supported extension can update exploration while the map is open.
        pcall(frame.RegisterEvent,frame,"MAP_EXPLORATION_UPDATED")

    elseif not R.source then
        return
    elseif eventName == "PLAYER_ENTERING_WORLD" then
        if R.startupActive then
            R.firstWorldReady = true
            R.startupStableKey = nil
            R.startupStableElapsed = 0
        else
            -- Later world transitions (boats/instances) are real travel.
            R.CheckLocation()
        end
    elseif eventName == "ZONE_CHANGED" or eventName == "ZONE_CHANGED_NEW_AREA" or
           eventName == "ZONE_CHANGED_INDOORS" then
        if not R.startupActive then R.CheckLocation() end
    elseif eventName == "MAP_EXPLORATION_UPDATED" then
        R.InvalidateExploration()
        if SSZMapCompat and SSZMapCompat.ClearOverlayCache then
            SSZMapCompat.ClearOverlayCache()
        end
        if SSZMapHighlight and SSZMapHighlight.Hide then
            SSZMapHighlight.Hide()
        end
        if SSZCompendium and SSZCompendium.Refresh then
            SSZCompendium:Refresh()
        end
        if SSZMapPanel and SSZMapPanel.Refresh then
            SSZMapPanel.Refresh()
        end
    elseif R.discoveryEvents[eventName] then
        local message = R.EventMessage(a, b, c)
        local area = R.DiscoveredArea(message)
        if area then
            R.OnDiscovered(area)
        end
    elseif eventName == "PLAYER_REGEN_DISABLED" or eventName == "PLAYER_REGEN_ENABLED" or
           eventName == "CINEMATIC_START" or eventName == "CINEMATIC_STOP" then
        R.Recheck()
    end
end)
