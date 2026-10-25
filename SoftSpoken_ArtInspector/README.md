# SoftSpoken Art Inspector (experimental)

Standalone Vanilla 1.12/Turtle WoW addon. It **only displays original client textures**; it does not alter SoftSpoken, the game's shop, or any artwork.

## Install

Put this `SoftSpoken_ArtInspector` directory directly under `Interface\AddOns`, enable it in the character-selection AddOns menu if needed, and reload the game.

If your current addon folder uses Git junctions, you can junction just this directory from a separate checkout of the `ui/top-rock-shadow-pass` branch instead of switching your production SoftSpoken checkout.

## Open

In chat, type `/ssart` (or `/shopart`).

- **Shop 700x460:** renders bg1/bg2 exactly in the same relative positions used by Turtle WoW's ShopFrame XML, cropped to the nominal shop frame dimensions.
- **Both sheets:** both complete 512×512 original texture sheets, placed side by side.
- **bg1 / bg2:** inspect each source separately.
- **Fit / 1:1 / 2:1:** zoom. Drag the artwork to pan if it exceeds the viewport.
- **Light backdrop / Dark backdrop:** inspect true embedded alpha and shaded edges without modifying the artwork.

Sources are loaded by the game from `Interface\ShopFrame\bg1` and `Interface\ShopFrame\bg2`. If the panel is blank, those assets may be absent or inaccessible to your client. This inspector cannot export them to files; it shows the originals rendered by the client.

Blizzard/Turtle art is not included in this repository.
