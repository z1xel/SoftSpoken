setfenv(1, SpokenEnv)

-- Shared Vanilla 1.12 settings window. Feature addons contribute pages displayed
-- as tabs in the same bounded Blizzard scroll frame, opened with /spoken.
Options = {}

-- Keep the existing native-window row alignment.
local INDENT = 25
local TOP = 16    -- where the page's title starts
local BOTTOM = 16 -- the margin under the last row

-- One coordinate system for the shared Vanilla window. Keep the search,
-- navigation, scroll viewport and module content aligned when polishing it.
local LEGACY_WIDTH = 550
local LEGACY_CONTENT_WIDTH = 470
local LEGACY_NAV_WIDTH = 514
local LEGACY_NAV_TOP = -37
local LEGACY_SCROLL_TOP = -116

local panel
local scroller
local legacyScrollChild
local legacyNavButtons = {}
local legacyMaxHeight
local FitWindow

-- Rows, headings and the spacing between them come from UI/Layout.lua, the file every
-- Spoken addon carries a copy of, so the three panels read alike.
local Layout = SpokenLayout
-- Product name stays consistent across locales, unlike descriptive settings text.
local HOME_TITLE = "SoftSpoken"

-- Full-width ornamental surround for the search row using the same native
-- chat-input artwork, cap sizes, and silver rails as main.
-- Draw on a mouse-transparent overlay above the outer window trim, so
-- its silver corners and rails remain visible where the frames intersect.
local function DrawOrnateHeaderBand(window)
    -- Both horizontal rails and all four corner caps surround the search.
    -- The original open-top U from main omitted its three top pieces.
    local art = [[Interface\ChatFrame\UI-ChatInputBorder-]]
    local leftX, rightX = 2, -2
    -- Search EditBox spans approximately y=-72..-93. Keep the native
    -- 16-unit corner pieces and give the field 7-8 units of vertical padding.
    local topY, bottomY = -65, -101
    local cornerW, cornerH = 28, 16

    local function Part(file, layer, u1, u2, v1, v2, width, height, anchor, relative, x, y)
        local tex = window:CreateTexture(nil, layer)
        tex:SetTexture(art .. file)
        tex:SetTexCoord(u1, u2, v1, v2)
        tex:SetWidth(width)
        tex:SetHeight(height)
        tex:SetPoint(anchor, window, relative, x, y)
        return tex
    end

    -- These are the three missing pieces: the upper corner caps and top rail.
    local tl = Part("Left", "BORDER", 0, 28/256, 0, 0.5,
        cornerW, cornerH, "TOPLEFT", "TOPLEFT", leftX, topY)
    local tr = Part("Right", "ARTWORK", 228/256, 1, 0, 0.5,
        cornerW, cornerH, "TOPRIGHT", "TOPRIGHT", rightX, topY)

    local top = window:CreateTexture(nil, "BORDER")
    top:SetTexture(art .. "Left")
    top:SetTexCoord(75/256, 1, 0, 0.5)
    top:SetHeight(cornerH)
    top:SetPoint("TOPLEFT", tl, "TOPRIGHT", 0, 0)
    top:SetPoint("TOPRIGHT", tr, "TOPLEFT", 0, 0)

    local bl = Part("Left", "BORDER", 0, 28/256, 0.5, 1,
        cornerW, cornerH, "BOTTOMLEFT", "TOPLEFT", leftX, bottomY)
    local br = Part("Right", "ARTWORK", 228/256, 1, 0.5, 1,
        cornerW, cornerH, "BOTTOMRIGHT", "TOPRIGHT", rightX, bottomY)

    local bottom = window:CreateTexture(nil, "BORDER")
    bottom:SetTexture(art .. "Left")
    bottom:SetTexCoord(75/256, 1, 0.5, 1)
    bottom:SetHeight(cornerH)
    bottom:SetPoint("BOTTOMLEFT", bl, "BOTTOMRIGHT", 0, 0)
    bottom:SetPoint("BOTTOMRIGHT", br, "BOTTOMLEFT", 0, 0)

    -- The side rails join the new upper caps to the existing lower caps.
    local function Vertical(file, u1, u2, right)
        local tex = window:CreateTexture(nil, right and "ARTWORK" or "BORDER")
        tex:SetTexture(art .. file)
        tex:SetTexCoord(u1, u2, 12/32, 20/32)
        tex:SetWidth(4)
        local edge = right and "TOPRIGHT" or "TOPLEFT"
        local x = right and (rightX - 8) or (leftX + 8)
        tex:SetPoint(edge, window, edge, x, topY - cornerH)
        tex:SetPoint(right and "BOTTOMRIGHT" or "BOTTOMLEFT",
            window, edge, x, bottomY + cornerH)
    end
    Vertical("Left", 8/256, 12/256, false)
    Vertical("Right", 244/256, 248/256, true)
end

-- Only the two narrator styles supported on Vanilla 1.12.
local STYLE_LABELS = {
    classic = L.OPT_STYLE_CLASSIC,
    none = L.OPT_STYLE_NONE,
}

-- The game's key bindings list these under a Spoken heading (Bindings.xml). Set here, after
-- the locale files, so the names are in the player's language.
_G.BINDING_HEADER_SPOKEN = "Spoken"
_G.BINDING_NAME_SPOKEN_PLAYPAUSE = L.BIND_PLAYPAUSE
_G.BINDING_NAME_SPOKEN_SKIP = L.BIND_SKIP
_G.BINDING_NAME_SPOKEN_STOP = L.BIND_STOP
_G.BINDING_NAME_SPOKEN_COMPENDIUM = L.BIND_COMPENDIUM
local BINDINGS = {
    { "SPOKEN_PLAYPAUSE", L.BIND_PLAYPAUSE },
    { "SPOKEN_SKIP", L.BIND_SKIP },
    { "SPOKEN_STOP", L.BIND_STOP },
    { "SPOKEN_COMPENDIUM", L.BIND_COMPENDIUM },
}
-- The parts of Spoken by source key, named as their pages are, each with the game's own icon
-- for what it reads and the order its page is listed in under Spoken.
local PARTS = {
    { key = "quests", label = L.OPT_PART_QUESTS, text = L.OPT_PART_QUESTS_TEXT, tip = L.OPT_PART_QUESTS_TIP,
        icon = [[Interface\Icons\INV_Scroll_03]], order = 1 },
    { key = "zones", label = L.OPT_PART_ZONES, text = L.OPT_PART_ZONES_TEXT, tip = L.OPT_PART_ZONES_TIP,
        icon = [[Interface\Icons\INV_Misc_Map_01]], order = 2 },
    { key = "books", label = L.OPT_PART_BOOKS, text = L.OPT_PART_BOOKS_TEXT, tip = L.OPT_PART_BOOKS_TIP,
        icon = [[Interface\Icons\INV_Misc_Book_09]], order = 3 },
}

