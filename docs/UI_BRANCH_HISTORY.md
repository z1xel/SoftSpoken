# SoftSpoken UI Fidelity — Branch History in Eight Stages

**Branch:** `experiment/vanilla-ui-fidelity`  
**Period:** November 7–13, 2026 (UTC)  
**Snapshot:** `36dd9886f84054c1382c36fb6fe1c32da73d2fcd`  
**Compared against:** `main`, common ancestor `0eb980f6da6c551e755e4ce50363b3d8de8f7f44`  
**Scope:** **318 commits unique to this branch**, condensed into **eight chronological stages**.

> **Reading note:** This is a *development narrative*, not a list of 318 final features. The history includes experiments, one-unit visual adjustments, test updates, merges, and reversions. Each stage records what was tried, why it mattered, and what survived in the resulting UI. Commit ranges refer to the chronological `main...branch` comparison, not issue numbers.

## At a glance

| Stage | Commits | Theme | Lasting outcome |
|---|---:|---|---|
| 1. Native foundations | 1–22 (22) | Resizable frame, scrollbars, typography | Native-oriented Compendium baseline |
| 2. Quest Log fidelity | 23–83 (61) | Header, divider, page and shell geometry | Cropped/tiled original artwork |
| 3. Compositing and masks | 84–120 (37) | Header fades, scroll content, masked book | Layered Quest Log/header treatment |
| 4. Portraits and controls | 121–173 (53) | Quest-stage portraits, badges, search/filter | Consistent Compendium interactions |
| 5. Map and narrator visual identity | 174–226 (53) | World Map reader, speaker typography, Talking Heads | Unified visual language |
| 6. Progress and parchment | 227–282 (56) | Native loading bar, gold/silver rendering, QuestBG | Compact ornate player progress and parchment |
| 7. Resizing and content integration | 283–306 (24) | Three-slice performance, item/gameobject icons, atlas investigation | Responsive player bar and better quest fallbacks |
| 8. Release hardening | 307–318 (12) | Naming, screenshots, assets, polling, tests | Production-oriented UI branch |

## Stage 1 — Native foundations (commits 1–22)

**November 7–8.** Work began by investigating whether authentic Vanilla/ClassicAPI frame artwork could replace improvised stretched borders. Fixed Character Frame corners, tiled source art, correct draw order, and seam alignment were tested against the live Compendium. The navigation area moved away from its older thin-scrollbar gutter and hidden scroll controllers toward a **single native 1.12 scrollbar**, with the thumb clamped to the usable track during resizing.

Typography was brought closer to the original Quest Log, including heading/body proportions and a **14-point default reader body**. This established the principle that native geometry and reusable controls should replace parallel custom systems.

