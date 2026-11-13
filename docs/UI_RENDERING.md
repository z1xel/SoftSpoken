# SoftSpoken UI rendering and compatibility

This document describes the **current production UI** on the Vanilla UI fidelity branch.
It replaces the historical Quest Log tiling experiment log. The renderer is
installed as part of SoftSpoken; no prototype addon is needed.

## Compendium

- `SoftSpoken/Compendium/UI/FrameSkin.lua` owns the native 1.12 Compendium frame,
  with fixed Quest Log header corners, a pooled horizontally repeated center
  and native-tiled rails where ClassicAPI supports them.
- `InteriorSkin.lua` owns the two inset rims and search-field artwork.
- `LorePage.lua` and `PagePane.lua` share a single parchment/page construction
  path with the Places map reader.
- `NativeScrollbar.lua` connects the native 1.12 slider to the same owner scroll
  model used by wheel, mouse, keyboard and programmatic navigation. There is no
  second hidden scroll controller.
- `ClassicFrameSkin.lua` remains a deliberate compatibility fallback if the
  native production shell cannot load.
- Runtime images live under `SoftSpoken/Compendium/Textures/Skin` and
  `SoftSpoken/Compendium/Textures/Art`. Reference PNGs and extraction notes live
  under `docs/artwork`, outside the release ZIP.

## Player progress border

`SoftSpoken/UI/PlayerFrame.lua` uses the native Blizzard loading-bar artwork:
two fixed ornate 40-unit endcaps and 32-unit center tiles. Tiles are anchored
**directly to the border frame**, never chained through one another. The silver
treatment uses three masks (two caps, one center) rather than one per tile.
The border is 16 units tall; the gold playback fill is 5 units tall. Native
status-bar duration handling avoids a Lua per-frame audio progress loop.

## Scroll performance and old-client safeguards

- `List:ScrollTo` suppresses the synchronous `OnVerticalScroll` repaint it
  triggers, then redraws and refreshes the native slider once. Real user-driven
  scroll events continue through `OnVerticalScroll`.
- Native scrollbar fallbacks inspect delayed frame geometry no more than every
  0.10 seconds, instead of on each rendered frame. Direct scroll and size
  events still sync immediately.
- Inset rims poll anchored bounds every 0.12 seconds only as a fallback for
  Vanilla child frames that fail to dispatch `OnSizeChanged`. Direct resize
  events still reflow immediately.
- At a hypothetical 60 rendered frames/second, these intervals reduce the
  fallback callbacks from roughly 60/s to at most ~10/s and ~8.3/s respectively.
  This is a **callback-budget comparison, not an in-game FPS benchmark**.

## Source and compatibility constraints

- WoW 1.12 uses Lua 5.0-style frame/event behavior; core tests run with Lua
  5.1 mocks and cannot substitute for an in-game visual pass.
- Asset conversions are packaged as Vanilla-compatible TGA/BLP files.
- Native portrait rendering is capability-gated. The longstanding
  `SoftSpokenClassicPortraits` opt-out is retained; the redundant
  `SoftSpokenExperimentalStaticPortraits` switch was removed.
- Keep alpha gradients restricted to the scroll viewport. Map decorations and
  scroll housings must not inherit its transparency.
- Avoid anchoring repeated pieces to previous tiles: that layout chain caused
  severe resizing stalls on the original UI client.

## Regression checks

- `lua5.1 tests/compendium_book_mask.lua`
- `lua5.1 tests/audio_progress_ui.lua`
- `lua5.1 tests/stories_compendium_portrait_lifecycle.lua`
- `lua5.1 tests/stories_portrait_preloading.lua`
- The audio-pack regression workflow checks the new skin files with `luac5.1`.
- In-game: resize player/compendium through narrow and wide extremes; check
  scroll drag, arrow, wheel, search resets, opening map lore and tab switching.
  Also inspect ring/mask visibility and native portrait fallback on older
  ClassicAPI builds.

The implementation is production code; historical screenshot and extraction
experiments are preserved by Git history, not shipped as runtime dependencies.
