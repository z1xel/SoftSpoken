setfenv(1, SpokenEnv)

-- Turtle WoW (Lua 5.0) compatibility. Private to SpokenEnv: no global client
-- polyfills are installed for other addons. Load after UI and core modules.

-- Lua and UI shims needed by the 1.12 player.
if not select then
    function select(index, ...)
        if index == "#" then
            return arg.n
        else
            local result = {}
            for i = index, arg.n do
                table.insert(result, arg[i])
            end
            return unpack(result)
        end
    end
end

if not print or Version.IsLegacyVanilla then
    local argn, argi = "arg.n", "arg[i]"
    print = loadstring(format([[return function(...)
        local text = ""
        for i = 1, %s do
            text = text .. (i > 1 and " " or "") .. tostring(%s)
        end
        DEFAULT_CHAT_FRAME:AddMessage(text)
    end]], argn, argi))()
end

-- Vanilla PlaySound uses string names instead of SOUNDKIT numeric constants.
if not SOUNDKIT then
    SOUNDKIT = {
        U_CHAT_SCROLL_BUTTON = "uChatScrollButton",
        IG_QUEST_LOG_CLOSE = "igQuestLogClose",
        IG_MAINMENU_OPEN = "igMainMenuOpen",
        IG_MAINMENU_CLOSE = "igMainMenuClose",
    }
end

if not strsplit then
    function strsplit(delimiter, text)
        local result = {}
        local from = 1
        local delim_from, delim_to = string.find(text, delimiter, from)
        while delim_from do
            table.insert(result, string.sub(text, from, delim_from - 1))
            from = delim_to + 1
            delim_from, delim_to = string.find(text, delimiter, from)
        end
        table.insert(result, string.sub(text, from))
        return unpack(result)
    end
end

if not string.gmatch then
    string.gmatch = string.gfind
end

if not string.match then
    local function getargs(s, e, ...)
        return unpack(arg)
    end
    function string.match(str, pattern)
        return getargs(string.find(str, pattern))
    end
end

if not string.trim then
    function string.trim(str)
        return (string.match(str, "^%s*(.-)%s*$"))
    end
end

if not table.wipe then
    function table.wipe(tbl)
        for key in next, tbl do
            tbl[key] = nil
        end
    end
end
if not wipe then
    wipe = table.wipe
end

if not hooksecurefunc then
    ---@overload fun(name, hook)
    function hooksecurefunc(table, name, hook)
        if not hook then
            name, hook = table, name
            table = _G
        end

        local old = table[name]
        assert(type(old) == "function")
        table[name] = function(...)
            local result = { old(unpack(arg)) }
            hook(unpack(arg))
            return unpack(result)
        end
    end
end

if not GetAddOnEnableState then
    ---@overload fun(addon)
    function GetAddOnEnableState(character, addon)
        addon = addon or character
        local name, _, _, _, loadable, reason = _G.GetAddOnInfo(addon)
        if not name or not loadable and reason == "DISABLED" then
            return 0
        end
        return 2
    end

    function GetAddOnInfo(indexOrName)
        local name, title, notes, enabled, loadable, reason, security, newVersion = _G.GetAddOnInfo(indexOrName)
        return name, title, notes, loadable, reason, security, newVersion
    end
end

-- Keep the API available if a custom client omits the global helper.
if not MouseIsOver then
    function MouseIsOver(frame, topOffset, bottomOffset, leftOffset, rightOffset)
        return frame:IsMouseOver(topOffset, bottomOffset, leftOffset, rightOffset)
    end
end

--------------------------------------------------------------------------- frames
--
-- Everything the UI builds goes through this file's CreateFrame, which applies what an
-- old client lacks (SetShown, SetSize, SetResizeBounds, Get*Texture, HookScript...) as
-- mixins and overrides on the frame it returns. Lifted from the quests addon.

local RegionMixins = {}
local RegionOverrides = {}
local FrameMixins = {}
local FrameOverrides = {}
local FontStringMixins = {}
local ModelMixins = {}
local function ApplyMixinsAndOverrides(self, mixins, overrides)
    if mixins then
        for k, v in pairs(mixins) do
            if not self[k] then
                self[k] = v
            end
        end
    end
    if overrides then
        for k, v in pairs(overrides) do
            if self[k] then
                self["_" .. k], self[k] = self[k], v
            end
        end
    end
