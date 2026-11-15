# NPC Voice Before Reading — Vanilla sound timing

This feature runs on the original WoW 1.12.1 client with ClassicAPI. It must
not depend on modern Dialog-channel CVars and never modifies volume settings.

## Limits of live completion detection

ClassicAPI v1.18.14 C_Sound.GetRecentSoundFiles() reports up to 64 recent
distinct paths with start times (milliseconds on the GetTime clock) and muted
flags. Its native hooks record a path BEFORE asking the engine to open it:
a recent entry does NOT guarantee the sound was audible. The API does not
return native playback handles in this list.

C_Sound.IsPlaying(handle) can check a known handle but cannot link the
recent file path to its native handle. SOUNDKIT_FINISHED tracks sounds an
addon starts with runFinishCallback enabled, not Blizzard NPC greetings.
Scanning arbitrary sound-handle addresses is unsafe.

Implementations:
https://github.com/brues-code/ClassicAPI/blob/v1.18.14/src/sound/Mute.cpp
https://github.com/brues-code/ClassicAPI/blob/v1.18.14/src/sound/Play.cpp

A future native completion API would need to associate the sound file path
with the handle returned by the native sound opener and safely track its end.

## Current method

1. Hold the quest and gossip narration sources on the first NPC window
   of a visit, while preserving the existing gossip-to-quest visit guard.
2. Read recent ClassicAPI sound paths immediately and briefly recheck twice
   if an eligible greeting has not appeared.
3. Match against the precomputed Vanilla 1.12 NPCSounds greeting-slot paths.
4. When matched, estimate the end from the recorded file start time,
   duration, and 0.12-second padding. This is NOT true live completion.
5. If the API or a match is absent, fall back to 2.5 seconds.
6. Never manipulate sound CVars, scan speculative handles, or let this
   optional feature interrupt voice-pack discovery.

## Measurements and provenance

The lookup comes from:
https://github.com/Xian55/tortoise-db-viewer/blob/main/scripts/data/sound-map.json
(the 'vanilla' profile; durations extracted with ffprobe)
and
https://github.com/fondlez/wow-sounds/blob/main/vanilla/wow-sounds-ALL-vanilla-1.12.1.5875.csv
(original Vanilla 1.12.1 file-path catalog).

The source extraction is a reference dataset, not necessarily byte-identical
to every Vanilla-based client's sound archive. It also records file duration,
not the exact native stream completion time. Only paths present in the
original 1.12.1 file listing are included; Outland and Turtle custom sounds
are excluded. The addon distributes metadata, not any audio files.

The generated lookup contains 598 DISTINCT original Vanilla paths.
Unweighted per-file duration distribution:
- mean: 1.55 seconds
- median: 1.34 seconds
- 90th percentile: 2.54 seconds
- 95th percentile: 3.04 seconds
- 2.5-second fallback covers 89.5% of these durations

A stricter sample requiring "greet" in BOTH the sound kit name and file
path produces 558 kit/take observations (some files can recur across kits).
Of these observations, 2.5 seconds covers 92.7%. Distinct files are the
more conservative metric for an unbiased file-level count. None of this
represents the actual frequency with which players encounter NPC voices.

Regenerate with:
python scripts/generate_vanilla_greeting_lengths.py PATH_TO_SOUND_MAP_JSON PATH_TO_VANILLA_CSV

## In-game acceptance tests still pending

- Test on original 1.12 client with ClassicAPI v1.18.14 or later.
- With the feature enabled, interact with several ordinary human and orc
  NPCs; the estimated wait should release sooner on short recorded greetings.
- Test longer named-NPC greetings (Thrall, Cairne) for overlap.
- Test an NPC with no known greeting, a missing API, and muted audio:
  fallback should be 2.5 seconds without Lua errors.
- Test a gossip-to-quest transition and rapid changes between NPCs;
  no duplicate delays, early reading, or indefinitely held clips.
- Confirm installed voice packs register after reload, and no obsolete
  Sound_* channel CVars are accessed.
- Temporarily log observed file/time during client acceptance testing to
  establish that the adaptive path matches actual Vanilla playback.

The adaptive timing is experimental until verified in-game.
