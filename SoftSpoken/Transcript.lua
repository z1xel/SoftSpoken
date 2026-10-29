setfenv(1, SpokenEnv)

-- Turtle WoW / Lua 5.0 shared transcript engine.
-- All sources supply present.transcript; the player owns display, timing and lifecycle.
-- Phase 4.2: width-aware pages and gentle page fades.
-- The Vanilla-compatible timing and clip lifecycle are retained unchanged.
Transcript = { unavailable = true, vanillaCaptions = true } -- hide unported modern-only options

local CAPTION_HEIGHT = 66
local PAGE_LINES = 2
local FADE_OUT_SECONDS = 0.13
local FADE_IN_SECONDS = 0.17
local FALLBACK_SECONDS = 4 -- preserves the pre-4.1 behavior for clips with no known length
local UTF8_CHAR = "[%z\1-\127\194-\244][\128-\191]*"

local function FontSize()
    local n = tonumber(Addon:Profile("Transcript").FontSize) or 15
    return math.max(12, math.min(26, n))
end

local function Config()
    return Addon:Profile("Transcript")
end

local function SmoothPages()
    return Config().SmoothPages ~= false
end

-- Use the actual text metrics where available, but keep a safe fallback for
-- Vanilla clients and early UI initialization that return zero widths.
local function ApproxWidth(text)
    local _, count = string.gsub(text or "", "[%z\1-\127\194-\244][\128-\191]*", "")
    return count * FontSize() * 0.55
end

local function TextWidth(label, text)
    if label and label.SetText and label.GetStringWidth then
        label:SetText(text)
        local ok, width = pcall(label.GetStringWidth, label)
        if ok and type(width) == "number" and width > 0 then
            return width
        end
    end
    return ApproxWidth(text)
end

local function Enabled()
    return Addon:Profile("Transcript").Enabled ~= false
end

-- Adapted from upstream Spoken's transcript tokenizer, without 5.1-only syntax/APIs.
-- Strip WoW display markup *before* word indexing, so offsets match visible text.
function Transcript:CleanText(text)
    if type(text) ~= "string" then return "" end
    text = string.gsub(text, "|H.-|h(.-)|h", "%1")
    text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
    text = string.gsub(text, "|r", "")
    text = string.gsub(text, "|T.-|t", "")
    text = string.gsub(text, "|A.-|a", "")
    text = string.gsub(text, "|n", "\n")
    text = string.gsub(text, "\r\n", "\n")
    text = string.gsub(text, "\r", "\n")
    text = string.gsub(text, "^%s+", "")
    return string.gsub(text, "%s+$", "")
end

local function TextForClip(clip)
    local present = clip and clip.present
    local text = present and present.transcript
    if type(text) ~= "string" then return nil end
    text = Transcript:CleanText(text)
    if not string.find(text, "%S") then return nil end
    return text
end

local STOPS = { ["."] = 0.7, ["!"] = 0.7, ["?"] = 0.7,
    ["。"]=0.7, ["！"]=0.7, ["？"]=0.7,
    [","] = 0.35, [";"] = 0.35, [":"] = 0.35,
    ["，"]=0.35, ["、"]=0.35, ["；"]=0.35, ["："]=0.35 }
local CLOSERS = { ['"'] = true, ["'"] = true, [")"] = true, ["]"] = true,
    ["”"] = true, ["’"] = true, ["」"] = true, ["』"] = true,
    ["）"] = true, ["》"] = true, ["】"] = true }
local OPENERS = { ["“"] = true, ["‘"] = true, ["「"] = true, ["『"] = true,
    ["（"] = true, ["《"] = true, ["【"] = true }

local function PausesAfter(chars)
    local i = table.getn(chars)
    while i > 1 and CLOSERS[chars[i]] do i = i - 1 end
    return STOPS[chars[i]] or 0
end

local function CodePoint(char)
    if string.len(char) ~= 3 then return 0 end
    local a, b, c = string.byte(char, 1, 3)
    return math.mod(a, 16) * 4096 + math.mod(b, 64) * 64 + math.mod(c, 64)
