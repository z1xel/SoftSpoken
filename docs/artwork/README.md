# SoftSpoken UI source artwork

These PNG files are **source/reference images**, not textures loaded by the WoW 1.12 client.
Keeping them under `docs/artwork` prevents the release ZIP (which packages the four addon folders)
from shipping development copies alongside the runtime TGA/BLP files.

- `compendium/PortraitRing-source.png` is the unscaled CharacterTab ring source.
- `compendium/QuestMapLogBrownBand_source.png` preserves an unused atlas extraction for reference; the TGA was removed from runtime assets.
- `compendium/prototype/` preserves the original frame/rock references used to prepare active runtime TGA art.
- [Portrait ring provenance](PORTRAIT_RING_SOURCE.md)
- [Search icon provenance](SEARCH_ICON_SOURCE.md)
- [Talking Heads provenance](TALKING_HEADS.md)

Only textures referenced by live addon code should remain under the four installable addon folders.
Removed unused runtime textures remain recoverable from Git history.
