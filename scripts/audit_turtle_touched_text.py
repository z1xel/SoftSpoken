#!/usr/bin/env python3
"""Read-only *Turtle-touched* quest text audit against an independent Vanilla 1.12 DB.

A difference against cMaNGOS is a *candidate*, not proof that Turtle's live
server deliberately edited Blizzard's text. Never change either Lua corpus.
"""
import argparse
import collections
import csv
import hashlib
import json
import re
import sqlite3
import unicodedata
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
STAGES={"accept":("details","Details"),"progress":("requesttext","RequestItemsText"),
        "complete":("offertext","OfferRewardText")}
COLUMNS=("quest_id catalog_title turtle_title vanilla_title turtle_method "
         "category source_status baseline_status title_different objective_different "
         "changed_stages stage_differences world_evidence curated_status "
         "turtle_starter_spawns source_title_agrees_catalog eligibility_reason "
         "vanilla_quest_present source_zone baseline_zone turtle_evidence provenance_class").split()
STAGE_COLUMNS=("quest_id catalog_title category stage source_present baseline_present "
               "source_diff_baseline source_chars source_sha256 spoken_present "
               "spoken_matches_turtle turtle_overlay_present turtle_overlay_matches_turtle "
               "coverage resolution source_migration_modified_stage turtle_evidence provenance_class").split()
PHRASES=("deprecated","cancelled","canceled","disabled","dummy","<nyi>","<test>","<unused>")
def norm(v):
    v=unicodedata.normalize("NFKC",(v or "")).replace("\u2019","'").replace("\u2018","'").replace("\u201c",'"').replace("\u201d",'"')
    return " ".join(v.replace("\r\n","\n").replace("\r","\n").split())
def titlekey(v): return norm(v).casefold()
def content(v):
    s=norm(v)
    return s if s else ""
def sha(s):return hashlib.sha256(s.encode("utf-8")).hexdigest() if s else ""
def records(p):
    with p.open(encoding="utf-8-sig",newline="") as f:return list(csv.DictReader(f))
def catalog(p):
    data=p.read_text(encoding="utf-8")
    body=data.split("\tquests = {",1)[1].split("\n\t},\n\n\tsorts = {",1)[0]
    out={}
    for m in re.finditer(r'^\s*\[(\d+)\]\s*=\s*\{\s*("(?:\\.|[^"\\])*")',body,re.M):
        qid=int(m[1])
        if qid in out:raise ValueError("duplicate Compendium quest ID "+str(qid))
        out[qid]=json.loads(m[2])
    if len(out)<7000:raise ValueError("Unexpectedly incomplete catalog: "+str(len(out)))
    return out
def columns(db,table):
    return {r[1].lower():r[1] for r in db.execute("PRAGMA table_info("+table+")")}
def get_all(db,table,wanted):
    cols=columns(db,table)
    if not cols:raise ValueError("Expected database table missing: "+table)
    missing=set(wanted)-set(cols)
    if missing:raise ValueError(table+" missing "+str(sorted(missing))+"; got "+str(sorted(cols)))
    result={}
    ordered=[cols[x] for x in wanted]
    for row in db.execute("SELECT "+",".join('"'+c+'"' for c in ordered)+" FROM "+table):
        data=dict(zip(wanted,row))
        qid=int(data["entry"])
        result[qid]=data
    return result
def get_turtle(db):
    return get_all(db,"quests",["entry","title","details","requesttext","offertext",
                               "objectives","zone","hidden"])
def world_starters(db, ids):
    """Starter/spawn evidence for ALL existing Compendium IDs, not only unclassified."""
    npcs=collections.defaultdict(set)
    objects=collections.defaultdict(set)
    items=collections.defaultdict(set)
    for table, out in (("creature_quest_start",npcs),("gameobject_quest_start",objects)):
        for qid,actor in db.execute("SELECT quest,id FROM "+table):
            if qid in ids:
                out[int(qid)].add(int(actor))
    for item,quest in db.execute("SELECT entry,start_quest FROM items WHERE start_quest>0"):
        if quest in ids:items[int(quest)].add(int(item))
    active_npc={int(r[0]) for r in db.execute("SELECT DISTINCT id FROM spawns")}
    active_obj={int(r[0]) for r in db.execute("SELECT DISTINCT id FROM spawn_points WHERE kind='o'")}
    result={}
    for id in ids:
        npc=len(npcs[id] & active_npc)
        obj=len(objects[id] & active_obj)
        if npc: evidence="npc_with_spawn"
        elif obj: evidence="object_with_spawn"
        elif items[id]: evidence="item_starter_unverified"
        elif npcs[id] or objects[id]: evidence="unspawned_starter_relation"
        else: evidence="no_known_starter_relation"
        result[id]=(evidence, bool(npc or obj),npc,obj)
    return result


