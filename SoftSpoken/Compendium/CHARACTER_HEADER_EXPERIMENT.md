# Blizzard-native resizable header experiment

**Branch:** `ui/top-rock-shadow-pass`  
**Active code:** `SoftSpoken/Compendium/UI/PrototypeFrameSkin.lua`

## Why the previous implementation failed

The fixed-width `UI-Character-General-TopLeft/TopRight` sheets include **opaque window backgrounds**. Repeating their large 120px-high regions in a much wider Compendium duplicated stone patterns and created large rectangular seams at the left, center, right, and bottom of the header.

Moving those opaque sheets up/down could not fix the fundamental problem.

## Current construction

The active prototype restores the original Character Frame texture across the
entire top while keeping its fixed corners and the resizable border system.

1. **Backdrop** — original `UI-Background-Rock-Classic`, unchanged.
2. **Left corner** — `UI-Character-General-TopLeft` x=0..256, y=0..92,
   anchored TOPLEFT (-14,+12); original portrait ring and icon untouched.
3. **Repeating middle** — `UI-Character-General-TopLeft` source x=78..220
   (142px-wide native-size repetitions), y=0..92, anchored at screen x=64,
   y=+12. Reflow tiles to x=width−128 using the pooled texture segments.
   The earlier generic repeating title rail, underlay and streak strips are
   replaced by this experimental Character Frame middle.
4. **Right corner** — `UI-Character-General-TopRight` x=0..128, y=0..76,
   anchored TOPRIGHT (+34,+13), with the approved manual alignment retained.
   The generic top-right cap remains removed; minimize/close controls remain.
5. **Remaining borders** — original `_UI-Frame` lower-edge tile and
   `!UI-Frame` side borders, unchanged.
6. **Resizing** — `OnSizeChanged -> Reflow` and texture pooling retained;
   partial final repeats are source-clipped rather than stretched.

All repeated and fixed segments use unmodified native Blizzard textures, at
1:1 source scale. No custom texture, recoloring, gradients or fake shadows.

## Coordinate checks

| Piece | Source crop | Frame position |
| --- | --- | --- |
| Left fixed corner | x=0..256, y=0..92 | TOPLEFT (-14,+12); spans x=-14..242 |
| Middle repeated strip | x=78..220, y=0..92 | x=64..(width−128), y=+12 |
| Right fixed corner | x=0..128, y=0..76 | TOPRIGHT (+34,+13); spans x=(width−94)..(width+34) |
| Minimize bezel | `UI-Frame` 33×23 | TOPRIGHT (-22,+1), unchanged |

The middle source width is 142px; at a compact width of 340px the span is
148px, requiring two clipped source-sized tiles. At width 670px it is 478px,
and at 1200px it is 1008px. The art extends further than the header join on
both ends intentionally, and the in-game render must be inspected for visible
repetition seams and boundary overlap.

## In-game validation still necessary

Check (a) the repeated Character middle is visible and vertically aligned with both ends, (b) very wide and collapsed widths for repeat seams, (c) whether opaque Character artwork introduces unwanted overlap/seams at the middle joins, and (d) that the left side, search, parchment, navigation, tabs and scrollbars remain unchanged. This is a **code-verified prototype, not a claimed in-game visual pass**.

If the experimental opaque Character middle produces rectangular repetition seams, adjust its source band or the join regions without moving the already-approved fixed corners.

Original Blizzard textures: [Gethe Classic FrameGeneral](https://github.com/Gethe/wow-ui-textures/tree/classic/FrameGeneral) · [PaperDollInfoFrame](https://github.com/Gethe/wow-ui-textures/tree/classic/PaperDollInfoFrame).
