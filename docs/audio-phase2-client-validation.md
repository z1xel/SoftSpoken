# SoftSpoken audio Phase 2 — in-game validation checklist

**Status:** Pending user testing. **Branch:** `development/audio-api`, **not merged**.
This checklist is the single running record of everything that cannot be
validated in the GitHub Actions Lua mock harness. Do not mark any of these
checkboxes complete based on CI alone.

## Environment (record once before testing)

- [ ] Tested the latest development/audio-api checkout; note commit SHA.
- [ ] ClassicAPI **v1.18.14 or newer** loaded and active (note version).
- [ ] Client: original **WoW 1.12**, note server/client variation.
- [ ] Note whether **SuperWoW** is installed/enabled and its released version.
- [ ] Modules enabled: Stories / Places / Writings, and which voice packs are installed.
- [ ] If possible, install/use the optional SoftSpoken Developer module and copy
      its **detailed diagnostic report** for any failures. The report includes
      ClassicAPI status, selected channel, current clip, gate reason, handle
      presence, metadata duration, and native playback state—without MP3
      paths, transcript text, or numeric native handles.

## A. Core playback and visible state (#56, #57, #58, #60, #66)

- [ ] **A1 — Normal recording:** Play a Stories line and let it end. It should
      be audible in full; UI stops only after the actual sound ends.
- [ ] **A2 — Progress bar:** Show Progress Bar ON/OFF in Large Window; it
      follows the duration estimate but never completes prematurely. Voice
      Only shows no bar. Resize/hide portrait and repeat.
- [ ] **A3 — Stop/Replay:** Click the narrator stop control during a long line,
      then Replay. That line should restart **from the beginning** (no true
      mid-file resume is implemented).
- [ ] **A4 — Skip/Stop All:** Queue two or three lines. Skip affects only the
      current line; Stop All clears the queue. No duplicated callbacks/audio,
      lingering queue entries, or global SFX interruption.
- [ ] **A5 — Rapid controls:** Rapid Stop, Replay, Skip and select different
      clips; no stuck progress, stale control state, or wrong clip stopping.
- [ ] **A6 — Missing/damaged recording (optional):** In a *copied* test
      installation, remove or break an individual MP3. A failed start should
      be reported/cleared without claiming it is playing or blocking future
      queue entries. Restore the file afterward.

## B. Combat, cinematics and Places (#61, #73)

- [ ] **B1 — Both controls OFF (new default):** Places narration may begin
      during combat; one already playing continues.
- [ ] **B2 — Hold ON, Stop OFF:** Start automatic Places narration, enter
      combat during it. It must **finish**, without restarting; a NEW
      automatic Places line waits until combat ends.
- [ ] **B3 — Hold ON, Stop ON:** Enter combat during automatic Places audio.
      Only that Places line stops and remains queued. It must NOT immediately
      restart during the fight; after combat it replays **from the start**.
- [ ] **B4 — Toggle settings mid-fight:** Turn Hold/Stop on and off, including
      attempting Stop without Hold. UI must enforce Stop implies Hold.
      No stop/restart loops.
- [ ] **B5 — Different sources:** Manually play a Place, Story or Writing
      during combat. Places' AUTO-only restriction must not stop those.
- [ ] **B6 — Cinematic:** With Hold/Stop OFF, start/skip/watch a cinematic
      while automatic Places narration is relevant. It should be held during
      the cinematic and become available afterward, independent of combat.
- [ ] **B7 — Reload migration (existing user):** If the old Hold During
      Combat setting was ON before updating, verify both Hold and Stop are
      ON after upgrade; previous OFF stays OFF. Reset defaults makes both
      OFF. Do not wipe existing saved data simply to test this.

## C. Fresh starting character (#75)

- [ ] **C1 — New level-one character:** After location stabilizes for the
      existing 0.75s, and after opening cinematic finishes or is skipped,
      first starting-area narration begins after **another 1.5s**.
- [ ] **C2 — Selection:** Exactly one best matching introduction plays
      (starting subzone preferred where voiced; parent fallback otherwise).
      No simultaneous zone+subzone duplicate.
- [ ] **C3 — Reload while still held:** Reload before the delayed greeting
      begins. It should retry when the player returns, not disappear forever.
- [ ] **C4 — Unrelated sources:** Manually queue a quest during the greeting
      delay; it is not subject to the 1.5s gate. Subsequent discoveries
      have no special startup delay.

## D. Writings — most important regression coverage (#65)

- [ ] **D1 — Compendium multi-page book:** Select an audio-backed book of
      at least three pages. Pages play **once each**, in order, with a
      short intentional page transition and no overlap.
- [ ] **D2 — Interrupt:** Stop a Compendium reading midway. Its remaining
      pages must not start later; other sources can continue.
- [ ] **D3 — In-world reader:** Open a multi-page physical book and turn
      pages rapidly. Each newly displayed page narrates correctly; duplicate
      ITEM_TEXT_READY must not replay the same page. Unlike Compendium,
      the reader should wait for player page turns.
