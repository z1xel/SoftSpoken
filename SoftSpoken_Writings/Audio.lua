-- What a page sounds like: which pack narrates it, where the file is, how long it runs.
--
-- Narration ships in a separate sound-pack addon because it is a large download, and it is
-- optional: without one there is nothing to play, so the addon stays quiet and says why.
--
-- THERE IS NO STAND-IN CLIP, for the reason SoftSpoken_Places/Audio.lua gives at length:
-- substituting unrelated audio is worse than silence, because silence is honest about what
-- is missing and a borrowed clip is not.

local Writings = SSB

local L = Writings.L

-- The pack table shape this version knows how to read. A pack declaring anything else is
-- ignored with a warning: refusing to read it is recoverable, guessing at an unknown layout
-- plays silence and reports nothing.
local PACK_FORMAT = 1

-- Validate an audio index before using it to construct a native MP3 path.
-- Metadata lengths are only UI estimates; absent/bad durations are fine.
local function ValidFile(file)
    if type(file) ~= "string" or not string.find(file, "%S") then return false end
    if string.find(file, ":", 1, true) or string.find(file, "%c") then return false end
    local normalized = string.gsub(file, "\\", "/")
    if string.sub(normalized, 1, 1) == "/" then return false end
    if normalized == ".." or string.find(normalized, "^%.%./")
        or string.find(normalized, "/%.%./") or string.find(normalized, "/%.%.$") then
        return false
    end
    return true
end

local function ValidEntry(entry)
    return type(entry) == "table" and ValidFile(entry.file)
end

local function EstimatedLength(length)
    local n = tonumber(length)
    if n and n > 0 and n < math.huge then return n end
    return nil
end

-- The dedicated Writings book portrait is bundled in Core. Keep the native
-- Vanilla inventory icon as a fallback if the custom art cannot be rendered.
local BOOK_TEXTURE = [[Interface\AddOns\SoftSpoken\Textures\WritingsBook]]
local VANILLA_BOOK_TEXTURE = [[Interface\Icons\INV_Misc_Book_09]]

-- A page's picture: its bag item's icon, its writing material, then (for
-- books only) our book cover. Other readable types keep the Vanilla icon.
local ICON_CROP = { 0.08, 0.92, 0.08, 0.92 }
local MATERIALS = {
	Stone = [[Interface\Icons\INV_Misc_StoneTablet_01]],
	Marble = [[Interface\Icons\INV_Misc_StoneTablet_07]],
	Bronze = [[Interface\Icons\INV_Misc_StoneTablet_03]],
	Silver = [[Interface\Icons\INV_Misc_StoneTablet_11]],
	Valentine = [[Interface\Icons\INV_Letter_15]],
}
Writings.MATERIALS = MATERIALS

--- Open is what the item text events say, not the game's frame, which DialogueUI hides. A page
--- queued with nothing open takes the book.
function Writings:PagePicture(bookID)
	if self.lastPage then
		local item = ItemTextGetItem and ItemTextGetItem()
		local icon, crop
		if Spoken and Spoken.BagItemIcon then icon, crop = Spoken:BagItemIcon(item) end
		if icon then return { kind = "texture", texture = icon, texCoord = crop } end
		local material = ItemTextGetMaterial and ItemTextGetMaterial()
		if material and MATERIALS[material] then
			return { kind = "texture", texture = MATERIALS[material], texCoord = ICON_CROP }
		end
	end
	local places = _G.SSBPlaces and SSBPlaces.books
	local readable = places and places[bookID]
	if not readable or readable.type == "book" then
		return {
			kind = "texture", texture = BOOK_TEXTURE,
			-- The cover is already composed on a square texture. Do not crop
			-- its edges using the inventory icon's built-in inset.
			texCoord = { 0, 1, 0, 1 },
			fallback = { kind = "texture", texture = VANILLA_BOOK_TEXTURE, texCoord = ICON_CROP },
		}
	end
	return { kind = "texture", texture = VANILLA_BOOK_TEXTURE, texCoord = ICON_CROP }
end

