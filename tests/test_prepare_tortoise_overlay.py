"""Synthetic-only tests for conservative Turtle overlay generation.

No third-party quest prose is included in this repository fixture.
Run: python3 -m unittest discover -s tests -p test_prepare_tortoise_overlay.py
"""
import csv
import json
import sqlite3
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "prepare_tortoise_quest_overlay.py"
FIELDS = ["quest_id", "status", "title"]


class OverlayPreparationTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.work = Path(self.tmp.name)
        self.db = self.work / "fixture.sqlite"
        con = sqlite3.connect(self.db)
        try:
            con.executescript(
                "CREATE TABLE quests (entry INTEGER PRIMARY KEY, title TEXT, zone INTEGER, "
                "details TEXT, requesttext TEXT, offertext TEXT);"
            )
            con.executemany("INSERT INTO quests VALUES (?,?,?,?,?,?)", [
                (10001, "Exact Example", 14, "Hello $N.", "", "Goodbye $C."),
                (10002, "Old Friend’s Example", -82, "Body A", "Body B", "Body C"),
                (10003, "[DEPRECATED] Retired Example", 12, "Outdated A", "Outdated B", "Outdated C"),
                (10004, "Changed Quest", 12, "Other A", "Other B", "Other C"),
                (10005, "Excluded Example", 12, "Skip", "Skip", "Skip"),
            ])
            con.commit()
        finally:
            con.close()
        self.manifest = self.work / "manifest.csv"
        with self.manifest.open("w", newline="", encoding="utf-8") as fh:
            writer = csv.DictWriter(fh, fieldnames=FIELDS)
            writer.writeheader()
            for qid, status, title in [
                (10001, "imported", "Exact Example"),
                (10002, "already_present", "Old Friend's Example"),
                (10003, "already_present", "Retired Example"),
                (10004, "imported", "Completely Different"),
                (10005, "excluded_nonplayable", "Excluded Example"),
            ]:
                writer.writerow({"quest_id": qid, "status": status, "title": title})

    def invoke(self, *args):
        return subprocess.run(
            [sys.executable, str(SCRIPT), "--db", str(self.db), "--manifest",
             str(self.manifest), "--out", str(self.work / "report"), *args],
            cwd=ROOT, capture_output=True, text=True,
        )

    def test_read_only_holds_and_typography(self):
        result = self.invoke()
        self.assertEqual(result.returncode, 0, result.stderr)
        summary = json.loads((self.work / "report" / "summary.json").read_text())
        self.assertEqual(summary["total_targets"], 4)
        self.assertEqual(summary["eligible"], 2)
        self.assertEqual(summary["held"], [10003, 10004])
        self.assertEqual(summary["reason_counts"], {
            "eligible_exact_title": 1,
            "eligible_typography_only": 1,
            "hold_retired_source": 1,
            "hold_title_conflict": 1,
        })
        self.assertFalse((self.work / "TurtleQuestText.lua").exists())

    def test_no_text_export_without_rights_acknowledgement(self):
        path = self.work / "TurtleQuestText.lua"
        result = self.invoke("--emit-text", str(path))
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(path.exists())

    def test_explicit_local_export_contains_only_eligible_quests(self):
        path = self.work / "TurtleQuestText.lua"
        result = self.invoke("--emit-text", str(path), "--acknowledge-rights")
        self.assertEqual(result.returncode, 0, result.stderr)
        content = path.read_text(encoding="utf-8")
        self.assertIn("SSCTurtleQuestText[10001] = {", content)
        self.assertIn('accept = "Hello $N."', content)
        self.assertIn('complete = "Goodbye $C."', content)
        self.assertNotIn("progress = ", content.split("SSCTurtleQuestText[10001]")[1].split("}", 1)[0])
        self.assertIn("SSCTurtleQuestText[10002] = {", content)
        self.assertNotIn("SSCTurtleQuestText[10003]", content)
        self.assertNotIn("SSCTurtleQuestText[10004]", content)
        self.assertNotIn("SSCTurtleQuestText[10005]", content)
        self.assertTrue(content.endswith("\n"))


if __name__ == "__main__":
    unittest.main()