-- Sketches for the two supported narrator cards: the classic window and voice only.
local SKETCHES = {
    classic = function(art)
        local R, w = Layout.Rect, art.width
        local x = (w - 96) / 2
        -- Keep the broad dark window silhouette behind its portrait, header
        -- and text bars even when Grey() restores selected colours on 1.12.
        R(art, x, 7, 96, 44, 0.2, 0.18, 0.15, 1, "BACKGROUND")
        R(art, x + 4, 11, 32, 32, 0.75, 0.6, 0.3, 1)
        R(art, x + 41, 13, 46, 3, 1, 0.82, 0, 0.9)
        R(art, x + 41, 21, 50, 2, 0.9, 0.9, 0.9, 0.7)
        R(art, x + 41, 27, 42, 2, 0.9, 0.9, 0.9, 0.7)
        R(art, x + 41, 36, 40, 2, 0.48, 0.58, 0.65, 0.8)
        R(art, x + 41, 42, 34, 2, 0.48, 0.58, 0.65, 0.6)
    end,
    -- Nothing on screen: the bars of a sound rising and falling, in the middle of the box.
    none = function(art)
        local R, w = Layout.Rect, art.width
        local heights = { 8, 16, 26, 16, 8 }
        local x = (w - 5 * 6) / 2
        for index, height in ipairs(heights) do
            R(art, x + (index - 1) * 6, 29 - height / 2, 3, height, 1, 0.82, 0, 0.75)
        end
    end,
}
local STYLE_TEXTS = {
    classic = L.OPT_STYLE_CLASSIC_TEXT,
    none = L.OPT_STYLE_NONE_TEXT,
}
local STYLE_TIPS = {
    classic = L.WELCOME_STYLE_CLASSIC_TIP,
    none = L.WELCOME_STYLE_NONE_TIP,
}
-- Locale metadata and auto/fallback policy have one owner in core.
local LANGUAGES = Spoken.Language.LOCALES

--- Show `style` on screen with a sample line, or nil to stop.
function Options:Preview(style)
    Addon.previewStyle = style
    PlayerFrame:RefreshConfig()
    Transcript:RefreshConfig()
    if Subtitle then Subtitle:ShowSample(style == "subtitle") end
    PlayerFrame:ShowSample(style == "classic")
end

--- Preview mode: on, the chosen style is on screen with a sample line, and choosing another swaps
--- to it (StyleChosen); off, or when the page that turned it on closes, it all goes.
function Options:SetPreviewing(on)
    self.previewing = on and true or false
    self:Preview(on and Addon:PlayerStyle() or nil)
end

--- A style was chosen: in preview mode, it is the one shown now.
function Options:StyleChosen()
    if self.previewing then self:Preview(Addon:PlayerStyle()) end
end

--- The one Preview button over the narrator styles, on Spoken's page and in the welcome window,
--- turning preview mode on and off. Voice Only has nothing to show: with it chosen and the mode
--- off, the button stands greyed out.
function Options:PreviewButton(layout)
    local button = layout:HeadingButton(L.STYLE_PREVIEW, function()
        Options:SetPreviewing(not Options.previewing)
        layout:Refresh()
    end, L.STYLE_PREVIEW_TIP)
    layout:OnRefresh(function()
        button:SetText(Options.previewing and L.STYLE_PREVIEW_HIDE or L.STYLE_PREVIEW)
        Layout.FitButton(button)
        if Addon:PlayerStyle() == "none" and not Options.previewing then button:Disable() else button:Enable() end
    end)
    return button
end

-- The same parts and ways of showing lines, drawn the same way, in the welcome window.
Options.PARTS, Options.SKETCHES = PARTS, SKETCHES
Options.STYLE_LABELS, Options.STYLE_TEXTS, Options.STYLE_TIPS = STYLE_LABELS, STYLE_TEXTS, STYLE_TIPS

--- The ways of showing lines this client can offer, in the order they are listed: the narrator
--- cards, and the legacy window's list. Classic Window first; Voice Only last,
--- illustrated by the bars of a sound rising and falling.
function Options:Styles()
    return { "classic", "none" }
end

