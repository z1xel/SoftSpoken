"""Offline, reviewed location catalog builder. No source Lua is executed."""
import argparse
from collections import Counter
from copy import deepcopy
import json
from pathlib import Path
import re
import sys

from dbc import load_sources, sha256
from inventory import inventory

ID = re.compile(r"[a-z][a-z0-9_]*(?:\.[a-z][a-z0-9_]*)*\Z")
KINDS = set("world continent zone city subzone settlement landmark interior dungeon raid battleground arena unknown".split())
NS = {"areaTable", "upstreamUiMap", "nativeUiMap", "worldMapArea", "instanceMap", "worldMap"}
REL = {"within", "associatedWith", "entranceIn"}
TABLE = {"areaTable":"AreaTable", "worldMapArea":"WorldMapArea", "instanceMap":"Map", "worldMap":"Map"}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def read_json(path):
    def pairs(rows):
        result = {}
        for key, value in rows:
            require(key not in result, f"duplicate JSON key {key}")
            result[key] = value
        return result
    return json.loads(Path(path).read_text(encoding="utf-8"), object_pairs_hook=pairs)


def identity_manifest(manifest, previous=None):
    require(isinstance(manifest, dict), "invalid identity manifest")
    for key, record in manifest.items():
        require(ID.fullmatch(key), f"invalid canonical ID {key}")
        require(record.get("status") in ("active","retired"), f"invalid identity status {key}")
        require(isinstance(record.get("evidence"), list) and record["evidence"],
                f"identity lacks evidence {key}")
        require(not (record.get("redirect") and record.get("split")), f"redirect and split {key}")
        if record["status"] == "active":
            require("redirect" not in record and "split" not in record, f"active redirect/split {key}")
        if "split" in record:
            require(len(set(record["split"])) >= 2 and all(x in manifest and x != key for x in record["split"]),
                    f"invalid split {key}")
        seen, target = {key}, record.get("redirect")
        while target:
            require(target in manifest and target not in seen, f"invalid/cyclic redirect {key}")
            seen.add(target)
            next_record = manifest[target]
            target = next_record.get("redirect")
            if not target:
                require(next_record["status"] == "active", f"redirect to inactive ID {key}")
    for key, old in (previous or {}).items():
        require(key in manifest, f"allocated ID removed: {key}")
        require(not (old["status"] == "retired" and manifest[key]["status"] == "active"),
                f"retired ID recycled: {key}")


def entity_check(key, entity):
    require(isinstance(entity, dict) and not set(entity)-{"name","kind","parent","aliases","names"},
            f"{key}: unexpected entity fields")
    require(isinstance(entity.get("name"), str) and entity["name"].strip(), f"{key}: missing name")
    require(entity.get("kind") in KINDS, f"{key}: invalid kind")
    for field in ("names","aliases"):
        require(isinstance(entity.get(field, {}), dict), f"{key}: invalid {field}")
        for locale, values in entity.get(field, {}).items():
            require(re.fullmatch(r"[a-z]{2}[A-Z]{2}", locale), f"{key}: invalid locale")
            if field == "names":
                values = [values]
            require(isinstance(values, list) and values and all(isinstance(v,str) and v.strip() for v in values),
                    f"{key}: invalid {field} values")


def key_of(row):
    return row["scope"], row["namespace"], row["value"]


def check_id(row, scopes):
    scope, ns, value = key_of(row)
    require(ns in NS and type(value) is int, f"invalid identifier {row}")
    require(scope in scopes, f"unknown scope {scope}")
    require((ns == "nativeUiMap" and value != 0) or
            (ns in ("instanceMap","worldMap") and value >= 0) or
            (ns not in ("nativeUiMap","instanceMap","worldMap") and value > 0),
            f"invalid identifier value {row}")
    require((ns == "upstreamUiMap") == (scopes[scope] == "content"), f"scope/namespace mismatch {row}")


