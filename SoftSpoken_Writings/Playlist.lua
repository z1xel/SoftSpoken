-- Two reading modes with the same source and audio clips:
--   Compendium: the complete book is one continuous queue item, page to page.
--   In-world book: narrate ONLY the page shown by ITEM_TEXT_READY. Wait for the
--   player to turn the physical book page before starting the next recording.
-- Never use the narration player's global Pause button for page boundaries:
-- it pauses ALL sources, not one book. An empty Books queue is the page pause.

local SpokenBooks = SSB

--- The pages of a book from `pageId` onwards, in reading order.
function SpokenBooks:PagesFrom(pageId)
	local book = self:BookOf(pageId)
	if not book then
		return {}
	end

	local rest, found = {}, false
	for _, id in ipairs(book.pages) do
		if id == pageId then
			found = true
		end
		if found then
			table.insert(rest, id)
		end
	end
	return rest
end

--- Whether a page is already queued or speaking.
function SpokenBooks:IsQueued(pageId)
    return self.source and self.source.HasClip and
        self.source:HasClip("b:" .. pageId) or false
end


--- Each book being read, by book: { clip, the page of it in the queue; pages, those still to
--- come }, each page put at the head as the one before it finishes (PageEnded). A book's entry
--- goes once it is done, skipped or stopped.
SpokenBooks.following = {}

function SpokenBooks:IsComing(pageId)
	local book = self:PlaceOf(pageId)
	local entry = book and self.following[book]
	for _, id in ipairs(entry and entry.pages or {}) do
		if id == pageId then
			return true
		end
	end
	return false
end

local Follow

--- Whether the queue took `clip` and kept it: a file the client cannot find is dropped as it
--- starts, after the queue has taken it, and its stopCallback has run by then (Follow).
local function Taken(taken, clip)
	return taken and not clip.ended or false
end

--- A page left the queue: finished, the next page with a clip goes to the head; skipped or
--- stopped, the rest of the book goes with it.
local function PageEnded(clip, finished)
	local book = SpokenBooks:PlaceOf(clip.pageId)
	local entry = book and SpokenBooks.following[book]
	-- Only the book's page in the queue: an old page dropped as the book starts again over it
	-- leaves the new reading alone.
	if not (entry and entry.clip == clip) then
		return
	end
	if not finished then
		SpokenBooks.following[book] = nil
		return
	end
	local span = clip.span
	local before = span and clip.length and span.before + clip.length
	while table.getn(entry.pages) > 0 do
		local id = table.remove(entry.pages, 1)
		local nextClip = SpokenBooks:ClipFor(id)
		if nextClip then
			nextClip.ssbPlayback = "compendium"
			Follow(nextClip)
			nextClip.continues = table.getn(entry.pages) > 0
			nextClip.span = before and nextClip.length and { before = before, total = span.total } or nil
			if Taken(SpokenBooks.source and SpokenBooks.source:Continue(nextClip), nextClip) then
				entry.clip = nextClip
				return
			end
		end
		-- A page not read: the bar can no longer say how far through the book this is.
		before = nil
	end
	SpokenBooks.following[book] = nil
end

--- Where the first page of a reading sits in it, so the progress bar runs across the book
--- (clip.span): nothing before it, and every page's length in all. Nil where a page has none.
local function Span(first, rest)
	local total = tonumber(first.length)
	if not total then
		return nil
	end
	for _, id in ipairs(rest) do
		local length = SpokenBooks:PageLength(id)
		if not length then
			return nil
		end
		total = total + length
	end
	return { before = 0, total = total }
end

--- `clip` puts the next page at the head as it ends (PageEnded), before whatever else its own
--- stopCallback does: the next page is coming by the time that asks. Ended, it says so
--- (`ended`), so a page dropped as it starts is not taken for one being read (Taken).
function Follow(clip)
	local after = clip.stopCallback
	clip.stopCallback = function(ended, finished)
		ended.ended = true
		PageEnded(ended, finished)
		if after then after(ended, finished) end
	end
end

--- Whether any page of `book` is still queued or speaking.
---
--- Asked by the read-once rule, which must not refuse the book it is in the middle of
--- reading: a reader who jumps past the queued pages is still inside the book that was
--- already counted as read, and a refusal there would strand the narration on the page they
--- turned away from. Walks the book rather than trusting a remembered "currently reading",
--- which nothing clears when a queue drains on its own.
function SpokenBooks:IsNarrating(book)
    local data = self:Data()
    local entry = book and data and data.books[book]
    if not entry or not self.source or not self.source.HasClip then return false end

    -- Book membership remains domain-specific. The queue lookup is shared.
    local pages = {}
    for _, id in ipairs(entry.pages) do
        pages["b:" .. id] = true
    end
    return self.source:HasClip(function(clip)
        return clip.key and pages[clip.key]
    end)
end


--- Queue a book from the Compendium, or just the open page from the world.
--- `browsing` is the presentation context, not a reading-history setting:
---  * true  = keep reading all subsequent narrated pages without input.
---  * false = speak ONLY pageId; ITEM_TEXT_READY triggers the next page.
--- Returns how many narrated pages were accepted.
function SpokenBooks:PlayFrom(pageId, browsing)
    local source = self.source
    if not source then return 0 end

    local book = self:PlaceOf(pageId)

    if not browsing then
        local clip = self:ClipFor(pageId)
        if not clip then return 0 end
        clip.ssbPlayback = "reader"
        Follow(clip)
        if not Taken(source:Enqueue(clip), clip) then return 0 end
        self:MarkBookRead(book)
        return 1
    end

    -- The Compendium ALWAYS plays the complete book without page waits, even
    -- when obsolete readWholeBook/bookAsOneLine saved options are false.
    local queued, rest, first = 0, {}, nil
    for _, id in ipairs(self:PagesFrom(pageId)) do
        if queued == 0 then
            local clip = self:ClipFor(id)
            if clip then
                clip.ssbPlayback = "compendium"
                Follow(clip)
                if Taken(source:Enqueue(clip), clip) then
                    queued = queued + 1
                    first = clip
                end
            end
        elseif self:HasAudio(id) then
            table.insert(rest, id)
            queued = queued + 1
        end
    end
    if book and first then
        self.following[book] = { clip = first, pages = rest }
        first.continues = table.getn(rest) > 0
        first.span = Span(first, rest)
    end
    return queued
end

--- Sync to a page. Never replay an already queued page in the same mode.
--- Switching between the reader and Compendium cancels the old book session,
--- even if its current page ID happens to be the same.
function SpokenBooks:SyncTo(pageId, browsing)
    if not pageId then return 0 end
    local mode = browsing and "compendium" or "reader"
    local book = self:PlaceOf(pageId)
    local queued = self.source and self.source.FindClip and self.source:FindClip("b:" .. pageId)
    if queued and queued.ssbPlayback == mode then return 0 end
    if browsing and self:IsComing(pageId) then return 0 end

    if book and self:IsNarrating(book) then
        self:StopReading(book)
    end
    return self:PlayFrom(pageId, browsing)
end

--- Stop `book`, or every readable with none, and nothing else: a quest line may be queued too.
--- Not on closing the frame: a book reads on after it is shut.
function SpokenBooks:StopReading(book)
	if not book then
		if self.source then
			self.source:StopAll()
		end
		self.following = {}
		return
	end
	self.following[book] = nil
	if self.source then
		for _, clip in ipairs(Spoken:GetQueue()) do
			if clip.pageId and self:PlaceOf(clip.pageId) == book then
				self.source:Remove(clip)
			end
		end
	end
end
