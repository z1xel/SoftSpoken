-- Compendium right-pane visual pilot (Turtle WoW 1.12).
-- Borrow the exact parchment/backdrop/Blizzard inset geometry from the
-- approved SSZ_Portrait_Template_Test.  The real LorePage/TextView remain the
-- owners of entry data, wrapped text, pictures, buttons, audio and scrolling.
SSCPrototypePageSkin = SSCPrototypePageSkin or {}
local Skin = SSCPrototypePageSkin
local INTERIOR = SSCPrototypeInteriorSkin
local MARBLE = "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Prototype\\UI-Background-Marble"
-- This file is already included with SoftSpoken and is byte-identical to the
-- texture imported by the prototype, so the integrated reader can be portable.
local PARCHMENT = "Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\Art\\QuestDetailsBackgrounds"

function Skin.Apply(inset,holder,page)
    if not inset or not holder or not page or not page.frame then return end
    if inset.sszPrototypePageVisual then return inset.sszPrototypePageVisual end

    -- The inset includes both the parchment and the separate 31-unit housing.
    -- This reproduces the prototype's page geometry: parchment runs to 29
    -- units before the inset's right edge, while the scrollbar housing is
    -- anchored 2 units in from that edge and overlaps the parchment by 4.
    local visual=CreateFrame("Frame",nil,inset)
    visual:SetPoint("TOPLEFT",inset,"TOPLEFT",0,0)
    visual:SetPoint("BOTTOMRIGHT",inset,"BOTTOMRIGHT",-29,0)
    visual:SetBackdrop({bgFile=MARBLE,tile=true,tileSize=256,
        insets={left=1,right=1,top=1,bottom=1}})
    inset.sszPrototypePageVisual=visual

    -- Reuse the actual existing production page object and its scroll state.
    -- Only its holder is relocated; no new LorePage or TextView is constructed.
    holder:ClearAllPoints()
    holder:SetPoint("TOPLEFT",visual,"TOPLEFT",3,-3)
    holder:SetPoint("BOTTOMRIGHT",visual,"BOTTOMRIGHT",-3,3)

    -- Both Places and Books intentionally use the SAME parchment the approved
    -- visual test uses.  Do not modify the page's Show(), narration or reflow.
    if page.bg then
        page.bg:SetTexture(PARCHMENT)
        page.bg:SetTexCoord(0,0.560547,0,0.90625)
        page.bg:SetVertexColor(1,1,1,1)
        page.bgFile=PARCHMENT
    end
    -- The prototype has no spellbook top flourish or empty-page watermark.
    -- Alpha zero survives a later Show(entry) which may call :Show() on these.
    if page.backplate then page.backplate:SetAlpha(0) end
    if page.mark then page.mark:SetAlpha(0) end

    -- The parchment is painted by page.frame, so the metal inset must be a
    -- separate foreground layer like the approved prototype's `rim` frame.
    local rim=CreateFrame("Frame",nil,visual)
    rim:SetAllPoints(visual)
    rim:SetFrameLevel(page.frame:GetFrameLevel()+3)
    rim:EnableMouse(false)
    if INTERIOR and INTERIOR.DrawInsetBorder then
        INTERIOR.DrawInsetBorder(rim)
    end
    inset.sszPrototypePageRim=rim

    if page.Resize then page:Resize(false) end
    return visual
end