end

local function IsHan(char)
    local code = CodePoint(char)
    return (code >= 0x3040 and code <= 0x30FF)
        or (code >= 0x3400 and code <= 0x9FFF)
        or (code >= 0xF900 and code <= 0xFAFF)
end

local function IsPunctuation(char)
    local code = CodePoint(char)
    return string.find(char, "^%p$") ~= nil
        or (code >= 0x2000 and code <= 0x206F)
        or (code >= 0x3000 and code <= 0x303F)
        or (code >= 0xFF00 and code <= 0xFF65)
end

-- Keep punctuation attached to the preceding Han/kana character, without inserting
-- artificial spaces in captions. Other languages continue to use whitespace words.
local function SplitRun(run)
    local words, open = {}, {}
    local function Add(char, han)
        local word = { chars = open, han = han }
        table.insert(word.chars, char)
        table.insert(words, word)
        open = {}
    end
    for char in string.gfind(run, UTF8_CHAR) do
        local last = words[table.getn(words)]
        if IsHan(char) then
            Add(char, true)
        elseif OPENERS[char] then
            table.insert(open, char)
        elseif table.getn(open) == 0 and last and (not last.han or IsPunctuation(char)) then
            table.insert(last.chars, char)
        else
            Add(char, false)
        end
    end
    if table.getn(open) > 0 then
        if table.getn(words) == 0 then table.insert(words, { chars = {} }) end
        local last = words[table.getn(words)].chars
        for _, char in ipairs(open) do table.insert(last, char) end
    end
    return words
end

-- Word positions are byte offsets in the cleaned text, and weights represent
-- relative speech time. Both are independent of player dimensions/font settings.
local function Split(text)
    local words, total = {}, 0
    for at, space, run in string.gfind(text, "()(%s*)(%S+)") do
        local first = at + string.len(space)
        for i, item in ipairs(SplitRun(run)) do
            local wordText = table.concat(item.chars)
            local count = table.getn(item.chars)
            local weight = 0.6 + count * 0.12 + PausesAfter(item.chars)
            local word = {
                text = wordText, count = count, first = first,
                last = first + string.len(wordText) - 1,
                joined = i > 1, breakBefore = i == 1 and string.find(space, "\n") ~= nil,
                startWeight = total, finishWeight = total + weight,
            }
            table.insert(words, word)
            first = first + string.len(wordText)
            total = total + weight
        end
    end
    return words, total
end

-- Supplied timings match the upstream contract: one *start time in seconds* per
-- word, ordered from 0 through clip.length. Invalid, partial, or out-of-range
-- arrays are ignored in full to avoid incorrect word or page timing.
local function ApplyTimings(words, timings, duration)
    local count = table.getn(words)
    if type(timings) ~= "table" or count == 0 or
        table.getn(timings) ~= count or not duration or duration <= 0 then return false end
    local previous = 0
    for i = 1, count do
        local at = timings[i]
        if type(at) ~= "number" or at ~= at or at < previous or at > duration then
            return false
        end
        previous = at
    end
    for i = 1, count do
        words[i].start = timings[i]
        words[i].finish = timings[i + 1] or duration
    end
    return true
end

-- Pure timeline construction for pagination and future typewriter modes.
-- Returns: words, totalWeight, timingIsExplicit, timelineSeconds.
function Transcript:BuildTimeline(text, duration, timings)
    local words, weight = Split(self:CleanText(text))
    duration = tonumber(duration)
    if not duration or duration <= 0 or duration ~= duration then duration = nil end
    local length = duration or FALLBACK_SECONDS
    local explicit = ApplyTimings(words, timings, duration)
    if not explicit and weight > 0 then
        for _, word in ipairs(words) do
            word.start = word.startWeight * length / weight
            word.finish = word.finishWeight * length / weight
        end
    end
    return words, weight, explicit, length
end

