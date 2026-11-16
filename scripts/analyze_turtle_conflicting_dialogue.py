#!/usr/bin/env python3
"""Read-only comparison of the 289 migration-backed Spoken/Turtle text conflicts.

Only metrics and brief excerpts are written. Never edits quest dialogue.
"""
import argparse
import collections
import csv
import difflib
import json
import re
import sqlite3
import unicodedata
from pathlib import Path
import audit_turtle_touched_text as audit

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "docs/audits/turtle_touched_text_coverage"
FIELDS = ("quest_id catalog_title stage similarity edit_category "
          "spoken_chars turtle_chars length_delta variable_tokens_changed "
          "spoken_tokens turtle_tokens changed_word_count source_sha256").split()
EXAMPLES = [(6071, "complete"), (194, "complete"), (3914, "complete"),
            (129, "accept"), (3801, "accept"), (3802, "accept"),
            (32, "complete"), (53, "complete"), (98, "complete"),
            (100, "complete"), (1794, "complete"), (3116, "complete"),
            (5215, "complete"), (9322, "accept"), (8419, "complete")]


def words(s):
    return re.findall(r"\S+", s)


def variables(s):
    return sorted(re.findall(r"\$[A-Za-z][A-Za-z0-9]*", s, re.I))


def words_without_punctuation(s):
    return re.findall(r"[\w]+", unicodedata.normalize("NFKC", s).casefold())


def compare_text(spoken, turtle):
    a = audit.content(spoken)
    b = audit.content(turtle)
    if not a or not b or a == b:
        raise ValueError("A conflict must contain two different nonempty text stages")
    similarity = difflib.SequenceMatcher(None, a, b, autojunk=False).ratio()
    if words_without_punctuation(a) == words_without_punctuation(b):
        kind = "punctuation_or_whitespace"
    elif similarity >= 0.92:
        kind = "minor_wording"
    elif similarity >= 0.7:
        kind = "moderate_wording"
    else:
        kind = "substantial_difference"
    a_words, b_words = words(a), words(b)
    matcher = difflib.SequenceMatcher(None, a_words, b_words, autojunk=False)
    changed = sum(max(i2-i1, j2-j1) for op,i1,i2,j1,j2 in matcher.get_opcodes()
                  if op != "equal")
    return {
        "similarity": round(similarity, 4),
        "edit_category": kind,
        "spoken_chars": len(a),
        "turtle_chars": len(b),
        "length_delta": len(b) - len(a),
        "variable_tokens_changed": int(variables(a) != variables(b)),
        "spoken_tokens": ";".join(variables(a)),
        "turtle_tokens": ";".join(variables(b)),
        "changed_word_count": changed,
    }


def first_changed_excerpt(a, b, limit=130):
    wa, wb = words(a), words(b)
    for tag, i1, i2, j1, j2 in difflib.SequenceMatcher(
            None, wa, wb, autojunk=False).get_opcodes():
        if tag == "equal":
            continue
        before = " ".join(wa[max(0, i1 - 3):min(len(wa), i2 + 3)])
        after = " ".join(wb[max(0, j1 - 3):min(len(wb), j2 + 3)])
        return before[:limit], after[:limit]
    return a[:limit], b[:limit]