**Representative commits:** [`f19b338`](https://github.com/z1xel/SoftSpoken/commit/f19b338), [`e6b1c38`](https://github.com/z1xel/SoftSpoken/commit/e6b1c38), [`239eb09`](https://github.com/z1xel/SoftSpoken/commit/239eb09).

## Stage 2 — Rebuilding the Quest Log shell (commits 23–83)

**November 8.** The visual target shifted from Character Frame borders to the **wide, original Quest Log**. Numerous small, screenshot-led revisions measured the true 1.12 texture names and source regions, then refined the header's vertical crop, fixed right endcap, center repetition, and joins. The lower shell, side rails, two-pane margins, and scrollbar housing were moved in coordinated increments rather than scaling the entire texture.

The spellbook divider also became a native-scale multipart construction: preserve both ornamental ends and repeat a straight center without distorting their proportions. Several aggressive divider trims were reverted when they removed the authentic endpoint. The stage ended with a functioning, geometry-conscious Compendium shell ready for masking.

**Representative commits:** [`c1186e0`](https://github.com/z1xel/SoftSpoken/commit/c1186e0), [`6182ef4`](https://github.com/z1xel/SoftSpoken/commit/6182ef4), [`ca0d950`](https://github.com/z1xel/SoftSpoken/commit/ca0d950).

## Stage 3 — Header compositing and mask refinement (commits 84–120)

**November 8–11.** Once the source artwork was aligned, the next problem was how to blend the wide Quest Log header into resizable left and right panels. The branch explored horizontal mask boundaries, vertical orientation, bounded bottom fades, multiple panel-specific fade regions, and alpha behavior on the uncropped left header. Temporary debug textures were introduced to diagnose inverted fades and incorrect mask placement.

A **single circularly masked inventory-book icon** replaced the earlier strip-based workaround. A simplified continuous fade was also tried and explicitly rolled back in favor of separate regions. The lasting result was independently controlled header fades and correct layering, rather than one mask stretched indiscriminately over the entire window.

**Representative commits:** [`ebb8930`](https://github.com/z1xel/SoftSpoken/commit/ebb8930), [`57ef714`](https://github.com/z1xel/SoftSpoken/commit/57ef714), [`7662035`](https://github.com/z1xel/SoftSpoken/commit/7662035).

## Stage 4 — Quest portraits, discovery indicators, and Compendium controls (commits 121–173)

**November 11.** Quest pages gained a more coherent visual hierarchy: NPC portraits inside a decorative ring, a book icon positioned underneath the header ring, and **Accept / Progress / Complete** status badges in the portrait's smaller socket. Ring choices (CharacterTab versus minimap-style alternatives), badge offsets, layering, and clipping were adjusted and tested repeatedly; the CharacterTab treatment was restored after alternative artwork proved less suitable.

The navigation experience was polished with native-style search fields, clear/search icons, filter arrows, dropdown framing, and revised spacing. A scoped ClassicAPI scroll-edge fade was introduced for full Compendium content. Many micro-commits reflect trial placements or reversions, not additional permanent widgets.

**Representative commits:** [`b5ba2cd`](https://github.com/z1xel/SoftSpoken/commit/b5ba2cd), [`95d6844`](https://github.com/z1xel/SoftSpoken/commit/95d6844), [`4164a03`](https://github.com/z1xel/SoftSpoken/commit/4164a03).

## Stage 5 — World Map integration and narrator identity (commits 174–226)

**November 12.** The Places reader, then called **Zone Lore**, was brought visually into the same system as the Compendium: consistent parchment, inset chrome, scrollbars, margins, and native Turtle WoW minimized-map frame elements. A long sequence of small spacing adjustments aligned the reader to the World Map without altering the map itself. The inner silver inset was briefly hidden for comparison and then restored above the surrounding artwork.

For narration and quest details, speaker text was refined toward **Morpheus typography** with measured relative sizing; the player ultimately used **Morpheus at size 22**. The player's portrait received the exact **143×143 Blizzard Neutral Talking Heads atlas region**, correctly positioned over the existing model and dark backing. An alternative Talking Heads text background was tested and reverted.

**Representative commits:** [`0e5afff`](https://github.com/z1xel/SoftSpoken/commit/0e5afff), [`7c1a82c`](https://github.com/z1xel/SoftSpoken/commit/7c1a82c), [`73f3590`](https://github.com/z1xel/SoftSpoken/commit/73f3590).

## Stage 6 — The ornate playback progress bar and final parchment (commits 227–282)

**November 12.** The narrator gained a compact progress presentation based on **Blizzard's native loading-screen border** and the existing duration-driven StatusBar. The gold fill went through multiple color studies before settling on a textured warm brass base with a concentrated additive yellow reflection; a spark follows the fill without a Lua per-frame playback driver. Repeated small reductions compressed the decorative border to **16 UI units** while keeping the active gold track **5 units** tall.

Simply stacking tinted border copies did not brighten the metal convincingly. A **masked silver overlay** was retained instead. Separately, the shared lore reader switched to a bundled Vanilla-compatible **QuestBG** parchment; its bottom extent and page coverage were corrected. Scroll-edge fades were consolidated into shared helpers for relevant Compendium views.

**Representative commits:** [`fede8a2`](https://github.com/z1xel/SoftSpoken/commit/fede8a2), [`4bfc047`](https://github.com/z1xel/SoftSpoken/commit/4bfc047), [`8f072e6`](https://github.com/z1xel/SoftSpoken/commit/8f072e6), [`abae1cb`](https://github.com/z1xel/SoftSpoken/commit/abae1cb).

## Stage 7 — Resizing performance and content fallbacks (commits 283–306)

**November 12.** Stretching the loading border distorted its ornate ends, so the progress renderer was divided into **fixed left/right caps and a tiled 32-unit center**. The fill was reanchored to those caps; narrow widths cropped instead of overlapping. Performance initially deteriorated because every tile carried a separate masked silver layer and because tiles were anchored in a chain.

The fixes reduced the silver treatment to **three masks total**, reused tile textures, and—crucially—**anchored each center tile directly to the border frame**. The repeated checkpoint stalls observed during manual resizing then disappeared in user testing. Stories also gained ClassicAPI-backed **quest-item icons** and a distinct **GameObject fallback**. Several StoryHeader/QuestMapLog atlas extraction attempts were tested, corrected, or reverted rather than kept as active decoration.

**Representative commits:** [`b7e48fd`](https://github.com/z1xel/SoftSpoken/commit/b7e48fd), [`945b361`](https://github.com/z1xel/SoftSpoken/commit/945b361), [`f25cc8d`](https://github.com/z1xel/SoftSpoken/commit/f25cc8d), [`4ff72de`](https://github.com/z1xel/SoftSpoken/commit/4ff72de).

## Stage 8 — Documentation, production cleanup, and merge preparation (commits 307–318)

**November 13.** Zone Lore was renamed **Lore of the Land**. The README gained refreshed, optimized screenshots covering the player, Compendium, Stories, Places, Writings, map, and discovery. A final top-rail overlap experiment was reverted to the visually approved **6-unit** version.

The pre-merge audit then eliminated unused packaged artwork, archived non-runtime source PNGs and provenance under `docs/artwork`, promoted the live frame skins from experimental names and paths to production modules, removed the redundant static-portrait experiment switch, and replaced the stale tiling log with [`docs/UI_RENDERING.md`](UI_RENDERING.md). Scrollbar updates were optimized to avoid duplicate row painting, while Vanilla compatibility polls were throttled rather than removed. Added tests check real player-layout assumptions, mask assets, fallback polling, and installable paths.

**Final result:** The branch was **318 commits ahead and 0 behind `main`** at the documented snapshot. The relevant GitHub Actions regression suite completed successfully; **the branch was not merged**.

**Representative commits:** [`765b391`](https://github.com/z1xel/SoftSpoken/commit/765b391), [`abe5cde`](https://github.com/z1xel/SoftSpoken/commit/abe5cde), [`398da91`](https://github.com/z1xel/SoftSpoken/commit/398da91), [`36dd988`](https://github.com/z1xel/SoftSpoken/commit/36dd988).

---

## What the 318 commits ultimately produced

| Area | Final direction |
|---|---|
| Compendium frame | Native Quest Log-inspired art with cropped, repeated source regions and carefully controlled masks |
| Reader | Shared QuestBG parchment, balanced margins, circular book ornament, and scoped viewport fades |
| Navigation | One native scrollbar per scroll model, optimized row rendering, search/filter controls, and responsive layout |
| Quest details | Consistent NPC/item/GameObject portrait fallbacks, stage badges, and speaker typography |
| Places | Integrated **Lore of the Land** panel with Turtle WoW map chrome and shared reader styling |
| Player | Talking Heads Neutral portrait frame, Morpheus name typography, compact brass progress fill, and three-mask tiled border |
| Performance | No chained progress tiles; controlled fallback polling and reduced redundant scroll repaints |
| Packaging | Retired textures removed; source art placed in docs; production names, tests, and asset checks updated |

### Important lessons from the experimental history

1. **Preserve native visual proportions:** fixed ornament caps and authentic atlas crops outperform stretching detailed artwork.
2. **Anchor repeated elements to a stable parent:** chaining tile anchors created visible resize stalls even when texture counts were controlled.
3. **Avoid multiplying masking work:** three shared visual mask regions were preferable to one mask per repeat tile.
4. **Keep one scroll model and one rendering path:** duplicated controllers or synchronous repaint paths add work and complicate Vanilla compatibility.
5. **Distinguish experiments from results:** several rings, fades, header crops, text backgrounds, and atlas extractions were intentionally reverted. Their presence in Git history does not mean they ship.

**Merge note:** The branch passed the available automated checks at this snapshot, but a final in-game visual and resize/scroll regression pass remains appropriate before integration into `main`.

**Source of chronology:** GitHub's chronological [318-commit comparison against `main`](https://github.com/z1xel/SoftSpoken/compare/0eb980f6da6c551e755e4ce50363b3d8de8f7f44...36dd9886f84054c1382c36fb6fe1c32da73d2fcd). Representative commits above are examples, not an exhaustive list.
