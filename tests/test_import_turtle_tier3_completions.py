"""Synthetic, rights-free regression checks for Tier 3-only completion imports."""
import csv
import sqlite3
import sys
import tempfile
import unittest
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/"scripts"))
import audit_turtle_touched_text as audit
import import_turtle_tier3_completions as tier


class Tier3ImportTests(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root=Path(self.tmp.name)
        self.manifest=self.root/"tier.csv"
        self.db=self.root/"source.sqlite"
        with self.manifest.open("w",newline="",encoding="utf-8") as stream:
            writer=csv.DictWriter(stream,fieldnames=["quest_id","catalog_title","stage",
                                   "source_chars","source_sha256","spoken_chars",
                                   "source_migration_modified_stage"])
            writer.writeheader()
            for qid in sorted(tier.IDS):
                raw=f"A synthetic Tier 3 completion for quest {qid} and $N."
                writer.writerow(dict(quest_id=qid,catalog_title=f"Quest {qid}",
                                     stage="complete",source_chars=len(raw),
                                     source_sha256=audit.sha(audit.content(raw)),
                                     spoken_chars=48,source_migration_modified_stage=1))
        with sqlite3.connect(self.db) as con:
            con.execute("CREATE TABLE quests (entry INTEGER,title TEXT,details TEXT,requesttext TEXT,offertext TEXT)")
            con.executemany("INSERT INTO quests VALUES(?,?,?,?,?)",[
                (qid,f"Quest {qid}","","",f"A synthetic Tier 3 completion for quest {qid} and $N.")
                for qid in sorted(tier.IDS)])

    def test_exactly_thirteen_verified_completion_stages(self):
        selected=tier.select_manifest(self.manifest)
        self.assertEqual(len(selected),13)
        texts=tier.load_verified_source(self.db,selected)
        self.assertEqual(set(texts),tier.IDS)
        self.assertTrue(all(set(stages)=={"complete"} for stages in texts.values()))

    def test_preserves_preexisting_progress_of_same_quest(self):
        texts=tier.load_verified_source(self.db,tier.select_manifest(self.manifest))
        old=('SSCTurtleQuestText = SSCTurtleQuestText or {}\n'
             'SSCTurtleQuestText[9057] = SSCTurtleQuestText[9057] or {}\n'
             'SSCTurtleQuestText[9057].progress = "Keep old progress"\n'
             'SSCTurtleQuestText[40001] = {accept="Keep high ID"}\n')
        block=tier.render_batch(texts)
        new=tier.merge_batch(old,block)
        self.assertTrue(new.startswith(old))
        self.assertIn('SSCTurtleQuestText[9057].progress = "Keep old progress"',new)
        self.assertIn('SSCTurtleQuestText[9057].complete = ',new)
        self.assertEqual(tier.merge_batch(new,block),new)

    def test_refuses_collision_on_same_stage(self):
        old=('SSCTurtleQuestText = SSCTurtleQuestText or {}\n'
             'SSCTurtleQuestText[9034].complete = "Curated version"\n')
        with self.assertRaisesRegex(ValueError,"Preexisting Tier 3 completion"):
            tier.merge_batch(old,tier.BEGIN+"\n"+tier.END+"\n")

    def test_refuses_unapproved_ids(self):
        rows=list(csv.DictReader(self.manifest.open(newline="",encoding="utf-8")))
        rows[0]["quest_id"]="9000"
        with self.manifest.open("w",newline="",encoding="utf-8") as stream:
            w=csv.DictWriter(stream,fieldnames=list(rows[0]))
            w.writeheader();w.writerows(rows)
        with self.assertRaisesRegex(ValueError,"Unexpected Tier 3"):
            tier.select_manifest(self.manifest)

    def test_pinned_source_change_blocks_write(self):
        with sqlite3.connect(self.db) as con:
            con.execute("UPDATE quests SET offertext='Wrong' WHERE entry=9095")
        with self.assertRaisesRegex(ValueError,"source hash changed"):
            tier.load_verified_source(self.db,tier.select_manifest(self.manifest))


if __name__=="__main__":
    unittest.main()
