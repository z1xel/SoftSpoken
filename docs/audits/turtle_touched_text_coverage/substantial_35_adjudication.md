# Case review: 35 substantial Spoken–Tortoise dialogue differences

**Implementation status:** All 13 Tier 3 completion-only overrides have been committed in `TurtleQuestText.lua`. The other 22 substantial-conflict stages retain the original Spoken text. The original 289-case comparison remains a historical audit snapshot.

## 1. Thirteen Naxxramas tier-3 completions: Turtle appears preferable

The existing Spoken corpus uses generic, frequently misspelled fulfillment messages such as `Exellent $N`, whereas the Tortoise snapshot supplies item/NPC-appropriate lines consistent with Classic quest records. This is a meaningful potential improvement, not a Turtle-exclusive storyline edit. **Implemented:** exactly these 13 `complete` stages are now in the Turtle overlay, preserving the original Spoken corpus.

| Quest ID | Quest | Stage | Spoken characters | Tortoise characters |
| ---: | --- | --- | ---: | ---: |
| 9034 | Dreadnaught Breastplate | complete | 98 | 57 |
| 9043 | Redemption Tunic | complete | 91 | 27 |
| 9046 | Redemption Spaulders | complete | 95 | 101 |
| 9057 | Cryptstalker Spaulders | complete | 97 | 141 |
| 9077 | Bonescythe Breastplate | complete | 95 | 157 |
| 9095 | Frostfire Robe | complete | 87 | 122 |
| 9096 | Frostfire Leggings | complete | 91 | 122 |
| 9097 | Frostfire Circlet | complete | 90 | 122 |
| 9098 | Frostfire Shoulderpads | complete | 95 | 122 |
| 9099 | Frostfire Sandals | complete | 90 | 122 |
| 9100 | Frostfire Gloves | complete | 89 | 122 |
| 9101 | Frostfire Belt | complete | 88 | 122 |
| 9102 | Frostfire Bindings | complete | 91 | 122 |

Relevant Classic corroboration: [Dreadnaught Breastplate](https://www.wowhead.com/classic/quest=9034), [Redemption Tunic](https://www.wowhead.com/classic/quest=9043), [Redemption Spaulders](https://www.wowhead.com/classic/quest=9046), [Cryptstalker Spaulders](https://www.wowhead.com/classic/quest=9057), [Bonescythe Breastplate](https://www.wowhead.com/classic/quest=9077), and [Frostfire Robe](https://www.wowhead.com/classic/quest=9095) / [Frostfire Bindings](https://www.wowhead.com/classic/quest=9102). The eight Frostfire completions intentionally reuse the same NPC response.

## 2. Fifteen short or truncated source stages: keep Spoken

Fourteen Tortoise strings are word-sequence prefixes of the original Spoken texts. The remaining quest 8151 is also clearly shortened, with a class placeholder substitution. In each case the Spoken version is much more complete and closer to the independent Vanilla baseline; verified examples match Classic quest pages. **Do not replace these stages merely because the Turtle SQL schema says the field changed.**

| Quest ID | Quest | Stage | Spoken characters | Tortoise characters |
| ---: | --- | --- | ---: | ---: |
| 100 | Call of Water | complete | 115 | 37 |
| 311 | Return to Marleth | complete | 170 | 63 |
| 478 | Maps and Runes | complete | 219 | 42 |
| 510 | Foreboding Plans | complete | 216 | 28 |
| 511 | Encrypted Letter | complete | 193 | 57 |
| 1239 | The Severed Head | complete | 276 | 59 |
| 1268 | Suspicious Hoofprints | complete | 385 | 194 |
| 1953 | Return to the Marsh | complete | 270 | 95 |
| 3914 | Linken's Sword | complete | 128 | 26 |
| 8151 | The Hunter's Charm | complete | 300 | 92 |
| 8233 | A Simple Request | complete | 340 | 87 |
| 8313 | Sharing the Knowledge | complete | 172 | 28 |
| 8419 | An Imp's Request | complete | 175 | 27 |
| 9339 | A Thief's Reward | complete | 151 | 33 |
| 9365 | A Thief's Reward | complete | 151 | 33 |

Examples: 510 contains only the opening stage direction in Tortoise; 3914 only the opening sentence; 1239 and 9339 lose the rest of the NPC's explanation. Classic pages also retain the longer forms for [An Imp's Request](https://www.wowhead.com/classic/quest=8419), [The Hunter's Charm](https://www.wowhead.com/classic/quest=8151), and [A Thief's Reward](https://www.wowhead.com/classic/quest=9339).

## 3. Seven source misassignments: keep Spoken

| Quest ID | Quest | What happened |
| ---: | --- | --- |
| 2603 | Vulture's Vigor | Tortoise acceptance starts with the repeat-quest introduction used under 2602; Classic 2603 has the original Spoken introduction |
| 4727 | Beached Sea Turtle | Tortoise completion describes sea mammals, matching the different Beached Sea Creature quest 4730 rather than 4727 |
| 5538 | Mold Rhymes With... | Tortoise completion contains the text Classic identifies as the quest's *progress* conversation |
| 6283 | Bloodfury Bloodline | Tortoise's progress and completion conversations appear reversed; this also implicates one stage among our earlier 207-stage import |
| 8050 | The Eye of Zuldazar | Tortoise completion is assigned under the other quest's ID (8051) relative to Classic |
| 8051 | The Eye of Zuldazar | Opposite half of the 8050/8051 swap; original Spoken ordering agrees with Classic |
| 8146 | The Maelstrom's Tendril | Tortoise completion corresponds to quest 8147; Spoken 8146 matches Classic 8146 |

Classic cross-checks: [2603](https://www.wowhead.com/classic/quest=2603), [4727](https://www.wowhead.com/classic/quest=4727), [4730](https://www.wowhead.com/classic/quest=4730), [5538](https://www.wowhead.com/classic/quest=5538), [6283](https://www.wowhead.com/classic/quest=6283), [8050](https://www.wowhead.com/classic/quest=8050), [8051](https://www.wowhead.com/classic/quest=8051), [8146](https://www.wowhead.com/classic/quest=8146), [8147](https://www.wowhead.com/classic/quest=8147).

## Implications

- **Do not import all 289 source-conflicting stages.** A stage-level SQL migration is evidence of a source change, not proof that the changed field contains the correct words.
- **Completed:** the 13 Classic-corroborated Tier 3 completion texts were imported into the existing Turtle-only Lua data; the original Spoken dataset is unchanged.
- **Completed:** the three incorrect imported *progress* overrides (**6283, 8051 and 8146**) were replaced with verified Classic-stage text. See [imported stage exception review](imported_207_exception_review.md). Other 204 stages from the 207 batch remain byte-for-byte unchanged.
- **Independent baseline caveat:** the cMaNGOS snapshot disagrees with Classic stage assignments for some repeatables and quest chains. Its numerical similarity scores are not themselves evidence that a source migration is right or wrong.
- Keep the other 22 substantial-conflict stages on original Spoken.
- The remaining 254 cosmetic/minor/moderate cases are separately triaged in [their own review](remaining_254_review.md); none was overridden.

## Technical evidence

See [three-way comparison](substantial_35_three_way.csv), [full list with short side-by-side excerpts](substantial_35_side_by_side.md), and [aggregates](substantial_35_summary.json). Those reports are from pinned source snapshots; the Classic corroboration above is external to that pinned source.

**No quest text was modified while writing this adjudication.**
