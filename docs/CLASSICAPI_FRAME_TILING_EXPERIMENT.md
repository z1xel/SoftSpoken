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
  source x=0..256/y=0..92 (256x92), at top-left (-14,+12).
- **Fixed right piece:** stock
  `Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight`,
  source x=0..128/y=0..76 (128x76), at top-right (+34,+13).
- **Original-art precedence:** both are on the parent `OVERLAY` layer so
  the Character Frame's native metal/rock overrides underlying repeat strips.
  The icon is drawn later on `OVERLAY`, beneath the subsequently drawn
  portrait ring, so the original opaque artwork does not bury the icon.
  The separate FrameGeneral top-right corner is omitted **only** on the
  full-size frame; the minimize-button bezel remains for now.
- **Resizable center:** the existing `_UI-Frame` title rail is anchored
  from x=64 to width-33, and its title underlay is likewise anchored.
  With ClassicAPI, `SetHorizTile(true)` repeats the natural-width 256px
  source without allocating segments for each resize.
- **Other edges:** unchanged source texture/UVs for the streaks, bottom rail
  and left/right vertical strips, with `SetHorizTile` or `SetVertTile`
  and opposing edge anchors. The full-size vertical strips begin at
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
builds six anchored native tiles and skips segment reflow entirely.
Without those methods, the **existing pooled manual-segment fallback**
continues to render the rails (with the same full Character Frame corners).

The compact World Map attachment is **not changed**. Its frame corners,
foreground trim, tiling code and `RefreshCompact` remain as on main.
The interior inset borders also remain untouched.

## In-game verification (NOT yet completed)

1. Open the full-size Compendium with ClassicAPI installed. Check that
   the **broad original Character Frame rock/metal detail is actually visible**
   on both ends (not just a cropped decorative accent), the close/minimize
   buttons are unobstructed, and the middle rail has no visible break.
2. Resize from the minimum through normal to maximum width, including
   widths just below/above 256px tile boundaries. Look for seams,
   cropping changes and a stretched rather than repeated pattern.
3. Resize vertically. Verify both side strips meet their bottom corners,
   and the lower rail stays aligned without stale height measurements.
4. Repeat at non-default UI scales.
5. Test without ClassicAPI. Verify the fallback frame still appears and
   remains resizable, and does not call missing texture methods.
6. Collapse to and expand from the World Map attachment. Confirm its
   compact frame remains identical to main and the full header returns.
7. Compare to the old `ui/top-rock-shadow-pass` screenshots for the
   art and junctions; adjust only the original crops/anchors if needed.

**Do not merge on a code-only pass.** The native tiling mechanism is
grounded in ClassicAPI's implementation, but its appearance, source
asset alignment and client behavior still require an actual WoW 1.12
visual check.
