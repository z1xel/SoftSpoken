"""Read-only offline voice-pack auditor tests; no actual MP3 decode needed."""
import importlib.util
import json
from pathlib import Path
from tempfile import TemporaryDirectory
from types import SimpleNamespace
import unittest
from unittest.mock import patch

path = Path(__file__).resolve().parents[1] / "scripts" / "audio_pack_audit.py"
spec = importlib.util.spec_from_file_location("audio_pack_audit", path)
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)


class AuditorTests(unittest.TestCase):
    def test_ffprobe_metadata(self):
        p = SimpleNamespace(
            returncode=0,
            stdout=json.dumps({"format": {"duration": "15.202",
                                          "bit_rate": "192000"},
                               "streams": [{"codec_type": "audio",
                                            "codec_name": "mp3"}]}),
            stderr=""
        )
        with patch.object(audit.subprocess, "run", return_value=p):
            result = audit.probe(Path("unmodified.mp3"))
        self.assertEqual(result["duration_seconds"], 15.202)
        self.assertEqual(result["codec"], "mp3")
        self.assertEqual(result["bit_rate_kbps"], 192.0)

    def test_loudnorm_measures_input_and_writes_null(self):
        p = SimpleNamespace(returncode=0, stdout="", stderr="""
        [Parsed_loudnorm_0] { "input_i" : "-21.34",
        "input_tp" : "-3.15", "input_lra" : "5.4", "input_thresh" : "-31" }
        """)
        with patch.object(audit.subprocess, "run", return_value=p) as run:
            result = audit.loudness(Path("unchanged.mp3"))
        self.assertEqual(result["integrated_lufs"], "-21.34")
        self.assertEqual(result["true_peak_dbfs"], "-3.15")
        self.assertEqual(result["loudness_range_lu"], "5.4")
        cmd = run.call_args.args[0]
        self.assertEqual(cmd[-3:], ["-f", "null", "-"])
        self.assertNotIn("-y", cmd)

    def test_scanner_skips_symlinks_non_mp3_and_honors_limit(self):
        with TemporaryDirectory() as tmp:
            root = Path(tmp)
            folder = root / "SoftSpokenAudio"
            folder.mkdir()
            for name in ["01.mp3", "02.MP3", "metadata.lua"]:
                (folder / name).write_bytes(b"fake data")
            candidates = list(audit.files_under(root, 1))
            self.assertEqual(len(candidates), 1)
            self.assertEqual(candidates[0].suffix.lower(), ".mp3")
            self.assertEqual(len(list(audit.files_under(root, None))), 2)
            (folder / "link.mp3").symlink_to(folder / "01.mp3")
            self.assertEqual(len(list(audit.files_under(root, None))), 2)

    def test_failed_probe_reports_error_without_touching_file(self):
        with TemporaryDirectory() as tmp:
            root = Path(tmp)
            folder = root / "Pack"
            folder.mkdir()
            clip = folder / "broken.mp3"
            clip.write_bytes(b"broken")
            before = clip.read_bytes()
            failure = SimpleNamespace(returncode=1, stdout="", stderr="cannot decode")
            with patch.object(audit.subprocess, "run", return_value=failure):
                rows = list(audit.audit(root, False, 10))
            self.assertEqual(len(rows), 1)
            self.assertIn("cannot decode", rows[0]["error"])
            self.assertEqual(clip.read_bytes(), before)


if __name__ == "__main__":
    unittest.main()
