#!/usr/bin/env python3
"""Read-only adjudication of zone, shared-ID text and Turtle-exclusive text holds.

Only exact, supported evidence may resolve a hold. In particular:
  * A community DB quest row does not establish live availability.
  * A title variant is not permission to import different quest dialogue.
  * A renamed quest with explicit quest-ID, giver, recipient and objective
    corroboration may be approved as an isolated title alias.
  * Deprecated, test and restricted quests remain held.
"""
import argparse
import collections
import csv
import hashlib
import json
import re
import sqlite3
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/"docs/audits/turtle_hold_resolution"
ZONES=ROOT/"docs/audits/tortoise_zone_overlay/holds.csv"
SHARED=ROOT/"docs/audits/turtle_touched_text_coverage/held_quests.csv"
EXCLUSIVE=ROOT/"docs/audits/tortoise_quest_overlay/summary.json"
CATALOG=ROOT/"SoftSpoken_Stories/Data/Compendium.lua"
SOURCE_ALIAS=41797
ALIASES={
    41797:("A Good Friend","A Dear Friend"),
}
CORE_VARIANT_IDS={
    7795,7800,7805,7811,7813,7818,7823,7824,7833,7836,
    8044,8141,8142,8143,8144,8148,8293
}
REPURPOSE_IDS={5214,5641,5645,5647,8249}


def read_csv(path):
    with path.open(newline="",encoding="utf-8-sig") as stream:
        return list(csv.DictReader(stream))


def write_csv(path,rows):
    with path.open("w",newline="",encoding="utf-8") as stream:
        writer=csv.DictWriter(stream,fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)


def catalog_rows(path):
    data=path.read_text(encoding="utf-8")
    body=data.split("\tquests = {",1)[1].split("\n\t},\n\n\tsorts = {",1)[0]
    out={}
    for m in re.finditer(r'(?m)^\s*\[(\d+)\]\s*=\s*\{\s*("(?:\\.|[^"\\])*")',body):
        qid=int(m[1])
        if qid in out:raise ValueError("Duplicate quest row "+str(qid))
        out[qid]={"title":json.loads(m[2]),"line":m[0]}
    if len(out)!=7246:
        raise ValueError("Unexpected catalog total "+str(len(out)))
    return out


def source_quest(conn,qid):
    cols={r[1].lower():r[1] for r in conn.execute("PRAGMA table_info(quests)")}
    expected=["entry","title","objectives","details","requesttext","offertext","zone","hidden"]
    if not set(expected)<=set(cols):raise ValueError("Source columns missing "+str(set(expected)-set(cols)))
    result=conn.execute(
        "SELECT "+",".join('"'+cols[k]+'"' for k in expected)+
        " FROM quests WHERE "+'"'+cols["entry"]+'"=?',(qid,)).fetchone()
    return dict(zip(expected,result)) if result else None


def ids(conn,table,qid):
    return sorted(int(row[0]) for row in conn.execute("SELECT id FROM "+table+" WHERE quest=?",(qid,)))


def digest(text):
    if not isinstance(text,str) or not text.strip():
        return None
    # pin the exact raw UTF-8 payload; no whitespace normalization guesses
    return {"chars":len(text),"sha256":hashlib.sha256(text.encode("utf-8")).hexdigest()}


def approved_title_alias(conn,catalog):
    row=source_quest(conn,SOURCE_ALIAS)
    if not row:
        raise ValueError("Source quest 41797 missing")
    start=ids(conn,"creature_quest_start",SOURCE_ALIAS)
    end=ids(conn,"creature_quest_end",SOURCE_ALIAS)
    orig=catalog[SOURCE_ALIAS]
    if (orig["title"]!="A Good Friend" or row["title"]!="A Dear Friend" or
        int(row["zone"])!=5581 or start!=[228] or end!=[62307]):
        raise ValueError(
            "Quest 41797 identity changed: "+
            json.dumps({"catalog":orig["title"],"source":row["title"],
                        "zone":row["zone"],"starter":start,"ender":end}))
    content=" ".join((row.get("objectives") or "").split()).casefold()
    if not ("avette" in content and "barbara" in content and "letter" in content):
        raise ValueError("Quest 41797 letter-delivery objective not corroborated")
    hashes={stage:digest(row[col]) for stage,col in (
        ("accept","details"),("progress","requesttext"),("complete","offertext"))}
    if not hashes["accept"] or not hashes["complete"]:
        raise ValueError("Approved alias does not have expected source dialogue")
    return {
        "quest_id":SOURCE_ALIAS,
        "catalog_title":"A Good Friend",
        "source_title":"A Dear Friend",
        "source_zone":5581,
        "region":"Northwind",
        "starter_kind":"NPC","starter_id":228,
        "ender_kind":"NPC","ender_id":62307,
        "objective_tokens_verified":["avette","barbara","letter"],
        "stage_hashes":hashes,
        "evidence_url":"https://octowow.st/db/?quest=41797",
        "decision":"allow_exact_title_alias_without_renaming_catalog",
        "source_version":"Xian55/tortoise-db-viewer 567ce23c73087e9b67fd2d4732c171d751e54bba"
    }


def zone_resolution(row):
    id=int(row["quest_id"])
    reason=row["reason"]
    if id==SOURCE_ALIAS:
        if reason!="title_disagreement" or row["source_area_id"]!="5581":
            raise ValueError("41797 classification source drifted")
        return "approved_title_alias","Use existing named Northwind region 5581"
    if reason=="missing_area_template":
        return "hold_unmapped_area","No matching AreaTable entry; prior ring quests not an authenticated replacement"
    if reason=="reserved_world_area":
        return "hold_restricted_area","GM Island does not prove a public zone or playable quest"
    if reason=="method_not_enabled":
        return "hold_disabled_method","The frozen Method/status rejects normal availability"
    if reason=="zero_area_or_sort":
        return "hold_no_area","An empty area value supplies no valid map or category"
    if reason=="shared_id_not_world_linked":
        return "hold_unproven_availability","Shared-ID record exists; no confirmed spawned quest starter in pinned evidence"
    if reason=="title_disagreement":
        return "hold_source_identity","Source title differs or has a retired/NYI marker"
    raise ValueError("Unexpected zone hold "+str(id)+":"+reason)