def validate_view(view, identities, scopes, tables=None):
    entities = view["entities"]
    for key, entity in entities.items():
        require(identities.get(key, {}).get("status") == "active", f"unallocated entity {key}")
        entity_check(key, entity)
    def target(key):
        require(key in entities, f"unknown entity reference {key}")
    graph = {key: [] for key in entities}
    for key, entity in entities.items():
        if "parent" in entity:
            target(entity["parent"])
            graph[key].append(entity["parent"])
    edges = set()
    for row in view.get("relations", []):
        src, relation, dest = row["from"], row["relation"], row["to"]
        target(src); target(dest)
        require(src != dest and relation in REL, f"invalid relation {row}")
        key = (min(src,dest), relation, max(src,dest)) if relation == "associatedWith" else (src,relation,dest)
        require(key not in edges, f"duplicate relation {row}")
        edges.add(key)
        if relation == "within":
            require(dest not in graph[src], f"duplicate containment {row}")
            graph[src].append(dest)
    visiting, finished = set(), set()
    def visit(node):
        require(node not in visiting, f"containment cycle at {node}")
        if node in finished:
            return
        visiting.add(node)
        for parent in graph[node]:
            visit(parent)
        visiting.remove(node)
        finished.add(node)
    for node in graph:
        visit(node)
    bindings = {}
    for row in view.get("bindings", []):
        check_id(row, scopes)
        target(row["location"])
        key = key_of(row)
        require(key not in bindings, f"duplicate/conflicting identifier {key}")
        require(row["namespace"] != "worldMap", "worldMap is representation-only")
        if tables and row["scope"] in tables:
            ns, value = row["namespace"], row["value"]
            source_table = TABLE.get(ns)
            if ns == "nativeUiMap":
                source_table, value = ("AreaTable",value) if value > 0 else ("WorldMapArea",-value)
            if source_table:
                require(value in tables[row["scope"]][source_table], f"binding missing native source row {key}")
                if ns == "instanceMap":
                    require(tables[row["scope"]]["Map"][value]["instanceType"] in (1,2,3,4),
                            f"non-instance Map.dbc binding {key}")
        bindings[key] = row["location"]
    maps = {}
    for row in view.get("mapRepresentations", []):
        check_id(row, scopes)
        target(row["subject"])
        require(row["namespace"] in ("upstreamUiMap","nativeUiMap","worldMapArea","worldMap","instanceMap"),
                f"not a map namespace {row}")
        key = key_of(row)
        require(key not in maps, f"duplicate map representation {key}")
        if tables and row["scope"] in tables:
            ns, value = row["namespace"], row["value"]
            source_table = TABLE.get(ns)
            if ns == "nativeUiMap":
                source_table,value = ("AreaTable",value) if value > 0 else ("WorldMapArea",-value)
            if source_table:
                require(value in tables[row["scope"]][source_table], f"representation missing source row {key}")
        if key in bindings:
            require(bindings[key] == row["subject"], f"map subject conflicts with identity binding {key}")
        maps[key] = row["subject"]
    coverage = set()
    for row in view.get("mapCoverage", []):
        target(row["location"])
        key = key_of(row["map"])
        require(key in maps, f"coverage references missing map {key}")
        pair = row["location"], key
        require(pair not in coverage, f"duplicate map coverage {pair}")
        coverage.add(pair)
    for key, status in view.get("availability", {}).items():
        target(key)
        require(status in ("present","absent","unknown"), f"invalid availability {key}")
    return bindings


def effective(base, overlay):
    view = deepcopy(base)
    allowed = {"add","patch","removeBindings","addBindings","removeRelations","addRelations",
               "removeMapRepresentations","addMapRepresentations","removeMapCoverage","addMapCoverage","availability"}
    require(not set(overlay)-allowed, "unknown overlay operation")
    for key, entity in overlay.get("add", {}).items():
        require(key not in view["entities"], f"overlay add already exists {key}")
        view["entities"][key] = deepcopy(entity)
    for key, patch in overlay.get("patch", {}).items():
        require(key in view["entities"], f"overlay patch missing entity {key}")
        require(not set(patch)-{"set","clear"}, f"invalid patch {key}")
        fields, clear = patch.get("set",{}), patch.get("clear",[])
        require(not set(fields)&set(clear), f"patch set/clear overlap {key}")
        for field in clear:
            require(field in ("parent","aliases","names"), f"cannot clear {field}")
            view["entities"][key].pop(field,None)
        view["entities"][key].update(deepcopy(fields))
    for field in ("bindings","relations","mapRepresentations","mapCoverage"):
        title = field[0].upper()+field[1:]
        rows = view.setdefault(field,[])
        for row in overlay.get("remove"+title,[]):
            require(row in rows, f"overlay removal missing exact row {row}")
            rows.remove(row)
        rows.extend(deepcopy(overlay.get("add"+title,[])))
    view.setdefault("availability",{}).update(overlay.get("availability",{}))
    return view