- [ ] **D4 — Close/reopen:** Verify Stop on Close OFF allows existing audio
      to continue and ON stops that book, not an unrelated quest.
      Reopening works; Read Once suppresses already finished books as intended.
- [ ] **D5 — End behavior:** Close When Read acts only when the appropriate
      page/book finishes naturally, never after a skipped/failed page.
- [ ] **D6 — Change reading context:** Switch from Compendium to physical
      reader for the same book while speaking. No duplicate pages or
      abandoned/stuck queue entries.

## E. Manual Play policy / cross-module queue (#64)

- [ ] **E1 — Stories + Writings:** While a book is speaking, select a quest
      manually. It queues behind the current recording and other queued
      work; does NOT interrupt the book.
- [ ] **E2 — Repeated clicks:** Click the same queued item rapidly. Exactly
      one queued instance remains and plays once.
- [ ] **E3 — Places travel:** Queue a manually selected Place while Stories
      speaks, then trigger several automatic discoveries. The manually
      selected Place must survive automatic Places backlog trimming.
- [ ] **E4 — Multi-page precedence:** With a Compendium book underway,
      queue a Story and a Place. Consecutive book pages continue as
      previously; the user-selected clips are not dropped or reordered
      unexpectedly.
- [ ] **E5 — Disable a module:** While audio from different modules is
      queued, disable one module. Its entries should disappear without
      silencing or skipping other modules.

## F. Audio channels, NPCs, fades and SuperWoW (#62, #63, #69, #70, #72)

These cases **require a real game client**; GitHub's Lua mocks cannot
verify the 1.12 audio mixer, MP3 file bus, speaker device, or SuperWoW.

- [ ] **F1 — Channel baseline:** In SoftSpoken Settings → Audio →
      **Narration Channel**, verify the default is Master and Stories,
      Places and Writings narrate normally on it.
- [ ] **F2 — Category routing:** Select SFX, Music and Ambience in turn,
      then start a **new** narration from each module. Verify each
      category actually works in your released ClassicAPI client, and
      restore Master afterward. A category change must not stop or
      reroute a recording already playing.
- [ ] **F3 — Upstream defaults:** In Audio settings, verify **Turn
      Other Sounds Down** is ON. Under **Quieter Game While Spoken Talks**,
      verify Music 30%, Ambience 40%, Effects 60%; no separate NPC voice slider.
- [ ] **F3a — Three simultaneous fades:** Set the game's Music, Ambience
      and Effects levels to recognizable values (e.g. 80%). Play a long
      Master-routed narration. Music/Ambience/Effects should gently
      become about 24%/32%/48%, then return to exactly 80%.
- [ ] **F3b — Per-category settings:** Change each SoftSpoken level
      during narration. It should adjust that category without touching
      game Master Volume or altering either of the other two baselines.
- [ ] **F3c — Protect active voice:** Route narration to Music, then
      Ambience, then SFX on different recordings. The active voice's
      own category should remain at normal volume; the others duck.
      Changing a route mid-file must not reroute the existing recording.
- [ ] **F3d — Transitions:** Queue narration across Stories, Places and
      multi-page Writings. Between lines there should be no audible
      volume pumping. Stop, Replay, Skip and combat Hold/Stop should
      restore the game mix when no voice is speaking.
- [ ] **F3e — Player overrides:** Adjust Music, Ambience or Effects
      directly in the game's sound settings during a line. SoftSpoken
      must respect that change rather than restore a stale baseline.
- [ ] **F3f — Recovery:** /reload mid-voice, then normal logout/login.
      All categories that were reduced should return to baseline.
      Crash recovery is simulated in CI; don't intentionally crash
      your primary client.
- [ ] **F3g — Toggle OFF while speaking:** All three volumes fade
      back to their original values. Turning back ON resumes ducking.
- [ ] **F3h — Vanilla CVars:** Check for no writes to MasterVolume or
      MasterSoundEffects; the only adjusted CVars are SoundVolume,
      MusicVolume and AmbienceVolume. Vanilla 1.12 has no Dialog slider.
- [ ] **F4 — NPC greeting overlap:** Start a quest/gossip interaction when
      an NPC voice bark is playing. Record whether narration overlaps,
      fails to start, or delays; never require muting unrelated SFX.
- [ ] **F5 — Sound contention:** Queue several narration files, interact
      with voiced NPCs, and enter a busy combat scene. Listen for
      unexpectedly rejected streams, ghost playing UI, skipped lines.
- [ ] **F6 — Fade and gap:** Stop/Skip during a long line; confirm only
      SoftSpoken's recording fades/stops, not game SFX. Listen for
      excessive silence or overlap between consecutive lines/pages.
- [ ] **F7 — SuperWoW A/B (if installed):** Repeat F1, F4, F5 with and
      without the **released** SuperWoW extension; record version and
      any effects of its supported sound settings. Do not infer that
      a roadmap feature is available.
- [ ] **F8 — Minimize/alt-tab:** Play a long narration, switch focus and
      return. Report whether it continued, stopped, or left the UI stale.
      Respect the player's existing background-sound preference.
