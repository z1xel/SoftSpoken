# Neutral Talking Heads portrait assets

Source: Blizzard's Talking Heads artwork, archived as [TalkingHeads.PNG](https://github.com/Gethe/wow-ui-textures/blob/live/QUESTFRAME/TalkingHeads.PNG) (1024×1024).

Both assets are uncompressed, 32-bit BGRA TGA files (128×128, top-left origin with 8-bit alpha), compatible with WoW 1.12. The source colors and transparency are retained.

- `PortraitNeutral.tga`: exact 128×128 crop at source (x=872, y=8). The transparent central aperture measures about 107×107 pixels. Alliance and Horde variants are intentionally not packaged yet.
- `PortraitBg.tga`: a reference extraction of the Talking Heads dark backing, cropped at source (x=572, y=314) and resampled to 128×128. **Not used by the narrator:** the source crop has transparent pixels on its bottom and lower-right edges that exposed the world behind the portrait when stretched to 120×120.

The narrator uses its original `PortraitFrameBackground.blp` for both the main portrait backing and the pause overlay. Only the ornate Neutral border was substituted. `PortraitFrameAtlas.blp` remains in use for the vertical divider, playback glyphs, and mover. The Neutral frame is drawn over the existing ClassicAPI portrait, with a small measured centering offset; no parchment text background or animated glow elements are introduced.

The Neutral border has a baked dark outer outline and shadowed inner edge. The underlying 120×120 model viewport is a separate rectangle; its fit should be checked in game before modifying the border art.

To switch factions later, package the corresponding atlas region and update only the portrait border texture path.