end
local hookModel
function CreateFrame(frameType, name, parent, template)
    if UIParent.SetBackdrop and template == "BackdropTemplate" then
        template = nil
    end

    local frame = _G.CreateFrame(frameType, name, parent, template)
    ApplyMixinsAndOverrides(frame, RegionMixins, RegionOverrides)
    ApplyMixinsAndOverrides(frame, FrameMixins, FrameOverrides)
    if frameType == "Model" or frameType == "PlayerModel" or frameType == "DressUpModel" then
        ApplyMixinsAndOverrides(frame, ModelMixins)
        if hookModel then
            hookModel(frame)
        end
    end
    return frame
end

function RegionMixins:SetShown(shown)
    if shown then
        self:Show()
    else
        self:Hide()
    end
end
function RegionMixins:SetSize(width, height)
    self:SetWidth(width)
    self:SetHeight(height)
end
function FrameMixins:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight)
    self:SetMinResize(minWidth, minHeight)
    if maxWidth and maxHeight then
        self:SetMaxResize(maxWidth, maxHeight)
    end
end
function ModelMixins:SetAnimation(animation)
    self:SetSequence(animation)
end
function ModelMixins:SetCustomCamera(camera)
    self:SetCamera(camera)
end

-- Model IDs permit the legacy portrait renderer to recognize loaded models and
-- retrieve animation durations. Keep the extended paths for Turtle custom models.
local modelToFileID = {
    ["interface/buttons/talktomequestion_white"]                = 130737,

    ["character/bloodelf/female/bloodelffemale"]                = 116921,
    ["character/bloodelf/male/bloodelfmale"]                    = 117170,
    ["character/broken/female/brokenfemale"]                    = 117400,
    ["character/broken/male/brokenmale"]                        = 117412,
    ["character/draenei/female/draeneifemale"]                  = 117437,
    ["character/draenei/male/draeneimale"]                      = 117721,
    ["character/dwarf/female/dwarffemale"]                      = 118135,
    ["character/dwarf/female/dwarffemale_hd"]                   = 950080,
    ["character/dwarf/female/dwarffemale_npc"]                  = 950080,
    ["character/dwarf/male/dwarfmale"]                          = 118355,
    ["character/dwarf/male/dwarfmale_hd"]                       = 878772,
    ["character/dwarf/male/dwarfmale_npc"]                      = 878772,
    ["character/felorc/female/felorcfemale"]                    = 118652,
    ["character/felorc/male/felorcmale"]                        = 118653,
    ["character/felorc/male/felorcmaleaxe"]                     = 118654,
    ["character/felorc/male/felorcmalesword"]                   = 118667,
    ["character/foresttroll/male/foresttrollmale"]              = 118798,
    ["character/gnome/female/gnomefemale"]                      = 119063,
    ["character/gnome/female/gnomefemale_hd"]                   = 940356,
    ["character/gnome/female/gnomefemale_npc"]                  = 940356,
    ["character/gnome/male/gnomemale"]                          = 119159,
    ["character/gnome/male/gnomemale_hd"]                       = 900914,
    ["character/gnome/male/gnomemale_npc"]                      = 900914,
    ["character/goblin/female/goblinfemale"]                    = 119369,
    ["character/goblin/male/goblinmale"]                        = 119376,
    ["character/goblinold/male/goblinoldmale"]                  = 119376,
    ["character/human/female/humanfemale"]                      = 119563,
    ["character/human/female/humanfemale_hd"]                   = 1000764,
    ["character/human/female/humanfemale_npc"]                  = 1000764,
    ["character/human/male/humanmale"]                          = 119940,
    ["character/human/male/humanmale_cata"]                     = 119940,
    ["character/human/male/humanmale_hd"]                       = 1011653,
    ["character/human/male/humanmale_npc"]                      = 1011653,
    ["character/icetroll/male/icetrollmale"]                    = 232863,
    ["character/naga_/female/naga_female"]                      = 120263,
    ["character/naga_/male/naga_male"]                          = 120294,
    ["character/nightelf/female/nightelffemale"]                = 120590,
    ["character/nightelf/female/nightelffemale_hd"]             = 921844,
    ["character/nightelf/female/nightelffemale_npc"]            = 921844,
    ["character/nightelf/male/nightelfmale"]                    = 120791,
    ["character/nightelf/male/nightelfmale_hd"]                 = 974343,
    ["character/nightelf/male/nightelfmale_npc"]                = 974343,
    ["character/northrendskeleton/male/northrendskeletonmale"]  = 233367,
    ["character/orc/female/orcfemale"]                          = 121087,
    ["character/orc/female/orcfemale_npc"]                      = 121087,
    ["character/orc/male/orcmale"]                              = 121287,
    ["character/orc/male/orcmale_hd"]                           = 917116,
    ["character/orc/male/orcmale_npc"]                          = 917116,
    ["character/scourge/female/scourgefemale"]                  = 121608,
    ["character/scourge/female/scourgefemale_hd"]               = 997378,
    ["character/scourge/female/scourgefemale_npc"]              = 997378,
    ["character/scourge/male/scourgemale"]                      = 121768,
    ["character/scourge/male/scourgemale_hd"]                   = 959310,
    ["character/scourge/male/scourgemale_npc"]                  = 959310,
    ["character/skeleton/male/skeletonmale"]                    = 121942,
    ["character/taunka/male/taunkamale"]                        = 233878,
    ["character/tauren/female/taurenfemale"]                    = 121961,
    ["character/tauren/female/taurenfemale_hd"]                 = 986648,
    ["character/tauren/female/taurenfemale_npc"]                = 986648,
    ["character/tauren/male/taurenmale"]                        = 122055,
    ["character/tauren/male/taurenmale_hd"]                     = 968705,
    ["character/tauren/male/taurenmale_npc"]                    = 968705,
    ["character/troll/female/trollfemale"]                      = 122414,
    ["character/troll/female/trollfemale_hd"]                   = 1018060,
    ["character/troll/female/trollfemale_npc"]                  = 1018060,
    ["character/troll/male/trollmale"]                          = 122560,
    ["character/troll/male/trollmale_hd"]                       = 1022938,
    ["character/troll/male/trollmale_npc"]                      = 1022938,
    ["character/tuskarr/male/tuskarrmale"]                      = 122738,
    ["character/vrykul/male/vrykulmale"]                        = 122815,
}
local function CleanupModelName(model)
    model = string.lower(model)
    model = string.gsub(model, "\\", "/")
    model = string.gsub(model, "%.m2", "")
    model = string.gsub(model, "%.mdx", "")
        return model
    end
