# ClassicAPI-native resizable Character Frame experiment

**Branch:** `experiment/classicapi-native-frame-tiling` (created from `main`)
**Implementation:** `SoftSpoken/Compendium/UI/PrototypeFrameSkin.lua`
**Reference experiment:** `ui/top-rock-shadow-pass` and its `CHARACTER_HEADER_EXPERIMENT.md`

## Intent

Use Blizzard's *actual* Character Frame left and right artwork as fixed-size
corner pieces, while repeating Blizzard's native FrameGeneral border art across
the variable center. No synthetic gradients, resized corner images, replacement
textures, or screenshot crops.

The old experiment's markdown documented small, seam-aligned crops; its later
code changed them to much larger, overlapping source regions. This branch
starts with the **documented cropped geometry** rather than the oversized
regions, to avoid copying opaque Character Frame interior into the rail.

## Construction

- **Fixed left piece:** stock
  `Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft`,
  source x=0..78/y=0..68 (78x68), at root top-left offset (-14,+12).
  The right edge is x=64, where the middle begins.
- **Fixed right piece:** stock
  `Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight`,
  source x=56..101/y=14..52 (45x38), at top-right (-3,-2).
  The piece overlaps the last 15 pixels of the rail. The generic 33x33
  FrameGeneral top-right cap is omitted **only** on the full-size frame.
- **Resizable center:** the existing `_UI-Frame` title rail is anchored
  from x=64 to width-33, and its title underlay is likewise anchored.
  With ClassicAPI, `SetHorizTile(true)` repeats the natural-width 256px
  source without allocating segments for each resize.
- **Other edges:** unchanged source texture/UVs for the streaks, bottom rail
  and left/right vertical strips, with `SetHorizTile` or `SetVertTile`
  and opposing edge anchors.
- **Backdrop:** unchanged native 256px tiled rock.
- **Portrait ring, book icon, buttons, search, insets and page layout:**
  unchanged.

## Compatibility and scope

ClassicAPI's methods are **optional**. If `SetHorizTile` and
`SetVertTile` are present on the texture object, the full-size frame
builds six anchored native tiles and skips segment reflow entirely.
Without those methods, the **existing pooled manual-segment fallback**
continues to render the rails (but with the same experimental fixed corners).

The compact World Map attachment is **not changed**. Its frame corners,
foreground trim, tiling code and `RefreshCompact` remain as on main.
The interior inset borders also remain untouched.

## In-game verification (NOT yet completed)

1. Open the full-size Compendium with ClassicAPI installed. Check that
   the Character Frame left/right corners render, the close/minimize
   buttons are unobstructed and the center rail has no visible break.
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
