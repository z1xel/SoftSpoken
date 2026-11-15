#!/usr/bin/env python3
"""Regenerate Vanilla NPC greeting lengths from extracted client metadata.

Inputs downloaded separately:
  Xian55/tortoise-db-viewer scripts/data/sound-map.json
  fondlez/wow-sounds vanilla/wow-sounds-ALL-vanilla-1.12.1.5875.csv
"""
import argparse
import json
from pathlib import Path

def generate(sound_map: Path, vanilla_paths: Path) -> str:
    source = json.loads(sound_map.read_text(encoding="utf-8"))
    if source.get("profile") != "vanilla":
        raise ValueError("Expected sound-map.json with vanilla profile")

    catalog = {
        p.strip().replace("\\", "/").lower()
        for p in vanilla_paths.read_text(encoding="utf-8-sig").splitlines()
        if p.strip()
    }
    result = {}
    kits = {int(row[0]) for row in source["npcSounds"].values() if row and row[0]}
    for kit in kits:
        sound = source["sounds"].get(str(kit))
        if not sound:
            continue
        for relative, ms in zip(sound.get("f", []), sound.get("d", [])):
            if not isinstance(ms, (int, float)) or ms <= 0:
                continue
            relative = relative.replace("\\", "/").lower()
            candidates = ["sound/" + relative]
            if relative.endswith(".ogg"):
                candidates.insert(0, "sound/" + relative[:-4] + ".wav")
            path = next((p for p in candidates if p in catalog), None)
            if path is None:
                continue
            key = path[len("sound/"):]
            if key in result and result[key] != int(ms):
                raise ValueError("Conflicting durations for " + key)
            result[key] = int(ms)

    lines = [
        "-- Generated original Vanilla 1.12.1 NPC greeting audio lengths, in milliseconds.",
        "-- Source: Xian55/tortoise-db-viewer scripts/data/sound-map.json (vanilla profile)",
        "-- Matched against fondlez/wow-sounds vanilla 1.12.1.5875 path list.",
        "-- Only NPCSounds greeting-slot clips with original 1.12 sound paths are retained.",
        "-- This is duration metadata, not the original audio. See docs/greeting-timing.md.",
        "setfenv(1, VoiceOver)",
        "",
        "VanillaGreetingLengths = {",
    ]
    for key, ms in sorted(result.items()):
        lines.append(f'    ["{key}"] = {ms},')
    lines.extend(["}", ""])
    return "\n".join(lines)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("sound_map", type=Path)
    parser.add_argument("vanilla_paths", type=Path)
    parser.add_argument("--output", type=Path, default=Path(
        "SoftSpoken_Stories/Data/VanillaGreetingLengths.lua"))
    args = parser.parse_args()
    output = generate(args.sound_map, args.vanilla_paths)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(output, encoding="utf-8")
    print(f"Wrote {output.count('] = ')} original Vanilla file durations to {args.output}")
