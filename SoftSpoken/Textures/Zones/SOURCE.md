# Bundled zone portrait emblems

This folder contains 57 unmodified `.tga` textures from upstream Spoken:

- Source: [rusty-key/spoken-wow](https://github.com/rusty-key/spoken-wow/tree/59a3445d70346b69815efa8cec5f21156dc4d144/addons/Spoken/Textures/Zones)
- Pinned upstream revision: `59a3445d70346b69815efa8cec5f21156dc4d144`
- Upstream attribution: [THIRD_PARTY.md](https://github.com/rusty-key/spoken-wow/blob/59a3445d70346b69815efa8cec5f21156dc4d144/THIRD_PARTY.md)

Most zone emblems originate from Blizzard's later-game zone-achievement artwork;
the Azeroth globe and battleground images also derive from game assets. The
custom Forever-zone, city and Moonglade emblems were made for upstream Spoken in
the same visual style. The MIT license covering the addon code **does not**
grant rights to this artwork. See the linked upstream third-party notice.

The map ID -> filename table is in `SoftSpoken/API.lua`. Narrator portraits
are chosen in `SoftSpoken_Places/Audio.lua`: subzone audio reuses its parent
zone's icon, and a missing icon uses the existing SoftSpoken book art.
Scenic illustrations in `SoftSpoken_Places/Textures/Pictures/` are a separate
asset set, retained for the Places Compendium.
