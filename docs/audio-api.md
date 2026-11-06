# Audio API baseline (development/audio-api)

This document records the **initial ClassicAPI-first playback backend** for
[#55](https://github.com/z1xel/SoftSpoken/issues/55), especially
[#72](https://github.com/z1xel/SoftSpoken/issues/72),
[#56](https://github.com/z1xel/SoftSpoken/issues/56),
[#57](https://github.com/z1xel/SoftSpoken/issues/57), and
[#58](https://github.com/z1xel/SoftSpoken/issues/58).
It is development guidance, **not** a change to the published v0.8.1-beta release.

## Required client extension

- **Baseline: ClassicAPI v1.18.14 or newer** (`CLASSIC_API_VERSION >= 11814`).
  This is an intentionally conservative **documented release baseline**, not
  a claim that older releases could never support these APIs.
- This was checked against the tagged [ClassicAPI v1.18.14 native sound source](https://github.com/brues-code/ClassicAPI/blob/v1.18.14/src/sound/Play.cpp)
  and the [release](https://github.com/brues-code/ClassicAPI/releases/tag/v1.18.14).
- The runtime checks the version constant and the presence of
  `PlaySoundFile`, `StopSound`, and `C_Sound.IsPlaying`. If these are absent
  or too old, SoftSpoken refuses narration admission with a versioned error
  instead of treating a Vanilla playback result as a usable handle.
- **Progress bar tiers:** v1.19.0+ exposes native duration-driven status bars;
  **v1.19.1+ is recommended** for correct status-fill geometry and spark
  anchoring. The playback transport still accepts v1.18.14+, using a static
  progress estimate when native duration objects are unavailable.
- **OctoWoW:** enable ClassicAPI through the **launcher Mods tab** before
  starting the client. An `!!!ClassicAPI` addon folder alone does not prove
  the native extension is active. For manually managed Vanilla clients,
  follow the [ClassicAPI installation instructions](https://github.com/brues-code/ClassicAPI#installation)
  (including VanillaFixes/`dlls.txt` when applicable).
  SoftSpoken does not package or modify the DLL.
- Later ClassicAPI releases may work, but compatibility with any specific
  installed launcher build or second native extension must be verified in game.

## API contract used here

| API | Meaning |
| --- | --- |
| `PlaySoundFile(path, channel)` | Returns `willPlay, soundHandle`; handle is a positive number on success. `Master`, `Music`, `Ambience`, `SFX` supported. |
| `StopSound(soundHandle, fadeMs)` | Targeted stop; fade is **milliseconds**. No global sound CVar reset. |
| `C_Sound.IsPlaying(handle)` | Boolean play-state query used by #57's guarded poll; not a time-position/seek API. |
| `CLASSIC_API_VERSION` | Version encoded as major×10000 + minor×100 + patch. |

ClassicAPI's internal stop implementation tracks its own started sound records.
SoftSpoken additionally owns each handle in a per-clip Lua table, so another
clip's or a fabricated handle cannot be passed through its stop utility. The
association is removed on stop or natural queue completion. The native API
does not report whether a `StopSound` call actually found a still-playing
sound; a successful Lua call alone does not prove that it stopped one.

## Engine-driven completion and lifecycle (#57 / #58)

Each accepted clip has a playback-attempt token, an owned ClassicAPI handle,
and an explicit lifecycle state: `waiting`, `held`, `starting`, `playing`,
`gap`, `paused`, `interrupted`, `finished`, `failed`, or `removed`.
A single one-shot poll runs every **0.15 seconds** while playing.
`C_Sound.IsPlaying(handle)` determines end-of-voice, not `clip.length`.
An initial **0.45-second** grace and **two consecutive false readings**
protect against delayed initialization and transient false responses.
Eight consecutive native query failures cause a controlled clip failure;
a **one-hour watchdog** is the last-resort safeguard for a handle that
appears stuck forever. Both paths drop the affected clip and move on.

When the engine confirms completion, the queue releases its handle and
transitions to `gap` before running the existing inter-clip gap and cue
policy. Stale poll and gap timers compare the clip identity and attempt
token before acting; callbacks can no longer complete a later playback
attempt or a replacement clip.

Queue mutations are serialized around lifecycle notifications.
Stop callbacks (including Writings page continuation), disabled sources,
low-priority eviction, and Stop All cannot accidentally start a new clip
halfway through an earlier clip's terminal events. Stop All/Stop Source
also reject same-scope requeues from stop callbacks.

**Progress display remains metadata-estimated**, but its rendering now uses
ClassicAPI's **native duration-driven StatusBar** (v1.19.0 or newer):
`C_DurationUtil.CreateDuration()`, `duration:SetTimeFromStart()`, and
`bar:SetTimerDuration(..., Immediate, ElapsedTime)`. The track, gold hairline,
and 1.12 CastingBar spark preserve the existing Large Window appearance.
There is no per-frame Lua width update. The native status-bar fill geometry
also lets the spark stay attached to its edge (v1.19.1+ fixes that geometry).

The audio backend still supports ClassicAPI v1.18.14+. On older releases
without the duration API, the StatusBar displays the most recently provided
static estimate rather than attempting to bind an unavailable native timer.
**v1.19.1+ is recommended for the animated progress indicator**; this does not
change the minimum requirement of the audio transport.

`SoundQueue:Share` and `VoiceElapsed` still supply the duration estimate;
`C_Sound.IsPlaying` alone controls completion. A one-shot guard switches the
native bar to a static 98.5% cap near the metadata end while audio continues,
and a progress-only queue notification displays the final share on entry into
the post-voice gap. Missing duration metadata leaves an empty track. Pause
freezes the share, Replay binds a fresh duration, and book-page spans start
at their existing aggregate offset. Voice Only hides the bar. The transcript
continues to remain visible until native playback actually ends.
Real resume/seek remains unsupported (#59); Pause interrupts and
Resume restarts the recording.
The ClassicAPI handle API cannot unambiguously distinguish an old
finished handle from a newly allocated sound using a reused native
pointer; the grace/debounce and watchdog mitigate symptoms but in-game
stress testing is still required.

### Test coverage

The deterministic `tests/audio_queue.lua` harness mocks the native
sound engine and AceTimer scheduler, including short/long/zero/nil
metadata, rejected playback, false-status debounce, repeated query
errors, watchdog, stop+poll races, gap cancellation, callback-driven
Writings continuation, Pause/Resume with combat gates, cross-source
Stop/Skip, priority admission, Stop All and reentrant callbacks.

## Important user-facing behavior change

Legacy 1.12 cannot independently mute NPC dialogue. Previously SoftSpoken
implemented *Silence NPC Voices* by switching `MasterSoundEffects` off and
immediately on, which interrupts unrelated game audio. This has been removed.
The nonfunctional toggle is hidden in legacy settings pending #63; there is
**no claim that NPC barks are ducked in the meantime**. Modern-client
dialogue muting is left intact.

## SuperWoW coexistence: verification still needed

The public SuperWoW release and ClassicAPI are both native client extensions.
Source descriptions alone do **not** establish that their hooks safely
coexist. The #72 acceptance matrix still requires testing the **released**
versions, with ClassicAPI alone and with SuperWoW, on the actual target
client. In particular, test simultaneous MP3s, handle reuse, changing zones,
combat SFX saturation, minimized/background playback, loading order, and
whether either DLL replaces `PlaySoundFile`, `StopSound` or `C_Sound`.
Do not claim this compatibility is verified before in-game testing.

## Tests and remaining acceptance

- [x] Backend guards and real owned-handle transport implemented.
- [x] Remove global `MasterSoundEffects` reset from playback/legacy dialogue paths.
- [x] Add isolated mock-ClassicAPI regression test `tests/audio_soundutils.lua`.
- [ ] Exercise playback, stop, fade, skip, gate interruption, shutdown and
      failed file/channel on a real 1.12 client with ClassicAPI v1.18.14+.
- [ ] Repeat with ClassicAPI **and** released SuperWoW; record exact versions.
- [x] Implement engine-driven completion, gap states and queue race guards (#57 / #58).
- [x] Run deterministic mock engine and timer regressions in Lua 5.1.
- [x] Restore upstream-style Large Window progress and optional Show Progress Bar toggle (#60).
- [x] Test estimation, pause/replay, missing metadata, Voice Only and UI layout.
- [ ] Verify real MP3 decode startup, sound handle reuse, and under-load concurrency on the game client.
- [ ] Verify real Stories/Places/Writings interaction and UI timing (#60).

Run the mock regression from the repository root:

```sh
lua5.1 tests/audio_soundutils.lua
lua5.1 tests/audio_queue.lua
lua5.1 tests/audio_progress_ui.lua
```
