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
| Fixed left | left x=0..256, y=0..75 | 256x75 | TOPLEFT (-13,+13) |
| Fixed right | right x=0..200, y=0..75 | 200x75 | TOPRIGHT (+34,+13), cap at frame edge |
| Natural center continuation | left x=256..512, y=0..75 | up to 256px, 1:1 | x=242 onward |
| Repeating center extension | left x=346..442, y=0..75 | 96px tiles, last one UV-clipped | after first 256px |

The three top pieces were normalized to the same height and then
progressively cropped from below: 92 to 89, 86, 80, 74, 73, 72 and
finally **71 units**, before uncropping 4 units to **75 units**. Their Y crop now ends at 75/512 without stretching.

The original right sheet's metal end cap sits near source x=166,
not at its rightmost edge. The right corner now uses **one continuous,
unstretched texture crop x=0..200** at anchor **(+34,+13)**. Its end cap
therefore stays at the frame's right edge: 34 - (200 - 166) = 0.
The corner extends **166 units inward**, using the available original
pixels rather than repeating source material with an extra texture object.
The previous 77-unit right-side extension has been removed.

The initial 256px center continues the actual x=256..512 pixels of the
left Quest Log sheet. Only the excess width repeats a comparatively plain
section of the same header. The repeat crop was shifted right by 26 source
units total (x=320..416 to x=346..442); its 96-unit width, tiling positions,
and the 256-unit initial continuation stay unchanged. This avoids repeating
portrait, parchment, and inner-panel divider artwork through the middle.

At Compendium width **670** UI units, the exposed middle is
**262 units** (x=242 to x=504): 256 original source pixels and
a 6-pixel repeat. The single native right sheet begins at x=504,
and its metal end cap remains at the right frame edge.
The pre-existing 1px left overlap is preserved intentionally.

The fixed source corners are drawn on `OVERLAY` (above the center
`ARTWORK` pieces). The separate old FrameGeneral portrait ring stays
removed; the existing book icon renders inside the Quest Log's own ring.

## Lower shell one-unit geometry adjustments (twice)

The Compendium's **bottom edge and entire lower structure have moved up
two real UI units in total** relative to the unchanged 75-unit Quest Log
header, in two successive one-unit revisions. This is a physical height
reduction, not simply moving artwork over an unchanged frame.

- The actual window height, minimum height and maximum height each
  decrease by **2 total**. The default geometry metadata is now 598
  (originally 600); the minimum is 428 (originally 430).
- The initial centered window is offset upward by **1 UI unit total**,
  so its **top screen position stays unchanged** after the reduction.
  During manual resizing, the existing `PinTopLeft()` path keeps that
  same top anchored.
- The shared list inset's top distance becomes **60** (originally 62).
  Its bottom distance stays 6. Both resolved vertical edges therefore
  move up by 2 total without changing the panel height.
- The page inset is anchored to the list's top and the window's bottom,
  so it translates by the same 2 units total. Its marble, border, page
  viewport, and scrollbars follow their parent frames automatically.
- The native/fallback outer vertical rails start 2 units higher (60
  instead of 62); their lower ends follow the shortened frame and
  retain their original lengths.
- Bottom corners, frame border, character-style bottom tabs, their
  hit targets, and the resize grip already anchor to the window's
  bottom, so they move up by 2 total without separate offsets.
- **Untouched:** all three Quest Log header textures and their 75-unit
  crops, portrait icon, title, minimize/close controls, and search
  field with its own controls.
- Saved-height migration uses `lowerShellShiftV1` and
  `lowerShellShiftV2` to track the two revisions. An already-migrated
  V1 character is reduced by only 1 additional unit; an unmigrated
  character by 2 total. Repeated `/reload` does not shrink again.

Verify the old and new screenshot framing at the same UI scale,
plus full-size/compact transitions, min/max resize, all three page
types and their scrollbars. No in-client geometry result is claimed
from the code change alone.

## Right-page scrollbar one-unit horizontal adjustment

The shared page scrollbar's 31-unit **housing** moves 1 UI unit right,
from right offset -4 to -3 relative to its page inset. At the default
670-unit Compendium width, the slot now spans x=636..667 (previously
x=635..666). Slider, thumb, arrow buttons, marble track, texture caps,
and mouse targets follow the same housing automatically. The left scrollbar,
parchment holder, page viewport, frame size, and vertical geometry do not
change. Both the shared Compendium page and standalone lore reader use
the same page-scroll skin.

## Four-zone bottom fade for the three-piece Quest Log header

The existing 75-unit header (y=-13..62) uses four adjacent spatial
ClassicAPI mask regions. Two TGA alpha profiles are reused: 68 fully
opaque + 7 smooth fade, and 65 fully opaque + 7 faster fade + 3 fully transparent.

- **First panel:** x=4 through x=305, two units inside the first
  panel's right edge x=307: **68/7** (unchanged).
- **Gap:** x=305 through x=334, the second panel's left inset edge:
  **65/7/3** (faster fade).
- **Second panel:** x=334 through x=windowWidth−31 (x=639 at width 670):
  **68/7** (new). The second panel's parchment-visible right edge is
  x=windowWidth−29 (x=641), so the split is 2 units to its left.
- **Right-hand strip:** x=windowWidth−31 through
  x=windowWidth−3 (x=639..667 at width 670): **65/7/3** (faster fade).
  This preserves the existing overall mask limit at the right edge of
  the page scrollbar housing.

The second panel's left edge is anchored 27 units to the right of the
list inset's right edge by `PagePane.CreatePagePane`. The parchment
visual's right edge is 29 units left of the window's right edge by
`PrototypePageSkin.Apply`. The masks reuse those geometry values
(`g.listSlotRightOffset` and `g.pageRightInset`) so the page region
grows with window resizing and the 2-unit right inset remains constant.

Two TGA assets are used:
`QuestLogHeaderBoundedBottomFadeLeft.tga` for 68/7 (unchanged) and
`QuestLogHeaderBoundedBottomFade.tga` for 65/7/3 (alpha profile updated).
The second texture preserves the original opaque 65 units and its smooth
fade shape, but compresses the fade into 7 units; the final 3 units have
zero alpha. Both files retain fully opaque side-edge columns. Four positioned
`CreateMaskTexture` regions are necessary because their alpha profiles
must **replace**, not multiply, across the horizontal zones. Both TGAs
have fully opaque side-edge columns and CLAMP sampling. The fixed
left header texture receives one mask, fixed right receives two, and
each pooled center tile receives three once at allocation. Maximum
per-texture mask count is three (below ClassicAPI's seven-mask limit).

No changes to title/portrait, header crop coordinates, other window
geometry, scrollbars, background, or fallback behavior.

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
