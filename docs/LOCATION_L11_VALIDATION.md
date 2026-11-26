# L11 — geographical integration cleanup and client acceptance

Baseline: 765023409c16fbc515a56ebb3b3badfa295b8954 (L10). All six reported CI runs at that SHA succeeded. This phase targets the fixed Octo client only, not release/main or a new ClassicAPI extension.

## Architecture and cleanup

- Data.lua is the fixed effective catalog; Registry.lua is loaded once and owns identity, relationships, identifiers, names and map representations. History.lua owns canonical persistence adapters. All load before the feature modules.
- Places, Stories and Writings retain their authored content and presentation contracts. Legacy map IDs and exact area keys still identify audio, artwork and content contexts. TurtleAreaMeta supplies reviewed presentation filing, not native identity. The city nesting projection, compatibility labels and legacy migration/hold paths are intentionally retained. Removing these would change existing behavior or break the pre-registry harnesses.
- Native player-area observations now share one registry method, ObservePlayerArea. An observed unknown or unavailable native area blocks text fallback; a missing API, error, or invalid/noninteger result allows it. Places and Writings still have distinct regional and presentation policies. Stories uses ResolvePlayerZone.
- Canonical lookups avoid allocating redirect tracking for active IDs; name matching folds once and filters in precedence order only as needed; a unique match does not allocate/sort a candidate list. Ambiguity ordering and locale precedence are preserved. Places reuses a static regional kind set.
- No discovery fan-out, data regeneration, voice pack changes, saved-variable format changes, or historical exploration recovery. A physical identity such as Southfury River does not share discovery across its Durotar/Barrens content contexts.

## Automated checks

Run the location fixture and complete-catalog test, Places/Stories/Writings registry regressions, persistence lifecycle, module discovery and existing audio/UI workflows. The complete-catalog test reports time and retained heap after repeated queries. This is a Lua 5.1 proxy measurement, not the WoW client's memory budget or frame time. Do not infer live performance from it.

## Live OctoWoW acceptance (not executed by CI)

1. Update the single addon from dev (no separate location install). Back up SavedVariables before testing. Log in on an existing character and a fresh character; confirm no Lua errors and that history survives /reload and relog.
2. Places: visit a known zone, then a subzone; verify correct lore, artwork and recording. Test Southfury River from Durotar and Barrens independently: visiting one must not unlock the other merely through shared identity. Check another cross-zone site and a contentless native area; no incorrect parent narration. Test map overlay hover and browsing while standing elsewhere.
3. Stories: verify known Vanilla quests, a custom Octo area, and dungeon/raid categories, including an exterior/interior pair. Confirm quest journal and playback are unchanged.
4. Writings: discover a world book and acquire a carried book in one region, then read in another. Check actual origin, static possible sources, native-only Hyjal if reachable, and quantities after reload.
5. Disable each module, perform a supported discovery, enable again and check silent discovery policy. Verify disabled modules do not autoplay.
6. Traverse loading screens, zone borders and instance entrances; check that stale text does not select unrelated lore. No automatic map zoom changes.
7. Compare startup and repeated travel/Compendium browsing with the pre-L11 dev snapshot using the same character, voice packs, client and settings. Record client addon memory and visible stutter before/after, after normal garbage collection. Report exact zone, character state, error and reproduction steps for failures.

L11 live acceptance remains open until these tests are actually performed. Do not mark the geography refactor as live-verified merely because CI passes.
