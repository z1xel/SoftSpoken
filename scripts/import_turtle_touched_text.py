#!/usr/bin/env python3
"""Verify and locally import the first Turtle-restored shared-ID dialogue batch.

No source dialogue is committed by this script or printed to logs. Audit stages
must be present in a pinned, text-free manifest and match their SHA-256 digest
against the independently fetched Tortoise SQLite before anything is written.

Usage:
  python3 scripts/import_turtle_touched_text.py --db /path/tortoise.sqlite
  python3 scripts/import_turtle_touched_text.py --db /path/tortoise.sqlite --write --local-only
The second command updates the existing TurtleQuestText.lua; it never creates
a companion addon and never touches the original QuestText.lua.
"""
import argparse
import csv
import hashlib
import os
import re
import sqlite3
import tempfile
from collections import defaultdict
from pathlib import Path

import audit_turtle_touched_text as audit
from prepare_tortoise_quest_overlay import lua_quoted

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = ROOT / "docs/audits/turtle_touched_text_coverage/directly_supported_text_gaps.csv"
DEFAULT_DESTINATION = ROOT / "SoftSpoken_Stories/Data/TurtleQuestText.lua"
STAGE_COLUMNS = {"accept": "details", "progress": "requesttext", "complete": "offertext"}
FIRST_BATCH = {
    820: {"accept", "progress", "complete"},
    3111: {"accept"},
    3578: {"accept", "progress", "complete"},
    3579: {"accept", "progress", "complete"},
    3580: {"accept", "progress", "complete"},
}
BEGIN = "-- BEGIN Turtle-touched first batch (generated; local only)"
END = "-- END Turtle-touched first batch"


def select_manifest(manifest):
    with manifest.open(encoding="utf-8-sig", newline="") as fh:
        records = list(csv.DictReader(fh))
    selected = {}
    for row in records:
        quest_id = int(row["quest_id"])
        if quest_id not in FIRST_BATCH:
            continue
        stage = row["stage"]
        if stage not in FIRST_BATCH[quest_id]:
            continue
        if not audit.eligible_direct_turtle_stage(row):
            raise ValueError(f"Quest {quest_id} {stage} is not directly supported")
        if row["coverage"] not in {"turtle_stage_missing", "spoken_outdated_for_turtle"}:
            raise ValueError(f"Quest {quest_id} {stage} has unsafe coverage: {row['coverage']}")
        if row["source_present"] != "1" or row["turtle_overlay_present"] != "0":
            raise ValueError(f"Quest {quest_id} {stage}: missing source or preexisting override")
        key = (quest_id, stage)
        if key in selected:
            raise ValueError(f"Duplicate candidate: {quest_id} {stage}")
        if not re.fullmatch(r"[a-f0-9]{64}", row["source_sha256"]):
            raise ValueError(f"Missing source hash: {quest_id} {stage}")
        selected[key] = row
    expected = {(qid, stage) for qid, stages in FIRST_BATCH.items() for stage in stages}
    if set(selected) != expected:
        missing = sorted(expected - set(selected))
        unexpected = sorted(set(selected) - expected)
        raise ValueError(f"First batch incomplete or changed: missing={missing}, unexpected={unexpected}")
    return selected


def load_verified_source(database, selected):
    with sqlite3.connect(f"file:{database.resolve().as_posix()}?mode=ro", uri=True) as con:
        columns = {r[1].lower() for r in con.execute("PRAGMA table_info(quests)")}
        needed = {"entry", "title", *STAGE_COLUMNS.values()}
        if needed - columns:
            raise ValueError(f"Missing Tortoise source columns: {sorted(needed - columns)}")
        ids = sorted({qid for qid, _ in selected})
        placeholder = ",".join("?" for _ in ids)
        rows = con.execute(
            f"SELECT entry, title, details, requesttext, offertext FROM quests WHERE entry IN ({placeholder})",
            ids,
        ).fetchall()
    by_id = {int(row[0]): row for row in rows}
    if set(by_id) != set(ids):
        raise ValueError(f"Quest IDs missing from source: {sorted(set(ids) - set(by_id))}")
    texts = defaultdict(dict)
    stage_index = {"accept": 2, "progress": 3, "complete": 4}
    for (qid, stage), record in sorted(selected.items()):
        row = by_id[qid]
        if audit.titlekey(row[1]) != audit.titlekey(record["catalog_title"]):
            raise ValueError(f"Source/catalog title mismatch for quest {qid}")
        raw = row[stage_index[stage]]
        if not isinstance(raw, str) or not raw.strip():
            raise ValueError(f"Quest {qid} {stage} source is blank")
        if audit.sha(audit.content(raw)) != record["source_sha256"]:
            raise ValueError(f"Pinned source hash changed for quest {qid} {stage}")
        if len(raw) != int(record["source_chars"]):
            raise ValueError(f"Source character count changed for quest {qid} {stage}")
        texts[qid][stage] = raw
    return texts


