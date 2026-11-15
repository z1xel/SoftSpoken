-- Audit ONLY: emit existing static quest text into an ephemeral /tmp TSV.
-- Never add or alter SpokenQuestsText / SSCTurtleQuestText.
-- Raw dialogue bytes must never be committed or uploaded from this audit.
local target, dest=assert(arg[1]),assert(arg[2])
dofile("SoftSpoken_Stories/Data/QuestText.lua")
dofile("SoftSpoken_Stories/Data/TurtleQuestText.lua")
local selected={}
for line in io.lines(target) do
    local id=tonumber(line)
    if id then selected[id]=true end
end
local out=assert(io.open(dest,"w"))
local counts={spoken=0,turtle=0}
local function hex(s)
    return (s:gsub(".",function(c)return string.format("%02x",string.byte(c))end))
end
for _,pair in ipairs({
    {"spoken",SpokenQuestsText or {}},
    {"turtle",SSCTurtleQuestText or {}},
}) do
    local label,rows=pair[1],pair[2]
    for qid in pairs(selected) do
        local record=rows[qid]
        if type(record)=="table" then
            for _,stage in ipairs({"accept","progress","complete"}) do
                local value=record[stage]
                if type(value)=="string" and value:find("%S") then
                    out:write(qid,"\t",label,"\t",stage,"\t",hex(value),"\n")
                    counts[label]=counts[label]+1
                end
            end
        end
    end
end
out:close()
print("Static stage extraction (ephemeral): Spoken="..counts.spoken..", Turtle="..counts.turtle)
