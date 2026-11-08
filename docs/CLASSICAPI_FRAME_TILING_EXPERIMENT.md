# Wide Quest Log shell experiment

**Branch:** `experiment/classicapi-native-frame-tiling` (based on `main`)
**Implementation:** `SoftSpoken/Compendium/UI/PrototypeFrameSkin.lua`
**Status:** code-only experiment; requires in-client visual review.

## Goal

Use the real *wide / dual-pane Quest Log* upper-frame artwork for the
full-size Compendium without stretching any image or changing any
content-panel behavior. Preserve the successful offsets from the previous
Character Frame experiment, its resizable shell, and the existing 1.12
fallback renderer.

The client artwork used is:

- `Interface\\QuestFrame\\UI-QuestLog-Left` (512x512 sheet)
- `Interface\\QuestFrame\\UI-QuestLog-Right` (256x512 sheet)

These are the **original Vanilla 1.12 wide Quest Log files** (confirmed
against extracted client textures), not the *later Classic Era*
`UI-QuestLogDualPane-Left/Right` filenames. Using those later filenames
made the frame invisible on the 1.12 client. They also differ from the
narrow `UI-QuestLog-TopLeft/TopRight` sheets. The code references
the native client files; **no additional texture assets** are shipped.

## Full-size header geometry

| Piece | Native source pixels | On-screen extent | Anchor |
| --- | --- | --- | --- |
| Fixed left | left x=0..256, y=0..71 | 256x71 | TOPLEFT (-13,+13) |
| Fixed right | right x=0..256, y=0..71 | 256x71 | TOPRIGHT (+13,+13) |
| Natural center continuation | left x=256..512, y=0..71 | up to 256px, 1:1 | x=242 onward |
| Repeating center extension | left x=320..416, y=0..71 | 96px tiles, last one UV-clipped | after first 256px |

The three top pieces were normalized to the same height and then
progressively cropped from below: 92 to 89, 86, 80, 74, 73, 72 and
finally **71 units**. Their Y crop now ends at 71/512 without stretching.

The fixed right piece was subsequently expanded horizontally from 128 to
**256 units** (native source x=0..256), and its top-right anchor changed
from (+34,+13) to **(+13,+13)**. It now reaches **243 units into the
frame**, matching the left corner's 256 - 13 = 243-unit reach. Both
sheets still display original pixels at 1:1 scale.

The right sheet now uses its full source width (x=0..256), instead of
the earlier narrower x=72..200 crop. This is a deliberately symmetric
frame-geometry experiment; the actual right cap position needs in-game
visual confirmation.
The initial 256px center continues the actual x=256..512 pixels of the
left Quest Log sheet. Only the excess width repeats a comparatively plain
section of the same header. This avoids repeating portrait, parchment,
and inner-panel divider artwork through the middle.

At Compendium width **670** UI units, the exposed middle is **185 units**
(x=242 to x=427), supplied entirely by the native left-sheet
continuation. Repetition is used only when resizing beyond that span.
The pre-existing 1px left overlap is preserved intentionally.

The fixed source corners are drawn on `OVERLAY` (above the center
`ARTWORK` pieces). The separate old FrameGeneral portrait ring stays
removed; the existing book icon renders inside the Quest Log's own ring.

## What stays unchanged

- Parent `SetBackdrop` with original rock tiling
- ClassicAPI `SetHorizTile/SetVertTile` for the full-size bottom and sides
- Pooled 1.12 manual-tiling fallback when ClassicAPI is not installed
- The compact World Map attachment and its native frame/trim
- List/search/page insets, parchment, buttons, tabs, content, audio

## In-game checks before merging

1. Compare the Compendium at 670 UI units alongside Turtle WoW's built-in
   wide Quest Log. Inspect the left portrait-to-rail join, center
   continuation at x=242, and right artwork start at x=width-243.
2. Verify that the newly full-width right sheet is visibly aligned
   correctly. Its ornamental cap is not necessarily on the source's far
   right pixel, so verify its appearance rather than assuming that
   symmetric anchors guarantee symmetric ornament position.
3. Check the natural-to-repeating transition (approximately x=498 at
   default width) for a visible seam or repeated material pattern.
4. Drag the window through minimum, default and maximum widths; test
   non-default UI scale and a height resize.
5. Repeat with ClassicAPI disabled to verify manual side/bottom tiling.
6. Collapse and expand the Compendium from the World Map. The compact
   frame should be identical to the branch's pre-Quest-Log behavior.

**Do not merge without a client-side visual pass.** Asset availability
and exact appearance in the Turtle 1.12 client are not confirmed by a
GitHub diff. If the Quest Log's native join is off by a few pixels,
modify only fixed crops/UVs or the repeat-source choice before altering
the proven frame anchors.

## Historical context

Earlier commits in this branch used the Character Frame sources
`UI-Character-General-TopLeft/TopRight` and a 64px repeating crop.
Those experiments established the working fixed corner offsets
(-13,+13) and (+34,+13), which this Quest Log pass preserves.
