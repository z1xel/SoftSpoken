"""Reviewed identity exceptions for the exact Octo 20261126 extract only."""
from bootstrap_octo import PROFILE, label, norm

# Immutable explicit allocations, not generated from current names.
CROSS_ZONE = {
    'blackrock_mountain':[25,254,1445], 'bulwark':[152,813],
    'lordamere_lake':[170,1338,1339], 'dun_algaz':[269,836,837],
    'thandol_span':[330,880,881], 'southfury_river':[377,814,815,878,879],
    'great_lift':[485,1718], 'south_gate_pass':[805,839], 'north_gate_pass':[807,838],
    'talondeep_path':[1276,1277], 'darrowmere_lake':[2297,2299],
    'thondroril_river':[2619,2620], 'thoradins_wall':[293,1057,1857],
    'silverpine_forest.greymane_wall':[230,5203], 'caverns_of_time.exterior':[1941,2300],
    'grim_reaches':[5016,5602], 'grim_batol_memorial':[5021,5620],
}
SEAS = {
    'great_sea':[214,332,2318,2319,2320,2321,2339,2364,2365,2397,2398,2399],
    'forbidding_sea':[308,2400,2401,2402,2403], 'veiled_sea':[457,2322,2323,2324,2325,2326,2477],
    'south_seas':[2317,2338],
}
ROOTS = {
    'shadowfang_keep':[209,5132,5150,5161,5169,5173,5177],
    'gnomeregan':[721,5134,5152,5162], 'deadmines':[1581,5138],
    'scholomance':[2057,5142,5156,5165], 'dire_maul':[2557,5145,5157,5166,5171,5175],
    'blackwing_lair':[2677,5146,5158,5167], 'ahnqiraj_temple':[3428,5147],
    'hateforge_quarry':[5098,5103], 'deeprun_tram':[2257,5144], 'black_morass':[2366,5204],
}
MAP_ALIASES = {'sunken_temple':(1477,109), 'blackrock_spire':(1583,229),
               'blackrock_depths':(1584,230), 'onyxias_lair':(2159,249)}
EXTERIORS = {'zulgurub':19,'gnomeregan':133,'shadowfang_keep':236,'razorfen_kraul':1717,
    'blackfathom_deeps':2797,'razorfen_downs':1316,'zulfarrak':978,'uldaman':1517,
    'stratholme':2279,'dire_maul':2577,'ruins_of_ahnqiraj':3454,'dragonmaw_retreat':5600,
    'frostmane_hollow':5735,'gilneas_city':5180,'alterac_valley':2839,'timbermaw_hold':1216}
HISTORY = {'southshore':(271,2369),'tarren_mill':(272,2368),'durnholde_keep':(275,2370),
    'southpoint_tower':(285,2376),'hillsbrad_fields':(286,2372),'azurelode_mine':(288,2379),
    'nethander_stead':(289,2374),'dun_garok':(290,2371),'eastern_strand':(294,2373),
    'western_strand':(295,2378),'darrow_hill':(1056,2375),'thoradins_wall':(293,2377)}
DISTINCT = {'burning_steppes.altar_of_storms':255,'blasted_lands.altar_of_storms':1441,
    'eastern_plaguelands.green_belt':1019,'wetlands.green_belt':1025,'highlands.hidden_grove':5025,
    'rock_of_desolation':5557}


def apply(area, wma, map_ids, areas, entities, added, identities, dispositions, assign_area):
    """Apply exact scoped decisions before deriving containment, coverage and crosswalks."""
    related = []
    def bind(key, ids, kind, reason):
        names = {norm(label(area[i])) for i in ids}
        if len(names) != 1 or not next(iter(names)):
            raise ValueError(f"reviewed group name mismatch {key}: {ids}")
        if key not in entities:
            if key in identities:
                raise ValueError(f"review allocation already reserved {key}")
            identities[key] = {"status":"active","evidence":[f"{PROFILE}: reviewed AreaTable {ids}; {reason}"]}
            added[key] = entities[key] = {"name":label(area[ids[0]]),"kind":kind}
        for i in ids:
            if i in areas:
                if areas[i] != key:
                    raise ValueError(f"review would reassign {i}")
                continue
            if dispositions[("AreaTable",i)]["status"] != "held":
                raise ValueError(f"review would overwrite non-held row {i}")
            del dispositions[("AreaTable",i)]
            assign_area(i,key,reason)
    for key,ids in CROSS_ZONE.items():
        bind(key,ids,"zone" if key=="grim_reaches" else "landmark","reviewed cross-zone physical identity")
    related.append(("caverns_of_time.exterior","caverns_of_time"))
    for key,ids in SEAS.items():
        if any(area[i]["worldMap"] not in (0,1) for i in ids):
            raise ValueError("reviewed sea must be outdoors")
        bind(key,ids,"landmark","reviewed named outdoor body of water")
    for key,ids in ROOTS.items():
        if len({area[i]["worldMap"] for i in ids}) != 1 or any(area[i]["parentArea"] for i in ids):
            raise ValueError(f"root context mismatch {key}")
        bind(key,ids,"subzone" if key=="black_morass" else "unknown","reviewed same-map root representations")
    for key,(i,mid) in MAP_ALIASES.items():
        if map_ids.get(mid)!=key or not any(r["areaTable"]==i and r["worldMap"]==mid for r in wma.values()):
            raise ValueError(f"missing direct map representation {key}")
        bind(key,[i],"unknown","direct WorldMapArea instance subject, not an outdoor entrance")
    for key,i in EXTERIORS.items():
        if area[i]["worldMap"] not in (0,1) or key not in entities:
            raise ValueError(f"exterior context mismatch {key}")
        bind(key+".exterior",[i],"landmark","reviewed outdoor location distinct from instance")
        related.append((key+".exterior",key))
    for key,(present,historical) in HISTORY.items():
        if area[present]["worldMap"]!=0 or area[historical]["worldMap"]!=269 or area[historical]["parentArea"]!=2367:
            raise ValueError(f"historical context mismatch {key}")
        if present not in areas:
            bind(key,[present],"subzone","present-day Hillsbrad identity")
        bind("old_hillsbrad."+key,[historical],"subzone","historical Hillsbrad identity")
        related.append(("old_hillsbrad."+key,areas[present]))
    for key,i in DISTINCT.items():
        bind(key,[i],"subzone","reviewed distinct geographical context")
    for i,row in area.items():
        if row["worldMap"]==451:
            if i in areas:
                raise ValueError(f"development row already allocated {i}")
            dispositions[("AreaTable",i)].update(status="excluded",reason="user policy: exclude development map")
    return related
