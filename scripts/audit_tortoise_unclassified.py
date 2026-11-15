#!/usr/bin/env python3
"""Read-only audit of EXISTING unclassified Compendium quests against Turtle SQL.

Never add quests or write metadata into the Compendium. An SQL quest template alone
does not establish live-server availability.
"""
import argparse
import collections
import csv
import json
import re
import sqlite3
import unicodedata
from pathlib import Path

ROW_RE = re.compile(r"^\s*\[(\d+)\]\s*=\s*(\{[^\n]*\}),\s*$", re.M)
RETIRED = re.compile(r"placeholder|deprecated|cancell?ed|\bunused\b|cashtest|qaspell|\[test\]|monster\s*-\s|\s-\s*qa\b|\(old\)", re.I)
COLUMNS = ("quest_id catalog_title source_title source_present title_match "
           "source_hidden_heuristic method method_source_verified method_snapshot_match method_status "
           "tortoise_zone_or_sort zone_or_sort_name classification_type npc_starters "
           "spawned_npc_starters npc_starter_ids spawned_npc_ids object_starters "
           "spawned_object_starters object_starter_ids spawned_object_ids item_starters "
           "item_starter_ids npc_enders object_enders quest_prev quest_next sql_evidence "
           "review_category proposed_action known_turtle_status source_ref").split()


def norm(v):
    return " ".join(unicodedata.normalize("NFKC", v or "").replace("\u2019", "'").split()).casefold()


def catalog(path):
    text = path.read_text(encoding="utf-8")
    body = text.split("\tquests = {", 1)[1].split("\n\t},\n\n\tsorts = {", 1)[0]
    all_quests, missing = {}, {}
    for m in ROW_RE.finditer(body):
        qid, value = int(m[1]), m[2]
        if qid in all_quests:
            raise ValueError("duplicate quest " + str(qid))
        t = re.search(r'^\{\s*"((?:[^"\\]|\\.)*)"', value)
        if not t:
            raise ValueError("missing quest title " + str(qid))
        title = json.loads('"' + t[1] + '"')
        all_quests[qid] = title
        if not re.search(r"\bzones\s*=\s*\{[^}]*\d", value) and not re.search(r"\bsort\s*=", value):
            missing[qid] = title
    return all_quests, missing


def pairs(db, table, wanted):
    out = collections.defaultdict(set)
    for qid, entity in db.execute("SELECT quest,id FROM " + table):
        if qid in wanted:
            out[qid].add(int(entity))
    return out


