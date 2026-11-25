-- SoftSpoken Places (Vanilla 1.12 / Lua 5.0).
-- Places lifecycle and event wiring; content and audio policies live in siblings.

-- Lifecycle/wiring only. Content and player policies live in siblings.
local PlacesRuntime = SpokenPlacesRuntime
local CharDB = PlacesRuntime.CharDB
local Say = PlacesRuntime.Say
local frame

frame = CreateFrame("Frame")
local locationPollElapsed = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    if not PlacesRuntime.source then return end
    elapsed = elapsed or arg1 or 0
    if PlacesRuntime.startupActive then
        PlacesRuntime.StabilizeStartingLocation(elapsed)
    else
        locationPollElapsed = locationPollElapsed + elapsed
        if locationPollElapsed >= 1 then
            locationPollElapsed = 0
            -- Record actual movement even when the legacy client fails to
            -- emit ZONE_CHANGED for a subzone nested inside another.
            PlacesRuntime.CheckLocation()
        end
    end
end)
frame:SetScript("OnEvent", function(self, firedEvent, a, b, c)
    local eventName = firedEvent or event
    if not PlacesRuntime.source then
        return
    elseif eventName == "PLAYER_ENTERING_WORLD" then
        if PlacesRuntime.startupActive then
            PlacesRuntime.firstWorldReady = true
            PlacesRuntime.startupStableKey = nil
            PlacesRuntime.startupStableElapsed = 0
        else
            -- Later world transitions (boats/instances) are real travel.
            PlacesRuntime.CheckLocation()
        end
    elseif eventName == "ZONE_CHANGED" or eventName == "ZONE_CHANGED_NEW_AREA" or
           eventName == "ZONE_CHANGED_INDOORS" then
        if not PlacesRuntime.startupActive then PlacesRuntime.CheckLocation() end
    elseif eventName == "MAP_EXPLORATION_UPDATED" then
        PlacesRuntime.InvalidateExploration()
        if SSZMapCompat and SSZMapCompat.ClearOverlayCache then
            SSZMapCompat.ClearOverlayCache()
        end
        if SSZMapHighlight and SSZMapHighlight.Hide then
            SSZMapHighlight.Hide()
        end
        if SpokenCompendium and SpokenCompendium.Refresh then
            SpokenCompendium:Refresh()
        end
        if SSZMapPanel and SSZMapPanel.Refresh then
            SSZMapPanel.Refresh()
        end
    elseif PlacesRuntime.discoveryEvents[eventName] then
        local message = PlacesRuntime.EventMessage(a, b, c)
        local area = PlacesRuntime.DiscoveredArea(message)
        if area then
            PlacesRuntime.OnDiscovered(area)
        end
    elseif eventName == "PLAYER_REGEN_DISABLED" or eventName == "PLAYER_REGEN_ENABLED" or
           eventName == "CINEMATIC_START" or eventName == "CINEMATIC_STOP" then
        -- The start event may precede the cinematic frame becoming visible.
        if eventName == "CINEMATIC_START" then PlacesRuntime.cinematicEventActive = true end
        if eventName == "CINEMATIC_STOP" then PlacesRuntime.cinematicEventActive = false end
        PlacesRuntime.Recheck()
    end
end)

function PlacesRuntime:Initialize()
    if self.initializationStarted then return end
    self.initializationStarted = true
    self:InitDB()
    CharDB()
    if not Spoken or not Spoken.IsCompatible or not Spoken:IsCompatible(1) then
        Say("Shared SoftSpoken player initialization failed.")
        return false
    end
    -- Legacy caption preferences are handled during D4 recovery, before DB initialization.
    self.db.RegisterCallback(self, "OnProfileReset", function()
        if self.initialized then self:RefreshConfig() end
    end)
    -- Packaged 32-bit TGA map-location cursor artwork for Vanilla 1.12;
    -- the player keeps its existing type glyphs and queued grayscale.
    if Spoken.RegisterBullet then
        Spoken:RegisterBullet("zone", [[Interface\AddOns\SoftSpoken\Textures\SoundQueueBulletMaploc]], 16)
    end
    PlacesRuntime.source = Spoken:GetSource("zones")
    if not PlacesRuntime.source then
        PlacesRuntime.source = Spoken:RegisterSource("zones", {
            title = "SoftSpoken Places",
            addon = "SoftSpoken",
            order = 2,
            queueLimit = 3,
            interClipGap = 0.25,
            -- Existing audio registries, exposed only as read-only
            -- metadata for the shared settings panel.
            packs = function() return PlacesRuntime.AudioPackNames() end,
        })
    end
    if PlacesRuntime.source.AddGate then PlacesRuntime.source:AddGate(PlacesRuntime.HoldAutoplay) end
    if Spoken.RegisterCallback then
        Spoken:RegisterCallback("AUDIO_CHANGED", function()
            SpokenPlacesBridge:NotifyAudioChanged()
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
    for name in pairs(PlacesRuntime.discoveryEvents) do frame:RegisterEvent(name) end
    -- A supported extension can update exploration while the map is open.
    pcall(frame.RegisterEvent,frame,"MAP_EXPLORATION_UPDATED")
    self:SetupOptions()
    self.initialized = true
end

-- Re-evaluate the active combat gate and any open Places UI on profile changes.
function PlacesRuntime:RefreshConfig()
    self.Recheck()
    if SSZMapPanel and SSZMapPanel.Refresh then SSZMapPanel.Refresh() end
    if SSZLoreWindow and SSZLoreWindow.Refresh then SSZLoreWindow.Refresh() end
    if self.RefreshOptions then self:RefreshOptions() end
end
