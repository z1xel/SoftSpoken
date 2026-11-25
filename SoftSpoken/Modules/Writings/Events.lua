-- ITEM_TEXT_* book event binding for Vanilla 1.12 globals.
local Writings=SpokenWritings
function Writings:OnTextReady()
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
    if not self.source or not self.db or not self.db.profile.autoplay then return 0 end
    -- Read Only Once applies to opening a previously read book, not to every
    -- new page of a book that has been marked read during THIS reading session.
    local continuingBook = previous and self:PlaceOf(previous) == book
    if self.db.profile.readOnce and self:HasReadBook(book) and
        not self:IsNarrating(book) and not continuingBook then return 0 end
    return self:SyncTo(page, false)
end
function Writings:OnTextClosed()
    local book=self:PlaceOf(self.lastPage)
    self.lastPage=nil
    if book and self.db and self.db.profile.stopOnClose then
        self:StopReading(book)
    end
end
function Writings:OnPageFinished(clip)
    if not self.db or not self.db.profile.closeWhenRead then return end
    local book=self:PlaceOf(clip and clip.pageId)
    if not book or self:PlaceOf(self.lastPage)~=book or self:IsNarrating(book) then return end
    local later=self:PagesFrom(clip.pageId)
    for i=2,table.getn(later) do
        if self:HasAudio(later[i]) then return end
    end
    if CloseItemText then CloseItemText() end
end
function Writings:ReadCurrent()
    local page=self:PageOnScreen() or self.lastPage
    if not page then return 0 end
    return self:SyncTo(page)
end
function Writings:SetupEvents()
    if self.eventFrame then return end
    local f=CreateFrame("Frame")
    self.eventFrame=f
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("ITEM_TEXT_BEGIN")
    f:RegisterEvent("ITEM_TEXT_READY")
    f:RegisterEvent("ITEM_TEXT_CLOSED")
    f:SetScript("OnEvent",function()
        local e=event
        if e=="PLAYER_ENTERING_WORLD" then
            -- The source and database are ready. Only the Blizzard book frame
            -- may not have existed during login.
            if Writings.SetupPlayButton and Writings:SetupPlayButton() then
                f:UnregisterEvent("PLAYER_ENTERING_WORLD")
            end
        elseif e=="ITEM_TEXT_READY" then
            Writings:OnTextReady()
            if Writings.SetupPlayButton then Writings:SetupPlayButton() end
            if Writings.RefreshPlayButton then Writings:RefreshPlayButton() end
        elseif e=="ITEM_TEXT_CLOSED" then
            Writings:OnTextClosed()
            if Writings.RefreshPlayButton then Writings:RefreshPlayButton() end
        end
    end)
end
