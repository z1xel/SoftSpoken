-- Read-only: compare actual Vanilla pfQuest quest metadata with Turtle's
-- replacement table. A Turtle table entry is NOT a modification if identical.
-- Usage: lua5.1 scripts/diff_pfquest_turtle_quests.lua <vanilla.lua> <turtle.lua> <out.csv>
local vanilla,turtle,outfile,vanillalist=assert(arg[1]),assert(arg[2]),assert(arg[3]),assert(arg[4])
pfDB={quests={}}
dofile(vanilla)
assert(type(pfDB.quests.data)=="table","Vanilla pfQuest quest data not loaded")
local base=pfDB.quests.data
local vout=assert(io.open(vanillalist,"w"))
vout:write("quest_id,vanilla_pfquest_present\\n")
local classicIds={}
for id,entry in pairs(base) do
    if type(id)=="number" and id>0 and type(entry)=="table" then
        classicIds[#classicIds+1]=id
    end
end
table.sort(classicIds)
for _,id in ipairs(classicIds) do
    vout:write(id,",1\\n")
end
vout:close()
print("Vanilla pfQuest structured quest IDs:",#classicIds)
dofile(turtle)
local other=pfDB.quests["data-turtle"]
assert(type(other)=="table","Turtle pfQuest quest table not loaded")
local function equal(a,b,depth)
    if type(a)~=type(b) then return false end
    if type(a)~="table" then return a==b end
    assert(depth<14,"Unexpected nested quest data recursion")
    for k,v in pairs(a) do
        if not equal(v,b[k],depth+1) then return false end
    end
    for k,_ in pairs(b) do if a[k]==nil then return false end end
    return true
end
local ids,counts={},{same=0,changed=0,added=0,removed=0}
for id,entry in pairs(other) do
    if type(id)=="number" and id>0 then
        if entry=="_" then
            counts.removed=counts.removed+1
        elseif base[id]==nil then
            counts.added=counts.added+1
            ids[#ids+1]={id,"pfquest_turtle_new_quest_entry"}
        elseif equal(base[id],entry,0) then
            counts.same=counts.same+1
        else
            counts.changed=counts.changed+1
            ids[#ids+1]={id,"pfquest_turtle_changed_metadata"}
        end
    end
end
assert(counts.changed+counts.added>0,"Expected Turtle-specific quest changes")
table.sort(ids,function(a,b)return a[1]<b[1]end)
local out=assert(io.open(outfile,"w"))
out:write("quest_id,evidence\n")
for _,row in ipairs(ids) do
    out:write(row[1],",",row[2],"\n")
end
out:close()
print(string.format("pfQuest true deltas: %d changed, %d new, %d identical, %d removed",
    counts.changed,counts.added,counts.same,counts.removed))
