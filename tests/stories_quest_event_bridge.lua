-- Run the real Stories event bridge with minimal Vanilla 1.12 globals.
-- Catch regressions in event-time ID context, queuing, and Read After Close.
local now, current = 100, { id = 101, title = "First Quest", npc = "Quest Giver" }
local clips, scheduled = {}, {}
local stageSource, stageText, lastFallback
local greetingOn, greetingStarts = false, 0
local function eq(got, want, label)
    assert(got == want, (label or "value") .. ": got " .. tostring(got) ..
        ", expected " .. tostring(want))
end
local function total() return table.getn(clips) end
_G.GetTime = function() return now end
_G.GetTitleText = function() return current.title end
_G.GetQuestText = function() return "Offer " .. current.title end
_G.GetProgressText = function() return "Progress " .. current.title end
_G.GetRewardText = function() return "Reward " .. current.title end
_G.GetQuestID = function() return current.id end
_G.UnitName = function(unit) return unit == "npc" and current.npc end
_G.UnitGUID = function(unit) return unit == "npc" and "creature:777" end
_G.StaticPopupDialogs, _G.OKAY = {}, "OK"
_G.format = string.format -- WoW exposes this global alias; stock Lua 5.1 does not.

local function frame()
    local f = { registered = {}, scripts = {} }
    function f:RegisterEvent(event) self.registered[event] = true end
    function f:UnregisterEvent(event) self.registered[event] = nil end
    function f:SetScript(script, fn) self.scripts[script] = fn end
    return f
end
_G.CreateFrame = frame

local ace = {}
function ace:GetAddon() return nil end
function ace:NewAddon()
    return {
        RegisterEvent = function() end,
        ScheduleTimer = function(self, fn, seconds)
            scheduled[table.getn(scheduled) + 1] = { fn, seconds }
        end,
        ScheduleRepeatingTimer = function()
            error("unreachable modern polling watcher installed")
        end,
    }
end
local aceDB = {}
function aceDB:New(_, defaults)
    return { profile = defaults.profile, char = defaults.char,
        RegisterCallback = function() end }
end
_G.LibStub = function(name)
    if name == "AceAddon-3.0" then return ace end
    if name == "AceDB-3.0" then return aceDB end
    error("unexpected LibStub request: " .. tostring(name))
end

local env = {}
env = {
    _G = _G, NotSecret = function(v) return v end,
    Version = { IsAnyLegacy = true, IsLegacyVanilla = true,
        IsBelowLegacyVersion = function() return true end },
    Enums = { SoundEvent = { QuestAccept = 1, QuestProgress = 2, QuestComplete = 3 },
        GossipFrequency = { OncePerNPC = 1, Never = 0 }, GUID = { Item = 4000 } },
    Utils = { GetNPCName = function() return current.npc end,
        GetNPCGUID = function() return nil end,
        IsNPCObjectOrItem = function() return false end },
    Debug = { runtime = {}, Record = function(self, name, msg)
        self.runtime.stage, self.runtime.message = name, msg
    end, Note = function() end },
    Player = { source = {}, Setup = function() end, Origin = function() return "test" end,
        Enqueue = function(self, data, manual)
            clips[total() + 1] = { data = data, manual = manual }
            env.Debug:Record("queued", "queued by test player")
            return true
        end, Remove = function() end },
    DataModules = {
        EnumerateAddons = function() end,
        HasRegisteredModules = function() return true end,
        GetQuestID = function(self, source, title, npc, words)
            lastFallback = { source = source, title = title, npc = npc, words = words }
            return title == "Fallback Quest" and 202 or nil
        end,
        GetQuestLogQuestGiverTypeAndID = function() return nil end },
    Options = { Initialize = function() end },
    GreetingFirst = { Setup = function() end,
        IsOn = function() return greetingOn end,
        Open = function() greetingStarts = greetingStarts + 1 end },
    Followup = { Setup = function() end },
    ReportButton = { Initialize = function() end },
    ContributeButton = { Setup = function() end },
    DialogPlayButton = { Setup = function() end },
}
env.StoriesNarrator = env.Player
VoiceOver = setmetatable(env, { __index = _G })
assert(loadfile("SoftSpoken_Stories/QuestRuntime.lua"))()
local addon = VoiceOver.Addon
function addon:NoteLegacyQuestEvent(source, words)
    stageSource, stageText = source, words
