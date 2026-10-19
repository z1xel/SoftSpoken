-- Small 1.12-compatible button on the vanilla book frame.
local B=SSB
function B:RefreshPlayButton()
    local b=self.playButton
    if not b then return end
    if not self:IsPartOn() then b:Hide(); return end
    local id=self:PageOnScreen()
    if not id or not self:HasAudio(id) then b:Hide(); return end
    b:SetText(self:IsNarrating(self:PlaceOf(id)) and (self.L.STOP or "Stop") or (self.L.PLAY or "Play"))
    b:Show()
end
function B:SetupPlayButton()
    if self.playButton then return self.playButton end
    if not ItemTextFrame then return nil end
    local b=CreateFrame("Button",nil,ItemTextFrame,"UIPanelButtonTemplate")
    b:SetWidth(64); b:SetHeight(22); b:SetText(self.L.PLAY or "Play")
    -- Match upstream PlayButton.lua: a TEXT button in the lower parchment corner.
    -- Fit the widest label, but never assume WoW's localized font API is available.
    if b.GetTextWidth then
        local widest=0
        for _,label in ipairs({self.L.PLAY or "Play", self.L.STOP or "Stop"}) do
            b:SetText(label)
            widest=math.max(widest,b:GetTextWidth() or 0)
        end
        b:SetWidth(math.max(58,widest+24))
        b:SetText(self.L.PLAY or "Play")
    end
    if ItemTextScrollFrame then
        b:SetPoint("BOTTOMRIGHT",ItemTextScrollFrame,"BOTTOMRIGHT",-6,6)
        if b.SetFrameLevel and ItemTextScrollFrame.GetFrameLevel then
            b:SetFrameLevel(ItemTextScrollFrame:GetFrameLevel()+2)
        end
    else b:SetPoint("BOTTOMRIGHT",ItemTextFrame,"TOPRIGHT",-39,-412) end
    b:SetScript("OnClick",function()
        local id=B:PageOnScreen()
        if not id then return end
        local book=B:PlaceOf(id)
        if B:IsNarrating(book) then B:StopReading(book)
        else B:ReadCurrent() end
        B:RefreshPlayButton()
    end)
    b:SetScript("OnEnter",function()
        if not GameTooltip then return end
        GameTooltip:SetOwner(b,"ANCHOR_RIGHT")
        GameTooltip:SetText((b:GetText()==(B.L.STOP or "Stop")) and (B.L.STOP_TIP or "Stop reading this book") or (B.L.PLAY_TIP or "Read this book aloud"))
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
    -- The shared AUDIO_CHANGED event now updates the button on queue changes.
    -- No per-frame polling is needed.
    b:Hide()
    self.playButton=b
    return b
end
