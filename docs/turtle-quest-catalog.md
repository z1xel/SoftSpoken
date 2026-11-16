# Turtle Quest Catalog

**Status:** Curated feature-branch snapshot; **not yet integrated into `dev`**.  
**Catalog revision audited:** [`a44bb42dfafcbf1eb498e30e33b5148243cb4e84`](https://github.com/z1xel/SoftSpoken/commit/a44bb42dfafcbf1eb498e30e33b5148243cb4e84).  
**Comparison baseline:** `dev` at `a8f3defcaf02c4f7358199c9da918a7e0a954990`.  
**Last consolidated:** November 16, 2026.  
**Ownership:** SoftSpoken's curated quest corpus and its in-game adapters. This is the **single maintained reference** for the catalog: architecture, source policy, all audit findings, accepted corrections, known exceptions, and the remaining work. Superseded raw reports remain recoverable from Git history, not required for understanding this document.

## 1. Purpose and boundaries

SoftSpoken's quest Compendium is intended to be a **curated, predominantly static Vanilla + Turtle WoW catalog**, available in-game without a live database service or a growing per-user reporting database. The catalog drives quest discovery, chains, categories, places, speaker portraits, stage dialogue and optional playback. It does **not** confer quest availability, create audio files, or modify the server's quest data.

The baseline is **Vanilla**. Approved Turtle records and corrections extend that baseline; **Classic/Era is not an authority for overwriting Vanilla**. Independent Classic references may support a narrowly reviewed exception, but a disagreement between community databases never authorizes automatic replacement. Similarly, the historical mixed Forever/Era upstream source is *not* permission to restore Forever-only content.

The shipping model has three independent dimensions:

1. **Quest identity and relationships** (titles, chains, eligible races/classes, starters/enders, categories and geographic references).
2. **Quest dialogue text**, selected independently for acceptance, progress and completion.
3. **Narration/voice-pack availability**, resolved at playback; catalog presence does not imply an installed recording.

All figures below describe the audited feature-branch snapshot, **not** the untested combination with `dev` and not an assertion about every quest currently playable on a live Turtle server.

## 2. Shipped snapshot: authoritative counts

| Metric | `dev` at baseline | Curated catalog | Meaning |
| --- | ---: | ---: | --- |
| Static Compendium quest IDs | 4,828 | **6,646** | Distinct keyed quest records |
| Original Spoken text records | 4,803 | **4,228** | Original text kept for retained IDs |
| Turtle-specific text quest entries | 0 | **2,593** | 2,370 exclusive-ID + 223 shared/older-ID entries |
| Turtle area metadata entries | 0 | **45** | AreaTable metadata; not 45 new native UI maps |
| Dedicated named instance Map IDs | none | **26** | Central `DungeonNames.lua` lookup |

**Quest-ID reconciliation (4,828 → 6,646):** **2,418 added** (2,377 approved Turtle high-ID quests plus 41 older-ID restorations), **600 removed** (unapproved high-ID records inherited from the mixed Forever corpus), **25 previously present records modified**, and **4,203 previously present records unchanged**. Shared quest titles were not changed by this comparison. The 25 modified records require an explicit final pre-merge field review; do not infer that every inherited Vanilla metadata field has been independently audited.

**Original text reconciliation (4,803 → 4,228):** 575 original Spoken quest-text entries associated with excluded Forever-only IDs were removed. **Retained original dialogue bodies were not rewritten.** New or corrected Turtle text lives in its separate overlay, not in `SpokenQuestsText`.

**Turtle text reconciliation:** 2,370 approved exclusive-ID entries (including quest 41797's verified alias) and 223 low/shared-ID quest entries. The shared-ID import includes **233 stage-specific overrides**: 13 restored stages, 207 formerly missing stages (three independently corrected progress values), and 13 adjudicated Tier 3 completion stages. Quest-entry counts and stage counts are different units; do not add them together.

Older reports cite **7,246** Compendium records and **2,369** exclusive text entries. Those are *historical pre-cleanup/pre-alias numbers*, not the final snapshot.

## 3. Canonical runtime files and load order

The selective production payload comprises **12 runtime file changes** (three new, nine modified) and this document. The data and lookup files are:

| File | Responsibility |
| --- | --- |
| `SoftSpoken_Stories/Data/Compendium.lua` | `SpokenQuestsCompendium`: quest records, relationships, area references, fallbacks |
| `SoftSpoken_Stories/Data/QuestText.lua` | `SpokenQuestsText`: retained original Spoken dialogue |
| `SoftSpoken_Stories/Data/TurtleQuestText.lua` | `SSCTurtleQuestText`: curated, stage-specific Turtle dialogue overlay |
| `SoftSpoken_Stories/Data/TurtleAreaMeta.lua` | `SSCTurtleAreaMeta`: 45 typed AreaTable/zone/instance relationships |
| `SoftSpoken/Compendium/UI/MapNames.lua` | Native UiMap name lookup, including Vanilla battleground IDs 1459–1461 |
| `SoftSpoken/Compendium/UI/DungeonNames.lua` | **Single authority for names** of the 26 known instance Map IDs |

The runtime adapters are:

| File | Responsibility |
| --- | --- |
| `SoftSpoken_Stories/Compendium/QuestCatalog_112.lua` | Indexing, chains, eligibility, grouping, zones and instances |
| `SoftSpoken_Stories/Compendium/QuestsTab_112.lua` | Discovery/voice filters, subtitles, Compendium list presentation |
| `SoftSpoken_Stories/Compendium/QuestPage_112.lua` | Stage text priority, speaker labels, portraits and playback |
| `SoftSpoken_Stories/SpeakerResolver.lua` | Typed giver/ender resolution; live GUID and plural-speaker behavior |
| `SoftSpoken/addon.xml` | Loads the shared map/instance name lookups |
| `SoftSpoken_Stories/addon.xml` | Loads static data before the quest Compendium adapters |

**Load-order invariant:** the shared Compendium and its name lookups must exist before quest UI grouping uses them; `Compendium.lua`, `QuestText.lua`, `TurtleQuestText.lua` and `TurtleAreaMeta.lua` must load before the quest adapters. `SpeakerResolver.lua` reads the catalog lazily, since its module can load before the data files. Both manifests must be merged with the *current* `dev` versions, never replaced wholesale.

No audit Python/Node scripts are needed by the game client. The addon remains compatible with its intended WoW 1.12/Lua 5.0 environment; testing with Lua 5.1 alone does not replace an in-client smoke test.

## 4. Quest record contract

`SpokenQuestsCompendium.quests[questID]` stores a quest's English title at `[1]` and optional metadata. Important fields:

- `zones = { uiMapID, ... }`: one or more **native UI map** IDs.
- `turtleArea = areaTableID`: a separate source **AreaTable** namespace; never use it as a native UI map ID.
- `sort`: quest class, profession, event or other category.
- `dungeon`: an existing **instance Map ID** used for grouping under its entrance zone.
- `prev` and `name`: chain predecessor/name references; retain links only when valid.
- `races`, `classes`: eligibility bit masks; absent means unrestricted by that field.
- `starter`, `starterObject`, `starterItem`: typed starting speaker/interaction origin.
- `ender`, `enderObject`: typed hand-in target; an absent explicit ender can fall back to the starter.
- `starters`, `enders`, `enderObjects`: alternative, plural speaker/interaction candidates.
- `starterAlliance`, `starterHorde`: faction-specific speakers; where no explicit ender exists, the appropriate selected starter also serves as hand-in.
- `npcNames`, `objectNames`, `itemNames`: curated name fallbacks when installed pack metadata supplies no name.

A missing starter or ender is **unknown**, not evidence of an invisible/scripted quest; an absent explicit ender can be deliberate when the starter also receives completion. Never replace a set of possible speakers with an arbitrary single speaker merely to display one portrait. A quest can be statically listed even if its current live-server availability has not been established.

`QuestCatalog_112.lua` builds a Vanilla-friendly hierarchy: Kalimdor, Eastern Kingdoms, Other Lands, class/profession/event/other categories, native zone/dungeon groups and custom Turtle-area groups. Chain links remain data relationships. The UI defaults to discovery filtering; observed quests outside the static catalog can still be shown as encountered/unknown rather than silently disappearing.

## 5. Stage text and narration contract

For **each** `accept`, `progress` and `complete` stage independently, `SSCQuestPage:Text(questID, stage)` uses this precedence:

1. Nonblank per-character **live-captured** dialogue (`SSCQuestJournal.dialogue`).
2. Nonblank curated **Turtle overlay** (`SSCTurtleQuestText`).
3. Original **Spoken** dialogue (`SpokenQuestsText`).
4. No text, if every source lacks that stage.

Missing and whitespace-only overlay stages **do not mask the fallback**. Display expansion supports normal WoW placeholders such as `$N`, `$C`, `$R`, `$B` and `$Gmale:female;`. Preserve placeholder meaning when auditing possible source changes. Some quests legitimately omit stages; no stage should be invented merely to improve a coverage metric.

**Text is not audio.** `DataModules:PrepareSound` uses the installed packs and can select a giver-specific recording or fall back to a generic `questID-accept` / `-progress` / `-complete` recording. The presence of dialogue or a resolved NPC **does not prove** an NPC-matched recording exists.

**Speaker resolution:** `SpeakerResolver:ForQuest` uses explicit typed corpus relationships, faction selection and a legacy pack fallback when appropriate; it deliberately returns no arbitrary speaker for a plural set. `SpeakerResolver:ForSound` prioritizes the actual live interaction GUID where available. Object and item origins stay typed and do not acquire invented creature portraits.

In static Compendium pages with several possible speakers, show the native `Interface\\Icons\\INV_Misc_QuestionMark` portrait and italic *Multiple speakers possible*, preserving known candidates in the tooltip. This is presentation ambiguity only: it must not force a synthetic narrator or discard the live speaker identity.

## 6. Geography, names and instances

There are **three distinct ID domains**, which must never be interchanged:

| ID domain | Example | Correct use |
| --- | --- | --- |
| Native **UiMapID** | `1411` = Durotar; `1459` = Alterac Valley | `zones` and native `MapName` |
| **AreaTable ID** | `718` = Wailing Caverns area; `5581` = Northwind | `turtleArea` with `SSCTurtleAreaMeta` crosswalk |
| Instance **Map ID** | `43` = Wailing Caverns; `409` = Molten Core | `dungeon`, `dungeonMapID` and `DungeonName` |

`SSCTurtleAreaMeta` can supply `uiMapID` (verified native map identity), `dungeonMapID` with `parentZone` (place under an existing named instance group), or a `name` with `continent`, `parentZone`, `parentArea` and optional `instanceType` (standalone Turtle location/dungeon/raid/seasonal node). **Instance names for mapped Vanilla Map IDs live only in `DungeonNames.lua`**; metadata stores relationships and must not duplicate those names.

The final grouping includes reviewed links for **16 AreaTable-to-existing-instance mappings**, with custom Turtle instances remaining their own AreaTable-based groups. Examples include Crescent Grove (5077; Ashenvale), Hateforge Quarry (5098; Burning Steppes), Tower of Karazhan (3457; Deadwind Pass), Timbermaw Hold (5640; Azshara), and Stormwrought Ruins (5628; parent Turtle area Balor, 5561). No fake native instance IDs or invented geographic routes are created.

The original broad zone classification applied **2,372** audited placements (1,258 native zones; 978 named AreaTable places; 136 sorts), followed by **three independently approved exceptions**: quest **708** → Badlands UiMap 1418, **3366** → Wailing Caverns area 718, and **41797** → Northwind area 5581. The historical 37 classifications held for review are now **34 unresolved**. Unverifiable or reserved areas remain unknown; `Other Lands` does not mean all its children are instances.

Do not show a numeric "Dungeon #..." when a verified mapped instance name exists. A missing name should remain an explicit fallback and be reviewed, **not** be fixed by duplicating names in multiple tables. Unknown/reused QuestSort codes 21, 241 and 374 keep neutral labels; QuestSort 371 is Jewelcrafting under Professions.

## 7. Source provenance and cleanup rules

**Pinned research inputs** (historical evidence, not live-server guarantees):

| Input | Pinned reference / role |
| --- | --- |
| Vanilla pfQuest | `shagu/pfQuest` commit `104f35678ca39ab1fb78b655f815cc7016f5e0c8` — Vanilla quest-ID/relationship baseline |
| Turtle pfQuest | `shagu/pfQuest-turtle` commit `0bc7bf4e55d8867a065354da6f386461255e4801` — approved Turtle quest candidates/relationships |
| Tortoise community database | `Xian55/tortoise-db-viewer` commit `567ce23c73087e9b67fd2d4732c171d751e54bba`, snapshot `80f9b3153120` (built Nov 11, 2026) — independent source text, classification and relationship review |
| Turtle world SQL migrations | `tortoise-wow/tortoise-wow` commit `48cb227f2cb698920dc2f60eeadd6546243eb75e`, with 155 reviewed migrations — provenance of source changes |
| cMaNGOS Classic 1.12 | Historical independent baseline, release asset 751034809, SHA-256 `78c08a0b8d0e253d8a094ae830942d0a8b3316ad1a1ebba4be57342bc2c3d0d1` — comparison aid, **not** authority to overwrite Vanilla |
| Original mixed upstream corpus | Forever 1.60.1.70338, Era 1.15.9.69109, Efficient Games `2ae2154` — inherited generator/source history **only**, not a safe unfiltered regeneration target |

**Tortoise is a community reconstruction, not an authenticated export of the live Turtle WoW server.** An SQL record, world spawn or wiki entry is evidence, not conclusive current availability. Original generated headers in `Compendium.lua` still mention the older mixed Forever/Era pipeline; **those instructions are stale for the curated shipped snapshot**.

The cleanup eliminated **600 non-approved high-ID Forever-only quest records**, **575 corresponding original text records**, and **two dangling predecessor links** to excluded records. Protected older-ID Turtle recoveries are not discarded. This was an **ID-level exclusion pass**, **not** a complete field-by-field decontamination of inherited Vanilla metadata. Never claim perfect Forever-free provenance for every remaining field.

**Regeneration policy:** the checked-in Lua corpus is a **curated snapshot**, not something to rebuild casually from upstream. A future generator must explicitly reproduce the approved Turtle roster, source-qualified Forever exclusion list, restored older IDs, reviewed speaker/zone corrections, exact stage overlays, and original-text integrity. Until such a generator and its pinned sources are intentionally maintained, edit only reviewed data and verify an exact diff. The relevant original scripts and manifests remain on historical branches, not in the release payload.

**Redistribution caveat:** upstream source-code licenses and attribution do not by themselves establish permission to redistribute third-party or Blizzard quest prose. Review applicable rights and attribution requirements before publishing bulk imported dialogue; a script flag acknowledging rights is not a license.

## 8. Known holds and nonclaims

These are **different, overlapping audit cohorts**, not quantities to add together:

| Cohort / gap | Snapshot state | Rule |
| --- | --- | --- |
| Geographic classifications | **34** unresolved after 3 of 37 reviewed exceptions were approved | No guessed zone, public availability or invented AreaTable name |
| Missing exclusive-quest speaker roles | **42** held of 62 originally missing: 17 typed object roles without corroborated static spawns; 25 lacking a typed relation | No invented source/ender; preserve identity evidence |
| Plural speaker candidates | **27** audited high-ID quests; 20 genuine alternate-speaker cases and 7 faction-derived cases | Preserve all candidates and live-GUID precedence |
| Shared-ID text/availability holds | **49** individually reviewed, without bulk text import | Do not equate title equivalence or a cMaNGOS omission with a verified text change |
| Exclusive-ID text holds | **7** source-deprecated quest IDs withheld after quest 41797 was approved | Keep catalog records; withhold unverified/deprecated overlay prose |
| Directly supported existing-Spoken text conflicts | **276** remaining stages after the 13 Tier 3 completions were adjudicated | Do not overwrite all 276; prioritize material placeholder/wording changes |
| Installed voice-pack identity | **Not audited end-to-end** | Do not claim that the recording voice matches a static NPC mapping |
| Surviving mixed-source Vanilla metadata | **Not audited field by field** | No blanket provenance/cleanliness claim |

The seven source-deprecated dialogue IDs are `40128`, `40129`, `40132`, `41098`, `41100`, `41103` and `41105`: **they remain in the quest catalog**, but their source-deprecated Turtle dialogue is not imported. Quest **41797** is one identity with catalog title *A Good Friend* and independently corroborated alternate Tortoise title *A Dear Friend*; it retains catalog title, speaker mapping and its three approved Turtle text stages.

Other representative holds: GM Island IDs `40051–40056` and `40747`; unclassified source-zero `60013` and `70010`; missing AreaTable source area 1075 for `41633`; disabled `8289` and `8296`. Multiple-speaker quest `41768` retains both supported enders; `41868` retains a second pfQuest candidate pending stronger evidence rather than silently dropping it.

The original three hold lists (37 area, 49 shared text, eight exclusive text) cover **72 distinct quest IDs**, not 94 distinct missing quests. Historical 289-stage conflicting-text analyses predate the 13 approved completion overrides. The remaining source conflict review includes a narrower group with changed WoW placeholder directives; prioritize it rather than replacing cosmetically different Vanilla text.

## 9. Maintenance and change approval

For every future quest-data change:

1. **Identify the domain**: quest identity, speaker relation, native map, AreaTable classification, instance Map ID, or one particular dialogue stage.
2. **Identify the evidence and version**: pinned source, comparison baseline, in-game observation if available, quest ID and *exact* changed fields. Note unresolved contradictions.
3. **Respect authority boundaries**: preserve existing Vanilla records unless a change has separate approval; keep Turtle-specific text in `SSCTurtleQuestText`; preserve plural and faction-specific relationships.
4. **Apply the smallest data diff**; protect unchanged original `SpokenQuestsText` and catalog titles. Never restore excluded IDs from the mixed upstream dump or add fabricated map IDs.
5. **Validate** Lua syntax/runtime compatibility, exact ID and text counts or justified deltas, missing/dangling relations, classification domains, speaker fallback, per-stage text precedence and plural behavior.
6. **Record the decision in this document** if it changes architecture, counts, a named source, an approved exception or the current hold totals. New audit findings must be incorporated into this document as durable decisions. Raw research artifacts can live on temporary audit branches and in Git history, but must not be required for production maintenance.

Only deliberately reviewed static data belongs in the shipping addon. Do not add user-generated runtime quest databases, network lookups or an automatic reporting mechanism as part of this catalog integration; any future lightweight discrepancy-reporting design is a separate project.

## 10. Selective integration into `dev`

This document is produced **before** the integration branch. The recommended procedure is:

1. Branch from the **current** `dev`, not from the feature head; keep current UI, search, greeting and audio behavior authoritative.
2. Transfer **only** the 12 runtime file changes in `3` and this unified document. For both `addon.xml` files, integrate includes manually: specifically preserve `SoftSpoken/addon.xml`'s newer `UI/Search.lua` and `SoftSpoken_Stories/addon.xml`'s `Data/VanillaGreetingLengths.lua`, as well as the existing `GreetingFirst.lua` and `VoiceOver.lua` behavior.
3. Review the **25 modified shared/Vanilla quest records** separately, including starters/enders, faction fields and links, before accepting their metadata changes.
4. Keep development/import scripts, 71 separately stored historical report files, eight new audit workflows, raw snapshots, and bulk import/audit tests **off `dev`**; the substantive findings from the reports are consolidated in Sections 11–18 below. Add only small, justified runtime regression checks if needed.
5. Verify the merged runtime has exactly the approved catalog/text roster, correctly typed areas/instances, valid voice fallbacks and no regression in unrelated UI, greeting or search behavior.
6. Perform an **actual in-game** test on the intended Vanilla/Turtle client: a Vanilla quest, exclusive Turtle quest, restored shared/old ID, custom dungeon, plural-speaker case, faction-dependent case and all three dialogue stages.
7. Merge into `dev` only after the combined integration is tested and the remaining uncertainties are accepted explicitly. **No production merge is implied by the creation of this document.**

## 11. Audit program: what was examined, and what was actually approved

This section **consolidates the results** of all the quest import, source comparison, classification, text, speaker, exception, and cleanup reports. It is not a pasted archive of CSV/JSON rows. Where a finding is superseded by a later adjudication, the later **approved** state is stated here. The immutable feature revision (`a44bb42`), source SHAs and the repository's Git history preserve low-level evidence if a future investigator needs to recompute one quest.

| Audit workstream | Input and question | Final decision |
| --- | --- | --- |
| Vanilla/Turtle pfQuest comparison | Which quests are truly Turtle candidates and which shared IDs deserve correction? | Retain 2,377 approved exclusive quests; preserve Vanilla baseline; investigate older-ID exceptions separately |
| Tortoise source coverage | Which approved quests have source titles, stages, area, relationships? | Accept appropriately matched source, hold identity/deprecation disagreements |
| Turtle-exclusive import | Which starters, enders, faction rules and old restorations can be used? | Static curated relationships; no arbitrary inference from quest chains |
| World-SQL availability and classification | Is a quest source-backed, linked to a spawn, categorized and mappable? | 2,372 initial placements plus three exception approvals; unresolved classifications remain unknown |
| Instance-group reconciliation | Can area IDs be associated with existing dungeon Map IDs? | 16 validated crosswalks; separate custom Turtle instance nodes; one central name table |
| Speaker exception audit | Which missing roles are corroborated, and what about plural speakers? | 20 roles corrected; 42 withheld; plural mappings preserved |
| Turtle-touched shared-ID text audit | Which old-ID dialogue stages are genuinely supported as changes? | 233 stage overrides only, with corrections; 276 directly supported conflicts still retained on Spoken |
| Stage-alignment and text-conflict adjudication | Are imported stages correct? Is source text truncated or misplaced? | Three progress repairs, 13 Tier 3 completion improvements; no blanket overwrite |
| Combined hold adjudication | Which cross-audit holds overlap or can be resolved? | 72 distinct quest IDs in original hold union; three zone approvals and one formerly held exclusive-text approval |
| Forever cleanup | What non-approved mixed-source content must be removed? | Exclude 600 quest IDs, remove 575 original text entries, repair two dangling chain references |
| Final integration audit | Which development assets are actually needed in the game? | Ship 12 runtime changes plus this consolidated document, not all 131 changed files |

The historical workstreams overlap substantially. **Their counts cannot be summed into a number of missing quests**. A quest may simultaneously have an uncertain zone, unknown NPC starter and pending stage text.

## 12. Quest roster, Vanilla provenance and Forever cleanup

### 12.1 Approved Turtle roster

The frozen Turtle-specific pfQuest extraction contained **2,451 high-ID candidate records**: **2,247 imported**, **130 already present**, and **74 excluded** as retired, dummy, disabled or otherwise nonplayable source records. This yields the **2,377 retained Turtle-exclusive target records** used across subsequent Turtle audits. Source inclusion is *not* proof of contemporary live-server playability.

The final 2,418 added catalog records comprise those 2,377 plus **41 previously absent older-ID records**. The older-ID corpus includes specifically reviewed restorations **820, 3578, 3579 and 3580**; the overall count of 41 does not mean all were observed live. Historical Vanilla-pfQuest comparison treated **4,433 IDs** as its independent baseline inventory. The historical shared-ID import review also preserved **146 explicit removal markers** and excluded one internal-only flag rather than restoring them as ordinary quests.

**Quest 820, *What Do You Rely On?*** is an important representative case: original Vanilla quest ID, Turtle source category 14 (Durotar AreaTable), confirmed typed and spawned starter NPC 3304, precursor 818, reviewed native `zones = {1411}` and independent user-observed in-game existence. It is not to be mistakenly hidden merely because it was absent from one independent Vanilla reconstruction.

The catalog remains structurally Vanilla-first. Quest-title matches or an NPC in an alternate database are **evidence for review**, not permission to replace established Vanilla speaker relations, racial/class restrictions or dialogue. In particular, quest IDs **109, 1361, 2954, 5125 and 5402–5408** were among those explicitly identified for attention in the 25 modified existing-record comparisons. Complete field-level review of *all 25* is a pre-merge gate.

### 12.2 Forever exclusion pass

The final sweep of the old mixed upstream corpus removed:

- **600** high-ID quest records absent from both approved Turtle and pinned Vanilla sets;
- **575** associated original Spoken text records;
- **two** now-invalid chain predecessor references pointing to deleted records.

This changes the static roster from the **historical 7,246-record intermediate corpus** to **6,646**. Retained Spoken dialogue is unchanged byte-for-byte even though `QuestText.lua` has a different Git blob. The old generated `Compendium.lua` header referring to a Forever/Era build is obsolete for regeneration.

The exclusion rules are **source-qualified**, not a numeric cutoff: Turtle legitimately uses high quest IDs, and some older-ID restorations must be protected. The exact 600-ID deletion manifest and old Vanilla ID list remain in the historical Git revision if a future regeneration requires precise row-level provenance; they should not be restored into `dev` as standalone report files.

**Limit:** the cleanup does not establish that every race mask, zone, quest category, quest chain or speaker on pre-existing Vanilla IDs is free of inherited Forever/Era data. A field-by-field provenance audit of those residual fields remains separate future work.

## 13. Tortoise source coverage and exclusive dialogue

### 13.1 Source coverage among 2,377 retained Turtle-exclusive quests

| Pinned source metric | Count |
| --- | ---: |
| Quest template and title present | **2,377** |
| Nonblank acceptance/details | **2,303** |
| Nonblank progress/request-items text | **2,311** |
| Nonblank completion/offer-reward text | **2,369** |
| All three dialogue stages present | **2,233** |
| Nonzero source zone/category | **2,375** |

The initial title comparison found **2,346 byte-exact title matches**, **23 typography/whitespace-normalized equivalents** and **eight held identities**. The last eight were seven source-deprecated records and **41797** with a different title. Later independent source-identity work approved 41797, so the final exclusive dialogue destination contains **2,370 quest entries** and the remaining seven deprecated-source texts are withheld.

Missing stage text may be intentional; do not fill blank acceptance or progress stages with an imagined line. A Tortoise source text match is still **not** authentication that the same text is currently presented on a live Turtle client.

### 13.2 The 41797 identity decision

**41797 — *A Good Friend*** in the curated catalog and *A Dear Friend* in the Tortoise source represent the same quest, not two quests. The reviewed objective delivers Avette Fellwood's letter to Barbara Lee; starting NPC **228**, ending NPC **62307**, and area **5581 Northwind** align across independent references including OctoWow.

**Approved:** retain the catalog name *A Good Friend*; note *A Dear Friend* as a source alias; classify under Northwind; add only the exactly verified `accept`, `progress` and `complete` source stages into `TurtleQuestText.lua`. Do not change the base title or existing mapped speakers.

**Withheld source-deprecated dialogue (seven IDs):** `40128`, `40129`, `40132`, `41098`, `41100`, `41103`, `41105`. Their existing catalog quest records are **not deleted**; only the unapproved Turtle prose is excluded.

### 13.3 Redistribution and source certainty

The Tortoise viewer SQLite comes from a **community restoration**; the Turtle SQL/155 migrations establish provenance but not direct server authority. Code licensing (including AGPL) does **not automatically authorize redistribution of every piece of copied quest prose**. Before shipping bulk dialogue to the public, separately establish text redistribution and attribution requirements. Neither a source title match nor an `--acknowledge-rights` command-line switch settles that issue.

## 14. Quest availability, geography and instances

### 14.1 Classification audit

The historical pre-cleanup corpus had **2,409 existing unclassified quest records**: 2,377 retained Turtle-exclusive and **32** older/shared IDs. A read-only availability pass compared SQL `Method`, titles, starter relationships, source spawn records and zone/category fields. **2,372 classifications** were accepted, and **37** were originally held.

| Approved placement | Count | Meaning |
| --- | ---: | --- |
| Native `zones = {uiMapID}` | **1,258** | Verified direct or ancestor Vanilla UI-map crosswalk |
| Named `turtleArea = AreaTableID` | **978** | Valid non-native area kept in its own namespace |
| Quest `sort` category | **136** | Legitimate class/event/profession or special category |
| **Initial total** | **2,372** | 2,359 exclusive + 13 world-linked older/shared IDs |

The 37 original holds were later reviewed separately. **708** (*The Black Box*) was placed in Badlands with `zones = {1418}`; **3366** (*The Glowing Shard*) was placed in Wailing Caverns with `turtleArea = 718`; **41797** received `turtleArea = 5581` (Northwind). No new quest IDs were introduced by these three placements. **34 classifications remain unresolved.**

**The 34 outstanding geographic records, grouped by reason:**

| Reason | IDs (count) | Required standard |
| --- | --- | --- |
| Older shared-ID quest with no sufficiently corroborated live/spawned starter | 908, 909, 1157, 1158, 1289, 1318, 1390, 5659, 6000, 6165, 8793, 8794, 9247 (**13**) | Do not infer an available public quest from source presence |
| Title/identity/retirement conflict | 636, 3482, 40128, 40129, 40132, 41098, 41100, 41103, 41105 (**9**) | No guessed category for a different/retired source identity |
| GM Island or restricted area | 40051–40056, 40747 (**7**) | No assumption of public area or accessibility |
| Disabled source Method | 8289, 8296 (**2**) | No playability or zone restoration based on disabled template |
| Zero/absent zone/category | 60013, 70010 (**2**) | No made-up zone or sort |
| Missing source AreaTable template | 41633 (**1**) | Area 1075 has no supported crosswalk; do not copy a sibling quest's zone |

These groups account for **34**, not 37. Quest **41633, *Bonescythe Ring*** has source area ID 1075, absent in the pinned hierarchy; borrowing the region of companion **41632** (*Blackrock Mountain* in the snapshot) would conceal a source problem. The seven restricted-area cases are retained without claiming that a player can reach or accept them.

**Other important classification decisions:** positive source AreaTable IDs (e.g. 14 for Durotar) must be translated to valid Vanilla UiMapIDs (Durotar = 1411) or stored in a named `turtleArea` slot. They must not be written directly into `zones`. An unsupported name belongs under a neutral unknown/Other Lands grouping, not a fabricated `Dungeon #` or a made-up route. Previously reused QuestSort IDs **21/241/374** get neutral labels; **371** means Jewelcrafting.

### 14.2 Existing Vanilla instance crosswalk (16 reviewed relationships)

The **AreaTable → instance Map ID** pairings used by the runtime metadata are:

| AreaTable ID | Instance Map ID | Name |
| ---: | ---: | --- |
| 209 | 33 | Shadowfang Keep |
| 717 | 34 | Stormwind Stockade |
| 718 | 43 | Wailing Caverns |
| 719 | 48 | Blackfathom Deeps |
| 721 | 90 | Gnomeregan |
| 722 | 129 | Razorfen Downs |
| 796 | 189 | Scarlet Monastery |
| 1477 | 109 | Sunken Temple |
| 1581 | 36 | Deadmines |
| 1583 | 229 | Blackrock Spire |
| 1584 | 230 | Blackrock Depths |
| 2017 | 329 | Stratholme |
| 2100 | 349 | Maraudon |
| 2557 | 429 | Dire Maul |
| 2677 | 469 | Blackwing Lair |
| 2717 | 409 | Molten Core |

Names for those instance Map IDs live in **`SoftSpoken/Compendium/UI/DungeonNames.lua` alone**, which includes **26** dedicated native instance names. `TurtleAreaMeta.lua` supplies crosswalk relationships and entrance zones, not a competing copy of the names.

**Custom Turtle instances** remain AreaTable-indexed and attach beneath their verified parent area or entrance zone:

| AreaTable ID | Instance | Type | Parent |
| ---: | --- | --- | --- |
| 3457 | Tower of Karazhan | raid | Deadwind Pass 1430 |
| 5077 | Crescent Grove | dungeon | Ashenvale 1440 |
| 5087 | Stormwind Vault | dungeon | Stormwind City 1453 |
| 5098 | Hateforge Quarry | dungeon | Burning Steppes 1428 |
| 5130 | Winter Veil Vale | seasonal | Dun Morogh 1426 |
| 5601 | Dragonmaw Retreat | dungeon | Wetlands 1437 |
| 5628 | Stormwrought Ruins | dungeon | Balor AreaTable 5561 |
| 5640 | Timbermaw Hold | raid | Azshara 1447 |
| 5641 | Windhorn Canyon | dungeon | Thousand Needles 1441 |
| 5734 | Frostmane Hollow | dungeon | Dun Morogh 1426 |

A custom Turtle instance does **not** magically gain a native Map ID. `instanceType` distinguishes dungeon, raid and seasonal classifications, while `parentArea` handles nesting under another Turtle-only area. This is classification of known quest relationships, **not** a claim of complete Turtle dungeon/raid quest coverage.

## 15. Speaker, giver, ender and audio audits

### 15.1 Recovered speaker roles

Across the **2,377** approved high-ID quests, the original relationship manifest lacked **31 starter** roles and **31 ender** roles, overlapping across **36 quests**. **20 of 62** roles (nine starters and 11 enders, across 11 quests) were supported by typed relationships **and matching recorded NPC spawn evidence**, then corrected in the curated catalog:

| Quest ID | Verified correction |
| --- | --- |
| 41734 | Ender **6868**, Jarkal Mossmeld; existing item starter preserved |
| 41908–41909 | Starter and ender **62851** |
| 41912 | Starter **62986**, Ar'lia; ender **62920** |
| 41913 | Starter and ender **62920** |
| 41914 | Starter **62920**; ender **62986** |
| 41915 | Starter **62986**; ender **62850**, Moro'gai K'la |
| 41916 | Starter and ender **62850** |
| 41917 | Starter **62850**; ender **62986** |
| 41922 | Starter **62863**; ender **91781** |
| 80381 | Ender **80999**; starter still unknown |

Three specific name fallbacks (**6868**, **62986**, **62850**) were source-checked. Installed pack names override these table fallbacks. These additions do not alter quest title, race/class eligibility or area metadata.

### 15.2 The remaining 42 roles

| Reason | Roles | Examples and disposition |
| --- | ---: | --- |
| Typed world-object links lack a corroborated static object spawn | **17** | `41923–41926` Stone of Dreams objects **2020302–2020305** (eight starter/ender roles); `41929` ender object **2020306**; `42002–42005` source objects **2020329–2020331** (seven roles); `42036` ender **2020340** |
| No typed source relationship, or only inconclusive chain references | **25** | `40820–40821` Karazhan IV/V; `41955` Tricolored Hide-ra; `40749`, `41652`, `80381` one-sided gaps; `50322/50323/50331/50332` WANTED quests with possible but unverified notices; `41261`, `41954`, `60013`, `70010`, `80735/80736` |

Do **not** automatically infer a notice-board starter, a copy from a parallel faction chain, a scripted interaction or an intentionally hidden NPC. Some object links may be spawned on demand, but the pinned snapshot does not establish that. The historical **36 quests/62 missing roles** and present **42 unresolved roles** measure different stages of the same audit.

### 15.3 Plural speakers and recordings

**27 of 27** original high-ID multi-speaker candidate sets were preserved in the runtime mapping. **Seven** are faction-dependent `60030–60036` quests, using Alliance starter **51292** or Horde starter **51293**; **20** have genuine alternative speaker sets. The 27 starter sets match the pinned source; 25 of 27 ender sets also match exactly.

Two exception decisions matter:

- **41768 — The Messenger Of Northwind:** retain both ender NPCs **1749** and **62682**, corroborated independently even though the Tortoise snapshot listed just one.
- **41868 — Shadow Curse:** retain enders **62395** and **62422** in the current corpus; the extra **62395** still lacks sufficient independent confirmation, so it remains pending instead of being silently dropped.

The static page shows a **question-mark icon** and *Multiple speakers possible*; its tooltip can list the candidates. In live playback, a real interaction GUID takes priority. The bundled `SSS_VOFallback` contains **no giver-index coverage for the 27 plural high-ID quests**. Installed third-party audio packs and their actual voice files were not available during the audit: speaker metadata validation **does not prove a matching actor/recording**.

Recommended live audio checks: a single recovered speaker, **41768** (two possible enders), **42098** (three), and a `60030` faction-dependent example, recording the live GUID, selected audio filename and heard voice.

### 15.4 Selected restored older-ID speaker decisions

Historically reviewed examples include: **236** (starter **888**, ender **2142**), **810/811** (starter and ender **3189**), **3111** (starter **658**, ender **60516**), **3581** (starter **3387**, ender **8664**), **6131** (starter/ender **11554**), **8290** (starter/ender **14733**) and **8295** (starter/ender **14781**). These were individually corroborated with historical/alternative quest references; they are **not** general license to import Classic metadata wholesale. Where a source itself lacks typed relationships, separate historical corroboration must remain explicit.

## 16. Turtle-touched shared-ID dialogue: review and actual imports

### 16.1 Scope of the audit

This audit addressed the **older/shared-ID** quest cohort; it deliberately excluded the separately managed 2,377 Turtle-exclusive quests. Only source migration evidence, independently reviewed restored quests or convincing new-ID-plus-world-spawn evidence could make a stage actionable. A pfQuest metadata change alone, or cMaNGOS missing an old quest, is insufficient.

The historical source comparison yielded **760 potential changed/restored older-ID quests**, of which **49** were held for identity/availability/method reasons and **711** were selected for stage review (**2,133** stages). The broad diagnostic detected **366** possible gaps, including **90** lacking direct stage-specific provenance; the stronger actionable set was examined separately. **977** differences between community databases were rejected as uncorroborated Turtle changes.

The 49 original held records were all adjudicated at the *disposition* level; **that does not mean 49 replacement texts were approved**. Their categories are:

| Outcome | Count | IDs / reason |
| --- | ---: | --- |
| Omission in cMaNGOS but **present in Vanilla pfQuest** | **6** | **814, 3581, 7478, 7479, 7480, 7487**; no automatic new text |
| Title qualifier/minor spelling recognized, **text still held** | **17** | **7795, 7800, 7805, 7811, 7813, 7818, 7823, 7824, 7833, 7836, 8044, 8141–8144, 8148, 8293** |
| Probable quest-ID repurpose | **5** | **5214, 5641, 5645, 5647, 8249**; original and Turtle quest identities differ |
| Insufficient spawned-starter/availability evidence | **13** | **810, 811, 908, 909, 1157, 1158, 1289, 1390, 3366, 5659, 6000, 6131, 6165** |
| Disabled/unverified source Method | **6** | **236, 1288, 3381, 7668, 8289, 8296** |
| NYI/retired source identity | **2** | **636, 3482** |

Classification approval **3366** is not proof of its general NPC quest availability: it is a known **item-origin** quest. A title suffix difference (e.g., a city-specific runecloth donation) establishes a plausible identity, **not** source dialogue accuracy. An apparently reused quest ID requires a different authority model; never overwrite old Spoken text with content belonging to a different narrative.

### 16.2 Exactly what text changed

The following **233 shared-ID stage-specific overrides** were accepted into `SSCTurtleQuestText`:

1. **13** independently supported stages for restored quests: **820** (three stages), **3111** (acceptance only), and **3578/3579/3580** (three stages each).
2. **207** initially missing stages on older/shared IDs: **204 progress** and **three completion**, across **206** quest IDs. Three progress stages in that batch were later corrected without touching its other 204.
3. **13 completion-only improvements** for Naxxramas Tier 3 quests: **9034, 9043, 9046, 9057, 9077, 9095–9102**.

The **three verified progress repairs** were **6283** (*Bloodfury Bloodline*; source used turn-in response rather than pre-completion dialogue), **8051** (*The Eye of Zuldazar*; wrong adjacent quest 8050), and **8146** (*The Maelstrom's Tendril*; mixed with 8147). Their corrected text is in the Turtle overlay with normal Vanilla display tokens, not written into the original Spoken table.

A follow-up alignment audit of the 207 imported stages had: **167 strong same-stage matches**, **five moderate matches**, **ten high-confidence apparent other-stage matches**, **two weaker other-stage alerts**, and **23 low-similarity entries**. These were comparison *signals*, not 40 wrong imports: some repeatables legitimately repeat instructions; cMaNGOS itself contains stage mismappings. Notable false alarms include **7026**, **8506**, **8527**, **5505**, the eight Cryptstalker progress responses, war-effort repeatables and four Atiesh variants.

### 16.3 Conflict analysis and why the remaining text was not overwritten

The historical **289 conflicting original-Spoken stages** were **11 acceptance**, **278 completion**, **zero progress**. Similarity screening found:

| Type | Historical cases | Disposition |
| --- | ---: | --- |
| Punctuation, whitespace or placeholder casing | **163** | Retain Spoken |
| Minor wording | **76** | Do not automatically override |
| Moderate wording | **15** | Preserve likely truncations; review others |
| Substantial differences | **35** | 13 Tier 3 completions approved; other 22 keep Spoken |

After the 13 approved Tier 3 completions, **276 directly supported existing-Spoken conflicts remain without a Turtle override**: **11 acceptance, 265 completion**. These are review candidates, not 276 known errors.

For the **35 substantial** historical differences:

- **13 Tier 3 completion responses** were accepted because the source had more appropriate class/item dialogue than generic or misspelled original Spoken replies: **9034, 9043, 9046, 9057, 9077, 9095–9102**. All eight Frostfire completions intentionally use one shared response.
- **15 source-shortened completions** were **rejected** to protect fuller original text: **100, 311, 478, 510, 511, 1239, 1268, 1953, 3914, 8151, 8233, 8313, 8419, 9339, 9365**.
- **Seven source misassignments** were **rejected**: **2603** (another quest's introduction), **4727** (sea-creature response), **5538** (completion populated with progress), **6283** (stage inversion), **8050/8051** (cross-ID mixup), and **8146** (8147's response). The specific imported progress mistakes for 6283/8051/8146 were separately corrected.

For the remaining **254 non-substantial** historical cases, the decisions were **163 cosmetic retain**, **57 minor placeholder-sequence review**, **19 minor prose review**, **11 moderate likely truncation retain**, **four moderate context review**. Across those 254, **72** have changed case-normalized WoW directive sequences and should be prioritized over simple `$n` vs `$N` differences. Examples for targeted context review: **194** gender token, **3801/3802** ghostly voice cues, **117** line breaks, **1758** conversational wording, **8221/8224** fish quest family, **9322** Midsummer phrasing.

Shared text should be examined in **families**, not only by ID: War Supplies Signet, Darkmoon-ticket returns, Arathi Basin repeatables, Atiesh variants and the Frostfire Tier 3 family have repeated identical text. The 254-case audit found **19 duplicate-source clusters covering 73 conflict rows**.

**Important:** a source SQL migration changing one dialogue column is evidence of a changed database, **not** proof of new Turtle-authored prose or better content. A drastically shorter record may be truncated; a shifted `$G`/`$C`/`$N`/`$R` directive may be material even when character similarity is high. Never bulk-replace the original Spoken text from one community reconstruction.

## 17. Holds, remaining work and validation gates

### 17.1 Counting rules

The three original review cohorts contained **37 geographic**, **49 shared-ID text** and **eight exclusive-ID text** holds, but only **72 distinct quest IDs** after overlaps (14 geographic/shared overlaps and all eight exclusive-text IDs already present in the geographic list). The later approved actions were **three geographic placements** (708, 3366, 41797) and **one exclusive text-identity approval** (41797). The final unresolved counts are therefore **34 geographic classifications**, **seven deprecated-source exclusive texts**, **42 speaker roles**, plus outstanding shared text provenance and **276** source-supported conflict *stages*. These measures refer to different dimensions and must not be added together.

### 17.2 Reproducibility and technical tests

The historical development branch contains scripts to replay approved roster, exclusions, area, names and speaker decisions and to verify the resulting curated dataset (notably `scripts/reapply_turtle_quest_catalog.py --check` and `scripts/clean_forever_quest_data.py --check`). Their outputs and pinned manifests were used as **development verification**, not required runtime dependencies. They may remain recoverable from feature/audit commit history once separate reports/scripts are removed from the production branch.

The old `turtle-touched-text-audit.yml` workflow used a mutable cMaNGOS `latest` URL with a stale fixed SHA. **Do not describe its full regeneration step as a passing integration gate** until it is repinned to an immutable release or the historical release asset is recovered. Other catalog-source and Lua integrity checks passed in their respective audited branches; **the combined `dev` integration has not passed yet**.

Before accepting the new production catalog:

1. Confirm exact **6,646** quest IDs, **4,228** retained original text IDs, **2,593** Turtle text quest entries, **45** area records and **26** instance name Map IDs; reject accidental source drift.
2. Compare original retained Spoken dialogue byte-for-byte; verify no excluded Forever-only IDs or dangling links return.
3. Perform a **field-by-field diff on all 25 modified shared records**, especially old Vanilla starter/ender, faction and chain metadata.
4. Verify `zones`/`turtleArea`/`dungeon` are never confused; check known crosswalks, 34 unresolved locations, and proper city/continent and dungeon grouping.
5. Verify accepted stage overrides, blank-stage fallback, WoW substitution directives, dialogue/voice-pack separation, typed items/objects, alternate speaker sets, live-GUID priority and faction-specific speakers.
6. Preserve `dev`'s newer search and greeting includes, `GreetingFirst.lua`, `VoiceOver.lua`, and related presentation/audio behavior.
7. Smoke-test in the intended Turtle/Vanilla 1.12 client: a native Vanilla quest, a Turtle-exclusive quest, an old-ID restoration, a named Vanilla dungeon, a custom Turtle instance, plural speakers, faction differences and at least one stage per `accept`/`progress`/`complete`.
8. Validate against actual installed voice packs; static mappings alone do not certify that the played recording fits the interacting NPC.
9. Separately resolve redistribution/attribution issues for bulk quest text before any public release.

### 17.3 Deferred improvements (not part of this integration)

A future entity-based quest schema could make provenance and overrides first-class, avoiding the present curated snapshot/replay architecture. The broader ambition is near-perfect static coverage with **small opt-in discrepancy reporting** from actual game interactions, **not** continuously growing per-user quest databases or client-side repairs from arbitrary live network lookups. These remain design proposals, not implemented features or conditions for this branch merge.

Outstanding scientific/editorial questions include live Turtle quest availability, the source-backed object relations without static spawn proof, residual mixed-corpus metadata, audio-file/actor verification, important placeholder-sequence conflicts and future Turtle patch drift.

## 18. Documentation ownership and safe removal of the old reports

**This file is the authoritative self-contained documentation.** It contains the final numbers, the history of major audit conclusions, accepted quest/field decisions, named exception IDs, source pins, integration rules, and unresolved investigation areas. A developer should not need to open a historical CSV just to understand the architecture, why a correction was accepted, what is held, or what the next action is.

The original **71 files** consisted of **43 CSVs, 14 JSONs, 13 Markdown reports and one Vanilla ID inventory TXT**. Their contributions are consolidated above by topic:

| Former report family | Consolidated here |
| --- | --- |
| Turtle exclusive imports, shared-ID coverage and original source validation | `12–13` |
| Tortoise SQL presence, Method/spawn and zone overlays | `14` |
| Dungeon/raid name and area relationship review | `14.2` |
| Recovered starters/enders and plural-speaker verification | `15` |
| Turtle-touched quest text, first-stage imports, 207-stage alignment and Tier 3 cases | `16` |
| 289 conflicts, 35 substantial, 254 remaining and WoW placeholder analysis | `16.3` |
| Original 37/49/8 hold review and cross-cohort disposition | `14.1, 16.1, 17.1` |
| Forever-only exclusion, catalogue replay and validation summaries | `12.2, 17.2` |

**Intentional scope choice:** this is a *consolidation of information and decisions*, **not** a dump of every automatically generated quest row, text fingerprint or source comparison CSV. The operational records themselves are already embodied in the shipped Lua databases; historic row-level evidence remains retrievable from Git's immutable commit **`a44bb42dfafcbf1eb498e30e33b5148243cb4e84`** if required for an investigation. The raw reports are therefore **not runtime assets and should not be copied into `dev`**.

Once the consolidated document is reviewed, the 71 redundant standalone reports can be **deleted from the integration branch** without destroying their Git history. This consolidation does not authorize deleting unrelated existing project-wide documentation (`docs/ARCHITECTURE.md`, audio docs, UI docs, art sources, etc.). No historical files have been deleted as part of this documentation update.

**Pinned source anchors for exceptional verification:** [Vanilla pfQuest](https://github.com/shagu/pfQuest/tree/104f35678ca39ab1fb78b655f815cc7016f5e0c8), [Turtle pfQuest](https://github.com/shagu/pfQuest-turtle/tree/0bc7bf4e55d8867a065354da6f386461255e4801), [Tortoise viewer snapshot commit](https://github.com/Xian55/tortoise-db-viewer/commit/567ce23c73087e9b67fd2d4732c171d751e54bba), [Turtle SQL migrations](https://github.com/tortoise-wow/tortoise-wow/tree/48cb227f2cb698920dc2f60eeadd6546243eb75e), and the [immutable feature-branch audit revision](https://github.com/z1xel/SoftSpoken/tree/a44bb42dfafcbf1eb498e30e33b5148243cb4e84).

**Final principle:** the cleaned quest databases describe **what the game should display**; this document explains **why and how**. Historic intermediary analyses do not supersede the final approved state.
