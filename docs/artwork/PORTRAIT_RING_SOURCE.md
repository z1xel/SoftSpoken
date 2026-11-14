# Compendium quest portrait ring

Source: user-provided `UI-Character-CharacterTab-L1 (1).png` artwork, restored from commit `0ed6bc866d49894c50fd94389c23cf6aaa09c448`, with no regeneration or resampling.

- Original artwork: 80×80 PNG; visible area x=0..75, y=0..76.
- [`compendium/PortraitRing-source.png`](compendium/PortraitRing-source.png): 77×77 RGBA PNG with original artwork pixels preserved and transparent padding.
- Runtime `SoftSpoken/Compendium/Textures/Art/PortraitRing.tga`: 128×128 RGBA TGA with the same 77×77 pixels in the top-left and transparent padding for Vanilla.
- Texture UVs remain `(0, 77/128, 0, 77/128)` and the **current** renderer displays the ring at **68×68 UI units**, centered on the 62×62 portrait.
- Used over Stories Compendium quest-stage NPC portraits and faction-crest fallbacks.
- No changes to header art or book icon.

The texture files are restored to the previous CharacterTab version. The current renderer's size and centered position are intentionally retained.
