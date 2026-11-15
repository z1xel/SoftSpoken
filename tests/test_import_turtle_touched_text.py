"""Synthetic regression tests for first-batch Turtle-only dialogue import."""
import csv
import hashlib
import importlib.util
import sqlite3
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
import audit_turtle_touched_text as audit
import import_turtle_touched_text as imp


class FirstBatchImportTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.folder = Path(self.tmp.name)
        self.database = self.folder / "source.sqlite"
        self.manifest = self.folder / "manifest.csv"
        self.source_rows = []
        for qid, stages in imp.FIRST_BATCH.items():
            title = f"Quest {qid}"
            values = {stage: f"Test dialogue for {qid} {stage} with $B and $N" for stage in imp.STAGE_COLUMNS}
            self.source_rows.append((qid, title, values))
        with sqlite3.connect(self.database) as db:
            db.execute("CREATE TABLE quests (entry INTEGER, title TEXT, details TEXT, requesttext TEXT, offertext TEXT)")
            db.executemany("INSERT INTO quests VALUES (?, ?, ?, ?, ?)", [
                (qid, title, texts["accept"], texts["progress"], texts["complete"])
                for qid, title, texts in self.source_rows])
        self.write_manifest()

    def write_manifest(self, bad_hash=False):
        fields = ["quest_id", "catalog_title", "category", "stage", "source_present",
                  "spoken_matches_turtle", "turtle_overlay_present", "coverage",
                  "source_migration_modified_stage", "vanilla_pfquest_present",
                  "source_chars", "source_sha256"]
        with self.manifest.open("w", encoding="utf-8", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=fields)
            writer.writeheader()
            for qid, title, texts in self.source_rows:
                for stage in imp.FIRST_BATCH[qid]:
                    raw = texts[stage]
                    writer.writerow({
                        "quest_id": qid, "catalog_title": title,
                        "category": "legacy_id_absent_from_vanilla",
                        "stage": stage, "source_present": 1,
                        "spoken_matches_turtle": 0, "turtle_overlay_present": 0,
                        "coverage": "turtle_stage_missing",
                        "source_migration_modified_stage": int(qid == 3111),
                        "vanilla_pfquest_present": int(qid == 3111),
                        "source_chars": len(raw),
                        "source_sha256": "0" * 64 if bad_hash and qid == 820 and stage == "accept"
                                         else audit.sha(audit.content(raw))
                    })

    def test_only_selected_13_stage_hashes_pass(self):
        selected = imp.select_manifest(self.manifest)
        self.assertEqual(len(selected), 13)
        texts = imp.load_verified_source(self.database, selected)
        self.assertEqual(set(texts), set(imp.FIRST_BATCH))
        self.assertEqual(set(texts[3111]), {"accept"})
        self.assertEqual(set(texts[820]), {"accept", "progress", "complete"})

    def test_local_merge_preserves_other_turtle_quests(self):
        selected = imp.select_manifest(self.manifest)
        texts = imp.load_verified_source(self.database, selected)
        old = 'SSCTurtleQuestText = SSCTurtleQuestText or {}\nSSCTurtleQuestText[40001] = {accept="Keep"}\n'
        generated = imp.format_batch(texts)
        merged = imp.merge_local_overlay(old, generated, set(texts))
        self.assertIn('SSCTurtleQuestText[40001] = {accept="Keep"}', merged)
        self.assertIn('SSCTurtleQuestText[820].accept = ', merged)
        self.assertIn('SSCTurtleQuestText[3111].accept = ', merged)
        self.assertNotIn('SSCTurtleQuestText[3111].progress', merged)
        self.assertEqual(merged.count(imp.BEGIN), 1)
        self.assertEqual(merged.count(imp.END), 1)

    def test_second_import_replaces_only_generated_region(self):
        selected = imp.select_manifest(self.manifest)
        texts = imp.load_verified_source(self.database, selected)
        generated = imp.format_batch(texts)
        old = 'SSCTurtleQuestText = SSCTurtleQuestText or {}\nSSCTurtleQuestText[40001] = {accept="Keep"}\n'
        first = imp.merge_local_overlay(old, generated, set(texts))
        second = imp.merge_local_overlay(first, generated, set(texts))
        self.assertEqual(first, second)

    def test_hash_change_refuses_import(self):
        self.write_manifest(bad_hash=True)
        with self.assertRaisesRegex(ValueError, "source hash changed"):
            imp.load_verified_source(self.database, imp.select_manifest(self.manifest))

    def test_collision_refuses_overwrite(self):
        original = 'SSCTurtleQuestText = SSCTurtleQuestText or {}\nSSCTurtleQuestText[820] = {accept="Curated"}\n'
        with self.assertRaisesRegex(ValueError, "already appears"):
            imp.merge_local_overlay(original, imp.BEGIN + "\n" + imp.END + "\n", {820})

    def test_vanilla_pfquest_unmigrated_stage_refused(self):
        rows = list(csv.DictReader(self.manifest.open(encoding="utf-8", newline="")))
        for row in rows:
            if row["quest_id"] == "3111" and row["stage"] == "accept":
                row["source_migration_modified_stage"] = "0"
        with self.manifest.open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=rows[0].keys())
            writer.writeheader()
            writer.writerows(rows)
        with self.assertRaisesRegex(ValueError, "not directly supported"):
            imp.select_manifest(self.manifest)


if __name__ == "__main__":
    unittest.main()
