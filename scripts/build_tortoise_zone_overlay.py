#!/usr/bin/env python3
"""Build a conservative Turtle quest classification overlay from pinned SQL evidence.

Uses only EXISTING Compendium quest IDs from the frozen availability audit.
No unverified alpha/disabled quest may be introduced by this pipeline.

python3 scripts/build_tortoise_zone_overlay.py --db .audit-viewer-data/data/tortoise.sqlite
"""
import argparse
import collections
import csv
import json
import re
import sqlite3
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AUDIT = ROOT / "docs/audits/tortoise_unclassified_integrity/all_unclassified.csv"
EXCLUSIVE = ROOT / "docs/turtle_exclusive_import.csv"
MAP_NAMES = ROOT / "SoftSpoken/Compendium/UI/MapNames.lua"
OUT_MANIFEST = ROOT / "docs/tortoise_zone_overlay.csv"
OUT_REPORT = ROOT / "docs/audits/tortoise_zone_overlay"
OUT_META = ROOT / "SoftSpoken_Stories/Data/TurtleAreaMeta.lua"
FIELDS = ["quest_id", "catalog_title", "source_title", "source_area_id", "source_area_name",
          "source_method", "source_category", "cohort", "status", "reason",
          "classification", "value", "resolved_name", "resolution", "continent"]
# Reviewed AreaTable equivalents for EXISTING UiMap locations. Extend only
# with source-supported identities; do not infer links from names alone.
VERIFIED_UI_MAPS = {
    2597: ("Alterac Valley", 1459),
}


def normal(value):
    s = unicodedata.normalize("NFKC", value or "").casefold()
    s = s.replace("\u2019", "'").replace("\u2018", "'")
    s = re.sub(r"[^a-z0-9]+", " ", s).strip()
    if s.startswith("the "):
        s = s[4:]
    return s


def csv_rows(path):
    with path.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle))


def lua_string(value):
    return json.dumps(value, ensure_ascii=False)


def read_map_names(path):
    text = path.read_text(encoding="utf-8")
    names = {}
    for match in re.finditer(r'\[(\d+)\]\s*=\s*"([^"]+)"', text):
        key, name = int(match[1]), match[2]
        if key in (947, 1414, 1415):
            continue
        simplified = normal(name)
        if simplified in names and names[simplified] != key:
            raise ValueError("Ambiguous native zone name: " + name)
        names[simplified] = key
    if names.get("durotar") != 1411 or names.get("mulgore") != 1412:
        raise ValueError("Unexpected native Vanilla map mapping")
    return names


def find_area(db, area_id, names, source):
    """Return (kind,value,name,resolution,continent) with no guessed UI map IDs."""
    if area_id < 0:
        return "sort", -area_id, "QuestSort " + str(-area_id), "server_quest_sort", ""
    if area_id == 0:
        return "", "", "", "zero_area_or_sort", ""
    entry = source.get(area_id)
    if not entry:
        return "", "", "", "missing_area_template", ""
    visited, trail, cur = set(), [], area_id
    while cur not in visited:
        visited.add(cur)
        row = source.get(cur)
        if not row:
            break
        trail.append(row)
        key = normal(row["name"])
        # Never file restricted/developer locations as a public, playable region.
        if key in {"gm island", "developer island", "test island"}:
            return "", "", row["name"], "reserved_world_area", ""
        mapid = names.get(key)
        if mapid is not None:
            return "zones", mapid, row["name"], (
                "direct_native_map" if cur == area_id else "ancestor_native_map"
            ), ""
        parent = row["zone_id"]
        if not parent or parent == cur:
            break
        cur = parent
    # Preserve true Turtle/custom/dungeon area identity, but do NOT forge a
    # Vanilla/retail uiMapID. Dedicated catalog nodes will show these by name.
    root = trail[-1] if trail else entry
    if not root["name"] or root["name"].strip().startswith("<"):
        return "", "", root["name"], "unnamed_or_placeholder_area", ""
    world_map = root["map_id"]
    continent = 1415 if world_map == 0 else 1414 if world_map == 1 else ""
    return "turtleArea", int(root["entry"]), root["name"], (
        "direct_turtle_area" if root["entry"] == area_id else "ancestor_turtle_area"
    ), continent


