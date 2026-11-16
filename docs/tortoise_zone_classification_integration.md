# Turtle quest zone classification integration

## Scope and result (November 15, 2026)

All 2,409 **already-present** and currently unclassified Compendium quests were
audited against a pinned Tortoise-WoW SQLite snapshot and the original world SQL
(with 155 migration files applied, zero reported SQL migration errors).

A conservative 2,372 entries gained classifications:

| Field | Count | Interpretation |
| --- | ---: | --- |
| `zones = {uiMapID}` | 1,258 | Verified Vanilla map ID, matched by area name or parent area |
| `turtleArea = areaID` | 978 | Named Turtle/custom/dungeon area with **no invented uiMapID** |
| `sort = QuestSort` | 136 | Existing source category value |
| Held | 37 | Disabled, retired, shared-ID unverified, unknown, zero or restricted location |

Of the 2,372 applied entries, 2,359 are in the previously curated 2,377
Turtle-exclusive ID manifest and 13 are strongly world-linked older shared IDs.
No previously absent quest was introduced or restored. Existing zone assignments
and Vanilla quest fields were not changed.

### Old shared-ID decisions

The 13 selected older quests had matching titles, non-disabled Method values,
source NPC/object starter relations and corresponding world spawns in the frozen
source. They include quest `820` (*What Do You Rely On?*) and quests
`3578`, `3579`, `3580`.

Of the 32 older unclassified/shared IDs, 19 remain held for explicit review,
including disabled `8289` and `8296`, title disagreements, and quests
without a demonstrable spawned starter. Source availability evidence is **not**
a guarantee of current live-server playability.

The other 18 held IDs are Turtle-exclusive records: seven source-deprecated or
renamed records, `41797` (title discrepancy), seven associated with GM Island,
`60013` and `70010` (zero classification), and `41633` (no matching area
in the published AreaTable snapshot). The held records remain in the audit and
were not given a guessed classification.

## Where the data lives

- `docs/audits/tortoise_unclassified_integrity/`: immutable pre-import,
  quest-level SQL evidence and a separate 32 shared-ID review file.
- `docs/audits/tortoise_zone_overlay/decisions.csv` and `holds.csv`:
  2,409 import decisions and the exact 37 exceptions.
- `docs/tortoise_zone_overlay.csv`: 2,372 selected quest classifications,
  including the source ID, mapping method and cohort.
- `SoftSpoken_Stories/Data/Compendium.lua`: the **existing** quest rows,
  augmented only with the approved classification.
- `SoftSpoken_Stories/Data/TurtleAreaMeta.lua`: names and valid continent
  assignments for 45 virtual area groups (never uiMapIDs).
- `SoftSpoken_Stories/Compendium/QuestCatalog_112.lua`: renders those
  areas as named sections in the proper continent, or Other Lands when
  no continent is supported. No fake map navigation is attached.
- `scripts/build_tortoise_zone_overlay.py`: reproduces the manifest and
  area names from a pinned Tortoise SQLite snapshot.
- `scripts/reapply_tortoise_zone_overlay.py`: idempotent, manifest-only
  replay onto regenerated Compendium data; rejects missing IDs, changed
  titles and pre-existing conflicting classifications.

A new source import should never turn a Tortoise AreaTable ID such as
`14` into `zones = {14}`. Quest `820` correctly uses
`zones = {1411}` for Durotar. Custom area identifiers are held in
`turtleArea`, which intentionally has different semantics.

Unknown/reused QuestSort codes 21, 241 and 374 retain neutral group labels;
the code does not pretend they are old Vanilla dungeon categories.
QuestSort 371 is Jewelcrafting, grouped under Professions.

## Regeneration and checks

Run:

```sh
python3 scripts/reapply_turtle_quest_catalog.py
python3 scripts/reapply_turtle_quest_catalog.py --check
```

The existing replay script now also replays/checks the committed classification
manifest. No SQLite database is needed for an ordinary reapplication.

The isolated CI pipeline also rebuilds the manifest against the pinned snapshot,
checks Lua 5.1 syntax, runs catalog and speaker/portrait regressions, confirms
the 7,246 quest record count, and checks that prior explicit Turtle removals are
still excluded.

All modifications remain isolated on `audit/tortoise-unclassified-integrity`.
The feature branch is unchanged. In-game confirmation of custom-zone navigation
and any future ClassicAPI-vs-live quest text comparison are distinct tasks.

## Later exception resolution (November 16, 2026)

The **37 held** count above is the original historical audit result. A later [cross-cohort review](turtle_hold_resolution_review.md) adjudicated those 37 alongside 49 shared-ID dialogue holds and eight exclusive text holds. Three independently supported classifications have now been added:

- Quest **708, The Black Box** — `zones = {1418}` (Badlands), existing item starter 4613 and hand-in NPC 2092 preserved.
- Quest **3366, The Glowing Shard** — `turtleArea = 718` (Wailing Caverns), keeping its existing quest relations.
- Quest **41797, A Good Friend** — `turtleArea = 5581` (Northwind), with independently verified source title alias `A Dear Friend`. Its current catalog title and NPC mapping are unchanged.

The effective classification backlog is now **34 held quests**. The original 2,372 selected classifications remain untouched; the three exceptions are replayed separately by `scripts/reapply_turtle_zone_exception.py` from exact reviewed evidence. The [hold report](audits/turtle_hold_resolution/summary.json) distinguishes these from unverified starter/availability and reserved-area cases. Neither category placement nor source presence proves a quest's current live availability.

All changes are on `audit/turtle-touched-text-coverage`, not `main`.
