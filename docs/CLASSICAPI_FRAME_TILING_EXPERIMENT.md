# ClassicAPI-native resizable Character Frame experiment

**Branch:** `experiment/classicapi-native-frame-tiling` (created from `main`)
**Implementation:** `SoftSpoken/Compendium/UI/PrototypeFrameSkin.lua`
**Reference experiment:** `ui/top-rock-shadow-pass` and its `CHARACTER_HEADER_EXPERIMENT.md`

## Intent

Use Blizzard's *actual* Character Frame left and right artwork as fixed-size
corner pieces, while repeating Blizzard's native FrameGeneral border art across
the variable center. No synthetic gradients, resized corner images, replacement
textures, or screenshot crops.

The first commit tried the old experiment's *small documented crops*, but
that suppressed much of the Character Frame's original appearance.
The current implementation instead restores the **large actual source crops**
from the old branch (the code, not its now-outdated markdown). The opaque
Character Frame details are intentional and take priority over the more
generic FrameGeneral strips beneath them.

## Construction

- **Fixed left piece:** stock
  `Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft`,
  source x=0..256/y=0..92 (256x92), at top-left (-14,+13).
- **Fixed right piece:** stock
  `Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight`,
  source x=0..128/y=0..88 (128x88), at top-right (+34,+13).
  Both fixed source crops share a top baseline. The right art now extends
  to the inset's upper edge.
- **Original-art precedence:** both are on the parent `OVERLAY` layer so
  the Character Frame's native metal/rock overrides underlying repeat strips.
  The icon is drawn later on `OVERLAY`, beneath the subsequently drawn
  portrait ring, so the original opaque artwork does not bury the icon.
  The separate FrameGeneral top-right corner is omitted **only** on the
  full-size frame; the minimize-button bezel remains for now.
- **Resizable center:** the genuine Character Frame **top-left sheet itself**
  supplies the repeatable material. Sample the 64px-wide native source strip
  x=192..256/y=0..92 without stretching or recoloring it, and tile it across
  x=242..(width-94), between the fixed broad corners. Its pooled 64px
  pieces are re-anchored only on resize; the final segment clips its UVs to
  meet the right piece exactly. The generic FrameGeneral title rail,
  underlay and streaks are no longer drawn on the full-size frame.
  This is intentional: the Character Frame must prevail visually.
  ClassicAPI's `SetHorizTile` cannot repeat a *cropped portion* of a
  texture; it would duplicate the whole Character Frame sheet and portrait.
  The center therefore uses a small reusable segment pool even when
  ClassicAPI is installed.
- **Other edges:** only the bottom rail and left/right vertical strips
  remain sourced from FrameGeneral, with `SetHorizTile`/`SetVertTile`
  and opposing edge anchors if ClassicAPI is available. The full-size vertical strips begin at
  window-relative y=62 (the inset panel's top, `VISUAL_GEOMETRY.listTop`),
  with native and manual fallback paths using identical geometry. The native
  left corner covers an additional 18 units into the inset's frame area, which
  is acceptable because the higher-level inset masks that area.
- **Backdrop:** unchanged native 256px tiled rock.
- **Portrait ring, book icon, buttons, search, insets and page layout:**
  unchanged.

## Compatibility and scope

ClassicAPI's methods are **optional**. If `SetHorizTile` and
`SetVertTile` are present on the texture object, the full-size frame
builds three anchored native tiles (bottom/left/right); the original
Character Frame center always uses its own small, pooled, cropped-source
segments so it can retain exact source pixels. Without ClassicAPI, the
existing pooled manual-segment fallback still draws the outer rails.
Both paths use the same original Character source across the header.

The compact World Map attachment is **not changed**. Its frame corners,
foreground trim, tiling code and `RefreshCompact` remain as on main.
The interior inset borders also remain untouched.

## In-game verification (NOT yet completed)

1. Open the full-size Compendium with ClassicAPI installed. Check that
   the **broad original Character Frame rock/metal detail is actually visible**
   on both ends (not just a cropped decorative accent), the close/minimize
   buttons are unobstructed, and the middle rail has no visible break.
2. Resize from the minimum through normal to maximum width, including
   widths just below/above **64px** Character-center tile boundaries.
   Check especially the left join at x=242, right join at x=width-94,
   repeated source-strip seams, and any visible phase mismatch between
   the two original Character source sheets.
3. Resize vertically. Verify both side strips meet their bottom corners,
   the lower rail stays aligned, and the right native art extends down
   to the upper panel inset without showing a generic-metal interruption.
4. Repeat at non-default UI scales.
5. Test without ClassicAPI. Verify the fallback frame still appears and
   remains resizable, and does not call missing texture methods.
6. Collapse to and expand from the World Map attachment. Confirm its
   compact frame remains identical to main and the full header returns.
7. Compare to the old `ui/top-rock-shadow-pass` screenshots for the
   art and junctions; adjust native source strip selection, tiling width
   and corner alignment if the original artwork has a visible join.

**Do not merge on a code-only pass.** The native tiling mechanism is
grounded in ClassicAPI's implementation, but its appearance, source
asset alignment and client behavior still require an actual WoW 1.12
visual check.
