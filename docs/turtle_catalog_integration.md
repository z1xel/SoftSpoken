# Turtle Quest Catalog audit consolidation

The runtime catalog on `feature/turtle-quest-catalog` includes the successive audits:

1. `audit/tortoise-text-coverage`: Turtle-exclusive dialogue in `Data/TurtleQuestText.lua`, selected independently of the original `QuestText.lua`.
2. `audit/tortoise-unclassified-integrity`: verified native-zone and custom-Turtle-area classification, with separate `turtleArea` IDs and 45 named area groups.
3. `audit/turtle-touched-text-coverage`: 20 independently supported speaker roles, stage-specific shared-ID dialogue fixes, three classification exceptions and the approved quest 41797 alias.

## Protected catalog invariants

- Exactly 6,646 static Compendium quest IDs; 600 unapproved high-ID records excluded, with 575 associated original Spoken dialogue records removed. No deprecated quest IDs resurrected.
- The original `SoftSpoken_Stories/Data/QuestText.lua` remains unchanged (Git blob `543ebe66fd648e625699d6d8cd78d26359578d92`).
- 2,370 Turtle-exclusive quest text rows and 223 low/shared-ID overlay rows.
- Source-deprecated dialogue records 40128, 40129, 40132, 41098, 41100, 41103 and 41105 remain excluded.
- Native `uiMapID` zones and Turtle custom `AreaTable` IDs remain distinct.
- Data can be replayed by `python3 scripts/reapply_turtle_quest_catalog.py --check`, with source decisions maintained in the audit manifests.

## CI ownership

`.github/workflows/turtle-catalog-integration.yml` runs on the feature branch. It is intentionally read-only, tests Lua 5.1 syntax/runtime compatibility, checks original text integrity, and tests catalog/speaker replay.

The historical workflows under `.github/workflows/tortoise-*` and `turtle-*` remain scoped to their corresponding audit branches, including their audit-result commit steps; do not repoint their push destinations to the catalog feature branch. The historical `turtle-touched-text-audit.yml` full-source reconstruction depends on a mutable cMaNGOS `latest` release with a now-stale fixed SHA. It is **not** treated as a passing integration gate until the original baseline is recovered or a properly immutable replacement is reviewed.

## Outside automated validation

The pinned Tortoise community snapshot is not a live server export. Verify virtual-zone browsing, quest narration, installed voice-pack speaker recordings and faction-specific quest behavior on a Turtle WoW 1.12 client before a production/main merge. The outstanding classification, source-status and dialogue holds remain unresolved unless new evidence supports them.

## Forever-source removal pass

The source-qualified cleanup is in `docs/forever_quest_exclusions.csv`. It removes 600 high-ID quest records absent from pinned Vanilla pfQuest and the approved Turtle import, with 575 original Spoken text records. The pinned Vanilla ID inventory and explicitly protected older-ID Turtle restorations are committed separately.

`python3 scripts/clean_forever_quest_data.py --check` fails if any excluded record or new, unreviewed quest ID appears. The catalog replay runs this as its last step. The independent cleanup workflow also compares the reconstructed, filtered original corpus against shipped files byte-for-byte. This is an **ID-level cleanup**; Vanilla-ID quest metadata inherited from the upstream mixed corpus remains a separate field-by-field provenance audit.
