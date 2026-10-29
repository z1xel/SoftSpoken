setfenv(1, SpokenEnv)

-- The portrait: what the frame shows beside the queue for the clip that is speaking.
--
-- A renderer per `kind`, so the player never learns what a GUID or a zone is. A clip's
-- presentation names a kind and the arguments that kind needs; three ship here, and a
-- feature addon may register its own through Spoken:RegisterPortraitRenderer.
--
--   { kind = "texture", texture = [[...]], texCoord = { l, r, t, b } }
--   { kind = "texture", texture = [[...]], fit = "cover", aspectRatio = 2 }
--     cover center-crops to the player's square portrait without distorting art.
--     Explicit texCoord overrides fit; existing icon/material portraits are unchanged.
--   { kind = "model",   creatureID = 196, animation = 60, fallback = { kind = "texture", ... } }
--   { kind = "none" }
--
-- A renderer's Update returns false when it has nothing to draw -- a model with no
-- creature, a creature the client has not cached -- and the portrait then draws the
-- spec's `fallback` instead, once. That is VoiceOverRedux's ShouldShowBookFor turned
-- inside out: the book for Items, GameObjects, missing GUIDs, 2.4.3 and unloaded models
-- is now the quests addon's fallback rather than the player's knowledge.
Portrait = {}

local TEXTURES = [[Interface\AddOns\Spoken\Textures\]]
local WAIT_FOR_ANIMATION_FINISH_BEFORE_IDLE = true
local CAN_MODEL_LOAD_CACHE = Version:IsRetailOrAboveLegacyVersion(60000)

--------------------------------------------------------------------------------
-- Animation durations, by model FileDataID. Lifted whole from the quests addon's
-- Utils.lua: 200 lines about models, none about quests.
--------------------------------------------------------------------------------
local animationDurations = {
    ["Original"] = {
        [130737]  = { [60] = 1533 }, -- interface/buttons/talktomequestion_white
        [116921]  = { [60] = 4000 }, [1100258] = { [60] = 4000 }, -- bloodelf female
        [117170]  = { [60] = 2000 }, [1100087] = { [60] = 2000 }, -- bloodelf male
        [117400]  = { [60] = 2934 }, [117412]  = { [60] = 2934 }, -- broken
        [117437]  = { [60] = 3000 }, [1022598] = { [60] = 3000 }, -- draenei female
        [117721]  = { [60] = 3334 }, [1005887] = { [60] = 3334 }, -- draenei male
        [118135]  = { [60] = 2000 }, [950080]  = { [60] = 2000 }, -- dwarf female
        [118355]  = { [60] = 2000 }, [878772]  = { [60] = 2000 }, -- dwarf male
        [118652]  = { [60] = 2000 }, [118653]  = { [60] = 2000 }, [118654] = { [60] = 2000 }, [118667] = { [60] = 2000 }, -- felorc
        [118798]  = { [60] = 2500 }, -- foresttroll
        [119063]  = { [60] = 4000 }, [940356]  = { [60] = 4000 }, -- gnome female
        [119159]  = { [60] = 4000 }, [900914]  = { [60] = 4000 }, -- gnome male
        [119369]  = { [60] = 1800 }, [119376]  = { [60] = 1800 }, -- goblin
        [119563]  = { [60] = 2667 }, [1000764] = { [60] = 2667 }, -- human female
        [119940]  = { [60] = 2000 }, [1011653] = { [60] = 2000 }, -- human male
        [232863]  = { [60] = 2500 }, -- icetroll
        [120263]  = { [60] = 3000 }, [120294]  = { [60] = 3000 }, -- naga
        [120590]  = { [60] = 2100 }, [921844]  = { [60] = 2100 }, -- nightelf female
        [120791]  = { [60] = 2000 }, [974343]  = { [60] = 2000 }, -- nightelf male
        [233367]  = { [60] = 3600 }, -- northrendskeleton
        [121087]  = { [60] = 2000 }, [949470]  = { [60] = 2000 }, -- orc female
        [121287]  = { [60] = 2000 }, [917116]  = { [60] = 2000 }, -- orc male
        [121608]  = { [60] = 2000 }, [997378]  = { [60] = 2467 }, -- scourge female
        [121768]  = { [60] = 2667 }, [959310]  = { [60] = 2667 }, -- scourge male
        [121942]  = { [60] = 2667 }, -- skeleton
        [233878]  = { [60] = 2934 }, -- taunka
        [121961]  = { [60] = 2934 }, [986648]  = { [60] = 2934 }, -- tauren female
        [122055]  = { [60] = 2934 }, [968705]  = { [60] = 2934 }, -- tauren male
        [122414]  = { [60] = 2500 }, [1018060] = { [60] = 2500 }, -- troll female
        [122560]  = { [60] = 2500 }, [1022938] = { [60] = 2500 }, -- troll male
        [122738]  = { [60] = 3000 }, -- tuskarr
        [122815]  = { [60] = 3600 }, -- vrykul
    },
    -- HD overrides for model files which did not get a separate HD version
    ["HD"] = {
        [119369] = { [60] = 4667 },
        [119376] = { [60] = 4667 },
    },
}
if Version.IsLegacyVanilla or Version.IsRetailVanilla then
    -- Goblin models on vanilla (both 1.12 and 1.15) lack the talk animation; 0 makes
    -- them fall back to idle.
    animationDurations["Original"][119369][60] = 0
    animationDurations["Original"][119376][60] = 0
