#!/usr/bin/env python3
"""M4: regenerate staged Places POI data from Octo Vanilla-layout DBCs."""
import argparse, collections, csv, hashlib, itertools, json, math, re, string, struct
from pathlib import Path

FIELDS = {'AreaPOI': 29, 'AreaTable': 25, 'WorldMapArea': 8, 'WorldMapOverlay': 17}
CITY_IN = {1453:1429,1454:1411,1455:1426,1456:1412,1457:1438,1458:1420}
# Exact, map-scoped spelling aliases. Semantic alternatives remain held.
ALIASES = {(1421,'ivars patch'):'ivar patch', (1444,'lariss pavillion'):'lariss pavilion',
           (1441,'rustmaul digsite'):'rustmaul dig site'}
ALIAS_REVIEW = {'boulderfist outpost','silver covenant park','venture camp'}

def norm(s):
    s = ' '.join(s.lower().replace("'", '').translate(str.maketrans({c:' ' for c in string.punctuation})).split())
    return s[4:] if s.startswith('the ') else s

def texture_key(s): return re.sub(r'[^a-z0-9]', '', norm(s))

def dbc(path, fields):
    b = path.read_bytes(); magic,n,k,size,strings=struct.unpack_from('<4s4I',b)
    if magic != b'WDBC' or k != fields or size != 4*k or len(b)!=20+n*size+strings:
        raise ValueError(f'Unexpected DBC layout: {path}')
    block=b[20+n*size:]
    def name(offset):
        if offset>=len(block): raise ValueError(f'Bad string offset: {path}: {offset}')
        return block[offset:block.index(b'\0',offset)].decode('utf-8')
    return list(struct.iter_unpack('<'+'I'*k,b[20:20+n*size])),name,hashlib.sha256(b).hexdigest()

def f(i): return struct.unpack('<f',struct.pack('<I',i))[0]

def read_catalog(root,branch):
    p=root/('SoftSpoken_Places' if branch=='main' else 'SoftSpoken/Modules/Places')/'Data'
    z=(p/'Zones.lua').read_text(encoding='utf-8');s=(p/'Subzones.lua').read_text(encoding='utf-8')
    zones={};subs={};pending=set();mid=None;key=None
    for l in z.splitlines():
        m=re.match(r'^\t\[(\d+)\] = \{',l)
        if m: mid=int(m[1]);continue
        if mid is not None and l=='\t\tpending = true,': pending.add((mid,'zone',''))
        m=re.match(r'^\t\tname = "([^"]+)"',l)
        if m and mid is not None: zones[mid]=m[1];mid=None
    for l in s.splitlines():
        m=re.match(r'^\t\[(\d+)\] = \{',l)
        if m: mid=int(m[1]);subs[mid]=set();key=None;continue
        m=re.match(r'^\t\t\["([^"]+)"\] = \{',l)
        if m: key=m[1];subs[mid].add(key);continue
        if key is not None and l=='\t\t\tpending = true,': pending.add((mid,'subzone',key))
    if not zones or not subs or not set(subs)<=set(zones): raise ValueError('Catalog parse failed')
    review=json.loads((root/'docs/places-catalog-expansion.json').read_text(encoding='utf-8'))
    roots={r['mid']:r['aid'] for r in review['roots']}
    holds={(r['mid'],'subzone',r['key']) for r in review['subzones'] if 'poi' in r and not r.get('aid')}
    owners={tuple(map(int,m[1].split(','))):(m[2],int(m[3])) for m in re.finditer(r'\["([\d,]+)"\]\s*=\s*\{texture="([^"]+)", owner=(\d+)\}',(p/'OverlayOwners.lua').read_text(encoding='utf-8'))}
    if not owners: raise ValueError('No reviewed overlay ownership loaded')
    canonical=collections.defaultdict(set)
    if branch=='dev':
        data=(root/'SoftSpoken/Locations/Data.lua').read_text(encoding='utf-8')
        exp=(root/'SoftSpoken/Locations/PlacesCatalogExpansion.lua').read_text(encoding='utf-8')
        for k,i,m in re.findall(r'\["area"\]="([^"]*)",\["location"\]="([^"]+)",\["namespace"\]="legacyPlace",\["sourceScope"\]="spoken_classic",\["value"\]=(\d+)',data): canonical[(int(m),k)].add(i)
        for i,m,k in re.findall(r'^addContent\("([^"]+)", (\d+), "([^"]*)"\)',exp,re.M): canonical[(int(m),k)].add(i)
        for i,m in re.findall(r'^addMap\("([^"]+)", (\d+)\)',exp,re.M): canonical[(int(m),'')].add(i)
    return zones,subs,pending,roots,holds,owners,canonical

