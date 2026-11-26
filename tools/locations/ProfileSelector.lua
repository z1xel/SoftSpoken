-- L5 prototype. Not loaded by SoftSpoken until L6.
-- Evidence MUST originate from an independent client-data fingerprint adapter.
-- Never pass the catalog's own expected fingerprint back as observed evidence.
local Selector = {}
local names = { "AreaTable", "Map", "WorldMapArea", "WorldMapOverlay" }

local function Complete(hashes)
    if type(hashes) ~= "table" then return false end
    for _, name in ipairs(names) do
        local h = hashes[name]
        if type(h) ~= "string" or string.len(h) ~= 64 or string.find(h, "[^0-9a-f]") then
            return false
        end
    end
    return true
end

function Selector.Select(profiles, evidence)
    if type(profiles) ~= "table" or type(evidence) ~= "table" or
        type(evidence.world) ~= "string" or evidence.world == "" or
        not Complete(evidence.fingerprint) then
        return nil, "unavailable"
    end
    local matches = {}
    for id, profile in pairs(profiles) do
        if profile.world == evidence.world and Complete(profile.fingerprint) then
            local match = true
            for _, name in ipairs(names) do
                if profile.fingerprint[name] ~= evidence.fingerprint[name] then match = false end
            end
            if match then table.insert(matches, id) end
        end
    end
    local count = table.getn(matches)
    if count == 1 then return matches[1], "resolved" end
    if count == 0 then return nil, "unknown" end
    table.sort(matches)
    return nil, "ambiguous", matches
end

return Selector
