# SoftSpoken native audio investigations — issues #69, #72, #63, #59, #70

Status: **source-verified, NOT game-client verified**, 2026-11-02.
Branch: `development/audio-api`; no changes to native DLL binaries.

## #69 / #72 — Released SuperWoW and ClassicAPI compatibility

### Releases checked

- **ClassicAPI v1.19.0**, published 2026-11-02; our minimum supported
  **v1.18.14** remains valid. The tagged `src/sound/Play.cpp` is
  **byte-identical** between 1.18.14 and 1.19.0, so no new sound seek
  or pause/resume API was added in this update.
- **SuperWoW 2.2**, latest published release (updated 2026-07-16).
  The published [Features wiki](https://github.com/balakethelock/SuperWoW/wiki/Features)
  documents `BackgroundSound` (0/1) and `UncapSounds` (0/1).
  To raise overall client sound capacity, it also recommends
  `SoundSoftwareChannels` and `SoundMaxHardwareChannels` above their
  restrictive defaults. These are separate from per-file MP3 controls.

### Fundamental distinction: concurrency and ownership

ClassicAPI's `PlaySoundFile(path, channel)` calls the original 1.12
`Play2D` with **bus 3**. [The tagged source](https://github.com/brues-code/ClassicAPI/blob/v1.19.0/src/sound/Play.cpp)
notes this **bus has a two-file concurrency cap**. The engine sound
[definitions](https://github.com/brues-code/ClassicAPI/blob/v1.19.0/src/Offsets.h)
list this bus as one of 13 separately capped categories.

SuperWoW's `UncapSounds` relaxes the general sound-channel cap,
but the public docs **do not prove it overrides PlaySoundFile's
specific bus-3 cap**. Do not promise three simultaneous MP3s or
automatically enable/unlimit game sound settings.

SoftSpoken serializes its own MP3 queue intentionally. A full bus
can still refuse a clip if an unrelated addon is playing files,
which is handled as a failed start (not a phantom active voice).
We have not confirmed if the SuperWoW 2.2 DLL and ClassicAPI v1.19.0
interpose on conflicting sound symbols in a real installation.
Both must be checked on the user's machine.

### Read-only diagnostics added

`Developer:Context()` now shows `SUPERWOW_VERSION` when present
and current values of `UncapSounds`, `SoundSoftwareChannels`,
`SoundMaxHardwareChannels`, and `BackgroundSound` (or
`unavailable`). **It never calls `SetCVar`.** It also reports
ClassicAPI's version and backend health.

### Real-client A/B matrix (required before closing either issue)

1. Install **ClassicAPI alone**; record DLL version and all four
   sound-related CVar values. Confirm Stories, Writings and Places
   narration and narration stop work without touching game SFX.
2. Install **ClassicAPI + released SuperWoW 2.2** (note exact
   SuperAPI if present), with the player's existing sound settings.
   Compare native starts, failed starts, concurrent addon MP3s,
   combat SFX saturation, spoken NPC bark overlap and alt-tab.
3. Change `UncapSounds`/hardware/software channel limits only
   **manually**, if the player wants to A/B the effect. Save baseline
   beforehand and restore after. A general sound-count increase is
   not evidence bus 3 has changed.
4. Test `BackgroundSound` with game focus in/out: report
   whether long narration continues or silently stops, plus
   whether the queue correctly recognizes a real ending.
5. No case can be marked PASS from a Lua mock or these source notes.

## #63 — NPC sound interference

Vanilla has **no independent NPC/Dialog volume slider**. The
upstream-compatible `Turn Other Sounds Down` now fades Music,
Ambience and all SFX, not NPCs alone. This includes combat/UI
effects and is an explicit user-visible tradeoff. Ducking is
not a guarantee that game speech will never overlap.

ClassicAPI **does** expose `MuteSoundFile(path)`,
`UnmuteSoundFile(path)` and `C_Sound.GetRecentSoundFiles()`.
[The native implementation](https://github.com/brues-code/ClassicAPI/blob/v1.19.0/src/sound/Mute.cpp)
suppresses **future file opens** for identified paths across both
2D and 3D sound routes. This suggests a *possible* future
path-specific NPC bark suppression without muting all SFX. However,
a file path alone does not classify an NPC voice, and an unknown
NPC may use multiple variants. It cannot reliably stop a voice
already speaking. Muting arbitrary recent paths or failing to
unmute after narration would damage gameplay. **Do not enable
automatic path muting without a grounded per-NPC file map and
lifecycle tests.** Safe default: ordinary category ducking, no
automatic NPC-path suppression.

If we later build an opt-in path map, verify each NPC bark's path
using `GetRecentSoundFiles`, prevent broad directory masks,
register exact full paths, and guarantee unmute on stop,
combat, module disable, reload, logout and errors. Never mute
SoftSpoken's own MP3s.

## #59 — Real MP3 pause / resume / seek: feasibility

**Verdict for released ClassicAPI v1.19.0 and SuperWoW 2.2: not
available through their public Lua APIs.** The supported per-file
operations are `PlaySoundFile`, `StopSound`,
`C_Sound.IsPlaying`, and read-only scaled volume. They expose
no duration/playhead, seek, handle pause or resume function.
`C_Sound.PlaySoundWithOptions(volumeOverride)` operates on
SoundKit IDs, not arbitrary file-path MP3s.

A true seek extension to ClassicAPI would require **native work**
in the 32-bit 1.12 FMOD stream implementation, not merely a Lua
wrapper:

- Locate the actual FMOD stream and its position/timing methods
  through client disassembly for the exact supported build.
- Determine whether the *engine-owned* sound record can be paused
  without keeping it forever on a two-file-capped bus.
- Track native handle ownership and path hash across stop, resume,
  completion, native allocator reuse and logout. Never dereference
  a freed stream record; ClassicAPI already guards against this.
- Define behavior for a pause in combat and a new manual item
  queued behind a held item, plus end-of-file boundary conditions.
- Expose a narrow validated Lua interface (`PauseOwnedFile`,
  `ResumeOwnedFile` or position query/seek), with version gating.
- Run native in-game tests in long MP3s and conflict cases
  **before** replacing current restart-from-beginning semantics.

Until those prerequisites are met, **Stop/Replay restarts from
the beginning**. Do not present a pretend seekbar or mid-file resume.

## #70 — Voice-pack loudness and metadata audit

The repository contains only a small bundled sample MP3 and
voice-pack **indexes**; the main Spoken / SSS_VOFallback / Turtle
recording collections are not included here. Their actual
loudness cannot be inferred from `len` metadata or copied names.

Added `scripts/audio_pack_audit.py` as an **offline,
non-destructive** tool. It scans installed MP3s, uses ffprobe
for duration, codec and bitrate, and optionally measures each
recording's integrated LUFS, true peak and loudness range with
FFmpeg's loudnorm filter and **null output** (no file writes).
It produces CSV with the pack name and per-file errors:

```powershell
python scripts/audio_pack_audit.py "C:\TurtleWoW\Interface\AddOns" --loudness --limit 100 --csv audio-loudness.csv
```

The initial 100-file limit protects against accidentally decoding
tens of thousands of recordings. Use `--limit 0` for a full
installation scan, after a small representative run.

### One actual MP3 sanity measurement

The bundled `SoftSpoken_Stories/Sounds/og-thrall.mp3` was decoded
read-only with FFmpeg in [GitHub Actions run 41517428718](https://github.com/z1xel/SoftSpoken/actions/runs/41517428718):

| Recording | Length | Codec / bitrate | Integrated loudness | True peak | LRA |
| --- | --- | --- | --- | --- | --- |
| `og-thrall.mp3` | 33.802 s | MP3 / 64 kbps | **-16.73 LUFS** | **-0.93 dBFS** | **9.10 LU** |

This verifies the measurement process and one bundled sample only.
It is **not representative** of the installed Spoken / Combined / Turtle
packs; no across-pack spread or normalization improvement is established.

**No source audio has been modified, gain-normalized, converted
or replaced**. Before recommending a normalization target, collect
a comparable sample from each installed pack (quest, gossip,
female/male voice, Places and Writings); examine LUFS spread,
true-peak clipping and stylistic dynamics. Separate pack-wide
bias from outlier clips. Never claim a before/after improvement
without actual measurements and listening.
