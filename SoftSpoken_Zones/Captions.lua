-- Spoken Zones 1.12: independent lightweight narration captions.
-- Vanilla's Spoken player explicitly disables modern Transcript.lua.
-- Show readable approximate passages using duration-weighted text chunks.
-- The player itself and its audio queue are never altered.

SSZCaptions = {}
local Captions = SSZCaptions
local MAX_CHARS = 64
local MAX_WORDS = 12

local function Pages(text)
    local pages, part, characters, words, weight, total = {}, {}, 0, 0, 0, 0
    local function Flush()
        if table.getn(part) == 0 then return end
        local entry = { text = table.concat(part, " "), weight = weight }
        total = total + weight
        entry.finish = total
        table.insert(pages, entry)
        part, characters, words, weight = {}, 0, 0, 0
    end
    if type(text) ~= "string" then return pages, 0 end
    text = string.gsub(text, "\r", "")
    text = string.gsub(text, "%s+", " ")
    for word in (string.gfind or string.gmatch)(text, "%S+") do
        local n = string.len(word)
        if words > 0 and (characters + n + 1 > MAX_CHARS or words >= MAX_WORDS) then
            Flush()
        end
        table.insert(part, word)
        characters = characters + n + (words > 0 and 1 or 0)
        words = words + 1
        weight = weight + 0.90 + (n * 0.065)
        if string.find(word, "[%.%!%?][%'%\"]?$" ) then
            weight = weight + 0.6
        elseif string.find(word, "[,;:]$") then
            weight = weight + 0.25
        end
    end
    Flush()
    return pages, total
end

local function CreateDisplay()
    if Captions.frame then return end
    -- The public player API supplies the actual narrator window. Keeping the
    -- captions parented to it also makes dragging, scale and hide/show automatic.
    local player = Spoken and Spoken.GetPlayerFrame and Spoken:GetPlayerFrame()
    if not player then return end
    local frame = CreateFrame("Frame", nil, player)
    frame:SetWidth(240)
    frame:SetHeight(66)
    frame:SetPoint("TOPLEFT", player, "TOPLEFT", 135, -124)
    frame:SetFrameLevel(player:GetFrameLevel() + 3)
    -- Spoken already paints its own gradient: don't draw a separate tooltip box.
    local label = frame:CreateFontString(nil, "OVERLAY")
    label:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
    label:SetTextColor(1, 0.95, 0.83)
    label:SetJustifyH("LEFT")
    label:SetJustifyV("TOP")
    label:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -1)
    label:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -3, 0)
    frame:Hide()
    Captions.frame, Captions.label = frame, label
    local driver = CreateFrame("Frame", nil, UIParent)
    driver:SetScript("OnUpdate", function(self, elapsed)
        local delta = type(elapsed) == "number" and elapsed or arg1
        if type(delta) == "number" then Captions:Tick(delta) end
    end)
    Captions.driver = driver
end

-- Called by the existing classic Spoken PlayerFrame:LayoutCaptions() anchor.
function Captions:Dock(parent, anchor, point, x, y, width, height)
    if not self.frame then return end
    if parent and self.frame:GetParent() ~= parent then self.frame:SetParent(parent) end
    if parent then self.frame:SetFrameLevel(parent:GetFrameLevel() + 3) end
    self.frame:ClearAllPoints()
    if anchor then self.frame:SetPoint("TOPLEFT", anchor, point, x, y) end
    self.frame:SetWidth(math.max(1, width or 1))
    self.frame:SetHeight(math.max(1, height or 1))
    if height and height > 0 and self.item then
        self.frame:Show()
    else
        self.frame:Hide()
    end
end

function Captions:Stop(item)
    if item and self.item ~= item then return end
    self.item, self.pages, self.started, self.duration, self.lastPage = nil, nil, nil, nil, nil
    if self.frame then self.frame:Hide() end
end

function Captions:Start(item, text, duration)
    local pages, total = Pages(text)
    if table.getn(pages) == 0 then return false end
    CreateDisplay()
    if not self.frame then return false end
    self.item = item
    self.pages = pages
    self.total = total
    self.started = GetTime()
    self.duration = tonumber(duration) or 0
    self.lastPage = nil
    self.throttle = 0.08 -- render first caption immediately
    -- The player reserves the caption height and docks this frame through
    -- its original Transcript:HeightForClip / Transcript:Dock hooks.
    if Spoken and Spoken.RefreshPlayer then Spoken:RefreshPlayer() end
    self:Tick(0)
    return true
end

function Captions:Tick(elapsed)
    if not self.item or not self.started then return end
    self.throttle = (self.throttle or 0) + elapsed
    if self.throttle < 0.08 then return end
    self.throttle = 0
    local since = GetTime() - self.started
    if self.duration > 0 and since > self.duration + 0.75 then
        self:Stop()
        return
    end
    local at
    if self.duration > 0 then
        at = math.max(0, math.min(0.999999, since / self.duration)) * self.total
    else
        at = math.max(0, since / 4) * self.total
    end
    local number = table.getn(self.pages)
    local index = number
    for i = 1, number do
        if at < self.pages[i].finish then index = i; break end
    end
    if self.lastPage ~= index then
        self.lastPage = index
        self.label:SetText(self.pages[index].text)
    end
end

function Captions:HasLore()
    local db = SSZLore
    if type(db) ~= "table" then return false end
    for _ in pairs(db.zones or {}) do return true end
    for _ in pairs(db.subzones or {}) do return true end
    return false
end