end

--- Which model set durations are looked up in. Compat.lua overrides this for the
--- clients with HD model patches and for Mainline.
function Portrait:GetCurrentModelSet()
    return "Original"
end

--- Frame a loaded model on its head. Every client this addon has run on embeds a
--- portrait camera at index 0 in the creature's M2, and selecting it is what makes the
--- portrait a portrait rather than a figure standing in a box; Compat.lua overrides this
--- for Camelot, whose engine accepts the call and ignores it.
function Portrait:FrameHead(model)
    model:SetCustomCamera(0)
end

---@return number|nil seconds  0 if the model is known to lack the animation
--- Whether a model frame has something to draw.
---
--- Model:GetModel returned a path and was removed from the current clients, which answer
--- GetModelFileID instead; Compat.lua supplies GetModelFileID on the legacy ones
--- from their GetModel. Asking for the method this client does not have is an error, not
--- a nil, and one raised here abandons the whole frame update -- the portrait is drawn
--- before the rows, so the queue reads as empty.
function Portrait:ModelLoaded(model)
    if model.GetModelFileID then
        return model:GetModelFileID() ~= nil
    end
    if model.GetModel then
        return type(model:GetModel()) == "string"
    end
    -- Neither: assume it loaded rather than falling back on every clip forever.
    return true
end

function Portrait:GetModelAnimationDuration(model, animation)
    if not model or model == 123 then return end
    local models = animationDurations[self:GetCurrentModelSet()] or animationDurations["Original"]
    local animations = models[model] or animationDurations["Original"][model]
    local duration = animations and animations[animation]
    return duration and duration / 1000
end

--------------------------------------------------------------------------------
-- The model frame. One per portrait on current clients; 1.12 and 2.4.3 cannot show an
-- arbitrary creature in a DressUpModel and get one from a pool instead (Compat.lua).
--------------------------------------------------------------------------------

function Portrait:AcquireModelFrame(portrait, clip)
    if not portrait.model then
        portrait.model = CreateFrame("DressUpModel", nil, portrait)
        portrait.model:SetAllPoints()
    end
    return portrait.model
end

function Portrait:ReleaseModelFrame(portrait, frame)
end

