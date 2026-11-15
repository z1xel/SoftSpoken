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

## Current method and interaction classification

An absent Vanilla `npc` unit token is ambiguous, not proof of an object.

With **NPC Voice Before Reading** enabled:

1. Positive NPC evidence (an existing NPC token/name or a creature GUID)
   starts the full greeting wait. An explicit game-object or player GUID
   bypasses it.
2. When type is unresolved, gate narration for up to **0.20 seconds** and
   recheck every **0.05 seconds**. If still unresolved, release narration
   WITHOUT the 2.0-second fallback. Do not cache a fake NPC visit.
3. For confirmed NPCs, inspect ClassicAPI's recent sound-file paths and
   timestamps and find a known Vanilla greeting in the offline duration map.
4. On a match, estimate the end from start time, file duration and
   0.12-second padding. This is NOT a live playback-completion signal.
   Lowercase the file path before removing its "sound/" prefix; otherwise
   ClassicAPI "Sound\\..." paths miss the length lookup.
5. If a confirmed NPC has no sound-file match, wait **2.0 seconds** instead.
   This shorter compromise covers ~78.3% of the 598 unique file durations.
6. Preserve the gossip-to-quest same-visit guard; do not manipulate volume,
   probe arbitrary sound handles, or interrupt voice-pack discovery.

A separately bounded classification gate prevents a timer ordering race from
releasing narration just as the last NPC check runs. A confirmed NPC may
initially have no name or GUID; it is not cached under a fake identity.

With the setting OFF (default), audio overlap is intentional and narration
must not be held.

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
- 2.0-second fallback covers 78.3% of these durations

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
- Test a **confirmed NPC** with no known greeting or missing history API:
  fallback should be 2.5 seconds without Lua errors.
- Test an object quest and an absent NPC token: neither should incur the
  2.0-second fallback. A fully unknown interaction may wait up to 0.2 seconds.
- Test an NPC token resolving within 0.2 seconds of event: full greeting
  estimate should begin from the original event timestamp.
- Test the setting OFF: never gate playback.
- Test a gossip-to-quest transition and rapid changes between NPCs;
  no duplicate delays, early reading, or indefinitely held clips.
- Confirm installed voice packs register after reload, and no obsolete
  Sound_* channel CVars are accessed.
- Temporarily log observed file/time during client acceptance testing to
  establish that the adaptive path matches actual Vanilla playback.

The adaptive timing is experimental until verified in-game.

Regression harness (run from repository root with Lua 5.1+):

    lua tests/greetingfirst_classification.lua

## Native NPC greeting volume

Original Vanilla NPC greetings play as sound effects, controlled by the
SoundVolume CVar. They do not have a separate Dialog slider. Core SoftSpoken
narration normally uses the ClassicAPI Master channel.

SoftSpoken's OtherSounds mixer lowers SoundVolume (and optionally music and
ambience) only when narration actually starts. There is no volume change
when beginning the greeting gate. The original 1.2s volume-restoration settling period is intentionally
unchanged. A greeting can therefore still encounter residual attenuation
from a previous recording; addressing this requires a separate design and
is not part of the greeting timing fix.
