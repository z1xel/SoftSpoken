#!/usr/bin/env python3
"""Append only the 207 independently sourced missing Turtle quest dialogue stages.

The pinned CSV lists quest ID, stage, title, normalization hash and source length,
not dialogue. Read the pinned Tortoise SQLite, verify all 207 stage hashes,
and atomically append a separately marked block to the EXISTING TurtleQuestText.
No Spoken or earlier Turtle text is overwritten.
"""
import argparse
import csv
import json
import re
from pathlib import Path

from import_turtle_touched_text import (
    DEFAULT_DESTINATION, STAGE_COLUMNS, load_verified_source, write_atomically,
)
import audit_turtle_touched_text as audit
from prepare_tortoise_quest_overlay import lua_quoted

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = ROOT / "docs/audits/turtle_touched_text_coverage/missing_207_verified_stages.csv"
CURATED_CORRECTIONS = ROOT / "docs/audits/turtle_touched_text_coverage/verified_progress_corrections.json"
CORRECTED_IDS = {6283, 8051, 8146}
EXPECTED_STAGES = 207
EXPECTED_QUESTS = 206
BEGIN = "-- BEGIN Turtle-touched missing 207 dialogue stages"
END = "-- END Turtle-touched missing 207 dialogue stages"


def select_manifest(path):
    with path.open(encoding="utf-8-sig", newline="") as stream:
        rows = list(csv.DictReader(stream))
    selected = {}
    for row in rows:
        qid = int(row["quest_id"])
        stage = row["stage"]
        key = (qid, stage)
        if key in selected:
            raise ValueError(f"Duplicate missing-stage candidate: {key}")
        if stage not in STAGE_COLUMNS:
            raise ValueError(f"Invalid stage: {stage}")
        # Only truly absent static stages, not differing Spoken/Vanilla text.
        if (row["coverage"] != "turtle_stage_missing" or
                row["source_present"] != "1" or
                row["spoken_present"] != "0" or
                row["turtle_overlay_present"] != "0" or
                row["source_migration_modified_stage"] != "1" or
                row["source_diff_baseline"] != "1" or
                row["category"] != "dialogue_difference_candidate"):
            raise ValueError(f"Unsafe source or existing dialogue for quest {qid} {stage}")
        if (not re.fullmatch(r"[0-9a-f]{64}", row["source_sha256"]) or
                not int(row["source_chars"])):
            raise ValueError(f"Missing source fingerprint for quest {qid} {stage}")
        selected[key] = row
    if len(selected) != EXPECTED_STAGES:
        raise ValueError(f"Expected {EXPECTED_STAGES} pinned stages, found {len(selected)}")
    if len({qid for qid, _ in selected}) != EXPECTED_QUESTS:
        raise ValueError(f"Expected {EXPECTED_QUESTS} distinct quests")
    if sum(stage == "progress" for _, stage in selected) != 204:
        raise ValueError("Progress stage count drifted")
    if sum(stage == "complete" for _, stage in selected) != 3:
        raise ValueError("Completion stage count drifted")
    if any(stage == "accept" for _, stage in selected):
        raise ValueError("Acceptance is out of scope")
    return selected


def apply_curated_progress_corrections(texts, path=CURATED_CORRECTIONS):
    """Replace three known *misassigned* source strings, never other stages.

    Their original pinned source entries are still validated with the 207
    source SHA-256 manifest before this function is called.
    """
    source = json.loads(path.read_text(encoding="utf-8"))
    rows = source["corrections"]
    ids = {int(r["quest_id"]) for r in rows}
    if ids != CORRECTED_IDS or len(rows) != len(ids):
        raise ValueError("Unexpected curated correction quest IDs")
    touched = CORRECTED_IDS & set(texts)
    if touched and touched != CORRECTED_IDS:
        raise ValueError("Curated correction set is incomplete")
    for row in rows:
        qid = int(row["quest_id"])
        if row["stage"] != "progress" or not row.get("evidence_url", "").startswith(
                "https://www.wowhead.com/classic/quest="):
            raise ValueError(f"Unverified correction for quest {qid}")
        txt = row["text"]
        if not isinstance(txt, str) or len(txt) < 50:
            raise ValueError(f"Blank or suspicious corrected text for quest {qid}")
        if touched:
            old = texts[qid].get("progress")
            if not isinstance(old, str) or not old.strip() or audit.content(old) == audit.content(txt):
                raise ValueError(f"Quest {qid} does not have an incorrect pinned progress stage")
            texts[qid]["progress"] = txt
    return texts


def render_batch(texts):
    lines = [
        BEGIN,
        "-- 204 stages from pinned Turtle hashes; 3 corrected using reviewed Classic quest progress text.",
        "-- Original Tortoise hashes verified before corrected progress values were substituted.",
        "-- No Spoken stages overwritten.",
    ]
    for qid in sorted(texts):
        lines.append(f"SSCTurtleQuestText[{qid}] = SSCTurtleQuestText[{qid}] or {{}}")
        for stage in STAGE_COLUMNS:
            if stage in texts[qid]:
                lines.append(f"SSCTurtleQuestText[{qid}].{stage} = {lua_quoted(texts[qid][stage])}")
    lines.append(END)
    return "\n".join(lines) + "\n"


def merge_batch(original, generated, ids):
    if original.count(BEGIN) != original.count(END) or original.count(BEGIN) > 1:
        raise ValueError("Missing-stage generated block markers are invalid")
    base = original
    if BEGIN in base:
        start = base.index(BEGIN)
        stop = base.index(END, start) + len(END)
        if base[stop:stop + 1] == "\n":
            stop += 1
        base = base[:start] + base[stop:]
    # Conservative: reject any existing assignment for these IDs outside
    # the known generated block. An already-present stage must never be clobbered.
    existing = {int(m.group(1)) for m in re.finditer(
        r"(?m)^[ \t]*SSCTurtleQuestText\[\s*(\d+)\s*\]\s*(?:=|\.)", base)}
    conflicts = existing & ids
    if conflicts:
        raise ValueError(f"Other Turtle text exists for pinned quest IDs: {sorted(conflicts)[:20]}")
    if not base.strip():
        raise ValueError("Refusing to replace the existing Turtle quest corpus with a blank file")
    return base + ("" if base.endswith("\n") else "\n") + generated


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--db", type=Path, required=True, help="Local pinned Tortoise SQLite")
    ap.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    ap.add_argument("--destination", type=Path, default=DEFAULT_DESTINATION)
    ap.add_argument("--write", action="store_true", help="Append the verified stages to TurtleQuestText.lua")
    args = ap.parse_args()
    if not args.db.is_file():
        ap.error("Pinned SQLite source not found")
    selected = select_manifest(args.manifest)
    texts = apply_curated_progress_corrections(load_verified_source(args.db, selected))
    if args.write:
        if not args.destination.is_file():
            raise ValueError("Existing TurtleQuestText.lua is missing; refusing to create replacement")
        original = args.destination.read_text(encoding="utf-8")
        merged = merge_batch(original, render_batch(texts), set(texts))
        write_atomically(args.destination, merged)
        print(f"Committed-file-ready Turtle text: {len(texts)} quest IDs, {len(selected)} stages (3 reviewed progress corrections)")
    else:
        print(f"Verified {len(texts)} quest IDs / {len(selected)} missing stages against source hashes; no text written")


if __name__ == "__main__":
    main()
