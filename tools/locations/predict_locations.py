"""G4.2: conservative player-location candidate inventory; no live recognition inferred.
Usage: python predict_locations.py scan.zip WMOAreaTable.dbc output_directory
"""
import argparse, collections, csv, hashlib, io, json, pathlib, struct, zipfile, re

def norm(s):
    return re.sub(r'[^\w]+', ' ', s.lower().replace("'", '').replace('’', '')).strip().removeprefix('the ')

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('scan',type=pathlib.Path);p.add_argument('dbc',type=pathlib.Path);p.add_argument('out',type=pathlib.Path)
    args=p.parse_args();args.out.mkdir(parents=True,exist_ok=True)
    def digest(b):return hashlib.sha256(b).hexdigest()
    z=zipfile.ZipFile(args.scan)
    def member(name):
        matches=[n for n in z.namelist() if n.rsplit('/',1)[-1]==name]
        if len(matches)!=1:raise ValueError(f'Expected one {name}: {matches}')
        return z.read(matches[0])
    def read(name):return list(csv.DictReader(io.StringIO(member(name).decode('utf-8-sig'))))
    def write(name,rows):
        if not rows:raise ValueError('Empty '+name)
        with (args.out/name).open('w',encoding='utf-8',newline='') as f:
            w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    source=json.loads(member('summary.json'));b=args.dbc.read_bytes()
    if digest(b)!=source['wmo_audit']['wmo_dbc_sha256']:raise ValueError('WMO DBC hash mismatch')
    magic,n,f,width,ss=struct.unpack_from('<4s4I',b)
    if (magic,f,width)!=(b'WDBC',20,80) or len(b)!=20+n*width+ss:raise ValueError('Unsupported WMO DBC')
    st=b[20+n*width:];dbc={}
    for r in struct.iter_unpack('<20I',b[20:20+n*width]):
        name=st[r[11]:st.index(b'\0',r[11])].decode('utf-8')
        if r[0] in dbc:raise ValueError('Duplicate DBC row ID')
        dbc[r[0]]=(r[1],r[2],r[3],r[10],name)
    areas={r['area_id']:r for r in read('area_evidence.csv')};wmo=read('wmo_area_matches.csv');terrain=read('terrain_by_map.csv')
    group=collections.defaultdict(list);roots=collections.defaultdict(list)
    def model(r):return (r['map_id'],r['wmo_path'],r['placement_nameset_id'])
    for r in wmo:
        expected=(int(r['root_id']),int(r['placement_nameset_id']),int(r['group_id'])&0xffffffff,int(r['area_id']),r['wmo_explicit_name'])
        if dbc[int(r['dbc_row_id'])]!=expected:raise ValueError('WMO row mismatch: '+r['dbc_row_id'])
        (roots if r['group_index']=='-1' else group)[model(r) if r['group_index']=='-1' else (*model(r),r['group_index'])].append(r)
    def status(mid,aid):
        if aid=='0':return 'no_area_reference'
        if aid not in areas:return 'unknown_area_reference'
        return 'same_map_area' if areas[aid]['declared_map_id']==mid else 'cross_map_area'
    detail=[]
    for r in wmo:
        name=r['wmo_explicit_name'];aid=r['area_id'];mid=r['map_id'];rel=status(mid,aid)
        if not name:continue
        alternatives=(roots[model(r)] if r['group_index']=='-1' else group[(*model(r),r['group_index'])])
        conflict=len({(v['area_id'],norm(v['wmo_explicit_name'])) for v in alternatives})>1
        if mid=='451':kind='excluded_development_map'
        elif conflict:kind='ambiguous_dbc_key'
        elif r['group_index']=='-1':kind='root_name_hold'
        elif r['geometry_status']!='mesh_present':kind='geometry_hold'
        elif rel=='same_map_area':kind='group_name_same_area' if norm(name)==norm(areas[aid]['area_name']) else 'group_name_override_candidate'
        elif rel=='no_area_reference':kind='group_name_terrain_context_needed'
        else:kind='group_name_reference_review'
        detail.append(dict(map_id=mid,name=name,normalized_name=norm(name),area_id=aid,area_name=areas.get(aid,{}).get('area_name',''),area_context=rel,classification=kind,model=r['wmo_path'],nameset=r['placement_nameset_id'],root_id=r['root_id'],group_index=r['group_index'],group_id=r['group_id'],dbc_row_id=r['dbc_row_id'],mesh_triangles=r['mesh_triangles'],placement_count=r['unique_placement_ids'],example_tile=r['example_tile']))
    buckets=collections.defaultdict(list)
    for r in detail:buckets[(r['map_id'],r['normalized_name'],r['area_id'],r['classification'])].append(r)
    inventory=[]
    for (mid,nm,aid,kind),rs in sorted(buckets.items(),key=lambda kv:(int(kv[0][0]),kv[0][1],int(kv[0][2]),kv[0][3])):
        inventory.append(dict(map_id=mid,name='|'.join(sorted({x['name'] for x in rs})),normalized_name=nm,area_id=aid,area_name=rs[0]['area_name'],classification=kind,evidence_rows=len(rs),model_namesets=len({(x['model'],x['nameset']) for x in rs}),example_model=rs[0]['model'],example_tile=rs[0]['example_tile'],live_verified='no'))
    native=collections.defaultdict(lambda: [0,set()])
    for r in terrain:
        if r['area_id']!='0':native[(r['map_id'],r['area_id'])][0]+=int(r['chunk_count'])
    for r in wmo:
        if r['geometry_status']=='mesh_present' and r['area_id'] in areas and r['status'] in ('exact_placed_group','declared_map_mismatch','ambiguous_exact_key'):
            native[(r['map_id'],r['area_id'])][1].add((*model(r),r['group_index']))
    native_rows=[]
    for (mid,aid),(chunks,groups) in sorted(native.items(),key=lambda kv:tuple(map(int,kv[0]))):
        rel=status(mid,aid)
        native_rows.append(dict(map_id=mid,area_id=aid,area_name=areas.get(aid,{}).get('area_name',''),declared_map=areas.get(aid,{}).get('declared_map_id',''),terrain_chunks=chunks,placed_group_keys=len(groups),classification='excluded_development_map' if mid=='451' else 'native_area_candidate' if rel=='same_map_area' else 'native_context_review',live_verified='no'))
    write('named_wmo_detail.csv',detail);write('predicted_wmo_names.csv',inventory);write('predicted_native_areas.csv',native_rows)
    summary=dict(scan_sha256=digest(args.scan.read_bytes()),wmo_dbc_sha256=digest(b),verified_wmo_report_rows=len(wmo),native_context_rows=len(native_rows),native_classifications=dict(collections.Counter(r['classification'] for r in native_rows)),named_evidence_rows=len(detail),named_map_name_pairs=len({(r['map_id'],r['normalized_name']) for r in detail}),named_context_rows=len(inventory),named_classifications=dict(collections.Counter(r['classification'] for r in inventory)),named_evidence_classifications=dict(collections.Counter(r['classification'] for r in detail)),live_verified=0)
    (args.out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8');print(json.dumps(summary,indent=2))
if __name__=='__main__':main()
