# Talking Heads narrator assets

Source: Blizzard's Talking Heads artwork, archived as [TalkingHeads.PNG](https://github.com/Gethe/wow-ui-textures/blob/live/QUESTFRAME/TalkingHeads.PNG) (1024×1024).

The artwork is cross-checked against Blizzard's [AtlasInfo.lua](https://github.com/Resike/BlizzardInterfaceResources/blob/master/Resources/Data/AtlasInfo.lua) for atlas file 1111217 (1024×1024). The Neutral entry has native size **143×143**, UVs **(0.842773, 0.982422, 0.000976562, 0.140625)** and no tiling, corresponding to source pixels **x=863–1005, y=1–143** (inclusive).

- `PortraitNeutral.tga`: the exact **143×143** region, without resizing or alpha modification, placed at the top-left of a **256×256 transparent, 32-bit BGRA TGA** (top-left origin, 8-bit alpha). Vanilla samples it using `SetTexCoord(0,143/256,0,143/256)`. Alliance and Horde variants are intentionally not packaged yet.
- `TextBackground.tga`: **default non-faction dark translucent background**, exact 570×155 crop from source pixels x=1–570 and y=1–155 (inclusive), with untouched black RGB and original alpha, at the upper-left of a transparent 1024×256 TGA. The narrator renders it using `SetTexCoord(0,570/1024,0,155/256)` across its full resizable background; it is *not* the Neutral/Horde/Alliance parchment variant. Its on-screen proportions change with the narrator size.
- `PortraitBg.tga`: a reference extraction of the Talking Heads dark backing, cropped at source (x=572, y=314) and resampled to 128×128. **Not used by the narrator:** the source crop has transparent pixels on its bottom and lower-right edges that exposed the world behind the portrait when stretched to 120×120.

The narrator uses its original `PortraitFrameBackground.blp` for both the main portrait backing and the pause overlay. Its main dark window background now comes from `TalkingHeads-TextBackground`; the Neutral portrait border remains separate. `PortraitFrameAtlas.blp` remains in use for the vertical divider, playback glyphs, and mover. The Neutral frame uses Blizzard's actual geometry: native 143×143 frame relative to 115×115 model, with frame top-left offset (-16,+15) from the model. Those dimensions and offsets are uniformly multiplied by 120/115 to fit our existing 120×120 viewport. No faction-specific parchment backgrounds or animated glow elements are introduced.

The Neutral border has a baked dark outer outline and shadowed inner edge. Unlike the earlier incomplete 128×128 crop, this asset includes the full Blizzard-defined region. Its final on-screen alignment and appearance must still be checked in game.

To switch factions later, package the corresponding atlas region and update only the portrait border texture path.