def build(args):
    catalog_evidence = csv_rows(args.audit)
    ex = csv_rows(args.exclusive)
    existing_exclusive = {int(r["quest_id"]) for r in ex
                          if r["status"] in {"imported", "already_present"}}
    names = read_map_names(args.map_names)
    db = sqlite3.connect("file:" + str(args.db.resolve()) + "?mode=ro", uri=True)
    try:
        cols = {r[1] for r in db.execute("PRAGMA table_info(areas)")}
        if not {"entry", "name", "map_id", "zone_id"}.issubset(cols):
            raise ValueError("The published SQLite has no area hierarchy")
        areas = {int(entry): {"entry": int(entry), "name": name, "map_id": map_id,
                              "zone_id": zone_id}
                 for entry, name, map_id, zone_id in
                 db.execute("SELECT entry,name,map_id,zone_id FROM areas")}
    finally:
        db.close()

    summary = collections.Counter()
    meta, decisions, selected, unresolved = {}, [], [], []
    for row in catalog_evidence:
        qid = int(row["quest_id"])
        cohort = "turtle_exclusive" if qid in existing_exclusive else "older_shared_id"
        category = row["review_category"]
        source_id = int(row["tortoise_zone_or_sort"] or 0)
        flag = ""
        # Only the already-curated exclusive set may receive non-world-linked
        # classifications. Older shared IDs require the strong world-link audit.
        if row["source_present"] != "1":
            flag = "missing_quest_template"
        elif row["method_snapshot_match"] != "1":
            flag = "source_snapshot_disagreement"
        elif row["method_status"] != "enabled_or_autocomplete":
            flag = "method_not_enabled"
        elif row["title_match"] != "1":
            flag = "title_disagreement"
        elif row["source_hidden_heuristic"] == "1":
            flag = "retired_or_placeholder"
        elif row["known_turtle_status"] == "removed_by_turtle":
            flag = "previously_removed_by_turtle"
        elif cohort == "older_shared_id" and category != "world_linked_candidate":
            flag = "shared_id_not_world_linked"
        if flag:
            kind, value, name, resolution, continent = "", "", "", "held", ""
        else:
            kind, value, name, resolution, continent = find_area(
                None, source_id, names, areas)
            if not kind:
                flag = resolution
        status = "selected" if not flag else "held"
        decision = {
            "quest_id": qid, "catalog_title": row["catalog_title"],
            "source_title": row["source_title"],
            "source_area_id": source_id, "source_area_name": row["zone_or_sort_name"],
            "source_method": row["method"],
            "source_category": category, "cohort": cohort,
            "status": status, "reason": flag or "",
            "classification": kind, "value": value,
            "resolved_name": name, "resolution": resolution,
            "continent": continent
        }
        decisions.append(decision)
        summary["status_"+status] += 1
        summary["cohort_"+cohort+"_"+status] += 1
        summary["resolution_"+resolution] += 1
        if status == "selected":
            selected.append(decision)
            summary["classification_"+kind] += 1
            if kind == "turtleArea":
                key = int(value)
                new = {"name": name, "continent": continent}
                if key in meta and meta[key] != new:
                    raise ValueError("Conflicting area name or continent for " + str(key))
                meta[key] = new
        else:
            unresolved.append(decision)
    if len(decisions) != 2409:
        raise ValueError("Unexpected input count, review source provenance: " + str(len(decisions)))
    if len({r["quest_id"] for r in decisions}) != len(decisions):
        raise ValueError("Duplicate quest ID in classification decisions")
    if next((r for r in selected if r["quest_id"] == 820), {}).get("value") != 1411:
        raise ValueError("Quest 820 MUST resolve to Durotar map ID 1411")
    if any(r["quest_id"] in {8289, 8296} for r in selected):
        raise ValueError("Disabled quests escaped the hold gate")
    if any(r["quest_id"] == 41797 for r in selected):
        raise ValueError("Title disagreement escaped the hold gate")

    args.report.mkdir(parents=True, exist_ok=True)
    for path, lines in [
        (args.report / "decisions.csv", decisions),
        (args.report / "holds.csv", unresolved),
        (args.manifest, selected)
    ]:
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("w", encoding="utf-8", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=FIELDS)
            writer.writeheader()
            writer.writerows(lines)
    with (args.report / "summary.json").open("w", encoding="utf-8") as handle:
        json.dump({"source": "Pinned Tortoise SQLite + frozen SQL availability audit",
                   "counts": dict(sorted(summary.items())),
                   "areas_meta": len(meta),
                   "total_audited": len(decisions),
                   "selected": len(selected),
                   "held": len(unresolved),
                   "note": "No new quest IDs; positive source AreaTable IDs are never used as uiMapIDs."},
                  handle, indent=2, ensure_ascii=False)
        handle.write("\n")
    missing = sorted(set(VERIFIED_UI_MAPS) - set(meta))
    if missing:
        raise ValueError("Verified map equivalents missing source areas: " + str(missing))
    lua = [
        "-- Generated from the pinned Tortoise area hierarchy by",
        "-- scripts/build_tortoise_zone_overlay.py. Names, continent metadata and",
        "-- reviewed UI map equivalents for AreaTable IDs (which are NOT uiMapIDs).",
        "SSCTurtleAreaMeta = {"
    ]
    for area_id, m in sorted(meta.items()):
        cont = f", continent = {m['continent']}" if m["continent"] else ""
        linked = ""
        if area_id in VERIFIED_UI_MAPS:
            expected, ui_map_id = VERIFIED_UI_MAPS[area_id]
            if normal(m["name"]) != normal(expected):
                raise ValueError(f"AreaTable {area_id}: expected {expected}, got {m['name']}")
            linked = f", uiMapID = {ui_map_id}"
        lua.append(f"    [{area_id}] = {{ name = {lua_string(m['name'])}{cont}{linked} }},")
    lua.append("}")
    args.meta.parent.mkdir(parents=True, exist_ok=True)
    args.meta.write_text("\n".join(lua)+"\n", encoding="utf-8")
    print(json.dumps({"selected": len(selected), "held": len(unresolved),
                      "counts": dict(sorted(summary.items())), "areas_meta": len(meta)},
                     indent=2))


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--db", required=True, type=Path)
    ap.add_argument("--audit", type=Path, default=AUDIT)
    ap.add_argument("--exclusive", type=Path, default=EXCLUSIVE)
    ap.add_argument("--map-names", type=Path, default=MAP_NAMES)
    ap.add_argument("--manifest", type=Path, default=OUT_MANIFEST)
    ap.add_argument("--report", type=Path, default=OUT_REPORT)
    ap.add_argument("--meta", type=Path, default=OUT_META)
    build(ap.parse_args())


if __name__ == "__main__":
    main()
