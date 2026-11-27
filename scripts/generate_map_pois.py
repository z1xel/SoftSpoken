#!/usr/bin/env python3
"""M3/M4: offline Vanilla 5875 DBC -> Places POI positions, no runtime activation."""
import argparse, collections, csv, hashlib, json, math, re, string, struct
from pathlib import Path

FIELDS = {'AreaPOI': 29, 'AreaTable': 25, 'WorldMapArea': 8, 'WorldMapOverlay': 17}
CITY_IN = {1453:1429,1454:1411,1455:1426,1456:1412,1457:1438,1458:1420}

def norm(s):
    s = s.lower().replace("'", '')
    s = ' '.join(s.translate(str.maketrans({c:' ' for c in string.punctuation})).split())
    return s[4:] if s.startswith('the ') else s

# Texture stems are compared without punctuation, whitespace, or leading "the".
OVERLAY_ALIASES = {'ravenhillcemetary':'ravenhillcemetery', 'thelganrock':'thelgenrock'}

def texture_key(s):
    return re.sub(r'[^a-z0-9]', '', norm(s))

def overlay_owner(texture, ids, areas):
    ids = sorted(set(ids) - {0})
    stem = texture_key(texture)
    if stem == 'monastary': return None
    if len(ids) == 1: return ids[0] if ids[0] in areas else None
    stem = OVERLAY_ALIASES.get(stem, stem)
    matches = [aid for aid in ids if aid in areas and texture_key(areas[aid][2]) == stem]
    if not matches and stem.startswith('the'):
        matches = [aid for aid in ids if aid in areas and texture_key(areas[aid][2]) == stem[3:]]
    return matches[0] if len(matches) == 1 else None

def dbc(path, fields):
    b = path.read_bytes()
    magic, n, k, size, strings = struct.unpack_from('<4s4I', b)
    if magic != b'WDBC' or k != fields or size != 4*k or len(b) != 20+n*size+strings:
        raise ValueError(f'Unexpected DBC layout: {path}')
    block = b[20+n*size:]
    def name(offset):
        if offset >= len(block): raise ValueError(f'Bad string offset: {path}: {offset}')
        return block[offset:block.index(b'\0',offset)].decode('utf-8')
    return list(struct.iter_unpack('<'+'I'*k,b[20:20+n*size])), name, hashlib.sha256(b).hexdigest()

def f(i): return struct.unpack('<f', struct.pack('<I', i))[0]

def read_catalog(root):
    z = (root/'SoftSpoken_Places/Data/Zones.lua').read_text(encoding='utf-8')
    s = (root/'SoftSpoken_Places/Data/Subzones.lua').read_text(encoding='utf-8')
    zones = {}; mid = None
    for line in z.splitlines():
        m = re.match(r'^\s*\[(\d+)\]\s*=\s*\{',line)
        if m: mid=int(m[1])
        m = re.match(r'^\s*name\s*=\s*"([^"]+)"',line)
        if m and mid is not None: zones[mid]=m[1]; mid=None
    subs = {}; mid = None
    for line in s.splitlines():
        m = re.match(r'^\s*\[(\d+)\]\s*=\s*\{',line)
        if m: mid=int(m[1]); subs[mid]=set()
        m = re.match(r'^\s*\["([^"]+)"\]\s*=\s*\{',line)
        if m and mid is not None: subs[mid].add(m[1])
    if not zones or not subs or not set(subs)<=set(zones): raise ValueError('Catalog parse failed')
    return zones, subs

def xy(p, m):
    left,right,top,bottom=map(f,m[4:8]); wx,wy=map(f,p[4:6])
    if not all(map(math.isfinite,(left,right,top,bottom,wx,wy))) or left==right or top==bottom: return None
    x,y=(wy-left)/(right-left),(wx-top)/(bottom-top)
    return (x,y) if 0<=x<=1 and 0<=y<=1 else None

