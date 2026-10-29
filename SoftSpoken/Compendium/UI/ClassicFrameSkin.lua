-- SoftSpoken 1.12 Compendium window skin.
-- Built around the same hierarchy as upstream Spoken's Compendium:
-- one resizable root window; background on the root; content panels are
-- children; portrait/title/close and narrow metal decoration live above.
-- The silver metal is Blizzard artwork from UIFrameMetal and the associated
-- 128px tile sheets.  Corners have their ORIGINAL 132px size; the connecting
-- strokes are only 6-8px tall/wide, never 132px overlays across the page.
SSCClassicFrameSkin = SSCClassicFrameSkin or {}
local Skin = SSCClassicFrameSkin
local ROOT = 'Interface\\AddOns\\SoftSpoken\\Compendium\\Textures\\ClassicFrames\\'
local METAL = ROOT .. 'UIFrameMetal'
local METAL_H = ROOT .. 'UIFrameMetalHorizontal'
local METAL_V = ROOT .. 'UIFrameMetalVertical'
local MARBLE = ROOT .. 'UI-Background-Marble'
local BOOK = 'Interface\\QuestFrame\\UI-QuestLog-BookIcon'

-- Source pixels (the four original 132x132 corner regions in a 512x512 atlas).
-- These coordinates deliberately avoid the neighboring atlas elements.
local ATLAS = 512
local corners = {
    TL = {135, 267, 135, 267},
    TR = {1, 133, 135, 267},
    BL = {1, 133, 1, 133},
    BR = {135, 267, 1, 133},
}

local function UV(rect, width, height)
    return rect[1]/width, rect[2]/width, rect[3]/height, rect[4]/height
end

local function Art(parent, layer, file, rect, sourceW, sourceH)
    local t = parent:CreateTexture(nil, layer)
    t:SetTexture(file)
    if rect then t:SetTexCoord(UV(rect, sourceW, sourceH)) end
    return t
end

