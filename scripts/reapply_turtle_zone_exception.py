#!/usr/bin/env python3
"""Replay three vetted quest-classification exceptions without changing quest IDs.

41797 "A Good Friend" / "A Dear Friend": vetted Northwind title alias.
708 The Black Box: item starter; source zone Badlands.
3366 The Glowing Shard: Wailing Caverns item-drop quest.
The wider 37 zone holds remain protected; these three are the ONLY exceptions.
"""
import argparse
import csv
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "SoftSpoken_Stories/Data/Compendium.lua"
APPROVED = ROOT / "docs/audits/turtle_hold_resolution/approved_41797_identity.json"
OLDER = ROOT / "docs/turtle_older_zone_recoveries.csv"
EXPECTED = {
    "quest_id": 41797, "catalog_title": "A Good Friend",
    "source_title": "A Dear Friend", "source_zone": 5581,
    "starter_id": 228, "ender_id": 62307,
}
OLDER_SPECS = {
    708: ("The Black Box", 3, "zones", 1418, "starterItem", 4613),
    3366: ("The Glowing Shard", 718, "turtleArea", 718, "ender", 8418),
}


def verify_record(path=APPROVED):
    data = json.loads(path.read_text(encoding="utf-8"))
    for key, value in EXPECTED.items():
        if data.get(key) != value:
            raise ValueError(f"41797 approved identity changed: {key}")
    if data.get("decision") != "allow_exact_title_alias_without_renaming_catalog":
        raise ValueError("41797 title alias is not approved")
    if not all(data.get("stage_hashes", {}).get(stage)
               for stage in ("accept", "progress", "complete")):
        raise ValueError("Missing pinned quest text fingerprints")
    return data


def modify_quest(text, qid, title, guards, assignment):
    lines = text.splitlines(keepends=True)
    prefix = f"\t\t[{qid}] = {{ {json.dumps(title, ensure_ascii=False)}"
    matches = [i for i, line in enumerate(lines) if line.startswith(prefix)]
    if len(matches) != 1:
        raise ValueError(f"Missing/duplicate or renamed quest {qid}")
    index = matches[0]
    line = lines[index]
    ending = "\r\n" if line.endswith("\r\n") else "\n" if line.endswith("\n") else ""
    body = line[:-len(ending)] if ending else line
    if not body.endswith(" },"):
        raise ValueError(f"Unexpected quest row syntax for {qid}")
    for name, actor in guards.items():
        if not re.search(r"\b" + re.escape(name) +
                         r"\s*=\s*" + str(actor) + r"\b", body):
            raise ValueError(f"Missing validated {name} for quest {qid}")
    if re.search(r"\b(?:turtleArea|zones|sort)\s*=", body):
        if assignment not in body:
            raise ValueError(f"Quest {qid} has a conflicting classification")
        return text, False
    lines[index] = body[:-3].rstrip() + ", " + assignment + " }," + ending
    return "".join(lines), True


def apply(text):
    return modify_quest(
        text, 41797, "A Good Friend",
        {"starter": 228, "ender": 62307}, "turtleArea = 5581",
    )


def apply_older(text, manifest=OLDER):
    with manifest.open(newline="", encoding="utf-8") as source:
        rows = list(csv.DictReader(source))
    if len(rows) != 2 or {int(r["quest_id"]) for r in rows} != set(OLDER_SPECS):
        raise ValueError("Unexpected item-origin classification roster")
    changed = False
    for row in rows:
        qid = int(row["quest_id"])
        title, source_area, kind, value, guard, actor = OLDER_SPECS[qid]
        if (row["catalog_title"] != title or
                int(row["source_area"]) != source_area or
                row["classification"] != kind or int(row["value"]) != value or
                row["guard_field"] != guard or int(row["guard_id"]) != actor or
                not row["reference"].startswith("https://")):
            raise ValueError(f"Item-origin source guard changed for {qid}")
        value_text = (f"zones = {{{value}}}" if kind == "zones"
                      else f"turtleArea = {value}")
        text, updated = modify_quest(text, qid, title, {guard: actor}, value_text)
        changed = changed or updated
    return text, changed


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--apply", action="store_true")
    group.add_argument("--check", action="store_true")
    parser.add_argument("--catalog", type=Path, default=CATALOG)
    parser.add_argument("--approval", type=Path, default=APPROVED)
    args = parser.parse_args()
    verify_record(args.approval)
    original = args.catalog.read_text(encoding="utf-8")
    new, a = apply(original)
    new, b = apply_older(new)
    if args.check:
        if a or b:
            raise SystemExit("One or more approved quest classifications are missing")
        print("PASS: Northwind, Badlands, and Wailing Caverns classifications")
    else:
        if a or b:
            args.catalog.write_text(new, encoding="utf-8")
        print("Applied" if a or b else "Preserved", "three approved classifications")


if __name__ == "__main__":
    main()
