"""L4/L5: finalize a private Octo staging catalog; never publish or load it."""
import argparse
from collections import Counter, defaultdict
from copy import deepcopy
import hashlib
import json
from pathlib import Path
import zipfile

from bootstrap_octo import EXPECTED, PROFILE, norm
from build import (canonicalize, content_key, effective, identity_manifest, lua,
                   require, source_report, validate_view)
from dbc import read_dbc

FOREVER = {2482, 2521, 2524, 2548, 2652}
# The legacy Hillsbrad map included these exact Alterac names. Scope only
# the content lookup: do not reparent native Alterac locations to Hillsbrad.
HILLSBRAD = {"alterac mountains":36, "chillwind point":1684,
    "corrahns dagger":1679, "crushridge hold":282, "dandreds fold":1682,
    "gallows corner":1357, "gavins naze":1677, "growless cave":1683,
    "headland":1680, "lordamere lake":1339, "misty shore":1681,
    "ravenholdt manor":3486, "ruins of alterac":281, "slaughter hollow":283,
    "soferas naze":1678, "strahnbrad":280, "uplands":284}


def excluded(ref):
    return (ref["sourceScope"] == "spoken_classic" and
            ref["namespace"] in ("legacyPlace", "upstreamUiMap") and
            ref["value"] in FOREVER)


