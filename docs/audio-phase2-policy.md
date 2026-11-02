# Audio overhaul — Phase 2 listening policy (development/audio-api)

Status: **branch-only implementation; in-game verification and some choices pending**.
Do not treat the current development branch as a published release.

## Combat behavior (#61 / #73)

The Places options now distinguish **Hold Narration in Combat** and
**Stop Narration in Combat**. Both apply to automatic Places narration only,
not manual Play or Stories/Writings. Default: **both OFF**.

| Hold | Stop | Existing automatically playing Places line | New automatic Places clip |
| --- | --- | --- | --- |
| OFF | OFF | Continues | May start |
| ON | OFF | **Continues** to its native end | Held until combat clears |
| ON | ON | Interrupted and retained for replay from its beginning | Held until combat clears |
| OFF | ON | Invalid: Stop selection implicitly enables Hold; disabling Hold disables Stop | Held |

A cinema independently holds/interrupts auto Places, even when both
combat settings are OFF. Queue advancement remains source-scoped: it may
select a Stories/Writings clip while a Places clip is held.
There is no accurate seek/resume (#59); an interrupted voice restarts in full.

**Migration:** An existing saved `holdCombat=true` meant both Hold and
Stop in the previous release; it is migrated to both ON to preserve
previous behavior. Existing `false` stays OFF/OFF. A fresh character
defaults OFF/OFF (consistent with issue #74).
A one-time migration marker prevents future resets of user changes.
Defaults resets both options to OFF without clearing discovery history.

## Starting-area greeting (#75)

First level-one greeting waits for:
1. Stable location for the original 0.75 seconds.
2. Opening cinematic fully finished (whether watched or skipped).
3. A **1.5-second grace gate** for the queued *initial greeting only*.

The grace is not a global LineGap or clip.delay. A manual clip or another
source remains eligible to play during this period. The initial greeting
is marked `greeted` only on **real playback start**, not enqueue; if
reloaded while queued, the next login can retry. Only one preferred
initial subzone (or a parent fallback) is selected, following the
existing location selection policy.

## Playback controls and truthful states (#66)

- Stop during a line is **not true pause**. ClassicAPI stops that handle;
  Replay restarts the recording from the beginning.
- Only a clip actually **held** is labeled as held in the Large Window.
  A Hold-only combat setting does not label an ongoing line as held.
- `SoundQueue:GetClipState` reports playing, gap, paused, held, queued,
  and absent. The UI bar is metadata-estimated (#60) but completion is
  exclusively governed by native playback state (#57).
- No new seeks, global sound effects toggles, or artificial mid-file resume.

## Queue priority: confirmed manual selection policy (#64)

**Decision (user-approved):** Clicking manual Play during an actively
speaking recording **queues the selection behind it**. It does **not**
interrupt, restart, shorten, or preempt the active recording. Existing
waiting selections retain their order; a repeated Play click for the
same queued key does not duplicate it.

| Incoming action | Policy |
| --- | --- |
| Manual Play while audio is speaking | Append behind the current line and already queued items (FIFO) |
| Repeated manual Play of a queued selection | Keep the existing queued item; no duplicate |
| Manual Play while idle or explicitly paused | Front-start that selection (the prior legacy behavior) |
| Manually requested Places recording and queueLimit=3 | Preserve the explicit selection; trim stale automatic Places entries instead |
| Manually requested clip originally marked low-priority | Treat the explicit Play as normal admission priority; still queue behind the active line |
| Automatic Places (source queueLimit=3) | Enqueue; trim that source's oldest waiting automatic entries |
| Low-priority automatic entry while normal clip exists | Reject low entry |
| Normal entry while low-priority automatic clips wait | Evict waiting low entries; never interrupt speaking audio |
| Writings page continuation | Front-insert during the prior page's terminal callback; never interrupt the playing line |
| Gate-held head (combat/cinematic) | An eligible waiting clip may proceed during the hold; this does not stop live audio |

This is a retention fix for **manual intent**, not a new policy of
manually interrupting other sources. Manual selections may still
wait behind long Writings narration and multiple quest lines.

A queue limit now counts manual waiting entries but never discards them;
if all entries were manually requested, it can temporarily exceed the
autoplay limit. Explicit player choices take precedence over cleanup
of stale locations. Native end-of-clip detection remains the only
authority for transitioning to the next item.

## Audio channels, NPC overlap, and sound-engine constraints (#62 / #63)

The published ClassicAPI v1.18.14 source supports
`PlaySoundFile(file, channel)` with category flags `Master`, `Music`,
`Ambience`, `SFX`. It reports `C_Sound.GetSoundScaledVolume(handle)`
**read-only**, and **does not expose a per-file gain setter** for MP3
streams. Its file-playback bus caps concurrency at two simultaneous files.
Source: [ClassicAPI v1.18.14 sound implementation](https://github.com/brues-code/ClassicAPI/blob/v1.18.14/src/sound/Play.cpp).

SoftSpoken routes narration through `Master` by default. Phase 2 now
offers an **opt-in Narration Channel** selector under the shared Audio
settings: `Master`, `SFX`, `Music`, `Ambience`. This chooses the
ClassicAPI category of each **newly started** file only; it never stops
or reroutes an already owned handle, and does not change any global
game settings. Invalid saved values fall back to Master; a registered
source's explicit channel callback still takes priority.

We are **not** adding a fake independent narration-volume slider:
individual MP3 gain is unsupported, and the selected game category's
effects on actual audio volume still require real-client verification.

**Upstream Turn Other Sounds Down (adapted for Vanilla 1.12):**
The default is **ON**, as upstream. Each supported category is adjusted
independently while a native sound is speaking: Music **30%**, Ambience
**40%**, and SFX **60%** of the player's existing slider positions.
The real 1.12 CVars are `MusicVolume`, `AmbienceVolume`, and
`SoundVolume`. There is **no separate Dialog/NPC Voices slider** in
the original client, so the upstream Dialog 100% control is omitted,
not simulated or folded into a fake slider.

Like upstream `OtherSounds.lua`, there is a 0.8s fade (0.05s steps),
a 1.2s settle delay to avoid pumping between clips, immediate restoration
on logout, crash/reload recovery, and respect for slider changes made
during playback. The category that carries the *active* voice is
never lowered, even if the player changes Narration Channel mid-file.
`MasterVolume` and `MasterSoundEffects` are never modified.

One extra Vanilla safeguard: crash recovery only restores an original
value if the current slider still matches SoftSpoken's last written
value. Existing `SFXDucking` settings from the early prototype migrate
to the upstream-style `LowerOthers` controls without discarding the
user's prior on/off choice. This native mixer has **not yet been
validated in the actual 1.12 game client**.

The effects category includes combat/UI sound as well as some NPC voices.
Independent NPC-only ducking still requires #63 investigation.

**Still requires an actual game-client test matrix:** categories versus
individual game volume toggles; native bus capacity with default NPC
barks; ClassicAPI alone versus with SuperWoW; conflicting audio and
background playback. The ClassicAPI source documents *implementation*,
not tested client configuration.

## Writings page continuation (#65)

Writings' `stopCallback` only triggers `OnPageFinished` when the queue
supplies `finished=true`. Stops, skips, errors, combat interruption, and
source removal must not count as completed pages or close books.
Existing Read Once, manual selection, Stop on Close, and duplicate
ITEM_TEXT_READY behavior remain unchanged. Dedicated Lua 5.1 regression
tests now load the real `Audio.lua` and `Events.lua`.

## Fades, gaps, cues and loudness (#70)

- Ending a **last** line by Stop uses a **400ms** targeted fade.
- Skipping to an already waiting line stops the previous handle
  immediately to avoid unintended simultaneous streams.
- Stop/Replay uses a targeted **400ms** fade; game sound effects are
  untouched. Engine-driven natural endings have no artificial fade.
- Inter-clip pauses use each source's `interClipGap` plus the user's
  `LineGap` for different items. Consecutive Writings pages of the
  same group do not receive that extra generic gap or cue.
- The optional midway line cue retains its opt-in policy.

The timing source for these transitions is **the actual audio end**,
not the voice-pack's estimated duration. Different recording loudness
has not been altered; any voice-pack normalization needs an offline,
measured analysis. No per-stream gain feature is assumed.

## Tests and remaining acceptance

Automated Lua 5.1 regressions:
- `tests/audio_soundutils.lua` (owned handles, native failures, stops/fades)
- `tests/audio_queue.lua` (engine end, cross-source races, gaps, cues)
- `tests/audio_progress_ui.lua` (classic progress/setting)
- `tests/audio_phase2_places.lua` (migration, cinematic/combat, greeting)
- `tests/audio_phase2_writings.lua` (page/close/read-once semantics)
- `tests/audio_phase2_writings_queue.lua` (**real Playlist.lua + audio + events**
  integrated with the ClassicAPI-backed queue; continuation, Stop, missing
  first-page recording, physical reader and cross-module fairness)
- `tests/audio_phase2_diagnostics.lua` (read-only engine/mixer/queue report;
  no numeric handles, file paths, transcripts or global CVar writes)
- `tests/audio_phase2_routing.lua` (all four audio categories × three sources;
  valid settings, overrides, and no global CVar mutation)
- `tests/audio_phase2_ducking.lua` (upstream Music/Ambience/SFX fades,
  protected voice category, settings changes, native 1.12 CVars and recovery)

The exact 1.12 player-only tasks are tracked in
[`audio-phase2-client-validation.md`](audio-phase2-client-validation.md).
Those cases remain **untested in a real client**, even when CI is green.
The #64 manual queue policy is approved and implemented; #62 category
routing is implemented but requires actual channel/mixer verification.
#63 NPC-only ducking is intentionally not fabricated, because ClassicAPI
does not currently expose an independent MP3 gain control or game Dialog
channel on 1.12. Voice-pack loudness normalization is unimplemented.