--- What the open page is written on (ItemTextGetMaterial: Parchment, Stone, Marble...), or nil
--- with nothing open.
function Writings:PageMaterial()
	if not self.lastPage then return nil end
	return ItemTextGetMaterial and ItemTextGetMaterial() or nil
end

-- The context beneath a work's title: its kind and the character's recorded
-- discovery location. Never substitute catalogue possibilities or the player's
-- current reading location when the origin was not recorded.
local function NarratorContext(bookID, base)
    local location = Writings.KnownDiscoverySummary and
        Writings:KnownDiscoverySummary(bookID)
    if location then return base .. " \194\183 " .. location end
    return base
end

-- What a readable can be (Data/Places.lua's `type`), in the order the Compendium lists them,
-- and the keys of its names: `one` of it, over its line in the queue, and `all`, the Compendium's.
Writings.TYPES = { "book", "letter", "note", "scroll", "tablet", "plaque", "grave", "exhibit", "other" }
Writings.TYPE_NAMES = {
	book = { one = "READABLE_BOOK", all = "TYPE_BOOK" },
	letter = { one = "READABLE_LETTER", all = "TYPE_LETTER" },
	note = { one = "READABLE_NOTE", all = "TYPE_NOTE" },
	scroll = { one = "READABLE_SCROLL", all = "TYPE_SCROLL" },
	tablet = { one = "READABLE_TABLET", all = "TYPE_TABLET" },
	plaque = { one = "READABLE_PLAQUE", all = "TYPE_PLAQUE" },
	grave = { one = "READABLE_GRAVE", all = "TYPE_GRAVE" },
	exhibit = { one = "READABLE_EXHIBIT", all = "TYPE_EXHIBIT" },
	other = { one = "READABLE_OTHER", all = "TYPE_OTHER" },
}

--- What `book` is (a book, a letter, a gravestone...), as the Compendium sorts it.
function Writings:KindOf(book)
	local places = _G.SSBPlaces and SSBPlaces.books
	local place = places and places[book]
    local key = (self.TYPE_NAMES[place and place.type] or self.TYPE_NAMES.other).one
    -- When metadata or a localization entry is absent, the narrator still
    -- needs a readable gold context line (and must not concatenate nil).
    return L[key] or L.READABLE_OTHER or "Readable"
end

--- Whether a book is one line in the queue (Read Book as One Line), rather than a line per page.
function Writings:OneLine()
	return not (SSBSettings and SSBSettings.bookAsOneLine == false)
end

--- Every installed pack this version can read, newest format first.
function Writings:GetAudioPacks()
	local packs, seen = {}, {}
	local function AddRegistry(registry)
		if type(registry) ~= "table" then return end
		for name, pack in pairs(registry) do
			if type(pack) == "table" and pack.version == PACK_FORMAT and type(pack.pages) == "table" then
				local addon = pack.addon or name
				if type(addon) == "string" and addon ~= "" and not seen[addon] then
					seen[addon] = true
					pack.addon = addon
					table.insert(packs, pack)
				end
			end
		end
	end
	-- Upstream renamed Books to Readables; accept either pack registry.
	AddRegistry(_G.SpokenReadablesAudioPacks)
	AddRegistry(_G.SpokenBooksAudioPacks)
	-- Newer Readables format first, then original Books; stable within each
	-- family, so addon load/registration order cannot change the chosen voice.
	table.sort(packs, function(a, b)
		local function Tier(pack)
			local name = pack.addon or ""
			if string.find(name, "^SpokenReadables") then return 2 end
			if string.find(name, "^SpokenBooks") then return 1 end
			return 0
		end
		local at, bt = Tier(a), Tier(b)
		if at ~= bt then return at > bt end
		return (a.addon or "") < (b.addon or "")
	end)
	return packs
end

local function PageStopped(clip, finished)
	if finished then
		Writings:OnPageFinished(clip)
	end
end

--- The clip for a page, as the player's queue wants it, or nil when no pack carries it.
---
--- Language before pack order: a pack in the voice language answers before any other, and a
--- page it lacks falls back to the fallback language's packs -- page by page, so a partial
--- translation still reads what it has.
function Writings:ClipFor(pageId)
	local place = self:Data() and self:Data().pages[pageId]
	if not place then
		return nil
	end

	local packs = self:GetAudioPacks()
	local selected, alternatives, seen = nil, {}, {}
	for _, language in ipairs(self:LanguageOrder()) do
		for _, pack in ipairs(packs) do
			local entry = self:PackLanguage(pack) == language and pack.pages[pageId]
			if ValidEntry(entry) then
				local book = self:Data().books[place.book]
				local oneLine = self:OneLine()
				local text = entry.text
				if not text and language == self.BASE_LANGUAGE then text = place.text end
				if not text and self.pageText and self.pageText[language] then
					text = self.pageText[language][pageId]
				end
				-- The title the client showed, in the language of the words below it; the
				-- corpus's own is English.
				local title = self.bookTitle and self.bookTitle[language] and self.bookTitle[language][place.book]
					or (book and book.title) or ""
                -- Writings deliberately reverses the Stories/Places hierarchy:
                -- the work is the white Morpheus heading and its kind/origin
                -- appears in the gold active row. Keep the title in queued rows,
                -- where the context alone would make different books indistinguishable.
                local kind = self:KindOf(place.book)
                local displayTitle = title ~= "" and title or kind
                local context = NarratorContext(place.book, kind)
                local queueLabel = displayTitle
                if not oneLine and book and book.pages and table.getn(book.pages) > 1 then
                    local page = "Page " .. tostring(place.number) .. " of " .. tostring(table.getn(book.pages))
                    context = context .. " \194\183 " .. page
                    queueLabel = queueLabel .. " \194\183 " .. page
                end
				local candidate = {
					key = "b:" .. pageId,
					path = [[Interface\AddOns\]] .. pack.addon .. [[\Sounds\]] .. entry.file .. ".mp3",
					-- Duration is an optional estimate for the UI. ClassicAPI
					-- playback state, not this metadata, controls page completion.
					-- Zero/unknown remains nil instead of fabricating a length.
					length = EstimatedLength(entry.len),
					pageId = pageId,
					-- A line per page: one book is one item to the player, its pages read on
					-- with no pause or cue between.
					group = not oneLine and "book:" .. tostring(place.book) or nil,
					-- What the report is filed under: a fallback page is an English take even
					-- under a German selection, and its report is about that.
					language = language,
					present = {
                        header = displayTitle,
                        transcript = text,
                        label = context,
                        queueLabel = queueLabel,
						bullet = "book",
						material = self:PageMaterial(),
						portrait = self:PagePicture(place.book),
					},
					stopCallback = PageStopped,
				}
				if not seen[candidate.path] then
					seen[candidate.path] = true
					if not selected then selected = candidate
					else table.insert(alternatives, candidate) end
				end
			end
		end
	end

	if selected then selected.fallbacks = alternatives end
	return selected
end

--- A page's length in seconds, from the pack ClipFor would read it from; nil where that pack
--- recorded none.
function Writings:PageLength(pageId)
	local packs = self:GetAudioPacks()
	for _, language in ipairs(self:LanguageOrder()) do
		for _, pack in ipairs(packs) do
			local entry = self:PackLanguage(pack) == language and pack.pages[pageId]
			if ValidEntry(entry) then
				return EstimatedLength(entry.len)
			end
		end
	end
	return nil
end

--- Why there is no clip, phrased for the player. Distinguishes "you have no sound pack"
--- from "your pack does not cover this page": the first is a download and the second is
--- nothing they can do, and telling them apart is the point of saying anything at all.
function Writings:DescribeMissingAudio()
	if table.getn(self:GetAudioPacks()) == 0 then
		return L.OPT_NO_PACK_INSTALLED
	end
	return L.OPT_NO_PACK_AUDIO
end

--- Whether ClipFor would find a clip, without building one.
function Writings:HasAudio(pageId)
	local data = self:Data()
	if not (data and data.pages[pageId]) then
		return false
	end
	local packs = self:GetAudioPacks()
	for _, language in ipairs(self:LanguageOrder()) do
		for _, pack in ipairs(packs) do
			if self:PackLanguage(pack) == language and ValidEntry(pack.pages[pageId]) then
				return true
			end
		end
	end
	return false
end
