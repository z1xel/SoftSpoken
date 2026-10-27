-- SoftSpoken Quest Log: native Blizzard Plus/Minus-family play and stop glyphs.
-- Loaded after QuestOverlayUI.lua. Restrict all changes to the small quest-row
-- icons; details/portrait/other player controls retain their own artwork.
-- WoW 1.12 / Lua 5.0 compatible.
setfenv(1, VoiceOver)

local originalMakePlayButton = QuestOverlayUI.MakePlayButton
local originalSetPlayButtonState = QuestOverlayUI.SetPlayButtonState
local ROOT = format([[Interface\AddOns\%s\Textures\]], AddonFolder)
local PLAY = ROOT .. "QuestLogPlayButtonNative"
local PLAY_DOWN = ROOT .. "QuestLogPlayButtonNativeDown"
local STOP = ROOT .. "QuestLogStopButtonNative"
local STOP_DOWN = ROOT .. "QuestLogStopButtonNativeDown"

function QuestOverlayUI:MakePlayButton(parent)
    local button = originalMakePlayButton(self, parent)
    -- The quest-details portrait button supplies a parent and draws itself.
    -- Only the standard quest-log row buttons (parent == nil) are reskinned.
    if parent then return button end

    button.softSpokenNativeRowPlay = true
    button:SetWidth(16)
    button:SetHeight(16)
    button:SetHitRectInsets(0, 0, 0, 0)
    button:SetNormalTexture(PLAY)
    button:SetPushedTexture(PLAY_DOWN)
    button:SetDisabledTexture(PLAY)
    local disabled = button:GetDisabledTexture()
    if disabled then
        disabled:SetDesaturated(true)
        disabled:SetAlpha(0.33)
    end
    button:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
    return button
end

function QuestOverlayUI:SetPlayButtonState(button)
    if not button or not button.softSpokenNativeRowPlay or button.setPlayState then
        return originalSetPlayButtonState(self, button)
    end
    local playing = button.soundData and Player:Contains(button.soundData) or false
    button:SetNormalTexture(playing and STOP or PLAY)
    button:SetPushedTexture(playing and STOP_DOWN or PLAY_DOWN)
end
