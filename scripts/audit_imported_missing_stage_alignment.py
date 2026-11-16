#!/usr/bin/env python3
"""Read-only cross-stage sanity check for 207 already-imported quest stages.

A pinned Turtle source text may be in the *wrong* quest stage even when its
hash matches the import manifest. Compare all imported stages with their
corresponding and alternative Vanilla source stages, and with original Spoken.
Export only classifications, IDs and similarities; never modify dialogue.
"""
import argparse
import collections
import csv
import difflib
import json
from pathlib import Path

import audit_turtle_touched_text as audit

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/"docs/audits/turtle_touched_text_coverage"
FIELDNAMES=("quest_id catalog_title stage source_sha256 vanilla_same_similarity "
            "vanilla_best_other_stage vanilla_best_other_similarity "
            "spoken_same_quest_other_stage spoken_other_similarity classification").split()


def similarity(a,b):
    a,b=audit.content(a),audit.content(b)
    if not a or not b:return 0
    return round(difflib.SequenceMatcher(None,a,b,autojunk=False).ratio(),4)


def category(same,other,spoken):
    # Prefer an exact competing-stage match even when a different community
    # database also has an independently edited same-stage variant.
    if (other>=0.92 and other-same>=0.15) or (spoken>=0.92 and spoken-same>=0.15):
        return "likely_wrong_stage"
    if same>=0.92:
        return "strong_same_stage_match"
    if other > same + 0.12 and other >= 0.7:
        return "investigate_other_stage"
    if same>=0.7:
        return "modified_same_stage_candidate"
    return "uncorroborated_stage_text"


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--turtle",type=Path,required=True)
    parser.add_argument("--vanilla",type=Path,required=True)
    parser.add_argument("--lua-stages",type=Path,required=True)
    parser.add_argument("--manifest",type=Path,
                        default=OUT/"missing_207_verified_stages.csv")
    parser.add_argument("--out",type=Path,default=OUT)
    args=parser.parse_args()
    with args.manifest.open(newline="",encoding="utf-8") as fh:
        manifest=list(csv.DictReader(fh))
    if len(manifest)!=207:
        raise ValueError("Expected exactly 207 imported stage candidates")
    with __import__("sqlite3").connect(f"file:{args.turtle.resolve()}?mode=ro",uri=True) as db:
        source=audit.get_turtle(db)
    with __import__("sqlite3").connect(f"file:{args.vanilla.resolve()}?mode=ro",uri=True) as db:
        vanilla=audit.get_vanilla(db)
    spoken=audit.get_static(args.lua_stages)
    rows=[];stats=collections.Counter()
    for item in manifest:
        qid=int(item["quest_id"])
        stage=item["stage"]
        col= audit.STAGES[stage][0]
        txt=source[qid][col]
        if audit.sha(audit.content(txt)) != item["source_sha256"]:
            raise ValueError(f"Source changed for quest {qid}/{stage}")
        base=vanilla.get(qid)
        if base is None:
            raise ValueError(f"Vanilla reference missing for quest {qid}")
        same=similarity(txt,base[audit.STAGES[stage][1].lower()])
        alternatives=[
            (other,similarity(txt,base[van_col.lower()]))
            for other,(_,van_col) in audit.STAGES.items() if other!=stage]
        best_alt=max(alternatives,key=lambda x:x[1])
        other_spoken=[
            (other,similarity(txt,spoken.get((qid,"spoken"),{}).get(other)))
            for other in audit.STAGES if other!=stage]
        best_spoken=max(other_spoken,key=lambda x:x[1])
        cls=category(same,best_alt[1],best_spoken[1])
        stats[cls]+=1
        rows.append({
            "quest_id":qid,"catalog_title":item["catalog_title"],"stage":stage,
            "source_sha256":item["source_sha256"],
            "vanilla_same_similarity":same,
            "vanilla_best_other_stage":best_alt[0],
            "vanilla_best_other_similarity":best_alt[1],
            "spoken_same_quest_other_stage":best_spoken[0],
            "spoken_other_similarity":best_spoken[1],
            "classification":cls
        })
    args.out.mkdir(parents=True,exist_ok=True)
    with (args.out/"imported_207_stage_alignment.csv").open(
            "w",newline="",encoding="utf-8") as fh:
        writer=csv.DictWriter(fh,fieldnames=FIELDNAMES)
        writer.writeheader();writer.writerows(rows)
    suspicious=[dict(quest_id=r["quest_id"],title=r["catalog_title"],stage=r["stage"],
                     category=r["classification"],
                     same=r["vanilla_same_similarity"],
                     other=r["vanilla_best_other_similarity"],
                     alternate_stage=r["vanilla_best_other_stage"])
                for r in rows if r["classification"] in
                {"likely_wrong_stage","investigate_other_stage","uncorroborated_stage_text"}]
    summary={
        "audited_imported_stages":len(rows),
        "classifications":dict(sorted(stats.items())),
        "flagged_for_review":suspicious,
        "read_only":True,
        "note":"Comparison to independent community Vanilla baseline is a diagnostic, not proof of live Turtle stage behavior."
    }
    (args.out/"imported_207_stage_alignment_summary.json").write_text(
        json.dumps(summary,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
    print(json.dumps(summary,indent=2,ensure_ascii=False))


if __name__=="__main__":
    main()
