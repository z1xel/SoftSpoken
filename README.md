# SoftSpoken
An immersive narration and lore companion for Turtle WoW (1.12), featuring voiced exploration, books, and an in-game compendium. Based on Spoken WoW.

## Installation and module folders

Install the four folders directly in your WoW 1.12 `Interface/AddOns/` directory:

- `SoftSpoken/` — shared player and Compendium
- `SoftSpoken_Stories/` — quests and NPC conversations
- `SoftSpoken_Places/` — zone lore and discoveries
- `SoftSpoken_Writings/` — books, letters and other readable objects

**Upgrading from older SoftSpoken versions:** delete the obsolete
`SoftSpoken_Quests/`, `SoftSpoken_Zones/` and `SoftSpoken_Books/` folders
before installing these renamed folders. Otherwise WoW may load the old
modules alongside the new ones. Do not delete your `WTF/` saved-variable
files: internal data keys and stored preferences are unchanged.

Voice packs remain separately installed add-ons. If a third-party pack
explicitly declares one of the old module folder names as a dependency,
its TOC needs to reference the corresponding new name.
