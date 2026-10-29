-- ITEM_TEXT_* book event binding for Vanilla 1.12 globals.
local B=SSB
local f=CreateFrame("Frame")
B.eventFrame=f
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ITEM_TEXT_BEGIN")
f:RegisterEvent("ITEM_TEXT_READY")
f:RegisterEvent("ITEM_TEXT_CLOSED")
function B:OnTextReady()
    -- The game sends READY on opening and page turns, and sometimes repeats
    -- it for a single page. Do not automatically replay a page that just ended.
    local previous = self.lastPage
    local page = self:PageOnScreen()
    self.lastPage = page
    if not page then return 0 end
    local book = self:PlaceOf(page)
    self:MarkBookFound(book)
    if self.RefreshReadables and self.readables and self.readables.IsShown and self.readables:IsShown() then
        self:RefreshReadables()
    end
    if previous == page then return 0 end
    if not self.source or not SSBSettings or not SSBSettings.autoplay then return 0 end
    -- Read Only Once applies to opening a previously read book, not to every
    -- new page of a book that has been marked read during THIS reading session.
    local continuingBook = previous and self:PlaceOf(previous) == book
    if SSBSettings.readOnce and self:HasReadBook(book) and
        not self:IsNarrating(book) and not continuingBook then return 0 end
    return self:SyncTo(page, false)
end
function B:OnTextClosed()
    local book=self:PlaceOf(self.lastPage)
    self.lastPage=nil
    if book and SSBSettings and SSBSettings.stopOnClose then
        self:StopReading(book)
    end
end
function B:OnPageFinished(clip)
    if not SSBSettings or not SSBSettings.closeWhenRead then return end
    local book=self:PlaceOf(clip and clip.pageId)
    if not book or self:PlaceOf(self.lastPage)~=book or self:IsNarrating(book) then return end
    local later=self:PagesFrom(clip.pageId)
    for i=2,table.getn(later) do
        if self:HasAudio(later[i]) then return end
    end
    if CloseItemText then CloseItemText() end
end
function B:ReadCurrent()
    local page=self:PageOnScreen() or self.lastPage
    if not page then return 0 end
    return self:SyncTo(page)
end
f:SetScript("OnEvent",function()
    local e=event
    if e=="ADDON_LOADED" then
        if arg1=="SoftSpoken_Writings" then
            B:InitDB()
            f:UnregisterEvent("ADDON_LOADED")
        end
    elseif e=="PLAYER_ENTERING_WORLD" then
        if not SSBSettings then B:InitDB() end
        B:SetupSource()
        if B.SetupPlayButton then B:SetupPlayButton() end
    elseif e=="ITEM_TEXT_READY" then
        B:OnTextReady()
        if B.SetupPlayButton then B:SetupPlayButton() end
        if B.RefreshPlayButton then B:RefreshPlayButton() end
    elseif e=="ITEM_TEXT_CLOSED" then
        B:OnTextClosed()
        if B.RefreshPlayButton then B:RefreshPlayButton() end
    end
end)