def source_report(tables, dispositions, identities):
    """Exactly one reviewed disposition per known row, or an explicit unreviewed hold."""
    index = {}
    for row in dispositions:
        key = row["scope"], row["table"], row["id"]
        require(key not in index, f"duplicate source disposition {key}")
        require(row.get("status") in ("mapped","representation","excluded","held"), f"invalid source disposition {key}")
        require(isinstance(row.get("reason"),str) and row["reason"].strip(), f"missing source reason {key}")
        if row["status"] == "mapped":
            require(identities.get(row.get("location"),{}).get("status") == "active", f"unallocated source mapping {key}")
        index[key] = row
    report = []
    for scope, source in sorted(tables.items()):
        for name, rows in sorted(source.items()):
            for ident in sorted(rows):
                key = scope,name,ident
                report.append(index.pop(key,dict(scope=scope,table=name,id=ident,status="held",
                                                 reason="unreviewed source row")))
    require(not index, f"disposition refers to nonexistent source rows {list(index)[:5]}")
    return report


def content_key(ref):
    scope = ref["sourceScope"]
    require(isinstance(scope,str) and scope.strip(), "content reference lacks source scope")
    return scope, ref["namespace"], ref["value"], ref.get("area")


def content_report(refs, crosswalk, identities):
    index = {}
    for row in crosswalk:
        key = content_key(row)
        require(key not in index, f"duplicate crosswalk {key}")
        require(row.get("status") in ("mapped","held"), f"invalid crosswalk {key}")
        require(isinstance(row.get("reason"),str) and row["reason"].strip(), f"missing crosswalk evidence {key}")
        if row["status"] == "mapped":
            require(identities.get(row.get("location"),{}).get("status") == "active", f"unallocated content target {key}")
        index[key] = row
    report = []
    for ref in refs:
        row = index.get(content_key(ref), {"status":"held","reason":"no reviewed crosswalk"})
        report.append(dict(ref, **{k:row[k] for k in ("status","reason","location") if k in row}))
    return report


def lua(value):
    """Deterministic Lua 5.0 literal serializer. Use decimal byte escapes."""
    if isinstance(value,str):
        return '"' + "".join(chr(b) if 32 <= b < 127 and b not in (34,92)
                             else "\\%03d" % b for b in value.encode("utf-8")) + '"'
    if type(value) is bool:
        return "true" if value else "false"
    if type(value) is int:
        return str(value)
    if isinstance(value,list):
        return "{" + ",".join(lua(x) for x in value) + "}"
    if isinstance(value,dict):
        return "{" + ",".join("["+lua(k)+"]="+lua(value[k]) for k in sorted(value)) + "}"
    raise ValueError(f"unsupported runtime literal {value!r}")


def canonicalize(view):
    out = deepcopy(view)
    for field in ("bindings","relations","mapRepresentations","mapCoverage"):
        if field in out:
            out[field].sort(key=lambda row: json.dumps(row,sort_keys=True,ensure_ascii=True))
    return out


