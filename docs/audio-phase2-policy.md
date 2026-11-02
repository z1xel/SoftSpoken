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

## Queue priority: current behavior, approval required (#64)

**No behavioral change in this pass.** A deliberate user decision is
needed before changing the existing source-neutral policy:

| Incoming action | Current behavior |
| --- | --- |
| Manual Play when an unpaused clip already occupies the queue | Append behind currently playing/held audio (may wait) |
| Manual Play when queue is paused or idle | Put manually requested clip at front; start it |
| Automatic Places (source queueLimit=3) | Enqueue; trim that source's oldest waiting entries |
| Low-priority entry while normal clip exists | Reject low entry |
| Normal entry while low-priority clips are waiting | Evict waiting low entries; do not interrupt speaking clip |
| Writings continuation | Front-insert next page during prior page's completion callback |

A preferred future policy could prioritize explicit manual Play, but
interrupting Stories or long Writings without approval would be a
significant change. See #64.

## Audio channels, NPC overlap, and sound-engine constraints (#62 / #63)

The published ClassicAPI v1.18.14 source supports
`PlaySoundFile(file, channel)` with category flags `Master`, `Music`,
`Ambience`, `SFX`. It reports `C_Sound.GetSoundScaledVolume(handle)`
**read-only**, and **does not expose a per-file gain setter** for MP3
streams. Its file-playback bus caps concurrency at two simultaneous files.
Source: [ClassicAPI v1.18.14 sound implementation](https://github.com/brues-code/ClassicAPI/blob/v1.18.14/src/sound/Play.cpp).

SoftSpoken continues routing narration through `Master` by default;
we are **not** adding a fake narration-volume slider or changing the
user's global SFX/music/ambience settings.
The legacy client does not have a separate Dialog channel. The old
global-`MasterSoundEffects` reset has been removed (#56).
An NPC may still speak over SoftSpoken narration; safe ducking requires
native support and real-client verification before implementing #63.

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

**Before closing issues or merging:** in-game validation on a real 1.12
client for combat reentry, settings toggles during a speaking line,
cinematic skip/watch, startup greeting, multiple books, fade transitions
and simultaneous Stories/Places/Writings with released ClassicAPI DLL.
#64's manual priority policy and #62/#63 channel/ducking limitations
still need explicit resolution.
