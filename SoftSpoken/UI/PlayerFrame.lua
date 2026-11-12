-- SPOKEN_PASS2_REPAIR: Classic-only PlayerFrame; no MinimalPlayer dependency.
setfenv(1, SpokenEnv)

-- The frame's settings, or their defaults once AceDB has stripped them (Addon:Profile).
local function FrameConfig()
    return Addon:Profile("Frame")
end

-- The player: who is speaking, what is waiting, and the controls for both.
--
-- ZoneLore's SoundQueueUI.lua is the base -- itself VoiceOverRedux's with the domain
-- taken out and an actions row added -- with the things Redux had that the fork dropped
-- put back: the hide-portrait mode with its vertical line and mini pause button, and
-- the 1.12 layout quirks. Everything domain-shaped now comes from the clip's
-- presentation: the header, the row label, the bullet, the portrait, the actions.
--
-- Refreshed through the player's AUDIO_CHANGED callback rather than by the queue
-- calling this file, which is what keeps SoundQueue.lua free of any dependency on it.
PlayerFrame = {}

local PORTRAIT_SIZE = 120
local PORTRAIT_ATLAS_SIZE = 512
local PORTRAIT_ATLAS_BORDER_SIZE = 416
local PORTRAIT_ATLAS_VIEWPORT_SIZE = 348
local PORTRAIT_BORDER_SCALE = PORTRAIT_SIZE / PORTRAIT_ATLAS_VIEWPORT_SIZE
local PORTRAIT_BORDER_OUTSET = 34 * PORTRAIT_BORDER_SCALE
-- Blizzard's TalkingHeadUI.xml: the 115x115 model starts at (21, -21),
-- while its 143x143 portrait frame starts at (5, -6). Preserve the resulting
-- 16x15 inset, uniformly scaled to our existing 120x120 portrait viewport.
local TALKING_HEAD_FRAME_SIZE = 143 * PORTRAIT_SIZE / 115
local TALKING_HEAD_MODEL_INSET_X = 16 * PORTRAIT_SIZE / 115
local TALKING_HEAD_MODEL_INSET_Y = 15 * PORTRAIT_SIZE / 115
-- Native atlas coordinates: [863,1006) x [1,144) in the 1024px sheet.
-- The exact 143x143 region is packaged in a transparent 256x256 Vanilla TGA.
local TALKING_HEAD_TEX_COORD = 143 / 256
local PORTRAIT_LINE_WIDTH = 56 * PORTRAIT_BORDER_SCALE
local FRAME_WIDTH_WITHOUT_PORTRAIT = 300
local MAX_ROWS = 4
local TEXTURES = [[Interface\AddOns\SoftSpoken\Textures\]]

do
    local font = CreateFont("SpokenNameFont")
    font:SetFont("Fonts\\MORPHEUS.TTF", 22, "")
    font:SetShadowColor(0, 0, 0)
    font:SetShadowOffset(1, -1)
    font:SetJustifyH("LEFT")
    font:SetJustifyV("TOP")
end
do
    local font = CreateFont("SpokenRowFont")
    font:SetFont(GameFontNormal:GetFont(), 16, "")
    font:SetShadowColor(0, 0, 0)
    font:SetShadowOffset(1, -1)
    font:SetJustifyH("LEFT")
    font:SetJustifyV("MIDDLE")
end

-- 1.12 reports no width for a frame that has not been laid out; the edges are reliable.
local function WidthOf(frame)
    if Version.IsLegacyVanilla then
        return (frame:GetRight() or 0) - (frame:GetLeft() or 0)
    end
    return frame:GetWidth()
end

function PlayerFrame:Initialize()
    if self.frame then return end
    self:InitDisplay()
    self:InitProgress()
    self:InitPortraitLine()
    self:InitPortrait()
    self:InitMover()
    Actions:Build(self.frame)
    self:RefreshConfig()
    Callbacks:Register("AUDIO_CHANGED", function() PlayerFrame:Update() end)
    Callbacks:Register("PROGRESS_STATE_CHANGED", function() PlayerFrame:UpdateProgress() end)
end

