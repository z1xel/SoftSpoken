"""Static Vanilla + Turtle corpus excludes unverified Forever-only quest IDs."""
import csv
import re
import subprocess
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def rows(name):
    with (ROOT / "docs" / name).open(newline="", encoding="utf-8") as stream:
        return list(csv.DictReader(stream))


class ForeverCorpusCleanup(unittest.TestCase):
    def test_exclusion_manifest_is_explicit_and_grounded(self):
        excluded = rows("forever_quest_exclusions.csv")
        ids = [int(row["quest_id"]) for row in excluded]
        self.assertEqual(len(ids), 600)
        self.assertEqual(len(set(ids)), 600)
        self.assertTrue(all(id >= 20000 for id in ids))
        self.assertEqual(
            sum(row["original_spoken_text"] == "1" for row in excluded), 575)
        self.assertTrue(all(row["reason"] ==
                            "absent_from_pinned_vanilla_and_curated_turtle"
                            for row in excluded))
        vanilla = {int(line) for line in
                   (ROOT / "docs/vanilla_pfquest_ids.txt").read_text().splitlines()
                   if line}
        turtle = {int(row["quest_id"]) for row in
                  rows("turtle_exclusive_import.csv")
                  if row["status"] in ("imported", "already_present")}
        self.assertEqual(len(vanilla), 4433)
        self.assertEqual(len(turtle), 2377)
        self.assertFalse(set(ids) & (vanilla | turtle))

    def test_both_runtime_files_are_fully_clean(self):
        p = subprocess.run(
            [sys.executable, "scripts/clean_forever_quest_data.py", "--check"],
            cwd=ROOT, capture_output=True, text=True)
        self.assertEqual(p.returncode, 0, p.stdout + p.stderr)

    def test_keeps_original_vanilla_chain_and_rejects_forever_predecessors(self):
        from scripts.clean_forever_quest_data import sections, CATALOG_ROW
        catalog = (ROOT / "SoftSpoken_Stories/Data/Compendium.lua").read_text()
        start, end, _, _ = sections(catalog)
        records = {int(m[1]): m[0] for m in CATALOG_ROW.finditer(catalog[start:end])}
        self.assertEqual(len(records), 6646)
        catalog_sorts = catalog.split("\\n\\tsorts = {",1)[1]
        self.assertNotIn("[666] = {", catalog_sorts, "Forever Camping category restored")
        self.assertIn('[676] = { "Night Elf"', catalog_sorts,
                      "Original Night Elf category was removed")
        self.assertIn(666, records)
        self.assertIn(676, records)
        self.assertIn("Sunken Treasure", records[666])
        self.assertIn("The Hammer May Fall", records[676])
        self.assertIn("prev = 666", records[668])
        self.assertIn("prev = 676", records[677])
        self.assertNotIn("prev = 97894", records[982])
        self.assertNotIn("prev = 98391", records[2519])
        vanilla = {int(line) for line in
                   (ROOT / "docs/vanilla_pfquest_ids.txt").read_text().splitlines()
                   if line}
        self.assertEqual(len(set(records) & vanilla), 4265,
                         "Originally retained Vanilla quest identities changed")

    def test_original_dialogue_preserved_for_all_retained_ids(self):
        # The cleaner never substitutes or rewrites text. It only deletes
        # whole dialogue records enumerated in the manifest.
        original = (ROOT / "SoftSpoken_Stories/Data/QuestText.lua").read_text()
        ids = [int(x) for x in re.findall(r"(?m)^\t\[(\d+)\] = \{$", original)]
        self.assertEqual(len(ids), 4228)
        self.assertNotIn(92460, ids)  # Forever Skyborne starting-zone quest
        self.assertIn(2, ids)        # Original Vanilla dialogue retained
        self.assertIn(820, ids) if 820 in ids else None  # Turtle overlay is separate


if __name__ == "__main__":
    unittest.main()
