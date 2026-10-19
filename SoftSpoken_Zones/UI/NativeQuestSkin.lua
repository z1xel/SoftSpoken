-- SoftSpoken Compendium: connected native Vanilla window chrome (UI-6).
-- The Turtle Quest Log is a *fixed* 768x512 layout. Its last 35px at right
-- and last ~70px at bottom contain non-window space; extracting those regions
-- as a nine-slice gives blank rails. Use a native resizable border instead.
-- The original Quest Log title-band art is used for the header.
-- No newer-client API, atlas system, or externally supplied image is required.
SSZUI = SSZUI or {}
local U = SSZUI

function U.AddNativeQuestLogChrome(frame)
    local parts = {}

    -- The game's dark backdrop has transparency by itself. Paint an opaque
    -- charcoal base first; this prevents the world showing between the panels.
    local solid = frame:CreateTexture(nil, "BACKGROUND")
    solid:SetTexture(.075, .071, .067, 1)
    solid:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
    solid:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 5)
    parts.solid = solid

    -- Authentic client stone material, translucent over the solid color.
    local stone = frame:CreateTexture(nil, "BORDER")
    stone:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background-Dark")
    stone:SetVertexColor(.83, .81, .77, .78)
    stone:SetPoint("TOPLEFT", frame, "TOPLEFT", 7, -7)
    stone:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -7, 7)
    parts.stone = stone

    -- Original Turtle 1.12 QuestLog-Left BLP is 512x512. Its upper center
    -- contains the recognizable double-metal title band seen in the log.
    local titleBand = frame:CreateTexture(nil, "ARTWORK")
    titleBand:SetTexture("Interface\\QuestFrame\\UI-QuestLog-Left")
    titleBand:SetTexCoord(142/512, 350/512, 2/512, 35/512)
    titleBand:SetPoint("TOPLEFT", frame, "TOPLEFT", 22, -3)
    titleBand:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -22, -3)
    titleBand:SetHeight(34)
    parts.titleBand = titleBand

    -- Explicit separation for the search/filters and footer button bay.
    -- The edges themselves come from the parent frame's client Backdrop.
    local upperRule = frame:CreateTexture(nil, "ARTWORK")
    upperRule:SetTexture(.32, .30, .27, .85)
    upperRule:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -42)
    upperRule:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -14, -42)
    upperRule:SetHeight(1)
    parts.upperRule = upperRule

    local footer = frame:CreateTexture(nil, "BORDER")
    footer:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background-Dark")
    footer:SetVertexColor(.86, .82, .76, .94)
    footer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 12, 9)
    footer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 9)
    footer:SetHeight(34)
    parts.footer = footer

    local footerRule = frame:CreateTexture(nil, "ARTWORK")
    footerRule:SetTexture(.40, .38, .33, 1)
    footerRule:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 13, 42)
    footerRule:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -13, 42)
    footerRule:SetHeight(1)
    parts.footerRule = footerRule

    return parts
end
