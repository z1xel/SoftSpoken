import copy
import unittest
from finalize_octo import finalize, runtime_payload
from bootstrap_octo import reconcile, PROFILE
from test_octo_bootstrap import OctoBootstrapTests


class FinalizeTests(unittest.TestCase):
    def test_scoped_native_maps(self):
        seed,research,tables,refs=OctoBootstrapTests().fixture()
        decisions,_=reconcile(seed,research,tables,refs)
        before=copy.deepcopy(decisions)
        refs=list(refs)+[dict(sourceScope="spoken_classic",namespace="legacyPlace",value=2482,area="")]
        result,report=finalize(decisions,tables,refs)
        self.assertEqual(decisions,before)
        self.assertEqual((result,report),finalize(decisions,tables,refs))
        bindings=result["profileOverlays"][PROFILE]["addBindings"]
        self.assertTrue(any(b["namespace"]=="nativeUiMap" and b["value"]==12 and b["location"]=="elwynn_forest" for b in bindings))
        self.assertEqual(report["contentCounts"]["excluded"],1)
        self.assertEqual(report["nativeMapHolds"],[])
        self.assertEqual(result["identities"],decisions["identities"])
        with self.assertRaises(ValueError):
            finalize(result,tables,refs)

    def test_fixed_runtime_view(self):
        seed,research,tables,refs=OctoBootstrapTests().fixture()
        decisions,_=reconcile(seed,research,tables,refs)
        result,_=finalize(decisions,tables,refs)
        payload=runtime_payload(result)
        self.assertEqual(payload["world"],"octo")
        self.assertEqual(payload["scope"],PROFILE)
        self.assertIn("elwynn_forest",payload["view"]["entities"])
        self.assertTrue(any(r["namespace"]=="nativeUiMap" for r in payload["view"]["bindings"]))
        self.assertNotIn("profiles",payload)
        self.assertNotIn("profileOverlays",payload)
        self.assertNotIn("worldOverlays",payload)
