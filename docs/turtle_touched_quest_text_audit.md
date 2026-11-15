# Turtle-touched legacy/shared-ID quest text audit

**Date:** November 15, 2026  
**Branch:** `audit/turtle-touched-text-coverage`  
**Status:** Read-only provenance audit completed; the first 13 verified stage overrides are now committed to the Turtle-only Lua table. `SpokenQuestsText` remains unchanged.

## The question

Which quest acceptance, progress, or completion dialogue needs a **Turtle-specific**
overlay because Turtle added, restored, or changed the quest? This audit does
**not** indiscriminately rewrite Blizzard/Vanilla/Spoken dialogue.

The previously integrated **2,377 Turtle-exclusive high-ID quests** are
deliberately out of scope here. Their earlier coverage audit is documented in
`docs/tortoise_quest_source_integration.md`. This is the *complementary*
audit for the old/shared-ID quests that have already been added to the Compendium.

## Source evidence

- Tortoise SQLite: `Xian55/tortoise-db-viewer` pinned
  `567ce23c73087e9b67fd2d4732c171d751e54bba`.
- Independently built Classic 1.12 baseline: cMaNGOS Classic SQLite ZIP
  release asset 751034809; SHA-256
  `78c08a0b8d0e253d8a094ae830942d0a8b3316ad1a1ebba4be57342bc2c3d0d1`.
- Original Turtle world quest SQL plus **155 incremental migration files**:
  `tortoise-wow/tortoise-wow` `48cb227f2cb698920dc2f60eeadd6546243eb75e`.
  Audit extracts quest IDs and the specific dialogue field altered by a
  migration; no prose is emitted.
- Vanilla `shagu/pfQuest` `104f35678ca39ab1fb78b655f815cc7016f5e0c8`
  vs Turtle `shagu/pfQuest-turtle` `0bc7bf4e55d8867a065354da6f386461255e4801`.
  This comparison helps identify *quest metadata changes* and whether IDs
  predate Turtle. A metadata difference does **not** by itself mean Turtle
  changed dialogue.
- Prior manually curated Turtle restoration/shared-ID manifests and explicit
  live evidence (quest 820, observed in-game in November 2026).

The Vanilla baselines are independent *community restorations*, so even a
dialogue mismatch is not by itself evidence that Turtle authored the different
text. These are **review candidates**, not automatically authorized edits.

## Findings

| Measure | Count |
| --- | ---: |
| Existing Compendium quests | 7,246 |
| Existing exclusive high-ID quests excluded from this complementary audit | 2,377 |
| Potential old/shared-ID changes with Turtle-specific provenance | 760 |
| Held because of disabled Method, absent starter, source/catalog conflict, or Vanilla baseline ambiguity | 49 |
| Shared-ID quests selected for **review**, not automatic replacement | **711** |
| Source dialogue stages compared for that group | 2,133 |
| Possible incomplete/outdated stages under the *broader* review | 599 |
| **Directly supported missing/outdated stage candidates** | **509** |
| Distinct quest IDs among those 512 stages | **452** |
| Uncorroborated cMaNGOS-versus-Tortoise variations excluded | 977 |

Of the **509 directly supported stage candidates**, **289** currently have
Spoken text differing from Tortoise and **220** have no static text.
Stage breakdown: **16 acceptance**, **208 progress**, **285 completion**.
These are still candidates, not a license to overwrite original Spoken.

The other **90** of the broader 599 possible gaps lack the same direct
stage-specific text-migration or independently supported restoration evidence;
they remain in the broader review report, not the priority gap list.

### Restored or modified old-ID examples

- **820**, *What Do You Rely On?* — observed live in the user's screenshot.
  Present with a spawned Turtle starter and all three dialogue stages in
  Tortoise; all three are absent from the two static SoftSpoken text tables.
- **3578**, **3579**, **3580** — absent from both independent Vanilla baselines,
  matching non-disabled Turtle templates with world-spawned starters; all
  three static dialogue stages are missing.
- **3111**, *Glyphic Rune* — known-curated Turtle relationship and a migration
  modifying its acceptance text. All three static stages are missing, but **only
  acceptance** is directly supported for Turtle-specific import because the
  quest also exists in Vanilla pfQuest.
- **7478**, **7479**, **7480**, **7487** — absent from the cMaNGOS SQLite
  snapshot but **present** in Vanilla pfQuest, so **held** rather than
  misclassified as new/restored Turtle quests.