def required_table(db, table, fields):
    got = {r[1] for r in db.execute("PRAGMA table_info(" + table + ")")}
    if not set(fields).issubset(got):
        raise ValueError(table + ": missing " + str(sorted(set(fields) - got)))


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--db", type=Path, required=True)
    ap.add_argument("--methods", type=Path)
    ap.add_argument("--catalog", type=Path, default=Path("SoftSpoken_Stories/Data/Compendium.lua"))
    ap.add_argument("--known-status", type=Path, default=Path("docs/turtle_shared_id_coverage.csv"))
    ap.add_argument("--out", type=Path, default=Path("docs/audits/tortoise_unclassified_integrity"))
    ap.add_argument("--source-ref", default="Xian55/tortoise-db-viewer cdn@567ce23c")
    args = ap.parse_args()
    all_quests, targets = catalog(args.catalog)
    with args.known_status.open(newline="", encoding="utf-8") as f:
        known = {int(r["quest_id"]): r["classification"] for r in csv.DictReader(f)}
    methods = {}
    if args.methods:
        with args.methods.open(newline="", encoding="utf-8") as f:
            methods = {int(r["entry"]): r for r in csv.DictReader(f)}
    db = sqlite3.connect("file:" + str(args.db.resolve()) + "?mode=ro", uri=True)
    try:
        for table, cols in {
            "quests": ["entry", "title", "zone", "hidden", "prevquest", "nextquest"],
            "creature_quest_start": ["quest", "id"],
            "creature_quest_end": ["quest", "id"],
            "gameobject_quest_start": ["quest", "id"],
            "gameobject_quest_end": ["quest", "id"],
            "items": ["entry", "start_quest"],
            "spawns": ["id", "map"],
            "spawn_points": ["kind", "id"],
            "areas": ["entry", "name"],
        }.items():
            required_table(db, table, cols)
        quests = {r[0]: dict(zip(["entry", "title", "zone", "hidden", "prevquest", "nextquest"], r))
                  for r in db.execute("SELECT entry,title,zone,hidden,prevquest,nextquest FROM quests")
                  if r[0] in targets}
        starts_n = pairs(db, "creature_quest_start", targets)
        starts_o = pairs(db, "gameobject_quest_start", targets)
        ends_n = pairs(db, "creature_quest_end", targets)
        ends_o = pairs(db, "gameobject_quest_end", targets)
        starts_i = collections.defaultdict(set)
        for item_id, qid in db.execute("SELECT entry,start_quest FROM items WHERE start_quest>0"):
            if qid in targets:
                starts_i[qid].add(int(item_id))
        wanted_n = set().union(*starts_n.values()) if starts_n else set()
        wanted_o = set().union(*starts_o.values()) if starts_o else set()
        spawned_n = {int(r[0]) for r in db.execute("SELECT DISTINCT id FROM spawns") if r[0] in wanted_n}
        spawned_o = {int(r[0]) for r in db.execute("SELECT DISTINCT id FROM spawn_points WHERE kind='o'") if r[0] in wanted_o}
        areas = {int(a): name for a, name in db.execute("SELECT entry,name FROM areas")}
    finally:
        db.close()

    rows, counts, mismatches = [], collections.Counter(), []
    for qid, title in sorted(targets.items()):
        src, raw = quests.get(qid), methods.get(qid)
        present = src is not None
        title_src = (src or {}).get("title") or ""
        title_agree = present and norm(title) == norm(title_src)
        zone = src["zone"] if present else None
        if isinstance(zone, int) and zone > 0:
            kind, zone_name = "area", areas.get(zone, "")
        elif isinstance(zone, int) and zone < 0:
            kind, zone_name = "sort", "QuestSort " + str(-zone)
        else:
            kind, zone_name = "none", ""
        method = raw["method"] if raw else ""
        method_match = bool(raw and present and norm(raw["title"]) == norm(title_src)
                            and str(raw["zone"]) == str(zone))
        method_state = ("disabled" if method_match and method == "1"
                        else "enabled_or_autocomplete" if method_match and method in {"0", "2"}
                        else "unverified")
        n = starts_n.get(qid, set())
        o = starts_o.get(qid, set())
        i = starts_i.get(qid, set())
        ns, os = n & spawned_n, o & spawned_o
        world_linked = bool(ns or os)
        have_starter = bool(n or o or i)
        flagged = bool(src and (src["hidden"] or RETIRED.search(title_src)))
        removed = known.get(qid) == "removed_by_turtle"
        if removed:
            category, action = "previously_removed", "hold"
        elif not present:
            category, action = "missing_source", "hold"
        elif flagged:
            category, action = "source_retired_marker", "hold"
        elif method_state == "disabled":
            category, action = "method_disabled", "hold"
        elif not title_agree:
            category, action = "title_disagreement", "review"
        elif world_linked and method_state == "enabled_or_autocomplete":
            category, action = "world_linked_candidate", "review_zone"
        elif world_linked:
            category, action = "world_linked_method_unverified", "review"
        elif have_starter:
            category, action = "starter_without_known_world_spawn", "review"
        elif src.get("prevquest") or src.get("nextquest"):
            category, action = "chain_or_script_candidate", "review"
        else:
            category, action = "orphaned_or_script_only", "hold"
        evidence = ("npc_with_spawn" if ns else "object_with_spawn" if os else
                    "item_starter" if i else "unspawned_starter_relation" if n or o else
                    "chain_only" if present and (src["prevquest"] or src["nextquest"]) else
                    "template_only" if present else "no_template")
        row = {
            "quest_id": qid, "catalog_title": title, "source_title": title_src,
            "source_present": int(present), "title_match": int(bool(title_agree)),
            "source_hidden_heuristic": int(bool(src and src["hidden"])),
            "method": method, "method_source_verified": int(bool(raw)),
            "method_snapshot_match": int(method_match), "method_status": method_state,
            "tortoise_zone_or_sort": zone if zone is not None else "",
            "zone_or_sort_name": zone_name, "classification_type": kind,
            "npc_starters": len(n), "spawned_npc_starters": len(ns),
            "npc_starter_ids": ";".join(map(str, sorted(n))),
            "spawned_npc_ids": ";".join(map(str, sorted(ns))),
            "object_starters": len(o), "spawned_object_starters": len(os),
            "object_starter_ids": ";".join(map(str, sorted(o))),
            "spawned_object_ids": ";".join(map(str, sorted(os))),
            "item_starters": len(i), "item_starter_ids": ";".join(map(str, sorted(i))),
            "npc_enders": len(ends_n.get(qid, set())),
            "object_enders": len(ends_o.get(qid, set())),
            "quest_prev": src.get("prevquest", "") if src else "",
            "quest_next": src.get("nextquest", "") if src else "",
            "sql_evidence": evidence, "review_category": category,
            "proposed_action": action,
            "known_turtle_status": known.get(qid, ""), "source_ref": args.source_ref,
        }
        rows.append(row)
        counts["category_" + category] += 1
        counts["action_" + action] += 1
        if present: counts["source_present"] += 1
        if world_linked: counts["world_linked"] += 1
        if method_match: counts["method_snapshot_match"] += 1
        if method_state == "disabled": counts["method_disabled"] += 1
        if kind != "none": counts["metadata_available"] += 1
        if raw and not method_match: mismatches.append(row)
    args.out.mkdir(parents=True, exist_ok=True)
    for name, part in [
        ("all_unclassified.csv", rows),
        ("world_linked_candidates.csv", [r for r in rows if r["review_category"] == "world_linked_candidate"]),
        ("requires_review.csv", [r for r in rows if r["proposed_action"] != "review_zone"]),
        ("method_snapshot_disagreements.csv", mismatches),
    ]:
        with (args.out / name).open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=COLUMNS)
            writer.writeheader()
            writer.writerows(part)
    summary = {
        "catalog_total": len(all_quests),
        "unclassified_existing": len(targets),
        "method_rows_available": len(methods),
        "counts": dict(sorted(counts.items())),
        "focus_820": next((r for r in rows if r["quest_id"] == 820), None),
        "notes": [
            "Read-only: never introduce missing quest IDs or change Compendium.lua.",
            "SQL relationships and spawns support only availability candidates, not proof of a live quest.",
            "The viewer hidden flag comes from title heuristics, not the authoritative quest Method.",
            "Method is accepted only where raw SQL title and area/sort agree with the pinned viewer.",
            "The viewer may supplement its spawn_points with reported/scripted NPCs or objects.",
            "Positive ZoneOrSort is an AreaTable ID, not a Compendium UI map ID.",
        ],
    }
    with (args.out / "summary.json").open("w", encoding="utf-8") as f:
        json.dump(summary, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
