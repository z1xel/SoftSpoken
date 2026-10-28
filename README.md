# SoftSpoken v0.8.0
*Voiced dialogue, lore, and text for World of Warcraft Vanilla.*

<p align="center">
  <img src="docs/images/softspoken-icon-320.png" width="320" height="320" alt="SoftSpoken icon">
</p>

SoftSpoken brings Azeroth to life through narrated quests, NPC conversations, books, and exploration, alongside an in-game Compendium for revisiting the world you've discovered.

The project is primarily developed for **Turtle WoW** successors and related Vanilla-based experiences, such as **Octo WoW**.

Considerable effort has gone into making SoftSpoken feel at home in the original game. Its interface draws extensively from Blizzard's own artwork and design conventions, with the aim of making its additions feel like a natural extension of Vanilla's own UI.

SoftSpoken is an ongoing effort to bring [Spoken](https://github.com/rusty-key/spoken-wow) to the original World of Warcraft 1.12 client, making use of the capabilities provided by ClassicAPI and other client extensions where appropriate. This is less a straightforward compatibility patch than an extensive reworking of Spoken, rebuilding and adapting its components to the capabilities and limitations of the original Vanilla client.

Whether you're already familiar with the projects SoftSpoken builds upon, or are encountering them for the first time, the following overview introduces its capabilities.

## How SoftSpoken Works

SoftSpoken consists of a central module, simply titled **SoftSpoken**, which provides the narration player and shared audio system that the specialized modules rely on for playback. It also hosts the underlying framework of the **Compendium**, a unified interface for browsing the game's narrated content.

There are currently three specialized modules, with at least one more planned:

- **SoftSpoken Stories** — Handles the narration of quests and NPC conversations, keeping a record of quests you've undertaken and their associated dialogue, from acceptance to completion.

- **SoftSpoken Places** — Provides narrated lore for Azeroth's zones and subzones as you explore, tracking the places you've discovered and integrating with the World Map.

- **SoftSpoken Writings** — Narrates books, letters, notes, and other readable objects encountered throughout the world, maintaining a record of your discoveries and reading history.

### The Compendium

Each module has a dedicated tab within the Compendium, containing a catalogue of its respective entries.

By default, the Compendium follows a **discovery-based approach**, intended to complement exploration and preserve the experience of a blind playthrough. Content is progressively unlocked through your adventures:

- **Stories:** Quests are recorded as they're accepted, with completion dialogue becoming available once the quest has been completed.
- **Places:** Lore is unlocked as you encounter and discover locations throughout Azeroth.
- **Writings:** Books and other readable objects are unlocked as you discover and inspect them.

Undiscovered entries remain locked, allowing the Compendium to grow alongside your character's journey rather than reveal everything from the outset.

However, this behavior is entirely optional. Players who prefer to explore the lore without these restrictions can unlock undiscovered entries, effectively turning the Compendium into a more traditional **encyclopedia of Azeroth**.

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
