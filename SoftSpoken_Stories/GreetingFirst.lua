setfenv(1, VoiceOver)

-- Game Greeting First (Audio.GreetingFirst, off by default): on Vanilla 1.12 there is no
-- independent Dialog volume channel or reliable NPC-greeting completion event. Give the game's
-- greeting a short opportunity to play before starting automatic Stories/Gossip narration.
-- This is a fixed delay, not detection of the greeting's actual playback duration.
GreetingFirst = {}

local GREETING_DELAY = 1.5
local WINDOWS = { "GossipFrame", "QuestFrame", "DUIQuestFrame", "ImmersionFrame" }

local holdUntil = 0 -- when an NPC greeting's fixed delay ends
local visit           -- the NPC whose windows are open: it greets once, as the first opens
local opened = 0      -- windows opened, to tell a closing visit from gossip turning into a quest

function GreetingFirst:IsOn()
    return Addon.db and Addon.db.profile.Audio.GreetingFirst == true
end

function GreetingFirst:IsWaiting()
    return GetTime() < holdUntil
end

local function Retry()
    -- Sources normally retry every second, but we can ask the shared queue to advance sooner.
    if Player.source and Player.source.Retry then
        Player.source:Retry()
    end
end

--- An NPC's window opened. Hold the first narration of a visit, not every quest/gossip
--- page opened from that visit. No sound handles or modern audio CVars are inspected.
function GreetingFirst:Open()
    opened = opened + 1
    local npc = Utils:GetNPCGUID() or Utils:GetNPCName()
    if visit and visit == npc then
        return
    end
    visit = npc
    -- Objects/items have no voice; if narration is already playing, leave it alone.
    if Utils:IsNPCObjectOrItem() or Spoken:IsPlaying() then
        return
    end
    holdUntil = math.max(holdUntil, GetTime() + GREETING_DELAY)
    Addon:ScheduleTimer(Retry, GREETING_DELAY)
end

--- A window closed. Unless another opens at once (gossip turning into a quest), the visit
--- ends and the NPC may greet again on the next interaction.
function GreetingFirst:Closed()
    if not self:IsOn() then
        visit = nil
        return
    end
    local before = opened
    Addon:ScheduleTimer(function()
        if opened ~= before then
            return
        end
        for _, name in ipairs(WINDOWS) do
            local frame = _G[name]
            if frame and frame.IsVisible and frame:IsVisible() then
                return
            end
        end
        visit = nil
    end, 0.1)
end

function GreetingFirst:Setup()
    if self.ready or not Player.source then
        return
    end
    self.ready = true
    for _, source in ipairs({ Player.source, Player.gossipSource }) do
        source:AddGate(function()
            if GreetingFirst:IsWaiting() then
                return L.QUEUE_HELD_GREETING
            end
        end)
    end
    local frame = CreateFrame("Frame")
    for _, event in ipairs({ "GOSSIP_CLOSED", "QUEST_FINISHED" }) do
        pcall(frame.RegisterEvent, frame, event)
    end
    frame:SetScript("OnEvent", function() GreetingFirst:Closed() end)
end
