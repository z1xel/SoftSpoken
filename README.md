# SoftSpoken v0.8.0 βeta
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

- **SoftSpoken Stories** — Handles the narration of quests and NPC conversations, keeping a record of quests you've undertaken and their associated dialogue, from acceptance to completion.

- **SoftSpoken Places** — Provides narrated lore for Azeroth's zones and subzones as you explore, tracking the places you've discovered and integrating with the World Map.

- **SoftSpoken Writings** — Narrates books, letters, notes, and other readable objects encountered throughout the world, maintaining a record of your discoveries and reading history.


SoftSpoken does not generate speech itself. Audio is provided through separately installed voice packs, which the corresponding modules recognize and use for playback.

This allows different voice packs to be installed, combined, or updated independently of SoftSpoken itself.

Instructions for obtaining and installing compatible voice packs are provided below.

### The Compendium

<img width="2254" height="1501" alt="image (32)" src="https://github.com/user-attachments/assets/93b80205-386d-4cab-b6d0-36a652f72bc5" />

Each module has a dedicated tab within the Compendium, containing a catalogue of its respective entries.

By default, the Compendium follows a **discovery-based approach**, intended to complement exploration and preserve the experience of a blind playthrough. Content is progressively unlocked through your adventures:

- **Stories:** Quests are recorded as they're accepted, with completion dialogue becoming available once the quest has been completed.
- **Places:** Lore is unlocked as you encounter and discover locations throughout Azeroth.
- **Writings:** Books and other readable objects are unlocked as you discover and inspect them.

Undiscovered entries remain locked, allowing the Compendium to grow alongside your character's journey rather than reveal everything from the outset.

However, this behavior is entirely optional. Players who prefer to explore the lore without these restrictions can unlock undiscovered entries, effectively turning the Compendium into a more traditional **encyclopedia of Azeroth**.

## SoftSpoken Stories

SoftSpoken Stories provides narration for quests and NPC gossip throughout the game. Narration can play automatically as you interact with NPCs, with configurable behavior for greetings, conversations, and quest dialogue.

Within the Compendium, Stories maintains a record of the quests you've encountered, organizing them by location and quest chain. Each entry provides access to its associated dialogue and available recordings, allowing you to revisit earlier encounters without returning to the original NPC.

<img width="2254" height="1501" alt="image (34)" src="https://github.com/user-attachments/assets/a4ae5547-77cc-4d2b-b624-b1cfc71ccd19" />

## SoftSpoken Places

SoftSpoken Places brings narrated lore to the world's zones and subzones, providing historical background and descriptions of the locations you encounter throughout your travels. Narration can be triggered automatically as you discover new areas or played manually through the Compendium.

Places also integrates directly with the in-game World Map, providing access to its lore without having to leave the map interface.

<img width="2254" height="1501" alt="image (35)" src="https://github.com/user-attachments/assets/97f0a168-ad10-4e7d-a03e-90471923720a" />

## SoftSpoken Writings

SoftSpoken Writings provides narration for supported books, letters, scrolls, notes, and other readable objects encountered during your adventures.

When reading an object in the world, narration follows the page currently being viewed. When revisiting it through the Compendium, playback can continue through the entire work.

<img width="1925" height="1282" alt="image (36)" src="https://github.com/user-attachments/assets/046b846c-5394-4592-b4b1-949d730a74a2" />

## Development and Feedback

SoftSpoken is under active development, and bugs or incomplete functionality should be expected while the beta is being prepared. Feedback is welcome: please use [GitHub Issues](https://github.com/z1xel/SoftSpoken/issues/new/choose) to report bugs, compatibility problems, or suggest improvements.

For the time being, development is maintainer-led and **external pull requests are not being accepted**. Bug reports, testing, and suggestions are still very much appreciated.

## Installation

SoftSpoken is installed manually in your World of Warcraft 1.12 `Interface\AddOns` directory.

1. Download SoftSpoken from [GitHub](https://github.com/z1xel/SoftSpoken) using **Code → Download ZIP**, then extract the archive.
2. Copy the following four folders into your game's `Interface\AddOns` directory:

   ```text
   Interface/
   └── AddOns/
       ├── SoftSpoken/
       ├── SoftSpoken_Stories/
       ├── SoftSpoken_Places/
       └── SoftSpoken_Writings/
   ```

3. Make sure these folders are directly inside `AddOns`, rather than nested inside an additional `SoftSpoken-main` directory.
4. Launch the game and enable the modules from the AddOns menu.

Once installed, use `/softspoken` to open the settings or `/compendium` to open Azeroth's Compendium. The Compendium also has a default keybinding of **J**, provided that key was not already assigned to another action.

### Voice Packs

SoftSpoken does not include audio recordings. To enable narration, install compatible voice packs separately for whichever modules you intend to use.

| Module | Voice pack |
|---|---|
| **Stories** | [Spoken Quests Audio: All](https://github.com/rusty-key/spoken-wow/releases/tag/quests-audio/v2.4.0) — quests and NPC gossip |
| **Places** | [Spoken Zones Audio](https://github.com/rusty-key/spoken-wow/releases/tag/zones-audio/v2.0.1) — zones and subzones |
| **Writings** | [Spoken Books Audio](https://github.com/rusty-key/spoken-wow/releases/tag/books-audio/v2.1.2) — books and other readable objects |

These packs are developed for the original [Spoken](https://github.com/rusty-key/spoken-wow) project. They are separate from the addon itself and can be installed or updated independently.

**Installing voice packs:** Download and extract the desired archives, then place their audio-pack folders directly alongside the SoftSpoken modules in `Interface\AddOns`. Each pack should retain its original folder name and `.toc` file.

For Stories, the complete GitHub audio archive is a large download. Alternatively, the individual [Alliance](https://www.curseforge.com/wow/addons/spoken-audio-quests-alliance), [Horde](https://www.curseforge.com/wow/addons/spoken-audio-quests-horde), [Shared Quests](https://www.curseforge.com/wow/addons/spoken-audio-quests-shared), and [Gossip](https://www.curseforge.com/wow/addons/spoken-audio-gossip) packs can be downloaded separately.

The **Spoken Audio: Quests – All** package on CurseForge is intended for addon managers and does not contain the recordings itself. For manual installation, use the GitHub archive or download the individual packs.

### Additional Quest Audio

SoftSpoken Stories also supports additional quest audio packs that can supplement the official Spoken recordings, including VanillaCombined and AI VoiceOver's Turtle WoW audio.

When multiple supported packs are installed, SoftSpoken prioritizes recordings in the following order:

1. Official Spoken quest audio
2. VanillaCombined fallback
3. Turtle WoW fallback

This ordering is handled by SoftSpoken itself, without requiring manual changes to the packs' audio-priority settings.

### Upgrading from Older Versions

If upgrading from an earlier SoftSpoken installation, remove the obsolete `SoftSpoken_Quests`, `SoftSpoken_Zones`, and `SoftSpoken_Books` folders before installing the renamed modules.

Your existing voice packs can remain installed. Do not delete your `WTF` directory, which contains saved preferences and character data.
