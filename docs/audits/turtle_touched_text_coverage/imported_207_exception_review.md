# Stage alignment follow-up for the 207 imported quest texts

**Status:** Read-only review. No production dialogue changed by this report.

## Audit results

All 207 previously added stages were re-compared against the matching and alternative dialogue stages from cMaNGOS Classic, plus available original Spoken stages.

| Baseline similarity category | Count |
| --- | ---: |
| Strong match in same stage | 167 |
| Moderate match in same stage | 5 |
| Other stage more similar (high threshold) | 10 |
| Other stage more similar (moderate threshold) | 2 |
| Low similarity to available Vanilla stages | 23 |
| **Total** | **207** |

**Important:** These numbers are diagnostics, not a count of erroneous imports. The independent cMaNGOS baseline has demonstrable source-ID and stage mismappings. Classic sources confirm that some apparent errors are actually valid quest-stage dialogue:

- [7026 — Ram Riding Harnesses](https://www.wowhead.com/classic/quest=7026): the source's long harness instructions **are** the authentic progress text.
- [8506 — The Alliance Needs More Purple Lotus!](https://www.wowhead.com/classic/quest=8506) and [8527 — The Alliance Needs More Roast Raptor!](https://www.wowhead.com/classic/quest=8527): repeatable collection quests deliberately repeat acceptance instructions during progress.
- [5505 — The Key to Scholomance](https://www.wowhead.com/ptr/quest=5505): the completed-Skeleton-Key passage is documented as **progress**, despite resemblance to another database's completion.

**Do not blindly undo** stages flagged merely by comparison with cMaNGOS.

## Confirmed or strongly demonstrated problem stages already present in the Turtle overlay

| Quest ID | Imported stage | Turtle overlay currently contains | Authentic Classic stage |
| ---: | --- | --- | --- |
| **6283 — Bloodfury Bloodline** | progress | The quest's completion response instead of the actual pre-turn-in response | The NPC discusses Bloodfury Ripper while the quest is still unfinished |
| **8051 — The Eye of Zuldazar** | progress | The text for the *different* quest 8050 ("Welcome ... The Eye of Zuldazar pulses ...") | The 8051 progress text discusses battles against the Gurubashi and imbuing the Eye |
| **8146 — The Maelstrom's Tendril** | progress | The text for quest 8147 ("Even from here I can hear ...") | The 8146 progress text begins with the NPC joking about smelling the player again |

Classic references: [6283](https://www.wowhead.com/classic/quest=6283), [8050](https://www.wowhead.com/classic/quest=8050), [8051](https://www.wowhead.com/classic/quest=8051), [8146](https://www.wowhead.com/classic/quest=8146), [8147](https://www.wowhead.com/classic/quest=8147).

These three are **not** merely cMaNGOS similarity alerts. The imported Turtle stage content was examined directly and compared to quest-specific Classic progress dialogue. They should be corrected in the existing overlay before promoting the audit branch; do not overwrite `SpokenQuestsText`.

## Other records

- The remaining flagged cases have **not** been proven wrong. Eight Cryptstalker quest progress texts all match the authentic shared NPC line despite weak similarity to cMaNGOS.
- War-effort repeatable quests require checking repeat-specific dialogue rather than assuming every acceptance/progress match is a copied error.
- No changes should be bulk-applied based solely on the 207-stage diagnostic scores.

## Reproduction

- [Detailed CSV](imported_207_stage_alignment.csv) and [summary](imported_207_stage_alignment_summary.json)
- [Script](../../../scripts/audit_imported_missing_stage_alignment.py) compares pinned source and stage hashes, without copying or modifying dialogue.

The 35 substantial pre-existing-text conflicts are resolved separately in [adjudication](substantial_35_adjudication.md): 13 Tier 3 candidates to import, 15 shortened text stages to preserve, and 7 wrong source-mapping cases to preserve.
