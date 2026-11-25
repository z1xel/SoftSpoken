# Single-addon compatibility audit

## Voice packs

- [Spoken Quests Audio 2.4.0 generator](https://github.com/rusty-key/spoken-wow/blob/quests-audio/v2.4.0/pipelines/quests/tts_cli/build.py): load-on-demand data, legacy VoiceOver registration contract. No retired SoftSpoken folder dependency identified in source.
- [Spoken Books Audio 2.1.2](https://github.com/rusty-key/spoken-wow/blob/quests-audio/v2.4.0/addons/SpokenBooksAudio/SpokenBooksAudio.toc) and [Spoken Zones Audio 2.0.1](https://github.com/rusty-key/spoken-wow/blob/quests-audio/v2.4.0/addons/SpokenZonesAudio/SpokenZonesAudio.toc): no hard dependency in upstream manifests. Existing optional dependencies support their independent registry data. The repacked release ZIPs must still be checked directly.
- Bundled SSS_VOFallback source TOC: no dependency, load on demand.
- [Legacy Vanilla source manifest](https://github.com/lightbladeninja/wow-voiceover/blob/v1.5.0/AI_VoiceOverData_Vanilla/AI_VoiceOverData_Vanilla.toc) declares RequiredDeps: AI_VoiceOver. The [VanillaExtra source manifest](https://github.com/lightbladeninja/wow-voiceover/blob/v1.5.0/AI_VoiceOverData_VanillaExtra/AI_VoiceOverData_VanillaExtra.toc) declares OptionalDeps: AI_VoiceOver. These are pre-existing compatibility issues, not retired SoftSpoken dependencies. Do not install a duplicate player or bypass dependency enforcement automatically. Exact Turtle and repacked ZIP manifests remain unverified.

Release asset archives were not opened during this source audit. A release may differ from its source tag. Verify shipped manifests before publishing; if a pack hard-depends on an obsolete player, a compatible pack manifest or repack is required.

## Upgrade safety

Remove old full module folders from AddOns, preserve WTF and independent voice packs. UpgradeGuard disables only exact retired SoftSpoken module folder names before startup if possible. The login gate refuses unified initialization if a conflicting old addon is still enabled or already loaded. It cannot unload code already executed or guarantee the client honors DisableAddOn during its current loading pass. Restart after removing old folders. Phase D now implements saved-variable migration against the proposed native import function; see [unified persistence](UNIFIED_PERSISTENCE.md). Actual client validation remains pending.

## Deferred operations

Core and the three modules initialize at login. Stories accepts valid early registration via installed metadata, deduplicates inventory entries and defers any remaining selected load-on-demand packs until world entry. Places still waits for world entry before location stabilization; Writings retains its book-frame retry. EQL3 setup handles already-loaded and later-loaded integrations. Existing public source names, pack preference policy and version constants remain unchanged. Phase D subsequently unified persistence; Phase E separated discovery tracking from narration activation.

## C3 regression baseline

All three workflows passed on C2 commit `b22fc01842f8a8167fefd360ad8364f654cc16df`:
[Audio pack regression](https://github.com/z1xel/SoftSpoken/actions/runs/45328484236),
[Audio API transport regression](https://github.com/z1xel/SoftSpoken/actions/runs/45328484239),
[Development quest catalog regression](https://github.com/z1xel/SoftSpoken/actions/runs/45328484279).
C3 also adds explicit coverage for world-entry deferral, already-loaded and late integrations, and includes the existing completed-quest and PvP category tests in CI. This is a historical baseline. Current release gates are tracked in [development status](CONSOLIDATION_STATUS.md).