def get_vanilla(db):
    return get_all(db,"quest_template",["entry","title","details",
                                        "requestitemstext","offerrewardtext",
                                        "objectives","zoneorsort","method"])
def get_static(p):
    out=collections.defaultdict(dict)
    if not p:return out
    with p.open(encoding="ascii") as f:
        for n,line in enumerate(f,1):
            vals=line.rstrip("\r\n").split("\t")
            if len(vals)!=4:raise ValueError("Broken ephemeral Lua text export line "+str(n))
            qid,kind,stage,encoded=vals
            if kind not in {"spoken","turtle"} or stage not in STAGES:raise ValueError("Bad Lua text tag")
            raw=bytes.fromhex(encoded).decode("utf-8")
            out[(int(qid),kind)][stage]=raw
    return out
def csv_out(path,columns,rows):
    path.parent.mkdir(parents=True,exist_ok=True)
    with path.open("w",encoding="utf-8",newline="") as f:
        w=csv.DictWriter(f,fieldnames=columns,extrasaction="ignore")
        w.writeheader();w.writerows(rows)
def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--turtle",required=True,type=Path)
    ap.add_argument("--vanilla",required=True,type=Path)
    ap.add_argument("--methods",type=Path,required=True)
    ap.add_argument("--lua-stages",type=Path,help="Ephemeral dump of *existing* Lua corpus stages; never commit this")
    ap.add_argument("--pfquest-overrides",required=True,type=Path,
                    help="Pinned pfQuest-turtle explicit quest override IDs")
    ap.add_argument("--turtle-migrations",required=True,type=Path,
                    help="Quest text fields changed by pinned Turtle SQL migrations")
    ap.add_argument("--catalog",type=Path,default=ROOT/"SoftSpoken_Stories/Data/Compendium.lua")
    ap.add_argument("--exclusive",type=Path,default=ROOT/"docs/turtle_exclusive_import.csv")
    ap.add_argument("--shared",type=Path,default=ROOT/"docs/turtle_shared_id_coverage.csv")
    ap.add_argument("--shared-audit",type=Path,default=ROOT/"docs/audits/tortoise_unclassified_integrity/shared_id_only.csv")
    ap.add_argument("--modified",type=Path,default=ROOT/"docs/turtle_modified_shared_quest_resolutions.csv")
    ap.add_argument("--out",type=Path,default=ROOT/"docs/audits/turtle_touched_text_coverage")
    args=ap.parse_args()
    titles=catalog(args.catalog)
    excl={int(r["quest_id"]):r["status"] for r in records(args.exclusive)}
    shared={int(r["quest_id"]):r for r in records(args.shared)}
    known_modified={int(r["quest_id"]) for r in records(args.modified)}
    local_audit={int(r["quest_id"]):r for r in records(args.shared_audit)}
    methods={int(r["entry"]):r for r in records(args.methods)}
    pfquest={int(r["quest_id"]) for r in records(args.pfquest_overrides)}
    migration={int(r["entry"]):r for r in records(args.turtle_migrations)}
    if not pfquest or not migration:
        raise ValueError("Cannot audit Turtle-touched text without source-specific change provenance")
    with sqlite3.connect("file:"+str(args.turtle.resolve())+"?mode=ro",uri=True) as c:
        tw=get_turtle(c)
        world=world_starters(c,set(titles))
    with sqlite3.connect("file:"+str(args.vanilla.resolve())+"?mode=ro",uri=True) as c:
        vanilla=get_vanilla(c)
    static=get_static(args.lua_stages)
    listed,chosen,stages,held,uncorroborated=[],[],[],[],[]
    count=collections.Counter()
    for id,title in sorted(titles.items()):
        # This is deliberately NOT a fresh audit of every Spoken quest.
        # Exclude everything already in our dedicated, high-ID Turtle import
        # (including its 74 rejected nonplayable rows).
        if id in excl:
            count["excluded_exclusive_manifest"]+=1;continue
        src=tw.get(id)
        if not src:
            count["outside_source"]+=1;continue
        base=vanilla.get(id)
        baseline_present=base is not None
        disabled=(methods.get(id,{}).get("method")=="1")
        raw_method=methods.get(id)
        method_ok=(raw_method is not None and
                   titlekey(raw_method["title"])==titlekey(src["title"]) and
                   str(raw_method["zone"])==str(src["zone"]))
        retired=bool(src["hidden"]) or any(w in (src["title"] or "").lower() for w in PHRASES)
        known=shared.get(id,{}).get("classification","")
        explicit_removed=known in {"removed_by_turtle","excluded_internal"}
        audit=local_audit.get(id,{})
        evidence,proven_world,spawned_npc,spawned_obj=world.get(id,("",False,0,0))
        curated=(known=="imported" or id in known_modified or proven_world)
        pfquest_override=(id in pfquest)
        migrated=migration.get(id)
        changed_fields=set((migrated or {}).get("modified_text_fields","").split(";"))-{""}
        provenance = ";".join(filter(None,[
            "known_curated_turtle" if curated else "",
            "pfquest_turtle_quest_override" if pfquest_override else "",
            "world_sql_migration:"+",".join(sorted(changed_fields)) if migrated else ""
        ]))
        strong_provenance=bool(pfquest_override or migrated or curated)
        direct_text_provenance=bool(migrated)
        provenance_class=("turtle_sql_migration" if direct_text_provenance
                          else "pfquest_explicit_override" if pfquest_override
                          else "curated_turtle_relationship" if curated else "none")
        # Source comparison by dialogue stage, plus title and objective changes.
        changed=[]
        for stage,(twcol,vancol) in STAGES.items():
            if baseline_present and content(src[twcol])!=content(base[vancol.lower()]):
                changed.append(stage)
        title_diff=bool(base and titlekey(src["title"])!=titlekey(base["title"]))
        obj_diff=bool(base and content(src["objectives"])!=content(base["objectives"]))
        if not base:
            category="legacy_id_absent_from_vanilla"
        elif changed:
            category="dialogue_difference_candidate"
        elif title_diff or obj_diff:
            category="other_quest_text_difference_candidate"
        elif curated:
            category="curated_relation_change_only"
        else:
            count["excluded_unchanged_vanilla"]+=1
            continue
        # A disagreement between TWO emulated 1.12 community databases alone
        # does NOT establish a Turtle edit. Save such candidates as unverified,
        # never audit/override ordinary Spoken text for those quests.
        unverified = baseline_present and not strong_provenance
        if unverified:
            count["excluded_uncorroborated_database_differences"]+=1
        if not method_ok or disabled:
            reason="method_disabled_or_unverified"
        elif explicit_removed:
            reason="explicitly_removed_by_turtle"
        elif retired:
            reason="source_retired_or_placeholder"
        elif titlekey(src["title"]) != titlekey(title):
            reason="source_catalog_title_disagreement"
        elif not base and not proven_world:
            reason="legacy_id_missing_spawned_starter"
        else:
            reason=""
        row={
            "quest_id":id, "catalog_title":title,"turtle_title":src["title"],
            "vanilla_title":base["title"] if base else "",
            "turtle_method":raw_method["method"] if raw_method else "",
            "category":category,"source_status":"retired" if retired else "present",
            "baseline_status":"present" if baseline_present else "absent",
            "title_different":int(title_diff),"objective_different":int(obj_diff),
            "changed_stages":";".join(changed),
            "stage_differences":len(changed),
            "world_evidence":evidence,
            "curated_status":known if known else "modified_manifest" if id in known_modified else "",
            "turtle_starter_spawns":spawned_npc+spawned_obj,
            "source_title_agrees_catalog":int(titlekey(src["title"])==titlekey(title)),
            "eligibility_reason":reason or "review_candidate",
            "vanilla_quest_present":int(baseline_present),"source_zone":src["zone"],
            "baseline_zone":base["zoneorsort"] if base else "",
            "turtle_evidence":provenance,
            "provenance_class":provenance_class,
        }
        if unverified:
            uncorroborated.append(row)
            continue
        listed.append(row);count["candidates_"+category]+=1
        if reason:
            held.append(row);count["hold_"+reason]+=1
            continue
        chosen.append(row);count["review_"+category]+=1
        for stage,(twcol,vancol) in STAGES.items():
            source=content(src[twcol])
            base_text=content(base[vancol.lower()]) if base else ""
            changed_stage=(not baseline_present or source!=base_text)
            spoken=content(static.get((id,"spoken"),{}).get(stage))
            over=content(static.get((id,"turtle"),{}).get(stage))
            if not source:
                coverage="source_blank"
                resolution="No text to import; blank source stage may be intentional"
            elif over and over==source:
                coverage="turtle_override_exact"
                resolution="Already matched by Turtle override"
            elif over:
                coverage="turtle_override_conflict"
                resolution="Review source version vs Turtle overlay"
            elif spoken and spoken==source:
                coverage="spoken_matches_turtle"
                resolution="Existing original text matches; do not replace"
            elif changed_stage and spoken:
                coverage="spoken_outdated_for_turtle"
                resolution="Review Turtle-only stage override, leave Spoken unchanged"
            elif changed_stage:
                coverage="turtle_stage_missing"
                resolution="Review Turtle-only stage import"
            elif spoken:
                coverage="inherited_spoken_different"
                resolution="Unchanged vs cMaNGOS but Spoken differs; review only if needed"
            else:
                coverage="source_has_text_no_static_stage"
                resolution="No static dialogue: assess source stage, no blanket Vanilla import"
            sr={
                "quest_id":id,"catalog_title":title,"category":category,"stage":stage,
                "source_present":int(bool(source)),"baseline_present":int(bool(base_text)),
                "source_diff_baseline":int(changed_stage),"source_chars":len(src[twcol] or ""),
                "source_sha256":sha(source),
                "spoken_present":int(bool(spoken)),
                "spoken_matches_turtle":int(bool(spoken and spoken==source)),
                "turtle_overlay_present":int(bool(over)),
                "turtle_overlay_matches_turtle":int(bool(over and over==source)),
                "coverage":coverage,"resolution":resolution,
                "source_migration_modified_stage":int(bool(migrated and (
                    (migrated.get("source_quest_introduced_by_migration")=="1") or
                    ({"accept":"Details","progress":"RequestItemsText",
                      "complete":"OfferRewardText"}[stage] in changed_fields)))),
                "turtle_evidence":provenance,
                "provenance_class":provenance_class}
            stages.append(sr);count["stage_"+coverage]+=1
    out=args.out;out.mkdir(parents=True,exist_ok=True)
    csv_out(out/"candidate_quests.csv",COLUMNS,listed)
    csv_out(out/"review_scoped_quests.csv",COLUMNS,chosen)
    csv_out(out/"held_quests.csv",COLUMNS,held)
    csv_out(out/"uncorroborated_cross_database_variants.csv",COLUMNS,uncorroborated)
    csv_out(out/"stage_coverage.csv",STAGE_COLUMNS,stages)
    missing=[r for r in stages if r["coverage"] in {
        "spoken_outdated_for_turtle","turtle_stage_missing","turtle_override_conflict"}]
    csv_out(out/"turtle_specific_text_gaps.csv",STAGE_COLUMNS,missing)
    directly_supported=[r for r in missing if r["category"]=="legacy_id_absent_from_vanilla"
                        or r["source_migration_modified_stage"]==1]
    csv_out(out/"directly_supported_text_gaps.csv",STAGE_COLUMNS,directly_supported)
    summary={
        "scope":"Existing Compendium quests only, excluding the separate Turtle-exclusive import; no Vanilla text overwritten.",
        "turtle_source":"Pinned community Tortoise SQLite, not authenticated live Turtle WoW",
        "baseline":"Independent cMaNGOS Classic 1.12; differences are candidates, not confirmed deliberate Turtle edits.",
        "counts":dict(sorted(count.items())),
        "directly_supported_text_gaps":len(directly_supported),
        "uncorroborated_cross_database_variants":len(uncorroborated),
        "pfquest_quest_override_ids":len(pfquest),
        "turtle_sql_migration_text_changed_ids":len(migration),
        "catalog_quests":len(titles),"vanilla_quest_rows":len(vanilla),
        "tortoise_quest_rows":len(tw),"review_candidates":len(chosen),
        "held_candidates":len(held),"total_scoped_candidates":len(listed),
        "reviewed_stages":len(stages),"text_gaps":len(missing),
        "static_lua_inspected":bool(args.lua_stages),
        "caveats":["Live per-character SSCQuestJournal dialogue is not included in a static file audit.",
                   "cMaNGOS and Turtle are two evolving community database restorations; a text diff alone does not establish authorship or server availability.",
                   "Only explicit pfQuest Turtle overrides, verified Turtle SQL quest migrations or precurated Turtle relationships qualify a shared-ID review target.",
                   "An intentionally blank progress or acceptance stage is not a missing transcript.",
                   "No changed quest body, no new quest ID and no original Spoken text is written by this audit."]
    }
    (out/"summary.json").write_text(json.dumps(summary,indent=2,ensure_ascii=False)+"\n",encoding="utf-8")
    print(json.dumps(summary,indent=2,ensure_ascii=False))


if __name__=="__main__":main()
