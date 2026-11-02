-- Minimal WoW 1.12 UI doubles for the upstream-style progress hairline.
-- Run: lua5.1 tests/audio_progress_ui.lua
local style, visible = "classic", true
local config = {Frame={HidePortrait=false},Transcript={SubtitleProgress=true}}
local current = {key="a", estimate=0.35, speaking=true}
local function eq(a,b) assert(a==b, tostring(a).." ~= "..tostring(b)) end

local function Texture()
    local t={shown=true, width=200, anchors={}}
    function t:SetTexture(...) self.texture={...} end
    function t:SetHeight(n) self.height=n end
    function t:SetWidth(n) self.width=n end
    function t:GetWidth() return self.width end
    function t:SetSize(w,h) self.width,self.height=w,h end
    function t:SetAlpha(n) self.alpha=n end
    function t:SetBlendMode(v) self.blend=v end
    function t:SetPoint(...) table.insert(self.anchors,{...}) end
    function t:ClearAllPoints() self.anchors={} end
    function t:SetShown(v) self.shown=v end
    function t:Show() self.shown=true end
    function t:Hide() self.shown=false end
    return t
end
local frame={textures={}, scripts={}}
function frame:CreateTexture()
    local t=Texture()
    table.insert(self.textures,t)
    return t
end
function frame:SetScript(name,fn) self.scripts[name]=fn end
function frame:IsShown() return visible end

local function Font()
    return setmetatable({}, {__index=function() return function() end end})
end
SpokenEnv=setmetatable({
    Addon={
        Profile=function(self,name) return config[name] end,
        DisplayStyle=function() return style end
    },
    SoundQueue={
        ProgressShare=function(self,clip) return clip.estimate end,
        IsPlaying=function(self,clip) return clip.speaking end
    },
    Version={IsLegacyVanilla=true},
    CreateFont=function() return Font() end,
    GameFontNormal={GetFont=function() return "Fonts\\FRIZQT__.TTF" end}
},{__index=_G})

dofile("SoftSpoken/UI/PlayerFrame.lua")
local p=SpokenEnv.PlayerFrame
p.frame=frame
p.Current=function() return current end
p:InitProgress()

local bar=p.progress
eq(#frame.textures,3)
eq(type(frame.scripts.OnUpdate),"function")
eq(bar.track.height,2)
eq(bar.fill.height,2)
eq(bar.track.anchors[1][4],135) -- portrait + 15
eq(bar.fill.texture[1],1) -- gold-coloured fill, not modern atlases

p:UpdateProgress()
eq(bar.track.shown,true)
eq(bar.fill.shown,true)
eq(bar.fill.width,70) -- mocked track width 200 × 0.35
eq(bar.spark.shown,true)
eq(bar.spark.texture[1],[[Interface\CastingBar\UI-CastingBar-Spark]])

current.estimate=0.985
p.frame.scripts.OnUpdate()
eq(bar.fill.width,197)
eq(bar.spark.shown,true)

-- Real engine completion means full fill, and the spark disappears.
current.estimate=1
current.speaking=false
p:UpdateProgress()
eq(bar.fill.width,200)
eq(bar.spark.shown,false)

-- An unknown duration yields only the track, never a made-up percentage.
current.estimate=nil
p:UpdateProgress()
eq(bar.track.shown,true)
eq(bar.fill.shown,false)
eq(bar.spark.shown,false)

-- Toggle off and Voice Only both suppress all progress artwork.
current.estimate=0.4
config.Transcript.SubtitleProgress=false
p:UpdateProgress()
eq(bar.track.shown,false)
eq(bar.fill.shown,false)
config.Transcript.SubtitleProgress=true
style="none"
p:UpdateProgress()
eq(bar.track.shown,false)
style="classic"
visible=false
p:UpdateProgress()
eq(bar.track.shown,false)

-- The bar follows the playable area when the portrait is hidden.
visible=true
config.Frame.HidePortrait=true
p:LayoutProgress()
eq(bar.track.anchors[1][4],20)
p:UpdateProgress()
eq(bar.track.shown,true)
eq(bar.fill.width,80)

-- The subtitle engine must never hide text merely because metadata expired.
local file=assert(io.open("SoftSpoken/Transcript.lua", "r"))
local transcript=file:read("*a")
file:close()
assert(not transcript:find("seconds > self.duration"))
assert(transcript:find('Callbacks:Register%("CLIP_STOPPED"'))

print("audio_progress_ui.lua: Vanilla progress-line and Show Progress Bar assertions passed")