local function InitModelFrame(model)
    if model._initialized then return end
    model._initialized = true
    model:HookScript("OnHide", function(self)
        self:ClearModel()
        self.oldCreatureID = nil
        self.animation = nil
        self.animDuration = nil
        self.animDelay = nil
        self.animtimer = nil
    end)
    model:HookScript("OnUpdate", function(self, elapsed)
        -- If the creature was not cached, keep retrying until it is.
        if CAN_MODEL_LOAD_CACHE and self.oldCreatureID and not self:GetModelFileID() then
            self:SetCreature(self.oldCreatureID)
            if not self:GetModelFileID() then return end
        end
        Portrait:FrameHead(self)
        if self.animation and not self.animDuration then
            self.animDuration = Portrait:GetModelAnimationDuration(self:GetModelFileID(), self.animation)
            if self.animDuration and self.animDuration == 0 then
                self.animation = 0
                self:SetAnimation(self.animation)
            end
        end
        if self.animDelay and not SoundQueue:IsPaused() then
            self.animDelay = self.animDelay - elapsed
            if self.animDelay < 0 then self.animDelay = nil else return end
        end
        local isPaused = not SoundQueue:IsPlaying()
        if not WAIT_FOR_ANIMATION_FINISH_BEFORE_IDLE and self.animation and self.animation ~= 0 and not self.animDelay and isPaused then
            self.animation = 0
            self.animtimer = nil
            self:SetAnimation(self.animation)
        end
        if self.animation and GetTime() - (self.animtimer or 0) >= (self.animDuration or 2) then
            if isPaused or self.animation == 0 then
                if WAIT_FOR_ANIMATION_FINISH_BEFORE_IDLE and self.animation ~= 0 and not self.animDelay then
                    self.animation = 0
                    self.animtimer = nil
                    self:SetAnimation(self.animation)
                end
            else
                self.animtimer = GetTime()
                self:SetAnimation(self.animation)
            end
        end
        self.wasPaused = isPaused
    end)
end

--------------------------------------------------------------------------------
-- The three built-in renderers
--------------------------------------------------------------------------------

Renderers["none"] = {
    Acquire = function(portrait) return nil end,
    Update = function(frame, clip, spec) return true end,
    Release = function(frame) end,
}

-- Source-image width / height. The player portrait is square on 1.12.
-- Preserve whole height for landscapes, whole width for portraits.
function Portrait:CoverTexCoord(aspectRatio)
    local ratio = tonumber(aspectRatio)
    if not ratio or ratio <= 0 then return nil end
    if ratio >= 1 then
        local crop = 1 / ratio
        local left = (1 - crop) / 2
        return { left, 1 - left, 0, 1 }
    end
    local top = (1 - ratio) / 2
    return { 0, 1, top, 1 - top }
end

Renderers["texture"] = {
    Acquire = function(portrait)
        if not portrait.texture then
            portrait.texture = portrait:CreateTexture(nil, "ARTWORK")
            portrait.texture:SetAllPoints()
        end
        portrait.texture:Show()
        return portrait.texture
    end,
    Update = function(texture, clip, spec)
        if not spec.texture then return false end
        texture:SetTexture(spec.texture)
        local c = spec.texCoord
        if not c and spec.fit == "cover" then
            c = Portrait:CoverTexCoord(spec.aspectRatio)
        end
        c = c or { 8 / 256, 248 / 256, 8 / 256, 248 / 256 }
        texture:SetTexCoord(c[1], c[2], c[3], c[4])
        return true
    end,
    Release = function(texture) texture:Hide() end,
}

Renderers["model"] = {
    Acquire = function(portrait, clip)
        local model = Portrait:AcquireModelFrame(portrait, clip)
        InitModelFrame(model)
        model:Show()
        return model
    end,
    Update = function(model, clip, spec)
        local creatureID = spec.creatureID
        if not creatureID then return false end
        if creatureID ~= model.oldCreatureID then
            if CAN_MODEL_LOAD_CACHE then model:ClearModel() end
            model:SetCreature(creatureID)
            Portrait:FrameHead(model)
            model:SetModelScale(2)
            model.animation = spec.animation or 60
            model.animDuration = nil
            model.animDelay = clip.delay
            model.animtimer = nil
            model.oldCreatureID = creatureID
        elseif model.wasPaused and SoundQueue:IsPlaying() then
            model.animation = spec.animation or 60
            model.animDuration = nil
            model.animDelay = clip.delay
        end
        -- A model the client could not load draws nothing; say so, and the fallback shows.
        return Portrait:ModelLoaded(model)
    end,
    Release = function(model)
        model:Hide()
    end,
}

-- Request creature appearance data independently of audio and quest dispatch.
-- ClassicAPI's creature cache can populate asynchronously. A completion may
-- also fire synchronously during RequestLoadCreatureByID; defer player refresh
-- until OnUpdate to avoid reentering Portrait:Configure.
local requestedCreatures = {}
local creatureLoadFrame

