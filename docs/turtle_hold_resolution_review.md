# Resolution of Turtle availability, area-classification, and quest-dialogue holds

**Branch:** `audit/turtle-touched-text-coverage`  
**Sources:** Frozen pfQuest Turtle import, pinned Tortoise community SQLite `567ce23c73087e9b67fd2d4732c171d751e54bba`, original Vanilla Compendium, independent Classic documentation and OctoWow where specifically noted.

## First: these are 72 unique quest IDs, not 94 missing quests

| Original hold set | Number | Shared overlap |
| --- | ---: | --- |
| Unclassified quest records | 37 | 14 also in shared-ID text holds; 8 also in exclusive text holds |
| Held shared-ID text records | 49 | 14 also in zone holds |
| Held exclusive Turtle quest text records | 8 | All eight also in zone holds |
| **Distinct quest IDs across all three lists** | **72** | |

These cohorts describe different problems: availability evidence, a missing/nonstandard zone/category, old baseline omissions, text/provenance disagreements, and intentionally obsolete records. An available quest is not necessarily one we should fill with a guessed zone or replace with different dialogue.

## 1. Zone/classification holds — 37 reviewed, three resolved, 34 held

| Disposition | Count | Decision |
| --- | ---: | --- |
| **Approved exact title alias** | **1** | **41797**: catalog `A Good Friend`, source `A Dear Friend`; field `turtleArea = 5581` (Northwind) |
| **Approved Classic item-/loot-origin zones** | **2** | **708** `zones = {1418}` (Badlands); **3366** `turtleArea = 718` (Wailing Caverns) |
| Older shared-ID quests without adequate source starter/availability evidence | 13 | Hold: no invented NPC or assumption of live availability |
| Title/quest-identity conflicts | 9 | Hold: includes NYI/retired/source-renamed quests |
| GM Island/reserved location | 7 | Hold: no public map or player-facing quest availability inferred |
| Disabled source Method | 2 | Hold: 8289, 8296 |
| ZoneOrSort zero | 2 | Hold: 60013 `Happy New Year!`, 70010 `Dual Spec` |
| Source AreaTable ID missing | 1 | Hold: 41633 `Bonescythe Ring` has source area 1075 absent from the pinned area hierarchy |
| **Total** | **37** | |

