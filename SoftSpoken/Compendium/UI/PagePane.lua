-- Shared parchment, border, and scrollbar housing for Compendium pages
-- and the map's attached lore reader. This is deliberately independent of
-- lore/discovery data and does not create duplicate scroll controllers.
local C = SSCCompendium

-- Creates the same page hierarchy used by all three Compendium modules.
-- The caller controls only the inset's position; the page's artwork and
-- narrow 31-unit scrollbar housing always come from the shared skins.
local function BuildPage(inset, createPage)
    if not (SSCPrototypePageSkin and SSCPrototypePageSkin.Apply) then
        SSCUI.AddInsetBorder(inset)
    end
    if inset.SetBackdropColor then
        inset:SetBackdropColor(.08, .07, .06, 1)
    end
    local holder = CreateFrame("Frame", nil, inset)
    holder:SetPoint("TOPLEFT", inset, "TOPLEFT", 5, -5)
    holder:SetPoint("BOTTOMRIGHT", inset, "BOTTOMRIGHT", -36, 5)
    local page = createPage(holder)
    if SSCPrototypePageSkin and SSCPrototypePageSkin.Apply then
        SSCPrototypePageSkin.Apply(inset, holder, page)
    end
    if SSCPrototypeScrollSkin and SSCPrototypeScrollSkin.AttachPage then
        SSCPrototypeScrollSkin.AttachPage(inset, page)
    end
    return page
end

-- Compendium's existing split view, with its approved offsets unchanged.
function C.CreatePagePane(panel, list, createPage)
    local inset = CreateFrame("Frame", nil, panel)
    inset:SetPoint("TOPLEFT", list.inset, "TOPRIGHT", 27, 0)
    inset:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 6)
    return inset, BuildPage(inset, createPage)
end

-- Standalone reader (World Map attachment). Same skins and real lore page,
-- but its inset is anchored to the host panel rather than the left-hand list.
-- Allows the map to keep its close/collapse header without copying any skin.
function C.CreateStandalonePagePane(panel, createPage, margins)
    margins = margins or {}
    local inset = CreateFrame("Frame", nil, panel)
    inset:SetPoint("TOPLEFT", panel, "TOPLEFT",
        margins.left or 8, -(margins.top or 40))
    inset:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT",
        -(margins.right or 8), margins.bottom or 8)
    local page = BuildPage(inset, createPage)
    -- World-map addons can change the panel's height/scale without selecting
    -- a new zone. Reflow the existing text and image; never create another page.
    inset:SetScript("OnSizeChanged", function()
        if page and page.Resize then page:Resize(false) end
    end)
    return inset, page
end