function PlayerFrame:InitDisplay()
    self.frame = CreateFrame("Frame", "SpokenPlayerFrame", UIParent, "BackdropTemplate")
    function self.frame:Reset()
        self:SetWidth(PORTRAIT_SIZE + FRAME_WIDTH_WITHOUT_PORTRAIT)
        self:SetHeight(PORTRAIT_SIZE)
        self:ClearAllPoints()
        self:SetPoint("BOTTOM", 0, 200)
    end
    self.frame:Reset()
    if Addon:RestoreLayout("Player", self.frame) then
        -- Saved as the width with the portrait, which RefreshConfig takes off when hidden.
        self.frame:SetWidth(Addon:Layout().Player.width or self.frame:GetWidth())
    end
    self.frame:SetMovable(true)
    self.frame:SetResizable(true)
    self.frame:SetClampedToScreen(true)
    -- Placed from the saved layout instead; the client's cache would only fight it.
    self.frame:SetUserPlaced(false)
    self.frame:SetFrameStrata(FrameConfig().FrameStrata)
    self.frame:Hide()

    self.frame.background = self.frame:CreateTexture(nil, "BACKGROUND")
    self.frame.background:SetPoint("RIGHT")
    self.frame.background:SetTexture(TEXTURES .. "BackgroundGradient")

    self.frame.resizer = CreateFrame("Button", nil, self.frame)
    self.frame.resizer:SetPoint("BOTTOMRIGHT")
    self.frame.resizer:SetSize(16, 16)
    self.frame.resizer:SetNormalTexture(TEXTURES .. "SizeGrabber-Up")
    self.frame.resizer:SetPushedTexture(TEXTURES .. "SizeGrabber-Down")
    self.frame.resizer:SetHighlightTexture(TEXTURES .. "SizeGrabber-Highlight")
    self.frame.resizer:HookScript("OnEnter", function() SetCursor([[Interface\Cursor\UI-Cursor-SizeRight]]) end)
    self.frame.resizer:HookScript("OnLeave", function() SetCursor(nil) end)
    self.frame.resizer:HookScript("OnMouseDown", function()
        self.frame.resizer:GetHighlightTexture():Hide()
        self.frame:StartSizing("BOTTOMRIGHT")
    end)
    self.frame.resizer:HookScript("OnMouseUp", function()
        self.frame.resizer:GetHighlightTexture():Show()
        self.frame:StopMovingOrSizing()
        self:SaveLayout()
    end)

    self.frame.container = CreateFrame("Frame", nil, self.frame)
    self.frame.container:SetPoint("RIGHT")
    self.frame.container.buttons = {}
    function self.frame.container.buttons:Update()
        for _, button in ipairs(self) do button:Update() end
    end

    self.frame.container.name = self.frame.container:CreateFontString(nil, "ARTWORK", "SpokenNameFont")
    self.frame.container.name:SetPoint("TOPLEFT")
    self.frame.container.name:SetWordWrap(false)
    self.frame.container.name:SetTextColor(214 / 255, 214 / 255, 214 / 255)
    function self.frame.container.name:Update()
        local containerWidth = WidthOf(self:GetParent())
        self:SetWidth(0)
        self:SetText(self:GetText())
        self:SetWidth(math.min(containerWidth, self:GetStringWidth() + 1))
    end

    self.frame:SetScript("OnSizeChanged", function()
        self.frame.container.name:Update()
        self.frame.container.buttons:Update()
        self:LayoutCaptions()
        self:LayoutProgress()
    end)
end

-- ClassicAPI v1.19+: a native duration-driven StatusBar with Blizzard's
-- loading-screen frame, standard status-bar fill, and CastingBar spark.
-- Metadata only estimates UI progress. The queue's native sound handle, not
-- this duration object, decides whether a recording is finished.
local PROGRESS_CAP = 0.985
local PROGRESS_GUARD_AT = 0.98

local function ProgressColor(texture, r, g, b, a)
    if texture.SetColorTexture then
        texture:SetColorTexture(r, g, b, a)
    else
        texture:SetTexture(r, g, b, a)
    end
end

local function CancelProgressGuard(progress)
    if progress.guardTimer then
        Addon:CancelTimer(progress.guardTimer, true)
        progress.guardTimer = nil
    end
end

local function StaticProgress(progress, fraction)
    CancelProgressGuard(progress)
    -- SetMinMaxValues ends an active native timer (unlike SetValue).
    progress.bar:SetMinMaxValues(0, 1)
    progress.bar:SetValue(fraction or 0)
    progress.mode = "static"
end

