setfenv(1, SpokenEnv)

-- The old full modules are not migration helpers. Disable only these exact
-- folders before the client reaches them if possible; never touch voice packs
-- or SavedVariables. DisableAddOn is not an unload operation.
UpgradeGuard = {}
local retired = {
    SoftSpoken_Stories = true,
    SoftSpoken_Places = true,
    SoftSpoken_Writings = true,
}
local attempted = {}

local function Installed()
    local result = {}
    if not _G.GetNumAddOns or not _G.GetAddOnInfo then return result end
    for i = 1, _G.GetNumAddOns() do
        local name, _, _, enabled, loadable = _G.GetAddOnInfo(i)
        if retired[name] then
            -- Raw Vanilla GetAddOnInfo returns enabled as its fourth value.
            -- A string in the fifth slot identifies the newer API's reason.
            -- In particular, nil loadable is valid for a disabled Vanilla addon.
            if type(loadable) == "string" then
                enabled = loadable ~= "DISABLED"
            end
            result[name] = enabled ~= nil and enabled ~= false and enabled ~= 0
        end
    end
    return result
end

local function Loaded(name)
    if not _G.IsAddOnLoaded then return false end
    local value = _G.IsAddOnLoaded(name)
    return value == true or value == 1
end

function UpgradeGuard:Prepare()
    for name, enabled in pairs(Installed()) do
        if enabled and not attempted[name] then
            attempted[name] = true
            if _G.DisableAddOn then pcall(_G.DisableAddOn, name) end
        end
    end
end

function UpgradeGuard:CanStart()
    local conflicts, disabled = {}, {}
    local installed = Installed()
    for name in pairs(retired) do
        if Loaded(name) or installed[name] then
            table.insert(conflicts, name)
        elseif attempted[name] then
            table.insert(disabled, name)
        end
    end
    table.sort(conflicts)
    table.sort(disabled)
    if table.getn(conflicts) > 0 then
        if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff4040SoftSpoken: Old modules conflict with the unified installation: " ..
                table.concat(conflicts, ", ") ..
                ". Exit the game, remove the old AddOns folders (keep WTF), then restart. Unified startup was stopped.|r")
        end
        return false
    end
    if table.getn(disabled) > 0 and DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff80SoftSpoken: Disabled obsolete module folders: " ..
            table.concat(disabled, ", ") .. ". Remove them from AddOns; retain your WTF directory.|r")
    end
    return true
end

UpgradeGuard:Prepare()
