# SoftSpoken Blizzard Art Inspector (experimental)

This standalone Vanilla 1.12 / Turtle WoW addon displays **Blizzard's original frame texture assets**, loaded directly from the game client. It does not create new shadows, recolor the artwork, or change SoftSpoken's Compendium.

## Install

Place the `SoftSpoken_ArtInspector` directory directly inside `Interface\AddOns`. Enable it in the character-selection AddOns menu, if needed, and reload the game.

You can install just this directory from branch `ui/top-rock-shadow-pass` without switching your working SoftSpoken checkout.

## Open

Type `/ssart` or `/blizzart` in game.

- **Character L / R:** the original `Interface\PaperDollInfoFrame\UI-Character-General-TopLeft/TopRight` 256x256 and 128x256 sheets. Includes Blizzard's portrait ring, browner stone background, ridges, frame details, and shadows.
- **Friends L / R:** original `Interface\FriendsFrame\UI-FRIENDSFRAME-TOPLEFT/TOPRIGHT` sheets. Compare the stronger brown stone treatment.
- **Top/title:** the original `Interface\FrameGeneral\_UI-Frame` 256x128 atlas, including the native title-bar tile, bevel and under-header streak.
- **Corners:** original `Interface\FrameGeneral\UI-Frame` 128x128 atlas for portrait and fixed endcap.
- **Sides:** original `Interface\FrameGeneral\!UI-Frame` 64x256 vertical pieces.
- **Rock:** original `Interface\FrameGeneral\UI-Background-Rock` 256x256 tile.
- **Character pair / Friends pair:** display each pair of complete sheets side by side, without any overlay or resizing of the original artwork.
- **Fit / 1:1 / 2:1:** display size. Pan with mouse when zoomed in.
- **Light backdrop:** reveals the true embedded transparency; the pixels themselves are never changed.

## Verified source artwork

Blizzard original art from the [Gethe/wow-ui-textures classic branch](https://github.com/Gethe/wow-ui-textures/tree/classic):

- [PaperDollInfoFrame](https://github.com/Gethe/wow-ui-textures/tree/classic/PaperDollInfoFrame)
- [FriendsFrame](https://github.com/Gethe/wow-ui-textures/tree/classic/FriendsFrame)
- [FrameGeneral](https://github.com/Gethe/wow-ui-textures/tree/classic/FrameGeneral)

Blizzard's corresponding [PortraitFrameTemplateNoCloseButton](https://github.com/Gethe/wow-ui-source/blob/classic/Interface/AddOns/Blizzard_SharedXML/Classic/SharedUIPanelTemplates.xml) demonstrates how the reusable FrameGeneral assets are layered, tiled, and anchored.

This inspector renders the files in the local client by their original texture paths. Some newer Classic assets might not exist in a 1.12 client; if an individual selection renders blank, check its corresponding GitHub PNG. No bundled PNG files are required.

**Important:** The Turtle WoW shop's `ShopFrame/bg1` and `bg2` are precomposed custom images, not the original modular Blizzard frame artwork. They are intentionally not used here.
