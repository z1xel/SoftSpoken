-- SoftSpoken Writings for Turtle WoW 1.12 (Lua 5.0).
-- Separate feature module that registers with required SoftSpoken Core;
-- does not modify Core or Places. Book recognition/playlist code was
-- adapted from rusty-key/spoken-wow (MIT).
SpokenWritings = SpokenWritings or {}
local Writings = SpokenWritings
Writings.version = "v0.9.2-beta"
Writings.name = "SoftSpoken_Writings"
local defaults = {
    autoplay=true, readWholeBook=true, bookAsOneLine=true, readOnce=false,
    stopOnClose=false, closeWhenRead=false,
    voiceLanguage="auto", fallbackLanguage="enUS",
    compendiumFoundOnly=true, compendiumVoicedOnly=false,
    compendiumByZone=true, unlockUnfound=false
}
function Writings:Print(message)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cff80c0ffSoftSpoken Writings 1.12|r: "..tostring(message))
    end
end
function Writings:InitDB()
    SSBSettings = SSBSettings or {}
    for k,v in pairs(defaults) do
        if SSBSettings[k]==nil then SSBSettings[k]=v end
    end
    SSBCharacter = SSBCharacter or {}
    SSBCharacter.read = SSBCharacter.read or {}
    if not SSBCharacter.found then
        SSBCharacter.found = {}
        for id in pairs(SSBCharacter.read) do
            SSBCharacter.found[id]=true
        end
    end
    return SSBSettings
end
-- Upstream reset semantics: settings only. Character discovery/read history survives.
function Writings:ResetOptions()
    if not SSBSettings then self:InitDB() end
    for key,value in pairs(defaults) do SSBSettings[key]=value end
    if self.RefreshReadables then self:RefreshReadables() end
    if self.RefreshPlayButton then self:RefreshPlayButton() end
    if self.RefreshOptions then self:RefreshOptions() end
end
function Writings:Get(k)
    if k=="fontSize" then
        return SSBSettings and SSBSettings.fontSize or 12
    end
    return SSBSettings and SSBSettings[k]
end
function Writings:Data() return SSBData end
function Writings:MarkBookFound(id)
    if not id then return end
    if not SSBCharacter then self:InitDB() end
    SSBCharacter.found[id]=true
end
function Writings:IsBookFound(id)
    return id and SSBCharacter and SSBCharacter.found[id]==true or false
end
function Writings:MarkBookRead(id)
    if not id then return end
    if not SSBCharacter then self:InitDB() end
    SSBCharacter.read[id]=true
end
function Writings:HasReadBook(id)
    return id and SSBCharacter and SSBCharacter.read[id]==true or false
end
function Writings:ForgetRead()
    local count=0
    if not SSBCharacter then return count end
    for _ in pairs(SSBCharacter.read) do count=count+1 end
    SSBCharacter.read={}
    return count
end
function Writings:PlayerAvailable()
    return Spoken and Spoken.IsCompatible and Spoken:IsCompatible(1) or false
end
function Writings:IsPartOn()
    return not (Spoken and Spoken.IsPartOn) or Spoken:IsPartOn("books")
end
function Writings:SetupSource()
    if self.source then return self.source end
    if not self:PlayerAvailable() then return nil end
    self.source=Spoken:RegisterSource("books", {
        title="SoftSpoken Writings", addon="SoftSpoken_Writings", order=3,
        interClipGap=0.35,
        packs=function()
            local names={}
            for _,p in ipairs(Writings:GetAudioPacks()) do
                table.insert(names,p.title or p.addon)
            end
            return names
        end
    })
    if Spoken.RegisterBullet then
        Spoken:RegisterBullet("book", [[Interface\AddOns\SoftSpoken\Textures\SoundQueueBulletInspect]],16)
    end
    if Spoken.RegisterCallback then
        Spoken:RegisterCallback("PART_SWITCHED",function(key)
            if key=="books" and Writings.RefreshPlayButton then Writings:RefreshPlayButton() end
        end)
        Spoken:RegisterCallback("AUDIO_CHANGED",function()
            if Writings.RefreshPlayButton then Writings:RefreshPlayButton() end
            if Writings.RefreshReadablesPlayback then Writings:RefreshReadablesPlayback() end
        end)
    end
    return self.source
end