def build(dbc_dir,zones,subs):
    data={n:dbc(dbc_dir/(n+'.dbc'),k) for n,k in FIELDS.items()}
    pois,pname,_=data['AreaPOI']; ars,aname,_=data['AreaTable']; maps,_,_=data['WorldMapArea']; overlays,oname,_=data['WorldMapOverlay']
    if len({a[0] for a in ars})!=len(ars) or len({m[0] for m in maps})!=len(maps): raise ValueError('Duplicate area/map ID')
    areas={a[0]:(a[1],a[2],aname(a[11])) for a in ars}
    def ancestry(a):
        seen=set()
        while a in areas and a not in seen:
            seen.add(a); a=areas[a][1]
        return seen
    zone_names=collections.defaultdict(list)
    for mid,n in zones.items(): zone_names[norm(n)].append(mid)
    map_bind={}; ambiguous_maps=[]
    for m in maps:
        a=areas.get(m[2]); choices=zone_names.get(norm(a[2]),[]) if a and a[0]==m[1] else []
        if len(choices)==1 and choices[0] not in (947,1414,1415): map_bind[m[0]]=choices[0]
        elif len(choices)>1: ambiguous_maps.append(m[0])
    # Multiple client map records for one lore map are not interchangeable.
    counts=collections.Counter(map_bind.values()); map_bind={k:v for k,v in map_bind.items() if counts[v]==1}
    def target(mid,key):
        if key in subs.get(mid,set()): return ('subzone',key)
        city=[c for c,parent in CITY_IN.items() if parent==mid and norm(zones.get(c,''))==key]
        if len(city)==1: return ('city',str(city[0]))
        return None
    audit=[]; positions=[]; seen=set(); poi_ids=collections.Counter(p[0] for p in pois)
    for i,p in enumerate(pois):
        name=pname(p[10]); key=norm(name); candidates=[]; named=[]; reason=''
        if not key: reason='empty_name'
        elif not p[8]&4: reason='no_zone_map_flag'
        elif p[28]: reason='dynamic_world_state'
        elif poi_ids[p[0]]>1: reason='duplicate_native_id_review'
        else:
            for m in maps:
                mid=map_bind.get(m[0]); t=target(mid,key) if mid and m[1]==p[7] else None
                if not t: continue
                named.append(m[0]); pos=xy(p,m)
                if pos: candidates.append((m,mid,t,pos))
            if len(candidates)>1:
                linked=[c for c in candidates if c[0][2] in ancestry(p[9])]
                if len(linked)==1: candidates=linked
            if not candidates: reason='outside_matching_map' if named else 'no_catalog_match'
            elif len(candidates)>1: reason='ambiguous_map'
            else:
                m,mid,t,(x,y)=candidates[0]; kind,k=t
                sig=(mid,kind,k,x,y)
                if sig in seen: reason='identical_position'
                else:
                    seen.add(sig);positions.append(dict(map_id=mid,kind=kind,key=k,x=x,y=y,poi_id=p[0],world_map_area=m[0]));reason='included'
        audit.append(dict(row=i+1,poi_id=p[0],name=name,importance=p[1],icon=p[2],faction=p[3],world_x=f(p[4]),world_y=f(p[5]),world_z=f(p[6]),world_map=p[7],flags=p[8],area_id=p[9],world_state=p[28],duplicate_id_count=poi_ids[p[0]],status=reason,candidates=';'.join(str(c[0][0]) for c in candidates),named_maps=';'.join(map(str,named))))
    overlay_targets=set()
    ownership=[]
    for o in overlays:
        mid=map_bind.get(o[1]); texture=oname(o[8]); ids=sorted(set(o[2:6]) - {0})
        owner=overlay_owner(texture, ids, areas)
        if len(ids)>1:
            ownership.append(dict(overlay_id=o[0],map_id=mid or '',texture=texture,area_ids=','.join(map(str,ids)),owner_id=owner or 0,owner_name=areas[owner][2] if owner else ''))
        if not mid or not texture or not (o[15]>o[13] and o[16]>o[14]) or not owner: continue
        t=target(mid,norm(areas[owner][2]))
        if t:
            kind,k=t;overlay_targets.add((mid,kind,k))
    independent_overlay_targets=overlay_targets
    poi_targets={(p['map_id'],p['kind'],p['key']) for p in positions}
    catalog={(mid,'subzone',key) for mid,keys in subs.items() for key in keys}|{(parent,'city',str(city)) for city,parent in CITY_IN.items() if city in zones}
    coverage=[]
    for mid,kind,k in sorted(catalog):
        a=(mid,kind,k) in overlay_targets;b=(mid,kind,k) in poi_targets
        coverage.append(dict(map_id=mid,zone=zones[mid],kind=kind,key=k,geometry='both' if a and b else 'overlay_only' if a else 'poi_only' if b else 'neither'))
    for p in positions:
        identity=(p['map_id'],p['kind'],p['key'])
        p['runtime_status']='covered_by_overlay' if identity in independent_overlay_targets else 'runtime_poi'
    position_status={p['poi_id']:p['runtime_status'] for p in positions}
    for record in audit:
        record['runtime_status']=position_status.get(record['poi_id'],'') if record['status']=='included' else ''
    for row in coverage:
        identity=(row['map_id'],row['kind'],row['key'])
        row['runtime_poi']=identity in poi_targets and identity not in independent_overlay_targets
    positions.sort(key=lambda p:(p['map_id'],p['kind'],p['key'],p['poi_id']))
    return positions,audit,coverage,{n:d[2] for n,d in data.items()},map_bind,ownership

