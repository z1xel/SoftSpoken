# Unified persistence — phase D

## D1–D2 foundation and module cutover

The target has two SavedVariables globals: `SoftSpokenDB` (account) and
`SoftSpokenCharacterDB` (per-character). `Persistence.lua` is private to
SpokenEnv and is deliberately inert at file load. D2 switches the TOC and controllers together. Core initializes the root and binds all module namespaces before constructing the shared UI; feature initialization consumes those namespaces. The old globals are no longer declared. **Do not use D2–D3 against a real WTF directory:** legacy import is not implemented until D4; normal logout can replace the old Core file.

### Ownership

| Destination | Content |
| --- | --- |
| Root AceDB profile | Existing Core preferences, including Parts, shared language, narrator, transcript, audio and minimap |
| Root AceDB global | Existing account-wide layout, recovery baseline and other global state |
| Root AceDB char | Existing non-profile Core state (IsPaused) |
| Stories namespace profile | Existing Stories profile (Audio, DebugEnabled, other saved preferences); Compendium.foundOnly, voicedOnly, unlock |
| Places namespace profile | Existing SSZCharacter.settings preferences: autoplay, subzones, mode, combat, greeting, map panel, font and Compendium filters |
| Writings namespace profile | Existing SSBSettings preferences, including reading behavior, language, font and Compendium filters |
| Character.Stories.journal | Existing SSCQuestJournal history (seen, completed, titles, dialogue; move settings to namespace) |
| Character.Stories | Existing Stories AceDB char gossip history and recent quest-title cache |
| Character.Places | Existing SSZCharacter visit/heard/greeting history; separate preferences |
| Character.Writings | Existing SSBCharacter read/found/location/acquisition records |

Keep existing effective defaults. Do not carry historical Places preference
migration flags into new profiles; D4 must interpret them before transferring
preferences. The old captions preference is a legacy Core import, not a new
Places preference. Preserve unknown historical data during D4 rather than
silently discarding character records. Core's existing account-wide AceDB
`char` subsection remains character-keyed and is not a profile or journal.

Namespaces use the bundled AceDB's native profile propagation, not another
registry. Core and Stories supply their existing defaults; Places/Writings use the definitions in Persistence.lua. No
module may cache a profile table across profile changes.

### D2–D5

- D2: switch TOC and controllers together; move all persisted access to this
  foundation. Audit early event handlers and cached settings pointers.
- D3: simplify profile operations and refresh callbacks, retain module-specific
  resets, distinguish Core-only reset from whole-profile reset. Keep profile UI
  disabled until validated.
- D4: use the proposed ClassicAPI read-only import returning account and
  character tables separately. Migrate only released addon identities.
  Preserve each character's active legacy preferences, not inactive legacy
  profiles; use a character-specific profile where needed. Preserve character
  histories completely. Account and character migration completion are separate.
  No support for intermediate development snapshots. Exact API unavailable yet.
- D5: test migration, real logout/reload and client compatibility before release.

D1 tests load the real vendored AceDB and exercise seeded data, idempotent
initialization, profile switching/copy/reset/delete and history isolation.
D2 regression fixtures use the new module settings/history access paths. Legacy Places combat/default flags, heard-key normalization and caption conversion must be covered by D4 migration tests.
