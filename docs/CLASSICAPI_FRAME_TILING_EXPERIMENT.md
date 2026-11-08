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
| Fixed left | left x=0..256, y=0..80 | 256x80 | TOPLEFT (-13,+13) |
| Fixed right | right x=72..200, y=0..80 | 128x80 | TOPRIGHT (+34,+13) |
| Natural center continuation | left x=256..512, y=0..80 | up to 256px, 1:1 | x=242 onward |
| Repeating center extension | left x=320..416, y=0..80 | 96px tiles, last one UV-clipped | after first 256px |

The previous vertical extents were 92 (left), 88 (right), and 62
(center). In this pass, all three were first normalized to the left
corner's original **92-unit height**, then trimmed **3 units**, followed by another **3-unit bottom crop** and a **6-unit bottom crop**,
yielding **80 units each**. The top baselines,
horizontal offsets, source X crops, tile widths and resize behavior
are unchanged. The source Y crops now end at 80/512 without stretching.

The right UV crop is offset within its 256px-wide sheet to include the
original right metal cap; directly cropping x=0..128 would omit that cap.
The initial 256px center continues the actual x=256..512 pixels of the
left Quest Log sheet. Only the excess width repeats a comparatively plain
section of the same header. This avoids repeating portrait, parchment,
and inner-panel divider artwork through the middle.

At Compendium width **670** UI units, the exposed middle is 334 units
(x=242 to x=576), corresponding to **256 natural + 78 extended** pixels.
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
   continuation at x=242, and right cap at x=width-94.
2. Check that the Quest Log's top-right metal corner is actually visible.
   The source's cap is inside x=72..200 of its sheet; adjust the crop
   only if in-client evidence requires it.
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
