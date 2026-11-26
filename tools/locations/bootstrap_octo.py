"""Bootstrap a reviewed-input Octo location proposal from the pinned DBC archive.

No runtime changes or raw DBC redistribution. New IDs are proposals until reviewed.
Run from repository root; output is private staging, outside SoftSpoken/.
"""
import argparse
from collections import Counter, defaultdict
from copy import deepcopy
import hashlib
import json
from pathlib import Path
import re
import unicodedata
import zipfile

PROFILE = "octo_20261126"
EXPECTED = {
    "AreaTable": "f17b32702cf489390e059df6e5e668c469c6b5e90a39b9109f6fa2a9627b3617",
    "Map": "5b3cd262f3eb422a404b5aa8ddb3fecbe6de87e451c55b28775690867e4c39b9",
    "WorldMapArea": "97fbaf8cf54578d9d7de3cb221e1cb8e784969658b8b72dac0abd0af4492841e",
    "WorldMapOverlay": "fc7a78561c5d51fa7dc254428c7a2e134b2dd082a02bb157ebda4ead030f41e6",
}


def norm(text):
    text = unicodedata.normalize("NFKD", text.casefold())
    text = "".join(c for c in text if not unicodedata.combining(c))
    return re.sub(r"^the ", "", re.sub(r"[^a-z0-9]+", " ", text.replace("'", "").replace("’", "")).strip())


def label(row):
    return row.get("names", {}).get("enUS", "").strip()


def placeholder(name):
    return not name or bool(re.search(r"unused|delete\s*me|\*\*\*|^test|chunk test", name, re.I))


def dump(path, obj):
    path.write_text(json.dumps(obj, indent=2, ensure_ascii=False, sort_keys=True)+"\n", encoding="utf-8")