local function Build()
    panel = CreateFrame("Frame", "SpokenOptionsPanel", UIParent)
    panel.name = HOME_TITLE
    -- The only supported host is the bounded native Vanilla 1.12 ScrollFrame.
    scroller = CreateFrame("ScrollFrame", "SpokenOptionsLegacyScroll", panel, "UIPanelScrollFrameTemplate")
    scroller:EnableMouseWheel(true)
    scroller:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, LEGACY_SCROLL_TOP)
    scroller:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -42, 20)
    local host = CreateFrame("Frame", nil, scroller)
    host:SetWidth(LEGACY_CONTENT_WIDTH)
    host:SetHeight(1)
    scroller:SetScrollChild(host)
    legacyScrollChild = host
    panel.content = host
    local cfg = function() return Addon.db.profile.Frame end
    local audio = function() return Addon.db.profile.Audio end
    local transcript = function() return Addon.db.profile.Transcript end
    local mm = function() return Addon.db.profile.Minimap.LibDBIcon end
    local function Style() return Addon:PlayerStyle() end
    local function InWindow()
        local style = Style()
        return style == "classic"
    end
    local function Words() return transcript().Enabled end
    local refresh = function() PlayerFrame:RefreshConfig(); Options:UpdateRows() end
    local refreshTranscript = function() Transcript:RefreshConfig(); Options:UpdateRows() end

    local layout = Layout.New(host, INDENT, -TOP)
    panel.layout = layout
    layout:Header(HOME_TITLE, L.OPT_HOME_NOTE, nil, [[Interface\AddOns\SoftSpoken\icon.tga]], 56)
    -- Two kinds of row that does nothing right now. One that belongs to another way of
    -- showing lines is hidden, and the page closes up round it: a player who chose subtitles
    -- has no use for the window's size. One waiting on a switch beside it is greyed out
    -- instead, saying which switch -- seeing it there is how a player learns it exists.
    local function Requires(row, applies, reason) return layout:Requires(row, applies, reason) end
    local function Only(row, applies) return layout:ShowWhen(row, applies) end
    local function Shown() return Style() ~= "none" end


    -- Show the three main modules; Gossip belongs to Quests and is still
    -- configured on its page. Keep it marked as known so the optional-source
    -- fallback below does not recreate a separate Gossip checkbox.
    layout:Section(L.OPT_PARTS_TITLE, true)
    local known = { gossip = true }
    local cards = {}
    for _, part in ipairs(PARTS) do
        known[part.key] = true
        local key, order = part.key, part.order
        local function On() return Spoken:IsPartOn(key) end
        local function Write(v) Sources:SetTurnedOff(key, not v) end
        local function Missing() if not Sources:Get(key) then return L.REASON_NOT_INSTALLED end end
        table.insert(cards, { icon = part.icon, title = part.label, text = part.text, tooltip = part.tip,
            read = On, write = Write, apply = function() Options:UpdateRows() end, disabled = Missing,
            unavailable = L.PART_NOT_INSTALLED,
            status = function() return Options:PartVoice(key) end,
            hint = function(on) return on and L.OPT_PART_CLICK_OFF or L.OPT_PART_CLICK_ON end,
            button = L.OPT_PART_SETTINGS, onButton = function() Options:OpenPage(order) end,
            buttonEnabled = function() return Sources:Get(key) ~= nil end })
    end
    layout:ModuleList(cards)
    -- Optional third-party sources keep their existing switches. Bind the
    -- callbacks through a function scope: 1.12's Lua 5.0 generic-for
    -- variables must not be captured directly by a deferred UI handler.
    local function AddOtherSource(key, source)
        layout:Checkbox(source.title, L.OPT_PART_OTHER_TIP,
            function() return not Sources:IsTurnedOff(source) end,
            function(v) Sources:SetTurnedOff(key, not v) end)
    end
    for key, source in Sources:Iterate() do
        if not known[key] then AddOtherSource(key, source) end
    end

    -- The two narrator styles this 1.12 client actually supports. Both
    -- use SpokenLayout's existing hand-drawn sketches and tooltip borders;
    -- no Retail assets or new style settings are involved.
    local styles = Options:Styles()
    layout:Section(L.OPT_PLAYER_STYLE, true)
    local tiles = {}
    for _, style in ipairs(styles) do
        table.insert(tiles, { value = style, title = STYLE_LABELS[style], text = STYLE_TEXTS[style],
            tooltip = STYLE_TIPS[style], art = SKETCHES[style] })
    end
    Options:PreviewButton(layout)
    layout:Tiles(tiles, Style, function(v) Addon:SetPlayerStyle(v) end,
        function()
            PlayerFrame:RefreshConfig(); refreshTranscript()
            Options:StyleChosen()
        end, { choose = L.STYLE_CHOOSE })
    layout:Group(L.OPT_NARRATOR_SETTINGS)
    layout:Section(L.OPT_SHOW_TITLE)
    -- Vanilla uses the shared page-caption renderer, not upstream's modern
    -- typewriter engine. Offer only controls that really work.
    if Transcript.vanillaCaptions then
        layout:Section(L.OPT_TEXT_TITLE)
        Only(layout:Checkbox(L.TRANSCRIPT_SHOW, L.TRANSCRIPT_SHOW_TIP,
            function() return transcript().Enabled ~= false end,
            function(v) Transcript:SetEnabled(v) end,
            function() Options:UpdateRows() end), InWindow)
        local size = layout:Slider(L.TRANSCRIPT_SIZE, 12, 26, 1,
            function() return transcript().FontSize or 15 end,
            function(v) transcript().FontSize = v end,
            refreshTranscript, Layout.Number, L.TRANSCRIPT_SIZE_TIP)
        Only(size, InWindow)
        Requires(size, Words, L.REASON_WORDS)
        local fade = layout:Checkbox("Smooth Caption Changes",
            "Gently fade between pages of narrated text.",
            function() return transcript().SmoothPages ~= false end,
            function(v) transcript().SmoothPages = v end, refreshTranscript)
        Only(fade, InWindow)
        Requires(fade, Words, L.REASON_WORDS)
    end
    -- Upstream's Show Progress Bar applies to every visible narrator;
    -- this 1.12 port currently supports Large Window and Voice Only.
    -- The meter is an estimate; only ClassicAPI determines audio completion.
    Only(layout:Checkbox(L.OPT_SUBTITLE_PROGRESS, L.OPT_SUBTITLE_PROGRESS_TIP,
        function() return transcript().SubtitleProgress ~= false end,
        function(v) transcript().SubtitleProgress = v end, refresh), InWindow)

    Only(layout:Checkbox(L.OPT_LOCK_FRAME, L.OPT_LOCK_FRAME_TIP,
        function() return cfg().LockFrame end, function(v) cfg().LockFrame = v end, refresh), Shown)
    Only(layout:Button(L.OPT_RESET, 160, function()
        PlayerFrame:Reset()
        if Subtitle then Subtitle:Reset() end
    end, L.OPT_RESET_TIP), Shown)

    layout:Section(L.OPT_WINDOW_TITLE)
    Only(layout:Slider(L.OPT_SCALE, 0.5, 2, 0.05,
        function() return cfg().FrameScale end, function(v) cfg().FrameScale = v end, refresh,
        nil, L.OPT_SCALE_TIP), InWindow)
    Only(layout:Checkbox(L.OPT_HIDE_PORTRAIT, L.OPT_HIDE_PORTRAIT_TIP,
        function() return cfg().HidePortrait end, function(v) cfg().HidePortrait = v end, refresh),
        InWindow)
    -- The small window's metal and every round button's ring: offered whatever the style.
    if Version.IsCamelot then
        layout:Checkbox(L.OPT_BRONZE_TINT, L.OPT_BRONZE_TINT_TIP,
            function() return cfg().BronzeTint end, function(v) cfg().BronzeTint = v end, refresh)
    end
    -- One row per optional action, shown only for the supported classic window.
    for _, optional in ipairs(Actions.optional) do
        -- Lua 5.0 shares generic-for variables between iterations; callbacks need their own key.
        local actionID = optional.id
        -- Preserve the original read/write behavior, but keep Report's
        -- visibility preference unavailable until that setting is supported.
        local isReport = actionID == "report"
        local reportUnavailable = L.OPT_REPORT_SETTING_UNAVAILABLE
            or "* Report button visibility is currently unavailable."
        local row = layout:Checkbox(format(L.OPT_HIDE_ACTION, optional.label), L.OPT_HIDE_ACTION_TIP,
            function() return cfg().HiddenActions[actionID] end,
            function(v)
                if isReport then return end
                cfg().HiddenActions[actionID] = v or nil
            end, function()
                if isReport then return end
                refresh()
                if Subtitle then Subtitle:Update() end
            end)
        Only(row, InWindow)
        if isReport then
            -- Requires supplies the disabled look; BlockInteraction prevents
            -- the row's hover, tooltip and checkbox clicks on Vanilla 1.12.
            Requires(row, function() return false end, reportUnavailable)
            layout:BlockInteraction(row)
            local notice = layout:Note(reportUnavailable, nil, 28)
            notice:SetTextColor(1, 0.24, 0.24)
            notice:SetAlpha(1)
            notice.layoutBaseAlpha = 1
            Only(notice, InWindow)
        end
    end
    -- No "hide the window" switch: nothing on screen at all is Voice Only, a way of showing
    -- lines like the others, chosen with them above.


    -- The narrator style's settings end here; what follows is Spoken's whatever the style.
    layout:EndGroup()

    -- Azeroth's Compendium: Places, Writings and Stories each supply their
    -- own persisted unlock preference via the registered tab. The rows query
    -- the tab on refresh because feature modules register after this page.
    local function Compendium() return _G.SSCCompendium or _G.SpokenZones112Compendium or _G.SpokenCompendium end
    local function Tab(key)
        local compendium = Compendium()
        return compendium and compendium.Tab and compendium:Tab(key)
    end
    layout:Section(L.OPT_COMPENDIUM_TITLE)
    local open = layout:Button(L.OPT_COMPENDIUM_OPEN, 200, function()
        local compendium = Compendium()
        if compendium and compendium.Toggle then compendium:Toggle() end
    end, L.OPT_COMPENDIUM_OPEN_TIP)
    Only(open, function() local compendium = Compendium(); return compendium ~= nil and compendium.Toggle ~= nil end)
    Requires(open, function()
        local compendium = Compendium()
        return compendium ~= nil and compendium.Available ~= nil and compendium:Available()
    end, L.REASON_COMPENDIUM_OFF)
    for _, unlock in ipairs({
        { tab = "quests", part = "quests", label = L.OPT_UNLOCK_STORIES, tip = L.OPT_UNLOCK_STORIES_TIP, module = L.OPT_PART_QUESTS },
        { tab = "places", part = "zones", label = L.OPT_UNLOCK_PLACES, tip = L.OPT_UNLOCK_PLACES_TIP, module = L.OPT_PART_ZONES },
        { tab = "readables", part = "books", label = L.OPT_UNLOCK_WRITINGS, tip = L.OPT_UNLOCK_WRITINGS_TIP, module = L.OPT_PART_BOOKS },
    }) do
        -- Lua 5.0 reuses 'unlock' and resets it to nil after the last iteration.
        -- Capture keys for each checkbox callback instead of closing over that variable.
        local tabKey, partKey, moduleName = unlock.tab, unlock.part, unlock.module
        local row = layout:Checkbox(unlock.label, unlock.tip,
            function() local tab = Tab(tabKey); return tab ~= nil and tab.unlock ~= nil and tab.unlock.get() end,
            function(v) local tab = Tab(tabKey); if tab and tab.unlock then tab.unlock.set(v) end end)
        Only(row, function() local tab = Tab(tabKey); return tab ~= nil and tab.unlock ~= nil end)
        Requires(row, function() return Spoken:IsPartOn(partKey) end, format(L.REASON_MODULE_OFF_FMT, moduleName))
    end

    -- Everything about how a line is played, whichever addon queued it: the two feature
    -- addons each used to carry their own channel control, and a player with both
    -- installed had two settings for one thing.
    -- Retain the complete language options and saved preferences, but do not
    -- expose working selectors until multilingual voice support is ready.
    -- Requires greys and disables both Vanilla dropdowns; the write guards
    -- also prevent an already-open menu from changing either preference.
    layout:Section(L.OPT_LANGUAGE_TITLE)
    local languageSelectionAvailable = false
    local languageUnavailable = L.OPT_LANGUAGE_UNAVAILABLE
        or "* Multiple languages are not currently supported. Language selection is disabled."
    local function LanguageAvailable() return languageSelectionAvailable end
    local language = function() return Addon.db.profile.Language end
    local voices, fallbacks = { "auto" }, { "none" }
    for _, locale in ipairs(LANGUAGES) do
        table.insert(voices, locale.code)
        table.insert(fallbacks, locale.code)
    end
    local function Native(code)
        return Spoken.Language:GetNativeName(code)
    end
    local function ClientLanguage()
        return Spoken.Language:GetClientLanguage()
    end
    local voiceChoice = layout:Dropdown(L.OPT_VOICE_LANGUAGE, L.OPT_VOICE_LANGUAGE_TIP, voices,
        function() return language().Voice or "auto" end,
        function(code)
            if languageSelectionAvailable then Spoken:SetLanguageChoice("voice", code) end
        end, nil,
        function(code)
            if code == "auto" then return format(L.OPT_LANG_AUTO_FMT, Native(ClientLanguage())) end
            return Native(code)
        end)
    layout:Requires(voiceChoice, LanguageAvailable, languageUnavailable)
    if not languageSelectionAvailable then layout:BlockInteraction(voiceChoice) end
    local fallbackChoice = layout:Dropdown(L.OPT_FALLBACK_LANGUAGE, L.OPT_FALLBACK_LANGUAGE_TIP, fallbacks,
        function() return language().Fallback or "enUS" end,
        function(code)
            if languageSelectionAvailable then Spoken:SetLanguageChoice("fallback", code) end
        end, nil,
        function(code) return code == "none" and L.OPT_FALLBACK_NONE or Native(code) end)
    layout:Requires(fallbackChoice, LanguageAvailable, languageUnavailable)
    if not languageSelectionAvailable then layout:BlockInteraction(fallbackChoice) end
    local languageNotice = layout:Note(languageUnavailable, nil, 34)
    languageNotice:SetTextColor(1, 0.24, 0.24)
    languageNotice:SetAlpha(1)
    languageNotice.layoutBaseAlpha = 1

    layout:Section(L.OPT_AUDIO_TITLE)
    -- ClassicAPI v1.18.14 routes MP3s to real game categories but exposes
    -- no per-file gain setter. New starts use this selection, never alter
    -- game CVars or pretend to control an existing voice's native handle.
    layout:Dropdown(L.OPT_NARRATION_CHANNEL, L.OPT_NARRATION_CHANNEL_TIP,
        { "Master", "SFX", "Music", "Ambience" },
        function() return audio().NarrationChannel or "Master" end,
        function(v)
            if v == "Master" or v == "SFX" or v == "Music" or v == "Ambience" then
                audio().NarrationChannel = v
            end
        end, nil, function(v)
            if v == "SFX" then return "Sound Effects" end
            return v
        end)
    -- Upstream Turn Other Sounds Down. Original 1.12 has Music, Ambience,
    -- and SFX sliders but no independent NPC/Dialog volume.
    local lower = function() return audio().LowerOthers end
    local applyLower = function() OtherSounds:RefreshConfig(); Options:UpdateRows() end
    if OtherSounds:IsAvailable() then
        layout:Checkbox(L.OPT_LOWER_OTHERS, L.OPT_LOWER_OTHERS_TIP,
            function() return lower().Enabled end,
            function(v) lower().Enabled = v and true or false end, applyLower)
    end
    layout:Slider(L.OPT_LINE_GAP, 0, 5, 0.25,
        function() return audio().LineGap or 0 end, function(v) audio().LineGap = v end,
        nil, Layout.Seconds, L.OPT_LINE_GAP_TIP)
    layout:Checkbox(L.OPT_CUE_BETWEEN, L.OPT_CUE_BETWEEN_TIP,
        function() return audio().CueBetweenLines end,
        function(v) audio().CueBetweenLines = v end)
    if OtherSounds:IsAvailable() then
        layout:Section(L.OPT_LOWER_TITLE)
        -- Each call has independent upvalues, including on 1.12 Lua 5.0.
        local function AddVolumeSlider(channel, label)
            local slider = layout:Slider(label, 0, 1, 0.05,
                function() return lower()[channel] end,
                function(v) lower()[channel] = v end,
                applyLower, Layout.Percent)
            Requires(slider, function() return lower().Enabled end, L.REASON_LOWER)
            -- Don't offer a slider that would lower the current voice
            -- category; it is always protected from being ducked.
            Requires(slider, function()
                return (audio().NarrationChannel or "Master") ~= channel
            end, L.REASON_VOICE_CHANNEL)
        end
        AddVolumeSlider("Music", L.OPT_LOWER_MUSIC)
        AddVolumeSlider("Ambience", L.OPT_LOWER_AMBIENCE)
        AddVolumeSlider("SFX", L.OPT_LOWER_SFX)
        layout:Note(L.OPT_LOWER_VANILLA_NO_DIALOG, nil, 36)
    end
    -- The buttons live on Blizzard's quest, book and map frames, not on the player, but
    -- they all open the player's box, so the one switch for them is here. Absent where
    -- Contribute.xml is not loaded (the legacy clients): nothing there to hide.
    if Spoken.Contribute then
        layout:Section(L.OPT_CONTRIBUTE_TITLE)
        -- How much there is to send, first, so a player knows when it is worth sending.
        if Gather then
            layout:Badge(L.OPT_GATHER_ROW, function()
                if not Gather:IsEnabled() then return "off", L.GATHER_OFF end
                local count = Gather:Count()
                if count == 0 then return "off", L.GATHER_NONE end
                return "ok", format(L.GATHER_BADGE_FMT, count)
            end, L.OPT_GATHER_TIP, true)
        end
        layout:Checkbox(L.OPT_HIDE_CONTRIBUTE, L.OPT_HIDE_CONTRIBUTE_TIP,
            function() return Addon.db.profile.Contribute.HideButtons end,
            function(v) Addon.db.profile.Contribute.HideButtons = v end,
            function() Callbacks:Fire("CONTRIBUTE_SETTINGS_CHANGED") end)
        -- The opt-out the first Contribute click promises. Independent of hiding the buttons:
        -- a player who gathers has no use for them, and hiding them must not stop it.
        if Gather then
            layout:Checkbox(L.OPT_GATHER, L.OPT_GATHER_TIP,
                function() return Gather:IsEnabled() end,
                function(v)
                    -- Choosing here is an answer to the first-click question too.
                    Gather:SetIntroduced()
                    Gather:SetEnabled(v)
                end, function() Options:UpdateRows() end)
            layout:Columns(2)
            layout:Button(L.OPT_GATHER_SHARE, 200, function() Spoken:ShowGatherInstructions() end,
                L.OPT_GATHER_SHARE_TIP)
            layout:Button(L.OPT_GATHER_CLEAR, 200, function() Gather:Clear(); Options:UpdateRows() end,
                L.OPT_GATHER_CLEAR_TIP)
        end
    end

    layout:Section(L.OPT_MINIMAP_TITLE)
    layout:Checkbox(L.OPT_MINIMAP_SHOW, L.OPT_MINIMAP_SHOW_TIP,
        function() return not mm().hide end,
        function(v) mm().hide = not v end, function() Minimap:Refresh() end)
    layout:Checkbox(L.OPT_MINIMAP_LOCK, L.OPT_MINIMAP_LOCK_TIP,
        function() return mm().lock end,
        function(v) mm().lock = v end, function() Minimap:Refresh() end)
    -- The minimap already dispatches these saved click mappings.
    local clicks = {
        { key = "LeftButton", label = "Left Click" },
        { key = "MiddleButton", label = "Middle Click" },
        { key = "RightButton", label = "Right Click" },
    }
    -- Playback commands are no longer assignable to minimap mouse buttons.
    -- Minimap:GetClickCommand migrates old/nil assignments to these options.
    local commands = { "Settings", "Compendium", "Menu" }
    local commandLabels = {
        Settings = "Open Settings", Compendium = "Open Compendium",
        Menu = "Open Menu",
    }
    for _, entry in ipairs(clicks) do
        local mouseButton, label = entry.key, entry.label
        layout:Dropdown(label, "Choose an existing minimap button action.", commands,
            function() return Minimap:GetClickCommand(mouseButton) end,
            function(command) Addon.db.profile.Minimap.Commands[mouseButton] = command end,
            nil, function(command) return commandLabels[command] or command end)
    end

    -- Keys for the queue, said here as well as in the game's key bindings: with subtitles only
    -- or voice only there is no window to click, and a player needs to know these exist.
    layout:Section(L.OPT_KEYS_TITLE)
    -- Each action by its name, with its key beside it where a setting's control would be: read
    -- at a glance down the box, the way the game's own bindings list reads, and set right there.
    -- The legacy clients name a key only when told where its name lives ("KEY_SPACE").
    local function KeyText(key)
        if not GetBindingText then return key end
        if Version.IsAnyLegacy then return GetBindingText(key, "KEY_") or key end
        return GetBindingText(key) or key
    end
    local function Bind(name, key)
        if InCombatLockdown and InCombatLockdown() then
            if UIErrorsFrame then UIErrorsFrame:AddMessage(L.OPT_KEY_COMBAT, 1, 0.1, 0.1) end
            return
        end
        if not (SetBinding and GetBindingKey) then return end
        -- The action's old keys go, so it has the one it was given.
        local old = { GetBindingKey(name) }
        for _, previous in ipairs(old) do SetBinding(previous, nil) end
        if key then SetBinding(key, name) end
        if SaveBindings then SaveBindings(GetCurrentBindingSet and GetCurrentBindingSet() or 1) end
        layout:Refresh()
    end
    for _, binding in ipairs(BINDINGS) do
        local name, label = binding[1], binding[2]
        layout:Key(label, function()
            local key = GetBindingKey and GetBindingKey(name)
            if not key then return "off", L.OPT_KEY_NONE end
            return "key", KeyText(key)
        end, function(key)
            -- A key the game or another addon uses already is asked about, not taken.
            local taken = key and GetBindingAction and GetBindingAction(key)
            if taken and taken ~= "" and taken ~= name then
                Layout.Confirm(format(L.OPT_KEY_TAKEN_FMT, KeyText(key), _G["BINDING_NAME_" .. taken] or taken, label),
                    L.OPT_KEY_REPLACE, L.CANCEL, function() Bind(name, key) end)
                return
            end
            Bind(name, key)
        end, L.OPT_KEY_SET_TIP, { press = L.OPT_KEY_PRESS })
    end

    -- Profiles, for all of Spoken at once: the player's own settings and every part that keeps
    -- its settings in profiles switch, copy and delete together.
    Options:AddProfiles(layout)

    -- Restore the player's existing settings (module preferences are separate).
    layout:StartOver(L.OPT_START_OVER_TITLE, L.OPT_RESET_ALL, function()
        Layout.Confirm(L.OPT_RESET_ALL_CONFIRM, L.OPT_RESET_AND_RELOAD, L.CANCEL, function()
            -- The Unlock switches are on this page but kept with each part's settings, which
            -- ResetProfile does not reach, and each part's own Reset skips them.
            for _, key in ipairs({ "places", "readables", "quests" }) do
                local tab = Tab(key)
                if tab and tab.unlock then tab.unlock.set(false) end
            end
            Addon.db:ResetProfile()
            Addon.db.global.Layout = nil
            ReloadUI()
        end)
    end, L.OPT_RESET_ALL_TIP)

    if panel.HookScript then
        panel:HookScript("OnShow", function() Options:UpdateRows() end)
        -- The sample is for placing the subtitle while the settings are open, not after.
        panel:HookScript("OnHide", function()
            -- Close search regardless of whether the player used the X, Escape,
            -- the minimap button, or a module's own entry point.
            if Search and Search.Close then Search:Close() end
            if Subtitle and Subtitle:IsShowingSample() then Subtitle:ShowSample(false) end
            if Options.previewing or Addon.previewStyle then Options:SetPreviewing(false) end
        end)
    end
    return panel
