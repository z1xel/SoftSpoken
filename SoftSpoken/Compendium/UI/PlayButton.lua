-- Shared Compendium parchment action button. Module supplies behavior through SetTarget/Refresh.
-- 1.12-compatible 24px round buttons, matching the original Zones button artwork.
SSCPlayButton = SSCPlayButton or {}
local A = SSCPlayButton
local ROOT="Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Controls\\"
function A.Create(parent)
    local button=CreateFrame("Button",nil,parent)
    button:SetWidth(24);button:SetHeight(24)
    button:SetPoint("TOPRIGHT",parent,"TOPRIGHT",-22,-23)
    local icon=button:CreateTexture(nil,"ARTWORK")
    icon:SetAllPoints(button);icon:SetTexture(ROOT.."play");icon:SetAlpha(0.85)
    button.icon=icon
    local highlight=button:CreateTexture(nil,"OVERLAY")
    highlight:SetAllPoints(button);highlight:SetTexture(ROOT.."play")
    highlight:SetBlendMode("ADD");highlight:SetAlpha(0.15)
    button:SetHighlightTexture(highlight);button.highlightArt=highlight
    function button:SetState(state)
        if state~="stop" and state~="replay" then state="play" end
        self.state=state
        self.playing=(state=="stop")
        self.icon:SetTexture(ROOT..state)
        self.highlightArt:SetTexture(ROOT..state)
    end
    function button:SetTarget() self:SetState("play");self:Disable();self:Hide() end
    function button:Refresh() end
    button:SetScript("OnEnter",function(self)
        local b=this or self
        if not b then return end
        b.icon:SetAlpha(1)
        if GameTooltip then
            GameTooltip:SetOwner(b,"ANCHOR_LEFT")
            if b.state=="stop" then GameTooltip:SetText("Stop narration")
            elseif b.state=="replay" then
                GameTooltip:SetText("Replay narration")
                GameTooltip:AddLine("Resumes from the beginning on this client.",1,0.8,0.2,1)
            else GameTooltip:SetText("Play narration") end
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave",function(self)
        local b=this or self
        if b then b.icon:SetAlpha(0.85) end
        if GameTooltip then GameTooltip:Hide() end
    end)
    button:SetTarget()
    return button
end