- [ ] **F9 — Loudness:** Compare a sample from each installed voice pack.
      Note extreme loudness jumps; offline normalization is NOT yet
      implemented and no unsafe independent MP3 volume slider is exposed.

## G. Voice-pack selection and actual files (#67)

The Lua unit tests check deterministic metadata order, not whether
every referenced MP3 exists in the player's installed pack directories.

- [ ] **G1 — Stories priority:** With overlapping packs installed,
      confirm a clip covered by Spoken Quests uses Spoken ahead of
      SSS_VOFallback and AI_VoiceOverData_Turtle, irrespective of TOC
      priority and addon load order.
- [ ] **G2 — Fallback gaps:** Find a quest/gossip line not covered by
      Spoken but present in Combined or Turtle. Confirm the fallback
      plays and the queue advances correctly.
- [ ] **G3 — Physical missing MP3:** On a disposable copy of the
      installation, remove an MP3 indexed by a high-priority pack.
      Report whether the start fails and how the queue recovers; a
      missing *physical* file does not currently guarantee a retry
      through lower-priority packs. Restore the file after testing.
- [ ] **G4 — Places collisions:** For duplicate zone/subzone entries
      in compatible Places packs, verify deterministic choice;
      a malformed entry should yield rather than fabricate audio.
- [ ] **G5 — Writings partial pack:** Test a multi-page book with some
      pages absent from the preferred-language pack. Each page should
      use an available recorded fallback independently, once/in order.
- [ ] **G6 — Installed index audit:** Run the [offline audit script]
      (../scripts/audio_pack_audit.py) with a small --limit sample;
      compare returned filenames with voice packs' audio indexes.
      Report missing/bad files without changing original recordings.

## H. Released native extensions and sound contention (#69 / #72 / #63 / #59)

- [ ] **H1 — Extensions:** Record exact `CLASSIC_API_VERSION` and
      `SUPERWOW_VERSION` if installed, plus read-only diagnostic
      values for `UncapSounds`, `BackgroundSound`,
      `SoundSoftwareChannels`, `SoundMaxHardwareChannels`.
- [ ] **H2 — ClassicAPI-only A/B:** Start a long narration, trigger
      normal NPC greeting/combat/UI sounds and a second external MP3
      (if available). Record failed sound starts and queue recovery.
- [ ] **H3 — SuperWoW 2.2 A/B:** Repeat H2 and F7 with released
      SuperWoW enabled, keeping existing sound settings at first.
      Optionally change `UncapSounds` and channel limits manually,
      then restore. Do not assume this lifts ClassicAPI's 2-file bus cap.
- [ ] **H4 — NPC voice source identification:** If NPC barks remain
      disruptive, check `C_Sound.GetRecentSoundFiles()` around a
      known NPC interaction to identify exact file paths. Do not mute
      unknown paths automatically. Report the path and event timing.
- [ ] **H5 — Real pause semantics:** On a long book, Stop/Replay
      currently restarts from the beginning. Confirm that the UI
      does not promise true seek/pause-resume (unsupported by current DLLs).

## I. Loudness sample for #70

- [ ] **I1 — Real audio pack measurements:** Run
      `python scripts/audio_pack_audit.py "C:\\TurtleWoW\\Interface\\AddOns" --loudness --limit 100 --csv loudness.csv`
      with FFmpeg installed, choosing comparable clips across
      Spoken / Combined / Turtle / Places / Writings. Compare LUFS
      and true peaks; listen before changing any audio. This tool
      never writes to the source MP3s.

## What to send back after testing

A short **PASS / FAIL / NOT TESTED** for each ID (A1–I1), plus the
recording/module and reproduction steps for any failure. If something
fails, record ClassicAPI and SuperWoW versions, narrator style, whether
the recording was manual/automatic, and the diagnostics if available.

**Automated coverage already available in GitHub Actions (not a
substitute for the cases above):**

- `tests/audio_soundutils.lua` — targeted handles, failed starts, fade arguments.
- `tests/audio_queue.lua` — engine-based completion, queues, gates, pauses,
  manual retention, gaps and cue ordering.
- `tests/audio_progress_ui.lua` — Classic progress bar and settings.
- `tests/audio_phase2_places.lua` — combat migration and starting grace.
- `tests/audio_phase2_writings.lua` — Writings event/stop behavior.
- `tests/audio_phase2_writings_queue.lua` — real Writings playlist and
  queue integration, missing first-page audio, cross-module ordering.
- `tests/audio_phase2_diagnostics.lua` — read-only mixer and queue report.
- `tests/audio_phase2_routing.lua` — all four ClassicAPI output categories,
  cross-source defaults, saved-value fallback, and no CVar mutations.
- `tests/audio_phase2_ducking.lua` — upstream Music/Ambience/SFX
  defaults, three-category fades, active-voice protection, mixer override,
  queue gaps, logout/crash recovery, and unavailable CVar handling.

**Release gates:** all automated CI green; A–E major behavior tested on
1.12; F mixer limits documented and any unsafe CVar behavior eliminated;
then review PR and merge. No unverified issue should be closed solely
because mocks passed.