def finalize(decisions, tables, refs):
    d = deepcopy(decisions)
    require(set(d["profileOverlays"]) == {PROFILE}, "unexpected profile")
    overlay = d["profileOverlays"][PROFILE]
    view = effective(effective(d["base"], d["worldOverlays"]["octo"]), overlay)
    area = tables["AreaTable"]
    index = {r["value"]: r["location"] for r in view["bindings"]
             if r["scope"] == PROFILE and r["namespace"] == "areaTable"}
    wma = {r["value"]: r["subject"] for r in view["mapRepresentations"]
           if r["scope"] == PROFILE and r["namespace"] == "worldMapArea"}
    require(not any(r["namespace"] == "nativeUiMap" for r in view["bindings"]),
            "use the reviewed pre-L5 manifest, not an already finalized output")
    subjects = defaultdict(set)
    rows = defaultdict(list)
    holds = []
    for wid, row in sorted(tables["WorldMapArea"].items()):
        aid = row["areaTable"]
        # ClassicAPI UiMapIDForRow emits +AreaTableID or -rowID for zero-area rows.
        value = aid if aid else -wid
        if wid not in wma:
            holds.append(dict(value=value, row=wid, reason="unresolved WorldMapArea subject"))
            continue
        subjects[value].add(wma[wid]); rows[value].append(wid)
    for value, candidates in sorted(subjects.items()):
        if len(candidates) != 1 or (value > 0 and index.get(value) not in candidates):
            holds.append(dict(value=value, rows=rows[value], reason="map/area identity conflict"))
            continue
        key = next(iter(candidates))
        overlay["addBindings"].append(dict(scope=PROFILE,namespace="nativeUiMap",value=value,location=key))
        overlay["addMapRepresentations"].append(dict(scope=PROFILE,namespace="nativeUiMap",value=value,subject=key))
    cross = {content_key(r): r for r in d["contentCrosswalk"]}
    require(not any(excluded(r) for r in cross.values()), "unsupported map in crosswalk")
    present = {content_key(r) for r in refs}
    repairs = []
    for name, aid in sorted(HILLSBRAD.items()):
        key = ("spoken_classic", "legacyPlace", 1424, name)
        if key not in present or key in cross:
            continue
        row = area[aid]
        require(row["worldMap"] == 0 and (aid == 36 or row["parentArea"] == 36)
                and norm(row["names"]["enUS"]) == norm(name) and aid in index,
                f"Alterac evidence changed: {aid}")
        entry = dict(sourceScope=key[0],namespace=key[1],value=key[2],area=name,
                     status="mapped",location=index[aid],
                     reason=f"reviewed legacy Hillsbrad grouping; native Alterac AreaTable {aid}")
        d["contentCrosswalk"].append(entry); cross[key] = entry; repairs.append(entry)
    identity_manifest(d["identities"], decisions["identities"])
    view = effective(effective(d["base"], d["worldOverlays"]["octo"]), overlay)
    require(not any(r["scope"] == "spoken_classic" and r["value"] in FOREVER
                    for r in view["bindings"]), "unsupported map binding")
    validate_view(view,d["identities"],{PROFILE:"native","spoken_classic":"content"},{PROFILE:tables})
    source = source_report({PROFILE:tables},d["sourceDispositions"],d["identities"])
    content = []
    for ref in refs:
        row = cross.get(content_key(ref), {"status":"held","reason":"no reviewed crosswalk"})
        if excluded(ref):
            row = {"status":"excluded","reason":"user policy: unsupported WoW Forever map"}
        # Input reports contain previous statuses: replace them, not accumulate them.
        clean = {k:v for k,v in ref.items() if k not in ("status","reason","location")}
        content.append(dict(clean, **{k:row[k] for k in ("status","reason","location") if k in row}))
    require(all(r["location"] in view["entities"] for r in content if r["status"]=="mapped"), "missing content target")
    report = dict(entities=len(view["entities"]), nativeMapBindings=sum(r["namespace"]=="nativeUiMap" for r in view["bindings"]),
                  nativeMapHolds=holds, legacyRepairs=repairs, contentCounts=dict(Counter(r["status"] for r in content)),
                  sourceCounts=dict(Counter(r["status"] for r in source)), sources=source, content=content)
    return d, report


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--review",type=Path,required=True,help="filtered review ZIP")
    parser.add_argument("--archive",type=Path,required=True,help="pinned native DBC ZIP")
    parser.add_argument("--output",type=Path,required=True)
    args=parser.parse_args()
    out=args.output.resolve()
    require(not any((parent/"SoftSpoken.toc").is_file() for parent in (out,*out.parents)),
            "stage outside the addon directory")
    out.mkdir(parents=True,exist_ok=True)
    require(not any(out.iterdir()),"use an empty private output directory")
    with zipfile.ZipFile(args.review) as z:
        seed=json.loads(z.read("decisions.octo.json")); manifest=json.loads(z.read("sources.octo.json"))
        refs=json.loads(z.read("coverage.json"))["content"]
    source = manifest["profiles"][PROFILE]
    require(source["rights"]=="private-staging","unexpected rights state")
    require({k:v["sha256"] for k,v in source["files"].items()} == EXPECTED, "review/source fingerprint mismatch")
    tables={}
    import tempfile
    with tempfile.TemporaryDirectory() as tmp, zipfile.ZipFile(args.archive) as z:
        for name, expected in EXPECTED.items():
            raw=z.read(name+".dbc")
            require(hashlib.sha256(raw).hexdigest()==expected,f"wrong source: {name}")
            path=Path(tmp)/(name+".dbc"); path.write_bytes(raw); tables[name]=read_dbc(path,name)
    d,report=finalize(seed,tables,refs)
    def dump(name,value):
        (out/name).write_text(json.dumps(value,sort_keys=True,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
    dump("decisions.octo.json",d); dump("sources.octo.json",manifest); dump("coverage.json",report)
    payload=dict(schemaVersion=1,base=canonicalize(d["base"]),worldOverlays=d["worldOverlays"],
                 profileOverlays=d["profileOverlays"],profiles={PROFILE:dict(world="octo",fingerprint=EXPECTED)},
                 redirects={k:r["redirect"] for k,r in d["identities"].items() if "redirect" in r},
                 splits={k:r["split"] for k,r in d["identities"].items() if "split" in r})
    mapped=[{k:r[k] for k in ("sourceScope","namespace","value","area","location") if k in r}
            for r in d["contentCrosswalk"] if r["status"]=="mapped"]
    mapped.sort(key=lambda r:json.dumps(r,sort_keys=True))
    # These are private L6 development inputs, never automatic release output.
    (out/"Locations.generated.lua").write_text("-- PRIVATE STAGING ONLY; not for distribution\nSoftSpokenLocationData = "+lua(payload)+"\n",encoding="utf-8")
    (out/"ContentBindings.generated.lua").write_text("-- PRIVATE STAGING ONLY; not for distribution\nSoftSpokenLocationContentBindings = "+lua(mapped)+"\n",encoding="utf-8")
    print(json.dumps({k:v for k,v in report.items() if k not in ("content","sources","legacyRepairs")},sort_keys=True))


if __name__ == "__main__": main()
