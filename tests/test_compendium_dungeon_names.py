#!/usr/bin/env python3
"""All dungeon-map IDs referenced by the quest catalog must have a display name."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
catalog = (ROOT / "SoftSpoken_Stories/Data/Compendium.lua").read_text(encoding="utf-8")
names = (ROOT / "SoftSpoken/Compendium/UI/DungeonNames.lua").read_text(encoding="utf-8")
used = {int(x) for x in re.findall(r'\bdungeon\s*=\s*(\d+)', catalog)}
named = {int(x) for x in re.findall(r'\[(\d+)\]\s*=\s*"[^"]+"', names)}
missing = sorted(used - named)
assert not missing, "Quest dungeon IDs missing from DungeonNames.lua: " + str(missing)
assert len(used) == 26, "Unexpected dungeon count; review catalog coverage"
assert 3065 not in named, "Forever-only Hall of Thanes dungeon label remains"
print(f"PASS: all {len(used)} quest dungeon-map IDs have static names")