A quest that still exists in an old Vanilla dataset may nonetheless have been
restored or altered on Turtle. Holding it means **more independent evidence
needed**, not claiming it is nonplayable.

## Outputs

All reports are text-free: IDs, existing catalog titles, source/method and
evidence classifications, stage flags, character lengths, and SHA-256 hashes.
No third-party quest dialogue bodies are committed by this audit.

- `docs/audits/turtle_touched_text_coverage/summary.json` — consolidated counts.
- `review_scoped_quests.csv` — 711 candidate quests for manual review.
- `directly_supported_text_gaps.csv` — **priority 509 stage candidates**.
- `turtle_specific_text_gaps.csv` — broader 599 possible gaps.
- `held_quests.csv` — 49 disabled/conflicted/unverified quests.
- `uncorroborated_cross_database_variants.csv` — 977 rejected
  cMaNGOS-vs-Tortoise differences lacking a stronger Turtle edit signal.
- `stage_coverage.csv` — whether source, Vanilla baseline, original
  Spoken text, or Turtle-specific overlay supplies each stage.

### Safety / limitations

- **No** original `SoftSpoken_Stories/Data/QuestText.lua` modifications.
- Existing Turtle-exclusive entries in `SoftSpoken_Stories/Data/TurtleQuestText.lua` are preserved; the first 13 verified stages are appended.
- **No** `SoftSpoken_Stories/Data/Compendium.lua` modifications.
- Live, per-character `SSCQuestJournal` capture is not available to a
  static source audit, so in-game appearance may differ.
- Some quests legitimately lack acceptance or progress dialogue.
- Any eventual import should write **only verified quest/stage overrides** to
  `SSCTurtleQuestText`, leaving `SpokenQuestsText` intact.


## First source-verified local import batch (November 15, 2026)

The first batch deliberately selects **13 stages across five restored-quest IDs**:

| Quest ID | Eligible dialogue |
| --- | --- |
| 820 | acceptance, progress, completion |
| 3111 | acceptance only |
| 3578 | acceptance, progress, completion |
| 3579 | acceptance, progress, completion |
| 3580 | acceptance, progress, completion |

A cMaNGOS omission no longer qualifies a quest for a full three-stage import
when it **also appears in Vanilla pfQuest**. For such IDs, only stages named
by the pinned Turtle SQL text migrations are actionable. This removes
two unevidenced stages for 3111 and an unevidenced acceptance stage for 5640
from the previous 512-candidate priority report. Both retain their
separately supported stages.

The stage importer, `scripts/import_turtle_touched_text.py`, verifies the
source title, normalized SHA-256 content hash, and raw source character count
for each targeted stage against the supplied pinned Tortoise SQLite. It
rejects pre-existing per-quest Turtle text assignments, incomplete manifests,
or any stage whose provenance no longer qualifies. Tests verify collisions,
hash failures, scope and idempotency. GitHub Actions checked all 13 hashes
and committed these exact stages to the existing Turtle quest text file.

For a **populated** Turtle text table, the safest one-command local operation
is to append only the audited stage batch. It preserves every existing line
outside the generated first-batch region:

```sh
node scripts/import_tortoise_quest_dialogue.mjs --touched-only
```

The default importer still supports rebuilding **2,369 eligible
Turtle-exclusive quest rows plus 13 first-batch stages** into the same
`SoftSpoken_Stories/Data/TurtleQuestText.lua` file when a full pinned-source
regeneration is intentionally desired:

```sh
node scripts/import_tortoise_quest_dialogue.mjs
```

For standalone validation with a locally held pinned SQLite:

```sh
python3 scripts/import_turtle_touched_text.py --db /path/to/tortoise.sqlite
```

To add just the first batch to an existing local Turtle text table:

```sh
python3 scripts/import_turtle_touched_text.py --db /path/to/tortoise.sqlite --write --local-only
```

**Committed:** 13 stages for quest IDs 820, 3111, 3578, 3579 and 3580, into
`SoftSpoken_Stories/Data/TurtleQuestText.lua` on the audit branch. The existing
2,369 entries and original Spoken table remain unchanged. This completes the
first batch; 496 other high-priority stages remain unimported. The Tortoise
snapshot is a community reconstruction rather than an authenticated live
Turtle server export, so in-game text may differ.