def xy(p,m):
    left,right,top,bottom=map(f,m[4:8]);wx,wy=map(f,p[4:6])
    if not all(map(math.isfinite,(left,right,top,bottom,wx,wy))) or left==right or top==bottom: return None
    x,y=(wy-left)/(right-left),(wx-top)/(bottom-top)
    return (x,y) if 0<=x<=1 and 0<=y<=1 else None

def build(dbc_dir,zones,subs,pending,roots,holds,owners,canonical,branch):
    data={n:dbc(dbc_dir/(n+'.dbc'),k) for n,k in FIELDS.items()}
    pois,pname,_=data['AreaPOI'];ars,aname,_=data['AreaTable'];maps,_,_=data['WorldMapArea'];overlays,oname,_=data['WorldMapOverlay']
    if len({a[0] for a in ars})!=len(ars) or len({m[0] for m in maps})!=len(maps): raise ValueError('Duplicate area/map ID')
    areas={a[0]:(a[1],a[2],aname(a[11])) for a in ars}
    def ancestry(a):
        seen=set()
        while a in areas and a not in seen: seen.add(a);a=areas[a][1]
        return seen
    root_names=collections.defaultdict(list)
    for mid,n in zones.items():
        if mid not in roots and mid not in (947,1414,1415,2482,2521,2524,2548,2652): root_names[norm(n)].append(mid)
    root_ids=collections.defaultdict(list)
    for mid,aid in roots.items():
        if mid in zones: root_ids[aid].append(mid)
    map_bind={}
    for m in maps:
        a=areas.get(m[2]); choices=(root_ids.get(m[2]) or root_names.get(norm(a[2]),[])) if a and a[0]==m[1] else []
        if len(choices)==1 and f(m[4])!=f(m[5]) and f(m[6])!=f(m[7]): map_bind[m[0]]=choices[0]
    counts=collections.Counter(map_bind.values());map_bind={k:v for k,v in map_bind.items() if counts[v]==1}
    def target(mid,key,poi=False):
        if poi: key=ALIASES.get((mid,key),key)
        if key in subs.get(mid,set()): return ('subzone',key)
        cities=[c for c,parent in CITY_IN.items() if parent==mid and c in zones and (norm(zones[c])==key or (c==1453 and key=='stormwind'))]
        if len(cities)==1: return ('city',str(cities[0]))
        return None
    # Use committed ownership, not a fresh inference from membership or texture names.
    overlay_targets=set();ownership=[]
    for o in overlays:
        mid=map_bind.get(o[1]);texture=oname(o[8]);ids=tuple(sorted(set(o[2:6])-{0}));owner=0
        if len(ids)==1: owner=ids[0]
        elif len(ids)>1:
            reviewed=owners.get(ids)
            if reviewed and reviewed[0]==texture_key(texture): owner=reviewed[1]
            if owner and owner not in ids: raise ValueError('Invalid reviewed overlay owner')
            ownership.append(dict(overlay_id=o[0],map_id=mid or '',texture=texture,area_ids=','.join(map(str,ids)),owner_id=owner,owner_name=areas.get(owner,(0,0,''))[2]))
        if not mid or not texture or not(o[15]>o[13] and o[16]>o[14]) or owner not in areas: continue
        t=target(mid,norm(areas[owner][2]));
        if t: overlay_targets.add((mid,*t))
    def canon(mid,kind,k):
        if branch!='dev': return ''
        ids=canonical.get((int(k),'') if kind=='city' else (mid,k),set())
        return next(iter(ids)) if len(ids)==1 else ''
    audit=[];positions=[];seen=set();poi_ids=collections.Counter(p[0] for p in pois);worlds={m[1] for m in maps if m[0] in map_bind}
    for i,p in enumerate(pois):
        name=pname(p[10]);key=norm(name);candidates=[];named=[];reason='';status='';binding=None
        if not key: reason='empty_name'
        elif not p[8]&4: reason='no_zone_map_flag'
        elif p[28]: reason='dynamic_world_state'
        elif poi_ids[p[0]]>1: reason='duplicate_native_id_review'
        elif p[7] not in worlds: reason='unsupported_world_map'
        elif key in ALIAS_REVIEW: reason='semantic_alias_review'
        else:
            for m in maps:
                mid=map_bind.get(m[0]);t=target(mid,key,True) if mid and m[1]==p[7] else None
                if not t: continue
                named.append(m[0]);pos=xy(p,m)
                if pos: candidates.append((m,mid,t,pos))
            if len(candidates)>1:
                linked=[c for c in candidates if c[0][2] in ancestry(p[9])]
                if len(linked)==1: candidates=linked
            if not candidates: reason='outside_matching_map' if named else 'no_catalog_match'
            elif len(candidates)>1: reason='ambiguous_map'
            else:
                m,mid,(kind,k),(x,y)=candidates[0]; identity=(mid,kind,k);sig=(*identity,x,y);binding=identity
                if sig in seen: reason='identical_position'
                else:
                    seen.add(sig);reason='included';cid=canon(*identity)
                    if identity in overlay_targets: status='covered_by_overlay'
                    elif identity in holds: status='hold_independent_discovery'
                    elif branch=='dev' and not cid: status='hold_canonical_binding'
                    else: status='runtime_poi'
                    is_pending=(int(k),'zone','') in pending if kind=='city' else identity in pending
                    positions.append(dict(map_id=mid,kind=kind,key=k,x=x,y=y,poi_id=p[0],world_map_area=m[0],canonical=cid,pending=is_pending,runtime_status=status))
        audit.append(dict(row=i+1,poi_id=p[0],name=name,importance=p[1],icon=p[2],faction=p[3],world_x=f(p[4]),world_y=f(p[5]),world_z=f(p[6]),world_map=p[7],flags=p[8],area_id=p[9],world_state=p[28],duplicate_id_count=poi_ids[p[0]],status=reason,runtime_status=status,binding='|'.join(map(str,binding)) if binding else '',candidates=';'.join(str(c[0][0]) for c in candidates),named_maps=';'.join(map(str,named))))
    poi_targets={(p['map_id'],p['kind'],p['key']) for p in positions};runtime_targets={(p['map_id'],p['kind'],p['key']) for p in positions if p['runtime_status']=='runtime_poi'}
    catalog={(mid,'subzone',key) for mid,keys in subs.items() for key in keys}|{(parent,'city',str(city)) for city,parent in CITY_IN.items() if city in zones}
    coverage=[]
    for mid,kind,k in sorted(catalog):
        ident=(mid,kind,k);a=ident in overlay_targets;b=ident in poi_targets
        coverage.append(dict(map_id=mid,zone=zones[mid],kind=kind,key=k,geometry='both' if a and b else 'overlay_only' if a else 'poi_only' if b else 'neither',runtime_poi=ident in runtime_targets,pending=(int(k),'zone','') in pending if kind=='city' else ident in pending))
    positions.sort(key=lambda p:(p['map_id'],p['kind'],p['key'],p['poi_id']))
    return positions,audit,coverage,{n:d[2] for n,d in data.items()},map_bind,ownership

