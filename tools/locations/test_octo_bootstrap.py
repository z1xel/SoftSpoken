import copy
import unittest
from bootstrap_octo import PROFILE, reconcile, norm
from build import effective, validate_view, identity_manifest

class OctoBootstrapTests(unittest.TestCase):
    def fixture(self):
        entities = {
            "azeroth": {"name":"Azeroth","kind":"world"},
            "eastern_kingdoms": {"name":"Eastern Kingdoms","kind":"continent","parent":"azeroth"},
            "kalimdor": {"name":"Kalimdor","kind":"continent","parent":"azeroth"},
            "elwynn_forest": {"name":"Elwynn Forest","kind":"zone","parent":"eastern_kingdoms"},
            "elwynn_forest.goldshire": {"name":"Goldshire","kind":"subzone"},
        }
        seed = dict(identities={k:{"status":"active","evidence":["test"]} for k in entities},
                    base=dict(entities=entities, bindings=[dict(scope="spoken_classic",namespace="upstreamUiMap",value=1429,location="elwynn_forest")]),
                    contentCrosswalk=[],worldOverlays={},profileOverlays={},sourceDispositions=[])
        research = {"nativeEvidenceCandidates":[
            dict(areaTable=12,location="elwynn_forest",areaName="Elwynn Forest"),
            dict(areaTable=87,location="elwynn_forest.goldshire",areaName="Goldshire",mapRegionAreaID=12)]}
        def area(ident,name,parent=0,world=0):
            return dict(id=ident,names={"enUS":name},parentArea=parent,worldMap=world)
        tables = dict(AreaTable={
            12:area(12,"Elwynn Forest"),87:area(87,"Goldshire",12),
            88:area(88,"Unique Mill",12),89:area(89,"Shared Gate",12),
            90:area(90,"Shared Gate",12),91:area(91,"UNUSED"),92:area(92,"Example Dungeon",world=3)},
            Map={0:dict(id=0,names={"enUS":"Eastern Kingdoms"},instanceType=0),
                 1:dict(id=1,names={"enUS":"Kalimdor"},instanceType=0),
                 3:dict(id=3,names={"enUS":"Example Dungeon"},instanceType=1)},
            WorldMapArea={1:dict(id=1,areaTable=12,worldMap=0,directory="Elwynn")},
            WorldMapOverlay={1:dict(id=1,worldMapArea=1,areaIDs=[87,88,89])})
        refs=[dict(sourceScope="spoken_classic",namespace="legacyPlace",value=1429,area="unique mill"),
              dict(sourceScope="spoken_classic",namespace="legacyPlace",value=1429,area="shared gate")]
        return seed,research,tables,refs

    def test_reconcile(self):
        seed,research,tables,refs=self.fixture()
        original=copy.deepcopy(seed)
        result,report=reconcile(seed,research,tables,refs)
        self.assertEqual(seed,original)
        self.assertEqual((result,report),reconcile(seed,research,tables,refs))
        identity_manifest(result["identities"],seed["identities"])
        view=effective(effective(result["base"],result["worldOverlays"]["octo"]),result["profileOverlays"][PROFILE])
        index=validate_view(view,result["identities"],{PROFILE:"native","spoken_classic":"content"},{PROFILE:tables})
        self.assertEqual(index[(PROFILE,"areaTable",87)],"elwynn_forest.goldshire")
        self.assertEqual(index[(PROFILE,"areaTable",92)],index[(PROFILE,"instanceMap",3)])
        self.assertEqual(view["entities"]["unique_mill"]["parent"],"elwynn_forest")
        self.assertNotIn((PROFILE,"areaTable",89),index)
        self.assertEqual(report["sourceCounts"]["AreaTable"],{"mapped":4,"held":2,"excluded":1})
        self.assertEqual(report["sourceCounts"]["WorldMapOverlay"],{"held":1})
        self.assertEqual([x["location"] for x in result["contentCrosswalk"]],["unique_mill"])
        self.assertEqual(len(result["sourceDispositions"]),sum(map(len,tables.values())))
        with self.assertRaises(ValueError):
            reconcile(result,research,tables,refs)

    def test_invalid_parent_cycle(self):
        seed,research,tables,refs=self.fixture()
        tables["AreaTable"][12]["parentArea"]=87
        with self.assertRaisesRegex(ValueError,"invalid native parent"):
            reconcile(seed,research,tables,refs)

    def test_seed_mismatch(self):
        seed,research,tables,refs=self.fixture()
        tables["AreaTable"][87]["names"]["enUS"]="Different Place"
        result,report=reconcile(seed,research,tables,refs)
        self.assertEqual(report["seedNativeMatches"],1)
        self.assertTrue(any(r["kind"]=="seed-native-mismatch" for r in report["conflicts"]))
        self.assertIn("elwynn_forest.goldshire",result["identities"])

if __name__=="__main__":
    unittest.main()