end
addon:OnInitialize()
assert(addon.questEventRecorderFrame and addon.directEventFrame, "event frames missing")
for _, e in ipairs({ "QUEST_DETAIL", "QUEST_PROGRESS", "QUEST_COMPLETE" }) do
    assert(addon.directEventFrame.registered[e], e .. " not directly registered")
    assert(addon.questEventRecorderFrame.registered[e], e .. " not recorded")
end
assert(not addon.autoQuestState and not addon.autoQuestTicker, "watcher state remains")
eq(table.getn(scheduled), 0, "watcher timers")
local function fire(event)
    local recorder, direct = addon.questEventRecorderFrame, addon.directEventFrame
    if recorder.registered[event] then recorder.scripts.OnEvent(recorder, event) end
    if direct.registered[event] then direct.scripts.OnEvent(direct, event) end
end

fire("QUEST_DETAIL")
eq(stageSource, "accept", "offer ID context")
eq(stageText, "Offer First Quest", "offer text context")
eq(total(), 1, "offer narration")
eq(clips[1].data.questID, 101, "offer quest ID")
eq(clips[1].data.portraitGUID, "creature:777", "live portrait")
fire("QUEST_DETAIL")
eq(total(), 1, "duplicate suppression")

now = now + 1
fire("QUEST_PROGRESS")
eq(stageSource, "progress", "progress context")
eq(clips[2].data.event, 2, "progress sound")
eq(clips[2].data.text, "Progress First Quest", "progress text")

now = now + 1
fire("QUEST_COMPLETE")
eq(stageSource, "complete", "completion context")
eq(clips[3].data.event, 3, "completion sound")
eq(clips[3].data.text, "Reward First Quest", "completion text")

now = now + 1
current = { id = 0, title = "Fallback Quest", npc = "Quest Giver" }
fire("QUEST_DETAIL")
eq(clips[4].data.questID, 202, "dialog fallback ID")
eq(lastFallback.source, "accept", "fallback stage")
eq(lastFallback.words, "Offer Fallback Quest", "fallback text")

-- The last automatic stage wins while deferred; closing queues it once.
now = now + 1
current = { id = 303, title = "Deferred Quest", npc = "Quest Giver" }
addon.db.profile.Audio.ReadAfterClose = true
fire("QUEST_DETAIL")
eq(total(), 4, "offer held")
now = now + 1
fire("QUEST_COMPLETE")
eq(total(), 4, "completion held")
fire("QUEST_FINISHED")
eq(total(), 5, "close enqueues last stage")
eq(clips[5].data.event, 3, "last stage wins")
eq(clips[5].data.questID, 303, "deferred ID")
now = now + 1
addon:InvokeQuestHandler("QUEST_DETAIL", "manual", true)
eq(total(), 6, "manual bypasses close hold")
eq(clips[6].manual, true, "manual flag")

addon.db.profile.Audio.ReadAfterClose = false
addon.db.profile.Audio.Autoplay = false
now = now + 1
current = { id = 404, title = "Manual Quest", npc = "Quest Giver" }
fire("QUEST_DETAIL")
eq(total(), 6, "autoplay off")
addon:InvokeQuestHandler("QUEST_DETAIL", "manual", true)
eq(total(), 7, "manual works with autoplay off")

addon.db.profile.Audio.Autoplay = true
greetingOn = true
now = now + 1
current = { id = 505, title = "Greeting Quest", npc = "Quest Giver" }
fire("QUEST_DETAIL")
assert(greetingStarts > 0, "greeting wait must still arm")

local fp = assert(io.open("SoftSpoken_Stories/QuestRuntime.lua", "r"))
local code = fp:read("*a")
fp:close()
for _, dead in ipairs({ "PollAutomaticQuest", "AUTO_POLL_INTERVAL",
    "questSnapshot", "autoQuestState", "autoQuestTicker" }) do
    assert(not string.find(code, dead, 1, true), "obsolete watcher reference: " .. dead)
end
assert(string.find(code, "pcall(QuestIDFor, event)", 1, true),
    "missing event-time Vanilla quest ID context")
print("PASS: Vanilla quest events, IDs, dedup, portrait, defer, manual and greeting without watcher")