function ModelMixins:GetModelFileID()
    local model = self:GetModel()
    if model and type(model) == "string" then
        model = CleanupModelName(model)
        return modelToFileID[model]
    end
    end

-- Vanilla event/this and tooltip compatibility.
function RegionOverrides:SetPoint(point, region, relativeFrame, offsetX, offsetY)
        if region == nil and relativeFrame == nil and offsetX == nil and offsetY == nil then
            self:_SetPoint(point, 0, 0)
        else
            self:_SetPoint(point, region, relativeFrame, offsetX, offsetY)
        end
    end
    function FrameOverrides:SetScript(script, handler)
        -- Vanilla can clear a callback via SetScript(script, nil).
        if handler == nil then
            return self:_SetScript(script, nil)
        end
        self:_SetScript(script, script == "OnEvent"
            and function() handler(this, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) end
            or  function() handler(this,        arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) end)
    end
    function FrameMixins:HookScript(script, handler)
        local old = self:GetScript(script)
        self:_SetScript(script, script == "OnEvent"
            and function() if old then old() end handler(this, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) end
            or  function() if old then old() end handler(this,        arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) end)
    end


    hooksecurefunc(GameTooltip, "SetOwner", function(self, owner, anchor)
        self._owner = owner
    end)
    function GameTooltip:GetOwner()
        return self._owner
    end

