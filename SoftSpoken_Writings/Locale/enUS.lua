local SpokenBooks = SSB

-- Interface strings used by the Books options, book controls, and narration.
--
-- FORMAT ARGUMENTS ARE POSITIONAL (%1$s, %2$d), even where there is only one and
-- the position is obvious. Word order is the thing a translator most often has to
-- change and least often can.
--
-- A locale file per language overlays this table (Locale/<code>.lua), so anything
-- missing falls back to English at runtime. Chat and diagnostic prints stay
-- English everywhere, as in the other Spoken addons.

SpokenBooks.L = SpokenBooks.L or {}
local L = SpokenBooks.L

L.OPT_NOTE = "Books, letters, notes and plaques, read aloud when you open them."
L.OPT_SECTION_READING = "When to Read"
L.OPT_AUTOPLAY = "Read Automatically"
L.OPT_AUTOPLAY_TIP = "Reads a book or letter as soon as it opens. Off, nothing starts by itself: press Play on the page."
L.OPT_WHOLE_BOOK = "Read Whole Book"
L.OPT_WHOLE_BOOK_TIP = "Reads every page, not only the one on screen. Opening the first page lines up the rest, so the voice reads on while you turn the pages."
L.OPT_ONE_LINE = "Read Book as One Line"
L.OPT_ONE_LINE_TIP = "Puts a book in the queue as one line, named by what it is: Skip skips the rest of it, and the progress bar runs across the whole book. Off, each page waits in the queue on its own, with its page count."
L.OPT_READ_ONCE = "Read Only Once"
L.OPT_READ_ONCE_TIP = "Something this character has already heard is not read again when you open it. Play still works."
L.OPT_SECTION_LANGUAGE = "Language"
L.OPT_SECTION_PACKS = "Voice Packs"
L.OPT_STOP_ON_CLOSE = "Stop When Book Closes"
L.OPT_STOP_ON_CLOSE_TIP = "Stops the voice as soon as you close the book, letter or plaque. Off, it reads on after you close it."
L.OPT_CLOSE_WHEN_READ = "Close Book When Done Reading"
L.OPT_CLOSE_WHEN_READ_TIP = "Closes the book, letter or plaque automatically once its last page has been read aloud. With DialogueUI, that also brings back the interface it hides."
L.OPT_VOICE_LANGUAGE = "Voice Language"
L.OPT_FALLBACK_LANGUAGE = "If a Page Is Missing"
L.OPT_SECTION_READ = "Reading History"
L.PLAY = "Play"
L.STOP = "Stop"
L.PLAY_TIP = "Read this book aloud"
L.STOP_TIP = "Stop reading this book"
L.OPT_NO_PACK_AUDIO = "The installed voice pack has no narration for this page yet."
L.OPT_NO_PACK_INSTALLED = "No Writings voice pack is installed."




L.TYPE_BOOK = "Books"
L.TYPE_LETTER = "Letters"
L.TYPE_NOTE = "Notes"
L.TYPE_SCROLL = "Scrolls"
L.TYPE_TABLET = "Tablets and Runes"
L.TYPE_PLAQUE = "Plaques and Signs"
L.TYPE_GRAVE = "Gravestones"
L.TYPE_EXHIBIT = "Exhibits"
L.TYPE_OTHER = "Other"
-- One readable of each kind, over its name in the windows and the subtitle.
L.READABLE_BOOK = "Book"
L.READABLE_LETTER = "Letter"
L.READABLE_NOTE = "Note"
L.READABLE_SCROLL = "Scroll"
L.READABLE_TABLET = "Tablet"
L.READABLE_PLAQUE = "Plaque"
L.READABLE_GRAVE = "Gravestone"
L.READABLE_EXHIBIT = "Exhibit"
L.READABLE_OTHER = "Writing"
