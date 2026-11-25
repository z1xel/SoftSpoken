# Single-addon development status

The consolidated code is the intended development baseline, not a new release.
The published v0.9.1-beta and main remain unchanged. The pre-consolidation dev
history is preserved in deprecated; the original pre-release history is also
retained in archive/dev-pre-v0.9.0-beta-squash.

## Implemented

| Phase | Status |
| --- | --- |
| A–B: audit and physical consolidation | Complete |
| C: native startup and compatibility | Implemented; live validation pending |
| D: unified persistence and legacy import | Implemented against proposed API; simulated serialization passed |
| E: module lifecycle and silent discovery | Implemented; automated regressions passed |
| F: release preparation | Preview packaging and docs; release gates remain |

## Verified baseline

All five workflows passed on E6 commit `1db7b9ae4448c0cfccc616e4a4e178db810c9352`:

- [Legacy migration](https://github.com/z1xel/SoftSpoken/actions/runs/45568198381)
- [Audio API transport](https://github.com/z1xel/SoftSpoken/actions/runs/45568198270)
- [Module discovery](https://github.com/z1xel/SoftSpoken/actions/runs/45568198449)
- [Quest catalog](https://github.com/z1xel/SoftSpoken/actions/runs/45568198417)
- [Audio packs](https://github.com/z1xel/SoftSpoken/actions/runs/45568198458)

## Release gates

- Implement and test native `ImportSavedVariables(addonName)` in ClassicAPI.
- Complete [real-client migration and persistence checks](UNIFIED_PERSISTENCE.md#d5-client-validation), then enable the profile management UI.
- Complete [module lifecycle tests](MODULE_LIFECYCLE.md) in-game, including pending narration, books, bags, and map interactions.
- Verify actual distributed voice-pack manifests and supported client integrations ([compatibility audit](SINGLE_ADDON_COMPATIBILITY.md)).
- Validate the single-addon preview ZIP and final regression suite. Keep the release version unchanged until a new release is explicitly prepared.

Never test an upgrade against the only copy of the user's WTF data.