def write_outputs(out,positions,audit,coverage,hashes,map_bind,ownership):
    out.mkdir(parents=True,exist_ok=True)
    for name,rows in [('poi_records',audit),('poi_positions',positions),('coverage',coverage),('overlay_ownership',ownership)]:
        with (out/(name+'.csv')).open('w',encoding='utf-8',newline='') as h:
            writer=csv.DictWriter(h,fieldnames=list(rows[0]));writer.writeheader();writer.writerows(rows)
    # Deliberately not loaded by a TOC until M5/M6.
    lines=['-- Generated by scripts/generate_map_pois.py; M3/M4 staging only.', '-- OctoWoW DBC-derived positions; no runtime activation.', 'SSZMapPOIData = {']
    runtime_positions=[p for p in positions if p['runtime_status']=='runtime_poi']
    for mid,group in __import__('itertools').groupby(runtime_positions,key=lambda p:p['map_id']):
        lines.append(f'    [{mid}] = {{')
        for p in group:
            k=json.dumps(p['key'],ensure_ascii=False) if p['kind']=='subzone' else p['key']
            lines.append(f'        {{kind="{p["kind"]}", id={k}, x={p["x"]:.9f}, y={p["y"]:.9f}, poi={p["poi_id"]}}},')
        lines.append('    },')
    lines.append('}')
    (out/'MapPOIs.lua').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    # Shared sets are unique in the audited DBC. Do not emit conflicting signatures.
    signatures=collections.defaultdict(list)
    for row in ownership: signatures[row['area_ids']].append(row)
    lines=['-- Generated by scripts/generate_map_pois.py; shared overlay ownership.', 'SSZOverlayOwners = {']
    for sig,rows in sorted(signatures.items()):
        if len(rows)!=1: continue
        row=rows[0]
        lines.append(f'    ["{sig}"] = {{texture="{texture_key(row["texture"])}", owner={row["owner_id"]}}},')
    lines.append('}')
    (out/'OverlayOwners.lua').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    summary={'input_sha256' :hashes,'record_status':dict(collections.Counter(r['status'] for r in audit)),'coverage':dict(collections.Counter(r['geometry'] for r in coverage)),'map_bindings':map_bind,'positions':len(positions),'by_map':{str(m):dict(collections.Counter(r['geometry'] for r in coverage if r['map_id']==m)) for m in sorted({r['map_id'] for r in coverage})}}
    summary['shared_overlays']=len(ownership)
    summary['resolved_shared_overlays']=sum(bool(r['owner_id']) for r in ownership)
    summary['runtime_positions']=len(runtime_positions)
    summary['runtime_associations']=len({(p['map_id'],p['kind'],p['key']) for p in runtime_positions})
    summary['runtime_status']=dict(collections.Counter(p['runtime_status'] for p in positions))
    (out/'summary.json').write_text(json.dumps(summary,indent=2,sort_keys=True)+'\n',encoding='utf-8')
    return summary

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--dbc-dir',type=Path,required=True);p.add_argument('--repo',type=Path,default=Path('.'));p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    z,s=read_catalog(a.repo);print(json.dumps(write_outputs(a.out,*build(a.dbc_dir,z,s)),indent=2))

if __name__=='__main__': main()
