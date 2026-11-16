#!/usr/bin/env python3
"""Audit missing Turtle quest speakers and all multi-speaker assignments.

The original pfQuest-derived speaker manifest is only one source. Compare
typed start/end relationships, item starters and spawn observations from the
pinned Tortoise SQLite to the actual Compendium row. Do not automatically
infer a speaker from the preceding or following quest.
Voice-pack metadata checks are deliberately distinguished from audio proof.
No addon gameplay file is altered by this audit.
"""
import argparse
import collections
import csv
import json
import re
import sqlite3
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/"docs/audits/turtle_speaker_exceptions"
MANIFEST=ROOT/"docs/turtle_exclusive_import.csv"
CORPUS=ROOT/"SoftSpoken_Stories/Data/Compendium.lua"
FALLBACK=ROOT/"Data_Packs/SSS_VOFallback/sources"
FIELDS=["quest_id","quest_title","missing_in_manifest","missing_in_compendium",
        "manifest_starters","manifest_enders","compendium_starters","compendium_enders",
        "source_starters","source_enders","source_starter_spawned","source_ender_spawned",
        "source_prevquest","source_nextquest","source_hidden","start_script","complete_script",
        "starter_status","ender_status","next_action"]
MULTI_FIELDS=["quest_id","quest_title","manifest_starters","manifest_enders",
              "compendium_accept_candidates","compendium_progress_complete_candidates",
              "starter_status","ender_status","faction_specific","fallback_npc_lookup",
              "voice_verification"]


def table_rows(path):
    with path.open(newline="",encoding="utf-8-sig") as stream:
        return list(csv.DictReader(stream))


def id_set(s):
    return {int(k) for k in re.findall(r"\d+",s or "")}


def combined_ids(row,kind):
    return {("U",v) for v in id_set(row[f"{kind}_U"])}|{
        ("O",v) for v in id_set(row[f"{kind}_O"])}|{
        ("I",v) for v in id_set(row[f"{kind}_I"])}


def catalog_rows(path):
    text=path.read_text(encoding="utf-8")
    # Scope the parser to the quest body. Other Compendium sections such
    # as sorting/category maps also use numeric Lua table keys.
    text=text.split("\tquests = {",1)[1].split("\n\t},\n\n\tsorts = {",1)[0]
    rows={}
    # The generated Compendium stores exactly one quest per line. Do not
    # execute Lua or guess parser values from other nested tables.
    pattern=r'(?m)^\s*\[(\d+)\]\s*=\s*\{\s*"(?:\\.|[^"\\])*"\s*(?:,.*)?\},\s*$'
    for m in re.finditer(pattern,text):
        qid=int(m[1])
        if qid in rows:
            raise ValueError(f"Duplicate Compendium quest: {qid}")
        rows[qid]=m[0]
    if len(rows)<7000:
        raise ValueError(f"Compendium parser found only {len(rows)} quest rows")
    return rows


def corpus_speaker_ids(line,which):
    keys=(("starter","starters","starterObject","starterItem",
           "starterAlliance","starterHorde") if which=="starter" else
          ("ender","enders","enderObject","enderObjects"))
    result=set()
    for key in keys:
        for m in re.finditer(r"\b"+key+r"\s*=\s*(\{[^}]*\}|\d+)",line):
            typ=("O" if "Object" in key else "I" if "Item" in key else "U")
            result|={(typ,x) for x in id_set(m[1])}
    return result


def plural(line,kind):
    names=("starters",) if kind=="starter" else ("enders","enderObjects")
    return any(len(id_set(m[1]))>1 for name in names for m in re.finditer(
        r"\b"+name+r"\s*=\s*\{([^}]*)\}",line))


def faction_specific(line):
    return bool(re.search(r"\bstarterAlliance\s*=\s*\d+",line) and
                re.search(r"\bstarterHorde\s*=\s*\d+",line))


def source_links(db,table,qids):
    result=collections.defaultdict(set)
    for qid,entity in db.execute(f"SELECT quest,id FROM {table}"):
        if int(qid) in qids:
            result[int(qid)].add(int(entity))
    return result


