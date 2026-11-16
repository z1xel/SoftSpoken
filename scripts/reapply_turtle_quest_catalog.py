#!/usr/bin/env python3
"""Reapply curated high-ID Turtle quests after regenerating Compendium.lua.

Manifest provenance: pfQuest-turtle 1.0.37, October 14, 2026.
Only insert absent IDs and speaker names. Never replace a Vanilla, Turtle
or server-specific record that has already been curated.

  python3 scripts/reapply_turtle_quest_catalog.py
  python3 scripts/reapply_turtle_quest_catalog.py --check
"""
import argparse
import csv
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "SoftSpoken_Stories" / "Data" / "Compendium.lua"
QUESTS = ROOT / "docs" / "turtle_exclusive_import.csv"
NAMES = ROOT / "docs" / "turtle_exclusive_speaker_names.csv"
ROW = re.compile(r"^\s*\[(\d+)\]\s*=\s*\{.*\},\s*$")
NAME_ROW = re.compile(r'^\s*\[(\d+)\]\s*=\s*"(?:\\.|[^"\\])*",\s*$')


def load_csv(path):
    with path.open(encoding="utf-8", newline="") as stream:
        return list(csv.DictReader(stream))


def add_quests(text, records):
    opening, closing = "\n\tquests = {", "\n\t},\n\n\tsorts = {"
    first = text.index(opening) + len(opening)
    last = text.index(closing, first)
    existing = {}
    for line in text[first:last].splitlines():
        if not line.strip():
            continue
        match = ROW.match(line)
        if not match or int(match[1]) in existing:
            raise ValueError("Invalid or duplicate catalog row: " + line[:110])
        existing[int(match[1])] = line
    added = 0
    for record in records:
        if record["status"] != "imported":
            continue
        quest_id = int(record["quest_id"])
        line = "\t\t" + record["compendium_row"]
        match = ROW.match(line)
        if not match or int(match[1]) != quest_id:
            raise ValueError("Malformed manifest entry: " + str(quest_id))
        if quest_id not in existing:
            existing[quest_id] = line
            added += 1
    if not added:
        return text, 0
    updated = "\n" + "\n".join(existing[k] for k in sorted(existing))
    return text[:first] + updated + text[last:], added


def lua_quote(name):
    import json
    return json.dumps(name, ensure_ascii=False)


def add_names(text, records):
    total = 0
    for kind, field in (("U", "npcNames"), ("O", "objectNames"), ("I", "itemNames")):
        selected = {int(r["id"]): r["name"] for r in records if r["kind"] == kind}
        if not selected:
            continue
        opening = "\t" + field + " = {\n"
        pos = text.find(opening)
        if pos < 0:
            insert_at = text.index("\n\tquests = {")
            entries = "".join("\t\t[%d] = %s,\n" % (i, lua_quote(n))
                              for i, n in sorted(selected.items()))
            text = (text[:insert_at] + "\n\t" + field + " = {\n"
                    + entries + "\t},\n" + text[insert_at:])
            total += len(selected)
            continue
        first = pos + len(opening)
        last = text.index("\n\t},", first)
        old = {int(m[1]) for line in text[first:last].splitlines()
               if (m := NAME_ROW.match(line))}
        additions = sorted((i, n) for i, n in selected.items() if i not in old)
        if not additions:
            continue
        extra = "".join("\t\t[%d] = %s,\n" % (i, lua_quote(n))
                        for i, n in additions)
        text = text[:last] + "\n" + extra.rstrip("\n") + text[last:]
        total += len(additions)
    return text, total


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true",
                        help="fail if the imported overlay is incomplete")
    parser.add_argument("--catalog", type=Path, default=CATALOG)
    args = parser.parse_args()
    original = args.catalog.read_text(encoding="utf-8")
    result, n_quests = add_quests(original, load_csv(QUESTS))
    result, n_names = add_names(result, load_csv(NAMES))
    if args.check:
        if result != original:
            raise SystemExit("Incomplete Turtle overlay: %d quests, %d names missing"
                             % (n_quests, n_names))
        print("PASS: Turtle overlay present and idempotent")
    elif result != original:
        args.catalog.write_text(result, encoding="utf-8")
        print("Restored %d Turtle quests and %d entity names" % (n_quests, n_names))
    else:
        print("Turtle quest overlay already present")
    # The separate, reviewed SQL classification manifest is regenerated from
    # the frozen audit. Apply it AFTER adding missing curated quest IDs so a
    # future upstream Compendium regeneration cannot silently lose zones.
    zone_manifest = ROOT / "docs/tortoise_zone_overlay.csv"
    if zone_manifest.exists():
        subprocess.run([
            sys.executable,
            str(ROOT / "scripts/reapply_tortoise_zone_overlay.py"),
            "--check" if args.check else "--apply",
            "--catalog", str(args.catalog)
        ], check=True)
    # Preserve the 20 independently typed-and-spawned quest speaker roles
    # after any future pfQuest corpus regeneration. Never infer a speaker
    # from a neighbor in the chain.
    speaker_manifest = ROOT / "docs/turtle_speaker_recovery.csv"
    if speaker_manifest.exists():
        subprocess.run([
            sys.executable,
            str(ROOT / "scripts/reapply_turtle_speaker_recovery.py"),
            "--check" if args.check else "--apply",
            "--catalog", str(args.catalog)
        ], check=True)
    # Exactly one externally corroborated identity alias: the catalog calls
    # quest 41797 "A Good Friend", while the pinned source calls it
    # "A Dear Friend". This is a NORTHWIND classification, not a quest rename.
    title_alias = ROOT / "docs/audits/turtle_hold_resolution/approved_41797_identity.json"
    if title_alias.exists():
        subprocess.run([
            sys.executable,
            str(ROOT / "scripts/reapply_turtle_zone_exception.py"),
            "--check" if args.check else "--apply",
            "--catalog", str(args.catalog)
        ], check=True)


    # Keep the shipped corpus Vanilla + reviewed Turtle only. This is
    # intentionally last, after all curated quest/region/speaker overlays.
    subprocess.run([
        sys.executable, str(ROOT / "scripts/clean_forever_quest_data.py"),
        "--check" if args.check else "--apply",
        "--catalog", str(args.catalog),
    ], check=True)

if __name__ == "__main__":
    main()
