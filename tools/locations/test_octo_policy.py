"""Regression for reviewed policy application without redistributing the native source."""
import unittest
from unittest.mock import patch
import octo_policy as policy

class ApprovedOctoPolicyTests(unittest.TestCase):
    def test_reviewed_groups_and_development_exclusion(self):
        def row(name, world=0, parent=0):
            return dict(names={"enUS":name},worldMap=world,parentArea=parent)
        area={1:row("Bridge"),2:row("Bridge",1),3:row("Dungeon",0),
              4:row("Dungeon",9),5:row("Development",451)}
        entities={"dungeon":{"name":"Dungeon","kind":"dungeon"}}
        identities={"dungeon":{"status":"active","evidence":["fixture"]}}
        added,areas={},{}
        dispositions={("AreaTable",i):{"status":"held"} for i in area}
        def assign(i,key,reason):
            areas[i]=key
            dispositions[("AreaTable",i)]={"status":"mapped","reason":reason}
        with patch.multiple(policy,CROSS_ZONE={"bridge":[1,2]},SEAS={},
                            ROOTS={"dungeon":[4]},MAP_ALIASES={},
                            EXTERIORS={"dungeon":3},HISTORY={},DISTINCT={}):
            related=policy.apply(area,{}, {9:"dungeon"},areas,entities,added,
                                  identities,dispositions,assign)
        self.assertEqual(areas[1],areas[2])
        self.assertNotEqual(areas[3],areas[4])
        self.assertIn(("dungeon.exterior","dungeon"),related)
        self.assertEqual(dispositions[("AreaTable",5)]["status"],"excluded")
        self.assertNotIn(5,areas)

if __name__=="__main__":
    unittest.main()
