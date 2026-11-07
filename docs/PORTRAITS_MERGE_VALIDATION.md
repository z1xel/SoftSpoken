# ClassicAPI portraits — merge validation

**Branch:** `experiment/classicapi-texture-portraits`
**Status:** Code and CI regression suite exercised; **client-side validation is still required**.
**Target:** Vanilla WoW 1.12 (OctoWoW/Turtle-compatible), with graceful degradation when ClassicAPI is absent.

## Implementation boundary

- `SoftSpoken_Stories/SpeakerResolver.lua` resolves giver, ender, item/object and live dialogue identity.
- `SoftSpoken/CreatureAppearance.lua` owns one ClassicAPI creature-data request registry and completion listener; native/WDB portrait caches remain the client's responsibility.
- `SoftSpoken_Stories/Compendium/QuestPage_112.lua` renders static 2D native textures and binds each holder to quest/stage/creature/generation. The page does not create 3D models.
- `SoftSpoken_Stories/Compendium/PortraitPreload_112.lua` prefetches **data only** for selected and discovered visible/hovered quests. Selection bypasses the speculative queue. Speculative work has at most two in-flight IDs, 400 ms spacing, eight queued IDs, and stops on tab hide.
- `SoftSpoken/UI/Portrait.lua` keeps the narrator's existing 3D rendering and listens to the same creature-data service.

No new TGA art, decorative portrait rings, gameplay markers, new quest objectives, or additional gameplay information are introduced.

## Automated regression gate

The `.github/workflows/audio-pack-regression.yml` checks must pass on the **final branch head**. Run locally from the repository root with a compatible Lua interpreter if needed:

```sh
lua5.1 tests/stories_speaker_resolution.lua
lua5.1 tests/creature_appearance_service.lua
lua5.1 tests/stories_questlog_portrait_prime.lua
lua5.1 tests/stories_compendium_portrait_lifecycle.lua
lua5.1 tests/stories_portrait_preloading.lua
lua5.1 tests/classicapi_portrait_compatibility.lua
lua5.1 tests/stories_faction_crest.lua
```

The workflow also runs the Places/Writings and audio pack regression tests and `luac5.1 -p` checks. Mocked Lua 5.1 tests **do not substitute for** running the Vanilla 1.12 client and Lua 5.0 runtime.

**Post-audio-overhaul integration check:** The complete `audio-api-regression.yml` Lua and Python test commands were additionally run against the combined portrait/audio branch in [GitHub Actions run 42344572879](https://github.com/z1xel/SoftSpoken/actions/runs/42344572879) (passed). The temporary duplicated test commands were then removed from the portrait workflow; the standalone audio API workflow remains unchanged and will run under its normal branch/PR triggers.

## Required client-side checks

1. **Cold creature cache:** With a genuinely uncached NPC, open an already-discovered quest's Stories page. The faction crest should appear immediately; when the creature query finishes, its speaker should receive the correct static portrait. Confirm no blank/transparent portrait remains indefinitely. For repeatable tests, use an isolated client/cache copy, not an unbacked-up player installation.
2. **Warm cache:** Reopen the same quest. Portraits should appear promptly without visible redraw artifacts. Navigate between it and other quests rapidly; no prior speaker's face should leak into the current quest.
3. **Different giver/ender:** Test a quest whose giver and ender are different creatures, and one whose ender is a game object. Verify Description, Progress and Completion labels/portraits independently.
4. **Live dialogue and quest log:** Open an actual NPC dialogue and play/replay its clip; then play the same quest from the quest log. Real unit GUID identity must not be replaced by the quest ID or an unrelated target. Audio selection and playback must not regress.
5. **Compendium lifecycle:** Switch between Stories, Places and Writings; close/reopen the Compendium; reselect the Stories tab for its landing page; change the selected quest while data is pending; resize the window; use search/filter, scroll rapidly, and then `/reload`. No stale portrait, incorrect tooltip, Lua error or crash is acceptable.
6. **Visibility and progress:** Check not-yet-completed quests, locked/undiscovered quests, objects/items and unavailable voice packs. Hidden Completion sections must not show a portrait. Data preloading must not expose undiscovered quest information.
7. **Fallback and compatibility:** Test without a supported ClassicAPI build, without `SetPortraitTextureFromCreatureDisplayID`, and with missing/invalid display data. The UI and narration must still work, using existing faction crest or item/note artwork.
8. **Request discipline:** Verify scrolling does not cause a noticeable hitch or flood native requests. Changing tabs, closing the Compendium or reducing search results to zero should stop speculative work. Selecting a quest must take priority over viewport requests.
9. **Native rendering:** Check that a native 64×64 portrait becomes visible after its asynchronous bake. A successful `pcall(SetPortraitTextureFromCreatureDisplayID, ...)` only confirms submission, **not** a rendered image. The public native API supplies no dependable image-complete or invalid-display callback. Test in the actual client.
10. **Compatibility & packaging:** Install all four addon folders using the normal release ZIP layout. Confirm WoW 1.12 loads every new Lua file through the two `addon.xml` manifests, and that the ClassicAPI-free configuration does not emit errors.

## Debug overrides (development only)

- Set `SoftSpokenExperimentalStaticPortraits = false` during a session to disable Compendium static portrait rendering. Reopen/reselect the quest to refresh its UI.
- Set `SoftSpokenClassicPortraits = false` during a session to use the narrator's original fallback instead of the ClassicAPI creature renderer.
- Both are optional Lua globals, not saved configuration switches. Reset them to `nil` to restore feature-detected behavior. These runtime overrides are not substitutes for physically testing a ClassicAPI-free client.

## Merge gate

- All automated checks pass on the up-to-date experiment head; comparison against `main` shows only intended portrait/UI/test changes and no new binary art.
- All client tests above pass in at least one supported Vanilla 1.12 setup **with** ClassicAPI and one supported fallback setup **without** it.
- No in-game crash, accidental gameplay advantage, stale speaker, or regression in audio playback.
- Only after those checks, review a PR against current `main`, resolve any concurrent changes and merge. **Do not treat green CI alone as approval to merge.**
