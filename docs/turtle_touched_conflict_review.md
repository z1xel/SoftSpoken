# Review of 289 conflicting shared-ID quest dialogue stages

**Branch:** `audit/turtle-touched-text-coverage`  
**Scope:** 289 source-migration-backed stages with nonempty original Spoken text, no Turtle override, and different pinned Tortoise source text. **No text was replaced by this review.**

## What the full comparison found

| Stage | Count |
| --- | ---: |
| Completion | 278 |
| Acceptance | 11 |
| Progress | 0 |

| Heuristic edit category | Count |
| --- | ---: |
| Punctuation, whitespace or WoW placeholder case | 163 |
| Minor wording (character similarity ≥0.92) | 76 |
| Moderate wording (0.70–0.92 similarity) | 15 |
| Substantial difference (below 0.70 similarity) | 35 |
| **Total** | **289** |

The WoW directive audit also distinguishes **259 literal directive-spelling changes**:
**155 change only the case of one-letter codes**, while **104 change the
case-normalized directive sequence** (for example adding, removing or
reordering a game placeholder). These numbers overlap the wording categories,
rather than adding more quests. In particular, a difference in `$B` /
`$b` spelling is not by itself evidence of new dialogue; changing a
`$G` gender directive may be more consequential.

**These are text-difference classifications, not proof that Turtle deliberately revised Vanilla prose.** Each stage also has evidence of a Turtle SQL migration affecting the corresponding dialogue column, but the pinned sources are community snapshots, not authenticated live-server exports.

Among the 35 substantial cases, **20 have shorter Turtle dialogue** and **15 have longer Turtle dialogue**. Of the 20 reductions, **15 remove over 100 characters** relative to original Spoken. Replacing all 289 blindly would discard whole paragraphs in several quests.

## Specific cases worth human review

| Quest ID | Quest | Observation | Review priority |
| ---: | --- | --- | --- |
| 32 | Rise of the Silithid | Mostly `$n` versus `$N`; no material change to prose | Low |
| 3801 / 3802 | Dark Iron Legacy | Turtle adds a spoken-by-a-ghost stage direction at the beginning | Check if useful for narration |
| 3914 | Linken's Sword | Original 128 characters; Turtle 26 | High: apparent truncation |
| 100 | Call of Water | Original 115 characters; Turtle 37 | High: apparent truncation |
| 1239 | The Severed Head | Original 276 characters; Turtle 59 | High: apparent truncation |
| 2603 | Vulture's Vigor | Acceptance has 505 characters in Spoken vs 233 in Turtle and very different wording | High: source/version mismatch possible |
| 5538 | Mold Rhymes With... | Turtle completion adds 244 characters vs Spoken | High: potential new material |
| 9095–9102 | Frostfire armor quests | Eight substantially different completions reuse one identical Turtle text | Review as one family before per-ID overrides |
| 8050 / 8051 | The Eye of Zuldazar | Text lengths reverse direction across adjacent IDs | Check candidate pairing, do not infer a swap |

## Why family grouping matters

The source-SHA report contains **22 duplicate-text clusters covering 85 conflict rows**. These include ten War Supplies Signet quests, nine Darkmoon-ticket rewards, and eight Frostfire armor turn-ins. Repeated template dialogue makes the raw number of quest IDs a poor measure of editorial work. Review these families together.

## Recommended next actions

1. **Keep all 163 cosmetic/placeholder-case conflicts untouched.** Existing Spoken text remains perfectly usable unless a specific token or grammatical issue is established.
2. **Review the 35 substantial cases first**, prioritizing apparent truncation and cross-quest/version mismatch. Preserve richer original content unless Turtle source and live interaction establish an intended correction.
3. **Review the 15 moderate cases** and the 76 minor cases with attention to game variables (`$N`, `$C`, `$B`, `$G`); fixing variable substitutions can matter even where text similarity is high.
4. Only add **stage-specific** Turtle overrides for independently justified differences. Never rewrite the original `SpokenQuestsText` corpus.

## Reproducible review outputs

- `docs/audits/turtle_touched_text_coverage/conflict_review.csv`: per-quest stage, character similarity, text-length difference, token differences and source SHA-256.
- `docs/audits/turtle_touched_text_coverage/conflict_review_examples.md`: short original-vs-source excerpts.
- `docs/audits/turtle_touched_text_coverage/conflict_review_summary.json`: aggregates.
- `scripts/analyze_turtle_conflicting_dialogue.py`: full validation and comparison from the pinned SQLite and ephemeral original Spoken export.

No quest text was changed in this investigation.
