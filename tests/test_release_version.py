#!/usr/bin/env python3
"""Require the active SoftSpoken release version to agree across every module."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
EXPECTED = "v0.9.2-beta"
version = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
assert version == EXPECTED, f"Unexpected release milestone: {version!r}"

modules = ("SoftSpoken", "SoftSpoken_Stories", "SoftSpoken_Places", "SoftSpoken_Writings")
for module in modules:
    text = (ROOT / module / (module + ".toc")).read_text(encoding="utf-8-sig")
    found = re.findall(r"(?m)^## Version:\s*(\S+)\s*$", text)
    assert found == [version], f"{module}.toc has version {found!r}, expected {version}"

runtime = {
    "SoftSpoken/Environment.lua": r'AddonVersion\s*=\s*"([^"]+)"',
    "SoftSpoken_Stories/Environment.lua": r'AddonVersion\s*=\s*"([^"]+)"',
    "SoftSpoken_Writings/Core.lua": r'Writings\.version\s*=\s*"([^"]+)"',
    "tests/audio_phase2_diagnostics.lua": r'AddonVersion\s*=\s*"([^"]+)"',
}
for path, pattern in runtime.items():
    found = re.findall(pattern, (ROOT / path).read_text(encoding="utf-8"))
    assert found == [version], f"{path} has {found!r}, expected {version}"

readme = (ROOT / "README.md").read_text(encoding="utf-8")
assert readme.startswith("# SoftSpoken " + version + "\n"), "README release title is stale"
assert "v0.8.1-beta.zip" in readme, "Existing published release link must remain available"
for retired in ("publish-v081-beta.yml", "publish-v090-beta.yml", "stage-v091-beta.yml"):
    assert not (ROOT / ".github/workflows" / retired).exists(), (
        f"Retired release workflow remains active: {retired}"
    )
stage = ROOT / ".github/workflows/stage-v092-beta.yml"
assert stage.is_file() and version in stage.read_text(encoding="utf-8"), (
    "New version-specific release staging workflow is missing"
)
print("PASS:", version, "matches four addon manifests, runtime constants, tests and staging")