def reconcile(seed, research, tables, refs=(), meta=None, reviewed=False):
    """Return a candidate manifest and explicit review report, without mutating seed."""
    d = deepcopy(seed)
    if d.get("worldOverlays") or d.get("profileOverlays") or d.get("sourceDispositions"):
        raise ValueError("bootstrap requires the original L4 seed; do not regenerate an allocated catalog")
    meta = meta or {}
    area, maps, wma, overlays = (tables[k] for k in ("AreaTable", "Map", "WorldMapArea", "WorldMapOverlay"))
    entities = deepcopy(d["base"]["entities"])
    added, patches, bindings, reps, coverage = {}, {}, [], [], []
    areas, map_ids, map_subjects = {}, {}, {}
    dispositions, conflicts = {}, []
    name_ids = defaultdict(list)
    for aid, row in sorted(area.items()):
        if not placeholder(label(row)):
            name_ids[norm(label(row))].append(aid)

    def issue(kind, **fields):
        conflicts.append(dict(kind=kind, **fields))

    def disp(table, ident, status, reason, location=None):
        key = table, ident
        if key in dispositions:
            raise ValueError(f"duplicate disposition {key}")
        dispositions[key] = dict(scope=PROFILE, table=table, id=ident, status=status, reason=reason)
        if location is not None:
            dispositions[key]["location"] = location

    def allocate(name, kind, qualifier, ident, source):
        slug = norm(name).replace(" ", "_")
        if not slug or not slug[0].isalpha():
            slug = "place_" + slug
        key = slug
        if key in d["identities"]:
            key = qualifier + "." + slug
        if key in d["identities"]:
            key += "_" + str(ident)
        if key in d["identities"]:
            raise ValueError(f"canonical allocation collision {key}")
        d["identities"][key] = {"status":"active", "evidence":[f"{PROFILE}: {source} {ident}; {name}"]}
        added[key] = entities[key] = {"name":name, "kind":kind}
        return key

    def bind(ns, value, location):
        bindings.append(dict(scope=PROFILE, namespace=ns, value=value, location=location))

    def maprep(ns, value, subject):
        reps.append(dict(scope=PROFILE, namespace=ns, value=value, subject=subject))

    def ancestors(aid):
        result, seen = [], {aid}
        while aid in area and area[aid]["parentArea"]:
            parent = area[aid]["parentArea"]
            if parent in seen or parent not in area:
                raise ValueError(f"invalid native parent chain at {aid}")
            result.append(parent); seen.add(parent); aid = parent
        return result

    chain = {aid:ancestors(aid) for aid in area}
    region_areas = defaultdict(set)
    for row in overlays.values():
        parent = wma.get(row["worldMapArea"], {}).get("areaTable")
        if parent:
            for aid in row["areaIDs"]:
                region_areas[aid].add(parent)

    def context(aid, parent):
        return aid == parent or parent in chain[aid] or parent in region_areas[aid]

    def assign_area(aid, key, reason):
        if aid in areas:
            if areas[aid] != key:
                raise ValueError(f"conflicting AreaTable assignment {aid}")
            return
        areas[aid] = key
        bind("areaTable", aid, key)
        disp("AreaTable", aid, "mapped", reason, key)

    # Preserve the immutable seed allocations. Recheck both name and region where applicable.
    for row in sorted(research["nativeEvidenceCandidates"], key=lambda x:x["areaTable"]):
        aid, key = row["areaTable"], row["location"]
        native = area.get(aid)
        if (key not in entities or native is None or placeholder(label(native)) or
                norm(label(native)) != norm(row["areaName"]) or
                (row.get("mapRegionAreaID") and not context(aid, row["mapRegionAreaID"]))):
            issue("seed-native-mismatch", candidate=row, actual=label(native or {}))
            continue
        assign_area(aid, key, "seed anchor rechecked against Octo name and native region")

    # Map.dbc is a separate identifier namespace. Its link field is not a parent map.
    legacy_instances = {r["value"]:r["location"] for r in d["contentCrosswalk"]
                        if r["namespace"] == "instanceMap" and r["status"] == "mapped"}
    for mid, row in sorted(maps.items()):
        name, kind = label(row), row["instanceType"]
        if mid in (0,1):
            key = {0:"eastern_kingdoms",1:"kalimdor"}[mid]
        elif placeholder(name) or mid == 451:
            disp("Map",mid,"excluded","explicit development/placeholder map")
            continue
        else:
            key = legacy_instances.get(mid)
            if key and norm(entities[key]["name"]) != norm(name):
                issue("legacy-instance-name-mismatch",mapID=mid,location=key,actual=name)
                key = None
            root = [aid for aid,a in area.items() if a["worldMap"] == mid and not a["parentArea"] and norm(label(a)) == norm(name)]
            known = {areas[aid] for aid in root if aid in areas}
            if not key and len(known)==1:
                key = next(iter(known))
            if not key:
                # Names of known root areas can establish identity only inside this map.
                typ = {1:"dungeon",2:"raid",3:"unknown",4:"arena"}.get(kind,"unknown")
                if kind == 3 and ("arena" in name.casefold() or mid == 26): typ="arena"
                key = allocate(name,typ,"instance" if kind else "map",mid,"Map")
            if len(root)==1 and (root[0] not in areas or areas[root[0]]==key):
                assign_area(root[0],key,"unique same-name root AreaTable on the instance/world map")
            elif len(root)>1:
                issue("multiple-map-root-areas",mapID=mid,location=key,candidates=root)
        if key not in entities:
            raise ValueError(f"missing seed continent {key}")
        map_ids[mid] = key
        if kind in (1,2,3,4):
            bind("instanceMap",mid,key); maprep("instanceMap",mid,key)
            disp("Map",mid,"mapped","native instance Map.dbc identity",key)
        else:
            maprep("worldMap",mid,key)
            disp("Map",mid,"representation","native world-map context",key)

    # Explicit reviewed aliases: name differs, but native map and known area anchor agree.
    for aid, mid in ((717,34),(1581,36),(3428,531)):
        if aid in area and area[aid]["worldMap"] == mid and mid in map_ids and aid not in areas:
            assign_area(aid,map_ids[mid],"reviewed native instance root alias")

    # Remaining globally unique named rows are new entity proposals, including contentless places.
    # Repeated names are retained for human reconciliation, not duplicated or merged by default.
    for aid,row in sorted(area.items()):
        if aid in areas: continue
        name = label(row)
        if placeholder(name):
            disp("AreaTable",aid,"excluded","unnamed or explicitly unused/test marker")
            continue
        if row["worldMap"] == 451:
            disp("AreaTable",aid,"held","development map; reachability/identity not established")
            continue
        if len(name_ids[norm(name)]) != 1:
            disp("AreaTable",aid,"held","repeated native name; identity needs review")
            issue("duplicate-area-name",areaID=aid,name=name,candidates=name_ids[norm(name)])
            continue
        existing = [key for key,e in entities.items() if norm(e["name"])==norm(name)]
        if existing:
            disp("AreaTable",aid,"held","name already allocated without verified identity binding")
            issue("existing-name-unbound",areaID=aid,name=name,candidates=existing)
            continue
        kind = "subzone" if row["parentArea"] else "unknown"
        if not row["parentArea"] and any(r["areaTable"]==aid for r in wma.values()): kind="zone"
        key = allocate(name,kind,"area",aid,"AreaTable")
        assign_area(aid,key,"unique named native row; new candidate identity")

    relations = []
    boundary_keys = set()
    instance_alias_areas = set()
    if reviewed:
        from octo_policy import apply, CROSS_ZONE, SEAS, MAP_ALIASES
        related = apply(area,wma,map_ids,areas,entities,added,d["identities"],dispositions,assign_area)
        boundary_keys = set(CROSS_ZONE) | set(SEAS)
        instance_alias_areas = {i for i,_ in MAP_ALIASES.values()}
        relations = [dict(from_=src,relation="associatedWith",to=dst) for src,dst in related]
        conflicts = [r for r in conflicts if not (
            r["kind"] in ("duplicate-area-name","existing-name-unbound") and r["areaID"] in areas or
            r["kind"]=="multiple-map-root-areas" and all(i in areas and areas[i]==r["location"] for i in r["candidates"]))]

    # DBC containment only where both ends are mapped and within the same underlying map.
    # Cross-map parent links are evidence for review, not physical containment assertions.
    parent_candidates = defaultdict(set)
    for aid,key in sorted(areas.items()):
        row = area[aid]; parent = row["parentArea"]
        if parent:
            if parent in areas and area[parent]["worldMap"] == row["worldMap"] and areas[parent]!=key:
                parent_candidates[key].add(areas[parent])
            elif parent not in areas or area[parent]["worldMap"] != row["worldMap"]:
                issue("unresolved-native-parent",areaID=aid,parentArea=parent,location=key)
        elif aid not in instance_alias_areas and row["worldMap"] in (0,1) and key not in ("eastern_kingdoms","kalimdor"):
            parent_candidates[key].add(map_ids[row["worldMap"]])
    for key, parents in sorted(parent_candidates.items()):
        if key in boundary_keys and len(parents)>1:
            # Several verified DBC region associations; do not fabricate a primary.
            if key in added: added[key].pop("parent",None)
            elif entities[key].get("parent"):
                patch=patches.setdefault(key,{"set":{},"clear":[]})
                patch["set"].pop("parent",None); patch["clear"].append("parent")
            for parent in sorted(parents):
                relations.append(dict(from_=key,relation="associatedWith",to=parent))
            continue
        if len(parents)!=1:
            issue("multiple-native-parents",location=key,candidates=sorted(parents)); continue
        parent=next(iter(parents))
        if key in added: added[key]["parent"]=parent
        elif entities[key].get("parent")!=parent:
            patches.setdefault(key,{"set":{},"clear":[]})["set"]["parent"]=parent

    for wid,row in sorted(wma.items()):
        aid,mid = row["areaTable"],row["worldMap"]
        key = areas.get(aid) if aid else ("azeroth" if row["directory"]=="World" else map_ids.get(mid))
        if not key:
            disp("WorldMapArea",wid,"held","map subject unresolved"); continue
        map_subjects[wid]=key; maprep("worldMapArea",wid,key)
        disp("WorldMapArea",wid,"representation","native map subject",key)
    pairs=set()
    for oid,row in sorted(overlays.items()):
        wid=row["worldMapArea"]
        missing=[aid for aid in row["areaIDs"] if aid not in areas]
        if wid not in map_subjects or missing:
            disp("WorldMapOverlay",oid,"held","map or covered area unresolved")
            issue("overlay-partial",overlayID=oid,worldMapArea=wid,unresolvedAreaIDs=missing)
        else:
            disp("WorldMapOverlay",oid,"representation","map coverage; not containment")
        if wid in map_subjects:
            for aid in row["areaIDs"]:
                if aid in areas: pairs.add((areas[aid],wid))
    for key,wid in sorted(pairs):
        coverage.append(dict(location=key,map=dict(scope=PROFILE,namespace="worldMapArea",value=wid)))

    # Fill held content references only with exact normalized name and verified native context.
    from build import excluded_content_map
    cross=d["contentCrosswalk"]
    def ckey(r): return r["sourceScope"],r["namespace"],r["value"],r.get("area")
    existing={ckey(r):r for r in cross}
    upstream={r["value"]:r["location"] for r in d["base"]["bindings"] if r["namespace"]=="upstreamUiMap"}
    area_by_entity=defaultdict(list)
    for aid,key in areas.items(): area_by_entity[key].append(aid)
    for ref in refs:
        ck=ckey(ref)
        if ck in existing: continue
        scope,ns,value,subkey=ck
        if excluded_content_map(scope,ns,value): continue
        key=None
        if ns=="legacyPlace" and value in upstream and subkey:
            parents=area_by_entity[upstream[value]]
            matches={areas[aid] for aid in name_ids.get(norm(subkey),[]) if aid in areas and any(context(aid,p) for p in parents)}
            if len(matches)==1: key=next(iter(matches))
        elif ns=="areaTable" and value in areas and value in meta:
            row=meta[value]; native=area[value]
            if row.get("name") and norm(row["name"])==norm(label(native)): key=areas[value]
            elif row.get("uiMapID") in upstream and upstream[row["uiMapID"]]==areas[value]: key=areas[value]
            elif row.get("dungeonMapID") in map_ids and map_ids[row["dungeonMapID"]]==areas[value]: key=areas[value]
        if key:
            record=dict(sourceScope=scope,namespace=ns,value=value,status="mapped",location=key,reason="exact native name/context or corroborated legacy metadata")
            if subkey is not None: record["area"]=subkey
            cross.append(record); existing[ck]=record
    d["worldOverlays"]={"octo":dict(add=added,patch=patches)}
    if relations:
        unique = {(min(r["from_"],r["to"]),max(r["from_"],r["to"])) for r in relations}
        d["worldOverlays"]["octo"]["addRelations"]=[{"from":a,"relation":"associatedWith","to":b} for a,b in sorted(unique)]
    d["profileOverlays"]={PROFILE:dict(addBindings=bindings,addMapRepresentations=reps,addMapCoverage=coverage)}
    d["sourceDispositions"]=[dispositions[k] for k in sorted(dispositions)]
    counts={name:dict(Counter(r["status"] for r in d["sourceDispositions"] if r["table"]==name)) for name in tables}
    report=dict(profile=PROFILE,status="candidate-review-required",entities=len(entities),newEntities=len(added),seedNativeMatches=sum(1 for r in research["nativeEvidenceCandidates"] if areas.get(r["areaTable"])==r["location"]),sourceCounts=counts,bindings=dict(Counter(r["namespace"] for r in bindings)),mapRepresentations=len(reps),mapCoverage=len(coverage),contentCrosswalks=len(cross),conflicts=conflicts)
    return d,report


