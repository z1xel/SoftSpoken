# Third-party licenses, credits, and content provenance

SoftSpoken is a fan-made World of Warcraft 1.12 addon and an adaptation of
[Spoken](https://github.com/rusty-key/spoken-wow) by Rusty Key. It includes
code and assets with **different owners and different terms**. This page is
an attribution/provenance index; attribution by itself does not establish
redistribution permission.

The [root MIT license](LICENSE) applies **only to code** for which its
copyright holders have granted MIT rights. It is **not** a blanket license
for everything in this repository. See the verbatim
[Spoken LICENSE](LICENSES/Spoken-MIT.txt) for the original notice and
[Spoken's third-party inventory](https://github.com/rusty-key/spoken-wow/blob/master/THIRD_PARTY.md)
for more detail on inherited assets and text.

## Code lineage

- **Spoken** (Rusty Key): the shared player, quest/story narration,
  Places/Writings features, data, and UI mechanisms are adapted from
  [rusty-key/spoken-wow](https://github.com/rusty-key/spoken-wow). The
  original author's MIT notice is preserved in this repository.
- **AI VoiceOver** (MrThinger and subsequent contributors): prior code
  ancestry of Spoken's quest playback and data-module loading systems.
  The [original project's source](https://github.com/mrthinger/wow-voiceover)
  carries the [Unlicense](LICENSES/AI-VoiceOver-UNLICENSE.txt), which applies
  to source code, **not automatically to its distributed audio, voices or
  Blizzard game text**.
- **SoftSpoken contributors:** additional code and changes to port and
  integrate the addons with Vanilla 1.12, ClassicAPI and SuperWoW. The
  names of upstream authors and copyright holders are not replaced by
  the SoftSpoken name.

## Bundled Lua libraries

Vendored libraries remain under their own licenses. They are loaded
from `SoftSpoken/Libs/` and `SoftSpoken_Stories/Libs/`; their source
files and embedded notices must remain intact when packaging.

| Library | Bundled path(s) | License / notice |
| --- | --- | --- |
| LibStub | `SoftSpoken/Libs/LibStub/` | Public domain; credits and dedication in the Lua file header |
| CallbackHandler-1.0 | `SoftSpoken/Libs/CallbackHandler-1.0/` | Ace3 project license; [full notice](LICENSES/Ace3.txt) |
| Ace3 components (AceDB, AceTimer; AceAddon, AceConsole, AceConfig, AceDBOptions, AceEvent, AceGUI) | `SoftSpoken/Libs/AceDB-3.0/`, `SoftSpoken/Libs/AceTimer-3.0/`, and `SoftSpoken_Stories/Libs/Ace*/` | [Ace3 license](LICENSES/Ace3.txt), copyright 2007 Ace3 Development Team; includes a restriction on redistributing Ace3 **standalone** |
| AceCore-3.0 (legacy compatibility library) | `SoftSpoken/Libs/AceCore-3.0/` | **Provenance and precise license not yet verified**; do not assume it is MIT without checking |
| LibDataBroker-1.1 | `SoftSpoken/Libs/LibDataBroker-1.1/` | Upstream reports public-domain / CC0 status; the bundled Lua has no explicit license header. [Project source](https://github.com/tekkub/libdatabroker-1-1) |
| LibDBIcon-1.0 | `SoftSpoken/Libs/LibDBIcon-1.0/` | **GPL-2.0-or-later**, copyright (C) 2008–2010 Rabbit, stated explicitly in the bundled source header. [GPL v2 full text](LICENSES/GPL-2.0.txt). **Not MIT or public domain.** |

This inventory reflects the version bundled here and should be revisited
when libraries are upgraded. The presence of a GPL library may require
additional compatibility/compliance assessment for the **combined
distribution**, even when the rest of the addon code is MIT; the root
license does not supersede those obligations. Preserve complete library
source and notices with released archives.

## Game text and lore databases

- **Quest, NPC, gossip, book, and item texts**, names and associated
  World of Warcraft game data under
  `SoftSpoken_Stories/Data/` and `SoftSpoken_Writings/Data/` derive
  principally from Blizzard Entertainment game content and the
  community-maintained world databases referenced by
  [Spoken](https://github.com/rusty-key/spoken-wow/blob/master/THIRD_PARTY.md).
  Neither this repository's MIT license nor those databases' code
  licenses grant ownership of Blizzard's text.
- **Places zone/subzone prose**, under `SoftSpoken_Places/Data/`,
  is adapted from Spoken's lore dataset derived from
  [Warcraft Wiki](https://warcraft.wiki.gg).
  Warcraft Wiki publishes its contributed text under
  [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/);
  relevant attribution, indication of changes and share-alike terms
  should be observed for adapted wiki text.
- Other collected metadata, including book location/source information,
  may contain data from community world databases. Consult
  Spoken's third-party inventory for source-by-source provenance.

## Artwork, textures and screenshots

- **Blizzard game UI art:** various parchment, metal frames, spellbook,
  quest-log and map elements under `SoftSpoken/Compendium/Textures/`,
  `SoftSpoken_Places/Textures/Art/`, and related UI assets are adapted
  from World of Warcraft UI artwork. Blizzard owns the underlying game
  artwork; the MIT code license does not license these textures.
- **Zone emblems and map icons:** `SoftSpoken/Textures/Zones/` and
  game icon textures include Blizzard imagery as well as pieces
  supplied by Spoken or its contributors. Attribution for
  Spoken-sourced zone icons is discussed in
  [upstream THIRD_PARTY.md](https://github.com/rusty-key/spoken-wow/blob/master/THIRD_PARTY.md);
  do not treat all icons as original SoftSpoken artwork.
- **Zone illustrations:** `SoftSpoken_Places/Textures/Pictures/`
  consists primarily of processed World of Warcraft screenshots,
  carried over from Spoken. A **per-picture source link index** is
  retained at
  [`SoftSpoken_Places/Textures/Pictures/CREDITS.md`](SoftSpoken_Places/Textures/Pictures/CREDITS.md).
  Source pages identify uploaders and their individual terms. These
  pictures were cleaned, sharpened, cropped, tinted or edged as
  described in that file; this does not erase the source rights.
  **Wiki-hosted images do not all necessarily carry the same license.**
- **Inherited AI VoiceOver/Spoken player UI assets**, including legacy
  `Book.blp`, `PortraitFrameAtlas.blp`,
  `QuestLogPlayButton.blp`, queue bullets and other `SoftSpoken/Textures/`
  elements, retain their original provenance. See Spoken's
  [third-party asset descriptions](https://github.com/rusty-key/spoken-wow/blob/master/THIRD_PARTY.md).
- **Link/service icons:** `SoftSpoken/Textures/Link*.tga` include
  third-party service marks and may include art from
  [Dashboard Icons](https://github.com/homarr-labs/dashboard-icons)
  and [Simple Icons](https://github.com/simple-icons/simple-icons), as
  described upstream. Trademark ownership remains with the respective
  organizations.
- **SoftSpoken icon and edited/new art:** assess each original or
  transformed image on its own merits. Project creation and inclusion
  do not automatically grant a license to third-party source art.

## Audio and voice packs

- The **four core addon folders** do not contain the official Spoken
  quest, zone or book voice packs. These are downloaded from
  [Spoken releases](https://github.com/rusty-key/spoken-wow/releases)
  separately, subject to their own applicable terms.
- `Data_Packs/SSS_VOFallback/` is an **optional** reduced combination
  of AI VoiceOver Vanilla/VanillaExtra material. The current repository
  contains **1,121 MP3 files (700 quest, 421 gossip)** as well as
  accompanying generated lookup/duration tables. Credit for original
  VoiceOver work belongs to MrThinger and the relevant recording
  contributors; the original game dialogue belongs to Blizzard.
- The licenses covering the **player/source code** (MIT or Unlicense)
  do **not automatically establish redistribution rights for those MP3
  recordings**, voice models, or underlying spoken game text. The
  precise audio-pack and speech-provider terms should be confirmed
  **before publishing the optional pack as a release asset**. No
  blanket MIT license is asserted for the recordings.
- Turtle WoW / third-party voice packs are **not** bundled here and
  remain the responsibility of their respective authors/distributors.

## Pre-release rights checks

The notices above improve attribution; they do not certify that every
asset is cleared for redistribution. Before shipping public archives:

1. Confirm the provenance and redistribution terms of the **1,121
   optional fallback recordings**. If not cleared, omit that optional
   pack from release assets until permission/terms are verified.
2. Verify the **AceCore-3.0** origin/license and confirm compliance
   when bundled alongside the GPL-licensed **LibDBIcon-1.0**. Preserve
   original library headers, the Ace3 terms and the complete GPL text.
3. Check relevant **Warcraft Wiki / individual screenshot file**
   license and attribution conditions, including source authors,
   modifications and any share-alike obligations.
4. Audit new branding, copied Blizzard textures and any later-added
   assets (including changes on open pull requests) for provenance.
5. Ensure release ZIPs retain `LICENSE`, `THIRD_PARTY.md`,
   required license texts and picture credits.

These are release checks, **not evidence of infringement**; unresolved
rights should be reported explicitly rather than silently assumed.

## Fan project notice

SoftSpoken is an independent fan project, not affiliated with, endorsed
or sponsored by Blizzard Entertainment. World of Warcraft and Blizzard
Entertainment are trademarks or registered trademarks of Blizzard
Entertainment, Inc.
