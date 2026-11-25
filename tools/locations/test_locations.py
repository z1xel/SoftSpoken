import copy
import json
import struct
import tempfile
import unittest
from pathlib import Path

from dbc import LAYOUTS, read_dbc, sha256, load_sources
from inventory import inventory, table
from build import identity_manifest, validate_view, effective, content_report, source_report, lua, build

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]


def fixture():
    data = json.loads((HERE/"fixtures/schema-v1-example.json").read_text())
    view = {k:data[k] for k in ("entities","bindings","relations","mapRepresentations","mapCoverage")}
    identities = {k:{"status":"active","evidence":["synthetic"]} for k in view["entities"]}
    scopes = {"fixture_vanilla":"native","fixture_spoken":"content","fixture_custom":"native"}
    return view, identities, scopes


def make_dbc(path, name, rows):
    fields = LAYOUTS[name]
    stringblock = b"\0Test\0"
    data = b"".join(struct.pack(f"<{fields}I", *row) for row in rows)
    path.write_bytes(struct.pack("<4s4I",b"WDBC",len(rows),fields,fields*4,len(stringblock))+data+stringblock)


class LocationTests(unittest.TestCase):
    def test_real_inventory(self):
        data = inventory(ROOT)
        refs = data["references"]
        from collections import Counter
        counts = Counter(x["owner"] for x in refs)
        self.assertEqual(counts["Places.Zones"],54)
        self.assertEqual(counts["Places.Subzones"],878)
        self.assertEqual(counts["Places.Pictures"],810)
        self.assertEqual(counts["Stories.turtleArea"],980)
        self.assertEqual(counts["Stories.dungeon"],556)
        self.assertEqual(len(data["questSortsExcluded"]),1118)
        self.assertGreater(counts["Writings.from"],0)
        self.assertGreater(counts["Writings.zones"],0)
        self.assertEqual(data,inventory(ROOT))

    def test_literal_parser(self):
        self.assertEqual(table('local x = { [2] = { "a\\\\b", false, key="name" }, -- comment\n}',"x"),
                         {2:{1:"a\\b",2:False,"key":"name"}})
        with self.assertRaises(ValueError):
            table("x = { [1]=true, [1]=false }","x")
        with self.assertRaises(ValueError):
            table("x = { foo() }","x")

    def test_fixture(self):
        v,i,s = fixture()
        identity_manifest(i)
        b = validate_view(v,i,s)
        self.assertNotEqual(b[("fixture_vanilla","areaTable",209)],b[("fixture_vanilla","instanceMap",209)])
        self.assertEqual(b[("fixture_vanilla","areaTable",211)],b[("fixture_vanilla","areaTable",212)])

    def test_cycles_and_collisions(self):
        v,i,s = fixture()
        v["entities"]["example_world"]["parent"]="example.bridge"
        with self.assertRaisesRegex(ValueError,"cycle"):
            validate_view(v,i,s)
        v,i,s = fixture()
        v["bindings"].append(dict(v["bindings"][0],location="other.tower"))
        with self.assertRaisesRegex(ValueError,"duplicate/conflicting"):
            validate_view(v,i,s)
        v,i,s = fixture()
        v["entities"]["example.tower"]["lore"]="not registry data"
        with self.assertRaisesRegex(ValueError,"unexpected"):
            validate_view(v,i,s)

    def test_overlay(self):
        v,i,s = fixture()
        old = v["bindings"][0]
        new = dict(old,location="other.tower")
        patched = effective(v,{"removeBindings":[old],"addBindings":[new],
                               "patch":{"example.tower":{"set":{"name":"Renamed"},"clear":["aliases"]}}})
        self.assertEqual(validate_view(patched,i,s)[("fixture_vanilla","areaTable",209)],"other.tower")
        self.assertEqual(v["entities"]["example.tower"]["name"],"Tower")
        with self.assertRaises(ValueError):
            validate_view(effective(v,{"addBindings":[new]}),i,s)
        with self.assertRaises(ValueError):
            effective(v,{"removeBindings":[new]})

    def test_manifest(self):
        v,i,s = fixture()
        old = copy.deepcopy(i)
        i["example.tower"]={"status":"retired","evidence":["synthetic"],"redirect":"other.tower"}
        identity_manifest(i,old)
        with self.assertRaises(ValueError):
            identity_manifest(old,i)
        i["other.tower"]={"status":"retired","evidence":["synthetic"],"redirect":"example.tower"}
        with self.assertRaises(ValueError):
            identity_manifest(i)

    def test_holds(self):
        v,i,s = fixture()
        refs=[{"namespace":"legacyPlace","value":1429,"area":"tower","owner":"Places","record":"1"},
              {"namespace":"legacyPlace","value":1429,"area":"other","owner":"Places","record":"2"}]
        result=content_report(refs,[dict(refs[0],status="mapped",location="example.tower",reason="review")],i)
        self.assertEqual([r["status"] for r in result],["mapped","held"])
        self.assertNotIn("location",result[1])
        report=source_report({"fixture":{"AreaTable":{1:{},2:{}}}},
                             [{"scope":"fixture","table":"AreaTable","id":1,"status":"excluded","reason":"unused"}],i)
        self.assertEqual([x["status"] for x in report],["excluded","held"])

    def test_dbc_and_full_build(self):
        with tempfile.TemporaryDirectory() as tmp:
            p=Path(tmp)
            area=[0]*25
            area[0],area[3],area[11]=209,18,1
            world=[0]*42
            world[0],world[1],world[2],world[4]=209,1,1,1
            ma=[0]*8
            ma[0],ma[2],ma[3]=1,209,1
            overlay=[0]*17
            overlay[0],overlay[1],overlay[2],overlay[8]=1,1,209,1
            rows={"AreaTable":[area],"Map":[world],"WorldMapArea":[ma],"WorldMapOverlay":[overlay]}
            files={}
            for name, records in rows.items():
                path=p/(name+".dbc")
                make_dbc(path,name,records)
                files[name]={"path":str(path),"sha256":sha256(path)}
            self.assertEqual(read_dbc(p/"AreaTable.dbc","AreaTable")[209]["names"],{"enUS":"Test"})
            source={"world":"fixture","revision":"fixture","provenance":"synthetic","rights":"synthetic",
                    "locale":"enUS","layout":"vanilla_5875","effectivePatched":True,"files":files}
            manifest={"profiles":{"fixture_vanilla":source}}
            self.assertEqual(len(load_sources(manifest,ROOT)["fixture_vanilla"]),4)
            v,i,s=fixture()
            # Only include bindings with matching source rows.
            v["bindings"]=[r for r in v["bindings"] if r["value"]==209]
            v["mapRepresentations"]=[];v["mapCoverage"]=[]
            decisions={"identities":i,"base":v}
            a=build(manifest,decisions,ROOT,p/"a")
            b=build(manifest,decisions,ROOT,p/"b")
            self.assertEqual(a,b)
            self.assertEqual(a["sourceCounts"],{"held":4})
            for name in ("Locations.generated.lua","coverage.json","normalized-sources.json"):
                self.assertEqual((p/"a"/name).read_bytes(),(p/"b"/name).read_bytes())
            source["effectivePatched"]=False
            with self.assertRaises(ValueError):
                load_sources(manifest,ROOT)
            source["effectivePatched"]=True
            files["AreaTable"]["sha256"]="bad"
            with self.assertRaisesRegex(ValueError,"checksum"):
                load_sources(manifest,ROOT)
            with self.assertRaisesRegex(ValueError,"no verified"):
                build({},decisions,ROOT,p/"bad")
            self.assertFalse((p/"bad"/"Locations.generated.lua").exists())
            (p/"AreaTable.dbc").write_bytes(b"oops")
            with self.assertRaises(ValueError):
                read_dbc(p/"AreaTable.dbc","AreaTable")

    def test_lua_escaping(self):
        self.assertEqual(lua('A"\\é'),'"A\\034\\092\\195\\169"')


if __name__=="__main__":
    unittest.main()