end

--- Grey out what the current choices leave doing nothing, saying why, and name the sample
--- button for what a click on it will do.
function Options:UpdateRows()
    if not panel then return end
    panel.layout:Refresh()
    if Options.activePage and Options.activePage.layout then
        Options.activePage.layout:Refresh()
    end
    local sample = panel.sampleButton
    if sample then
        sample:SetText(Subtitle:IsShowingSample() and L.SUBTITLE_SAMPLE_HIDE or L.SUBTITLE_SAMPLE_SHOW)
    end
end

--- How a part stands, for its card and the top of its page: not installed, switched off, or
--- on with however many voice packs it found. The words are the player's, so every part
--- says it the same way.
function Options:PartStatus(key)
    local source = Sources:Get(key)
    if not source then return "off", L.PART_NOT_INSTALLED end
    if Sources:IsTurnedOff(source) then return "off", L.PART_OFF end
    local count = self:PackCount(source)
    if not count then return nil end
    if count == 0 then return "warn", L.PART_NO_PACK end
    if count == 1 then return "ok", L.PART_ONE_PACK end
    return "ok", format(L.PART_PACKS_FMT, count)
end

-- How many voice packs a part's addon found, or nil where it does not say.
function Options:PackCount(source)
    if not (source and source.packs) then return nil end
    local ok, packs = pcall(source.packs)
    if not ok or type(packs) ~= "table" then return nil end
    return getn(packs)
