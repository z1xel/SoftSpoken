# Original Blizzard Character Frame: resizable top-header experiment

**Branch:** `ui/top-rock-shadow-pass`

**Implementation:** `SoftSpoken/Compendium/UI/PrototypeFrameSkin.lua`

The Compendium's top uses original Blizzard textures loaded by the game client. The source crop is now taller (120 UI units) so the top stone is not abruptly cut in the visible header:

- `Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft` (256x256)
- `Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight` (128x256)

The original portrait icon, circular metal ring, close/minimize buttons, frame dimensions, backdrop and all page geometry are unchanged. No exported image assets, color tints, artificial shadows or Turtle Shop composites are used.

## Repeated center and fixed ends

The *fixed left* now uses original Blizzard Character TopLeft source x=0..220 and y=0..120, at the **native portrait frame origin x=-14, y=+11**. This restores the complete left corner and ensures that the embedded original ring and the existing icon/overlay ring occupy the same coordinates.

The *middle* continues to use original Character TopLeft source x=128..220 and y=0..120, repeated as a 92-unit strip between the fixed ends. At compact width (~340), its available length is about 6 UI units, so neither end needs to overlap.

The *fixed right* now uses **the entire 128px source width** x=0..128 from Character TopRight (previously truncated at 96px) and y=0..120, right-anchored at full native pixel width.

The previous header was artificially raised **26 UI units**, while the approved portrait ring is raised only **11 UI units**. The corrected source artwork now shares the ring's +11 vertical anchor. This shifts the actual character art downward by 15 UI units into the existing title bar position without moving the Compendium title, buttons, or content. Both ends remain at 1:1 native scale.

## What to test in-game

1. Compare at default Compendium width against the Character Frame reference.
2. Resize very wide and inspect the repeated middle for visible seams. The source was not authored as a repeating tile: **the center is experimental, not guaranteed seamless**.
3. Collapse and expand (the compact-width midsection is short). Check both ends do not overlap.
4. Verify the complete native left corner aligns with the existing portrait icon/ring, with no duplicate ring or detached vertical seam.
5. Check the right end with minimize, close, hover and pressed states.
6. Check that search, navigation, parchment, tabs and scrollbars remain unchanged.

If a seam or edge misaligns, use an in-game screenshot to refine these **source crop boundaries only**. Do not add generated shadows, gradients, tints or fake brown shading.

### Restore original

Switch the Git repository back to `main`; no changes have been made to main. Do not merge this branch unless the in-game inspection passes.

### Original artwork reference

[Gethe Classic PaperDollInfoFrame](https://github.com/Gethe/wow-ui-textures/tree/classic/PaperDollInfoFrame)
