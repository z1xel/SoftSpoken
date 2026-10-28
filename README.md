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
