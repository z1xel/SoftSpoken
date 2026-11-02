# Audio API baseline (development/audio-api)

This document records the **initial ClassicAPI-first playback backend** for
[#55](https://github.com/z1xel/SoftSpoken/issues/55), especially
[#72](https://github.com/z1xel/SoftSpoken/issues/72) and
[#56](https://github.com/z1xel/SoftSpoken/issues/56).
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
- Load the extension with VanillaFixes, placing `ClassicAPI.dll` next to
  the client and listing it in `dlls.txt` (see [installation instructions](https://github.com/brues-code/ClassicAPI#installation)).
  SoftSpoken does not package or modify that DLL.

## API contract used here

| API | Meaning |
| --- | --- |
| `PlaySoundFile(path, channel)` | Returns `willPlay, soundHandle`; handle is a positive number on success. `Master`, `Music`, `Ambience`, `SFX` supported. |
| `StopSound(soundHandle, fadeMs)` | Targeted stop; fade is **milliseconds**. No global sound CVar reset. |
| `C_Sound.IsPlaying(handle)` | Boolean play-state query, planned for #57. Not a time-position/seek API. |
| `CLASSIC_API_VERSION` | Version encoded as major×10000 + minor×100 + patch. |

ClassicAPI's internal stop implementation tracks its own started sound records.
SoftSpoken additionally owns each handle in a per-clip Lua table, so another
clip's or a fabricated handle cannot be passed through its stop utility. The
association is removed on stop or natural queue completion. The native API
does not report whether a `StopSound` call actually found a still-playing
sound; a successful Lua call alone does not prove that it stopped one.

**This patch deliberately leaves `SoundQueue`'s metadata-duration timers
unchanged.** A clip may still end too early or too late due to incorrect
metadata until #57 implements engine-driven completion. Timer-driven progress,
pause semantics and queue reentrancy are addressed in #57, #58 and #60.

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
- [ ] Implement authoritative real-playback completion in #57.

Run the mock regression from the repository root:

```sh
lua5.1 tests/audio_soundutils.lua
```
