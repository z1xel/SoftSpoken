# Remaining 254 shared-ID dialogue conflicts: read-only triage

**Scope:** the 254 *non-substantial* records in the original 289-conflict Spoken/Tortoise comparison. This is a separate review from the 35 substantial cases and is kept as a historical source snapshot. It does not modify `SpokenQuestsText` or `SSCTurtleQuestText`.

## Results

| Category | Count | Default decision |
| --- | ---: | --- |
| Only punctuation, whitespace, or one-letter WoW directive capitalization | **163** | **Retain original Spoken**; no evidence of better narrative text |
| Minor difference with a changed directive sequence | **57** | **Manual token review**: game display placeholders/line breaks can be meaningful |
| Minor wording variation with unchanged directive sequence | **19** | Manual prose review; retain Spoken until a fix is established |
| Moderate wording difference with Turtle source at least 30 characters shorter | **11** | Retain Spoken; likely partial truncation |
| Other moderate differences | **4** | Manual prose/context review |
| **Total** | **254** | **No automatic overrides** |

149 of the 163 cosmetic rows differ only in WoW directive letter casing; the other 14 have punctuation/spacing differences. **None of these 163 changes the directive sequence after case normalization.** For example, `$n` and `$N` are equivalent in the quest viewer.

Across these 254 records, **72 change a game-directive sequence** after case normalization. Those deserve attention, but most small differences involve formatting directives or alternate grammatical phrasing, rather than demonstrated Turtle-only new story content.

## Moderate differences (15 IDs)

These are important because 11 have substantially shorter Tortoise strings:

| Quest ID | Title | Turtle minus Spoken (characters) | Default |
| ---: | --- | ---: | --- |
| 283 | A Dark Threat Looms | -70 | Retain Spoken, inspect omitted passage |
| 646 | Trol'kalar | -155 | Retain Spoken, inspect omitted passage |
| 842 | Crossroads Conscription | -152 | Retain Spoken, inspect omitted passage |
| 902 | Samophlange | -56 | Retain Spoken, inspect omitted passage |
| 1284 | Suspicious Hoofprints | -99 | Retain Spoken, inspect omitted passage |
| 2867 | Return to Feathermoon Stronghold | -194 | Retain Spoken, inspect omitted passage |
| 2903 | The Battle Plans | -122 | Retain Spoken, inspect omitted passage |
| 2942 | The Morrow Stone | -121 | Retain Spoken, inspect omitted passage |
| 4730 | Beached Sea Creature | -93 | Retain Spoken; source family already has an ID mismatch |
| 4732 | Beached Sea Turtle | -135 | Retain Spoken, inspect omitted passage |
| 8519 | A Pawn on the Eternal Board | -217 | Retain Spoken, inspect omitted passage |
| 194 | Raptor Mastery | -12 | Manually review gender directive removal |
| 1947 | Journey to the Marsh | -17 | Manually review wording |
| 5674 | Elune's Grace (acceptance) | +26 | Manually review added wording |
| 8859 | Secrets of the Colossus - Zora | -9 | Manually review wording |

These are triage decisions based on stage-aware comparison, not definitive claims about live Turtle server text.

## Minor text changes (76 IDs)

The **57** with changed directive sequences should be inspected in priority order. A change to `$B` line breaks is usually less important than removal or alteration of `$G` gender-dependent words, `$C` class, `$N` player name, or `$R` player race. The automated report does *not* equate every changed directive with a broken client; it identifies which rows warrant context.

Some named examples:

- **3801 and 3802 — Dark Iron Legacy:** Turtle inserts ghostly-voice narrative cues at the beginning of acceptance dialogue; potentially appropriate if these stage directions are actually shown by the 1.12 client.
- **9322 — Wild Fires in Kalimdor:** adds phrasing; original Spoken should remain until quest-context verification.
- **117 — Thunderbrew:** differs in paragraph-break placement.
- **1758 — Tome of the Cabal:** minor conversational wording changes; no reason to overwrite without corroboration.
- **8221 and 8224 — Rare Fish:** small, similar changes that should be reviewed as a family.

The other **19** minor changes contain no altered normalized directive sequence. They are likely lower priority than corrections affecting client-display tokens.

## Reused text families

There are **19 identical-Tortoise-dialogue clusters covering 73 rows** within these 254 conflicts. Representative clusters are the ten War Supplies Signet quests, nine Darkmoon-ticket turn-ins, Arathi Basin reputation/reward repeatables, the Salve via Gathering and Salve via Disenchanting repeatables, and four Atiesh quest variants. Review repeated texts once per family rather than treating every quest ID as a separate editorial problem.

## Decision and remaining work

**Retain Spoken for the 163 cosmetic cases and for all 11 likely shortened moderate cases.** Do not bulk-import the other 80 minor/moderate cases based only on SQL migration evidence. Their highest-value next pass is a focused in-game and source-specific review of the **72 directive-sequence changes**, which may include harmless line breaks.

The original 35 substantial differences are independently adjudicated in [the substantial review](substantial_35_adjudication.md). Their 13 approved Tier 3 completions are being integrated as stage-specific Turtle overrides; the other 22 keep Spoken. This means the unresolved priority audit is expected to fall from 289 to **276** after the 13 verified overrides, but the historical review of 254 still covers the original non-substantial portion of those candidates.

## Machine-readable output

- [All 254 stage-level triage decisions](remaining_254_triage.csv)
- [Summary and classification counts](remaining_254_summary.json)
- [Original comparison metrics](conflict_review.csv)

**No Original Spoken or Turtle dialogue stage is changed by this review.**
