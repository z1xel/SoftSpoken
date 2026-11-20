# Audio modernization — development history

> Historical development record for `development/audio-api` prior to its squash merge into `main`. This document describes **what changed and why**, including experiments subsequently replaced. It is not a claim that every combination has been tested on a real client.

**Development period:** November 2–7, 2026  
**Pre-document branch head:** [`6c58218f227a`](https://github.com/z1xel/SoftSpoken/commit/6c58218f227a97439fc2dbe0861ff4c99a63ba6c)  
**Base before integration:** [`13f7da470bda`](https://github.com/z1xel/SoftSpoken/commit/13f7da470bda21c9885fd409bd890fbe7e87c9d3)  
**Scope before this document:** **160 branch-specific commits**, **42 changed files**, 4,789 added lines and 412 removed lines compared with `main`. The commit adding this historical document follows those 160 commits.  
**Historical comparison:** [pre-merge base → audio branch](https://github.com/z1xel/SoftSpoken/compare/13f7da470bda21c9885fd409bd890fbe7e87c9d3...6c58218f227a97439fc2dbe0861ff4c99a63ba6c) · [individual branch commits](https://github.com/z1xel/SoftSpoken/commits/development/audio-api/)

## Executive summary

The core goal was to modernize SoftSpoken's audio subsystem for original World of Warcraft 1.12 using the actual capabilities of ClassicAPI. The original port inherited much of upstream Spoken's organization, but metadata-based duration estimates, client-specific sound behavior, and weak isolation between interruption paths could produce premature completion, overlapping narration, or unintended game-sound interruption.

The modernization retains the shared **Sources → SoundQueue → SoundUtils** architecture while introducing native sound-handle ownership and real engine completion detection. It then extends that foundation through narrator progress, Writings and Places lifecycle behavior, manual queue policy, per-category audio ducking, deterministic voice-pack fallback, diagnostics, and test coverage.

The branch includes many intentionally incremental commits: an early approach may have been replaced later (for example, Lua-updated progress replaced by native StatusBar; SFX-only ducking replaced by three-category mixing). **The final source tree, not every intermediate commit, is the authoritative implementation.**

## Chronological overview

| Phase | Commits | Period | Main subject | Issues |
| --- | ---: | --- | --- | --- |
| 1 | 19 | Nov 2 | Native playback and queue lifecycle | #56, #57, #58, #72 |
| 2 | 13 | Nov 2 | Narrator progress and transcript correctness | #60 |
| 3 | 30 | Nov 2 | Combat, book continuation, queue policy | #61, #64, #65, #66, #73, #75 |
| 4 | 43 | Nov 2 | Narration routing and three-category mixing | #62, #63 |
| 5 | 18 | Nov 2 | Pack selection, diagnostics, MP3 auditing | #67, #69, #70, #72 |
| 6 | 19 | Nov 3 | Runtime fallback and native StatusBar | #60, #67 |
| 7 | 14 | Nov 6 | In-game bug fixes and race hardening | #58, #65 |
| 8 | 4 | Nov 6–7 | Merge preparation and legacy-code cleanup | pre-merge |
| **Total** | **160** | **Nov 2–7** | **Audio modernization prior to this document** | |

Of these 160 development commits, 123 were committed November 2, 19 November 3, 16 November 6, and two November 7 (dates recorded by GitHub's committer timestamps). The branch also contains commits inherited from `main`; those are **not** part of the 160.

## Phase 1 — ClassicAPI transport and real queue lifecycle (19 commits)

The first phase established the new audio foundation:

- **Owned handles**: `SoundUtils` tracks the ClassicAPI handle returned by `PlaySoundFile` for each clip; `StopSound` applies only to that clip's owned handle. Neither arbitrary nor invented handles are trusted.
- **No global SFX reset**: removed the prior global `MasterSoundEffects` muting mechanism. Vanilla 1.12 does not expose a separate, independently controllable NPC Dialog channel.
- **Real completion**: the active recording's `C_Sound.IsPlaying(handle)` state, not `clip.length`, determines when voice ends. An estimated duration remains useful for UI and transcript timing, not for completion.
- **Guarded polling**: the native status is checked approximately every 0.15 seconds, with a 0.45-second startup grace, two consecutive false readings for ending, bounded query failures, and a last-resort one-hour watchdog.
- **Race protection**: an incrementing per-clip playback-attempt token invalidates old polls and scheduled gap callbacks. Queue mutation guards serialize reentrant stop callbacks, clip admission, removal, and Writings continuation.

Representative commits: [native handle ownership](https://github.com/z1xel/SoftSpoken/commit/7939baa3fc807e14d945ff42e494899dc31db25a); [explicit clip lifecycle](https://github.com/z1xel/SoftSpoken/commit/124d17890afce14ae8198bb712d45fb26a442321); [serialized queue mutation](https://github.com/z1xel/SoftSpoken/commit/f90a73888f38d7e0ee4bdd33fa2ad0b4a7d2f6fd); [engine-driven completion](https://github.com/z1xel/SoftSpoken/commit/b1309075cf473ab035fb9c39aeee961372440b80); [Stop All / interruption race fixes](https://github.com/z1xel/SoftSpoken/commit/6eb90884821b21ebaac145adbcf1dfc71c076437).

**Result:** a single shared queue reacts to actual native playback, without guessing that MP3s end when their metadata says they should.

## Phase 2 — Narrator progress and transcript accuracy (13 commits)

Restored an upstream-inspired Warcraft-style thin gold progress hairline in the Large Window narrator and added **Show Progress Bar**. Progress was deliberately metadata-estimated while native sound-state remained the authority for completion.

The transcript was changed to remain visible while the engine still reports active playback, even if the recording's stated length expires. Additional cases covered missing/zero metadata, Stop/Replay, grouped book pages, Voice Only, and the original 1.12 frame/texture anchor geometry.

This first version **manually updated the progress texture in Lua** and was later superseded in Phase 6 by ClassicAPI's native duration-driven StatusBar.

Representative commits: [initial UI progress](https://github.com/z1xel/SoftSpoken/commit/be18a090634d097f2b23737c7b11a676227bc811); [transcript retention](https://github.com/z1xel/SoftSpoken/commit/a2ac5805b6bb3ac0f3f8bc91e907e7f17de78987); [progress layout correction](https://github.com/z1xel/SoftSpoken/commit/a5f36c023f0fd8de9f0563bb35afaa229823371f).

## Phase 3 — Playback policies across the three content modules (30 commits)

Established consistent player-facing behavior rather than independent module-specific playback rules:

- **Manual selection**: a manually selected Story, Place, or Writing does not cut off an already speaking line; it queues behind existing narration. Manual requests survive automatic Places backlog trimming.
- **Held clips and gates**: combat/cinematic holds prevent new applicable narration; a held head must not block unrelated playable sources. Reopening gates retries held clips.
- **Places combat controls**: split the earlier combat preference into **Hold During Combat** and **Stop During Combat**, including migration of old settings and truthful UI indicators.
- **Fresh-character greeting**: apply starting-location stabilization, cinematic considerations, and mark the greeting delivered on actual playback rather than mere admission.
- **Writings**: verify native-end-driven transitions between book pages, Compendium continuation, reader-page playback, stopping, and closing.
- **UI truthfulness**: distinguish actively playing, waiting, paused and combat-held states; don't claim a manual Play immediately started when it only queued.

Representative commits: [Places Hold/Stop split](https://github.com/z1xel/SoftSpoken/commit/85f4e7d397c9bae2ac7b70b9373790fdf8802fd6); [startup greeting handling](https://github.com/z1xel/SoftSpoken/commit/6ac27609591089b034ed0ccff7c5c71a9fa4e199); [manual queue preservation](https://github.com/z1xel/SoftSpoken/commit/c3881755b4f26a88b16053dc3ee0e07fa395b79a); [integrated Writings playlist regression](https://github.com/z1xel/SoftSpoken/commit/7cacbbf70e44a81efb7a893ccc87131e67d09b55); [read-only diagnostics](https://github.com/z1xel/SoftSpoken/commit/d85fed4f720ff1f4d69097be1fdbfaf86ac465cd).

## Phase 4 — Channel routing and game-sound ducking (43 commits)

First added configurable ClassicAPI narration routing: **Master** by default, optionally **SFX, Music, or Ambience**. Each file uses the chosen category at start, and changes to settings apply to subsequent starts.

An early optional SFX-only volume-reduction prototype was then **replaced** by an adaptation of upstream Spoken's `OtherSounds.lua`. The completed Vanilla mixer independently fades **Music, Ambience and SFX**, using default multipliers of 30%, 40% and 60% for other sound, while protecting the category in which narration itself is playing.

The mixer preserves the player's original volume baselines, respects manual slider changes, restores values after narration, and stores conservative crash/reload recovery snapshots. It does not toggle the global SFX enable flag or claim to mute individual NPC voices.

Representative commits: [configurable narration routing](https://github.com/z1xel/SoftSpoken/commit/7839b1438d49908071bcaf2f5316fe262a808f54); [upstream multi-channel port](https://github.com/z1xel/SoftSpoken/commit/0a3b86ff4e0e3e6b759ab2e80b8f2f93c505229e); [restore upstream mixer defaults](https://github.com/z1xel/SoftSpoken/commit/1b6e0e2ac2e4ea5195e36825142fd32a97d7a438); [user volume override](https://github.com/z1xel/SoftSpoken/commit/9093d2c3c4b6a7d2cacf7cd2eaf51a4a6e904dba); [mixer regression tests](https://github.com/z1xel/SoftSpoken/commit/524f6513ba33f7e378bd0995ea2c792351dfffaa).

**Important supersession:** the first SFX-only approach is not a separate final mixer alongside the upstream port.

## Phase 5 — Deterministic voice packs, native investigation, and diagnostics (18 commits)

Improved how Stories, Places and Writings choose candidates from installed voice-pack registries. Selection is deterministic where multiple packs overlap; malformed filenames and invalid metadata do not silently override valid recordings; durations may be missing without preventing otherwise valid audio from playing.

Added read-only diagnostics for ClassicAPI capabilities, sound categories, relevant CVars, SuperWoW detection, and shared queue state. Investigated released native extensions for MP3 concurrency, seeking, NPC barks and coexistence.

Added `scripts/audio_pack_audit.py`, a **non-destructive** FFmpeg/ffprobe utility for batch inspection of audio metadata, loudness and peaks, plus automated tests and a bundled MP3 sanity measurement. **No audio is transcoded or normalized as part of this work.**

Representative commits: [Places pack precedence](https://github.com/z1xel/SoftSpoken/commit/32663a0ba966304a49493b3b7e05510db2e9b0f1); [Writings pack validation](https://github.com/z1xel/SoftSpoken/commit/b0ad75716b0bafbdaa9383cf1f666440f38654a5); [Stories fallback validation](https://github.com/z1xel/SoftSpoken/commit/48ab06d3be86dbcc2e5c7d2e5692ae898e010c6b); [native-extension diagnostics](https://github.com/z1xel/SoftSpoken/commit/a359fb2806f23f535333385c17cf3e8ffc40b5cb); [MP3 audit tool](https://github.com/z1xel/SoftSpoken/commit/42f7677255d206ca648f4976883da9234ae9c138).

## Phase 6 — Runtime fallback and native StatusBar (19 commits)

The queue now retains ordered voice-pack alternatives so that if native `PlaySoundFile` rejects the preferred recording, it can attempt other indexed candidates for that same line. This was integrated across Stories, Places and Writings; Writings also updates the displayed text when a fallback changes language. Retries through the candidate list are bounded to avoid unbounded work in a frame.

Separately, the manual Lua-driven progress renderer from Phase 2 was replaced by ClassicAPI's **native duration-driven StatusBar**, using `C_DurationUtil.CreateDuration` and `StatusBar:SetTimerDuration`. The native animation preserves the hairline styling and spark. Near an underestimated duration's end, a one-shot guard holds the displayed fill around 98.5% until native playback really completes. Older ClassicAPI releases without the duration API retain a static estimate instead.

Representative commits: [ordered runtime alternatives](https://github.com/z1xel/SoftSpoken/commit/f673aadc19491798c0fc1024c08b8703d49965b6); [failed-start fallback](https://github.com/z1xel/SoftSpoken/commit/76e2dddd846e79baa84f5970a701cd865352b3b9); [Writings transcript on fallback](https://github.com/z1xel/SoftSpoken/commit/1c13fa64560cd51c41d028f336790511b0ee44e3); [native progress bar](https://github.com/z1xel/SoftSpoken/commit/791dc7bd71f421205fbc5f5cbe7833749a0a74dd); [native progress tests](https://github.com/z1xel/SoftSpoken/commit/6a33aebe1bcdba8ae6e4520545bcbe6c3d562f06).

**Limitation:** a rejected MP3 start does **not** prove the file is missing. ClassicAPI's two-file stream bus can also reject a perfectly valid file when at capacity. The current code tries alternate paths and may ultimately classify the start as missing; it does not provide a general delayed capacity retry.

## Phase 7 — Real-client bugs and targeted fixes (14 commits)

Actual in-game testing revealed three particularly valuable regressions:

1. **Compendium first page showed page progress instead of whole-book progress.** The first recording was enqueued before its book-wide `span` was assigned. Initialize span before admission so the first page binds the correct native timer. Physical in-world readers still track the currently visible page only. [Fix first-page span timing](https://github.com/z1xel/SoftSpoken/commit/c80aee91bcecf85247795e57289fa1af156caf0f).
2. **Rapid Stop/Replay or physical page turns eventually silenced narration and closed the window.** A fade-out kept the previous MP3 stream occupying ClassicAPI's two-file bus; quick replacements could exhaust capacity. Immediate replacements now hard-stop the old stream before starting another, while ordinary final-stop fades remain. [Stop/Replay stream fix](https://github.com/z1xel/SoftSpoken/commit/9d292782e36b70c9dcd6d9a0b037b5dbcf516e6e); [rapid book-page fix](https://github.com/z1xel/SoftSpoken/commit/76183bae04ef2021fe6a773614bced8c49099b05).
3. **A new book inherited a stopped state after removing the last paused queue entry.** The queue-wide pause flag survived an empty queue. Final-clip removal now clears it, and fresh admission recovers from stale persisted pause state. [Fix stale queue pause](https://github.com/z1xel/SoftSpoken/commit/c443bd20aea42bd112aff293d43fe5080be391ff).

Each fix received targeted mock-engine or real-playlist regressions before this branch was considered a merge candidate.

## Phase 8 — Stabilization and merge preparation (4 commits)

- Aligned `Environment.lua` version metadata with the four published `v0.8.1-beta` TOC manifests, updated ClassicAPI/OctoWoW guidance, and cleaned up CI trigger coverage. [Version/CI cleanup](https://github.com/z1xel/SoftSpoken/commit/d7619dd2c7294aa1b87dd1f7e569cdd5db6f63c0).
- Merged `main` into the development branch through an ordinary **two-parent merge**, preserving the latest README installation guidance and associated artwork. [Sync main](https://github.com/z1xel/SoftSpoken/commit/67b7d9cb8163c2c422e17675ed802007daa1a335).
- Removed unreachable Vanilla dialogue-muting internals and the fake pre-enqueue `TestSound` probe that always returned true; eliminated old producer flags, a hidden setting, and unused branches. Kept relevant public upstream compatibility stubs inert to avoid missing-method errors. [Remove dead dialogue mute / probe](https://github.com/z1xel/SoftSpoken/commit/283eecf754c853e130d844f3cafe0af4c19129a5); [Remove obsolete producer flags](https://github.com/z1xel/SoftSpoken/commit/6c58218f227a97439fc2dbe0861ff4c99a63ba6c).

The shared queue shrank from approximately 1,016 to **940 lines** while preserving its native playback, priority and interruption semantics. No speculative queue-lifecycle rewrite was performed: correctness and proven behavior took priority over shorter or more fragmented code.

## Final architecture after modernization

```text
Stories (quests / gossip)   Places (zones / autoplay)   Writings (books / pages)
            \                       |                      /
                 registered Sources / clip metadata
                                |
                       SoundQueue.lua
          FIFO · manual priority · holds · gaps · callbacks
          token-guarded polling · synchronized mutation
                                |
                       SoundUtils.lua
                owned ClassicAPI sound handles
                   Play / Stop / IsPlaying
                                |
                       ClassicAPI / WoW 1.12

   Side subscribers: PlayerFrame + Transcript (UI/progress)
                     OtherSounds (category-volume ducking)
                     Developer (read-only diagnostics)
```

The core queue deliberately remains centralized. The three source modules provide domain-specific text, audio candidates, policies and book/zone/quest interactions. `SoundUtils` remains the transport boundary; only it should operate on native playback handles. UI progress stays informational and must never determine clip completion.

### Invariants that must remain true

1. A currently speaking line is not interrupted by unrelated manual selection; manually requested clips are not discarded as stale automatic backlog.
2. Native `C_Sound.IsPlaying` determines completion; metadata may be wrong or missing.
3. Pausing **stops** the stream; Replay starts it again from the beginning because true MP3 seek/resume is unavailable.
4. Old polls, stale gap timers and callbacks cannot complete a later clip or playback attempt.
5. Source-scoped stopping must never stop an unrelated source's owned handle.
6. Writings Compendium progress spans the work, but the in-world reader follows individual pages.
7. Immediate replacements release the outgoing file slot; final-stop fades must not make quick replacements fail.
8. The player’s independent SFX/music/ambience preferences and unrelated game sounds are preserved.
9. An empty queue does not leave a saved pause state that blocks the next request.

## Test coverage and validation status

The branch adds **11 test files (2,370 added test lines)**, **four audio design/validation documents**, the MP3 audit script, and an audio transport CI workflow; it also expands the existing audio-pack workflow.

The principal automated suites cover:

- `tests/audio_soundutils.lua`: native handle ownership, invalid handles, start failures, safe stops, backend minimum.
- `tests/audio_queue.lua`: native end polling, timer races, mutation reentrancy, source selection, rapid controls, bus contention simulation, stale pause cleanup.
- `tests/audio_progress_ui.lua`: native progress rendering, cap, Voice Only and layout state.
- `tests/audio_phase2_writings_queue.lua`: actual playlist/page continuation and fast physical page replacement.
- `tests/audio_phase2_places.lua`: combat/cinematic holds, migration and starting greetings.
- `tests/audio_phase2_ducking.lua` / `tests/audio_phase2_routing.lua`: per-category volume and routing.
- `tests/audio_phase3_pack_selection.lua`, `tests/test_audio_pack_audit.py`: deterministic pack selection and offline audit correctness.

Both the Audio API transport regression and Audio pack regression workflows passed at the final pre-document code head. See [audio transport run](https://github.com/z1xel/SoftSpoken/actions/runs/42340606045) and [audio pack run](https://github.com/z1xel/SoftSpoken/actions/runs/42340606029). These are **automated mocked/CI checks**, not proof of every real-client combination.

For manual client cases, use [audio-phase2-client-validation.md](audio-phase2-client-validation.md). The beta may surface previously untested edge cases; report and fix those individually rather than rewriting the established queue.

## Known limitations and deferred work

| Subject | Current position |
| --- | --- |
| True native MP3 pause / seek / resume | Not exposed by the verified ClassicAPI/SuperWoW APIs; Stop/Replay restarts the clip. |
| Wrong or missing duration metadata | Does not drive native completion, but can distort progress or timed subtitle-page advancement. |
| Native MP3 start rejection | Missing file, bad path, or full two-stream bus may produce the same failure result; ordered alternative files are tried but start-reason identification is unavailable. |
| Independent NPC-only muting | Vanilla has no safe dedicated Dialog volume channel; intentionally does not silence global sound effects to suppress barks. |
| Per-recording volume normalization | No live per-MP3 gain or automatic normalization; offline LUFS/peak audit only. |
| ClassicAPI versions | Minimum documented transport baseline v1.18.14; native duration StatusBar v1.19.0+, with v1.19.1+ recommended for correct geometry. Verify actual launcher/client combinations. |
| SuperWoW coexistence and background behavior | Read-only diagnostics and source investigation exist; exhaustive real-client compatibility is not claimed. |
| Shared queue refactor | Deferred intentionally. Remove confirmed obsolete code and fix demonstrated failures; do not replace working guard logic for aesthetic simplicity. |

## Squash-merge preservation

A squash merge integrates the **final implementation and this document** into `main` as one reviewed change. It does **not** replay the intermediate 160 development commits into main's first-parent history. Keep the original `development/audio-api` branch available as an archival reference for individual implementation steps and debugging.

**Overall outcome:** SoftSpoken advanced from an upstream-inspired Vanilla 1.12 port to a ClassicAPI-native, engine-aware narration system, with one coordinated queue, native completion, safer category mixing, deterministic voice-pack selection, accurate first-page Compendium progress, and substantially stronger regression coverage.
