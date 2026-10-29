# Credits and third-party content

SoftSpoken is a free, fan-made addon for World of Warcraft 1.12. It adapts
[Spoken](https://github.com/rusty-key/spoken-wow) for Vanilla clients,
including Turtle WoW. Thank you to the people and projects whose work makes
this possible.

## Projects

- **[Spoken](https://github.com/rusty-key/spoken-wow)**, by **Rusty Key**. Its original
  copyright and MIT notice are preserved in [LICENSES/Spoken-MIT.txt](LICENSES/Spoken-MIT.txt).
  See [Spoken's credits](https://github.com/rusty-key/spoken-wow/blob/master/THIRD_PARTY.md)
  for further source details.
- **[AI VoiceOver](https://github.com/mrthinger/wow-voiceover)**, by **MrThinger**
  and other contributors: an earlier foundation for the quest narration
  system and audio-data formats. Its source-code notice is preserved in
  [LICENSES/AI-VoiceOver-UNLICENSE.txt](LICENSES/AI-VoiceOver-UNLICENSE.txt).
- **SoftSpoken contributors**: the Vanilla 1.12 port, integrations,
  interface adaptations, and additional development.

## Bundled Lua libraries

The addons bundle libraries in `SoftSpoken/Libs/` and
`SoftSpoken_Stories/Libs/`. These retain their own licenses:

- **Ace3 components and CallbackHandler-1.0** — Ace3 Development Team,
  [Ace3 license](LICENSES/Ace3.txt). Includes AceDB, AceTimer, AceAddon,
  AceConsole, AceConfig, AceDBOptions, AceEvent and AceGUI.
- **LibDBIcon-1.0** — Rabbit, **GPL v2 or later**, as specified in its
  source header; [GPL v2 text](LICENSES/GPL-2.0.txt).
- **LibStub** — public-domain dedication and credits in its source header.
- **LibDataBroker-1.1** — [original project](https://github.com/tekkub/libdatabroker-1-1);
  commonly distributed as public-domain/CC0; its bundled Lua file does not
  contain an explicit license notice.
- **AceCore-3.0** — bundled legacy compatibility library; its exact
  origin and license are not identified in the source copy.

The [root MIT license](LICENSE) covers code appropriately licensed under
MIT, not the bundled libraries under different terms. Retain the original
library notices when distributing the addon.

## Warcraft content and artwork

- **World of Warcraft quest dialogue, NPC names, books and game data**
  belong to Blizzard Entertainment. The text databases were adapted
  through Spoken and earlier community projects.
- **Places lore text** was adapted from [Warcraft Wiki](https://warcraft.wiki.gg),
  whose contributed text is licensed under
  [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
- **Interface artwork, map icons and zone emblems** include Blizzard
  game assets and Spoken-derived artwork.
- **Places illustrations** are adapted game screenshots. The
  [per-picture source credits](SoftSpoken_Places/Textures/Pictures/CREDITS.md)
  identify the original images and their source pages.
- Other player textures and service icons inherit their original
  sources and trademarks; further details appear in
  [Spoken's third-party credits](https://github.com/rusty-key/spoken-wow/blob/master/THIRD_PARTY.md).

## Voice recordings

The official Spoken quest, zone and book recordings are distributed
separately by [Spoken](https://github.com/rusty-key/spoken-wow/releases).
The optional `Data_Packs/SSS_VOFallback/` contains 1,121 recordings
from AI VoiceOver Vanilla/VanillaExtra material, credited to the original
project and recording contributors. Other Turtle WoW voice packs are
distributed by their respective authors. Audio and game dialogue have
their own applicable terms; the MIT code license does not license them.

SoftSpoken is an independent fan project and is not affiliated with,
endorsed by or sponsored by Blizzard Entertainment. World of Warcraft
and Blizzard are trademarks of Blizzard Entertainment.
