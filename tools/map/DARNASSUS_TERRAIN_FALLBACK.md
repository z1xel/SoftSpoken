# Darnassus terrain map fallback (integration trial)

This branch folds the independently tested `SSZTerrainProbe` lookup into
SoftSpoken Places. It is deliberately restricted to displayed map 1457
(Darnassus). Do **not** interpret it as coverage of the full map-gap audit.

## What is new

- `UI/TerrainMap.lua` performs a constant-time lookup into 33x22
  terrain chunk data, derived from the player's actual Turtle WoW ADT scan.
- `UI/MapCompat.lua` calls that lookup **only after** native/POI/precise
  and conservative unique-overlay paths fail. It returns ordinary
  `subzone` selections and never reports discovery.
- `UI/MapHighlight.lua` reuses the existing hover manager and draws one
  generated BLP texture using `ADD` blending at alpha=1.
- The texture silhouettes use offline Gaussian smoothing/thresholding and
  feathering, with muted Teldrassil-derived additive color.
- Five compact BLP2/DXT1 textures are bundled, with no new addon dependency.

The map's location lookup and rendered highlight are separate: selection
can work even if an asset fails to load. The overlay/native paths retain
precedence. Map panel, selection and discovery restrictions are unchanged.

## In-game acceptance test

Install this branch's **whole** SoftSpoken_Places folder in the usual
SoftSpoken installation (no SSZTerrainProbe needed). Disable or remove
SSZTerrainProbe for an unambiguous visual test.

1. `/reload`; open Darnassus' map. Move the pointer through Cenarion
   Enclave, Craftsmen's Terrace, Warrior's Terrace, Temple Gardens and
   Tradesmen's Terrace.
2. Already-discovered districts should display the soft additive
   highlight and normal lore hover. Click without dragging: the correct
   district opens in the existing Places panel.
3. An undiscovered district must not reveal its lore because of hovering
   or clicking, and clicks must not alter visited/discovered records.
4. Hover/click a POI. Its own target must take precedence over terrain.
5. Switch to another map and back; old highlight must not remain visible.
6. Switch full-screen/minimized world map while hovering; texture must
   remain attached to the corresponding district.
7. Check an ordinary outdoor zone such as Elwynn: the existing overlay
   path and visual behavior should remain unchanged.
8. If ClassicAPI is disabled, Darnassus's terrain fallback should still
   work as long as native 1.12 map frames are available; other overlay
   features remain ClassicAPI-dependent.

## Limitations and follow-up

- Terrain chunk boundaries are ~33.33 yards, not hand-drawn district
  polygons; the smoothed highlight is a visual approximation.
- The build includes the **five** Darnassus entries only. The other
  missing/shared map areas still need the separate map-gap audit work.
- Blended values are calibrated to the Teldrassil native highlight
  reference, not to bespoke Darnassus district artwork (which does not
  exist in the client).
- The BLP2 assets are generated for this scan and intentionally checked in;
  a reusable generator for all missing maps belongs in a later phase.
- Client-side acceptance remains necessary. Automated checks cannot
  establish correct WoW 1.12 rendering or mouse event behavior.
