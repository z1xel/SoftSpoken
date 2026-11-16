# Turtle quest speaker and relationship exception audit

**Scope:** 2,377 retained Turtle-exclusive quests in the existing Compendium; pinned community Tortoise SQLite (Git commit `567ce23c73087e9b67fd2d4732c171d751e54bba`) and frozen pfQuest Turtle import. This is **not** a live-server spawn or audio attestation.

## What was missing

The original pfQuest-derived import had **31 quests without typed starters** and **31 without typed enders**, overlapping in **26 quests**: **36 distinct quest records, 62 absent speaker roles**. All 36 records exist in the pinned Tortoise source.

| Disposition for the 62 missing roles | Starter roles | Ender roles | Total |
| --- | ---: | ---: | ---: |
| Typed NPC relationship **and recorded NPC spawn**, corrected in the Compendium | 9 | 11 | **20** |
| Typed game-object relationship, **no corroborated static object spawn** | 7 | 10 | **17** |
| No typed link, but quest chain references another stage | 3 | 3 | **6** |
| No typed link or usable chain clue | 12 | 7 | **19** |
| **Total** | **31** | **31** | **62** |

A quest chain reference is **not** a quest giver; a static source omission is **not proof** a quest is deliberately hidden or script-driven. All 42 remaining roles are held rather than filled speculatively.

### Implemented: 20 roles across 11 quests

These were independently supported by both the source's typed start/end relationship and an NPC recorded as spawned in that source. All 20 are now on the existing `SoftSpoken_Stories/Data/Compendium.lua` rows, with unchanged quest titles, faction/class eligibility, and area metadata.

| Quest ID(s) | Quest / family | Verified recovery |
| --- | --- | --- |
| 41734 | Damaged Relic Mechanism | Item starter preserved; ender **6868** |
| 41908–41909 | Raw / Glowing Draenethyst | Starter and ender **62851** |
| 41912 | An Ill Omen | Starter **62986**, ender **62920** |
| 41913 | Draenei Divination | Starter and ender **62920** |
| 41914 | Hooves and Horns, Clad in Red | Starter **62920**, ender **62986** |
| 41915 | Answers from Father | Starter **62986**, ender **62850** |
| 41916 | The Elder's End | Starter and ender **62850** |
| 41917 | A Student's Determination | Starter **62850**, ender **62986** |
| 41922 | Homecoming | Starter **62863**, ender **91781** |
| 80381 | Shellcoins | Ender **80999**; starter remains unresolved |

The protected `docs/turtle_speaker_recovery.csv` manifest and `scripts/reapply_turtle_speaker_recovery.py` preserve these corrections after regenerating from the original, deliberately unmodified pfQuest import manifest. The catalog replay invokes speaker recovery after applying area metadata.

**Three missing display-name fallbacks** were independently cross-checked and added to the same Compendium name table: **6868 Jarkal Mossmeld**, **62986 Ar'lia**, and **62850 Moro'gai K'la**. Their exact names and reference URLs are separately pinned in `docs/turtle_speaker_recovery_names.csv`. Other unverified names were not invented.

### Held: 17 source-backed object roles

The snapshot's typed relationships identify these objects, but the same snapshot has no corroborating matching static object spawn. Some may be spawned on demand, scripted, triggered by an item, or be stale references. **No one of these explanations has yet been demonstrated.**

- **41923–41926 — Stone of Dreams** (Ashenvale, Feralas, Duskwood, Hinterlands): objects **2020302–2020305** start and end each quest (8 roles).
- **41929 — Bursting Mana Shard:** item **42169** starts, object **2020306** ends (1 role).
- **42002–42005 — Writhing Eyes / Silver Blade / Drenched in Power / The Rift Calls:** source objects **2020329–2020331** participate in the start/end chain (7 roles).
- **42036 — Secrets of Ten Thousand Years:** source object **2020340** as completion target (1 role).

These roles need evidence of actual object availability or a script-managed interaction before static integration. The typed relationships and IDs are preserved in the per-quest source review, not discarded.

### Held: 25 roles with no typed relationship

