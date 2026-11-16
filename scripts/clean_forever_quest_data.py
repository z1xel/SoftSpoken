#!/usr/bin/env python3
"""Remove source-unverified high-ID quest rows from the static in-game corpus.

Only the 600 individually enumerated, already-reviewed exclusions are removed.
The keep set comes from the pinned Vanilla pfQuest IDs, the curated Turtle
manifest, and four independently reviewed restored older quests.

Usage:
    python3 scripts/clean_forever_quest_data.py --check
    python3 scripts/clean_forever_quest_data.py --apply
"""
import argparse
import csv
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "SoftSpoken_Stories/Data/Compendium.lua"
TEXT = ROOT / "SoftSpoken_Stories/Data/QuestText.lua"
VANILLA = ROOT / "docs/vanilla_pfquest_ids.txt"
TURTLE = ROOT / "docs/turtle_exclusive_import.csv"
LEGACY = ROOT / "docs/turtle_restored_legacy_ids.csv"
EXCLUSIONS = ROOT / "docs/forever_quest_exclusions.csv"

CATALOG_ROW = re.compile(r"(?m)^\t\t\[(\d+)\] = \{[^\n]*\},(?:\r?\n|$)")
TEXT_ROW = re.compile(r"(?m)^\t\[(\d+)\] = \{\r?\n[\s\S]*?^\t\},\r?\n")
SORT_ROW = re.compile(r"(?m)^\t\t\[(\d+)\] = \{[^\n]*\},\r?\n")
UNUSED_FOREVER_SORTS = {666}


def csv_rows(path):
    with path.open(encoding="utf-8", newline="") as source:
        return list(csv.DictReader(source))


def ids(pattern, section):
    found = [int(m[1]) for m in pattern.finditer(section)]
    if len(found) != len(set(found)):
        raise ValueError("Duplicated quest IDs")
    return set(found)


def sections(catalog):
    marker = "\n\tquests = {"
    start = catalog.index(marker) + len(marker)
    end = catalog.index("\n\t},\n\n\tsorts = {", start)
    sort_marker = "\n\tsorts = {"
    sort_start = catalog.index(sort_marker, end) + len(sort_marker)
    sort_end = catalog.index("\n\t},", sort_start)
    return start, end, sort_start, sort_end


def clean(catalog, dialogue, denied):
    start, end, _, _ = sections(catalog)
    quest_section = catalog[start:end]
    def keep_or_clean_row(match):
        if int(match[1]) in denied:
            return ""
        # A kept Vanilla quest must not link to a removed Forever-only
        # predecessor. Remove that one unsupported chain edge, not the quest.
        return re.sub(r", prev = (\d+)",
                      lambda m: "" if int(m[1]) in denied else m[0],
                      match[0])

    new_quests = CATALOG_ROW.sub(keep_or_clean_row, quest_section)
    catalog = catalog[:start] + new_quests + catalog[end:]

    start, end, sort_start, sort_end = sections(catalog)
    sort_section = catalog[sort_start:sort_end]
    # Older upstream snapshots contain one or both Forever-only sort labels.
    # Deleting whichever is present is deterministic and idempotent.
    sort_section = SORT_ROW.sub(
        lambda m: "" if int(m[1]) in UNUSED_FOREVER_SORTS else m[0],
        sort_section)
    catalog = catalog[:sort_start] + sort_section + catalog[sort_end:]

    dialogue = TEXT_ROW.sub(
        lambda m: "" if int(m[1]) in denied else m[0], dialogue)
    return catalog, dialogue


def verify(catalog, dialogue, vanilla, turtle, legacy, denied):
    start, end, sort_start, sort_end = sections(catalog)
    catalog_ids = ids(CATALOG_ROW, catalog[start:end])
    text_ids = ids(TEXT_ROW, dialogue)
    expected = vanilla | turtle | legacy
    unidentified = catalog_ids - expected
    if unidentified:
        raise ValueError("Unapproved quest IDs: " + repr(sorted(unidentified)[:15]))
    if denied & expected:
        raise ValueError("Exclusion overlaps a protected Vanilla/Turtle quest")
    if denied & (catalog_ids | text_ids):
        raise ValueError("Excluded quest still in runtime Lua")
    if text_ids - catalog_ids:
        raise ValueError("Orphaned quest dialogue: " + repr(sorted(text_ids-catalog_ids)[:15]))
    if not turtle.issubset(catalog_ids) or not legacy.issubset(catalog_ids):
        raise ValueError("Turtle quest or protected legacy restoration was lost")
    if len(catalog_ids) != 6646 or len(text_ids) != 4228:
        raise ValueError("Unexpected corpus count: %d quests, %d text entries" %
                         (len(catalog_ids), len(text_ids)))
    sorts = ids(SORT_ROW, catalog[sort_start:sort_end])
    if UNUSED_FOREVER_SORTS & sorts:
        raise ValueError("Orphaned Forever-only sort labels remain")
    return len(catalog_ids), len(text_ids)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--apply", action="store_true")
    mode.add_argument("--check", action="store_true")
    parser.add_argument("--catalog", type=Path, default=CATALOG)
    parser.add_argument("--text", type=Path, default=TEXT)
    args = parser.parse_args()

    vanilla = {int(s) for s in VANILLA.read_text(encoding="utf-8").splitlines() if s}
    turtle = {int(r["quest_id"]) for r in csv_rows(TURTLE)
              if r["status"] in ("imported", "already_present")}
    legacy = {int(r["quest_id"]) for r in csv_rows(LEGACY)}
    removals = csv_rows(EXCLUSIONS)
    denied = {int(r["quest_id"]) for r in removals}
    if not (len(vanilla) == 4433 and len(turtle) == 2377 and
            len(legacy) == 4 and len(denied) == 600 and
            all(i >= 20000 for i in denied)):
        raise ValueError("Pinned corpus source manifest changed unexpectedly")

    original_catalog = args.catalog.read_text(encoding="utf-8")
    original_text = args.text.read_text(encoding="utf-8")
    new_catalog, new_text = clean(original_catalog, original_text, denied)
    counts = verify(new_catalog, new_text, vanilla, turtle, legacy, denied)

    if args.check:
        if new_catalog != original_catalog or new_text != original_text:
            raise SystemExit("Forever-source exclusions not fully applied")
        print("PASS: %d clean quests, %d static dialogue entries" % counts)
    else:
        if new_catalog != original_catalog:
            args.catalog.write_text(new_catalog, encoding="utf-8")
        if new_text != original_text:
            args.text.write_text(new_text, encoding="utf-8")
        print("Applied source exclusions: %d quests, %d dialogue entries" % counts)


if __name__ == "__main__":
    main()
