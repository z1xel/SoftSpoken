# L10 — canonical character geography

Independent character geographyVersion=1 is staged after D legacy recovery and before Core opens AceDB or modules consume history. Locations/History.lua publishes detached validated character data in one root assignment. The account migration ledger and profile selection do not change. Reload validates rather than reimporting; failed conversion does not publish staged state.

Canonical storage:
- Places.visited[locationID][legacyVisitContext]=true.
- Places.heard[locationID][legacyRecordingKey]=true.
- Writings.locations[bookID][locationID][method]=true.
- Writings.acquisitions[itemID][locationID]=outstanding quantity.

Each module has a versioned locationHolds envelope carrying raw keys and values under their original fields and book/item IDs, scoped to spoken_classic legacyPlace or upstreamUiMap. Unmapped or nonstandard values are retained, never fanned out. Exact legacy reads remain available. Held acquisition counts participate in consumption. Reconciliation after later catalog changes is explicit, not automatic.

Places keeps independent discovery contexts and recording histories. Writings records native-only regional identities even without an upstream map key and displays them using canonical names and continent ancestry. UI projections may still use numeric map keys where unique. Original content datasets and playback keys are untouched. Standalone legacy test harnesses still accept the old format; production startup loads History.lua before modules. Previously lost origin or overwritten acquisition methods cannot be reconstructed. Live reload and memory testing remain L11.

The multi-process persistence lifecycle test now loads the real registry/history and real AceDB before Core DB initialization. It serializes each character on logout, checks D and geography versions separately, and verifies that native-only origins and outstanding quantities survive a fresh Lua process without duplication. This is simulated client file I/O, not a live WoW test.
