#!/usr/bin/env python3
"""Extract only quest IDs from pfQuest-turtle's explicit data overrides.

The source is deliberately NOT considered proof of a live quest or of a
dialogue edit; it is Turtle-specific quest metadata corroboration only.
"""
import argparse
import csv
import re
from pathlib import Path

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--input",type=Path,required=True)
    ap.add_argument("--out",type=Path,required=True)
    args=ap.parse_args()
    data=args.input.read_text(encoding="utf-8-sig")
    # pfQuest files assign quest rows at exactly two spaces of indentation;
    # nested start/end/objective entries use greater indentation.
    matches=re.findall(r"(?m)^  \[(\d+)\]\s*=",data)
    ids={int(i) for i in matches}
    print("pfQuest Turtle explicit quest keys:",len(ids),
          "old IDs:",sum(q<20000 for q in ids),
          "first:",sorted(ids)[:15],
          "source beginning:",repr(data[:180]))
    if len(ids)<50:
        raise ValueError("Unexpected pfQuest-turtle quest layout; do not silently ignore source")
    with args.out.open("w",encoding="utf-8",newline="") as f:
        w=csv.writer(f);w.writerow(["quest_id","evidence"])
        for id in sorted(ids):w.writerow([id,"pfquest_turtle_quest_override"])
if __name__=="__main__":main()
