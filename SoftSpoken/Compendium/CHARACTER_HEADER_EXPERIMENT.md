# Blizzard-native resizable header experiment

**Branch:** `ui/top-rock-shadow-pass`  
**Active code:** `SoftSpoken/Compendium/UI/PrototypeFrameSkin.lua`

## Why the previous implementation failed

The fixed-width `UI-Character-General-TopLeft/TopRight` sheets include **opaque window backgrounds**. Repeating their large 120px-high regions in a much wider Compendium duplicated stone patterns and created large rectangular seams at the left, center, right, and bottom of the header.

Moving those opaque sheets up/down could not fix the fundamental problem.

## Current construction

The implementation now respects each Blizzard texture's original purpose:

1. **Continuous backdrop** — original `UI-Background-Rock-Classic` (256px natural tiling), unchanged.
2. **Resizable title rail** — genuine `_UI-Frame` title tile, title underlay, and native dark streaks, tiled in original 256px segments.
3. **Portrait end** — native `UI-Character-General-TopLeft` source x=0..78, y=0..68, fixed at x=-14/y=+12 (one pixel above the existing portrait ring at +11). This ends at screen x=64, precisely where Blizzard's repeatable title tile begins. Existing icon and ring remain above it.
4. **Right cap** — ONLY the existing Blizzard `UI-Frame` 33×33 top-right corner and matching minimize-button bezel. The additional `UI-Character-General-TopRight` crop was removed because it duplicated the right-hand metal geometry and showed a floating corner above the bar. Both remaining end pieces use the existing frame anchors.
5. **Remaining original frame borders** — bottom and vertical strokes, unchanged.
6. **Resize handling** — retained `OnSizeChanged -> Reflow` and reusable texture pool. No new textures created by dragging after pool capacity is reached.

The selected fixed regions remain at 1:1 native source size; no custom TGA, recoloring, gradients, fake shadows, or texture stretching has been introduced.

## Coordinate checks

| Visual component | Source span | Relative screen span |
| --- | --- | --- |
| Left Character ring-side piece | x=0..78 | x=-14..64 |
| Title metal / repeatable center | width=256 tiled | x=64..(width-33) |
| Right native UI-Frame corner | original atlas 33×33 | anchored TOPRIGHT at (0,+1) |
| Existing minimize button bezel | original atlas 33×23 | anchored TOPRIGHT at (-22,+1) |
| Left Character accent vertical anchor | fixed source | y=+12 from root top |

At **minimum compact width ≈340**, native title span = 340−64−33 = 243 (positive). At 670 width it is 573; at 1200 it is 1103. Native tile segments clip to exactly that span.

## In-game validation still necessary

Check (a) that the floating metal rectangle above the right title bar is gone at default width, (b) very wide and collapsed widths for repeat seams, (c) that title-line endpoints meet the native corners without a hairline shift, and (d) that the left side, search, parchment, navigation, tabs and scrollbars remain unchanged. This is a **code-verified prototype, not a claimed in-game visual pass**.

If an endcap's original Blizzard artwork has a baked edge slightly different from the modern native `_UI-Frame` rail, adjust only the small fixed original sprite selection or use the unchanged native FrameGeneral endcap. Do not return to tiling opaque Character window backgrounds.

Original Blizzard textures: [Gethe Classic FrameGeneral](https://github.com/Gethe/wow-ui-textures/tree/classic/FrameGeneral) · [PaperDollInfoFrame](https://github.com/Gethe/wow-ui-textures/tree/classic/PaperDollInfoFrame).
