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

The 75-unit fade-mask footprint (y=-13..62) uses four adjacent spatial
ClassicAPI mask regions, anchored independently of the artwork.
The left fixed header artwork displays 256 of its native 512 vertical
source pixels instead of 75 (an additional 181 UI units downward), at the
same 1:1 pixel scale and unchanged top anchor. Center tiles and the right
header remain 75 units tall. All four fade masks retain their 75-unit
footprint; a new independent clear-extension mask, attached only to the
fixed left corner artwork, spans the full 256-unit height over the first
panel's existing horizontal mask range (x=4..305 at default width).
Its alpha is 255 for the first 75 units and 0 for units 75..256 across
the interior; its opaque edge columns allow neutral CLAMP sampling outside
that range. Thus the original 68/7 fade is unchanged, and the extended
181-unit region is explicitly masked off.

Two TGA alpha profiles are reused: 68 fully
opaque + 7 smooth fade, and 66 fully opaque + 9 smooth fade to full transparency.

- **First panel:** x=4 through x=305, two units inside the first
  panel's right edge x=307: **68/7** (unchanged).
- **Gap:** x=305 through x=334, the second panel's left inset edge:
  **66/9**.
- **Second panel:** x=334 through x=windowWidth−31 (x=639 at width 670):
  **68/7** (new). The second panel's parchment-visible right edge is
  x=windowWidth−29 (x=641), so the split is 2 units to its left.
- **Right-hand strip:** x=windowWidth−31 through
  x=windowWidth−3 (x=639..667 at width 670): **66/9**.
  This preserves the existing overall mask limit at the right edge of
  the page scrollbar housing.

The second panel's left edge is anchored 27 units to the right of the
list inset's right edge by `PagePane.CreatePagePane`. The parchment
visual's right edge is 29 units left of the window's right edge by
`PrototypePageSkin.Apply`. The masks reuse those geometry values
(`g.listSlotRightOffset` and `g.pageRightInset`) so the page region
grows with window resizing and the 2-unit right inset remains constant.

Four TGA assets are used:
`QuestLogHeaderBoundedBottomFadeLeft.tga` for 68/7,
`QuestLogHeaderBoundedBottomFade.tga` for 66/9,
`QuestLogHeaderLeftClearExtension.tga` for first-panel transparency
from unit 75 to 256, and `QuestLogHeaderLeftEdgeVerticalFade.tga` for
the decorative strip x=-13..4 (new): 100% opaque through unit 68,
then a gradual, nearly linear fade to 0% opacity at unit 256.
The second texture is fully opaque through 66 units, then follows a
9-unit smooth fade to zero alpha at the bottom of its 75-unit extent. Four positioned fade-mask regions are necessary because their
alpha profiles must **replace**, not multiply, across the horizontal zones.
The first extension mask clears the first-panel area below its 68/7 fade;
the new sixth mask slowly fades only the previously unmasked left strip.
Both are attached exclusively to the fixed left header texture, preserving
the 68/7 region without resampling. All four TGAs have fully opaque side-edge
columns and CLAMP sampling. The fixed left header texture now receives three
masks, fixed right receives two, and each pooled center tile receives three
once at allocation. Maximum per-texture mask count remains three (below
ClassicAPI's seven-mask limit).

This step adjusts only the shared gap/right-strip fade from 65/8/2 to
66/9, without changing its 75-unit mask footprint or the horizontal
region boundaries. The two 68/7 masks, left-only clear extension, slow
left-edge fade, artwork, scrollbars, and window geometry are unchanged.

## Sliding top-right corner: 32-unit 2D feather experiment

The existing right header (`UI-QuestLog-Right`, source x=0..200) remains
200 × 75 UI units, right-anchored with x=+34 and y=+13. At a default
670-unit window width, its left edge is at x=504 and its right edge is at
x=704, exactly as before. It still follows resizing from the right.

The repeating center uses the same 1:1 source pixel mapping and artwork
layers as before, but now extends an additional **32 units** underneath
the fixed right header by reducing `QUESTLOG_CENTER_END_MARGIN` from
166 to 134. At width 670, the center therefore covers x=242..536
(previously x=242..504), with the new overlap at x=504..536.

The new `QuestLogHeaderRightLeftFeather.tga` is a 256×128 uncompressed
32-bit RGBA alpha mask spanning only the 200×75 fixed-right texture.
Its leftmost **32 UI units** use a smoothly eased horizontal transparent-to-
opaque blend, with additional 12-unit top and bottom easing localized to
this 32-unit strip. The other 168 UI units remain fully opaque. This mask
multiplies with the pre-existing **68/7** and **66/9** vertical masks on
the right texture. The right texture is on OVERLAY, while the center
tiles remain on ARTWORK beneath it.

Only the right texture gains this extra mask, for three total; the four
vertical mask regions, the left-edge slow fade, and left clear extension
are unchanged. Center tile pooling, window resize behavior, and both
native-tiling and manual fallback code paths remain intact.

This change is isolated in a single commit above the previous branch
head, so it can be reverted independently if in-game visuals reveal
unexpected seams or a visibly repeated texture pattern.

## What stays unchanged

- Parent `SetBackdrop` with original rock tiling
- ClassicAPI `SetHorizTile/SetVertTile` for the full-size bottom and sides
- Pooled 1.12 manual-tiling fallback when ClassicAPI is not installed
- The compact World Map attachment and its native frame/trim
- List/search/page insets, parchment, buttons, tabs, content, audio

## In-game checks before merging

1. Compare the Compendium at 670 UI units alongside Turtle WoW's built-in
   wide Quest Log. Inspect the left portrait-to-rail join, center
   continuation at x=242, and the 32-unit feather beneath the right
   artwork (x=width-166..width-134).
2. Confirm the right metal end cap remains beside the close/minimize
   buttons. There is no longer a second right-side texture or join.
3. Check the natural-to-repeating transition (approximately x=498 at
   default width) and the feathered overlap (x=504..536 at width 670)
   for a visible seam or repeated material pattern.
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
