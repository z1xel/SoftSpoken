import copy
import unittest
from finalize_octo import finalize
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