def write_outputs(out,positions,audit,coverage,hashes,map_bind,ownership,branch):
    out.mkdir(parents=True,exist_ok=True)
    for name,rows in [('poi_records',audit),('poi_positions',positions),('coverage',coverage),('overlay_ownership',ownership)]:
        with (out/(name+'.csv')).open('w',encoding='utf-8',newline='') as h:
            writer=csv.DictWriter(h,fieldnames=list(rows[0]));writer.writeheader();writer.writerows(rows)
    runtime=[p for p in positions if p['runtime_status']=='runtime_poi']
    lines=['-- Generated by scripts/generate_map_pois.py; M4 staging only.','-- OctoWoW DBC-derived positions; no runtime activation.']
    if branch=='dev': lines.append('setfenv(1, SpokenEnv)')
    lines.append('SSZMapPOIData = {')
    for mid,group in itertools.groupby(runtime,key=lambda p:p['map_id']):
        lines.append(f'    [{mid}] = {{')
        for p in group:
            k=json.dumps(p['key'],ensure_ascii=False) if p['kind']=='subzone' else p['key']
            extra=', location='+json.dumps(p['canonical']) if branch=='dev' else ''
            lines.append(f'        {{kind="{p["kind"]}", id={k}, x={p["x"]:.9f}, y={p["y"]:.9f}, poi={p["poi_id"]}{extra}}},')
        lines.append('    },')
    lines.append('}')
    (out/'MapPOIs.lua').write_text('\n'.join(lines)+'\n',encoding='utf-8')
    summary={'input_sha256':hashes,'record_status':dict(collections.Counter(r['status'] for r in audit)),'coverage':dict(collections.Counter(r['geometry'] for r in coverage)),'map_bindings':map_bind,'positions':len(positions),'by_map':{str(m):dict(collections.Counter(r['geometry'] for r in coverage if r['map_id']==m)) for m in sorted({r['map_id'] for r in coverage})},'shared_overlays':len(ownership),'resolved_shared_overlays':sum(bool(r['owner_id']) for r in ownership),'runtime_positions':len(runtime),'runtime_associations':len({(p['map_id'],p['kind'],p['key']) for p in runtime}),'runtime_status':dict(collections.Counter(p['runtime_status'] for p in positions))}
    (out/'summary.json').write_text(json.dumps(summary,indent=2,sort_keys=True)+'\n',encoding='utf-8');return summary

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--dbc-dir',type=Path,required=True);p.add_argument('--repo',type=Path,default=Path('.'));p.add_argument('--out',type=Path,required=True);p.add_argument('--branch',choices=['main','dev'],default='main');a=p.parse_args()
    print(json.dumps(write_outputs(a.out,*build(a.dbc_dir,*read_catalog(a.repo,a.branch),a.branch),a.branch),indent=2))
if __name__=='__main__':main()