def source_data(db,qids):
    links={}
    for side in ("start","end"):
        for kind,table in (("U","creature"),("O","gameobject")):
            links[(side,kind)]=source_links(db,f"{table}_quest_{side}",qids)
    items=collections.defaultdict(set)
    for item,qid in db.execute("SELECT entry,start_quest FROM items WHERE start_quest>0"):
        if qid in qids:items[int(qid)].add(int(item))
    links[("start","I")]=items
    spawns={int(x[0]) for x in db.execute("SELECT DISTINCT id FROM spawns")}
    objects={int(x[0]) for x in db.execute("SELECT DISTINCT id FROM spawn_points WHERE kind='o'")}
    qcols={row[1].lower():row[1] for row in db.execute("PRAGMA table_info(quests)")}
    optional=[name for name in ("startscript","completescript") if name in qcols]
    cols=["entry","title","hidden","prevquest","nextquest"]+optional
    quest={}
    for raw in db.execute("SELECT "+",".join('"'+qcols[c]+'"' for c in cols)+" FROM quests"):
        item=dict(zip(cols,raw))
        if item["entry"] in qids:quest[int(item["entry"])]=item
    return links,spawns,objects,quest


def src_ids(links,qid,side):
    return {(kind,x) for kind in ("U","O","I")
            for x in links.get((side,kind),{}).get(qid,set())}


def serialize(ids):
    return ";".join(f"{kind}:{id}" for kind,id in sorted(ids))


def status(original,actual,source,other,metadata):
    """Do not present an absent community DB link as proof of hidden behavior."""
    if original:
        return "present"
    if actual:
        return "manifest_only_gap"
    if source:
        return "recoverable_source_relationship"
    if metadata.get("script"):
        return "script_candidate_unverified"
    if metadata.get("prev") or metadata.get("next"):
        return "chain_without_typed_relationship"
    return "unresolved_no_typed_source_link"


def choose_action(s,e):
    if "recoverable_source_relationship" in (s,e):
        return "Verify the typed source ID, spawn and quest context; then add only that role"
    if s=="manifest_only_gap" or e=="manifest_only_gap":
        return "Correct the source manifest audit; Compendium already has an explicit role"
    if s=="script_candidate_unverified" or e=="script_candidate_unverified":
        return "Inspect scripted interaction or live quest dialog; do not invent static speaker"
    if s=="chain_without_typed_relationship" or e=="chain_without_typed_relationship":
        return "Check the actual previous/next quest turn-in NPC; chain alone is not evidence"
    return "Unresolved: inspect live interaction or more independent source records"


def fallback_metadata_ids(root):
    ids=set()
    for path in sorted(root.glob("*/generated/questlog_*_lookups.lua")):
        raw=path.read_text(encoding="utf-8")
        ids|={int(x) for x in re.findall(r"(?m)^\s*\[(\d+)\]\s*=",raw)}
    return ids


