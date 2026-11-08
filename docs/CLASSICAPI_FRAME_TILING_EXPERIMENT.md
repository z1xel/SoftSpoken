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
| Fixed right | right x=0..200, y=0..71 | 200x71 | TOPRIGHT (+34,+13), cap at frame edge |
| Natural center continuation | left x=256..512, y=0..71 | up to 256px, 1:1 | x=242 onward |
| Repeating center extension | left x=320..416, y=0..71 | 96px tiles, last one UV-clipped | after first 256px |

The three top pieces were normalized to the same height and then
progressively cropped from below: 92 to 89, 86, 80, 74, 73, 72 and
finally **71 units**. Their Y crop now ends at 71/512 without stretching.

The original right sheet's metal end cap sits near source x=166,
not at its rightmost edge. The right corner now uses **one continuous,
unstretched texture crop x=0..200** at anchor **(+34,+13)**. Its end cap
therefore stays at the frame's right edge: 34 - (200 - 166) = 0.
The corner extends **166 units inward**, using the available original
pixels rather than repeating source material with an extra texture object.
The previous 77-unit right-side extension has been removed.

The initial 256px center continues the actual x=256..512 pixels of the
left Quest Log sheet. Only the excess width repeats a comparatively plain
section of the same header. This avoids repeating portrait, parchment,
and inner-panel divider artwork through the middle.

At Compendium width **670** UI units, the exposed middle is
**262 units** (x=242 to x=504): 256 original source pixels and
a 6-pixel repeat. The single native right sheet begins at x=504,
and its metal end cap remains at the right frame edge.
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
   continuation at x=242, and right artwork start at x=width-166.
2. Confirm the right metal end cap remains beside the close/minimize
   buttons. There is no longer a second right-side texture or join.
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