**708** already had starter item 4613 and hand-in NPC 2092 in the Compendium. Its pinned source area is Badlands (3), which maps to existing Vanilla UI zone 1418. This corrects **classification**, not its availability claim. [Classic quest record](https://www.wowhead.com/classic/quest=708/the-black-box).

**3366** is a known item-origin quest from the Glowing Shard dropped by Mutanus in Wailing Caverns. Its source area 718 has an existing named `SSCTurtleAreaMeta` entry. The source lacks a normal spawned-NPC starter because the quest starts from an item, not because it is inherently unavailable. We changed only its browsing classification; we did not invent a starter. [Wailing Caverns quest guide](https://www.wowhead.com/classic/guide/classic-wow-wailing-caverns-dungeon-quests).

**41633:** A missing `AreaTable` entry (1075) is not a valid native map or Turtle virtual area. It is associated with `Echoes of War` and Bonescythe tier-three quests, but using that chain alone to copy a zone would conceal the missing source. Its sister `41632` has source `Blackrock Mountain` despite being a ring from the same raid-related chain; this deserves a separate provenance check. Do not fabricate area 1075.

GM Island quests 40051–40056 and 40747 retain their restricted-location holds. No source database row is proof of public player access.

## 2. Shared-ID text holds — all 49 reviewed; no additional bulk text imports

| Disposition | Count | Meaning |
| --- | ---: | --- |
| **Vanilla baseline omission identified** | **6** | 814, 3581, 7478, 7479, 7480, 7487 appear in Vanilla pfQuest despite cMaNGOS omission; no new Turtle text is justified merely by absence from cMaNGOS |
| **Title suffix / minor spelling variant identified** | **17** | 10 location-specific cloth/wool donation titles plus 7 familiar quest-name variants; quest identity interpretable, but text-stage differences remain held pending independently verified dialogue |
| **Probable quest-ID repurpose** | **5** | 5214, 5641, 5645, 5647, 8249; source refers to a different quest narrative/title; overriding Spoken would be unsafe |
| Insufficient world/spawn evidence for older ID | 13 | Hold as unproven Turtle availability; no inference from source existence |
| Method unavailable or unverified | 6 | Hold rather than silently restore |
| NYI/retired source title | 2 | 636 and 3482 remain held |
| **Total** | **49** | |

An approval of *title equivalence* is **not** approval of quest dialogue replacement. This audit does **not** import any of these 49 source texts; the 17 minor/suffix cases remain on their existing Spoken dialogue while text provenance is still under review. Historical 49-quest audit remains intact.

## 3. Exclusive Turtle dialogue holds — 8 reviewed, one resolved, seven held

**41797 — `A Good Friend` / `A Dear Friend`** is **one quest**: objective delivers Avette Fellwood's letter to Barbara Lee. The current catalog has NPC **228** as starter and **62307** as ender. The pinned Tortoise quest has the **same source IDs**, objective, area **5581 Northwind**, and three nonempty dialogue stages; OctoWow independently corroborates the source name, NPCs and quest objective. [OctoWow quest 41797](https://octowow.st/db/?quest=41797).

- Preserve the original Compendium title `A Good Friend`; record `A Dear Friend` as an approved title alias only.
- Add `turtleArea = 5581`, never treating this AreaTable value as a native `uiMapID`.
- Import its acceptance, progress, and completion dialogue into the **existing** `TurtleQuestText.lua`, with exact stage SHA-256 and character count validation and an idempotent single-quest block.
- Preserve the original `QuestText.lua` and the other high-ID and shared-ID dialogue bytes.
- Protect the seven `[DEPRECATED]` source IDs **40128, 40129, 40132, 41098, 41100, 41103, 41105** from dialogue import. These catalog records are not deleted; a source deprecation marker is a reason to withhold the replacement text.

The single approved exclusive import changes high-ID text coverage from **2,369 to 2,370 quests** while keeping the original roster of 2,377 target IDs and the same 7,246 Compendium quest IDs.

## Reproducibility, safety and status

- [Three-way deduplicated audit summary](audits/turtle_hold_resolution/summary.json)
- [37 zone-by-zone decisions](audits/turtle_hold_resolution/zone_37_resolution.csv)
- [49 shared-ID title/availability decisions](audits/turtle_hold_resolution/shared_49_resolution.csv)
- [Eight exclusive dialogue decisions](audits/turtle_hold_resolution/exclusive_8_resolution.csv)
- [Approved quest 41797 identity and source-stage hashes](audits/turtle_hold_resolution/approved_41797_identity.json)
- `docs/turtle_older_zone_recoveries.csv`: two fixed, exact item-origin classifications with links
- `scripts/audit_turtle_hold_resolutions.py`: regenerate and validate source decisions from SHA-verified SQLite
- `scripts/reapply_turtle_zone_exception.py`: strictly replay three reviewed classifications
- `scripts/import_turtle_approved_alias.py`: validates title alias, NPC identity, objective and stage fingerprints; refuses all other quest records and collisions
- `scripts/import_tortoise_quest_dialogue.mjs`: incorporates 41797 into *both* atomic local reimport and full regeneration
- `tests/test_turtle_held_quest_alias.py`: synthetic hashes, identity mismatch failures, collision refusal, text idempotence and classification replay
- `.github/workflows/turtle-hold-resolution.yml`: read-only pinned source audit, tests, original-Spoken preservation, one-quest import and twice-run SHA check

The former 37 and 8 reports remain as **historical held sets**, while the *effective unresolved counts* are **34 classification holds and seven exclusive dialogue holds**. The 49 shared-ID cases have documented per-quest dispositions; do not treat those as new eligible dialogue without stage-specific verification.

**Source limitations:** This is source-backed/corroborated, not an authenticated snapshot of today's live Turtle WoW server. No held quest was silently restored, no source marker overrode a current curated title, and no existing Vanilla dialogue was rewritten. No changes were merged into `main`.
