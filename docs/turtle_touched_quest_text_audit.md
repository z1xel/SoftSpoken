# Turtle-touched legacy/shared-ID quest text audit

**Date:** November 15, 2026  
**Branch:** `audit/turtle-touched-text-coverage`  
**Status:** Source-provenance audit and the first two imports completed: **220 stages** (13 restored + 207 previously missing) committed to the existing Turtle-only text table. `SpokenQuestsText` remains unchanged.

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
| Possible incomplete/outdated stages under the *broader* review | 379 |
| **Directly supported unresolved stage candidates** | **289** |
| Distinct quest IDs among those 289 stages | **289** |
| Uncorroborated cMaNGOS-versus-Tortoise variations excluded | 977 |

After the two verified imports, **all 220 directly-supported previously missing
stages now have a Turtle overlay**. The **289 remaining priority candidates**
already contain Spoken dialogue that differs from the pinned Tortoise source:
**11 acceptance** and **278 completion** stages. None of those conflicting
Spoken stages was overwritten by either import.

The other **90** of the broader 379 possible gaps lack the same direct
stage-specific text-migration or independently supported restoration evidence;
they remain in the broader review report, not the priority gap list.

### Restored or modified old-ID examples

- **820**, *What Do You Rely On?* — observed live in the user's screenshot.
  Present with a spawned Turtle starter and all three dialogue stages in
  Tortoise; all three are now present in the Turtle-only overlay.
- **3578**, **3579**, **3580** — absent from both independent Vanilla baselines,
  matching non-disabled Turtle templates with world-spawned starters; all
  three source-supported dialogue stages are now in the Turtle overlay.
- **3111**, *Glyphic Rune* — known-curated Turtle relationship and a migration
  modifying its acceptance text. All three static stages are missing, but **only
  acceptance** was directly supported and imported because the quest also
  exists in Vanilla pfQuest.
- **7478**, **7479**, **7480**, **7487** — absent from the cMaNGOS SQLite
  snapshot but **present** in Vanilla pfQuest, so **held** rather than
  misclassified as new/restored Turtle quests.

A quest that still exists in an old Vanilla dataset may nonetheless have been
restored or altered on Turtle. Holding it means **more independent evidence
needed**, not claiming it is nonplayable.

## Outputs

All reports are text-free: IDs, existing catalog titles, source/method and
evidence classifications, stage flags, character lengths, and SHA-256 hashes.
The audit reports do not include quest prose; the separately imported bodies live in the Turtle-only Lua file.

- `docs/audits/turtle_touched_text_coverage/summary.json` — consolidated counts.
- `review_scoped_quests.csv` — 711 candidate quests for manual review.
- `directly_supported_text_gaps.csv` — **289 unresolved source-supported text conflicts**.
- `turtle_specific_text_gaps.csv` — broader 379 possible gaps.
- `held_quests.csv` — 49 disabled/conflicted/unverified quests.
- `uncorroborated_cross_database_variants.csv` — 977 rejected
  cMaNGOS-vs-Tortoise differences lacking a stronger Turtle edit signal.
- `stage_coverage.csv` — whether source, Vanilla baseline, original
  Spoken text, or Turtle-specific overlay supplies each stage.

### Safety / limitations

- **No** original `SoftSpoken_Stories/Data/QuestText.lua` modifications.
- Existing 2,369 Turtle-exclusive entries in `SoftSpoken_Stories/Data/TurtleQuestText.lua` are preserved; 13 restored-quest and 207 previously missing shared-ID stages are appended.
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
is to append only the two audited stage batches. It preserves every existing line
outside the generated first-batch region:

```sh
node scripts/import_tortoise_quest_dialogue.mjs --touched-only
```

The default importer still supports rebuilding **2,369 eligible
Turtle-exclusive quest rows plus 13 restored stages and 207 missing stages** into the same
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
first batch; the follow-up 207-stage batch is also committed, leaving 289
source-supported, existing-Spoken conflicts unimported. The Tortoise
snapshot is a community reconstruction rather than an authenticated live
Turtle server export, so in-game text may differ.

## Second import: 207 missing stages (November 15, 2026)

- **204 progress and 3 completion stages**, affecting **206 shared-ID quests**.
- Exact quest/stage fingerprints pinned in `missing_207_verified_stages.csv`.
- `scripts/import_turtle_missing_stages.py` validates all 207 titles, source
  SHA-256 hashes, and raw text lengths against the pinned SQLite, requires
  stage-specific Turtle migration support, and rejects any stage already
  populated by Spoken or Turtle.
- The importer adds a dedicated generated block *after* the preserved 2,369
  exclusive quests and 13 restored stages; Lua 5.1 syntax and both append-only
  and full-regeneration workflows pass GitHub Actions.
- The post-import audit was regenerated from the new tracked Lua corpus and
  now reports **289 directly supported conflicting stages, 0 missing
  directly supported stages**, and **90 additional lower-confidence gaps**.
  The distinct 289 conflicts are left untouched for a separate review.

To reproduce both imports without overwriting the existing exclusive corpus:

```sh
node scripts/import_tortoise_quest_dialogue.mjs --touched-only
```

A public repository commit now contains these 207 bodies in
`SoftSpoken_Stories/Data/TurtleQuestText.lua`, while
`SoftSpoken_Stories/Data/QuestText.lua` and Compendium relationships remain
unchanged. These are consistent with the pinned Tortoise community snapshot,
not an authenticated dump of the live Turtle server.