def build(manifest, decisions, root, output, pack=None, previous=None, inventory_only=False):
    refs = inventory(root,pack)
    output = Path(output).resolve()
    addon = (Path(root)/"SoftSpoken").resolve()
    require(output != addon and addon not in output.parents, "staging output must be outside the addon")
    output.mkdir(parents=True, exist_ok=True)
    def dump(name, data):
        (output/name).write_text(json.dumps(data, indent=2, sort_keys=True, ensure_ascii=False)+"\n",encoding="utf-8")
    if inventory_only:
        dump("content-inventory.json",refs)
        return {"references":len(refs["references"]),"questSortsExcluded":len(refs["questSortsExcluded"])}
    tables = load_sources(manifest,root)
    require(tables, "no verified effective DBC profiles; use --inventory-only")
    scopes = dict.fromkeys(tables,"native")
    for key, record in manifest.get("contentScopes",{}).items():
        require(key not in scopes and record.get("revision") and record.get("provenance"), f"invalid content scope {key}")
        scopes[key] = "content"
    identities = decisions["identities"]
    identity_manifest(identities,previous)
    base = decisions["base"]
    validate_view(base,identities,scopes,tables)
    views = {}
    for profile, source in sorted(manifest["profiles"].items()):
        view = effective(base,decisions.get("worldOverlays",{}).get(source["world"],{}))
        view = effective(view,decisions.get("profileOverlays",{}).get(profile,{}))
        # Only selected native profile and pinned content namespaces are usable.
        for field in ("bindings","mapRepresentations"):
            view[field] = [r for r in view.get(field,[]) if r["scope"] == profile or scopes.get(r["scope"]) == "content"]
        view["mapCoverage"] = [r for r in view.get("mapCoverage",[]) if r["map"]["scope"] == profile or scopes.get(r["map"]["scope"]) == "content"]
        validate_view(view,identities,scopes,tables)
        views[profile] = view
    source = source_report(tables,decisions.get("sourceDispositions",[]),identities)
    content = content_report(refs["references"],decisions.get("contentCrosswalk",[]),identities)
    # Candidate research inventory: do not propose a canonical ID from a name
    # or assume that raw AreaTable parent IDs imply canonical containment.
    candidates = []
    for row in source:
        if row["status"] != "held":
            continue
        record = tables[row["scope"]][row["table"]][row["id"]]
        candidates.append(dict(row, evidence=record))
    dump("review-candidates.json", candidates)
    report = {"sourceCounts":dict(Counter(r["status"] for r in source)),
              "contentCounts":dict(Counter(r["status"] for r in content)),
              "sources":source,"content":content,"questSortsExcluded":refs["questSortsExcluded"]}
    dump("coverage.json",report)
    dump("normalized-sources.json",{p:{t:list(rows.values()) for t,rows in sorted(ts.items())} for p,ts in sorted(tables.items())})
    # Staging only. Never writes into SoftSpoken or modifies the TOC.
    payload = {"schemaVersion":1,"base":canonicalize(base),
               "worldOverlays":decisions.get("worldOverlays",{}),
               "profileOverlays":decisions.get("profileOverlays",{}),
               "profiles":{p:{"world":s["world"]} for p,s in sorted(manifest["profiles"].items())},
               "redirects":{k:v["redirect"] for k,v in identities.items() if "redirect" in v},
               "splits":{k:sorted(v["split"]) for k,v in identities.items() if "split" in v}}
    # Independent content bindings: no prose, artwork or audio embedded in locations.
    mapped = [{k:row[k] for k in ("sourceScope","namespace","value","area","location") if k in row}
              for row in decisions.get("contentCrosswalk",[]) if row["status"] == "mapped"]
    mapped.sort(key=lambda row: json.dumps(row,sort_keys=True,ensure_ascii=True))
    (output/"ContentBindings.generated.lua").write_text(
        "-- Generated staging content crosswalk; not loaded by the addon.\nSoftSpokenLocationContentBindings = "+lua(mapped)+"\n",encoding="utf-8")
    (output/"Locations.generated.lua").write_text("-- Generated staging data; not loaded by the addon.\nSoftSpokenLocationData = "+lua(payload)+"\n",encoding="utf-8")
    return {k:report[k] for k in ("sourceCounts","contentCounts")}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root",type=Path,default=Path(__file__).resolve().parents[2])
    parser.add_argument("--manifest",type=Path)
    parser.add_argument("--decisions",type=Path)
    parser.add_argument("--previous-identities",type=Path)
    parser.add_argument("--voice-pack",type=Path)
    parser.add_argument("--output",type=Path,required=True)
    parser.add_argument("--inventory-only",action="store_true")
    args = parser.parse_args()
    if not args.inventory_only and (not args.manifest or not args.decisions):
        parser.error("--manifest and --decisions required for catalog generation")
    try:
        result = build(read_json(args.manifest) if args.manifest else {},
                       read_json(args.decisions) if args.decisions else {},
                       args.root,args.output,args.voice_pack,
                       read_json(args.previous_identities) if args.previous_identities else None,
                       args.inventory_only)
    except (ValueError,KeyError,TypeError,OSError) as exc:
        parser.exit(1,f"location build failed: {exc}\n")
    print(json.dumps(result,sort_keys=True))


if __name__ == "__main__":
    main()
