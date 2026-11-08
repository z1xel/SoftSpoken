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
| Fixed right | right x=0..256, y=0..71 | 256x71 | TOPRIGHT (+90,+13), cap at frame edge |
| Rightward-art left extension | right x=0..77, y=0..71 | 77x71 | TOPRIGHT (-166,+13), ends where original sheet starts |
| Natural center continuation | left x=256..512, y=0..71 | up to 256px, 1:1 | x=242 onward |
| Repeating center extension | left x=320..416, y=0..71 | 96px tiles, last one UV-clipped | after first 256px |

The three top pieces were normalized to the same height and then
progressively cropped from below: 92 to 89, 86, 80, 74, 73, 72 and
finally **71 units**. Their Y crop now ends at 71/512 without stretching.

The right sprite has a crucial quirk: its metal end cap sits near **source
x=166**, not at the right edge of its 256px-wide image. Expanding the
cropped sprite to 256px and anchoring it at (+13,+13) wrongly moved the
metal end cap about **77 units to the left**. That mistake is corrected
by anchoring the unscaled full sheet at **(+90,+13)**, which restores
source x=166 to the window's right edge.

The original sheet reaches **166 units** inward from the cap. To make the
right corner reach the same **243 units** as the left without moving the
ornament, a separate **77x71** crop from the right sheet's neutral x=0..77
header is placed directly to the left (its right edge at x=width-166).
Both textures retain their native 1:1 dimensions. The extra section
is deliberately repeat-like art and its seam requires a screenshot check.
The initial 256px center continues the actual x=256..512 pixels of the
left Quest Log sheet. Only the excess width repeats a comparatively plain
section of the same header. This avoids repeating portrait, parchment,
and inner-panel divider artwork through the middle.

At Compendium width **670** UI units, the exposed middle remains
**185 units** (x=242 to x=427), supplied entirely by the native
left-sheet continuation. The right extension fills x=427..504, and
the native right sheet begins at x=504. Repetition is only required
for the middle on widths greater than its natural continuation.
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
2. Verify that the right metal end cap has returned beside the
   close/minimize buttons. Inspect the join between the added 77px
   extension and the original 256px right sheet at x=width-166.
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
