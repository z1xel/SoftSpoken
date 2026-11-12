# Neutral Talking Heads portrait assets

Source: Blizzard's Talking Heads artwork, archived as [TalkingHeads.PNG](https://github.com/Gethe/wow-ui-textures/blob/live/QUESTFRAME/TalkingHeads.PNG) (1024×1024).

Both assets are uncompressed, 32-bit BGRA TGA files (128×128, top-left origin with 8-bit alpha), compatible with WoW 1.12. The source colors and transparency are retained.

- `PortraitNeutral.tga`: exact 128×128 crop at source (x=872, y=8). The transparent central aperture measures about 107×107 pixels. Alliance and Horde variants are intentionally not packaged yet.
- `PortraitBg.tga`: dark portrait backing cropped at source (x=572, y=314), 122×120 pixels, scaled by nearest-neighbor sampling to 128×128 so it fills the existing 120×120 portrait backing.

The player continues to use `PortraitFrameAtlas.blp` for the vertical divider, playback glyphs, and mover. Its portrait border alone is replaced. The Neutral frame is drawn over the existing ClassicAPI portrait, with a small measured centering offset, and no parchment text background or animated glow elements are introduced.

To switch factions later, package the corresponding atlas region and update only the portrait border texture path.
