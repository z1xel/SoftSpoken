"""Regression for shared Vanilla-ID quest coverage imported from the Turtle patch.
Run from repo root: python -m unittest tests/test_turtle_shared_id_coverage.py
The manifest documents the original 175 'unchanged' shared-ID omissions.
"""
import csv
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs" / "turtle_shared_id_coverage.csv"
COMPENDIUM = ROOT / "SoftSpoken_Stories" / "Data" / "Compendium.lua"


class TurtleSharedIDCoverage(unittest.TestCase):
    def test_import_and_explicit_removals(self):
        with MANIFEST.open(newline="", encoding="utf-8") as f:
            source = list(csv.DictReader(f))
        self.assertEqual(len(source), 175)
        by_status = {}
        for entry in source:
            by_status.setdefault(entry["classification"], []).append(entry)
        self.assertEqual(len(by_status["imported"]), 28)
        self.assertEqual(len(by_status["removed_by_turtle"]), 146)
        self.assertEqual(len(by_status["excluded_internal"]), 1)

        body = COMPENDIUM.read_text(encoding="utf-8")
        quest_section = body.split("\\tquests = {", 1)[1].split(
            "\\t},\\n\\n\\tsorts = {", 1
        )[0]
        actual = {
            int(m.group(1)): m.group(2)
            for m in re.finditer(r"^\\s*\\[(\\d+)\\]\\s*=\\s*\\{([^\\n]*)", quest_section, re.M)
        }
        for entry in by_status["imported"]:
            qid = int(entry["quest_id"])
            with self.subTest(quest=qid):
                self.assertIn(qid, actual)
                title = entry["title"].replace("\\\\", "\\\\\\\\").replace('"', '\\\\"')
                self.assertIn('"' + title + '"', actual[qid])
                for direction in ("starter", "ender"):
                    rel = entry["turtle_" + direction]
                    if not rel:
                        continue
                    match = re.fullmatch(r"([UOI]):(\\d+)", rel)
                    self.assertIsNotNone(match)
                    typ, value = match.groups()
                    field = direction + ("" if typ == "U" else
                                         "Object" if typ == "O" else "Item")
                    if direction == "ender" and entry["turtle_starter"] == rel:
                        continue  # same giver is implicit
                    self.assertIn(field + " = " + value, actual[qid])
        for category in ("removed_by_turtle", "excluded_internal"):
            for entry in by_status[category]:
                self.assertNotIn(int(entry["quest_id"]), actual)


if __name__ == "__main__":
    unittest.main()