def main():
    from dbc import read_dbc
    from build import read_json, identity_manifest, validate_view, effective
    from inventory import inventory, table
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--archive",type=Path,required=True)
    parser.add_argument("--root",type=Path,default=Path(__file__).resolve().parents[2])
    parser.add_argument("--output",type=Path,required=True)
    parser.add_argument("--voice-pack",type=Path)
    parser.add_argument("--reviewed",action="store_true",help="apply approved Octo identity policies")
    args=parser.parse_args()
    out=args.output.resolve(); root=args.root.resolve(); addon=root/"SoftSpoken"
    if out==addon or addon in out.parents: parser.error("private staging output must be outside the addon")
    out.mkdir(parents=True,exist_ok=True)
    if any(out.iterdir()): parser.error("use a new empty staging directory")
    src=out/"private-dbc"; src.mkdir(); tables={}
    with zipfile.ZipFile(args.archive) as archive:
        for name,expected in EXPECTED.items():
            raw=archive.read(name+".dbc")
            if hashlib.sha256(raw).hexdigest()!=expected: raise ValueError(f"wrong pinned Octo source: {name}")
            path=src/(name+".dbc"); path.write_bytes(raw); tables[name]=read_dbc(path,name)
    tools=root/"tools/locations"
    seed=read_json(tools/"decisions.json"); research=read_json(tools/"review/vanilla-seed.json")
    refs=inventory(root,args.voice_pack)["references"]
    meta=table((addon/"Modules/Stories/Data/TurtleAreaMeta.lua").read_text(encoding="utf-8-sig"),"SSCTurtleAreaMeta")
    d,report=reconcile(seed,research,tables,refs,meta,reviewed=args.reviewed)
    identity_manifest(d["identities"],seed["identities"])
    scopes={PROFILE:"native","spoken_classic":"content"}
    view=effective(effective(d["base"],d["worldOverlays"]["octo"]),d["profileOverlays"][PROFILE])
    validate_view(view,d["identities"],scopes,{PROFILE:tables})
    manifest=read_json(tools/"sources.json")
    manifest["profiles"]={PROFILE:dict(world="octo",revision="user Octo extract 2026-11-26",provenance="user-supplied effective Octo/Turtle-derived client export; exact patch version not established",rights="private-staging",locale="enUS",layout="vanilla_5875",effectivePatched=True,files={name:dict(path=str(src/(name+".dbc")),sha256=h) for name,h in EXPECTED.items()})}
    dump(out/"decisions.octo.json",d); dump(out/"sources.octo.json",manifest); dump(out/"octo-review.json",report)
    print(json.dumps({k:v for k,v in report.items() if k!="conflicts"},indent=2,sort_keys=True))


if __name__=="__main__": main()