local function OnCreatureDataLoaded(frame, eventName, id, success)
    -- Stock 1.12 events use global event/arg1/arg2; Compat.lua's CreateFrame
    -- shim passes them to the handler explicitly.
    frame = frame or creatureLoadFrame
    eventName = eventName or event
    id = id or arg1
    if success == nil then success = arg2 end
    if eventName ~= "CREATURE_DATA_LOAD_RESULT" then return end
    id = tonumber(id)
    if not id or id <= 0 then return end
    if success == false or success == nil or success == 0 then
        requestedCreatures[id] = nil -- permit a later retry after a failure
        return
    end
    -- More than one request can finish before a frame update. Do not let
    -- the most recent response overwrite an earlier, currently speaking NPC.
    frame.pendingIDs = frame.pendingIDs or {}
    frame.pendingIDs[id] = true
    frame:SetScript("OnUpdate", function(self)
        self = self or creatureLoadFrame
        self:SetScript("OnUpdate", nil)
        local ready = self.pendingIDs
        self.pendingIDs = nil
        if not ready or rawget(_G, "SoftSpokenClassicPortraits") == false then return end
        -- Never restart a clip or revive a previous speaker after the queue
        -- moves on. Only repaint the portrait for the current creature.
        local ok, clip = pcall(function()
            return Spoken and Spoken.GetCurrent and Spoken:GetCurrent()
        end)
        if not ok then return end
        local spec = clip and clip.present and clip.present.portrait
        local currentID = spec and tonumber(spec.creatureID)
        if spec and spec.kind == "creature" and currentID and ready[currentID] and
           Spoken and type(Spoken.RefreshPlayer) == "function" then
            pcall(Spoken.RefreshPlayer, Spoken)
        end
    end)
end

function Portrait:RequestCreatureData(creatureID)
    local api = C_CreatureInfo
    creatureID = tonumber(creatureID)
    if rawget(_G, "SoftSpokenClassicPortraits") == false or not api or
       not creatureID or creatureID <= 0 or
       type(api.RequestLoadCreatureByID) ~= "function" then return false end
    if requestedCreatures[creatureID] then return true end

    if not creatureLoadFrame then
        local ok, frame = pcall(CreateFrame, "Frame", nil, UIParent)
        if not ok or not frame then return false end
        local registered = pcall(frame.RegisterEvent, frame, "CREATURE_DATA_LOAD_RESULT")
        if not registered then return false end
        frame:SetScript("OnEvent", OnCreatureDataLoaded)
        creatureLoadFrame = frame
    end
    -- Mark before requesting: a cache hit can dispatch the event immediately.
    requestedCreatures[creatureID] = true
    local ok, accepted = pcall(api.RequestLoadCreatureByID, creatureID)
    if not ok or accepted == false then
        requestedCreatures[creatureID] = nil
        return false
    end
    return true
end

-- ClassicAPI changed the owner of SetDisplayInfo in October 2026:
--   old: Model:SetDisplayInfo, manual SetCamera and SetLight
--   new: PlayerModel:SetDisplayInfo, native skins/light/camera/portrait zoom
-- Detect frame capabilities, not version strings (forks can cherry-pick APIs).
-- Vanilla's Compat.lua adds a no-op SetCreature shim, so its presence alone
-- MUST NOT be used to detect model support.
local function Candidate(portrait, key, frameType)
    if portrait[key] == nil then
        local ok, frame = pcall(CreateFrame, frameType, nil, portrait)
        if ok and frame then
            frame:Hide()
            portrait[key] = frame
        else
            portrait[key] = false
        end
    end
    return portrait[key] or nil
end

function Portrait:AcquireCreatureModel(portrait)
    local modern = Candidate(portrait, "creaturePlayerModel", "PlayerModel")
    if modern and type(modern.SetDisplayInfo) == "function" then
        modern._spokenBackend = "player"
        modern:SetAllPoints(portrait)
        portrait.creatureModel = modern
        return modern
    end
    local legacy = Candidate(portrait, "creatureLegacyModel", "Model")
    if legacy and type(legacy.SetDisplayInfo) == "function" then
        legacy._spokenBackend = "model"
        legacy:SetAllPoints(portrait)
        portrait.creatureModel = legacy
        return legacy
    end
    return nil
end