end

--- Whether a module has its voices, apart from whether it is enabled: "Voice Packs" and how many
--- of its packs are installed, in any language. Not out of how many there are: a player needs
--- their own language's, not all of them. Nothing for a module that is not installed.
function Options:PartVoice(key)
    local source = Sources:Get(key)
    if not source then return nil end
    local have = self:PackCount(source)
    if not have then return nil end
    return have == 0 and "muted" or "neutral", L.PART_VOICE, tostring(have)
end

--- Every AceDB object a profile choice applies to: the player's, then each installed part's
--- that keeps its settings in profiles (a source's `profiles`).
-- One installed source may advertise profiles before its AceDB object is ready.
-- Check for a callable GetProfiles method, rather than just a truthy field.
function Options:ProfileDBs()
    local dbs, seen = {}, {}
    if Addon.db and type(Addon.db.GetProfiles) == "function" then
        table.insert(dbs, Addon.db)
        seen[Addon.db] = true
    end
    for _, source in Sources:Iterate() do
        if type(source.profiles) == "function" then
            local ok, db = pcall(source.profiles)
            if ok and type(db) == "table" and
                type(db.GetProfiles) == "function" and not seen[db] then
                table.insert(dbs, db)
                seen[db] = true
            end
        end
    end
    return dbs
end

-- AceDB's GetProfiles returns a list, but a partially initialized module
-- must not prevent the entire 1.12 settings window from opening.
local function ProfileList(db)
    if not db or type(db.GetProfiles) ~= "function" then return {} end
    local ok, result = pcall(db.GetProfiles, db)
    if not ok or type(result) ~= "table" then return {} end
    return result
end

local function Has(db, name)
    for _, other in ipairs(ProfileList(db)) do
        if other == name then return true end
    end
    return false
end

--- Every profile any of the installed databases has, sorted once.
function Options:ProfileNames()
    local seen, names = {}, {}
    for _, db in ipairs(self:ProfileDBs()) do
        for _, name in ipairs(ProfileList(db)) do
            if type(name) == "string" and not seen[name] then
                seen[name] = true
                table.insert(names, name)
            end
        end
    end
    table.sort(names)
    return names
end

function Options:CurrentProfile()
    local db = self:ProfileDBs()[1]
    return db and db:GetCurrentProfile()
end

--- Switch every one to `name`, which AceDB makes where it is new.
function Options:SetProfile(name)
    for _, db in ipairs(self:ProfileDBs()) do db:SetProfile(name) end
end

--- Copy `name` into the profile in use, in every one that has it.
function Options:CopyProfile(name)
    for _, db in ipairs(self:ProfileDBs()) do
        if db.CopyProfile and Has(db, name) and db:GetCurrentProfile() ~= name then db:CopyProfile(name) end
    end
end

function Options:DeleteProfile(name)
    for _, db in ipairs(self:ProfileDBs()) do
        if db.DeleteProfile and Has(db, name) and db:GetCurrentProfile() ~= name then db:DeleteProfile(name) end
    end
end

function Options:AddProfiles(layout)
    if not self:ProfileDBs()[1] then return end
    self.profileLayout = layout
    -- Preserve all AceDB profile logic and saved data for later use, but make
    -- this entire UI section inert until profile support is ready.
    local profileSelectionAvailable = false
    local profileUnavailable = L.OPT_PROFILE_UNAVAILABLE
        or "* Profiles are currently unavailable. Profile management is disabled."
    local function ProfileAvailable() return profileSelectionAvailable end
    local function DisableProfileControl(control)
        layout:Requires(control, ProfileAvailable, profileUnavailable)
        if not profileSelectionAvailable then layout:BlockInteraction(control) end
    end
    local function Others()
        local others, current = {}, self:CurrentProfile()
        for _, name in ipairs(self:ProfileNames()) do
            if name ~= current then table.insert(others, name) end
        end
        return others
    end
    local function Pick(name) return name or L.OPT_PROFILE_PICK end
    layout:Section(L.OPT_SECTION_PROFILES)
    local current = layout:Dropdown(L.OPT_PROFILE, L.OPT_PROFILE_TIP,
        function() return self:ProfileNames() end,
        function() return self:CurrentProfile() end,
        function(name)
            if profileSelectionAvailable then self:SetProfile(name); layout:Refresh() end
        end)
    DisableProfileControl(current)
    local copy = layout:Dropdown(L.OPT_COPY_PROFILE, L.OPT_COPY_PROFILE_TIP,
        Others, function() return nil end,
        function(name)
            if profileSelectionAvailable then self:CopyProfile(name); layout:Refresh() end
        end, nil, Pick)
    DisableProfileControl(copy)
    local delete = layout:Dropdown(L.OPT_DELETE_PROFILE, L.OPT_DELETE_PROFILE_TIP,
        Others, function() return nil end,
        function(name)
            if profileSelectionAvailable then self:DeleteProfile(name); layout:Refresh() end
        end, nil, Pick)
    DisableProfileControl(delete)
    if StaticPopupDialogs and StaticPopup_Show then
        StaticPopupDialogs.SPOKEN_NEW_PROFILE = StaticPopupDialogs.SPOKEN_NEW_PROFILE or {
            text = L.OPT_PROFILE_NEW_PROMPT, button1 = _G.ACCEPT or "Accept", button2 = L.CANCEL,
            hasEditBox = true, timeout = 0, whileDead = true, hideOnEscape = true,
            -- 1.12 and 2.4.3 hand these nothing: the dialog, or its edit box, is in `this`.
            OnAccept = function(popup)
                if not profileSelectionAvailable then return end
                popup = popup or this
                local box = popup and (popup.editBox or popup.EditBox)
                if not box and StaticPopup_Visible then
                    local which = StaticPopup_Visible("SPOKEN_NEW_PROFILE")
                    box = which and _G[which .. "EditBox"]
                end
                local name = box and box:GetText()
                if name and name ~= "" then
                    Options:SetProfile(name)
                    if Options.profileLayout then Options.profileLayout:Refresh() end
                end
            end,
            EditBoxOnEnterPressed = function(box)
                box = box or this
                local popup = box and box:GetParent()
                if popup and popup.button1 then popup.button1:Click() end
            end,
        }
        local newProfile = layout:Button(L.OPT_PROFILE_NEW, 200, function()
            if profileSelectionAvailable then StaticPopup_Show("SPOKEN_NEW_PROFILE") end
        end, L.OPT_PROFILE_NEW_TIP)
        DisableProfileControl(newProfile)
    end
    local notice = layout:Note(profileUnavailable, nil, 34)
    notice:SetTextColor(1, 0.24, 0.24)
    notice:SetAlpha(1)
    notice.layoutBaseAlpha = 1
end

--- Open Spoken's page on a tab: Home's is 0, a feature addon's the order it was listed in.
function Options:OpenPage(order)
    if not panel then return false end
    if not self:SelectLegacyPage(order) then return false end
    panel:Show()
    return true
end

--- Every page search can reach: this one, then the feature addons' in their order.
function Options:Pages()
    local pages = {}
    if panel then
        table.insert(pages, { name = L.OPT_HOME_TITLE, layout = panel.layout, order = 0 })
    end
    for _, page in ipairs(self.pages or {}) do
        if page.layout then table.insert(pages, page) end
    end
    return pages
end

--- Open a page, and once the settings window has drawn it, scroll to `row` and light it up.
--- `page` is one of Pages(), each of which OpenPage finds by its order.
function Options:ShowRow(page, row)
    if not self:OpenPage(page.order) then return end
    page.layout:Refresh()
    local offset = math.max(0, -(row.layoutY or 0) - 60)
    -- Search navigation uses the same shared native scrollbar as tab navigation.
    if scroller then
        local maximum = scroller.GetVerticalScrollRange and
            scroller:GetVerticalScrollRange() or offset
        if offset > maximum then offset = maximum end
        scroller:SetVerticalScroll(offset)
    end
    page.layout:Highlight(row)
end

-- All module pages use one bounded Blizzard 1.12 scroll frame.
-- Each page keeps its own independent layout.
function Options:RefreshNavigation()
    if not (panel and panel.isWindow) then return end
    local pages = { { order = 0, name = L.OPT_HOME_TITLE } }
    for _, page in ipairs(self.pages or {}) do
        table.insert(pages, page)
    end
    -- Four pages fit the native Vanilla window: Home, Stories, Places, Writings.
    -- The currently selected Blizzard button is greyed out/disabled, exactly
    -- as it was before the extra gold selection rule was introduced.
    local width = math.floor(LEGACY_NAV_WIDTH / table.getn(pages))
    local activeOrder = self.activePage and self.activePage.order or 0
    for index, entry in ipairs(pages) do
        local button = legacyNavButtons[index]
        if not button then
            button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
            button:SetHeight(24)
            legacyNavButtons[index] = button
        end
        button:ClearAllPoints()
        button:SetWidth(width - 4)
        button:SetPoint("TOPLEFT", panel, "TOPLEFT", 18 + (index - 1) * width, LEGACY_NAV_TOP)
        button:SetText(entry.order == 0 and "Home" or entry.name)
        local order = entry.order
        button:SetScript("OnClick", function()
            if (Options.activePage and Options.activePage.order or 0) ~= order then
                Options:SelectLegacyPage(order)
            end
        end)
        if order == activeOrder then
            button:Disable()
        else
            button:Enable()
        end
        button:Show()
    end
    for index = table.getn(pages) + 1, table.getn(legacyNavButtons) do
        legacyNavButtons[index]:Hide()
    end
end

function Options:SelectLegacyPage(order)
    if not (panel and panel.isWindow and scroller and legacyScrollChild) then return false end
    local chosen
    if order ~= 0 then
        for _, page in ipairs(self.pages or {}) do
            if page.order == order then chosen = page; break end
        end
        if not chosen then return false end
    end
    local child = chosen and chosen.frame or legacyScrollChild
    local old = self.activePage and self.activePage.frame or legacyScrollChild
    -- Preview belongs to Home, not to whichever module tab is opened next.
    if order ~= 0 and (self.previewing or Addon.previewStyle) then
        self:SetPreviewing(false)
    end
    if old ~= child then old:Hide() end
    if Search and Search.Close then Search:Close() end
    -- All pages share the same scrollbar; no second window or nested scrollbar.
    child:SetParent(scroller)
    child:SetWidth(LEGACY_CONTENT_WIDTH)
    scroller:SetScrollChild(child)
    self.activePage = chosen
    child:Show()
    if scroller.SetVerticalScroll then scroller:SetVerticalScroll(0) end
    local layout = chosen and chosen.layout or panel.layout
    if layout then layout:Refresh() end
    -- Feature pages can have their own resize callback; always recalculate
    -- the shared 1.12 ScrollFrame after swapping its ScrollChild.
    if FitWindow then FitWindow() end
    self:RefreshNavigation()
    return true
end

-- Keep the scroll child tall enough for the active page without growing the
-- bounded Vanilla window.
FitWindow = function()
    if not panel then return end
    local activeLayout = Options.activePage and Options.activePage.layout or panel.layout
    if not activeLayout then return end
    local needed = math.max(1, TOP + activeLayout:Height() + BOTTOM)
    if legacyScrollChild then
        -- Keep a full-height settings window except for Voice Only on Home,
        -- where the narrator controls disappear and the empty space should
        -- collapse. Module tabs and Large Window retain the normal height.
        if panel.isWindow and legacyMaxHeight then
            local target = legacyMaxHeight
            if not Options.activePage and Addon:PlayerStyle() == "none" then
                -- Viewport = panel height + LEGACY_SCROLL_TOP - 20.
                -- Leave an 8px safety margin under the final setting.
                target = math.min(target,
                    math.max(300, needed - LEGACY_SCROLL_TOP + 28))
            end
            if math.abs((panel:GetHeight() or 0) - target) > 0.5 then
                panel:SetHeight(target)
            end
        end
        local child = Options.activePage and Options.activePage.frame or legacyScrollChild
        child:SetHeight(needed)
        -- Refresh the native scroll rectangle and slider after every reflow.
        if scroller then
            if scroller.UpdateScrollChildRect then scroller:UpdateScrollChildRect() end
            local maximum = math.max(0, needed - (scroller:GetHeight() or 0))
            local current = scroller.GetVerticalScroll and scroller:GetVerticalScroll() or 0
            local offset = math.max(0, math.min(current or 0, maximum))
            local name = scroller.GetName and scroller:GetName()
            local scrollbar = name and getglobal(name .. "ScrollBar")
            if scrollbar and scrollbar.SetMinMaxValues then
                scrollbar:SetMinMaxValues(0, maximum)
            end
            if scroller.SetVerticalScroll then scroller:SetVerticalScroll(offset) end
            if scrollbar and scrollbar.SetValue then scrollbar:SetValue(offset) end
        end
    end
end

function Options:Setup()
    if panel then return end
    Build()
    panel.layout.onResize = function() FitWindow() end
    self:UpdateRows()
    panel.isWindow = true
    -- Unified Vanilla settings window, bounded to the visible screen.
    panel.isWindow = true
    local screenHeight = (UIParent and UIParent.GetHeight and UIParent:GetHeight()) or 768
    legacyMaxHeight = math.min(620, math.max(300, screenHeight - 80))
    panel:SetSize(LEGACY_WIDTH, legacyMaxHeight)
    panel:SetPoint("CENTER")
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:SetFrameStrata("DIALOG")
    -- Use Blizzard's original Vanilla Options menu background, which
    -- carries its own translucent dark alpha. Keep the separate silver
    -- window border, rock header and search ornaments unchanged.
    if panel.SetBackdrop then
        panel:SetBackdrop({
            bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
            tile = true, tileSize = 32,
            insets = {left = 10, right = 10, top = 10, bottom = 10},
        })
        panel:SetBackdropColor(1, 1, 1, 1)
    end

    -- Give only the upper title/tab section the same tiled rock backing
    -- used by the Compendium. Keep the search surround and scroll content
    -- on the existing dark window backdrop.
    local headerRock = CreateFrame("Frame", nil, panel)
    headerRock:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -11)
    headerRock:SetPoint("BOTTOMRIGHT", panel, "TOPRIGHT", -10, -93)
    headerRock:SetFrameLevel(panel:GetFrameLevel())
    headerRock:EnableMouse(false)
    headerRock:SetBackdrop({
        bgFile = [[Interface\AddOns\SoftSpoken\Compendium\Textures\Skin\UI-Background-Rock-Classic]],
        tile = true, tileSize = 256,
        insets = {left = 0, right = 0, top = 0, bottom = 0},
    })

    -- A separate, mouse-transparent edge-only frame makes the native
    -- silver window border render over the rock and cropped housing.
    -- The underlying panel keeps only the flat dark background.
    local windowTrim = CreateFrame("Frame", nil, panel)
    windowTrim:SetAllPoints(panel)
    windowTrim:SetFrameLevel(headerRock:GetFrameLevel() + 1)
    windowTrim:EnableMouse(false)
    windowTrim:SetBackdrop({
        edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
        edgeSize = 32,
        insets = {left = 10, right = 10, top = 10, bottom = 10},
    })

    -- The search ornament needs its own draw level above the outer
    -- silver window border. Keep this frame mouse-transparent; only its
    -- narrow edge textures are drawn on it.
    local searchTrim = CreateFrame("Frame", nil, panel)
    searchTrim:SetAllPoints(panel)
    searchTrim:SetFrameLevel(windowTrim:GetFrameLevel() + 1)
    searchTrim:EnableMouse(false)

    -- The title plaque stays above both ornamental frame layers.
    local titleLayer = CreateFrame("Frame", nil, panel)
    titleLayer:SetAllPoints(panel)
    titleLayer:SetFrameLevel(searchTrim:GetFrameLevel() + 1)
    titleLayer:EnableMouse(false)

    -- The native 400x64 UI-DialogBox-Header is centered on this window.
    -- Blizzard's Key Bindings uses a -30 horizontal offset for its own
    -- asymmetric frame; retaining that offset shifts SoftSpoken's plaque
    -- left of center. Keep the caption anchored to the plaque itself.
    local titlePlate = titleLayer:CreateTexture(nil, "ARTWORK")
    titlePlate:SetTexture([[Interface\DialogFrame\UI-DialogBox-Header]])
    titlePlate:SetWidth(400)
    titlePlate:SetHeight(64)
    titlePlate:SetPoint("TOP", panel, "TOP", 0, 12)
    local heading = titleLayer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    heading:SetWidth(210)
    heading:SetHeight(16)
    heading:SetJustifyH("CENTER")
    heading:SetPoint("TOP", titlePlate, "TOP", 0, -13)
    heading:SetText(HOME_TITLE)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", function() panel:StartMoving() end)
    panel:SetScript("OnDragStop", function() panel:StopMovingOrSizing() end)
    FitWindow()
    -- Reuse the Compendium's native marble-and-metal scrollbar housing.
    -- Keep the existing 1.12 scrollbar as the only scroll controller.
    if SSCNativeScrollbar and SSCNativeScrollbar.AttachSettings then
        SSCNativeScrollbar.AttachSettings(panel, scroller)
    end
    -- Search-frame rails and diamond corners overdraw the outer trim.
    DrawOrnateHeaderBand(searchTrim)
    if Search and Search.BuildLegacy then Search:BuildLegacy(panel) end
    panel:Hide()
    self:RefreshNavigation()
    self:SelectLegacyPage(0)
    -- Native escape handling. The panel has a stable global name, and
    -- its OnHide hook also clears any open search results or preview.
    if UISpecialFrames then
        table.insert(UISpecialFrames, "SpokenOptionsPanel")
    end
    local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -6, -6)
    close:SetFrameLevel(titleLayer:GetFrameLevel() + 1)
    -- Keep the mirrored housing on the rock frame's BORDER layer:
    -- above that frame's rock backdrop, beneath its ARTWORK/OVERLAY
    -- decoration, and below the native close button.
    local closeHousing = headerRock:CreateTexture(nil, "BORDER")
    closeHousing:SetTexture([[Interface\AddOns\SoftSpoken\Compendium\Textures\Skin\UI-Frame]])
    closeHousing:SetTexCoord(114/128, 90/128, 26/128, 2/128)
    closeHousing:SetWidth(24)
    closeHousing:SetHeight(24)
    closeHousing:SetPoint("CENTER", close, "CENTER", 0, 0)
    close:SetScript("OnClick", function() panel:Hide() end)
