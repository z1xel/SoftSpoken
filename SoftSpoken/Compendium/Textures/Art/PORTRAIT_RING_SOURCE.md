# Compendium quest portrait ring

This ring comes from the user's `UI-Character-CharacterTab-L1 (1).png` artwork, with **no regeneration or resampling**.

- Original image: 80×80 transparent PNG; visible artwork bounded by x=0..75 and y=0..76.
- `PortraitRing-source.png`: 77×77 transparent, pixel-for-pixel preserved artwork with transparent right-side padding; PNG encoding is lossless.
- `PortraitRing.tga`: 128×128 uncompressed 32-bit TGA with the same 77×77 pixels in its upper-left and transparent padding elsewhere for Vanilla texture loading.
- In-game UVs: `(0, 77/128, 0, 77/128)`; displayed ring dimensions: 77×77 UI units.
- Used for Stories Compendium quest-stage NPC portraits and faction crest fallbacks; no changes to the book/header ring.

Source artwork and overlay are kept separate so the image can be replaced without rewriting the portrait renderer.
