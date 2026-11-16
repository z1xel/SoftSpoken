#!/usr/bin/env python3
"""Add only 13 manually reviewed, Classic-corroborated Tier 3 quest completions.

All text comes from a pinned Tortoise SQLite source verified against
a permanent quest/stage/title/SHA-256 manifest. Existing Spoken text is not
rewritten. Existing progress stages for the same quest IDs are preserved.
"""
import argparse
import csv
import re
from pathlib import Path

from import_turtle_touched_text import (
    DEFAULT_DESTINATION, load_verified_source, write_atomically,
)
from prepare_tortoise_quest_overlay import lua_quoted

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs/audits/turtle_touched_text_coverage/tier3_13_completion_manifest.csv"
IDS = {9034,9043,9046,9057,9077,9095,9096,9097,9098,9099,9100,9101,9102}
BEGIN = "-- BEGIN verified Tier 3 completion dialogue (13 quest stages)"
END = "-- END verified Tier 3 completion dialogue (13 quest stages)"


def select_manifest(path=MANIFEST):
    with path.open(newline="", encoding="utf-8-sig") as stream:
        rows = list(csv.DictReader(stream))
    if len(rows) != 13:
        raise ValueError(f"Expected 13 Tier 3 quest stages; got {len(rows)}")
    selected = {}
    for row in rows:
        qid = int(row["quest_id"])
        if (qid not in IDS or row["stage"] != "complete" or
                row["source_migration_modified_stage"] != "1" or
                not re.fullmatch(r"[0-9a-f]{64}", row["source_sha256"]) or
                int(row["source_chars"]) <= 0):
            raise ValueError(f"Unexpected Tier 3 stage: {qid}/{row['stage']}")
        if (qid, "complete") in selected:
            raise ValueError(f"Duplicate Tier 3 quest ID {qid}")
        selected[(qid, "complete")] = row
    if {qid for qid, stage in selected} != IDS:
        raise ValueError("Tier 3 imported ID set changed")
    return selected


def render_batch(texts):
    lines = [
        BEGIN,
        "-- 13 Classic-corroborated Tier 3 completion responses from pinned Turtle source.",
        "-- Stage-specific override; original Spoken data is unchanged.",
    ]
    for qid in sorted(IDS):
        lines += [
            f"SSCTurtleQuestText[{qid}] = SSCTurtleQuestText[{qid}] or {{}}",
            f"SSCTurtleQuestText[{qid}].complete = {lua_quoted(texts[qid]['complete'])}",
        ]
    lines.append(END)
    return "\n".join(lines) + "\n"


def merge_batch(original, generated):
    if original.count(BEGIN) != original.count(END) or original.count(BEGIN) > 1:
        raise ValueError("Malformed Tier 3 generated block markers")
    base = original
    if BEGIN in base:
        start = base.index(BEGIN)
        stop = base.index(END, start) + len(END)
        if base[stop:stop+1] == "\n":
            stop += 1
        base = base[:start] + base[stop:]
    if not base.strip():
        raise ValueError("Existing Turtle quest data is missing")
    for qid in sorted(IDS):
        # Existing other-stage assignments are fine. A preexisting complete
        # assignment outside our own generated region is never overwritten.
        if re.search(r"(?m)^[ \t]*SSCTurtleQuestText\[\s*"+str(qid)+r"\s*\]\.complete\s*=", base):
            raise ValueError(f"Preexisting Tier 3 completion override for quest {qid}")
        if re.search(r"(?m)^[ \t]*SSCTurtleQuestText\[\s*"+str(qid)+r"\s*\]\s*=\s*\{", base):
            raise ValueError(f"Preexisting combined quest table for quest {qid}")
    return base + ("" if base.endswith("\n") else "\n") + generated


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--db",type=Path,required=True)
    parser.add_argument("--manifest",type=Path,default=MANIFEST)
    parser.add_argument("--destination",type=Path,default=DEFAULT_DESTINATION)
    parser.add_argument("--write",action="store_true")
    args=parser.parse_args()
    if not args.db.is_file():
        parser.error("Pinned Tortoise source SQLite not found")
    rows=select_manifest(args.manifest)
    texts=load_verified_source(args.db,rows)
    if args.write:
        if not args.destination.is_file():
            raise ValueError("Refusing to create new TurtleQuestText.lua rather than append")
        original=args.destination.read_text(encoding="utf-8")
        write_atomically(args.destination,merge_batch(original,render_batch(texts)))
        print("Imported 13 verified Tier 3 completion-only stages into existing TurtleQuestText.lua")
    else:
        print("Verified 13 Classic-corroborated Tier 3 completion SHA-256 fingerprints")


if __name__=="__main__":
    main()
