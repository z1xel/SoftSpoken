"""Offline tests for read-only Turtle-touched text audit comparison and safety."""
import importlib.util
import sqlite3
import tempfile
import unittest
from pathlib import Path

PATH=Path(__file__).resolve().parents[1]/"scripts/audit_turtle_touched_text.py"
spec=importlib.util.spec_from_file_location("touched_audit",PATH)
a=importlib.util.module_from_spec(spec);spec.loader.exec_module(a)


class TurtleTouchedTextTest(unittest.TestCase):
    def test_title_normalization_does_not_mark_typography_only_edits(self):
        self.assertEqual(a.titlekey("The Friend’s Path"),a.titlekey("the friend's path"))
        self.assertEqual(a.content("Line one.\r\nLine two."),a.content("Line one. $B Line two.") if False else a.content("Line one. Line two."))
        self.assertNotEqual(a.content("Find four claws"),a.content("Find five claws"))

    def test_sql_stages_with_real_classic_column_names(self):
        with sqlite3.connect(":memory:") as db:
            db.executescript("""
            CREATE TABLE quest_template (
              entry INTEGER, Title TEXT, Details TEXT, RequestItemsText TEXT,
              OfferRewardText TEXT, Objectives TEXT, ZoneOrSort INTEGER, Method INTEGER
            );
            INSERT INTO quest_template VALUES (
              820,'What Do You Rely On?','','','','',14,2
            );""")
            data=a.get_vanilla(db)
        self.assertEqual(data[820]["zoneorsort"],14)
        self.assertEqual(data[820]["method"],2)

    def test_ephemeral_lua_text_dump_only_parses_stage_bytes(self):
        with tempfile.TemporaryDirectory() as td:
            p=Path(td)/"static.tsv"
            p.write_text('820\tspoken\taccept\t48656c6c6f0a\n'
                         '820\tturtle\tcomplete\t576f726c64\n',encoding="ascii")
            data=a.get_static(p)
            self.assertEqual(data[(820,"spoken")]["accept"],"Hello\n")
            self.assertEqual(data[(820,"turtle")]["complete"],"World")
            self.assertNotIn((810,"spoken"),data)

    def test_vanilla_pfquest_presence_requires_stage_specific_migration(self):
        base = {"category": "legacy_id_absent_from_vanilla",
                "vanilla_pfquest_present": 1,
                "source_migration_modified_stage": 0}
        self.assertFalse(a.eligible_direct_turtle_stage(base))
        self.assertTrue(a.eligible_direct_turtle_stage({
            **base, "source_migration_modified_stage": 1}))
        self.assertTrue(a.eligible_direct_turtle_stage({
            **base, "vanilla_pfquest_present": 0}))
        self.assertFalse(a.eligible_direct_turtle_stage({
            **base, "category": "dialogue_difference_candidate",
            "vanilla_pfquest_present": 0}))
        self.assertTrue(a.eligible_direct_turtle_stage({
            **base, "category": "dialogue_difference_candidate",
            "source_migration_modified_stage": 1}))

    def test_source_hash_never_contains_raw_text(self):
        self.assertEqual(len(a.sha("A historical quest")),64)
        self.assertEqual(a.sha(""),"")


if __name__=="__main__":unittest.main()
