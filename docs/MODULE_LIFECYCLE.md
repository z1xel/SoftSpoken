# E — module lifecycle and discovery policy

The existing source switch controls narration and module presentation.
A separate per-profile **Track … while disabled** checkbox for Stories,
Places and Writings defaults to on. It only affects disabled sources; enabled
sources always track. Gossip remains an independent narration source, and its
heard flags are not discoveries.

- Stories: retain quest journal and live dialogue observation while silent;
  opt-out blocks quest history capture and log synchronization.
- Places: silent tracking retains actual visited locations and discovery
  announcements; opt-out stops location polling and skips discovery
  events. Resume establishes a new location baseline instead of autoplaying
  missed transitions. Map panel polling/presentation follows narration.
- Writings: silent tracking retains found books, world locations and carried
  book acquisitions. Opt-out stops bag reconciliation and book detection.
  Resume uses a fresh bag baseline; items acquired while suspended are not
  treated as new discoveries. Silent book encounters do not count as narrated/read.

Existing saved history is never cleared by switches. Native quest completion
and map exploration data may be recovered after enabling, so this is not an
instruction to erase game progression. Source identity and voice packs remain
registered; hooks cannot be unloaded by normal 1.12 Lua. Keep lightweight
event listeners where needed for context, cleanup or recovery; guard work at
entry and persistence boundaries instead of repeatedly installing hooks.

Live-client validation: switch each source during playback, while a quest/book
window is open, during a delayed read and bag scan, on the map, and across
profile changes; check all three modes and repeat switches without duplicate
handlers. Verify world entry and bank transfer baselines. ClassicAPI migration
and the existing D release gates are unchanged.
