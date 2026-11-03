# Experimental Stories portrait rings

This experimental branch builds on `experiment/classicapi-static-compendium-portraits`
and does not affect `main`.

In the Compendium **Stories** quest detail page, each visible quest stage
shows a circular frame and quest-stage badge matching Spoken's Minimal
Classic speaker-face artwork. When a creature's display ID is available
and ClassicAPI exposes `SetPortraitTextureFromCreatureDisplayID`, the
static native portrait replaces the faction crest. The crest remains
the fallback when the native API or creature information is unavailable.

The native API requires a ClassicAPI build containing the static-portrait
feature; it is not necessarily available in stock releases.

To test:

1. Install that ClassicAPI DLL and the SoftSpoken addon directories from
   this branch, including the `MinimalPortrait*.tga` artwork.
2. Open Compendium → Stories and select a discovered quest with a
   creature giver. Inspect description, progress, and completion stages.
3. Check the ring and badge with both the fallback crest and a generated
   creature portrait. The portrait may arrive asynchronously.
4. Navigate rapidly between quests and use `/reload` to check lifecycle
   and scroll-frame behavior.

Set `SoftSpokenExperimentalStaticPortraits = false` to disable native
portrait requests for that game session while preserving the ring art
and faction-crest fallback. The native path is enabled by default
when the function exists.

Artwork origins are credited in `THIRD_PARTY.md`. This is a
visual-only teaser branch, not a production release.
