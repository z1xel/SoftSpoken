-- Terrain-derived fallback for map areas missing native 1.12 hover regions.
-- Source: the player's Turtle WoW Kalimdor ADT terrain-chunk scan.
-- The Darnassus 33 x 22 chunk grid is intentionally static, not recalculated
-- in combat or on hover. Only one lookup/substring is needed per query.
-- Never records visits, alters exploration, or changes the displayed map.
SSZTerrainMap = SSZTerrainMap or {}
local M = SSZTerrainMap

local CHUNK = 533.3333333333 / 16
local LEFT, RIGHT = 2938.36011, 1880.03003
local TOP, BOTTOM = 10238.32031, 9532.58984
local MIN_GX, MAX_GX, MIN_GY, MAX_GY = 423, 455, 204, 225

-- Rows correspond to Kalimdor terrain-chunk Y indices. Uppercase letters
-- represent one of five districts; other letters represent other terrain.
local rows = {
    [204] = "aaaaaaaAAAAAAAAAAABBBBBBBBaaaaaaa",
    [205] = "aaaaaaAAAAAAAAAAABBBBBBBBBaaaaaaa",
    [206] = "aaaaaaAAAAAAAAAABBBBBBBBBBPaaaaaa",
    [207] = "aaaaaaAAAAAAAAABBBBBBBBBBBPaaaaaa",
    [208] = "aaaaaaAAAAAAAAABBBBBBBBBBBPPaaaaa",
    [209] = "aaaaaaAAAAAAAAABBBBBBBBBBPPPaaaaa",
    [210] = "aaaaaPAAAAAAAAABBBBBBBBBPPPPPaaaa",
    [211] = "aaaPPPAAAAPPPPPBBBBCCCPPPPPPPaaaa",
    [212] = "aaaPPPPAAPPPPPPPPPCCCCPPPPPPPaaaa",
    [213] = "aaaPPPPPPPPPPPPCCCCCCCPPPPPPPaaaa",
    [214] = "aaaPPDDDDPPPPPPEEECCCCPPPPPPPaaaa",
    [215] = "aaaaaDDDDPPDDDEEEEEECEEEEPPPPaaaa",
    [216] = "aaaaaDDDDDDDDDEEEEEEEEEEEPPPPaaaa",
    [217] = "aaaaaDDDDDDDDDEEEEEEEEEEEPPPPaabb",
    [218] = "aaaaaaDDDDDDDDDDDEEEEEEEEPPPaaabb",
    [219] = "aaaaaaDDDDDDDDDDDEEEEEEEEPPaaaabb",
    [220] = "caaaaaDDDDDDDDDDDEEEEEEEEPPaaaabb",
    [221] = "caaaaaDDDDDDDDDDDEEEEEEEEPaaaaabb",
    [222] = "caaaaaDDDDDDDDDDDEEEEEEEEPaaabbbb",
    [223] = "caaaaaDDDDDDDDDDDEEEEEEEEaaaabbbb",
    [224] = "caaaaaaDDDDDDDDDDEEEEEEEEaaddbbbb",
    [225] = "caaaaaaDDDDDDDDDDEEEEEEEaaddddbbb",
}
local keys = {
    A = "cenarion enclave",
    B = "craftsmens terrace",
    C = "warriors terrace",
    D = "temple gardens",
    E = "tradesmens terrace",
}
-- All dimensions are relative to the original 1002 x 668 map canvas.
-- The BLP2 textures are generated from the same grid. Black background,
-- RGB additive light sampled after Gaussian silhouette smoothing + feather.
local prefix = "Interface\\AddOns\\SoftSpoken_Places\\Textures\\TerrainHighlights\\"
local highlights = {
    ["cenarion enclave"] = {file=prefix.."CenarionEnclave",x=145,y=0,w=414,h=275,tw=512,th=512},
    ["craftsmens terrace"] = {file=prefix.."CraftsmensTerrace",x=429,y=0,w=382,h=243,tw=512,th=256},
    ["warriors terrace"] = {file=prefix.."WarriorsTerrace",x=429,y=177,w=256,h=192,tw=256,th=256},
    ["temple gardens"] = {file=prefix.."TempleGardens",x=113,y=271,w=414,h=397,tw=512,th=512},
    ["tradesmens terrace"] = {file=prefix.."TradesmensTerrace",x=398,y=271,w=382,h=397,tw=512,th=512},
}
function M.AreaAt(mapID, x, y)
    if mapID ~= 1457 or type(x) ~= "number" or type(y) ~= "number" or
       x < 0 or x > 1 or y < 0 or y > 1 then return nil end
    local worldY = LEFT - x * (LEFT - RIGHT)
    local worldX = TOP - y * (TOP - BOTTOM)
    local gx = math.floor(512 - worldY / CHUNK)
    local gy = math.floor(512 - worldX / CHUNK)
    if gx < MIN_GX or gx > MAX_GX or gy < MIN_GY or gy > MAX_GY then return nil end
    local line = rows[gy]
    local letter = line and string.sub(line, gx - MIN_GX + 1, gx - MIN_GX + 1)
    return keys[letter]
end
function M.HighlightFor(mapID, key)
    if mapID ~= 1457 then return nil end
    return highlights[key]
end
