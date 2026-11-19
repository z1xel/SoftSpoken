-- Places integrations with Core's shared Compendium and lore page.
-- These hooks are installed after Core and before Places' map panel.
SpokenCompendium.OpenPlaceSelection = function(mapID, areaKey)
    if SSZLoreWindow and SSZLoreWindow.OpenSelectionFromPlayer then
        SSZLoreWindow.OpenSelectionFromPlayer(mapID, areaKey)
    end
end
SSCLorePage.OnOpenLore = function(mapID, areaKey)
    if SSZLoreWindow and SSZLoreWindow.ShowLoreFor then
        SSZLoreWindow.ShowLoreFor(mapID, areaKey)
    end
end
