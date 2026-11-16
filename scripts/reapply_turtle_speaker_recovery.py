#!/usr/bin/env python3
"""Idempotent, stage-specific replay of 20 source-backed Turtle NPC roles.

The original pfQuest/Turtle import remains immutable. A separately reviewed
manifest adds ONLY NPC starter/ender fields missing in that original import,
when both the Tortoise quest relationship and NPC spawn corroborate the ID.
Never copy speaker IDs from adjacent quest stages or invent object spawns.
"""
import argparse
import csv
import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
CATALOG=ROOT/"SoftSpoken_Stories/Data/Compendium.lua"
MANIFEST=ROOT/"docs/turtle_speaker_recovery.csv"
EXCLUSIVE=ROOT/"docs/turtle_exclusive_import.csv"
NAMES=ROOT/"docs/turtle_speaker_recovery_names.csv"
APPROVED_NAMES={6868:"Jarkal Mossmeld",62986:"Ar'lia",62850:"Moro'gai K'la"}
EXPECTED_IDS={41734,41908,41909,41912,41913,41914,41915,41916,41917,41922,80381}
REGEX=re.compile(r'(?m)^(\s*\[(\d+)\]\s*=\s*\{)([^\r\n]*)(\},[ \t]*$)')
TITLE=re.compile(r'^\s*("(?:\\.|[^"\\])*")')
FIELDS={
    "starter":("starter","starters","starterAlliance","starterHorde","starterObject","starterItem"),
    "ender":("ender","enders","enderObject","enderObjects"),
}


def records(path):
    with path.open(newline="",encoding="utf-8") as stream:
        return list(csv.DictReader(stream))


def load_manifest(path=MANIFEST,exclusive=EXCLUSIVE):
    original={int(row["quest_id"]):row for row in records(exclusive)
              if row["status"] in ("imported","already_present")}
    rows=records(path)
    if len(rows)!=20:
        raise ValueError(f"Expected 20 approved NPC speaker roles, got {len(rows)}")
    selected={}
    for row in rows:
        qid=int(row["quest_id"])
        role=row["field"]
        id=int(row["entity_id"])
        base=original.get(qid)
        if (qid not in EXPECTED_IDS or not base or
                base["title"]!=row["catalog_title"] or
                role not in FIELDS or id<=0 or
                row["source_key"]!="pinned_tortoise_typed_relation_and_npc_spawn"):
            raise ValueError(f"Unapproved NPC recovery record: {qid} {role}")
        if any(base[f"{role}_{t}"] for t in ("U","O","I")):
            raise ValueError(f"Original corpus already has {role} for {qid}")
        record=selected.setdefault(qid,{"title":row["catalog_title"]})
        if role in record:raise ValueError(f"Duplicate recovery role: {qid} {role}")
        record[role]=id
    if set(selected)!=EXPECTED_IDS:raise ValueError("Approved NPC recovery IDs drifted")
    return selected


def amend(line,rec,qid):
    m=REGEX.match(line)
    if not m:raise ValueError(f"Malformed generated quest row {qid}")
    body=m[3]
    title=TITLE.match(body)
    if not title or json.loads(title[1])!=rec["title"]:
        raise ValueError(f"Compendium title changed for {qid}")
    to_insert=[]
    for role in ("starter","ender"):
        wanted=rec.get(role)
        if not wanted:continue
        existing=[]
        for name in FIELDS[role]:
            existing += [(name,code) for code in re.findall(
                r"\b"+name+r"\s*=\s*(\d+|\{[^}]*\})",body)]
        if existing:
            if existing==[(role,str(wanted))]:
                continue
            raise ValueError(f"Preexisting conflicting {role} for {qid}: {existing}")
        to_insert.append(role+" = "+str(wanted))
    if not to_insert:return line
    # Keep zone/category classification LAST, preserving upstream and zone
    # overlay's exact last-field contract and idempotent regeneration tests.
    positions=[body.rfind(", "+name+" =") for name in ("zones","sort","turtleArea")]
    last=max(positions)
    addition=", "+", ".join(to_insert)
    if last>=0:
        updated=body[:last].rstrip()+addition+body[last:]
    else:
        updated=body.rstrip()+addition+" "
    return m[1]+updated+m[4]


def apply_names(text,path=NAMES):
    entries=records(path)
    if len(entries)!=3 or {int(r["id"]) for r in entries}!=set(APPROVED_NAMES):
        raise ValueError("Exact speaker name fallback approval set changed")
    for entry in entries:
        qid=int(entry["id"])
        if (entry["kind"]!="U" or entry["name"]!=APPROVED_NAMES[qid] or
                not entry["source_url"].startswith("https://")):
            raise ValueError("Invalid approved speaker name: "+str(qid))
    opening="\tnpcNames = {\n"
    first=text.index(opening)+len(opening)
    last=text.index("\n\t},",first)
    body=text[first:last]
    inserted=[]
    for qid,name in sorted(APPROVED_NAMES.items()):
        pattern=r"(?m)^\s*\["+str(qid)+r"\]\s*=\s*(\"(?:\\.|[^\"\\])*\")\s*,"
        match=re.search(pattern,body)
        if match:
            if json.loads(match[1])!=name:
                raise ValueError("Conflicting NPC name for "+str(qid))
            continue
        inserted.append(f"\t\t[{qid}] = {json.dumps(name,ensure_ascii=False)},\n")
    if not inserted:return text,0
    return text[:first]+"".join(inserted)+text[first:],len(inserted)


def apply(text,rows):
    opening,closing="\n\tquests = {","\n\t},\n\n\tsorts = {"
    a=text.index(opening)+len(opening)
    b=text.index(closing,a)
    body=text[a:b]
    found=set()
    changes=0
    output=[]
    for line in body.splitlines(keepends=True):
        m=REGEX.match(line.rstrip("\r\n"))
        if not m or int(m[2]) not in rows:
            output.append(line)
            continue
        qid=int(m[2])
        if qid in found:raise ValueError(f"Duplicate quest {qid}")
        found.add(qid)
        update=amend(line.rstrip("\r\n"),rows[qid],qid)
        output.append(update+line[len(line.rstrip("\r\n")):])
        changes+=int(update!=line.rstrip("\r\n"))
    if found!=set(rows):
        raise ValueError(f"Quest records absent: {sorted(set(rows)-found)}")
    return text[:a]+"".join(output)+text[b:],changes


def main():
    p=argparse.ArgumentParser(description=__doc__)
    choose=p.add_mutually_exclusive_group(required=True)
    choose.add_argument("--apply",action="store_true")
    choose.add_argument("--check",action="store_true")
    p.add_argument("--catalog",type=Path,default=CATALOG)
    p.add_argument("--manifest",type=Path,default=MANIFEST)
    p.add_argument("--names",type=Path,default=NAMES)
    a=p.parse_args()
    selected=load_manifest(a.manifest)
    old=a.catalog.read_text(encoding="utf-8")
    new,changes=apply(old,selected)
    new,name_changes=apply_names(new,a.names)
    if a.check:
        if old!=new:raise SystemExit(f"{changes} source-backed NPC quest rows and {name_changes} names missing")
        print("PASS: 20 source-backed Turtle NPC roles and 3 verified NPC names intact")
    elif old!=new:
        a.catalog.write_text(new,encoding="utf-8")
        print(f"Recovered NPC speaker fields in {changes} Turtle quest rows and {name_changes} names")
    else:
        print("No missing NPC speaker fields or names")


if __name__=="__main__":main()
