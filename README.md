# SoftSpoken v0.8.1 βeta
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

<img width="1530" height="1019" alt="image (33)" src="https://github.com/user-attachments/assets/cb94d9d0-86ca-46e8-a659-24f9956b88f7" />

There are currently three specialized modules, with at least one more planned:

- **[SoftSpoken Stories](#stories)** — Handles the narration of quests and NPC conversations, keeping a record of quests you've undertaken and their associated dialogue, from acceptance to completion.

- **[SoftSpoken Places](#places)** — Provides narrated lore for Azeroth's zones and subzones as you explore, tracking the places you've discovered and integrating with the World Map.

- **[SoftSpoken Writings](#writings)** — Narrates books, letters, notes, and other readable objects encountered throughout the world, maintaining a record of your discoveries and reading history.

### The Compendium

<img width="2254" height="1501" alt="image (32)" src="https://github.com/user-attachments/assets/93b80205-386d-4cab-b6d0-36a652f72bc5" />

Each module has a dedicated tab within the Compendium, containing a catalogue of its respective entries.

By default, the Compendium follows a **discovery-based approach**, intended to complement exploration and preserve the experience of a blind playthrough. Content is progressively unlocked through your adventures:

- **Stories:** Quests are recorded as they're accepted, with completion dialogue becoming available once the quest has been completed.
- **Places:** Lore is unlocked as you encounter and discover locations throughout Azeroth.
- **Writings:** Books and other readable objects are unlocked as you discover and inspect them.

Undiscovered entries remain locked, allowing the Compendium to grow alongside your character's journey rather than reveal everything from the outset.

However, this behavior is entirely optional. Players who prefer to explore the lore without these restrictions can unlock undiscovered entries, effectively turning the Compendium into a more traditional **encyclopedia of Azeroth**.

## Stories

SoftSpoken Stories provides narration for quests and NPC gossip throughout the game. Narration can play automatically as you interact with NPCs, with configurable behavior for greetings, conversations, and quest dialogue.

Within the Compendium, Stories maintains a record of the quests you've encountered, organizing them by location and quest chain. Each entry provides access to its associated dialogue and available recordings, allowing you to revisit earlier encounters without returning to the original NPC.

<img width="2254" height="1501" alt="image (34)" src="https://github.com/user-attachments/assets/a4ae5547-77cc-4d2b-b624-b1cfc71ccd19" />

## Places

SoftSpoken Places brings narrated lore to the world's zones and subzones, providing historical background and descriptions of the locations you encounter throughout your travels. Narration can be triggered automatically as you discover new areas or played manually through the Compendium.

Places also integrates directly with the in-game World Map, providing access to its lore without having to leave the map interface.

<img width="2254" height="1501" alt="image (35)" src="https://github.com/user-attachments/assets/97f0a168-ad10-4e7d-a03e-90471923720a" />

## Writings

SoftSpoken Writings provides narration for supported books, letters, scrolls, notes, and other readable objects encountered during your adventures.

When reading an object in the world, narration follows the page currently being viewed. When revisiting it through the Compendium, playback can continue through the entire work.

<img width="1925" height="1282" alt="image (36)" src="https://github.com/user-attachments/assets/046b846c-5394-4592-b4b1-949d730a74a2" />

## Development and Feedback

SoftSpoken is currently in beta and under active development. Some features may be incomplete, and bugs are to be expected. Feedback is encouraged: please use [GitHub Issues](https://github.com/z1xel/SoftSpoken/issues/new/choose) to report bugs, compatibility problems, or suggest improvements.

For the time being, development remains maintainer-led, and external pull requests are not being accepted. However, I plan to open contributions in the future, with technical documentation to be published in the coming months to help others understand the codebase.

In the meantime, bug reports, testing, and suggestions are greatly appreciated.

## Installation

1. Download **[SoftSpoken-v0.8.0-beta.1.zip](https://github.com/z1xel/SoftSpoken/releases/download/v0.8.0-beta.1/SoftSpoken-v0.8.0-beta.1.zip)** and extract it.
2. Find the following four addon folders in the extracted contents and copy them into your World of Warcraft 1.12 `Interface\AddOns` directory:

   ```text
   Interface/
   └── AddOns/
       ├── SoftSpoken/
       ├── SoftSpoken_Stories/
       ├── SoftSpoken_Places/
       └── SoftSpoken_Writings/
   ```
3. Launch the game and enable SoftSpoken and its modules in the **AddOns** menu.

Use `/softspoken` to open settings or `/compendium` to open Azeroth's Compendium. The Compendium also has a default keybinding of **J**, provided that key was not already assigned to another action.

**Voice packs are installed separately** as described below.

### Voice Packs

SoftSpoken does not generate speech itself. Audio is provided through separately installed voice packs, which the corresponding modules recognize and use for playback.

This allows different voice packs to be installed, combined, or updated independently of SoftSpoken itself.

To enable narration, install compatible voice packs for whichever modules you intend to use.

| Module | Voice pack |
|---|---|
| **Stories** | [Spoken Quests Audio: All](https://github.com/rusty-key/spoken-wow/releases/tag/quests-audio/v2.4.0) — quests and NPC gossip |
| **Places** | [Spoken Zones Audio — Vanilla 1.12](https://github.com/z1xel/SoftSpoken/releases/download/audio-vanilla-112-v1/SpokenZonesAudio-2.0.1-1.12.zip) — zones and subzones |
| **Writings** | [Spoken Books Audio — Vanilla 1.12](https://github.com/z1xel/SoftSpoken/releases/download/audio-vanilla-112-v1/SpokenBooksAudio-2.1.2-1.12.zip) — books and other readable objects |

These voice packs originate from [Spoken](https://github.com/rusty-key/spoken-wow) by Rusty Key. The **Places** and **Writings** downloads above are [Vanilla 1.12-compatible repacks](https://github.com/z1xel/SoftSpoken/releases/tag/audio-vanilla-112-v1) of the [original Zones](https://github.com/rusty-key/spoken-wow/releases/tag/zones-audio/v2.0.1) and [Books](https://github.com/rusty-key/spoken-wow/releases/tag/books-audio/v2.1.2) releases. Only the addon manifests (`.toc` files) were adjusted; the recordings are unchanged.

**Installing voice packs:** Download the packs you want and extract them directly into `Interface\AddOns`, alongside the SoftSpoken modules. No separate compatibility patch is needed for the linked Places and Writings packs.

**Vanilla 1.12 compatibility:** Enable **Load out of date AddOns** if necessary. After login, open `/softspoken` and check the **Voice Packs** section of each module to confirm it detected your installation.

### Additional Quest Audio

A substantial amount of Turtle WoW's custom quest and NPC dialogue has been voiced through the AI VoiceOver project. **SoftSpoken Stories supports these recordings directly**, without requiring the original AI VoiceOver addon or manual configuration.

I've also prepared **SSS_VOFallback** (SoftSpoken Stories VoiceOver Fallback), a supplementary pack containing Vanilla quest and gossip recordings not already covered by Spoken.

| Voice pack | Description | Download |
|---|---|---|
| **Turtle WoW VoiceOver** | AI-generated narration for Turtle WoW's custom quests and NPC dialogue. | [Download Turtle WoW Voice Data](https://github.com/lightbladeninja/wow-voiceover/releases/download/v1.5.0/AI_VoiceOverData_Turtle.zip) |
| **SSS_VOFallback** | Additional Vanilla and VanillaExtra recordings that fill gaps in Spoken's quest and gossip coverage. | [SSS_VOFallback Pack](https://github.com/z1xel/SoftSpoken/releases/download/v0.8.0-beta.1/SSS_VOFallback.zip) |

**Installation:** Place the `AI_VoiceOverData_Turtle` and/or `SSS_VOFallback` folders directly inside `Interface\AddOns`, alongside the SoftSpoken modules.

When multiple packs contain the same recording, SoftSpoken automatically prioritizes **Spoken → SSS_VOFallback → Turtle WoW**, without requiring manual edits to audio priorities.

## Support SoftSpoken

SoftSpoken is a free project, but developing and maintaining it takes a considerable amount of time and effort.

If you'd like to support my work, consider [buying me a coffee](https://buymeacoffee.com/zaxl).

## Credits and licensing

**SoftSpoken is developed and maintained by [z1xel](https://github.com/z1xel).** It builds upon [Spoken](https://github.com/rusty-key/spoken-wow) by Rusty Key.

For licensing information and third-party acknowledgments, see [LICENSE](LICENSE) and [THIRD_PARTY.md](THIRD_PARTY.md).
