-- Run from the repository root: lua5.1 tests/classicapi_portrait_compatibility.lua
-- Run the real SoftSpoken portrait renderer against mock Vanilla/ClassicAPI
-- frames, rather than testing a rewritten copy of its branching logic.

local function expect(actual, wanted, label)
    assert(actual == wanted, (label or "value") .. ": expected " ..
        tostring(wanted) .. ", got " .. tostring(actual))
end

local function Scenario(version)
    local frames, requests, current, refreshes = {}, {}, nil, 0
    local known = {}
    local function Frame(kind)
        local obj = {kind=kind, calls={}, scripts={}, shown=false}
        function obj:Call(name, value)
            table.insert(self.calls, {name=name,value=value})
        end
        function obj:Hide() self.shown=false;self:Call("Hide") end
        function obj:Show()
            self.shown=true
            self:Call("Show",self.display)
        end
        function obj:IsShown() return self.shown end
        function obj:SetAllPoints() self:Call("SetAllPoints") end
        function obj:ClearModel() self.display=nil;self.modelPath=nil;self:Call("ClearModel") end
        function obj:SetScript(name,handler) self.scripts[name]=handler end
        function obj:RegisterEvent(name) self.event=name end
        function obj:SetCamera(value) self:Call("SetCamera",value) end
        function obj:SetLight(...) self:Call("SetLight") end
        function obj:GetModel()
            if kind=="PlayerModel" and version=="new" then return nil end
            return self.modelPath
        end
        if (kind=="PlayerModel" and version=="new") or
           (kind=="Model" and version=="old") then
            function obj:SetDisplayInfo(id)
                self.display=id
                self.modelPath="creature/"..tostring(id)
                self:Call("SetDisplayInfo",id)
            end
        end
        if kind=="PlayerModel" and version=="new" then
            function obj:SetPortraitZoom(value) self:Call("SetPortraitZoom",value) end
            function obj:RefreshCamera() self:Call("RefreshCamera") end
        end
        if kind=="Frame" then obj:Show() end
        table.insert(frames,obj)
        return obj
    end
    local function Create(kind)
        return Frame(kind)
    end
    local speaker = {
        GetCurrent=function() return current end,
        RefreshPlayer=function() refreshes=refreshes+1 end,
    }
    local env = setmetatable({
        Renderers={}, Version={
            IsLegacyVanilla=true,IsRetailVanilla=false,
            IsRetailOrAboveLegacyVersion=function() return false end,
        },
        Spoken=speaker, UIParent={}, CreateFrame=Create,
        SoundQueue={IsPlaying=function() return true end,IsPaused=function() return false end},
        C_CreatureInfo={
            GetCreatureInfoByID=function(id)
                return known[id] and {displayID=known[id]} or nil
            end,
            RequestLoadCreatureByID=function(id)
                table.insert(requests,id)
                return true
            end,
        },
    }, {__index=_G})
    SpokenEnv = env
    SoftSpokenClassicPortraits = nil
    dofile("SoftSpoken/UI/Portrait.lua")

    local portrait = {shown=true}
    function portrait:IsShown() return self.shown end
    function portrait:CreateTexture()
        local t={shown=false}
        function t:SetAllPoints() end
        function t:Show() self.shown=true end
        function t:Hide() self.shown=false end
        function t:SetTexture(v) self.texture=v end
        function t:SetTexCoord() end
        return t
    end
    local function Clip(id, displayID)
        return {present={portrait={
            kind="creature",creatureID=id,displayID=displayID,
            fallback={kind="texture",texture="fallback.tga"},
        }}}
    end
    local function Configure(clip)
        current=clip
        env.Portrait:Configure(portrait,clip)
    end
    local function GetModel()
        return portrait.creatureModel
    end
    local function FindCall(model,name)
        for i,call in ipairs(model.calls) do
            if call.name==name then return i,call.value end
        end
    end

    if version=="new" or version=="old" then
        Configure(Clip(101,330))
        local model=GetModel()
        expect(model.kind,version=="new" and "PlayerModel" or "Model",version.." backend")
        expect(model.display,330,version.." display ID")
        expect(portrait.active,"creature",version.." active renderer")
        local assigned=FindCall(model,"SetDisplayInfo")
        local shown=FindCall(model,"Show")
        assert(assigned and shown and assigned<shown,"assign a display before showing it")
        if version=="new" then
            expect(FindCall(model,"SetPortraitZoom")~=nil,true,"native portrait zoom")
            expect(FindCall(model,"SetCamera"),nil,"no manual camera with PlayerModel")
            expect(FindCall(model,"SetLight"),nil,"no manual light with PlayerModel")
            expect(model:GetModel(),nil,"new model can load asynchronously")
            expect(model.shown,true,"new renderer stays visible while loading")
        else
            expect(FindCall(model,"SetCamera")~=nil,true,"legacy camera")
            expect(FindCall(model,"SetLight")~=nil,true,"legacy lighting")
        end

        -- Switch speaker on the same renderer. No previous speaker can remain
        -- on screen while the new display is being installed.
        model.calls={}
        Configure(Clip(202,440))
        expect(model.display,440,"speaker switch display")
        expect(portrait.active,"creature","speaker switch renderer")
        assigned=FindCall(model,"SetDisplayInfo")
        shown=FindCall(model,"Show")
        local hidden=FindCall(model,"Hide")
        assert(hidden and assigned and shown and hidden<assigned and assigned<shown,
            "hide stale model, assign new display, then show")

        -- A missing display must fall back to texture and release the model.
        Configure(Clip(303))
        expect(portrait.active,"texture","uncached creature fallback")
        expect(model.shown,false,"hide model while waiting for cache")
        expect(model._spokenDisplayID,nil,"forget stale display ID")
        expect(requests[1],303,"request uncached creature")

        -- The same clip becomes renderable when ClassicAPI's cache updates.
        known[303]=555
        Configure(Clip(303))
        expect(portrait.active,"creature","loaded creature becomes visible")
        expect(model.display,555,"loaded creature appearance")
        SoftSpokenClassicPortraits = false
        Configure(Clip(303,555))
        expect(portrait.active,"texture","disabled optional API uses fallback")
        SoftSpokenClassicPortraits = nil
    else
        Configure(Clip(101,330))
        expect(portrait.active,"texture","no model API texture fallback")
        expect(portrait.creatureModel,nil,"no unsupported model selected")
    end

    -- Simulate two asynchronous responses before one OnUpdate. Both IDs must
    -- be retained, not overwritten by the last event. Only the current NPC
    -- should cause a player repaint; the queue itself is never advanced.
    if version~="none" then
        Configure(Clip(701))
        Configure(Clip(702))
        local eventFrame
        for _,f in ipairs(frames) do
            if f.kind=="Frame" and f.event=="CREATURE_DATA_LOAD_RESULT" then
                eventFrame=f
            end
        end
        assert(eventFrame,"registered ClassicAPI cache event")
        eventFrame.scripts.OnEvent(eventFrame,"CREATURE_DATA_LOAD_RESULT",701,true)
        eventFrame.scripts.OnEvent(eventFrame,"CREATURE_DATA_LOAD_RESULT",702,true)
        current=Clip(701)
        eventFrame.scripts.OnUpdate(eventFrame,0)
        expect(refreshes,1,"both responses retained until refresh")
        expect(eventFrame.scripts.OnUpdate,nil,"remove completed update handler")
        -- If the current clip is unrelated, responses must not refresh it.
        eventFrame.scripts.OnEvent(eventFrame,"CREATURE_DATA_LOAD_RESULT",702,true)
        current=Clip(900)
        eventFrame.scripts.OnUpdate(eventFrame,0)
        expect(refreshes,1,"do not refresh wrong speaker")
    end
    return true
end

Scenario("old")
Scenario("new")
Scenario("none")
print("PASS: legacy and current ClassicAPI portrait backends, fallback and cache events")