def inline(value):
    return str(value).replace("|", r"\|").replace("\n", " ").replace(chr(96), "'")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--turtle", type=Path, required=True)
    ap.add_argument("--lua-stages", type=Path, required=True)
    ap.add_argument("--manifest", type=Path,
                    default=OUTPUT / "directly_supported_text_gaps.csv")
    ap.add_argument("--out", type=Path, default=OUTPUT)
    args = ap.parse_args()
    with args.manifest.open(newline="", encoding="utf-8") as stream:
        manifest = list(csv.DictReader(stream))
    eligible = {(int(x["quest_id"]), x["stage"]): x for x in manifest
                if x["coverage"] == "spoken_outdated_for_turtle"
                and x["source_migration_modified_stage"] == "1"}
    if len(eligible) != 289 or len(manifest) != 289:
        raise ValueError(f"Expected 289 directly supported text conflicts: got {len(eligible)}")
    static = audit.get_static(args.lua_stages)
    with sqlite3.connect(
            f"file:{args.turtle.resolve().as_posix()}?mode=ro", uri=True) as con:
        source = audit.get_turtle(con)
    review, full = [], {}
    for (qid, stage), candidate in sorted(eligible.items()):
        original = static.get((qid, "spoken"), {}).get(stage)
        override = static.get((qid, "turtle"), {}).get(stage)
        data = source.get(qid)
        if data is None:
            raise ValueError(f"Missing Turtle quest {qid}")
        raw = data[audit.STAGES[stage][0]]
        if (not isinstance(original, str) or not original.strip()
                or not isinstance(raw, str) or not raw.strip()):
            raise ValueError(f"Missing one side of quest {qid} {stage}")
        if isinstance(override, str) and override.strip():
            raise ValueError(f"Existing Turtle stage must not be a conflict: {qid} {stage}")
        if audit.titlekey(data["title"]) != audit.titlekey(candidate["catalog_title"]):
            raise ValueError(f"Title mismatch for quest {qid}")
        if audit.sha(audit.content(raw)) != candidate["source_sha256"]:
            raise ValueError(f"Pinned source hash mismatch for quest {qid} {stage}")
        metrics = compare_text(original, raw)
        review.append({
            "quest_id": qid, "catalog_title": candidate["catalog_title"],
            "stage": stage, **metrics,
            "source_sha256": candidate["source_sha256"],
        })
        full[(qid, stage)] = (audit.content(original), audit.content(raw))

    args.out.mkdir(parents=True, exist_ok=True)
    with (args.out / "conflict_review.csv").open(
            "w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(review)
    kinds = collections.Counter(x["edit_category"] for x in review)
    token_count = sum(x["variable_tokens_changed"] for x in review)
    by_stage = collections.Counter(x["stage"] for x in review)
    summary = {
        "total_conflicts": len(review),
        "by_stage": dict(sorted(by_stage.items())),
        "edit_categories": dict(sorted(kinds.items())),
        "changed_quest_placeholder_tokens": token_count,
        "comparison_source": "Pinned Tortoise SQLite versus original Spoken Lua corpus",
        "classification": "Character similarity and punctuation screening, not proof of Turtle authorship",
        "dialogue_overwritten": False,
    }
    (args.out / "conflict_review_summary.json").write_text(
        json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    ordered = sorted(review, key=lambda x: float(x["similarity"]))
    sample_ids = set(EXAMPLES)
    for kind in ("punctuation_or_whitespace", "minor_wording",
                 "moderate_wording", "substantial_difference"):
        subset = [r for r in ordered if r["edit_category"] == kind]
        if subset:
            sample_ids.add((int(subset[0]["quest_id"]), subset[0]["stage"]))
            sample_ids.add((int(subset[len(subset)//2]["quest_id"]),
                            subset[len(subset)//2]["stage"]))
    lines = [
        "# Representative Turtle vs original Spoken quest text differences",
        "",
        "Read-only snapshots of a pinned community source; these are not confirmed live edits.",
        "",
        "| Measure | Count |", "| --- | ---: |",
        *[f"| {kind.replace('_', ' ').capitalize()} | {count} |"
          for kind, count in sorted(kinds.items())],
        f"| Changed WoW placeholder token sequences | {token_count} |",
        "",
        "Each pair below shows only the first changed passage with short surrounding context.",
        "It is deliberately not a complete-text import manifest.",
        "",
        "| Quest / stage | Similarity | Original Spoken excerpt | Turtle source excerpt |",
        "| --- | ---: | --- | --- |",
    ]
    for row in review:
        key = (int(row["quest_id"]), row["stage"])
        if key not in sample_ids:
            continue
        a, b = full[key]
        old, new = first_changed_excerpt(a, b)
        lines.append(
            f"| {row['quest_id']} {inline(row['catalog_title'])} / {row['stage']} "
            f"| {float(row['similarity']):.2f} "
            f"| {inline(old)} | {inline(new)} |")
    lines += ["", "**Interpretation:** Low character similarity can indicate a "
              "substantive change, a longer/shorter transcript, a placeholder "
              "difference or an unrelated database variant. Inspect the full "
              "source dialogue and its migration before overriding Spoken.", ""]
    (args.out / "conflict_review_examples.md").write_text(
        "\n".join(lines), encoding="utf-8")
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
