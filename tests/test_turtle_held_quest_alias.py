"""Synthetic regression for the ONE allowed Turtle exclusive-title alias (41797)."""
import json
import sqlite3
import sys
import tempfile
import unittest
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/"scripts"))
import audit_turtle_hold_resolutions as review
import import_turtle_approved_alias as importer
import reapply_turtle_zone_exception as zone


class TurtleHeldQuestAliasTests(unittest.TestCase):
    def setUp(self):
        tmp=tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.root=Path(tmp.name)
        self.db=self.root/"tortoise.sqlite"
        self.manifest=self.root/"approval.json"
        with sqlite3.connect(self.db) as conn:
            conn.executescript("""
              CREATE TABLE quests(
                  entry INTEGER,title TEXT,objectives TEXT,details TEXT,
                  requesttext TEXT,offertext TEXT,zone INTEGER,hidden INTEGER);
              CREATE TABLE creature_quest_start(quest INTEGER,id INTEGER);
              CREATE TABLE creature_quest_end(quest INTEGER,id INTEGER);
            """)
            conn.execute("INSERT INTO quests VALUES(?,?,?,?,?,?,?,?)",(
                41797,"A Dear Friend",
                "Bring Avette Fellwood's letter to Barbara Lee.",
                "Synthetic acceptance of the quest with $N.",
                "Synthetic progress and a small inquiry.",
                "Synthetic completion with final receipt.",
                5581,0))
            conn.execute("INSERT INTO creature_quest_start VALUES(41797,228)")
            conn.execute("INSERT INTO creature_quest_end VALUES(41797,62307)")
            manifest=review.approved_title_alias(conn,review.catalog_rows(review.CATALOG))
        self.manifest.write_text(json.dumps(manifest),encoding="utf-8")

    def test_exact_quest_identity_and_stage_hashes(self):
        stage=importer.load_verified(self.db,self.manifest)
        self.assertEqual(set(stage),{"accept","progress","complete"})
        self.assertEqual(stage["accept"],"Synthetic acceptance of the quest with $N.")

    def test_unexpected_stage_text_rejected(self):
        with sqlite3.connect(self.db) as conn:
            conn.execute("UPDATE quests SET details='Changed' WHERE entry=41797")
        with self.assertRaisesRegex(ValueError,"identity or pinned stage hash"):
            importer.load_verified(self.db,self.manifest)

    def test_wrong_npc_or_title_rejected(self):
        with sqlite3.connect(self.db) as conn:
            conn.execute("UPDATE creature_quest_end SET id=3 WHERE quest=41797")
        with self.assertRaisesRegex(ValueError,"Quest 41797 identity changed"):
            importer.load_verified(self.db,self.manifest)

    def test_block_idempotent_and_preserves_existing_text(self):
        txt=importer.load_verified(self.db,self.manifest)
        seed='SSCTurtleQuestText = SSCTurtleQuestText or {}\nSSCTurtleQuestText[40001] = {accept="Existing"}\n'
        block=importer.format_block(txt)
        merged=importer.merge(seed,block)
        self.assertTrue(merged.startswith(seed))
        self.assertEqual(importer.merge(merged,block),merged)
        self.assertEqual(merged.count(importer.BEGIN),1)
        self.assertIn("SSCTurtleQuestText[41797] = {",merged)
        self.assertIn("accept =",merged)
        self.assertIn("complete =",merged)

    def test_protected_collision_not_silent_overwrite(self):
        seed='SSCTurtleQuestText[41797].accept = "Original"\n'
        with self.assertRaisesRegex(ValueError,"separate 41797"):
            importer.merge(seed,importer.format_block(
                importer.load_verified(self.db,self.manifest)))

    def test_catalog_classifier_only_adds_northwind(self):
        original=('\tquests = {\n'
                  '\t\t[41797] = { "A Good Friend", races = 4294967373, starter = 228, ender = 62307 },\n'
                  '\t\t[40128] = { "An Ancient Acquisition", starter = 60441 },\n'
                  '\t},\n\n\tsorts = {\n')
        result,changed=zone.apply(original)
        self.assertTrue(changed)
        self.assertIn('ender = 62307, turtleArea = 5581',result)
        self.assertIn('[40128] = { "An Ancient Acquisition", starter = 60441 }',result)
        self.assertEqual(zone.apply(result),(result,False))
        self.assertIn('"A Good Friend"',result)
        self.assertNotIn('"A Dear Friend"',result)

    def test_exact_approved_alias_manifest_in_repo(self):
        p=review.OUT/"approved_41797_identity.json"
        approved=zone.verify_record(p)
        self.assertEqual(approved["starter_id"],228)
        self.assertEqual(approved["ender_id"],62307)
        self.assertEqual(set(approved["stage_hashes"]),set(importer.STAGES))
        for obj in approved["stage_hashes"].values():
            self.assertEqual(len(obj["sha256"]),64)


if __name__=="__main__":
    unittest.main()
