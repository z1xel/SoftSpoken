# Compendium quest portrait ring

Source: user-provided `UI-Minimap-Border (1).png`, a standalone Blizzard-style minimap ring, 155×155 PNG.

- `PortraitRing-source.png` — 77×77 RGBA PNG, cropped to the nontransparent bounds of the uploaded image (152×152) and downscaled to 77×77 with Lanczos interpolation. This is a resize of the original image, **not regenerated artwork**.
- `PortraitRing.tga` — 128×128 RGBA TGA with the 77×77 ring in the upper-left and transparent padding elsewhere, for Vanilla texture loading.
- In-game UVs: `(0, 77/128, 0, 77/128)`; displayed ring dimensions: **68×68 UI units**, centered on the 62×62 portrait. The UV region remains 77×77 image pixels.
- Used as an overlay on Stories Compendium quest-stage NPC portraits and faction-crest fallbacks in `SoftSpoken_Stories/Compendium/QuestPage_112.lua`.
- No change to the book/header icon. The portrait renderer retains a centered 68-unit overlay, independently of the 77-pixel source file.

The uploaded source image is available separately in the source ZIP from the companion chat, and the rendered ring is a user-supplied texture, not AI generated.
