"""Synthetic coverage and atomic append regression for the 207 missing stages."""
import csv
import sqlite3
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
import audit_turtle_touched_text as audit
import import_turtle_missing_stages as missing


class MissingStageImportTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.csv = self.root / "manifest.csv"
        self.db = self.root / "snapshot.sqlite"
        self.entries = []
        for n in range(206):
            qid = 10000 + n
            stages = (["progress"] if n < 204 else ["complete"])
            if n == 0:
                stages.append("complete")
            text = {stage: f"Unique test dialogue {qid} {stage} with $N and $B" for stage in stages}
            self.entries.append((qid, text))
        with sqlite3.connect(self.db) as db:
            db.execute("CREATE TABLE quests (entry INTEGER, title TEXT, details TEXT, requesttext TEXT, offertext TEXT)")
            db.executemany("INSERT INTO quests VALUES (?, ?, ?, ?, ?)", [
                (qid, f"Quest {qid}", "", t.get("progress", ""), t.get("complete", ""))
                for qid, t in self.entries
            ])
        self.write_manifest()

    def write_manifest(self, bad_stage=None):
        fieldnames = ["quest_id", "catalog_title", "category", "stage", "source_present",
                      "source_diff_baseline", "source_chars", "source_sha256",
                      "spoken_present", "turtle_overlay_present", "coverage",
                      "source_migration_modified_stage"]
        with self.csv.open("w", newline="", encoding="utf-8") as stream:
            writer = csv.DictWriter(stream, fieldnames=fieldnames)
            writer.writeheader()
            for qid, texts in self.entries:
                for stage, raw in texts.items():
                    writer.writerow({
                        "quest_id": qid, "catalog_title": f"Quest {qid}",
                        "category": "dialogue_difference_candidate", "stage": stage,
                        "source_present": 1, "source_diff_baseline": 1,
                        "source_chars": len(raw), "source_sha256": audit.sha(audit.content(raw)),
                        "spoken_present": 1 if bad_stage == (qid, stage) else 0,
                        "turtle_overlay_present": 0, "coverage": "turtle_stage_missing",
                        "source_migration_modified_stage": 1,
                    })

    def test_all_207_hashes_and_stage_distribution(self):
        records = missing.select_manifest(self.csv)
        self.assertEqual(len(records), 207)
        texts = missing.load_verified_source(self.db, records)
        self.assertEqual(len(texts), 206)
        self.assertEqual(len(texts[10000]), 2)

    def test_generated_lua_preserves_original_and_first_batch(self):
        records = missing.select_manifest(self.csv)
        texts = missing.load_verified_source(self.db, records)
        original = ('SSCTurtleQuestText = SSCTurtleQuestText or {}\n'
                    'SSCTurtleQuestText[40001] = {accept="Keep"}\n'
                    '-- BEGIN Turtle-touched first batch (generated; local only)\n'
                    'SSCTurtleQuestText[820] = SSCTurtleQuestText[820] or {}\n'
                    'SSCTurtleQuestText[820].accept = "Existing"\n'
                    '-- END Turtle-touched first batch\n')
        generated = missing.render_batch(texts)
        updated = missing.merge_batch(original, generated, set(texts))
        self.assertTrue(updated.startswith(original))
        self.assertIn('SSCTurtleQuestText[40001] = {accept="Keep"}', updated)
        self.assertIn('SSCTurtleQuestText[820].accept = "Existing"', updated)
        self.assertEqual(updated.count(missing.BEGIN), 1)
        self.assertEqual(updated.count(missing.END), 1)
        self.assertEqual(len([line for line in updated.splitlines() if ".progress =" in line]), 204)
        self.assertEqual(len([line for line in updated.splitlines() if ".complete =" in line]), 3)
        self.assertEqual(updated, missing.merge_batch(updated, generated, set(texts)))

    def test_existing_quest_collision_fails(self):
        original = ('SSCTurtleQuestText = SSCTurtleQuestText or {}\n'
                    'SSCTurtleQuestText[10001] = {progress="Curated"}\n')
        with self.assertRaisesRegex(ValueError, "Other Turtle text exists"):
            missing.merge_batch(original, missing.BEGIN + "\n" + missing.END + "\n", {10001})

    def test_other_stage_on_same_quest_survives_reimport(self):
        # Quest 9057 has an approved Tier 3 completion alongside a
        # previously imported missing progress stage. Both must survive.
        original = ('SSCTurtleQuestText = SSCTurtleQuestText or {}\n'
                    'SSCTurtleQuestText[9057] = SSCTurtleQuestText[9057] or {}\n'
                    'SSCTurtleQuestText[9057].complete = "Reviewed Tier 3 line"\n')
        generated = (missing.BEGIN + '\n'
                     'SSCTurtleQuestText[9057] = SSCTurtleQuestText[9057] or {}\n'
                     'SSCTurtleQuestText[9057].progress = "Missing progress"\n'
                     + missing.END + '\n')
        merged = missing.merge_batch(original, generated, {9057})
        self.assertTrue(merged.startswith(original))
        self.assertIn('SSCTurtleQuestText[9057].progress = "Missing progress"', merged)
        self.assertIn('SSCTurtleQuestText[9057].complete = "Reviewed Tier 3 line"', merged)
        self.assertEqual(merged, missing.merge_batch(merged, generated, {9057}))

    def test_existing_same_stage_assignment_is_refused(self):
        original = ('SSCTurtleQuestText = SSCTurtleQuestText or {}\n'
                    'SSCTurtleQuestText[9057].progress = "Must remain"\n')
        generated = (missing.BEGIN + '\n'
                     'SSCTurtleQuestText[9057].progress = "Bad overwrite"\n'
                     + missing.END + '\n')
        with self.assertRaisesRegex(ValueError, "already occupies stages"):
            missing.merge_batch(original, generated, {9057})

    def test_existing_spoken_text_is_ineligible(self):
        self.write_manifest(bad_stage=(10000, "progress"))
        with self.assertRaisesRegex(ValueError, "Unsafe source or existing dialogue"):
            missing.select_manifest(self.csv)

    def test_source_hash_mismatch_fails(self):
        with sqlite3.connect(self.db) as db:
            db.execute("UPDATE quests SET requesttext='Different' WHERE entry=10001")
        with self.assertRaisesRegex(ValueError, "source hash changed"):
            missing.load_verified_source(self.db, missing.select_manifest(self.csv))

    def test_three_reviewed_progress_corrections(self):
        corrections = __import__("json").loads(
            missing.CURATED_CORRECTIONS.read_text(encoding="utf-8"))["corrections"]
        originals = {int(r["quest_id"]): {"progress": "Wrong source text"}
                     for r in corrections}
        fixed = missing.apply_curated_progress_corrections(originals)
        self.assertEqual(set(fixed), {6283,8051,8146})
        for item in corrections:
            qid = int(item["quest_id"])
            self.assertEqual(fixed[qid]["progress"], item["text"])
            self.assertNotIn("Wrong source text", fixed[qid]["progress"])
        self.assertIn("Bloodfury Ripper", fixed[6283]["progress"])
        self.assertIn("Gurubashi", fixed[8051]["progress"])
        self.assertIn("smell you again", fixed[8146]["progress"])

    def test_source_verification_still_precedes_reviewed_repair(self):
        # Source hashes were not weakened to accommodate the three repairs.
        originals = {6283: {"progress": "Known bad source"},
                     8051: {"progress": "Known bad source"},
                     8146: {"progress": "Known bad source"}}
        originals[6283]["progress"] = "Different"
        with self.assertRaisesRegex(ValueError, "incorrect pinned progress stage"):
            # A corrected stage already present must not be silently rewritten.
            import json
            curated = json.loads(missing.CURATED_CORRECTIONS.read_text())["corrections"]
            for row in curated:
                if int(row["quest_id"]) == 6283:
                    originals[6283]["progress"] = row["text"]
            missing.apply_curated_progress_corrections(originals)

    def test_blank_destination_fails(self):
        with self.assertRaisesRegex(ValueError, "blank file"):
            missing.merge_batch("", missing.BEGIN + "\n" + missing.END + "\n", set())


if __name__ == "__main__":
    unittest.main()
