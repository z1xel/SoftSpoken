#!/usr/bin/env python3
"""Import only the independently corroborated quest-41797 title alias.

The original Compendium title "A Good Friend" remains unchanged. The pinned
Tortoise source calls the same quest "A Dear Friend". Before any dialogue
is appended, validate quest ID, both NPCs, area, objective, and ALL source
stage lengths/SHA-256 digests from an immutable reviewed manifest.

No original SpokenQuestsText entry is touched. All other title mismatches
and seven [DEPRECATED] exclusive quests stay held.
"""
import argparse
import json
import re
import sqlite3
from pathlib import Path

from audit_turtle_hold_resolutions import (
    approved_title_alias, catalog_rows, source_quest, CATALOG, SOURCE_ALIAS,
)
from import_turtle_touched_text import write_atomically
from prepare_tortoise_quest_overlay import lua_quoted

ROOT=Path(__file__).resolve().parents[1]
APPROVED=ROOT/"docs/audits/turtle_hold_resolution/approved_41797_identity.json"
DEST=ROOT/"SoftSpoken_Stories/Data/TurtleQuestText.lua"
BEGIN="-- BEGIN verified Turtle title alias quest 41797"
END="-- END verified Turtle title alias quest 41797"
STAGES={"accept":"details","progress":"requesttext","complete":"offertext"}


def load_verified(db_path,approval_path=APPROVED,catalog_path=CATALOG):
    expected=json.loads(approval_path.read_text(encoding="utf-8"))
    if (expected.get("decision")!="allow_exact_title_alias_without_renaming_catalog" or
            expected.get("quest_id")!=SOURCE_ALIAS):
        raise ValueError("Unapproved 41797 source identity manifest")
    with sqlite3.connect(f"file:{db_path.resolve()}?mode=ro",uri=True) as db:
        actual=approved_title_alias(db,catalog_rows(catalog_path))
        src=source_quest(db,SOURCE_ALIAS)
    if expected!=actual:
        raise ValueError("Quest 41797 identity or pinned stage hash changed")
    texts={stage:src[column] for stage,column in STAGES.items()
           if actual["stage_hashes"][stage]}
    if set(texts)!={"accept","progress","complete"}:
        raise ValueError("Incomplete approved 41797 dialogue")
    return texts


def format_block(texts):
    lines=[
        BEGIN,
        "-- Checked against pinned Tortoise SQLite and independently corroborated NPC/objective identity.",
        "-- Original Spoken text unchanged; only this approved title alias is allowed.",
        "SSCTurtleQuestText[41797] = {",
    ]
    for stage in STAGES:
        lines.append(f"    {stage} = {lua_quoted(texts[stage])},")
    lines += ["}",END]
    return "\n".join(lines)+"\n"


def merge(base,block):
    if base.count(BEGIN)!=base.count(END) or base.count(BEGIN)>1:
        raise ValueError("Malformed 41797 block markers")
    original=base
    if BEGIN in original:
        a=original.index(BEGIN)
        b=original.index(END,a)+len(END)
        if original[b:b+1]=="\n":b+=1
        original=original[:a]+original[b:]
    if "SSCTurtleQuestText" not in original:
        raise ValueError("Missing original Turtle dialogue corpus")
    if re.search(r"(?m)^\s*SSCTurtleQuestText\[\s*41797\s*\]\s*(?:=|\.)",original):
        raise ValueError("A separate 41797 override exists; refusing overwrite")
    return original+("" if original.endswith("\n") else "\n")+block


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--db",type=Path,required=True)
    p.add_argument("--approval",type=Path,default=APPROVED)
    p.add_argument("--destination",type=Path,default=DEST)
    p.add_argument("--write",action="store_true")
    a=p.parse_args()
    if not a.db.is_file():p.error("Pinned Turtle SQLite not available")
    texts=load_verified(a.db,a.approval)
    if a.write:
        if not a.destination.is_file():
            raise ValueError("Existing TurtleQuestText.lua absent; refusing to create a partial corpus")
        previous=a.destination.read_text(encoding="utf-8")
        updated=merge(previous,format_block(texts))
        if updated!=previous:
            write_atomically(a.destination,updated)
        print("Verified title-aliased quest 41797; three stages "+("updated" if updated!=previous else "unchanged"))
    else:
        print("Verified 41797 quest identity and all 3 dialogue stage hashes")


if __name__=="__main__":main()
