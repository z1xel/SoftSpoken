#!/usr/bin/env python3
"""Three-way read-only triage of 35 large Spoken/Tortoise dialogue differences.

Compares original Spoken text, pinned Turtle viewer text, and an independent
Vanilla cMaNGOS baseline. Summarizes text loss/addition patterns, duplicate
dialogue families and first distinct passages. Leaves all Lua files untouched.
"""
import argparse
import collections
import csv
import difflib
import json
import re
import sqlite3
from pathlib import Path

import audit_turtle_touched_text as audit
from analyze_turtle_conflicting_dialogue import first_changed_excerpt, inline

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs/audits/turtle_touched_text_coverage"


def presentation_words(raw):
    """Ignore WoW one-letter directives only for broad wording containment."""
    text = re.sub(r"\$[A-Za-z]", " ", audit.content(raw)).casefold()
    return re.findall(r"[\w]+", text, re.UNICODE)


def contains_contiguous(longer, shorter):
    if not shorter:
        return False
    n = len(shorter)
    return any(longer[i:i+n] == shorter for i in range(len(longer)-n+1))


def containment(spoken, turtle):
    a, b = presentation_words(spoken), presentation_words(turtle)
    if a == b:
        return "same_words"
    if len(b) <= len(a) and a[:len(b)] == b:
        return "turtle_is_spoken_prefix"
    if len(a) <= len(b) and b[:len(a)] == a:
        return "spoken_is_turtle_prefix"
    if len(b) < len(a) and contains_contiguous(a, b):
        return "turtle_contained_in_spoken"
    if len(a) < len(b) and contains_contiguous(b, a):
        return "spoken_contained_in_turtle"
    if len(b) < len(a):
        return "shorter_but_rewritten"
    if len(b) > len(a):
        return "longer_but_rewritten"
    return "rephrased_equal_word_count"


def similarity(a, b):
    if not a or not b:
        return None
    return round(difflib.SequenceMatcher(
        None, audit.content(a), audit.content(b), autojunk=False).ratio(), 4)


def baseline_assessment(spoken, turtle, vanilla):
    if not vanilla or not audit.content(vanilla):
        return "baseline_missing", None, None
    a, b = similarity(spoken, vanilla), similarity(turtle, vanilla)
    if a - b > .05:
        status = "spoken_closer_to_vanilla"
    elif b - a > .05:
        status = "turtle_closer_to_vanilla"
    else:
        status = "approximately_equal"
    return status, a, b


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--turtle", type=Path, required=True)
    p.add_argument("--vanilla", type=Path, required=True)
    p.add_argument("--lua-stages", type=Path, required=True)
    p.add_argument("--out", type=Path, default=OUT)
    args = p.parse_args()
    with (args.out / "conflict_review.csv").open(
            newline="", encoding="utf-8") as stream:
        rows = list(csv.DictReader(stream))
    selected = [r for r in rows if r["edit_category"] == "substantial_difference"]
    if len(rows) != 289 or len(selected) != 35:
        raise ValueError(f"Expected 35 substantial from 289: {len(selected)} from {len(rows)}")
    static = audit.get_static(args.lua_stages)
    with sqlite3.connect(f"file:{args.turtle.resolve()}?mode=ro", uri=True) as con:
        turtle = audit.get_turtle(con)
    with sqlite3.connect(f"file:{args.vanilla.resolve()}?mode=ro", uri=True) as con:
        vanilla = audit.get_vanilla(con)

    counts = collections.Counter()
    duplicate_sha = collections.Counter(r["source_sha256"] for r in selected)
    report = []
    lines = [
        "# Side-by-side review: 35 substantial dialogue conflicts",
        "",
        "No dialogue is modified by this analysis. Comparison uses original Spoken",
        "Lua, pinned Tortoise quest rows, and cMaNGOS Classic quest_template.",
        "Similarity and substring checks are triage heuristics, **not a claim",
        "that Turtle deliberately removed or changed the text**.",
        "",
    ]
    for row in selected:
        qid = int(row["quest_id"])
        stage = row["stage"]
        column, vcol = audit.STAGES[stage]
        t = turtle[qid][column]
        s = static.get((qid, "spoken"), {}).get(stage, "")
        base = vanilla.get(qid)
        v = base[vcol.lower()] if base else ""
        if (not s or not t or audit.sha(audit.content(t)) != row["source_sha256"]):
            raise ValueError(f"Broken stage content or source fingerprint: {qid} {stage}")
        if static.get((qid, "turtle"), {}).get(stage):
            raise ValueError(f"Previously overridden stage is no longer a conflict: {qid} {stage}")
        status, spoken_sim, turtle_sim = baseline_assessment(s, t, v)
        shape = containment(s, t)
        counts["baseline_"+status] += 1
        counts["shape_"+shape] += 1
        if int(row["length_delta"]) < 0:
            counts["shorter_turtle"] += 1
        else:
            counts["longer_turtle"] += 1
        if duplicate_sha[row["source_sha256"]] > 1:
            counts["has_identical_turtle_text_across_quests"] += 1
        old_excerpt, new_excerpt = first_changed_excerpt(audit.content(s), audit.content(t), limit=115)
        if len(old_excerpt) < 30 and len(s) > 100:
            old_excerpt = audit.content(s)[:115]
        if len(new_excerpt) < 30 and len(t) > 100:
            new_excerpt = audit.content(t)[:115]
        report.append({
            "quest_id": qid,
            "title": row["catalog_title"],
            "stage": stage,
            "spoken_chars": int(row["spoken_chars"]),
            "turtle_chars": int(row["turtle_chars"]),
            "difference_chars": int(row["length_delta"]),
            "spoken_turtle_similarity": float(row["similarity"]),
            "relationship": shape,
            "vanilla_status": status,
            "spoken_vanilla_similarity": "" if spoken_sim is None else spoken_sim,
            "turtle_vanilla_similarity": "" if turtle_sim is None else turtle_sim,
            "reused_turtle_source_count": duplicate_sha[row["source_sha256"]],
            "source_sha256": row["source_sha256"],
        })
        lines += [
            f"### {qid} — {row['catalog_title']} ({stage})",
            "",
            f"- **Lengths:** Spoken {row['spoken_chars']} characters; Turtle {row['turtle_chars']} "
            f"({int(row['length_delta']):+d}).",
            f"- **Text relationship:** {shape.replace('_', ' ')}.",
            f"- **Vanilla comparison:** {status.replace('_', ' ')}"
            + (f" (Spoken {spoken_sim:.2f}; Turtle {turtle_sim:.2f} similarity)"
               if spoken_sim is not None else "") + ".",
        ]
        if duplicate_sha[row["source_sha256"]] > 1:
            lines.append("- **Shared source:** identical Turtle dialogue also used by "
                         f"{duplicate_sha[row['source_sha256']]-1} other substantial-conflict quests.")
        lines += [
            f"- **Spoken excerpt:** {inline(old_excerpt)}",
            f"- **Turtle excerpt:** {inline(new_excerpt)}",
            "",
        ]
    fieldnames = list(report[0].keys())
    with (args.out / "substantial_35_three_way.csv").open(
            "w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(report)
    summary = {
        "total": len(selected),
        "counts": dict(sorted(counts.items())),
        "source": "original Spoken text, pinned Tortoise SQLite, pinned cMaNGOS Classic",
        "read_only": True,
        "caveat": "Vanilla baseline is another community database; closeness does not prove live correctness.",
    }
    (args.out / "substantial_35_summary.json").write_text(
        json.dumps(summary, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8")
    (args.out / "substantial_35_side_by_side.md").write_text(
        "\n".join(lines), encoding="utf-8")
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
