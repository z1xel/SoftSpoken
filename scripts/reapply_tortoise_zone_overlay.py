#!/usr/bin/env python3
"""Reapply the verified Turtle quest classification overlay to Compendium.lua.

This deliberately uses a frozen manifest, NOT the live database. Safe to run
after regenerating Compendium.lua; never creates quest records or changes
existing Vanilla classifications.

  python3 scripts/reapply_tortoise_zone_overlay.py --apply
  python3 scripts/reapply_tortoise_zone_overlay.py --check
"""
import argparse
import csv
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs/tortoise_zone_overlay.csv"
CATALOG = ROOT / "SoftSpoken_Stories/Data/Compendium.lua"
ROW = re.compile(r'^(\s*\[(\d+)\]\s*=\s*)(\{[^\n]*\})(,\s*)$', re.M)
FIELD = re.compile(r'\b(zones|sort|turtleArea)\s*=')


def read_manifest(path):
    with path.open(encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream)
        required = {"quest_id", "catalog_title", "classification", "value", "status"}
        if not required.issubset(reader.fieldnames or []):
            raise ValueError("Missing classification manifest fields")
        records = {}
        for r in reader:
            qid = int(r["quest_id"])
            if qid in records:
                raise ValueError("Duplicate classification ID " + str(qid))
            if r["status"] != "selected":
                raise ValueError("Manifest contains an unapproved quest " + str(qid))
            kind = r["classification"]
            if kind not in {"zones", "sort", "turtleArea"}:
                raise ValueError("Unrecognized field " + str(kind))
            value = int(r["value"])
            if value <= 0:
                raise ValueError("Invalid classification number " + str(qid))
            records[qid] = {"value": value, "kind": kind, "title": r["catalog_title"]}
    return records


def title_of(body):
    m = re.match(r'^\{\s*("(?:[^"\\]|\\.)*")', body)
    if not m:
        raise ValueError("Quest row has no JSON-compatible title: " + body[:80])
    return json.loads(m[1])


def field_assignment(rec):
    kind, val = rec["kind"], rec["value"]
    if kind == "zones":
        return "zones = {" + str(val) + "}"
    return kind + " = " + str(val)


def apply(original, rows):
    opening, closing = "\n\tquests = {", "\n\t},\n\n\tsorts = {"
    a = original.index(opening) + len(opening)
    b = original.index(closing, a)
    body = original[a:b]
    matches = list(ROW.finditer(body))
    mapping = {}
    for m in matches:
        qid = int(m[2])
        if qid in mapping:
            raise ValueError("Duplicate Compendium quest " + str(qid))
        mapping[qid] = m
    missing = set(rows) - set(mapping)
    if missing:
        raise ValueError("Overlay would require adding absent quest IDs: " +
                         str(sorted(missing)[:25]))

    outputs, added, preserved = [], 0, 0
    last = 0
    for m in matches:
        qid = int(m[2])
        rec = rows.get(qid)
        if not rec:
            continue
        original_body = m[3]
        if title_of(original_body) != rec["title"]:
            raise ValueError("Catalog title changed for quest " + str(qid))
        wanted = field_assignment(rec)
        current = FIELD.findall(original_body)
        if current:
            # Never replace a new classification that upstream or a curator added.
            if len(current) != 1 or current[0] != rec["kind"] or not re.search(
                r'(?<!\w)' + re.escape(wanted).replace(r'\ ', r'\s*') + r'(?!\w)',
                original_body
            ):
                raise ValueError("Conflicting pre-existing classification for quest " + str(qid))
            preserved += 1
            continue
        append = original_body[:-1] + ", " + wanted + "}"
        outputs.append(body[last:m.start()])
        outputs.append(m[1] + append + m[4])
        last = m.end()
        added += 1
    outputs.append(body[last:])
    new = original[:a] + "".join(outputs) + original[b:]
    return new, added, preserved


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--apply", action="store_true")
    group.add_argument("--check", action="store_true")
    parser.add_argument("--manifest", type=Path, default=MANIFEST)
    parser.add_argument("--catalog", type=Path, default=CATALOG)
    args = parser.parse_args()
    rows = read_manifest(args.manifest)
    original = args.catalog.read_text(encoding="utf-8")
    result, added, preserved = apply(original, rows)
    if added + preserved != len(rows):
        raise ValueError("Not all manifest records accounted for")
    if args.check:
        if result != original or added:
            raise SystemExit(str(added) + " approved classifications still missing")
        print("PASS: " + str(preserved) + " Turtle classifications present")
    else:
        if added:
            args.catalog.write_text(result, encoding="utf-8")
        print("Applied " + str(added) + " classifications, preserved " +
              str(preserved) + ", total " + str(len(rows)))


if __name__ == "__main__":
    main()
