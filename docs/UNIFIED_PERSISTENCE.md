# Unified persistence — phase D

## D1–D3 unified persistence and profile management

The target has two SavedVariables globals: `SoftSpokenDB` (account) and
`SoftSpokenCharacterDB` (per-character). `Persistence.lua` is private to
SpokenEnv and is deliberately inert at file load. D2 switches the TOC and controllers together. Core initializes the root and binds all module namespaces before constructing the shared UI; feature initialization consumes those namespaces. The old module globals are no longer declared; D6B temporarily retains the old Core name as a passive migration safety slot. **Do not use D2–D3 against a real WTF directory:** legacy import is not implemented until D4; normal logout can replace the old Core file.

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
- D3: root-only profile operations; root callbacks run after all namespaces
  have changed. Explicit module reset methods refresh only their own module.
  Core-only reset preserves all module preferences (including unlock switches),
  clears the account-wide window layout and reloads. Whole-profile reset
  restores all module/Core preferences but preserves account layout, character
  history and other profiles. Keep profile UI disabled until actual client
  validation (D5).
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

D3 fixes two D2 Writings lookups (autoplay and closeWhenRead), caught by the
audio transport regression. The bundled AceDB test now also exercises the
actual Core callback and Options profile operations, ensuring one root refresh
pass and independent reset scopes. Module reset tests assert a local refresh.

### D4 implementation contract

Startup calls the read-only global `ImportSavedVariables(addon)` before Core initialization. The proposed function must return two tables keyed by saved-variable name (account and current character); missing files return empty tables, errors must throw or return a non-table. No unified database writes occur until all imports and transformations succeed (D6B may retain recovered Core data in the declared legacy slot). Missing API blocks startup rather than silently initializing defaults. The account snapshot retains active preferences for other characters because the old Core filename is reused; each character consumes its own snapshot on first login. Character-specific imported profiles avoid cross-character preference conflicts. The API is not yet available in the real client; D5 must verify it and actual logout/reload behavior.

### D5 client validation

**Release blocked:** the real ClassicAPI import implementation and Vanilla client have not been tested. The four D4 CI workflows passed on ecdd0c4. D5 adds explicit tests for migration after AceDB cleanup, malformed histories, fresh characters, and runs the persistence/startup/upgrade suites together.

Use a disposable copy of the client and the entire WTF directory. Never test against the sole original copy: even if startup rejects migration, the client may overwrite the old Core SavedVariables file on logout because the TOC ownership changed. Keep the original backup outside the test client.

- [ ] Confirm ClassicAPI exposes ImportSavedVariables(addonName) at PLAYER_LOGIN; verify both scopes, missing files, malformed files, and no file writes or execution of arbitrary Lua. Confirm account and realm/character isolation.
- [ ] Start from released v0.9.1-beta with two characters, distinct active Core/Stories profiles, shared Writings settings, and distinct Places preferences. Seed quest dialogue/history, visited/heard/greeted state, books/discoveries/locations, explicit false settings, layout and mixer baseline. Exit normally and copy WTF.
- [ ] Replace the four addon folders with the unified folder; retain voice packs and WTF. Log in character A and inspect both new saved variables after logout. Compare all seeded data to the original backup.
- [ ] Log in character B after the old Core file is replaced; confirm original B settings and history, and no changes to A. Reload both characters twice; ensure no duplicate import or reverted preferences.
- [ ] Test empty WTF, missing API, partial/malformed legacy files and old folder conflicts using separate disposable copies. Failure must be visible and must not initialize controllers. Restore backup before retrying if files were overwritten.
- [ ] Test narration, quest log/gossip, Places map and autoplay, Writings page/book playback, Compendium filters, unlocks, pfUI/Questie/pfQuest integrations, native audio and portraits on supported clients. Verify voice-pack enable/load/reload behavior.
- [ ] In a disposable developer build only, enable the profile UI and test switch/copy/delete, Core-only reset, whole-profile reset and module reset; check all histories remain unchanged across reload/logout. Only enable the shipping UI after these pass.
- [ ] Verify packaged archive contains one addon folder plus separately installed packs, and no retired module folders. Do not merge or release until all gates are recorded.

