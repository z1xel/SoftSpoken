# Turtle quest source validation and staged integration

## Status (2026-11-15)

**Branch:** `audit/tortoise-text-coverage`, based on `feature/turtle-quest-catalog`.
**Source:** Xian55/tortoise-db-viewer CDN commit `567ce23c73087e9b67fd2d4732c171d751e54bba`, snapshot version `80f9b3153120` (built 2026-11-11). The viewer builds its SQLite from a community Tortoise-WoW restoration, **not** an authenticated export of the current Turtle WoW live server.

**Immutable target set:** `docs/turtle_exclusive_import.csv`, 2,377 retained Turtle-exclusive quests (2,247 `imported` + 130 `already_present`). The 74 explicitly excluded records are never reintroduced.

## Read-only coverage

| Field | Nonempty |
| --- | ---: |
| Source record and title | 2,377 |
| Acceptance (Details) | 2,303 |
| Progress (RequestItemsText) | 2,311 |
| Completion (OfferRewardText) | 2,369 |
| All three | 2,233 |
| Numeric zone/category (nonzero) | 2,375 |

Reports: `docs/audits/tortoise_quest_coverage/summary.json`, `coverage.csv`, `title_conflicts.csv`.

Blank stages in the source are **not proof of an error**. Some quests intentionally have no progress or acceptance text. Do not manufacture missing dialogue.

## Conservative source-title decisions

**2,369 candidates for subsequent dialogue validation:** 2,346 byte-identical titles and 23 equivalents after whitespace/typographic punctuation normalization. This is a *candidate count*, not blanket approval to publish or automatically overwrite live-captured or Vanilla text.

**Eight held IDs** (never automatically emitted by the generator):

- Seven marked deprecated in the source while already present in our catalog: `40128`, `40129`, `40132`, `41098`, `41100`, `41103`, `41105`.
- `41797`: catalog/pfQuest snapshot title **A Good Friend**; Tortoise title **A Dear Friend**. Different source version/content is plausible. Preserve the catalog title and hold the dialogue until independently verified.

`60013` (*Happy New Year!*) and `70010` (*Dual Spec*) have zero `ZoneOrSort` in the source. Do not infer a zone.

Decision reports: `docs/audits/tortoise_quest_overlay/summary.json` and `decisions.csv`.

## Existing text/overlay contract

- `SoftSpoken_Stories/Data/QuestText.lua` **is populated** (approximately 2.86 MB in the audited branch), and its original `SpokenQuestsText` stages are included in the read-only shared-ID audit. Never edit that source as part of Turtle dialogue integration.
- `SoftSpoken_Stories/Data/TurtleQuestText.lua` **is also populated** (approximately 2.17 MB, 2,369 source/title-compatible exclusive quest rows). It is the **single** Turtle text destination and is loaded directly by `addon.xml` before the quest page. No companion addon exists. Two stage-specific importers append 13 restored stages and 207 previously absent stages without rewriting existing dialogue. The one-command exclusive importer can also regenerate all pinned text into the existing table.
- `SSCQuestPage:Text(id, stage)` selects each stage independently in this order: (1) per-character live capture, (2) Turtle overlay, (3) existing Spoken text. Missing/whitespace-only Turtle stages do not hide the fallback.
- Text is not copied to, nor does this branch modify, the authoritative Vanilla `SpokenQuestsText` table.

## Reproduction (read-only)

The GitHub workflow `.github/workflows/tortoise-quest-audit.yml` downloads the **pinned** published snapshot, decompresses SQLite, computes both reports, tests the generator with synthetic strings, and runs Lua 5.1 tests. No third-party dialogue body is included in its artifacts or repository commits.

Locally, with a legally usable local SQLite snapshot:

```sh
python3 scripts/audit_tortoise_quest_coverage.py --db /path/to/tortoise.sqlite
python3 scripts/prepare_tortoise_quest_overlay.py --db /path/to/tortoise.sqlite
```

After separately establishing use/redistribution rights, an operator can explicitly generate a **local-only** candidate overlay using `--emit-text /path/to/TurtleQuestText.lua --acknowledge-rights`. This flag acknowledges responsibility; **it is not a license**. Neither the workflow nor the normal audit emits quest prose.

The source code's AGPL-3.0 licensing and the viewer's attribution notices do not by themselves demonstrate that third-party or Blizzard quest prose is licensed for republishing in a public SoftSpoken addon. Do not commit a bulk dialogue overlay before clarifying permissions.

## Import directly into the existing Lua file

With Node.js 18+ and Python 3 installed, from the SoftSpoken repository root:

```sh
node scripts/import_tortoise_quest_dialogue.mjs
```

The command retrieves the pinned Tortoise SQLite snapshot, verifies its Git blob checksum, and writes **directly** to `SoftSpoken_Stories/Data/TurtleQuestText.lua`. It first builds the 2,369 source/title-compatible high-ID quest rows and then composes the 13 strictly evidenced stages of restored quests 820, 3111, 3578, 3579, and 3580 **plus 207 source-supported previously missing dialogue stages** into that same staged file. The original `SpokenQuestsText` dataset is untouched; the eight held exclusive quest IDs remain excluded. No extra addon folder or copy step is required. Blank source stages are never manufactured, and stage 3111 is restricted to acceptance.

To use an already downloaded SQLite file without network access:

```sh
node scripts/import_tortoise_quest_dialogue.mjs --source-sqlite /path/to/tortoise.sqlite
```

Alternatively, with a local database:

```sh
python3 scripts/prepare_tortoise_quest_overlay.py --db /path/to/tortoise.sqlite --into-addon
```

The shared-ID audit workflow generates the complete Lua file, runs `luac5.1 -p`, checks SHA hashes and regressions, and has committed the first 220 shared-ID dialogue stages to the isolated audit branch. The original Spoken text is not modified.

## Pending before production import

1. Independently compare a representative sample of all three dialogue stages to **actual live Turtle** interactions, including character substitution tokens, quest version differences, and 41797.
2. Review the seven source-deprecated quest IDs and decide whether the current server still serves them.
3. Audit text from any separately installed Spoken text pack, when available, for per-stage differences and collisions.
4. Confirm rights and attribution requirements before distributing a bulk text overlay.
5. Convert `ZoneOrSort` area IDs into the Compendium's `uiMapID` domain using verified crosswalks. **Do not** write positive AreaTable IDs directly into `zones = { ... }`, which is a different ID space. Preserve unknowns and the two zero values separately.
6. Re-run tests and check Vanilla and Turtle client behavior before merging into `feature/turtle-quest-catalog`.

No changes have been made to the production feature branch as part of this audit.
