#!/usr/bin/env python3
"""Prepare a Turtle-only quest dialogue overlay from a local Tortoise SQLite snapshot.

Default: read-only compatibility decisions (CSV/JSON, NO third-party text copied).
Opt-in --emit-text: write a local Lua overlay only after the operator has confirmed
the source text's redistribution/use permissions; NEVER automatically commit it.
"""
import argparse
import csv
import json
import sqlite3
import unicodedata
from collections import Counter
from pathlib import Path

SUPPORTED = {"imported", "already_present"}
STAGES = {"accept": "details", "progress": "requesttext", "complete": "offertext"}
# Curly/straight quotation marks are typography variants, not title changes.
TRANSLATE = str.maketrans({
    "\u2018": "'", "\u2019": "'", "\u201a": "'", "\u201b": "'",
    "\u201c": '"', "\u201d": '"', "\u201e": '"', "\u201f": '"',
    "\u00a0": " ",
})
ROWS = ("quest_id", "status", "catalog_title", "source_title", "decision",
        "reason", "available_stages", "zone_or_sort")


def title_key(value):
    normalized = unicodedata.normalize("NFKC", value or "").translate(TRANSLATE)
    return " ".join(normalized.split()).casefold()


def decide(manifest_title, source_title, record_exists):
    if not record_exists:
        return "hold", "missing_source"
    if any(phrase in (source_title or "").upper() for phrase in
           ("[DEPRECATED]", "[CANCELLED]", "[CANCELED]", "[DISABLED]", "[DUMMY]")):
        return "hold", "retired_source"
    if manifest_title == source_title:
        return "eligible", "exact_title"
    if title_key(manifest_title) == title_key(source_title):
        return "eligible", "typography_only"
    return "hold", "title_conflict"


def parse_targets(path):
    with path.open(encoding="utf-8-sig", newline="") as stream:
        rows = list(csv.DictReader(stream))
    targets = {}
    for row in rows:
        if row["status"] not in SUPPORTED:
            continue
        quest_id = int(row["quest_id"])
        if quest_id in targets:
            raise ValueError(f"Duplicate target quest {quest_id}")
        targets[quest_id] = row
    return targets


def load_rows(database, ids):
    con = sqlite3.connect(f"file:{database.resolve().as_posix()}?mode=ro", uri=True)
    con.row_factory = sqlite3.Row
    try:
        columns = {x[1] for x in con.execute("PRAGMA table_info(quests)")}
        required = {"entry", "title", "zone"} | set(STAGES.values())
        if required - columns:
            raise ValueError(f"Missing source columns: {sorted(required - columns)}")
        result = {}
        for offset in range(0, len(ids), 400):
            sub = ids[offset:offset + 400]
            sql = ("SELECT entry, title, zone, details, requesttext, offertext "
                   "FROM quests WHERE entry IN (" + ",".join("?" for _ in sub) + ")")
            for rec in con.execute(sql, sub):
                result[int(rec["entry"])] = dict(rec)
        return result
    finally:
        con.close()


def make_overlay(accepted, destination):
    # Ensure all emitted strings are valid Lua 5.1 double-quoted literals.
    lines = [
        "-- Generated Turtle-only quest dialogue. DO NOT edit by hand.",
        "-- Local export only; verify source content rights before redistribution.",
        "SSCTurtleQuestText = SSCTurtleQuestText or {}",
    ]
    for quest_id, src in sorted(accepted.items()):
        texts = [(stage, src[field]) for stage, field in STAGES.items()
                 if isinstance(src[field], str) and src[field].strip()]
        if not texts:
            continue
        lines.append("SSCTurtleQuestText[%d] = {" % quest_id)
        for stage, value in texts:
            # ensure_ascii=False keeps UTF-8 without JSON's \uXXXX (not Lua 5.1).
            quoted = json.dumps(value, ensure_ascii=False)
            if "\\u" in quoted or "\\/" in quoted:
                raise ValueError(f"Non-Lua escape in quest {quest_id} {stage}")
            lines.append("    %s = %s," % (stage, quoted))
        lines.append("}")
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--db", type=Path, required=True)
    ap.add_argument("--manifest", type=Path, default=Path("docs/turtle_exclusive_import.csv"))
    ap.add_argument("--out", type=Path, default=Path("docs/audits/tortoise_quest_overlay"))
    ap.add_argument("--source-ref", default="unspecified")
    ap.add_argument("--emit-text", type=Path,
                    help="Explicit, local-only text export path; never run during public CI")
    ap.add_argument("--acknowledge-rights", action="store_true",
                    help="Confirm right to use/export source dialogue; required with --emit-text")
    args = ap.parse_args()
    if args.emit_text and not args.acknowledge_rights:
        ap.error("--emit-text requires --acknowledge-rights (the source license alone is insufficient)")
    targets = parse_targets(args.manifest)
    source = load_rows(args.db, sorted(targets))
    counts, accepted, report, held = Counter(), {}, [], []
    for quest_id, manifest in sorted(targets.items()):
        src = source.get(quest_id)
        title = src["title"] if src else ""
        decision, reason = decide(manifest["title"], title, src is not None)
        stages = [stage for stage, column in STAGES.items()
                  if src and isinstance(src[column], str) and src[column].strip()]
        if decision == "eligible":
            accepted[quest_id] = src
        else:
            held.append(quest_id)
        counts[f"{decision}_{reason}"] += 1
        row = {
            "quest_id": quest_id, "status": manifest["status"],
            "catalog_title": manifest["title"], "source_title": title,
            "decision": decision, "reason": reason,
            "available_stages": ";".join(stages),
            "zone_or_sort": src["zone"] if src is not None else "",
        }
        report.append(row)
    args.out.mkdir(parents=True, exist_ok=True)
    with (args.out / "decisions.csv").open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=ROWS)
        writer.writeheader()
        writer.writerows(report)
    summary = {
        "source_ref": args.source_ref,
        "total_targets": len(targets),
        "eligible": len(accepted),
        "held": held,
        "reason_counts": dict(sorted(counts.items())),
        "text_exported": bool(args.emit_text),
        "notice": "Source and version match is not proven by title alone. Full dialogue reuse rights not verified."
    }
    with (args.out / "summary.json").open("w", encoding="utf-8") as fh:
        json.dump(summary, fh, indent=2, ensure_ascii=False)
        fh.write("\n")
    if args.emit_text:
        make_overlay(accepted, args.emit_text)
    print(json.dumps(summary, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