def shared_resolution(row):
    id=int(row["quest_id"])
    why=row["eligibility_reason"]
    if why=="absent_cmangos_but_present_vanilla_pfquest":
        if row["vanilla_pfquest_present"]!="1":
            raise ValueError("Not actually present in alternate Vanilla baseline: "+str(id))
        return "resolved_baseline_omission","In Vanilla pfQuest; cMaNGOS omission is not evidence of new Turtle quest"
    if why=="source_catalog_title_disagreement":
        if id in CORE_VARIANT_IDS:
            return "title_variant_identified_text_held","Same-ID title qualifier/spelling; text stage still needs validation"
        if id in REPURPOSE_IDS:
            return "hold_probable_id_repurpose","Source/title/objective differ; cannot map original spoken dialogue blindly"
        return "hold_unclassified_title_collision","No approved title relationship for this ID"
    if why=="method_disabled_or_unverified":
        return "hold_method_unverified","Existing curated quest remains, but Method alone does not establish live availability"
    if why=="legacy_id_missing_spawned_starter":
        return "hold_missing_spawn_evidence","Source quest exists; original unavailable cMaNGOS baseline and missing spawned starter are not conclusive"
    if why=="source_retired_or_placeholder":
        return "hold_retired_or_nyi","Source contains retired or placeholder title marker"
    raise ValueError("Unexpected shared text hold "+str(id)+":"+why)


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--turtle",type=Path,required=True)
    p.add_argument("--out",type=Path,default=OUT)
    a=p.parse_args()
    zones=read_csv(ZONES)
    shared=read_csv(SHARED)
    exclusive=json.loads(EXCLUSIVE.read_text(encoding="utf-8"))
    if len(zones)!=37 or len(shared)!=49 or len(exclusive["held"])!=8:
        raise ValueError(f"Hold baseline changed: zone {len(zones)} shared {len(shared)} exclusive {len(exclusive['held'])}")
    if sorted(exclusive["held"])!=[40128,40129,40132,41098,41100,41103,41105,41797]:
        raise ValueError("Exclusive quest hold roster changed")
    catalog=catalog_rows(CATALOG)
    for r in zones+shared:
        qid=int(r["quest_id"])
        if catalog[qid]["title"]!=r["catalog_title"]:
            raise ValueError("Current Compendium title changed "+str(qid))
    with sqlite3.connect(f"file:{a.turtle.resolve()}?mode=ro",uri=True) as conn:
        alias=approved_title_alias(conn,catalog)
        for zone in zones:
            source=source_quest(conn,int(zone["quest_id"]))
            if not source or source["title"]!=zone["source_title"]:
                raise ValueError("Source title changed for zone hold "+zone["quest_id"])
    zone_rows=[]
    for row in zones:
        status,action=zone_resolution(row)
        zone_rows.append({
            "quest_id":row["quest_id"],"title":row["catalog_title"],
            "cohort":row["cohort"],"old_reason":row["reason"],
            "resolution":status,"action":action})
    shared_rows=[]
    for row in shared:
        status,action=shared_resolution(row)
        shared_rows.append({
            "quest_id":row["quest_id"],"title":row["catalog_title"],
            "source_title":row["turtle_title"],
            "reason":row["eligibility_reason"],
            "resolution":status,"action":action})
    exclusive_rows=[]
    for qid in exclusive["held"]:
        status="approved_title_alias" if qid==SOURCE_ALIAS else "hold_deprecated_source"
        exclusive_rows.append({
            "quest_id":qid,
            "resolution":status,
            "action":("Import only source-fingerprinted dialogue and Northwind classification"
                      if qid==SOURCE_ALIAS else
                      "Preserve current existing quest; do not export deprecated source dialogue")
        })
    a.out.mkdir(parents=True,exist_ok=True)
    write_csv(a.out/"zone_37_resolution.csv",zone_rows)
    write_csv(a.out/"shared_49_resolution.csv",shared_rows)
    write_csv(a.out/"exclusive_8_resolution.csv",exclusive_rows)
    (a.out/"approved_41797_identity.json").write_text(
        json.dumps(alias,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
    summary={
        "original_zone_holds":len(zones),"original_shared_text_holds":len(shared),
        "original_exclusive_text_holds":len(exclusive_rows),
        "zone_dispositions":dict(sorted(collections.Counter(r["resolution"] for r in zone_rows).items())),
        "shared_dispositions":dict(sorted(collections.Counter(r["resolution"] for r in shared_rows).items())),
        "exclusive_dispositions":dict(sorted(collections.Counter(r["resolution"] for r in exclusive_rows).items())),
        "unique_ids_across_all_three":len({int(r["quest_id"]) for r in zones+shared}|set(exclusive["held"])),
        "overlap_zone_and_shared":sorted({int(r["quest_id"]) for r in zones}&{int(r["quest_id"]) for r in shared}),
        "direct_text_import_approved":[41797],
        "direct_zone_classification_approved":[41797],
        "other_quest_text_imports_approved":[],
        "text_files_modified":False,
        "availability_not_inferred_from_source_presence":True
    }
    (a.out/"summary.json").write_text(json.dumps(summary,indent=2)+"\n",encoding="utf-8")
    print(json.dumps(summary,indent=2))


if __name__=="__main__":main()