### D6A — character migration lifecycle

The account migration record now contains `characters[characterKey]` with
`legacy` or `new` status. A character already recorded there is never
reimported, even if its per-character file is absent; its current profile
selection is untouched. Missing history starts empty, rather than resurrecting
an obsolete snapshot. A character-only completion marker without the account
record is rejected as inconsistent. Unreleased D4/D5 snapshots without the
ledger are intentionally unsupported.

An unseen character is legacy only if it has a staged Core/Stories character
record or at least one of the three released per-character saved variables
(including an explicitly saved empty table). Otherwise it receives normal
namespace defaults, not the legacy Writings account snapshot. The snapshot
is retained for late-arriving history-only characters, but never applied to
characters without legacy evidence. This does not prove when a character was
created: a character with no surviving per-character or account-keyed evidence
cannot be identified as legacy. The read-only API remains required to classify
unseen characters; completed characters require no further API calls. D6B
still owns the file-protection and missing-API contract.

### D6B — legacy file protection and import validation

The migration release declares `SpokenSettings` alongside `SoftSpokenDB`
in the account TOC. This is not a third live database: no controller reads or
writes preferences through it. Valid old Core data loaded by the client is
left untouched, including on missing API, failed import, old-folder conflict,
or failed startup. If the native importer recovers a Core table the client did
not load, a detached copy is retained before other reads. The declaration and
retained data must not be removed until a later, explicitly validated cleanup
release. The other three legacy addon files remain outside the unified TOC.

This is semantic retention of readable Lua data, not a byte-for-byte backup or
an atomic disk-write guarantee. A malformed original file, native loader failure,
crash during write, or client-specific serialization behavior is not protected
by a TOC declaration alone. Before the first upgraded launch the installer/user
must keep a complete out-of-process WTF backup. Verify normal logout and failed
migration logout on the actual 1.12 client before shipping. Do not rely on .bak
rotation or attempt to restore files from a running Lua addon.

Native contract remains `ImportSavedVariables(addonName) -> account, character`.
Both returns must be detached plain tables, keyed by variable name, from the
current account and current realm/character, with empty tables only when absent.
Unreadable/malformed files must report errors, not absence. The DLL must use a
safe saved-data parser rather than execute arbitrary Lua, and must not mutate
files. SoftSpoken rejects non-serializable values, metatables, cycles, invalid
known preference types (using live defaults), and malformed nested history.
Unknown serializable fields are preserved. The unified globals and import ledger
are published only after validation; the retained legacy slot is the exception.
The session-local startupComplete flag is separate from import completion.

The native import function remains mandatory for unseen characters, including a
clean first install, because Lua cannot safely prove the absence of the retired
files when the function is missing. Completed characters need no importer.
Supporting first install without the extension would require a trustworthy
external clean-install assertion or presence probe; do not infer this from empty
new globals. No new DLL function is assumed or implemented here.

### D6C — cross-session persistence regression

Run `python3 tests/test_persistence_lifecycle.py` from the repository root.
The runner uses a temporary directory and fresh Lua 5.1 processes for each
session. It reads and writes only generated fixtures; its fixture-only loader
is not the native ClassicAPI parser. The Lua harness uses the actual TOC
SavedVariables declarations, production migration and Core/module DB binding,
real Core and Stories preference defaults, Options profile operations, and
the bundled AceDB PLAYER_LOGOUT handler. No WoW UI is constructed.

Scenarios: seed released-format files, failed import followed by logout, first
legacy login and profile operations, second character sharing an old Core
profile, repeat login, late history-only character, new character and reload,
and loss of the first character's unified history file. Assert separate
character histories, account layout, profile changes, original Core retention,
consumption ledger, no repeated import, default stripping, and fresh defaults.
The simulated file round trip does not verify the real client serializer,
ClassicAPI parser, crash durability or controller/UI integration; those remain
release gates. D6A and D6B CI passed before this test was added.
