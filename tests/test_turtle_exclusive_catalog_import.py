"""Regression for the exact 2026-10-14 Turtle-only quest catalog import.

Run: python3 tests/test_turtle_exclusive_catalog_import.py
No external download or voice pack required.
"""
import collections
import csv
import json
import re
import subprocess
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "SoftSpoken_Stories" / "Data" / "Compendium.lua"
MANIFEST = ROOT / "docs" / "turtle_exclusive_import.csv"
NAMES = ROOT / "docs" / "turtle_exclusive_speaker_names.csv"


def records(path):
    with path.open(encoding="utf-8", newline="") as stream:
        return list(csv.DictReader(stream))


def catalog():
    text = CATALOG.read_text(encoding="utf-8")
    section = text.split("\tquests = {", 1)[1].split("\n\t},\n\n\tsorts = {", 1)[0]
    rows = {}
    for match in re.finditer(r"^\s*\[(\d+)\]\s*=\s*(\{[^\n]*\}),", section, re.M):
        quest_id = int(match[1])
        if quest_id in rows:
            raise AssertionError("Duplicate quest " + str(quest_id))
        rows[quest_id] = match[2]
    return text, rows


class TurtleExclusiveCatalogTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.text, cls.catalog = catalog()
        cls.source = records(MANIFEST)
        cls.names = records(NAMES)

    def test_whole_source_accounted_for(self):
        self.assertEqual(len(self.source), 2451)
        self.assertEqual(len(self.catalog), 7246)
        counts = collections.Counter(r["status"] for r in self.source)
        self.assertEqual(counts, {"imported": 2247,
                                  "already_present": 130,
                                  "excluded_nonplayable": 74})
        self.assertEqual(len({int(r["quest_id"]) for r in self.source}), 2451)

    def test_imported_records_exact_and_existing_unchanged(self):
        for row in self.source:
            quest_id = int(row["quest_id"])
            with self.subTest(quest=quest_id):
                if row["status"] == "imported":
                    self.assertIn(quest_id, self.catalog)
                    self.assertEqual(self.catalog[quest_id] + ",",
                                     row["compendium_row"].split(" = ", 1)[1])
                elif row["status"] == "excluded_nonplayable":
                    self.assertNotIn(quest_id, self.catalog)
                else:
                    self.assertIn(quest_id, self.catalog)

    def test_relationship_provenance_and_ambiguity(self):
        imports = [r for r in self.source if r["status"] == "imported"]
        number = lambda r, stage: sum(
            len(r[stage + "_" + kind].split(";"))
            for kind in ("U", "O", "I") if r[stage + "_" + kind]
        )
        self.assertEqual(sum(number(r, "starter") == 0 for r in imports), 31)
        self.assertEqual(sum(number(r, "ender") == 0 for r in imports), 31)
        self.assertEqual(sum(number(r, "starter") > 1 for r in imports), 15)
        self.assertEqual(sum(number(r, "ender") > 1 for r in imports), 9)
        for r in imports:
            if number(r, "starter") > 1:
                self.assertIn("starters = {", self.catalog[int(r["quest_id"])])
            if number(r, "ender") > 1:
                self.assertIn("enders = {", self.catalog[int(r["quest_id"])])
        self.assertIn("races = 8589934770", self.catalog[40001])
        self.assertIn("races = 4294967373", self.catalog[40545])
        self.assertIn("starterObject = 1000505", self.catalog[41947])
        self.assertIn("ender = 63047", self.catalog[41948])

    def test_native_name_fallbacks_preserve_source(self):
        self.assertEqual(len(self.names), 884)
        self.assertEqual(collections.Counter(r["kind"] for r in self.names),
                         {"U": 787, "O": 35, "I": 62})
        for kind, table in (("U", "npcNames"), ("O", "objectNames"),
                            ("I", "itemNames")):
            body = self.text.split("\t" + table + " = {\n", 1)[1].split(
                "\n\t},", 1)[0]
            for record in self.names:
                if record["kind"] == kind:
                    line = "[%d] = %s," % (
                        int(record["id"]),
                        json.dumps(record["name"], ensure_ascii=False))
                    self.assertIn(line, body)

    def test_reapply_is_idempotent(self):
        proc = subprocess.run(
            [sys.executable, "scripts/reapply_turtle_quest_catalog.py",
             "--check"], cwd=ROOT, text=True, capture_output=True)
        self.assertEqual(proc.returncode, 0, proc.stdout + proc.stderr)


if __name__ == "__main__":
    unittest.main()