def audit(db_path,manifest_path=MANIFEST,corpus_path=CORPUS,
          fallback_path=FALLBACK):
    original=table_rows(manifest_path)
    selected=[x for x in original if x["status"] in ("imported","already_present")]
    if len(selected)!=2377:raise ValueError(f"Expected 2377 retained quest IDs, found {len(selected)}")
    parsed=catalog_rows(corpus_path)
    ids={int(x["quest_id"]) for x in selected}
    if not ids.issubset(parsed):
        raise ValueError(f"Missing Compendium quest IDs: {sorted(ids-set(parsed))[:10]}")
    candidates=[x for x in selected if not combined_ids(x,"starter")
                or not combined_ids(x,"ender")]
    if len(candidates)!=36:
        raise ValueError(f"Expected 36 missing-side quest candidates, found {len(candidates)}")
    with sqlite3.connect(f"file:{db_path.resolve()}?mode=ro",uri=True) as db:
        links,spawns,objects,quests=source_data(db,ids)
    source_count=collections.Counter()
    statuses=collections.Counter()
    detailed=[]
    for row in candidates:
        qid=int(row["quest_id"])
        line=parsed[qid]
        m={side:combined_ids(row,side) for side in ("starter","ender")}
        c={side:corpus_speaker_ids(line,side) for side in ("starter","ender")}
        t={"starter":src_ids(links,qid,"start"),"ender":src_ids(links,qid,"end")}
        q=quests.get(qid,{})
        data={}
        for side in ("starter","ender"):
            proof={"prev":q.get("prevquest"),"next":q.get("nextquest"),
                   "script":q.get("startscript" if side=="starter" else "completescript")}
            data[side]=status(m[side],c[side],t[side],None,proof)
            statuses[side+"_"+data[side]]+=1
        if not q:source_count["quest_absent_from_source"]+=1
        def spawned(links):
            return {(kind,id) for kind,id in links
                    if (kind=="U" and id in spawns)
                    or (kind=="O" and id in objects)}
        detailed.append({
            "quest_id":qid,"quest_title":row["title"],
            "missing_in_manifest":";".join(side for side in ("starter","ender") if not m[side]),
            "missing_in_compendium":";".join(side for side in ("starter","ender") if not c[side]),
            "manifest_starters":serialize(m["starter"]),
            "manifest_enders":serialize(m["ender"]),
            "compendium_starters":serialize(c["starter"]),
            "compendium_enders":serialize(c["ender"]),
            "source_starters":serialize(t["starter"]),
            "source_enders":serialize(t["ender"]),
            "source_starter_spawned":serialize(spawned(t["starter"])),
            "source_ender_spawned":serialize(spawned(t["ender"])),
            "source_prevquest":q.get("prevquest",""),"source_nextquest":q.get("nextquest",""),
            "source_hidden":q.get("hidden",""),
            "start_script":q.get("startscript",""),
            "complete_script":q.get("completescript",""),
            "starter_status":data["starter"],"ender_status":data["ender"],
            "next_action":choose_action(data["starter"],data["ender"]),
        })
    # Verify not only the initially "missing" quests: every actual plural
    # source candidate must be represented, and factional variants must not
    # be mistaken for one ambiguous speaker.
    fallback=fallback_metadata_ids(fallback_path)
    multi=[]
    for row in selected:
        qid=int(row["quest_id"])
        m={side:combined_ids(row,side) for side in ("starter","ender")}
        if max(len(m["starter"]),len(m["ender"]))<2:continue
        line=parsed[qid]
        c={side:corpus_speaker_ids(line,side) for side in ("starter","ender")}
        faction=faction_specific(line)
        starter_ok=(m["starter"]==c["starter"])
        ender_ok=(m["ender"]==c["ender"])
        # A faction-specific pair has a unique NPC once player faction is known.
        accept_plural=plural(line,"starter")
        end_plural=plural(line,"ender")
        multi.append({
            "quest_id":qid,"quest_title":row["title"],
            "manifest_starters":serialize(m["starter"]),
            "manifest_enders":serialize(m["ender"]),
            "compendium_accept_candidates":serialize(c["starter"]),
            "compendium_progress_complete_candidates":serialize(c["ender"]),
            "starter_status":"matched" if starter_ok else "candidate_set_differs",
            "ender_status":"matched" if ender_ok else "candidate_set_differs",
            "faction_specific":int(faction),
            "fallback_npc_lookup":int(qid in fallback),
            "voice_verification":("Needs actual installed pack and/or live NPC; "
                                  "Compendium has no interacting GUID"
                                  if (accept_plural or end_plural) else
                                  "Single faction speaker in player context; "
                                  "recordings still unverified"),
        })
    summary={
        "scope":"2,377 retained high-ID Turtle quests; both directions and typed entities",
        "missing_starter_manifest":sum("starter" in r["missing_in_manifest"] for r in detailed),
        "missing_ender_manifest":sum("ender" in r["missing_in_manifest"] for r in detailed),
        "quests_with_at_least_one_missing_side":len(detailed),
        "status_counts":dict(sorted(statuses.items())),
        "source_quest_rows_missing":source_count["quest_absent_from_source"],
        "multiple_speaker_manifest_quests":len(multi),
        "multiple_manifest_vs_compendium_differences":sum(
            r["starter_status"]!="matched" or r["ender_status"]!="matched" for r in multi),
        "faction_specific_multi_quests":sum(int(r["faction_specific"]) for r in multi),
        "multiple_manifest_quests_in_bundled_fallback_lookup":sum(
            int(r["fallback_npc_lookup"]) for r in multi),
        "voice_files_verified":0,
        "voice_limitation":"Actual installed quest voice packs, file paths and live speaker GUIDs are not present. Metadata or a file named questID-stage is not proof it is spoken by the correct NPC.",
        "read_only":True
    }
    return detailed,multi,summary


def emit(rows,cols,path):
    path.parent.mkdir(parents=True,exist_ok=True)
    with path.open("w",encoding="utf-8",newline="") as stream:
        writer=csv.DictWriter(stream,fieldnames=cols)
        writer.writeheader()
        writer.writerows(rows)


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--db",type=Path,required=True)
    p.add_argument("--manifest",type=Path,default=MANIFEST)
    p.add_argument("--catalog",type=Path,default=CORPUS)
    p.add_argument("--fallback",type=Path,default=FALLBACK)
    p.add_argument("--out",type=Path,default=OUT)
    a=p.parse_args()
    if not a.db.is_file():p.error("Pinned Tortoise SQLite missing")
    rows,multi,summary=audit(a.db,a.manifest,a.catalog,a.fallback)
    emit(rows,FIELDS,a.out/"missing_36_source_review.csv")
    emit(multi,MULTI_FIELDS,a.out/"multiple_speaker_review.csv")
    (a.out/"summary.json").write_text(
        json.dumps(summary,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
    print(json.dumps(summary,indent=2,ensure_ascii=False))


if __name__=="__main__":
    main()