function PlayerFrame:InitProgress()
    -- The loading-screen border keeps the original player's horizontal bounds.
    -- The active bar gets a proportional inset from its ornamental endcaps.
    local container = CreateFrame("Frame", nil, self.frame)
    container:SetHeight(30)

    local bar = CreateFrame("StatusBar", nil, container)
    local barHeight = 8
    bar:SetHeight(barHeight)
    local track = bar:CreateTexture(nil, "BACKGROUND")
    ProgressColor(track, 0.03, 0.025, 0.015, 0.7)
    track:SetAllPoints(bar)
    local fill = bar:CreateTexture(nil, "ARTWORK")
    fill:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
    bar:SetStatusBarTexture(fill)
    -- Slightly warm the sampled dark mustard-gold for the textured brass body.
    bar:SetStatusBarColor(166 / 255, 104 / 255, 39 / 255, 1.0)
    -- S5 brilliant-yellow reflection: 85% at the top, fading to zero
    -- 70% down the fill. Keep the lower 30% as unhighlighted brass.
    -- Anchor to the moving fill so it follows native playback progress.
    local goldHighlight = bar:CreateTexture(nil, "OVERLAY")
    goldHighlight:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
    goldHighlight:SetGradientAlpha("VERTICAL",
        255 / 255, 234 / 255, 0 / 255, 0,
        255 / 255, 234 / 255, 0 / 255, 1.0)
    goldHighlight:SetBlendMode("ADD")
    goldHighlight:SetPoint("TOPLEFT", fill, "TOPLEFT", 0, 0)
    goldHighlight:SetPoint("TOPRIGHT", fill, "TOPRIGHT", 0, 0)
    goldHighlight:SetHeight(barHeight * 0.70)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0)
    local spark = bar:CreateTexture(nil, "OVERLAY")
    spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
    spark:SetBlendMode("ADD")
    spark:SetSize(14, 19)
    spark:SetAlpha(0.5)
    -- v1.19.1 moves the status-bar texture's actual rect with its fill,
    -- so the spark follows without a Lua frame-by-frame update.
    spark:SetPoint("CENTER", fill, "RIGHT")
    spark:Hide()

    -- Child frame-levels outrank the parent's texture draw layers. Put the
    -- decorative rim in its own higher frame so it always covers the fill.
    local borderFrame = CreateFrame("Frame", nil, container)
    borderFrame:SetAllPoints(container)
    borderFrame:SetFrameLevel(bar:GetFrameLevel() + 1)
    local border = borderFrame:CreateTexture(nil, "OVERLAY")
    border:SetTexture([[Interface\Glues\LoadingBar\Loading-BarBorder]])
    border:SetAllPoints(borderFrame)
    -- Lift the existing metal engravings toward cool silver while preserving
    -- the border texture's black recesses and native detail.
    local silverHighlight = borderFrame:CreateTexture(nil, "OVERLAY")
    silverHighlight:SetTexture([[Interface\Glues\LoadingBar\Loading-BarBorder]])
    silverHighlight:SetVertexColor(1.0, 1.0, 1.0, 1.0)
    silverHighlight:SetBlendMode("ADD")
    silverHighlight:SetAllPoints(borderFrame)
    -- The native loading-bar metal is much darker than the Talking Head rim.
    -- A restrained third copy raises its existing ridges into silver-gray
    -- without a flat color wash over its black grooves or transparent center.
    local silverDetail = borderFrame:CreateTexture(nil, "OVERLAY")
    silverDetail:SetTexture([[Interface\Glues\LoadingBar\Loading-BarBorder]])
    silverDetail:SetVertexColor(0.90, 0.94, 1.0, 0.85)
    silverDetail:SetBlendMode("ADD")
    silverDetail:SetAllPoints(borderFrame)

    self.progress = { container = container, bar = bar, track = track,
        fill = fill, goldHighlight = goldHighlight, spark = spark, border = border,
        silverHighlight = silverHighlight, silverDetail = silverDetail }
    self:LayoutProgress()
end

function PlayerFrame:LayoutProgress()
    if not self.progress then return end
    local container = self.progress.container
    local left = FrameConfig().HidePortrait and 20 or PORTRAIT_SIZE + 15
    local width = math.max(0, WidthOf(self.frame) - left - 18)
    local inset = width * (36 / 512) -- measured clear opening of the 512px border

    container:ClearAllPoints()
    container:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", left, 0)
    container:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -18, 0)

    local bar = self.progress.bar
    bar:ClearAllPoints()
    -- Fine-tune the fill opening independently of the ornate frame.
    bar:SetPoint("LEFT", container, "LEFT", inset - 2, 0)
    bar:SetPoint("RIGHT", container, "RIGHT", -inset + 3, 0)
end

function PlayerFrame:UpdateProgress()
    local progress = self.progress
    if not progress then return end
    local shown = Addon:DisplayStyle() == "classic"
        and Addon:Profile("Transcript").SubtitleProgress ~= false
        and self.frame:IsShown()
    progress.container:SetShown(shown)
    if not shown then
        progress.spark:Hide()
        return
    end

    local clip = self:Current()
    local fraction = clip and SoundQueue:ProgressShare(clip)
    if fraction == nil then
        StaticProgress(progress, 0)
        progress.clip, progress.attempt = nil, nil
        progress.spark:Hide()
        return
    end

    local playing = SoundQueue:IsPlaying(clip)
    local startedAt = tonumber(clip.playbackStartedAt)
    local length = tonumber(clip.length)
    local native = C_DurationUtil and type(C_DurationUtil.CreateDuration) == "function"
        and type(progress.bar.SetTimerDuration) == "function"
        and Enum and Enum.StatusBarInterpolation and Enum.StatusBarTimerDirection
    if playing and native and startedAt and length and length > 0 then
        local attempt = clip.playbackAttempt
        if progress.clip ~= clip or progress.attempt ~= attempt
            or (progress.mode ~= "native" and progress.mode ~= "capped") then
            CancelProgressGuard(progress)
            progress.clip, progress.attempt = clip, attempt
            local total, origin = length, startedAt
            local span = clip.span
            if span and tonumber(span.total) and tonumber(span.total) > 0 then
                total = tonumber(span.total)
                origin = startedAt - (tonumber(span.before) or 0)
            end
            progress.duration = C_DurationUtil.CreateDuration()
            progress.duration:SetTimeFromStart(origin, total)
            progress.bar:SetTimerDuration(progress.duration,
                Enum.StatusBarInterpolation.Immediate,
                Enum.StatusBarTimerDirection.ElapsedTime)
            progress.mode = "native"

            -- The duration is an estimate, not an MP3 playhead. Near its end
            -- freeze the native bar below 100% while audio is still speaking.
            -- One-shot timer only; no Lua OnUpdate driver or texture resizing.
            local secondsToCap = origin + total * PROGRESS_GUARD_AT - GetTime()
            if secondsToCap <= 0 then
                StaticProgress(progress, PROGRESS_CAP)
                progress.mode = "capped"
            else
                progress.guardTimer = Addon:ScheduleTimer(function()
                    progress.guardTimer = nil
                    if progress.clip ~= clip or progress.attempt ~= attempt
                        or progress.mode ~= "native" or not SoundQueue:IsPlaying(clip) then
                        return
                    end
                    StaticProgress(progress, PROGRESS_CAP)
                    progress.mode = "capped"
                end, secondsToCap)
            end
        end
        progress.spark:Show()
    else
        -- Pause/hold, completed voice, or ClassicAPI before v1.19: display
        -- only the queue's current estimate; never pretend it is seeking.
        StaticProgress(progress, fraction)
        progress.clip, progress.attempt = clip, clip and clip.playbackAttempt
        progress.spark:SetShown(playing)
    end