-- Vanilla portrait pooling and frame/texture shims.
local modelFramePool = {}
    function Portrait:AcquireModelFrame(portrait, clip)
        if portrait.pooledModel and portrait.pooledModel._inUse then
            return portrait.pooledModel
        end

        local frame
        for _, pooled in ipairs(modelFramePool) do
            if not pooled._inUse then
                frame = pooled
                break
            end
        end

        if not frame then
            frame = CreateFrame("PlayerModel", nil, portrait)
            table.insert(modelFramePool, frame)
        end

        frame._inUse = true
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMLEFT")
        frame:SetSize(1, 1)
        frame:Show()
        frame:SetUnit("npc")

        portrait.pooledModel = frame
        return frame
    end
    function Portrait:ReleaseModelFrame(portrait, frame)
        if not frame then
            return
        end
        if portrait.pooledModel == frame then
            portrait.pooledModel = nil
        end
        frame:Hide()
        frame:ClearModel()
        frame._inUse = false
    end


    function hookModel(self)
        self._sequence = 0
        hooksecurefunc(self, "ClearModel", function(self)
            self._sequence = 0
            self._sequenceStart = nil
        end)
        hooksecurefunc(self, "SetSequence", function(self, sequence)
            self._sequence = sequence
            self._sequenceStart = GetTime()
        end)
        self:HookScript("OnUpdate", function(self, elapsed)
            if self._sequence ~= 0 then
                self:SetSequenceTime(self._sequence, (GetTime() - self._sequenceStart) * 1000)
            end
        end)
    end

    function FrameOverrides:HookScript(script, handler)
        if self:GetScript(script) then
            self:_HookScript(script, handler)
        else
            self:SetScript(script, handler)
        end
    end
    function FrameOverrides:CreateTexture(name, layer)
        local region = self:_CreateTexture(name, layer)
        ApplyMixinsAndOverrides(region, RegionMixins, RegionOverrides)
        return region
    end
    function FrameOverrides:CreateFontString(name, layer, template)
        local region = self:_CreateFontString(name, layer, template)
        ApplyMixinsAndOverrides(region, RegionMixins, RegionOverrides)
        ApplyMixinsAndOverrides(region, FontStringMixins)
        return region
    end
    function FrameOverrides:SetNormalTexture(file)
        local texture = self:CreateTexture(nil, "ARTWORK")
        local success = texture:SetTexture(file)
        texture:SetAllPoints()
        self._normalTexture = texture
        self:_SetNormalTexture(texture)
        return success
    end
    function FrameMixins:GetNormalTexture()
        return self._normalTexture
    end
    function FrameOverrides:SetPushedTexture(file)
        local texture = self:CreateTexture(nil, "ARTWORK")
        local success = texture:SetTexture(file)
        texture:SetAllPoints()
        self._pushedTexture = texture
        self:_SetPushedTexture(texture)
        return success
    end
    function FrameMixins:GetPushedTexture()
        return self._pushedTexture
    end
    function FrameOverrides:SetDisabledTexture(file)
        local texture = self:CreateTexture(nil, "ARTWORK")
        local success = texture:SetTexture(file)
        texture:SetAllPoints()
        self._disabledTexture = texture
        self:_SetDisabledTexture(texture)
        return success
    end
    function FrameMixins:GetDisabledTexture()
        return self._disabledTexture
    end
    function FrameOverrides:SetHighlightTexture(file)
        local texture = self:CreateTexture(nil, "HIGHLIGHT")
        local success = texture:SetTexture(file)
        texture:SetAllPoints()
        self._highlightTexture = texture
        self:_SetHighlightTexture(texture)
        return success
    end
    function FrameMixins:GetHighlightTexture()
        return self._highlightTexture
    end
    function FontStringMixins:SetWordWrap(wrap)
        if not wrap then
            self:SetHeight((select(2, self:GetFont())))
        end
    end
    function ModelMixins:SetCreature()
    end

    function GameTooltip_Hide()
        -- Used for XML OnLeave handlers
        GameTooltip:Hide()
    end

-- One implementation of the vanilla client primitives is shared with modules.
-- Feature addons retain their private environments; no global CreateFrame or
-- Lua compatibility functions are replaced. Core loads before its modules.
--
-- The few unavoidable game-global hooks (GameTooltip and AceGUI's
-- SetDesaturation helper) are installed once here rather than in Quests.
if not _G.SetDesaturation then
    function _G.SetDesaturation(texture, desaturation)
        local shaderSupported = texture.SetDesaturated and texture:SetDesaturated(desaturation)
        if not shaderSupported then
            if desaturation then
                texture:SetVertexColor(0.5, 0.5, 0.5)
            else
                texture:SetVertexColor(1.0, 1.0, 1.0)
            end
        end
    end
end

-- SetCursor was introduced after 1.12. Quests uses it for optional UI hints.
if not SetCursor then
    function SetCursor() end
end

Spoken.Compat = Spoken.Compat or {}
local sharedPrimitives = {
    "CreateFrame", "select", "print", "strsplit", "wipe", "hooksecurefunc",
    "SOUNDKIT", "GetAddOnInfo", "GetAddOnEnableState",
    "MouseIsOver", "GameTooltip_Hide", "SetCursor",
}
function Spoken.Compat.InstallClientShims(target)
    assert(type(target)=="table", "Expected a private addon environment")
    for _,name in ipairs(sharedPrimitives) do
        -- rawget: do not confuse the target's _G fallback with a private shim.
        local implementation=rawget(SpokenEnv,name)
        if implementation~=nil then rawset(target,name,implementation) end
    end
end
