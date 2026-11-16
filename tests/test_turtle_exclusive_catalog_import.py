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
ZONES = ROOT / "docs" / "tortoise_zone_overlay.csv"
SPEAKERS = ROOT / "docs" / "turtle_speaker_recovery.csv"
APPROVED_TITLE_ALIAS = ROOT / "docs/audits/turtle_hold_resolution/approved_41797_identity.json"


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
        cls.zone_overlay = {
            int(r["quest_id"]): r for r in records(ZONES)
        }
        cls.speaker_overlay = collections.defaultdict(list)
        for r in records(SPEAKERS):
            cls.speaker_overlay[int(r["quest_id"])].append(r)

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
                    actual = self.catalog[quest_id]
                    # Remove ONLY the precise, approved generated classification.
                    # All original starter/ender/race/chain fields must still match
                    # the frozen pfQuest Turtle import verbatim.
                    overlay = self.zone_overlay.get(quest_id)
                    if overlay:
                        kind, value = overlay["classification"], int(overlay["value"])
                        field = ("zones = {" + str(value) + "}" if kind == "zones"
                                 else kind + " = " + str(value))
                        suffix = ", " + field + " }"
                        self.assertTrue(actual.endswith(suffix),
                                        "Quest overlay not at end of quest row")
                        actual = actual[:-len(suffix)] + " }"
                    # Quest 41797's independently corroborated Northwind
                    # classification is a separate reviewed alias, not part
                    # of the original frozen pfQuest or bulk zone manifest.
                    if quest_id == 41797:
                        self.assertIn(", turtleArea = 5581 }", actual)
                        actual = actual.replace(", turtleArea = 5581 }", " }", 1)
                    # Remove ONLY the exact reviewed NPC role overlay,
                    # leaving the original pfQuest manifest row immutable.
                    for record in self.speaker_overlay.get(quest_id, []):
                        assignment = ", " + record["field"] + " = " + record["entity_id"]
                        self.assertIn(assignment, actual)
                        actual = actual.replace(assignment, "", 1)
                    self.assertEqual(actual + ",",
                                     row["compendium_row"].split(" = ", 1)[1])
                elif row["status"] == "excluded_nonplayable":
                    self.assertNotIn(quest_id, self.catalog)
                else:
                    self.assertIn(quest_id, self.catalog)

    def test_approved_alias_does_not_rename_original_quest(self):
        approved = json.loads(APPROVED_TITLE_ALIAS.read_text(encoding="utf-8"))
        self.assertEqual(approved["quest_id"],41797)
        self.assertEqual(approved["catalog_title"],"A Good Friend")
        self.assertEqual(approved["source_title"],"A Dear Friend")
        self.assertIn('"A Good Friend"',self.catalog[41797])
        self.assertIn("starter = 228, ender = 62307, turtleArea = 5581",
                      self.catalog[41797])
        self.assertIn("Northwind",approved["region"])

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

    def test_recovered_missing_speaker_roles(self):
        approved = [r for rows in self.speaker_overlay.values() for r in rows]
        self.assertEqual(len(approved), 20)
        self.assertEqual(len(self.speaker_overlay), 11)
        for row in approved:
            qid = int(row["quest_id"])
            self.assertIn(row["field"] + " = " + row["entity_id"], self.catalog[qid])

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
