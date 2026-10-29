"""Static regression checks for Darnassus terrain-map fallback assets.

Run: python -m unittest discover -s tools/map -p 'test_*.py'
No WoW installation or third-party packages required.
"""
from pathlib import Path
import re
import struct
import unittest

ROOT = Path(__file__).resolve().parents[2]
ADDON = ROOT / "SoftSpoken_Places"
TERRAIN = ADDON / "UI" / "TerrainMap.lua"
ASSETS = ADDON / "Textures" / "TerrainHighlights"

DARNASSUS = {
    "A": ("CenarionEnclave", 512, 512),
    "B": ("CraftsmensTerrace", 512, 256),
    "C": ("WarriorsTerrace", 256, 256),
    "D": ("TempleGardens", 512, 512),
    "E": ("TradesmensTerrace", 512, 512),
}
CHUNK = 533.3333333333 / 16


class DarnassusTerrainTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source = TERRAIN.read_text(encoding="utf-8")
        cls.rows = {
            int(y): row
            for y, row in re.findall(r'\[(\d+)\] = "([A-Za-z]+)"', cls.source)
        }

    def lookup(self, x, y):
        if not (0 <= x <= 1 and 0 <= y <= 1):
            return None
        world_y = 2938.36011 - x * (2938.36011 - 1880.03003)
        world_x = 10238.32031 - y * (10238.32031 - 9532.58984)
        gx = int((512 - world_y / CHUNK) // 1)
        gy = int((512 - world_x / CHUNK) // 1)
        if gy not in self.rows or not 423 <= gx <= 455:
            return None
        code = self.rows[gy][gx - 423]
        return code if code in DARNASSUS else None

    def test_exact_grid_shape_and_area_coverage(self):
        self.assertEqual(sorted(self.rows), list(range(204, 226)))
        self.assertTrue(all(len(row) == 33 for row in self.rows.values()))
        self.assertEqual(
            {k: sum(row.count(k) for row in self.rows.values()) for k in DARNASSUS},
            {"A": 74, "B": 72, "C": 19, "D": 115, "E": 98},
        )

    def test_original_user_sample(self):
        self.assertEqual(self.lookup(.3543013, .0978802), "A")
        self.assertIsNone(self.lookup(-.01, .2))
        self.assertIsNone(self.lookup(1.01, .2))

    def test_texture_blp2_headers_and_dimensions(self):
        for letter, (name, width, height) in DARNASSUS.items():
            with self.subTest(district=letter):
                blob = (ASSETS / (name + ".blp")).read_bytes()
                self.assertEqual(blob[:4], b"BLP2")
                self.assertEqual(struct.unpack_from("<I", blob, 4)[0], 1)
                self.assertEqual(blob[8:12], b"\x02\x00\x00\x00")
                self.assertEqual(struct.unpack_from("<II", blob, 12), (width, height))
                off = struct.unpack_from("<I", blob, 20)[0]
                size = struct.unpack_from("<I", blob, 84)[0]
                self.assertEqual(off, 1172)
                self.assertEqual(size, width * height // 2)  # DXT1, 4 bpp
                self.assertEqual(len(blob), off + size)

    def test_toc_load_order_and_resolver(self):
        toc = (ADDON / "SoftSpoken_Places.toc").read_text()
        self.assertLess(toc.index(r"UI\TerrainMap.lua"), toc.index(r"UI\MapCompat.lua"))
        compat = (ADDON / "UI" / "MapCompat.lua").read_text()
        self.assertIn('return "subzone", terrainKey, "terrain"', compat)
        self.assertLess(
            compat.index('return "subzone", key, "overlay"'),
            compat.index('return "subzone", terrainKey, "terrain"'),
        )


if __name__ == "__main__":
    unittest.main()