-- Build two-line pages using the rendered font's text width. The separator
-- keep paragraph boundaries and natural spaces in the displayed page text.
local function Pages(words, maxWidth, probe)
    local pages, parts = {}, {}
    local firstWord, lastWord, currentLine, lines = nil, nil, "", 1
    maxWidth = math.max(60, (maxWidth or 240) - 6)

    local function Flush()
        if not firstWord then return end
        table.insert(pages, {
            text = table.concat(parts), firstWord = firstWord, lastWord = lastWord,
        })
        parts = {}
        firstWord, lastWord, currentLine, lines = nil, nil, "", 1
    end

    for i, word in ipairs(words) do
        local separator = ""
        if firstWord then
            separator = word.joined and "" or " "
            if word.breakBefore then separator = "\n" end
            if separator == "\n" or (currentLine ~= "" and
                TextWidth(probe, currentLine .. separator .. word.text) > maxWidth) then
                if lines >= PAGE_LINES then
                    Flush()
                    separator = ""
                else
                    lines = lines + 1
                    separator = "\n"
                    currentLine = ""
                end
            end
        end
        if not firstWord then firstWord = i end
        lastWord = i
        table.insert(parts, separator .. word.text)
        currentLine = currentLine .. (separator == "\n" and "" or separator) .. word.text
    end
    Flush()
    return pages
end

function Transcript:HeightForClip(clip)
    return Enabled() and TextForClip(clip) and CAPTION_HEIGHT or 0
end

function Transcript:ResizePlayer(frame, height, minWidth, maxWidth)
    if frame.SetMinResize then
        frame:SetMinResize(minWidth, height)
        frame:SetMaxResize(maxWidth, height)
    end
    if frame:GetHeight() ~= height then frame:SetHeight(height) end
end

function Transcript:CreateDisplay()
    if self.frame then return end
    local player = PlayerFrame and PlayerFrame.frame
    if not player then return end
    local frame = CreateFrame("Frame", nil, player)
    frame:SetWidth(240)
    frame:SetHeight(CAPTION_HEIGHT)
    frame:SetPoint("TOPLEFT", player, "TOPLEFT", 135, -124)
    frame:SetFrameLevel(player:GetFrameLevel() + 3)
    local label = frame:CreateFontString(nil, "OVERLAY")
    label:SetFont("Fonts\\FRIZQT__.TTF", FontSize(), "OUTLINE")
    label:SetTextColor(1, 0.95, 0.83)
    label:SetJustifyH("LEFT")
    label:SetJustifyV("TOP")
    label:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -1)
    label:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -3, 0)
    local probe = frame:CreateFontString(nil, "ARTWORK")
    probe:SetFont("Fonts\\FRIZQT__.TTF", FontSize(), "OUTLINE")
    probe:Hide()
    frame:Hide()
    self.frame, self.label, self.probe = frame, label, probe

    local driver = CreateFrame("Frame", nil, UIParent)
    driver:SetScript("OnUpdate", function(self, elapsed)
        local delta = type(elapsed) == "number" and elapsed or arg1
        if type(delta) == "number" then Transcript:Tick(delta) end
    end)
    self.driver = driver
end

function Transcript:Dock(parent, anchor, point, x, y, width, height)
    self:CreateDisplay()
    if not self.frame then return end
    if parent and self.frame:GetParent() ~= parent then self.frame:SetParent(parent) end
    if parent then self.frame:SetFrameLevel(parent:GetFrameLevel() + 3) end
    self.frame:ClearAllPoints()
    if anchor then self.frame:SetPoint("TOPLEFT", anchor, point, x, y) end
    self.frame:SetWidth(math.max(1, width or 1))
    self.frame:SetHeight(math.max(1, height or 1))
    if self.activeClip and width and self.captionWidth ~= width then
        self.captionWidth = width
        self:Repage()
    elseif width then
        self.captionWidth = width
    end
    if height and height > 0 and self.activeClip and Enabled() then
        self.frame:Show()
    else
        self.frame:Hide()
    end
end

