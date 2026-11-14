-- Run from repository root: lua5.1 tests/questlog_deferred_layout_compatibility.lua
-- Exercise the real row-layout code without requiring pfQuest/Questie by name.
local function eq(actual, expected, label)
    assert(actual == expected, (label or "value") .. ": expected " .. tostring(expected) ..
        ", got " .. tostring(actual))
end

string.trim = string.trim or function(s)
    return (string.gsub(string.gsub(s, "^%s+", ""), "%s+$", ""))
end

local title = "The Missing Diplomat"
local shown = true
local frames = {}
local parent = {}
local buttonParent = {} -- unavailable-audio buttons can use a different parent
local text = { value = "  " .. title }
function text:GetText() return self.value end
function text:SetText(v) self.value = v end
function text:GetStringWidth() return string.len(self.value) * 12 end

local dummy = { value = "" }
function dummy:SetText(v) self.value = v end

local button = { offset = nil }
function button:ClearAllPoints() self.offset = nil end
function button:SetPoint(_, _, _, offset) self.offset = offset end
function button:IsShown() return shown end
function button:GetParent() return buttonParent end

local check = {}
function check:SetPoint(_, _, _, offset) self.offset = offset end

local row = {}
function row:GetParent() return parent end

QuestLogFrame = { IsShown = function() return shown end }
QuestLogDummyText = dummy
QUESTS_DISPLAYED = 1
GetNumQuestLogEntries = function() return 1 end
GetQuestLogTitle = function() return title, 35, nil, false, nil, nil, nil, 101 end
RunNextFrame = function(callback) table.insert(frames, callback) end

VoiceOver = setmetatable({
    AddonFolder = "SoftSpoken_Stories",
    format = string.format,
    Addon = { IsPartOn = function() return true end },
    Utils = {
        GetQuestLogScrollOffset = function() return 0 end,
        GetQuestLogTitleFrame = function() return row end,
        GetQuestLogTitleNormalText = function() return text end,
        GetQuestLogTitleCheck = function() return check end,
    },
}, { __index = _G })

dofile("SoftSpoken_Stories/QuestOverlayUI.lua")
local overlay = VoiceOver.QuestOverlayUI
overlay.questPlayButtons[101] = button

-- Vanilla and SoftSpoken padding remain stable across redraws.
overlay:UpdateQuestTitle(row, button, text, check, title)
eq(button.offset, 4, "vanilla position")
local padded = text.value
eq(string.trim(padded), title, "vanilla content preserved")
overlay:UpdateQuestTitle(row, button, text, check, title)
eq(text.value, padded, "padding does not accumulate")

-- A later addon update should remain untouched and move the button to the gutter.
text:SetText("[35] " .. title)
overlay:RecheckVisibleRowLayouts()
eq(text.value, "[35] " .. title, "Questie-style title untouched")
eq(button.offset, -16, "Questie-style gutter position")
eq(check.offset, text:GetStringWidth(), "checkbox follows displayed text")

text:SetText(" [35] " .. title)
overlay:RecheckVisibleRowLayouts()
eq(text.value, " [35] " .. title, "pfQuest-style title untouched")
eq(button.offset, -16, "pfQuest-style gutter position")

text:SetText("Localized replacement")
overlay:RecheckVisibleRowLayouts()
eq(text.value, "Localized replacement", "unknown replacement untouched")
eq(button.offset, -16, "unknown replacement conservative position")

-- Restore original vanilla behavior if a modifier stops adding a prefix.
text:SetText("  " .. title)
overlay:RecheckVisibleRowLayouts()
eq(text.value, padded, "vanilla padding restored")
eq(button.offset, 4, "vanilla position restored")

-- One scheduled pass per burst; a queued pass sees the later modification.
overlay:ScheduleLayoutRecheck()
overlay:ScheduleLayoutRecheck()
eq(#frames, 1, "coalesced one-shot check")
text:SetText("[35] " .. title)
frames[1]()
eq(button.offset, -16, "deferred check sees later title")
eq(text.value, "[35] " .. title, "deferred check preserves later title")
overlay:ScheduleLayoutRecheck()
eq(#frames, 2, "subsequent updates can schedule again")

-- Closing the log before callback should not change hidden row layout.
shown = false
local oldOffset = button.offset
frames[2]()
eq(button.offset, oldOffset, "closed log untouched")

local voiceover = assert(io.open("SoftSpoken_Stories/VoiceOver.lua", "r")):read("*a")
assert(string.find(voiceover, "QuestOverlayUI:ScheduleLayoutRecheck()", 1, true),
    "QuestLog_Update must schedule the deferred check")
print("PASS: vanilla padding, external title preservation and deferred row layout")
