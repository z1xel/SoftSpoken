# Compendium quest portrait ring

The image is a direct pixel copy of the user's edited Vanilla TargetFrame ring, **not AI-generated art**.

- `PortraitRing-source.png` — editable 77×77 transparent source, losslessly re-encoded.
- `PortraitRing.tga` — 128×128 uncompressed 32-bit BGRA TGA, top-left origin. The 77×77 original pixels occupy its top-left corner; remaining pixels are transparent.
- WoW 1.12 texture coordinates: `0, 77/128, 0, 77/128`. Display size: 77×77 UI units.
- Used only for Stories quest-stage portraits (`QuestPage_112.lua`), above the 2D face/crest.
- ClassicAPI's existing book-portrait circle mask clips the underlying icon, where that API is available.

The Compendium window's header/book icon and other frame art are deliberately unchanged.