function Transcript:StopClip(clip)
    if clip and self.activeClip ~= clip then return end
    self.activeClip, self.pages, self.started = nil, nil, nil
    self.words, self.totalWeight, self.timelineLength = nil, nil, nil
    self.explicitTimings, self.activeText, self.duration = nil, nil, nil
    self.lastPage, self.throttle = nil, nil
    self.requestedPage, self.transition = nil, nil
    if self.frame then self.frame:SetAlpha(1); self.frame:Hide() end
end

-- Word indices stay stable across reflow; neither page layout nor font changes
-- reset the playback clock. A resize snaps to its newly appropriate page.
function Transcript:Repage()
    if not self.activeClip or not self.words then return end
    if self.label then self.label:SetFont("Fonts\\FRIZQT__.TTF", FontSize(), "OUTLINE") end
    if self.probe then self.probe:SetFont("Fonts\\FRIZQT__.TTF", FontSize(), "OUTLINE") end
    self.pages = Pages(self.words, self.captionWidth, self.probe)
    self.lastPage, self.requestedPage, self.transition = nil, nil, nil
    self.throttle = 0.08
    if self.frame then self.frame:SetAlpha(1) end
    self:Tick(0)
end

function Transcript:ShowPage(index)
    local page = self.pages and self.pages[index]
    if not page then return end
    self.lastPage = index
    self.label:SetText(page.text)
end

function Transcript:FadeOut()
    if not self.frame or not SmoothPages() then
        self.transition = nil
        if self.frame then self.frame:SetAlpha(1) end
        self:ShowPage(self.requestedPage)
        return
    end
    self.transition = { stage = "out", elapsed = 0, from = self.frame:GetAlpha() or 1 }
end

function Transcript:AdvanceFade(delta)
    local fade = self.transition
    if not fade or not self.frame then return end
    fade.elapsed = fade.elapsed + math.max(0, delta or 0)
    if fade.stage == "out" then
        local fraction = math.min(1, fade.elapsed / FADE_OUT_SECONDS)
        self.frame:SetAlpha(fade.from * (1 - fraction))
        if fraction >= 1 then
            self:ShowPage(self.requestedPage)
            self.transition = { stage = "in", elapsed = 0 }
        end
    else
        local fraction = math.min(1, fade.elapsed / FADE_IN_SECONDS)
        self.frame:SetAlpha(fraction)
        if fraction >= 1 then
            self.frame:SetAlpha(1)
            self.transition = nil
        end
    end
end

function Transcript:StartClip(clip)
    local text = TextForClip(clip)
    if not Enabled() or not text then
        self:StopClip()
        return false
    end
    local words, weight, explicit, timelineLength = self:BuildTimeline(
        text, clip.length, clip.present and clip.present.timings)
    if table.getn(words) == 0 then
        self:StopClip()
        return false
    end
    self:CreateDisplay()
    if not self.frame then return false end
    self.activeClip = clip
    self.activeText, self.words, self.totalWeight = text, words, weight
    self.explicitTimings, self.timelineLength = explicit, timelineLength
    self.duration = tonumber(clip.length) or 0
    self.label:SetFont("Fonts\\FRIZQT__.TTF", FontSize(), "OUTLINE")
    self.started = GetTime() -- actual audio starts again on Vanilla resume/replay
    self.lastPage, self.throttle = nil, 0.08
    self:Repage()
    return true
end

-- Public foundation for future per-word presentation.
-- WordAt takes a normalized progress (same contract as upstream Spoken).
function Transcript:WordAt(progress)
    local words = self.words
    if type(progress) ~= "number" or progress ~= progress or progress < 0 or
        progress >= 1 or not words or table.getn(words) == 0 then return nil end
    local seconds = progress * (self.timelineLength or 0)
    if seconds < words[1].start then return nil end -- supplied initial silence
    local low, high = 1, table.getn(words)
    while low < high do
        local mid = math.floor((low + high) / 2)
        if words[mid].finish <= seconds then low = mid + 1 else high = mid end
    end
    return low
