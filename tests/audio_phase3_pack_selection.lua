-- Real Stories DataModules.lua index/priority regression (Lua 5.1 / Vanilla).
local function eq(a,b) assert(a==b,tostring(a).." ~= "..tostring(b)) end
GetAddOnMetadata=function(name,key)
    if string.find(key,"Version",1,true) then return "1" end
    if string.find(key,"Priority",1,true) then return "101" end
end
UnitSex=function() return nil end
VoiceOver=setmetatable({
    format=string.format,
    Enums={
        SoundEvent={QuestAccept=1,QuestProgress=2,QuestComplete=3,QuestGreeting=4,Gossip=5,
            IsQuestEvent=function() return true end},
    },
    Language={ResolutionOrder=function() return {"enUS","frFR"} end},
    EasterEggs={Apply=function() return false end},
    Debug={IsMockingMissingVoice=function() return false end},
},{__index=_G})
dofile("SoftSpoken_Stories/DataModules.lua")
local d=VoiceOver.DataModules
local function register(name,priority,lang,filePath,duration)
    d.presentModules[name]={AddonName=name,ModulePriority=priority,Language=lang}
    local module={SoundLengthLookupByFileName={["111-accept"]=duration},
        GetSoundPath=function(self,fileName) return filePath or ("Sounds\\"..fileName..".mp3") end}
    d:Register(name,module)
    return module
end
-- Deliberately opposite TOC priorities and registration order.
local turtle=register("AI_VoiceOverData_Turtle",1000,"enUS",nil,5)
local combined=register("SSS_VOFallback",-100,"enUS",nil,6)
local spoken=register("SpokenQuestsAudioAll",-500,"enUS",nil,7)
eq(d.registeredModulesOrdered[1],spoken)
eq(d.registeredModulesOrdered[2],combined)
eq(d.registeredModulesOrdered[3],turtle)
local function resolve()
    local clip={fileName="111-accept",event=1}
    local success=d:ResolveSoundFile(clip)
    return success,clip
end
local ok,c=resolve()
eq(ok,true);eq(c.module,spoken);eq(c.length,7)
-- Invalid high-priority path must fall through to Combined, not fabricate.
spoken.GetSoundPath=function() return "../escaped.mp3" end
ok,c=resolve();eq(ok,true);eq(c.module,combined)
combined.GetSoundPath=function() error("broken pack path builder") end
ok,c=resolve();eq(ok,true);eq(c.module,turtle)
-- An invalid duration is metadata for the progress estimate; the file
-- remains playable and its duration stays unknown instead of a bad number.
turtle.SoundLengthLookupByFileName["111-accept"]="garbage"
ok,c=resolve();eq(ok,true);eq(c.module,turtle);eq(c.length,nil)
-- If no valid path can be produced, return no clip rather than fake one.
turtle.GetSoundPath=function() return "C:\\absolute.mp3" end
ok,c=resolve();eq(ok,false)
-- Language preference still outranks pack families: one French recording
-- beats an English Spoken pack when French was explicitly selected.
VoiceOver.Language.ResolutionOrder=function() return {"frFR","enUS"} end
local french=register("LanguagePackFrench",-1000,"frFR",nil,4)
spoken.GetSoundPath=function(self,file) return "Sounds\\"..file..".mp3" end
ok,c=resolve();eq(ok,true);eq(c.module,french);eq(c.language,"frFR")
-- Extension/path validation is metadata validation, not physical MP3 existence.
print("audio_phase3_pack_selection.lua: Stories tier order, fallback, language and paths passed")