end

-- The vertical line and the small pause button that stand in for the portrait when the
-- player has turned it off. Redux's; the zones fork dropped them, and that was an
-- omission rather than a decision.
function PlayerFrame:InitPortraitLine()
    self.frame.portraitLine = self.frame:CreateTexture(nil, "BORDER")
    self.frame.portraitLine:SetPoint("TOPLEFT", -PORTRAIT_LINE_WIDTH / 2 + 2, PORTRAIT_BORDER_OUTSET)
    self.frame.portraitLine:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMLEFT", PORTRAIT_LINE_WIDTH / 2 + 2, -PORTRAIT_BORDER_OUTSET)
    self.frame.portraitLine:SetTexture(TEXTURES .. "PortraitFrameAtlas")
    self.frame.portraitLine:SetTexCoord(456 / PORTRAIT_ATLAS_SIZE, 512 / PORTRAIT_ATLAS_SIZE, 0, PORTRAIT_ATLAS_BORDER_SIZE / PORTRAIT_ATLAS_SIZE)

    self.frame.miniPause = CreateFrame("Button", nil, self.frame)
    self.frame.miniPause:SetSize(26, 26)
    self.frame.miniPause:SetPoint("CENTER", self.frame.container, "LEFT", -20 + 2, 0)
    self.frame.miniPause:SetNormalTexture(TEXTURES .. "PortraitFrameAtlas")
    self.frame.miniPause:GetNormalTexture():ClearAllPoints()
    self.frame.miniPause:GetNormalTexture():SetPoint("CENTER")
    self.frame.miniPause:GetNormalTexture():SetSize(14, 14)
    self.frame.miniPause:SetPushedTexture(TEXTURES .. "PortraitFrameAtlas")
    self.frame.miniPause:GetPushedTexture():ClearAllPoints()
    self.frame.miniPause:GetPushedTexture():SetPoint("CENTER")
    self.frame.miniPause:GetPushedTexture():SetSize(12, 12)
    self.frame.miniPause.background = self.frame.miniPause:CreateTexture(nil, "BACKGROUND")
    self.frame.miniPause.background:SetTexture(TEXTURES .. "SettingsButton")
    self.frame.miniPause.background:SetPoint("CENTER")
    self.frame.miniPause.background:SetSize(32, 32)
    function self.frame.miniPause:Update()
        local state = Actions.HeadState()
        Actions.Glyph(self:GetNormalTexture(), state)
        Actions.Glyph(self:GetPushedTexture(), state)
        self:GetNormalTexture():SetAlpha(MouseIsOver(self) and 1 or 0.75)
    end
    self.frame.miniPause:Update()
    self.frame.miniPause:HookScript("OnEnter", function(button) button:GetNormalTexture():SetAlpha(1) end)
    self.frame.miniPause:HookScript("OnLeave", function(button) button:GetNormalTexture():SetAlpha(0.75) end)
    self.frame.miniPause:HookScript("OnClick", function()
        PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
        SoundQueue:TogglePauseQueue()
    end)
end

