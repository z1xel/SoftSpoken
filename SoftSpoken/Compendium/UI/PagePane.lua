-- Shared parchment and scrollbar housing for Places, Books and Quests.
-- Preserve the approved 1.12 anchors and exact legacy frame geometry.
local C = SSCCompendium

-- createPage(holder) produces a page; every tab retains its own content,
-- button behavior and scrolling state.
function C.CreatePagePane(panel, list, createPage)
    local inset = CreateFrame("Frame", nil, panel)
    if not (SSCPrototypePageSkin and SSCPrototypePageSkin.Apply) then
        SSCUI.AddInsetBorder(inset)
    end
    if inset.SetBackdropColor then
        inset:SetBackdropColor(.08, .07, .06, 1)
    end
    inset:SetPoint("TOPLEFT", list.inset, "TOPRIGHT", 27, 0)
    inset:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 6)
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
    return inset, page
end
