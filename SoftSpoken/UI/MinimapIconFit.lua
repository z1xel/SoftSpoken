-- Adjust SoftSpoken's actual LibDBIcon minimap widget instead of modifying a
-- shared library whose createButton implementation might not be the one loaded.
-- This file is loaded directly after MinimapButton.lua.
setfenv(1, SpokenEnv)

local function ApplyFit()
    local lib = LibStub and LibStub("LibDBIcon-1.0", true)
    local button = lib and lib.GetMinimapButton and lib:GetMinimapButton("Spoken")
    if not (button and button.icon) then return end

    local icon = button.icon
    icon:SetWidth(26)
    icon:SetHeight(26)
    icon:ClearAllPoints()
    icon:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -2)
end

local previousSetup = Minimap.Setup
function Minimap:Setup()
    previousSetup(self)
    ApplyFit()
end

local previousRefresh = Minimap.Refresh
function Minimap:Refresh()
    previousRefresh(self)
    ApplyFit()
end

-- Covers versions that may already have registered the minimap button.
ApplyFit()