end

function Transcript:GetElapsed()
    if not self.started or not self.activeClip then return 0 end
    return math.max(0, GetTime() - self.started - (tonumber(self.activeClip.delay) or 0))
end

function Transcript:GetProgress()
    if not self.activeClip or not self.timelineLength or self.timelineLength <= 0 then return nil end
    return math.max(0, math.min(1, self:GetElapsed() / self.timelineLength))
end

function Transcript:GetCurrentWord()
    if not self.activeClip or not self.started or
        GetTime() - self.started < (tonumber(self.activeClip.delay) or 0) then return nil end
    local index = self:WordAt(self:GetProgress())
    return index, index and self.words[index] or nil
end

function Transcript:Tick(elapsed)
    if not self.activeClip or not self.started then return end
    self:AdvanceFade(elapsed or 0)
    self.throttle = (self.throttle or 0) + (elapsed or 0)
    if self.throttle < 0.06 then return end
    self.throttle = 0
    local seconds = self:GetElapsed()
    if self.duration > 0 and seconds > self.duration + 0.75 then
        self:StopClip()
        return
    end
    local progress = self:GetProgress()
    local wordIndex = self:WordAt(progress)
    local pageWord = wordIndex
    if not pageWord then
        pageWord = progress and progress >= 1 and table.getn(self.words) or 1
    end
    local number = self.pages and table.getn(self.pages) or 0
    if number == 0 then return end
    local wanted = number
    for i = 1, number do
        if pageWord <= self.pages[i].lastWord then wanted = i; break end
    end
    self.requestedPage = wanted
    if not self.lastPage then
        self:ShowPage(wanted)
    elseif self.lastPage ~= wanted then
        if not self.transition or self.transition.stage == "in" then
            self:FadeOut()
        end
    elseif self.transition and self.transition.stage == "out" then
        -- A seek or timing correction moved back before the transition completed.
        self.transition = nil
        if self.frame then self.frame:SetAlpha(1) end
    end
end

function Transcript:OnAudioChanged()
    if self.activeClip and
        (SoundQueue:IsPaused() or SoundQueue:GetCurrentSound() ~= self.activeClip) then
        self:StopClip()
    end
end

function Transcript:Initialize()
    if self.initialized then return end
    self.initialized = true
    self:CreateDisplay()
    Callbacks:Register("CLIP_STARTED", function(clip) Transcript:StartClip(clip) end)
    Callbacks:Register("CLIP_STOPPED", function(clip) Transcript:StopClip(clip) end)
    Callbacks:Register("AUDIO_CHANGED", function() Transcript:OnAudioChanged() end)
end

function Transcript:SetEnabled(enabled)
    Addon:Profile("Transcript").Enabled = enabled and true or false
    self:RefreshConfig()
end

function Transcript:RefreshConfig()
    if not Enabled() then
        self:StopClip()
    elseif self.activeClip then
        self:Repage()
    else
        local clip = SoundQueue:GetCurrentSound()
        if clip and SoundQueue:IsPlaying(clip) then self:StartClip(clip) end
    end
    if PlayerFrame and PlayerFrame.frame then PlayerFrame:Update() end
end

function Transcript:Reset()
    if self.activeClip then self:StartClip(self.activeClip) end
end
function Transcript:ScrollMode() return "page" end
function Transcript:SetStyle() end
function Transcript:GetScroll()
    return self.lastPage or 1, self.pages and table.getn(self.pages) or 1
end
function Transcript:ScrollTo() end
function Transcript:Describe()
    local current = self.activeClip and self.activeClip.key or "none"
    local page, total = self:GetScroll()
    return "Vanilla captions: " .. (Enabled() and "on" or "off") ..
        ", clip=" .. tostring(current) .. ", page=" .. page .. "/" .. total ..
        ", words=" .. tostring(self.words and table.getn(self.words) or 0) ..
        ", timing=" .. (self.explicitTimings and "supplied" or "estimated")
end