end

--- A feature addon's page, as a tab on Spoken's. A feature addon may build its panel before
--- this one exists, at its own load, so the page waits until it does. `page.Open` opens Spoken
--- on its tab; legacy clients share one bounded window instead of separate pages.
function Options:AddPage(frame, name, order, layout)
    if not frame or not layout then return nil end
    local page = { frame = frame, name = name, order = order or 100, layout = layout }
    page.Open = function() return Options:OpenPage(page.order) end
    self.pages = self.pages or {}
    table.insert(self.pages, page)
    table.sort(self.pages, function(a, b) return a.order < b.order end)
    -- A Vanilla page is a scroll child, not a separate settings window.
    frame:SetWidth(LEGACY_CONTENT_WIDTH)
    frame:Hide()
    local priorResize = layout.onResize
    layout.onResize = function(height)
        frame:SetHeight(TOP + layout:Height() + BOTTOM)
        if priorResize then priorResize(height) end
    end
    if panel and panel.isWindow then self:RefreshNavigation() end
    return page
end

function Options:Open()
    if panel then
        if panel:IsShown() then
            if Search and Search.Close then Search:Close() end
            panel:Hide()
        else
            self:SelectLegacyPage(0)
            panel:Show()
        end
    else
        print("Spoken: " .. L.OPT_NO_SETTINGS_API)
    end
end