-- Optional ClassicAPI creature renderer. It is visual only: failures must not
-- affect narration, quest lookup, or the player-frame update.
Renderers["creature"] = {
    Acquire = function(portrait)
        -- Keep candidates hidden until a valid display has been assigned.
        return Portrait:AcquireCreatureModel(portrait)
    end,
    Update = function(model, clip, spec)
        if not model or rawget(_G, "SoftSpokenClassicPortraits") == false then return false end
        local displayID = tonumber(spec.displayID)
        local creatureID = tonumber(spec.creatureID)
        if creatureID and creatureID <= 0 then creatureID = nil end
        if displayID and displayID <= 0 then displayID = nil end

        if not displayID and creatureID and C_CreatureInfo and
           type(C_CreatureInfo.GetCreatureInfoByID) == "function" then
            local ok, info = pcall(C_CreatureInfo.GetCreatureInfoByID, creatureID)
            if ok and type(info) == "table" then
                displayID = tonumber(info.displayID)
                if displayID and displayID <= 0 then displayID = nil end
            end
        end
        if not displayID then
            -- Never show the last speaker while a new NPC is being fetched.
            model:Hide()
            model._spokenDisplayID = nil
            Portrait:RequestCreatureData(creatureID)
            return false
        end
        if model._spokenDisplayID ~= displayID then
            -- Assignment happens before showing, so a reused frame cannot
            -- briefly display the previous NPC. The modern PlayerModel owns
            -- its appearance record, skins and camera; do not manually light
            -- it or call SetCamera as in the old plain-Model implementation.
            model:Hide()
            model._spokenDisplayID = nil
            if model._spokenBackend == "model" then model:ClearModel() end
            model:SetDisplayInfo(displayID)
            if model._spokenBackend == "model" then
                if type(model.SetCamera) == "function" then
                    pcall(model.SetCamera, model, 0)
                end
                if type(model.SetLight) == "function" then
                    pcall(model.SetLight, model, 1, 0, 0, 0, -1, 0.85, 1, 1, 1)
                end
            elseif type(model.SetPortraitZoom) == "function" then
                pcall(model.SetPortraitZoom, model, 1)
            end
            model._spokenDisplayID = displayID
        end
        model:Show()
        if model._spokenBackend == "model" then
            -- Old Model:GetModel is a useful immediate validity check.
            if model.GetModel and not model:GetModel() then return false end
        end
        -- New PlayerModel finishes building skins/camera asynchronously.
        -- An immediate GetModel() == nil is not proof of failure; hiding the
        -- frame at this point prevents the native asynchronous load completing.
        return true
    end,
    Release = function(model)
        if not model then return end
        model:Hide()
        if model._spokenBackend == "model" then model:ClearModel() end
        -- New PlayerModel retains its display record even across Hide/Show.
        -- Forget the ID so a later speaker always assigns a fresh one.
        model._spokenDisplayID = nil
    end,
}

--------------------------------------------------------------------------------
-- Dispatch
--------------------------------------------------------------------------------

-- Every renderer call is protected: a missing native Model API, bad DBC
-- display, or other visual error cannot interrupt the shared player's update.
local function Resolve(portrait, clip, spec, depth)
    local kind = spec and spec.kind or "none"
    local renderer = Renderers[kind] or Renderers["none"]
    if not Renderers[kind] then kind = "none" end

    if portrait.active ~= kind and portrait.activeFrame then
        local previous = Renderers[portrait.active]
        if previous then pcall(previous.Release, portrait.activeFrame) end
        portrait.activeFrame = nil
    end
    local ok, frame = pcall(renderer.Acquire, portrait, clip)
    portrait.active = kind
    portrait.activeFrame = ok and frame or nil

    if ok then
        local updated, visible = pcall(renderer.Update, frame, clip, spec or {})
        if updated and visible then return end
    end
    if spec and spec.fallback and depth < 2 then
        return Resolve(portrait, clip, spec.fallback, depth + 1)
    end
    if kind ~= "none" then
        Resolve(portrait, clip, { kind = "none" }, 3)
    end
end

--- Show the portrait for `clip`, or nothing.
function Portrait:Configure(portrait, clip)
    -- The primary player must remain functional if a portrait is broken.
    local ok, shown = pcall(portrait.IsShown, portrait)
    if not ok or not shown then return end
    local spec = clip and clip.present and clip.present.portrait or { kind = "none" }
    local rendered = pcall(Resolve, portrait, clip, spec, 0)
    if not rendered then
        -- Last-resort visual recovery; never allow it to throw upstream.
        pcall(Resolve, portrait, clip, { kind = "none" }, 3)
    end
end