def format_batch(texts):
    lines = [BEGIN, "-- Values matched the read-only pinned source audit hashes.",
             "-- Does not rewrite SpokenQuestsText or other Turtle quest IDs."]
    for qid in sorted(texts):
        lines.append(f"SSCTurtleQuestText[{qid}] = SSCTurtleQuestText[{qid}] or {{}}")
        for stage in STAGE_COLUMNS:
            if stage in texts[qid]:
                lines.append(f"SSCTurtleQuestText[{qid}].{stage} = {lua_quoted(texts[qid][stage])}")
    lines.append(END)
    return "\n".join(lines) + "\n"


def merge_local_overlay(original, generated, selected_ids):
    if original.count(BEGIN) != original.count(END) or original.count(BEGIN) > 1:
        raise ValueError("Malformed or duplicated generated batch markers")
    base = original
    if BEGIN in base:
        # Replace only the previously generated block, leaving everything else intact.
        start = base.index(BEGIN)
        stop = base.index(END, start) + len(END)
        if start > stop:
            raise ValueError("Malformed batch markers")
        base = base[:start] + base[stop:]
    # A preexisting assignment might contain legitimate hand-curated Turtle
    # text; refuse to overwrite it rather than inferring which stage is safe.
    for match in re.finditer(r"(?m)^\s*SSCTurtleQuestText\[\s*(\d+)\s*\]\s*(?:=|\.)", base):
        if int(match.group(1)) in selected_ids:
            raise ValueError(f"Quest {match.group(1)} already appears in original Turtle text")
    prefix = "" if base.endswith("\n") or not base else "\n"
    if not base.strip():
        base = "SSCTurtleQuestText = SSCTurtleQuestText or {}\n"
    return base + prefix + generated


def write_atomically(destination, content):
    destination.parent.mkdir(parents=True, exist_ok=True)
    fd, path = tempfile.mkstemp(prefix=".turtle-touched-", suffix=".lua", dir=destination.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as out:
            out.write(content)
        os.replace(path, destination)
    finally:
        if os.path.exists(path):
            os.unlink(path)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--db", type=Path, required=True, help="Verified pinned Tortoise SQLite")
    ap.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    ap.add_argument("--destination", type=Path, default=DEFAULT_DESTINATION)
    ap.add_argument("--write", action="store_true", help="Explicitly update existing TurtleQuestText.lua")
    permission = ap.add_mutually_exclusive_group()
    permission.add_argument("--local-only", action="store_true", help="Private use; do not publish exported text")
    permission.add_argument("--acknowledge-rights", action="store_true",
                            help="Operator confirms responsibility for redistribution permissions")
    args = ap.parse_args()
    if args.write and not (args.local_only or args.acknowledge_rights):
        ap.error("--write requires --local-only or --acknowledge-rights")
    if not args.db.is_file():
        ap.error("Tortoise SQLite not found")
    selected = select_manifest(args.manifest)
    texts = load_verified_source(args.db, selected)
    if args.write:
        original = args.destination.read_text(encoding="utf-8") if args.destination.exists() else ""
        generated = format_batch(texts)
        merged = merge_local_overlay(original, generated, set(texts))
        write_atomically(args.destination, merged)
        print(f"Locally wrote {len(texts)} quest IDs / {len(selected)} stage overrides into {args.destination}")
        print("The original Spoken QuestText.lua and unrelated Turtle data were untouched.")
    else:
        print(f"Source and stage hashes verified: {len(texts)} quest IDs / {len(selected)} stages.")
        print("Read-only check: no addon Lua or quest prose emitted.")


if __name__ == "__main__":
    main()
