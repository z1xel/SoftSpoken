# Original Blizzard Character Frame: resizable top-header experiment

**Branch:** `ui/top-rock-shadow-pass`

**Implementation:** `SoftSpoken/Compendium/UI/PrototypeFrameSkin.lua`

The Compendium's top uses original Blizzard textures loaded by the game client. The source crop is now taller (120 UI units) so the top stone is not abruptly cut in the visible header:

- `Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft` (256x256)
- `Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight` (128x256)

The original portrait icon, circular metal ring, close/minimize buttons, frame dimensions, backdrop and all page geometry are unchanged. No exported image assets, color tints, artificial shadows or Turtle Shop composites are used.

## Repeated center and fixed ends

The *fixed left* uses source x=65..220 and y=0..120 from Character TopLeft, rendered at screen x=54..209. Its new 10px left extension sits behind the existing portrait ring; the ring and icon stay unchanged.

The *middle* uses source x=128..220 and y=0..120 from the same Character TopLeft, repeated as a 92px native-resolution tile from x=209 to (window width - 96). It is driven by the existing pooled `tiled()` code.

The *fixed right* uses source x=0..96 and y=0..120 from Character TopRight. It anchors to the window's right end and follows any width change. Existing Blizzard close/minimize artwork stays above it.

All three are positioned 26 UI units above the root frame top. This preserves the original on-screen alignment of the previous source y=20..90 at +6; it simply includes the missing upper/lower source pixels. Their lower source boundary is beneath the existing Compendium insets, where it should not appear as a horizontal crop. Both end pieces remain at 1:1 source aspect ratio while resizing. The unchanged `OnSizeChanged -> Reflow()` callback only changes how many center tiles are visible.

## What to test in-game

1. Compare at default Compendium width against the Character Frame reference.
2. Resize very wide and inspect the repeated middle for visible seams. The source was not authored as a repeating tile: **the center is experimental, not guaranteed seamless**.
3. Collapse and expand (the compact-width midsection is short). Check both ends do not overlap.
4. Verify the added 10px of genuine ring-side stone integrates with the original portrait ring and introduces no second ring or detached rectangular edge.
5. Check the right end with minimize, close, hover and pressed states.
6. Check that search, navigation, parchment, tabs and scrollbars remain unchanged.

If a seam or edge misaligns, use an in-game screenshot to refine these **source crop boundaries only**. Do not add generated shadows, gradients, tints or fake brown shading.

### Restore original

Switch the Git repository back to `main`; no changes have been made to main. Do not merge this branch unless the in-game inspection passes.

### Original artwork reference

[Gethe Classic PaperDollInfoFrame](https://github.com/Gethe/wow-ui-textures/tree/classic/PaperDollInfoFrame)