function Skin.Apply(frame, title)
    -- Genuine tiled Blizzard marble: no stretching and no transparent gaps.
    frame:SetBackdrop({
        bgFile=MARBLE, tile=true, tileSize=256,
        insets={left=0,right=0,top=0,bottom=0},
    })
    if frame.SetBackdropColor then frame:SetBackdropColor(1,1,1,1) end

    -- Original 1.12 gray-stone header, sampled at native size rather than
    -- stretched across a giant window. Only the BACKGROUND layer is used.
    local headerTiles = {}
    local function UpdateHeader()
        local w = frame:GetWidth() or 0
        if w <= 0 then return end
        local total = math.max(0, w-23)
        local count = math.ceil(total/128)
        for i=1,count do
            local tile = headerTiles[i]
            if not tile then
                tile=frame:CreateTexture(nil,'BACKGROUND')
                tile:SetTexture('Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft')
                headerTiles[i]=tile
            end
            local tileWidth = math.min(128,total-(i-1)*128)
            tile:ClearAllPoints()
            tile:SetPoint('TOPLEFT',frame,'TOPLEFT',13+(i-1)*128,-35)
            tile:SetWidth(tileWidth)
            tile:SetHeight(51)
            tile:SetTexCoord(114/256,(114+tileWidth)/256,43/256,94/256)
            tile:Show()
        end
        for i=count+1,table.getn(headerTiles) do headerTiles[i]:Hide() end
    end
    frame:SetScript('OnSizeChanged',UpdateHeader)
    UpdateHeader()
    -- Child frame is transparent and mouse-pass-through; ONLY its border strokes
    -- and portrait/title are visible over the list and parchment.
    local chrome = CreateFrame('Frame', nil, frame)
    chrome:SetAllPoints(frame)
    chrome:EnableMouse(false)
    frame.SSZChrome = chrome
    local function RaiseChrome()
        chrome:SetFrameLevel(frame:GetFrameLevel() + 7)
    end
    frame.SSZRaiseChrome = RaiseChrome
    RaiseChrome()

    local TOP_RAISE = 14
    local PORTRAIT_X, PORTRAIT_Y = 7, 7-TOP_RAISE
    local pieces={}
    for _,name in ipairs({'TL','TR','BL','BR'}) do
        local tex = Art(chrome, 'OVERLAY', METAL, corners[name], ATLAS, ATLAS)
        tex:SetWidth(132)
        tex:SetHeight(132)
        if name == 'TL' then
            tex:SetPoint('TOPLEFT', chrome, 'TOPLEFT', 0, TOP_RAISE)
        elseif name == 'TR' then
            tex:SetPoint('TOPRIGHT', chrome, 'TOPRIGHT', 0, TOP_RAISE)
        elseif name == 'BL' then
            tex:SetPoint('BOTTOMLEFT', chrome, 'BOTTOMLEFT', 0, 0)
        else
            tex:SetPoint('BOTTOMRIGHT', chrome, 'BOTTOMRIGHT', 0, 0)
        end
        pieces[name]=tex
    end

    -- THREE horizontal strokes from the real 128x512 Blizzard texture.
    -- First and second strokes join the top corners; the third joins the foot.
    -- A sprite is at most eight pixels tall, so no atlas rectangle can run
    -- through the page when the window is resized.
    local function Horizontal(rect, yFromTop, fromBottom)
        local t=Art(chrome,'ARTWORK',METAL_H,rect,128,512)
        if fromBottom then
            t:SetPoint('BOTTOMLEFT',chrome,'BOTTOMLEFT',132,1)
            t:SetPoint('BOTTOMRIGHT',chrome,'BOTTOMRIGHT',-132,1)
        else
            t:SetPoint('TOPLEFT',chrome,'TOPLEFT',132,-yFromTop)
            t:SetPoint('TOPRIGHT',chrome,'TOPRIGHT',-132,-yFromTop)
        end
        t:SetHeight(rect[4]-rect[3])
        return t
    end
    -- Same vertical locations as those painted into the TL/TR atlas corners:
    -- 15..19 and 34..41 px from the original corner's top.
    local topUpper = Horizontal({0,128,149,156}, 14-TOP_RAISE, false)
    local topLower = Horizontal({0,128,169,177}, 34-TOP_RAISE, false)
    local bottomEdge = Horizontal({0,128,125,131}, 7, true)

    -- Verticals: the two contiguous 8px columns in the 512x128 metal sheet.
    -- Their ends anchor to the *inner ends* of the corners, not to a guessed
    -- length or a child frame's transient GetHeight() value.
    local function Vertical(rect, right)
        local t = Art(chrome,'ARTWORK',METAL_V,rect,512,128)
        if right then
            t:SetPoint('TOPRIGHT',chrome,'TOPRIGHT',-3,-(132-TOP_RAISE))
            t:SetPoint('BOTTOMRIGHT',chrome,'BOTTOMRIGHT',-3,132)
        else
            t:SetPoint('TOPLEFT',chrome,'TOPLEFT',11,-(132-TOP_RAISE))
            t:SetPoint('BOTTOMLEFT',chrome,'BOTTOMLEFT',11,132)
        end
        t:SetWidth(rect[2]-rect[1])
        return t
    end
    local leftEdge = Vertical({11,18,0,128},false)
    local rightEdge = Vertical({258,266,0,128},true)

    -- Portrait is intentionally painted ABOVE the ring's dark center but BELOW
    -- its silver-and-gold rim. It is the only content-sized decorative sprite.
    local portrait = Art(chrome,'ARTWORK',BOOK)
    portrait:SetWidth(59)
    portrait:SetHeight(60)
    portrait:SetPoint('TOPLEFT',chrome,'TOPLEFT',PORTRAIT_X,-PORTRAIT_Y)
    frame.portrait = portrait
    -- The corners are raised over the portrait via the OVERLAY draw layer.

    local caption=chrome:CreateFontString(nil,'OVERLAY','GameFontNormal')
    caption:SetText(title or "Azeroth's Compendium")
    caption:SetPoint('TOP',chrome,'TOP',26,-7)
    caption:SetHeight(20)
    caption:SetWidth(320)
    caption:SetJustifyH('CENTER')
    frame.titleText=caption

    local close=CreateFrame('Button',nil,frame,'UIPanelCloseButton')
    close:SetWidth(32);close:SetHeight(32)
    close:SetPoint('TOPRIGHT',frame,'TOPRIGHT',1,3)
    close:SetFrameLevel(chrome:GetFrameLevel()+1)
    close:SetScript('OnClick',function() frame:Hide() end)
    frame.CloseButton=close

    return frame
end
