-- SoftSpoken_Zones: upstream picture lookup, using locally converted .tga files.
-- Masks from the original DXT5 BLPs have already been baked into TGA alpha.
SSZPicturesUI = SSZPicturesUI or {}
local P = SSZPicturesUI
local ROOT = "Interface\\AddOns\\SoftSpoken_Zones\\Textures\\Pictures\\"
function P.Get(mapID, areaKey)
    local maps = SSZPictures
    local entries = maps and maps[mapID]
    local file = entries and entries[areaKey or ""]
    if type(file) ~= "string" or file == "" then return nil end
    return ROOT .. file
end
