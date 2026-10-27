-- Zone-specific semantics for the Compendium's generic button.
SSZAudioButton = SSZAudioButton or {}
local A = SSZAudioButton
local M = SSZLoreWindow
local function Notice(s) DEFAULT_CHAT_FRAME:AddMessage("[Spoken Zones] " .. s) end
function A.Bind(button)
    if not button or button._sszBound then return button end
    button._sszBound=true
    function button:Refresh()
        -- Like upstream: no empty/locked/unvoiced Play button cluttering
        -- the parchment. SetTarget() refreshes whenever navigation changes.
        if not self.mapID or
           (M.IsLocked and M.IsLocked(self.mapID,self.areaKey)) or
           (M.HasVoice and not M.HasVoice(self.mapID,self.areaKey)) then
            self:SetState("play")
            self:Disable()
            self:Hide()
            return
        end
        self:Enable()
        self:Show()
        local bridge=SSZBridge
        local state="play"
        if bridge and bridge.GetAudioState then
            state=bridge:GetAudioState(self.mapID,self.areaKey)
        end
        self:SetState(state)
    end
    function button:SetTarget(mapID,areaKey)
        self.mapID,self.areaKey=mapID,areaKey
        self:Refresh()
    end
    button:SetScript("OnClick",function(self)
        local b=this or self -- Vanilla 1.12 scripts use the global `this`.
        if not b or not b.mapID or
           M.IsLocked(b.mapID,b.areaKey) or not M.HasVoice(b.mapID,b.areaKey) then return end
        local bridge=SSZBridge
        if not bridge or not bridge.PlayEntry then
            Notice("Playback bridge not ready.") return
        end
        local ok,why
        if bridge.ToggleEntry then
            ok,why=bridge:ToggleEntry(b.mapID,b.areaKey)
        else
            ok,why=bridge:PlayEntry(b.mapID,b.areaKey)
        end
        if not ok then Notice("Cannot play: "..tostring(why)) end
        b:Refresh()
    end)
    -- Only an action's semantics, not its art: the original warns that Replay
    -- starts from the beginning on clients without audio seeking.
    button:SetScript("OnEnter",function(self)
        local b=this or self
        if not b then return end
        if b.icon then b.icon:SetAlpha(1) end
        if not GameTooltip then return end
        GameTooltip:SetOwner(b,"ANCHOR_LEFT")
        if b.state=="stop" then GameTooltip:SetText("Stop narration")
        elseif b.state=="replay" then
            GameTooltip:SetText("Replay narration")
            GameTooltip:AddLine("Resumes from the beginning on this client.",1,0.8,0.2,1)
        else GameTooltip:SetText("Play narration") end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave",function(self)
        local b=this or self
        if b and b.icon then b.icon:SetAlpha(0.85) end
        if GameTooltip then GameTooltip:Hide() end
    end)
    -- Multiple pages display the same player state, including playback started
    -- outside the Compendium. Don't attach the state to the visible selection.
    if SSZBridge and SSZBridge.OnAudioChanged then
        SSZBridge:OnAudioChanged(function() button:Refresh() end)
    end
    -- Current SoftSpoken fires AUDIO_CHANGED for every queue transition.
    -- Keep the old low-rate polling fallback only for older API builds.
    if not (Spoken and Spoken.RegisterCallback) then
        local elapsedSinceRefresh=0
        button:SetScript("OnUpdate",function(self,elapsed)
            local b=this or self
            if not b or not b.mapID or not b:IsShown() then return end
            elapsedSinceRefresh=elapsedSinceRefresh+(elapsed or arg1 or 0)
            if elapsedSinceRefresh>=0.5 then
                elapsedSinceRefresh=0
                b:Refresh()
            end
        end)
    end
    button:SetTarget(nil,nil)
    return button
end