- **40820–40821 — The Key to Karazhan IV/V (Alliance):** previous-quest links but no source speaker. The equivalent faction chain has speakers, but those do not justify copying across race/faction variants.
- **41955 — Tricolored Hide-ra:** previous quest exists, speaker unknown.
- **40749 — Translating The Unknown; 41652 — An Unusual Interference; 80381 — Shellcoins:** one side is known, other side unknown.
- **50322, 50323, 50331, 50332 — WANTED quests:** known delivery NPCs but no typed start; a notice-board starter is plausible, *not verified*.
- **41261, 41954, 60013, 70010, 80735, 80736:** no typed source start/end. `Happy New Year!` and `Dual Spec` may be service/event flows; do not label them intentionally hidden without interaction evidence.

Remaining detail, including side, typed source IDs, spawn evidence and `prevquest`/`nextquest`: [missing_36_source_review.csv](audits/turtle_speaker_exceptions/missing_36_source_review.csv).

## Multiple speakers: 27 retained high-ID quests

- **27 of 27** original multi-speaker candidate sets match the actual Compendium effective mappings. There is **no confirmed dropped or arbitrarily selected NPC candidate**.
- **7 of the 27** are faction-specific `Fashion Demands Sacrifices`/`Make the Right Choice` variants (60030–60036). The effective completion speaker is derived from `starterAlliance=51292` or `starterHorde=51293`. This is not a missing ender.
- **20** retain genuine alternate speakers. The current resolver deliberately does not choose one from a plural set in a static Compendium page, and a live interaction's speaker GUID takes precedence for active narration.
- When the pinned Tortoise source is compared independently, **all 27 starter sets and 25 ender sets match**. Two ender sets contain an extra candidate in pfQuest/Compendium:
  - **41768 — The Messenger Of Northwind:** two enders (NPCs **1749**, **62682**) in pfQuest/Compendium versus just 1749 in Tortoise. [OctoWow's quest record](https://octowow.st/db/?quest=41768) explicitly names **both** enders, so **retain both**.
  - **41868 — Shadow Curse:** enders **62395**, **62422** in pfQuest/Compendium versus just 62422 in Tortoise; [OctoWow](https://octowow.st/db/?quest=41868) also records 62422. **Leave 62395 pending evidence**, not silently remove it.

Machine-readable coverage: [multiple_speaker_review.csv](audits/turtle_speaker_exceptions/multiple_speaker_review.csv).

## Narration and installed voice packs

The **metadata routing is checked; the recordings themselves are not verified**.

`SpeakerResolver:ForQuest` uses typed quest-speaker entries and returns no arbitrary candidate for plural assignments. `SpeakerResolver:ForSound` prioritizes the real interaction GUID. `DataModules:PrepareSound` selects a sex-/giver-specific quest file when present and falls back to the stage recording named `questID-accept`, `questID-progress`, or `questID-complete`.

The repo's bundled `SSS_VOFallback` is a Vanilla fallback voice pack. Its giver-index metadata covers **zero** of the 27 Turtle-specific plural quest IDs. The actual additional player-installed packs, their NPC-specific voice-file indices and the on-disk recordings are not available here. Consequently:

- **Do not claim an NPC voice matches a mapped quest speaker** from an ID/name or filename alone.
- For a live verification, use one quest with a single restored NPC, one with two speakers (41768), one with three (42098), and the two-faction 60030. Record the live speaker GUID and which audio file the player selected, then compare the *actual* spoken voice and text.
- If an installed pack lacks per-giver recordings, a shared quest-stage recording can play for several legitimate NPCs. That's an explicit **audio coverage constraint**, not necessarily a broken speaker mapping.

## Validation and limits

The dedicated `.github/workflows/turtle-speaker-exceptions.yml` workflow downloads and SHA-verifies the immutable source; checks the 36 missing-side records and all 27 plural candidates; validates the 20 recovered fields and names; and commits source evidence. The existing Lua 5.1 speaker-resolver regression also checks typed starter, item starter, ender, plural candidate behavior and live GUID precedence. Replays are idempotent and stage-specific.

The old, separate Turtle-touched *text* workflow may currently fail because it downloads cMaNGOS `latest` while requiring the SHA of an earlier release ZIP. That **unrelated data-source drift** must be corrected by pinning the actual release, not by disabling checksum validation.

**Result:** **20 corrected roles**, **42 still held**. All 27 multiple-speaker mappings are structurally accounted for. Narration voice identity remains an in-game/installed-pack verification task, not a claim of automated certainty. Nothing has been merged into `main`.
