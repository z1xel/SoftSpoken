"""Unsupported map IDs must never leak into the shared geographical registry."""
import unittest
from build import EXCLUDED_SPOKEN_MAPS, excluded_content_map, content_report, check_id


class ContentExclusionTests(unittest.TestCase):
    def test_forever_references_excluded(self):
        refs = []
        for value in EXCLUDED_SPOKEN_MAPS:
            for namespace, area in (("upstreamUiMap", None), ("legacyPlace", ""), ("legacyPlace", "example")):
                ref = dict(sourceScope="spoken_classic", namespace=namespace, value=value)
                if area is not None: ref["area"] = area
                refs.append(ref)
        report = content_report(refs, [], {})
        self.assertTrue(all(r["status"] == "excluded" and "location" not in r for r in report))
        for ref in refs:
            with self.assertRaisesRegex(ValueError, "excluded WoW Forever"):
                content_report([ref], [dict(ref,status="mapped",location="hyjal",reason="bad alias")],
                               {"hyjal":{"status":"active"}})

    def test_scope_isolation(self):
        for value in EXCLUDED_SPOKEN_MAPS:
            with self.assertRaisesRegex(ValueError, "excluded WoW Forever"):
                check_id(dict(scope="spoken_classic",namespace="upstreamUiMap",value=value),
                         {"spoken_classic":"content"})
            check_id(dict(scope="octo_20261126",namespace="areaTable",value=value),
                     {"octo_20261126":"native"})
        check_id(dict(scope="octo_20261126",namespace="areaTable",value=616),
                 {"octo_20261126":"native"})
        self.assertFalse(excluded_content_map("spoken_classic","upstreamUiMap",616))
        self.assertFalse(excluded_content_map("other_scope","upstreamUiMap",2482))
