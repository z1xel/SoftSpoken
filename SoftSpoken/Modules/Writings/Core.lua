-- SoftSpoken Writings for Turtle WoW 1.12 (Lua 5.0).
-- Internal feature module that registers with the shared SoftSpoken player;
-- does not modify Core or Places. Book recognition/playlist code was
-- adapted from rusty-key/spoken-wow (MIT).
SpokenWritings = SpokenWritings or {}
local Writings = SpokenWritings
Writings.version = "v0.9.1-beta"
Writings.name = "SoftSpoken"
function Writings:Print(message)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cff80c0ffSoftSpoken Writings 1.12|r: "..tostring(message))
    end
end
function Writings:InitDB()
    self.db = SpokenEnv.Persistence:ModuleDB("Writings")
    self.character = SpokenEnv.Persistence.character.Writings
    return self.db.profile
end

-- Profile reset does not touch personal discoveries or reading history.
function Writings:ResetOptions()
    self.db:ResetProfile()
    if self.initialized then self:RefreshConfig() end
end

function Writings:RefreshConfig()
    if self.RefreshReadables then self:RefreshReadables() end
    if self.RefreshPlayButton then self:RefreshPlayButton() end
    if self.RefreshOptions then self:RefreshOptions() end
end

function Writings:Get(k)
    if k == "fontSize" then return self.db and self.db.profile.fontSize or 12 end
    return self.db and self.db.profile[k]
end
function Writings:Data() return SSBData end
function Writings:MarkBookFound(id)
    if id and self.character then self.character.found[id]=true end
end
function Writings:IsBookFound(id)
    return id and self.character and self.character.found[id]==true or false
end
function Writings:MarkBookRead(id)
    if id and self.character then self.character.read[id]=true end
end
function Writings:HasReadBook(id)
    return id and self.character and self.character.read[id]==true or false
end
function Writings:ForgetRead()
    local count=0
    if not self.character then return count end
    for _ in pairs(self.character.read) do count=count+1 end
    self.character.read={}
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
        title="SoftSpoken Writings", addon="SoftSpoken", order=3,
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

function Writings:Initialize()
    if self.initializationStarted then return end
    self.initializationStarted = true
    self:InitDB()
    assert(self:SetupSource(), "Writings source registration failed")
    self:SetupEvents()
    self:SetupOptions()
    if self.SetupPlayButton then self:SetupPlayButton() end
    self.initialized = true
end
