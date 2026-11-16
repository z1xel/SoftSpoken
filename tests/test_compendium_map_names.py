#!/usr/bin/env python3
"""Fail if an imported Compendium UiMapID lacks a static display name."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
catalog = (ROOT / "SoftSpoken_Stories/Data/Compendium.lua").read_text(encoding="utf-8")
names = (ROOT / "SoftSpoken/Compendium/UI/MapNames.lua").read_text(encoding="utf-8")
named = {int(value) for value in re.findall(r'\[(\d+)\]\s*=\s*"[^"]+"', names)}
used = {
    int(value)
    for zone_list in re.findall(r'\bzones\s*=\s*\{([^}]*)\}', catalog)
    for value in re.findall(r'\d+', zone_list)
}
missing = sorted(used - named)
assert not missing, "Compendium UiMapIDs without MapNames.lua labels: " + str(missing)
print(f"PASS: all {len(used)} Compendium UiMapIDs have static names")
