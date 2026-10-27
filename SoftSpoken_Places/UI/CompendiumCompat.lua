-- C3: bind the original Zones API names to shared Compendium components.
-- These aliases preserve third-party and in-module references, without loading
-- a second Compendium or allowing the shared add-on to require Zones.
SSZUI = SSCUI
SSZCompendium = SSCCompendium
SSZLorePage = SSCLorePage
SSZTextView = SSCTextView
SSZClassicFrameSkin = SSCClassicFrameSkin
SSZOriginalArt = SSCOriginalArt
-- Generic UI invokes these only when Zones is present.
SSCCompendium.OpenPlaceSelection = function(mapID,areaKey)
    if SSZLoreWindow and SSZLoreWindow.OpenSelectionFromPlayer then
        SSZLoreWindow.OpenSelectionFromPlayer(mapID,areaKey)
    end
end
SSCLorePage.OnOpenLore = function(mapID,areaKey)
    if SSZLoreWindow and SSZLoreWindow.ShowLoreFor then
        SSZLoreWindow.ShowLoreFor(mapID,areaKey)
    end
end
