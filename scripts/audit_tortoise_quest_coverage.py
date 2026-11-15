#!/usr/bin/env python3
"""Read-only coverage audit of Turtle-exclusive quests against a Tortoise SQLite snapshot.

No quest dialogue is imported or copied: only presence flags, lengths, source titles,
classification IDs and source/version provenance are recorded.
"""
import argparse
import csv
import json
import re
import sqlite3
import unicodedata
from collections import Counter, defaultdict
from pathlib import Path

TARGET_STATUSES = {"imported", "already_present"}
REQUIRED_COLUMNS = {"entry", "title", "zone", "details", "objectives", "requesttext", "offertext", "endtext"}
FIELDS = [
    "quest_id", "manifest_status", "catalog_title", "source_title", "source_record",
    "title_match", "accept_present", "progress_present", "complete_present", "all_three",
    "objectives_present", "endtext_present", "zone_or_sort", "classification_kind",
    "accept_chars", "progress_chars", "complete_chars"
]

def norm_title(value):
    value = unicodedata.normalize("NFKC", value or "")
    return re.sub(r"\s+", " ", value).strip().casefold()

def has_text(value):
    return isinstance(value, str) and bool(value.strip())

def count_text(value):
    return len(value) if has_text(value) else 0

def read_manifest(path):
    targets = {}
    source_status = Counter()
    with path.open(encoding="utf-8-sig", newline="") as fh:
        reader = csv.DictReader(fh)
        required = {"quest_id", "status", "title"}
        if not required.issubset(reader.fieldnames or []):
            raise ValueError(f"Missing manifest columns: {sorted(required - set(reader.fieldnames or []))}")
        for rec in reader:
            status = rec["status"].strip()
            source_status[status] += 1
            if status not in TARGET_STATUSES:
                continue
            quest_id = int(rec["quest_id"])
            if quest_id in targets:
                raise ValueError(f"Duplicate target quest ID: {quest_id}")
            targets[quest_id] = rec
    if not targets:
        raise ValueError("No Turtle-exclusive target quests found")
    return targets, source_status

def get_quest_rows(path, ids):
    db = sqlite3.connect(f"file:{path.resolve().as_posix()}?mode=ro", uri=True)
    db.row_factory = sqlite3.Row
    try:
        cols = {row[1] for row in db.execute("PRAGMA table_info(quests)")}
        if REQUIRED_COLUMNS - cols:
            raise ValueError(f"Missing SQLite columns: {sorted(REQUIRED_COLUMNS - cols)}")
        found = {}
        for offset in range(0, len(ids), 400):
            part = ids[offset:offset + 400]
            placeholders = ",".join("?" for _ in part)
            sql = ("SELECT entry, title, zone, details, objectives, requesttext, "
                   f"offertext, endtext FROM quests WHERE entry IN ({placeholders})")
            for row in db.execute(sql, part):
                found[int(row["entry"])] = dict(row)
        return found
    finally:
        db.close()

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--db", required=True, type=Path)
    ap.add_argument("--manifest", type=Path, default=Path("docs/turtle_exclusive_import.csv"))
    ap.add_argument("--out", type=Path, default=Path("docs/audits/tortoise_quest_coverage"))
    ap.add_argument("--source-ref", default="unspecified")
    args = ap.parse_args()
    targets, source_status = read_manifest(args.manifest)
    quests = get_quest_rows(args.db, sorted(targets))
    summary = {
        "dataset": "Tortoise-WoW viewer SQLite, community restoration (not live Turtle WoW)",
        "source_ref": args.source_ref,
        "targets": len(targets),
        "manifest_status_counts": dict(sorted(source_status.items())),
        "counts": {},
        "by_manifest_status": {},
        "warning": "Read-only coverage; neither live equivalence nor text redistribution rights established."
    }
    counts = Counter()
    per_status = defaultdict(Counter)
    rows, conflicts = [], []
    for quest_id, manifest in sorted(targets.items()):
        src = quests.get(quest_id)
        present = src is not None
        source_title = (src["title"] or "") if present else ""
        if not present:
            title_match = "missing_record"
        elif manifest["title"] == source_title:
            title_match = "exact"
        elif norm_title(manifest["title"]) == norm_title(source_title):
            title_match = "normalized"
        else:
            title_match = "different"
        accept = bool(present and has_text(src["details"]))
        progress = bool(present and has_text(src["requesttext"]))
        complete = bool(present and has_text(src["offertext"]))
        all_three = accept and progress and complete
        objectives = bool(present and has_text(src["objectives"]))
        endtext = bool(present and has_text(src["endtext"]))
        zone = src["zone"] if present else None
        classification = ("zone" if isinstance(zone, int) and zone > 0 else
                          "sort" if isinstance(zone, int) and zone < 0 else
                          "unclassified")
        row = {
            "quest_id": quest_id, "manifest_status": manifest["status"],
            "catalog_title": manifest["title"], "source_title": source_title,
            "source_record": int(present), "title_match": title_match,
            "accept_present": int(accept), "progress_present": int(progress),
            "complete_present": int(complete), "all_three": int(all_three),
            "objectives_present": int(objectives), "endtext_present": int(endtext),
            "zone_or_sort": zone if zone is not None else "",
            "classification_kind": classification,
            "accept_chars": count_text(src["details"]) if present else 0,
            "progress_chars": count_text(src["requesttext"]) if present else 0,
            "complete_chars": count_text(src["offertext"]) if present else 0,
        }
        rows.append(row)
        if present and title_match == "different":
            conflicts.append(row)
        subset = per_status[manifest["status"]]
        subset["total"] += 1
        counts[f"title_{title_match}"] += 1
        for key, test in {
            "source_record": present, "accept": accept, "progress": progress,
            "complete": complete, "all_three": all_three, "objectives": objectives,
            "endtext": endtext, "classified": classification != "unclassified",
            "zones": classification == "zone", "sorts": classification == "sort"
        }.items():
            if test:
                counts[key] += 1
                subset[key] += 1
    summary["counts"] = dict(sorted(counts.items()))
    summary["by_manifest_status"] = {key: dict(sorted(values.items()))
                                      for key, values in sorted(per_status.items())}
    args.out.mkdir(parents=True, exist_ok=True)
    for name, items in (("coverage.csv", rows), ("title_conflicts.csv", conflicts)):
        with (args.out / name).open("w", newline="", encoding="utf-8") as fh:
            writer = csv.DictWriter(fh, fieldnames=FIELDS)
            writer.writeheader()
            writer.writerows(items)
    with (args.out / "summary.json").open("w", encoding="utf-8") as fh:
        json.dump(summary, fh, ensure_ascii=False, indent=2, sort_keys=True)
        fh.write("\n")
    print(json.dumps(summary, indent=2, ensure_ascii=False))
    print(f"Audited {len(targets)} IDs; wrote reports to {args.out}")

if __name__ == "__main__":
    main()