function PlayerFrame:InitPortrait()
    self.frame.portrait = CreateFrame("Frame", nil, self.frame)
    self.frame.portrait:SetPoint("TOPLEFT")
    self.frame.portrait:SetSize(PORTRAIT_SIZE, PORTRAIT_SIZE)

    self.frame.portrait.background = self.frame.portrait:CreateTexture(nil, "BACKGROUND")
    self.frame.portrait.background:SetAllPoints()
    self.frame.portrait.background:SetTexture(TEXTURES .. "PortraitFrameBackground")

    self.frame.portrait.pause = CreateFrame("Button", nil, self.frame.portrait)
    self.frame.portrait.pause:SetFrameLevel(self.frame.portrait:GetFrameLevel() + 2)
    self.frame.portrait.pause:SetAllPoints()
    self.frame.portrait.pause.background = self.frame.portrait.pause:CreateTexture(nil, "BACKGROUND")
    self.frame.portrait.pause.background:SetAllPoints()
    self.frame.portrait.pause.background:SetTexture(TEXTURES .. "PortraitFrameBackground")
    self.frame.portrait.pause.background:SetAlpha(0.75)
    self.frame.portrait.pause:SetNormalTexture(TEXTURES .. "PortraitFrameAtlas")
    self.frame.portrait.pause:GetNormalTexture():ClearAllPoints()
    self.frame.portrait.pause:GetNormalTexture():SetPoint("CENTER")
    self.frame.portrait.pause:GetNormalTexture():SetSize(32, 32)
    self.frame.portrait.pause:SetPushedTexture(TEXTURES .. "PortraitFrameAtlas")
    self.frame.portrait.pause:GetPushedTexture():ClearAllPoints()
    self.frame.portrait.pause:GetPushedTexture():SetPoint("CENTER")
    self.frame.portrait.pause:GetPushedTexture():SetSize(28, 28)
    function self.frame.portrait.pause:Update()
        local paused = SoundQueue:IsPaused()
        if paused and not SoundQueue:IsPlaying() then self.background:Show() else self.background:Hide() end
        local state = Actions.HeadState()
        Actions.Glyph(self:GetNormalTexture(), state)
        Actions.Glyph(self:GetPushedTexture(), state)
        self:GetNormalTexture():SetAlpha(MouseIsOver(self) and 1 or (paused and 0.75 or 0))
    end
    self.frame.portrait.pause:Update()
    self.frame.portrait.pause:HookScript("OnEnter", function(button)
        button:GetNormalTexture():SetAlpha(1)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        local stopped = SoundQueue:IsPaused()
        GameTooltip:SetText(stopped and L.REPLAY or L.STOP)
        GameTooltip:AddLine(stopped and L.REPLAY_TOOLTIP or L.STOP_TOOLTIP, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    self.frame.portrait.pause:HookScript("OnLeave", function(button)
        button:GetNormalTexture():SetAlpha(SoundQueue:IsPaused() and 0.75 or 0)
        GameTooltip_Hide()
    end)
    self.frame.portrait.pause:HookScript("OnClick", function()
        PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
        SoundQueue:TogglePauseQueue()
    end)

    -- A separate frame so the border and the mover draw above everything in the portrait.
    self.frame.portrait.border = CreateFrame("Frame", nil, self.frame.portrait)
    self.frame.portrait.border:SetFrameLevel(self.frame.portrait.pause:GetFrameLevel() + 1)
    self.frame.portrait.border:SetAllPoints()
    self.frame.portrait.border.texture = self.frame.portrait.border:CreateTexture(nil, "BORDER")
    self.frame.portrait.border.texture:SetSize(TALKING_HEAD_FRAME_SIZE, TALKING_HEAD_FRAME_SIZE)
    self.frame.portrait.border.texture:SetPoint("TOPLEFT", self.frame.portrait, "TOPLEFT",
        -TALKING_HEAD_MODEL_INSET_X, TALKING_HEAD_MODEL_INSET_Y)
    self.frame.portrait.border.texture:SetTexture(TEXTURES .. "TalkingHeads\\PortraitNeutral")
    self.frame.portrait.border.texture:SetTexCoord(0, TALKING_HEAD_TEX_COORD, 0, TALKING_HEAD_TEX_COORD)
end

function PlayerFrame:InitMover()
    self.frame.mover = CreateFrame("Button", nil, self.frame.portrait.border)
    self.frame.mover:SetSize(26, 26)
    self.frame.mover:SetPoint("CENTER", self.frame.portrait.border, "BOTTOMLEFT", 5, 6)
    self.frame.mover:SetNormalTexture(TEXTURES .. "PortraitFrameAtlas")
    self.frame.mover:GetNormalTexture():SetTexCoord(462 / PORTRAIT_ATLAS_SIZE, 512 / PORTRAIT_ATLAS_SIZE, 462 / PORTRAIT_ATLAS_SIZE, 512 / PORTRAIT_ATLAS_SIZE)
    self.frame.mover:GetNormalTexture():ClearAllPoints()
    self.frame.mover:GetNormalTexture():SetPoint("CENTER")
    self.frame.mover:GetNormalTexture():SetSize(16, 16)
    self.frame.mover:SetPushedTexture(TEXTURES .. "PortraitFrameAtlas")
    self.frame.mover:GetPushedTexture():SetTexCoord(462 / PORTRAIT_ATLAS_SIZE, 512 / PORTRAIT_ATLAS_SIZE, 462 / PORTRAIT_ATLAS_SIZE, 512 / PORTRAIT_ATLAS_SIZE)
    self.frame.mover:GetPushedTexture():ClearAllPoints()
    self.frame.mover:GetPushedTexture():SetPoint("CENTER")
    self.frame.mover:GetPushedTexture():SetSize(14, 14)
    self.frame.mover.background = self.frame.mover:CreateTexture(nil, "BACKGROUND")
    self.frame.mover.background:SetTexture(TEXTURES .. "SettingsButton")
    self.frame.mover.background:SetPoint("CENTER")
    self.frame.mover.background:SetSize(32, 32)
    self.frame.mover:HookScript("OnEnter", function(button)
        if Addon:IsFrameLocked() then return end
        SetCursor([[Interface\Cursor\UI-Cursor-Move]])
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.QUEUE_TITLE)
        GameTooltip:AddLine(L.QUEUE_DRAG_HINT, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    self.frame.mover:HookScript("OnLeave", function() SetCursor(nil); GameTooltip_Hide() end)
    self.frame.mover:HookScript("OnMouseDown", function()
        if Addon:IsFrameLocked() then return end
        self.frame:StartMoving()
    end)
    self.frame.mover:HookScript("OnMouseUp", function()
        if Addon:IsFrameLocked() then return end
        self.frame:StopMovingOrSizing()
        self:SaveLayout()
    end)
end

function PlayerFrame:RefreshConfig()
    Actions.RefreshRings()
    Transcript:SetStyle(nil)
    local cfg = FrameConfig()
    self:LayoutProgress()
    if cfg.HidePortrait then
        if self.frame.portrait:IsShown() then
            self.frame:SetWidth(self.frame:GetWidth() - PORTRAIT_SIZE)
        end
        self:SetResizeBounds(100)
        self.frame.portraitLine:Show()
        self.frame.portrait:Hide()
        self.frame.miniPause:Show()
        self.frame.container:SetPoint("LEFT", 20, 0)
        self.frame.background:SetPoint("TOPLEFT")
        self.frame.background:SetPoint("BOTTOMLEFT")
        self.frame.mover:SetParent(self.frame)
        self.frame.mover:SetPoint("CENTER", self.frame, "BOTTOMLEFT", 2, 6)
    else
        if not self.frame.portrait:IsShown() then
            self.frame:SetWidth(self.frame:GetWidth() + PORTRAIT_SIZE)
        end
        self:SetResizeBounds(PORTRAIT_SIZE + 100)
        self.frame.portraitLine:Hide()
        self.frame.portrait:Show()
        self.frame.miniPause:Hide()
        self.frame.container:SetPoint("LEFT", self.frame.portrait, "RIGHT", 15, 0)
        self.frame.background:SetPoint("TOPLEFT", self.frame.portrait, "TOPRIGHT")
        self.frame.background:SetPoint("BOTTOMLEFT", self.frame.portrait, "BOTTOMRIGHT")
        self.frame.mover:SetParent(self.frame.portrait.border)
        self.frame.mover:SetPoint("CENTER", self.frame.portrait.border, "BOTTOMLEFT", 5, 6)
    end

    self.frame.mover:SetShown(not Addon:IsFrameLocked())
    self.frame.resizer:SetShown(not Addon:IsFrameLocked())
    self.frame:SetScale(cfg.FrameScale)
    self.frame:SetFrameStrata(cfg.FrameStrata)
    Addon:ApplyHost(self.frame)
    self:Update()
end

-- SetResizeBounds replaced SetMinResize/SetMaxResize; both exist across these clients.
function PlayerFrame:SetResizeBounds(minWidth)
    local height = Transcript:HeightForClip(SoundQueue:GetCurrentSound())
    self.captionExtra = height > 0 and height + 16 or 0
    Transcript:ResizePlayer(self.frame, PORTRAIT_SIZE + self.captionExtra, minWidth, 10000)
end

function PlayerFrame:LayoutCaptions()
    local hidePortrait = FrameConfig().HidePortrait
    local left = hidePortrait and 20 or PORTRAIT_SIZE + 15
    local height = Transcript:HeightForClip(SoundQueue:GetCurrentSound())
    Transcript:Dock(self.frame, self.frame, "TOPLEFT", left, -PORTRAIT_SIZE - 4,
        math.max(1, WidthOf(self.frame) - left - 10), height)
    self.frame.background:ClearAllPoints()
    self.frame.background:SetPoint("TOPLEFT", hidePortrait and 0 or PORTRAIT_SIZE, 0)
    self.frame.background:SetPoint("BOTTOMRIGHT")
end

local function BulletFor(clip, hovered)
    if hovered then
        return TEXTURES .. "SoundQueueBulletDelete", 14
    end
    -- Keep each audio type visible while it waits in the queue, not just
    -- when the clip reaches the head. Unknown types retain the queue dot.
    local bullet = Bullets[clip.present and clip.present.bullet]
    if bullet then return bullet.texture, bullet.size or 14 end
    return TEXTURES .. "SoundQueueBulletQueue", 22
end

function PlayerFrame:CreateRow(i)
    local button = CreateFrame("Button", nil, self.frame.container)
    self.frame.container.buttons[i] = button
    button:SetID(i)
    button:SetHeight(20)

    button.textWidget = button:CreateFontString(nil, "OVERLAY", "SpokenRowFont")
    button.textWidget:SetWordWrap(false)
    button.iconWidget = button:CreateTexture(nil, "ARTWORK")
    button.iconWidget:SetSize(16, 16)
    button.iconWidget:SetPoint("CENTER", button, "LEFT", 16 / 2, 0)

    function button:Configure(clip)
        self.clip = clip
        self:Update()
    end
    function button:Update(pushed, hovered)
        if pushed == nil then pushed = self.pushed else self.pushed = pushed end
        if hovered == nil then hovered = self.hovered else self.hovered = hovered end
        local clip = self.clip
        if not clip then self:Hide(); return end
        self:Show()
        local isHead = clip == SoundQueue:GetCurrentSound()
        local index = self:GetID()

        if isHead then
            self:SetAlpha(1)
            self.textWidget:SetShadowColor(0, 0, 0, 1)
            self:SetPoint("TOPLEFT", PlayerFrame.frame.container.name, "BOTTOMLEFT", 0, -2)
            self:EnableMouse(SoundQueue:CanBePaused())
        else
            local position = index - 1
            local alpha = math.max(0.1, math.min(1, 1 - (position - 1) / 3))
            self:SetAlpha(alpha)
            self.textWidget:SetShadowColor(0, 0, 0, 0.5 + 0.5 * alpha)
            self:SetPoint("TOPLEFT", PlayerFrame.frame.container.buttons[index - 1] or PlayerFrame.frame.container.name,
                "BOTTOMLEFT", 0, position == 1 and -8 or -2)
            self:EnableMouse(true)
        end

        -- A held clip says why; otherwise narration waiting out a pull looks exactly like
        -- narration that failed.
        local text = clip.present and clip.present.label or clip.key
        -- A Hold-only combat gate blocks queued/future autoplay, not the
        -- recording already speaking. Preserve the queued clip's gate reason
        -- without falsely labeling a live recording as stopped.
        local state = SoundQueue:GetClipState(clip)
        local held = (state == "held" or state == "queued")
            and SoundQueue:GetHeldReason(clip) or nil
        if held then
            text = format("%s |cff888888(%s)|r", text, held)
        end
        self.textWidget:ClearAllPoints()
        self.textWidget:SetPoint("LEFT", 16 + 5, 0)
        self.textWidget:SetText(text)
        self:SetWidth(math.min(WidthOf(self:GetParent()), 16 + 5 + self.textWidget:GetWidth() + 1))
        self.textWidget:SetPoint("RIGHT")

        local texture, size = BulletFor(clip, hovered)
        self.iconWidget:SetTexture(texture)
        self.iconWidget:SetSize(size, size)
        -- Queued clips keep their type glyphs, but in grayscale. Reset the
        -- shader for the playing clip and the red remove icon on hover:
        -- these texture widgets are reused as the queue advances.
        local waiting = not isHead and not hovered
        local supported
        if self.iconWidget.SetDesaturated then
            -- Vanilla 1.12 uses 1/nil rather than modern true/false.
            supported = self.iconWidget:SetDesaturated(waiting and 1 or nil)
        end
        -- Older graphics hardware may lack the desaturation shader.
        -- Use Blizzard's traditional dimmed fallback in that case.
        local shade = waiting and not supported and 0.55 or 1
        self.iconWidget:SetVertexColor(shade, shade, shade)
        if hovered then
            local r, g, b = unpack(RemoveColor)
            if pushed then r, g, b = r * 0.75, g * 0.75, b * 0.75 end
            self:SetAlpha(1)
            self.textWidget:SetTextColor(r, g, b)
            self.textWidget:SetShadowColor(0, 0, 0, 1)
        elseif isHead then
            local tint = clip.present and clip.present.tint
            if tint then
                self.textWidget:SetTextColor(tint[1] or tint.r, tint[2] or tint.g, tint[3] or tint.b)
            else
                self.textWidget:SetTextColor(245 / 255, 204 / 255, 24 / 255)
            end
        else
            self.textWidget:SetTextColor(123 / 255, 147 / 255, 167 / 255)
        end
    end

    button:HookScript("OnClick", function(self) SoundQueue:RemoveSoundFromQueue(self.clip) end)
    button:HookScript("OnMouseDown", function(self) self:Update(true) end)
    button:HookScript("OnMouseUp", function(self) self:Update(false) end)
    button:HookScript("OnEnter", function(self)
        self:Update(nil, true)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.QUEUE_REMOVE_TOOLTIP)
        GameTooltip:Show()
    end)
    button:HookScript("OnLeave", function(self) self:Update(nil, false); GameTooltip_Hide() end)
    button:Update()
    return button
end

--- A line to show while none is playing, so a window chosen as the narrator style in the welcome
--- window can be seen at once, as the subtitles show theirs. Either window draws it; the first
--- real line puts it away.
function PlayerFrame:ShowSample(shown)
    self.sample = shown and {
        key = "sample", length = 0,
        source = { key = "sample", gates = {}, interClipGap = 0 },
        present = { header = L.SAMPLE_SPEAKER, label = L.SAMPLE_LINE,
            portrait = { kind = "texture", texture = [[Interface\AddOns\SoftSpoken\icon.tga]] } },
    } or nil
    self:Update()
end

function PlayerFrame:IsShowingSample()
    return self.sample ~= nil
end

--- The line the window stands for: the one playing, or the sample while nothing is.
function PlayerFrame:Current()
    if not SoundQueue:IsEmpty() then self.sample = nil end
    return SoundQueue:GetCurrentSound() or self.sample
end

function PlayerFrame:Update()
    if not self.frame then return end
    -- Hidden in voice-only mode; returning to the classic window retains its position.
    local head = self:Current()
    self.frame:SetShown(Addon:DisplayStyle() == "classic" and head ~= nil)
    if not self.frame:IsShown() then return end

    self:SetResizeBounds(FrameConfig().HidePortrait and 100 or PORTRAIT_SIZE + 100)

    self.frame.miniPause:Update()
    self.frame.portrait.pause:Update()

    Portrait:Configure(self.frame.portrait, head)
    local actionCount = Actions:Configure(self.frame, head)
    local strip = actionCount > 0 and Actions.STRIP_HEIGHT or 0
    self.frame.container:SetPoint("RIGHT", self.frame, "RIGHT", 0, (strip + (self.captionExtra or 0)) / 2)

    self.frame.container:SetHeight(self.frame:GetHeight())
    self.frame.container:Hide() -- 1.12 quirk: forces a relayout before measuring
    self.frame.container:Show()

    local lastRow = 0
    local lastContent = self.frame.container.name
    for i, clip in ipairs(SoundQueue:IsEmpty() and { head } or SoundQueue.sounds) do
        if i == 1 then
            self.frame.container.name:SetText(clip.present and clip.present.header or "")
        end
        lastRow = lastRow + 1
        local row = self.frame.container.buttons[lastRow] or self:CreateRow(lastRow)
        row:Configure(clip)
        lastContent = row
        if lastRow == MAX_ROWS then break end
    end
    for i = lastRow + 1, getn(self.frame.container.buttons) do
        self.frame.container.buttons[i]:Configure(nil)
    end
    self.frame.container.name:Update()

    local contentTop = self.frame.container.name:GetTop() or 0
    local contentBottom = lastContent:GetBottom() or 0
    self.frame.container:SetHeight(contentTop - contentBottom)
    self:LayoutCaptions()
    self:UpdateProgress()

    -- Again once the layout has settled: truncation and hover state both depend on where
    -- the rows ended up. Same frame on current clients, next frame on old ones.
    Addon:ScheduleTimer(function()
        self.frame.container.buttons:Update()
        self.frame.container.name:Update()
    end, 0)
end

--- What the frame is actually doing, for a bug report. A row that is present but drawn
--- nowhere, or drawn under something, looks from the outside exactly like a row that was
--- never built; this tells the two apart without a client to poke at.
function PlayerFrame:Describe()
    local lines = {}
    local function Say(text) table.insert(lines, text) end
    if not self.frame then
        Say("no frame built")
        return lines
    end
    local container = self.frame.container
    Say(format("frame shown=%s w=%.0f h=%.0f", tostring(self.frame:IsShown()),
        self.frame:GetWidth() or 0, self.frame:GetHeight() or 0))
    Say(format("container shown=%s w=%.0f h=%.0f header=%q", tostring(container:IsShown()),
        container:GetWidth() or 0, container:GetHeight() or 0, container.name:GetText() or ""))
    Say(format("portrait kind=%s actions=%d", tostring(self.frame.portrait.active),
        self.frame.actions and self.frame.actions.shown or 0))
    for index, button in ipairs(container.buttons) do
        if button:IsShown() then
            -- Whether a row takes a click matters: the head only does while the clip it
            -- stands for can be stopped, and a row that ignores clicks cannot be cancelled.
            Say(format("  row %d w=%.0f mouse=%s text=%q", index, button:GetWidth() or 0,
                tostring(button:IsMouseEnabled()), button.textWidget:GetText() or ""))
        end
    end
    for id, button in pairs(self.frame.actions.byId) do
        if button:IsShown() then
            Say(format("  action %s at %.0f,%.0f text=%q", id,
                button:GetLeft() or 0, button:GetBottom() or 0, button:GetText() or ""))
        end
    end
    Say(format("head can be stopped=%s", tostring(SoundQueue:CanBePaused())))
    Say(format("queue=%d", SoundQueue:GetQueueSize()))
    return lines
end

function PlayerFrame:SaveLayout()
    local width = self.frame:GetWidth() + (FrameConfig().HidePortrait and PORTRAIT_SIZE or 0)
    Addon:SaveLayout("Player", self.frame, width)
end

--- Back to the default spot and width, forgetting the saved ones, for a frame dragged
--- off-screen or sized past use.
function PlayerFrame:Reset()
    Addon:Layout().Player = nil
    if not self.frame then return end
    self.frame:Reset()
    -- Reset's width has the portrait in it, and RefreshConfig only takes it off on a change.
    if FrameConfig().HidePortrait then self.frame:SetWidth(self.frame:GetWidth() - PORTRAIT_SIZE) end
    self:RefreshConfig()
end
