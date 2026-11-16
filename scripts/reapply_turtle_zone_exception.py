#!/usr/bin/env python3
"""Replay ONE independently verified title-aliased Turtle quest classification.

Quest 41797 has a catalog alias "A Good Friend" and source title "A Dear Friend".
The pinned source matches its ID, exact starter/ender IDs and letter objective.
Never classify other title mismatches or developer-only/unspawned quests.
"""
import argparse
import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
CATALOG=ROOT/"SoftSpoken_Stories/Data/Compendium.lua"
APPROVED=ROOT/"docs/audits/turtle_hold_resolution/approved_41797_identity.json"
EXPECTED={
    "quest_id":41797,"catalog_title":"A Good Friend","source_title":"A Dear Friend",
    "source_zone":5581,"starter_id":228,"ender_id":62307
}


def verify_record(p=APPROVED):
    j=json.loads(p.read_text(encoding="utf-8"))
    for k,v in EXPECTED.items():
        if j.get(k)!=v:
            raise ValueError(f"41797 title alias changed: {k}")
    if j.get("decision")!="allow_exact_title_alias_without_renaming_catalog":
        raise ValueError("Quest 41797 alias was not approved")
    if not j.get("stage_hashes",{}).get("accept"):
        raise ValueError("Missing pinned source fingerprint")
    return j


def apply(text):
    match=re.search(r'(?m)^(\s*\[41797\]\s*=\s*\{\s*)"A Good Friend"([^{}\r\n]*)(\},[ \t]*)$',text)
    if not match:
        raise ValueError("Missing or changed quest 41797")
    fields=match[2]
    if not re.search(r'\bstarter\s*=\s*228\b',fields) or not re.search(
            r'\bender\s*=\s*62307\b',fields):
        raise ValueError("Source starter/ender quest identity changed")
    expected="turtleArea = 5581"
    if re.search(r'\b(?:turtleArea|zones|sort)\s*=',fields):
        if re.search(r'\bturtleArea\s*=\s*5581\b',fields):
            return text,False
        raise ValueError("Quest 41797 has conflicting preexisting classification")
    raw=match[0]
    updated=match[1]+'"A Good Friend"'+fields.rstrip()+', '+expected+' '+match[3]
    return text.replace(raw,updated,1),True


def main():
    p=argparse.ArgumentParser(description=__doc__)
    opts=p.add_mutually_exclusive_group(required=True)
    opts.add_argument("--apply",action="store_true")
    opts.add_argument("--check",action="store_true")
    p.add_argument("--catalog",type=Path,default=CATALOG)
    p.add_argument("--approval",type=Path,default=APPROVED)
    a=p.parse_args()
    verify_record(a.approval)
    old=a.catalog.read_text(encoding="utf-8")
    result,changed=apply(old)
    if a.check:
        if changed:raise SystemExit("Quest 41797 is missing Northwind classification")
        print("PASS: 41797 verified title-aliased Northwind classification")
    else:
        if changed:a.catalog.write_text(result,encoding="utf-8")
        print("Applied" if changed else "Preserved","41797 Northwind classification")


if __name__=="__main__":main()
