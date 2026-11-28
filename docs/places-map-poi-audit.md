# Main POI-only port (P3/P4)

Source: dev cc4a72e6f509258e667a56411fefc53f38ee9cd7, 176 staged positions. Main catalog at 107b9e18b5604225b2c925023956372e3c66c43b, restored byte-for-byte from 737f208. Filter exact map/kind/content key, nonpending actual short or full lore, and known city parent relationship. No new catalog entries, no canonical registry, no saved-variable or discovery changes.

- 141 positions / 139 contextual targets / 36 maps retained.
- 35 positions excluded for no corresponding original lore.
- Coordinates and POI IDs unchanged from dev; strip dev-only canonical IDs.
- Source is Octo DBC-derived, not independently validated on Turtle/other clients. Native hits and owned overlays take priority. Static fallback radius 12 physical UI pixels, ambiguity margin 2 pixels. No new icons or artificial highlights.
- TOC loads static data and resolver. Existing hover/click/lock/drag system reused. No live validation yet.

Reproduce from a checkout of main, using the pinned dev data:
```sh
git show cc4a72e6f509258e667a56411fefc53f38ee9cd7:SoftSpoken/Modules/Places/Data/MapPOIs.lua > /tmp/dev-pois.lua
lua5.1 scripts/filter_dev_pois.lua /tmp/dev-pois.lua cc4a72e6f509258e667a56411fefc53f38ee9cd7 > /tmp/MapPOIs.lua
diff -u SoftSpoken_Places/Data/MapPOIs.lua /tmp/MapPOIs.lua
```
The old DBC generator remains available for historical audits, with optional expansion manifest; it is not the release dataset source.

## Excluded source positions

| Map | Lore key | POI ID |
|---|---|---:|
| 1412 | red cloud roost | 2718 |
| 1412 | windswept heights | 2719 |
| 1416 | slaughter hollow | 247 |
| 1417 | boulderfist outpost | 1010 |
| 1420 | blacktower inn | 2686 |
| 1420 | crumblepoint tower | 2681 |
| 1420 | garrick stead | 2674 |
| 1420 | gracestone mine | 2680 |
| 1420 | ishnudanil | 2679 |
| 1420 | jagged hills | 2687 |
| 1420 | lafford house | 2685 |
| 1420 | remnants camp | 2684 |
| 1420 | rogue heights | 2683 |
| 1420 | shatteridge tower | 2676 |
| 1426 | gnomeregan reclamation facility | 2693 |
| 1428 | hateforge excavation | 2697 |
| 1428 | hateforge quarry | 2698 |
| 1428 | karfang hold | 2696 |
| 1443 | maraudon | 1148 |
| 1446 | sandmoon village | 2723 |
| 1447 | bloodfist point | 2708 |
| 1447 | flaxwhisker front | 2709 |
| 1459 | icewing cavern | 1569 |
| 1459 | stonehearth outpost | 1100 |
| 1459 | wildpaw cavern | 1568 |
| 100408 | broken reef | 2655 |
| 100408 | deepneck cove | 2662 |
| 100616 | darkroot cave | 2746 |
| 105179 | ebonmere farm | 2636 |
| 105179 | mossgrove farm | 2638 |
| 105179 | westgate tower | 2629 |
| 105225 | balladors chapel | 2739 |
| 105225 | deepmurk cave | 2737 |
| 105225 | scourged pass | 2732 |
| 105225 | thaumarium | 2734 |
