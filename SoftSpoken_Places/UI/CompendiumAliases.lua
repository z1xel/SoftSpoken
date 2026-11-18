-- Compatibility aliases from historical Places (SSZ*) APIs to Core's
-- shared Compendium components. Keep these global names for existing callers
-- without introducing a second Compendium or a Core dependency on Places.
SSZUI = SSCUI
SSZCompendium = SSCCompendium
SSZLorePage = SSCLorePage
SSZTextView = SSCTextView
SSZClassicFrameSkin = SSCClassicFrameSkin
SSZOriginalArt = SSCOriginalArt
-- Places supplies these navigation hooks when its module is loaded.
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
