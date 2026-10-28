# SoftSpoken v0.8.0
*Voiced dialogue, lore, and text for World of Warcraft Vanilla.*

<p align="center">
  <img src="https://github.com/user-attachments/assets/15cad23a-80c1-4e0b-81cd-d8f975d1ba6a" width="320" alt="SoftSpoken icon">
</p>

SoftSpoken brings Azeroth to life through narrated quests, NPC conversations, books, and exploration, alongside an in-game Compendium for revisiting the world you've discovered.

The project is primarily developed for **Turtle WoW** successors and related Vanilla-based experiences, such as **Octo WoW**.

Considerable effort has gone into making SoftSpoken feel at home in the original game. Its interface draws extensively from Blizzard's own artwork and design conventions, with the aim of making its additions feel like a natural extension of Vanilla's own UI.

SoftSpoken is an ongoing effort to bring [Spoken](https://github.com/rusty-key/spoken-wow) to the original World of Warcraft 1.12 client, making use of the capabilities provided by ClassicAPI and other client extensions where appropriate. This is less a straightforward compatibility patch than an extensive reworking of Spoken, rebuilding and adapting its components to the capabilities and limitations of the original Vanilla client.

Whether you're already familiar with the projects SoftSpoken builds upon, or are encountering them for the first time, the following overview introduces its capabilities.

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

## Quest and gossip audio priority

SoftSpoken Stories automatically prefers quest/gossip voice packs in this order:

1. `SpokenQuestsAudio*` (all official Spoken quest and gossip variants)
2. `SSVOFallback_VanillaCombined` (combined Vanilla + Extra fallback)
3. `AI_VoiceOverData_Turtle` (Turtle fallback)

This is enforced by SoftSpoken, **not** by changing a pack's `.toc`.
It works even if a pack update changes its `X-VoiceOver-DataModule-Priority`
or its `X-SpokenQuests-DataModule-Priority` value. Within the Spoken family,
higher declared priorities still win (for example, voice-acted overrides).
Other unrecognized packs retain their TOC priority relative to one another,
and sort below the three recognized families.

Only actual matching recordings are overridden: if Spoken does not have a
line, VanillaCombined is tried, then Turtle, then other installed modules.
Players can install or update the original packs unchanged.

To run the regression test from the repository root with Lua 5.1:

```sh
lua5.1 tests/audio_pack_priority_guardrails.lua
```
