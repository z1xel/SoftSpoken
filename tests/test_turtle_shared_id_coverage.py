"""Validate curated shared Vanilla-ID quest imports and Turtle removals.
Run from repo root: python tests/test_turtle_shared_id_coverage.py
The manifest classifies the original 175 unchanged shared-ID omissions.
"""
import csv
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs" / "turtle_shared_id_coverage.csv"
COMPENDIUM = ROOT / "SoftSpoken_Stories" / "Data" / "Compendium.lua"


class TurtleSharedIDCoverage(unittest.TestCase):
    def test_imports_and_removals(self):
        with MANIFEST.open(newline="", encoding="utf-8") as file:
            source = list(csv.DictReader(file))

        self.assertEqual(len(source), 175)
        by_status = {}
        for entry in source:
            by_status.setdefault(entry["classification"], []).append(entry)
        self.assertEqual(len(by_status["imported"]), 28)
        self.assertEqual(len(by_status["removed_by_turtle"]), 146)
        self.assertEqual(len(by_status["excluded_internal"]), 1)

        content = COMPENDIUM.read_text(encoding="utf-8")
        section = content.split("\tquests = {", 1)[1].split(
            "\t},\n\n\tsorts = {", 1
        )[0]
        records = {
            int(match.group(1)): match.group(2)
            for match in re.finditer(
                r"^\s*\[(\d+)\]\s*=\s*\{([^\n]*)", section, re.M
            )
        }

        for entry in by_status["imported"]:
            quest_id = int(entry["quest_id"])
            with self.subTest(quest=quest_id):
                self.assertIn(quest_id, records)
                title = entry["title"].replace("\\", "\\\\").replace('"', '\\"')
                self.assertIn('"' + title + '"', records[quest_id])
                for direction in ("starter", "ender"):
                    relation = entry["turtle_" + direction]
                    if not relation:
                        continue
                    match = re.fullmatch(r"([UOI]):(\d+)", relation)
                    self.assertIsNotNone(match)
                    kind, value = match.groups()
                    field = direction + (
                        "" if kind == "U" else "Object" if kind == "O" else "Item"
                    )
                    if direction == "ender" and entry["turtle_starter"] == relation:
                        continue  # identical giver and hand-in are implicit
                    self.assertIn(field + " = " + value, records[quest_id])

        for classification in ("removed_by_turtle", "excluded_internal"):
            for entry in by_status[classification]:
                self.assertNotIn(int(entry["quest_id"]), records)


if __name__ == "__main__":
    unittest.main()
