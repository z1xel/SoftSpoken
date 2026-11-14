#!/usr/bin/env python3
"""Verify production UI paths and reject development artifacts in installable modules."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
MODULES = (
    "SoftSpoken",
    "SoftSpoken_Stories",
    "SoftSpoken_Places",
    "SoftSpoken_Writings",
)
LEGACY_IDENTIFIERS = (
    "SSCPrototypeFrameSkin",
    "SSCPrototypeInteriorSkin",
    "SSCPrototypeScrollBar",
    "sszPrototypeSkin",
    "sszPrototypePageVisual",
    "sszPrototypePageRim",
    "SoftSpokenExperimentalStaticPortraits",
    r"Textures\\Prototype",
)
REQUIRED_RUNTIME = (
    "SoftSpoken/Compendium/UI/FrameSkin.lua",
    "SoftSpoken/Compendium/UI/InteriorSkin.lua",
    "SoftSpoken/Compendium/UI/NativeScrollbar.lua",
    "SoftSpoken/Compendium/Textures/Skin/UI-Frame.tga",
    "SoftSpoken/Compendium/Textures/Skin/InsetClassic/UI-Frame.tga",
    "SoftSpoken/Compendium/Textures/Skin/BookPortraitCircleMask.tga",
    "SoftSpoken/Compendium/Textures/Skin/UI-Background-Marble.tga",
    "SoftSpoken/Compendium/Textures/Skin/UI-Background-Rock-Classic.tga",
    "SoftSpoken/Compendium/Textures/Art/PortraitRing.tga",
    "SoftSpoken/Textures/TalkingHeads/PortraitNeutral.tga",
)
REQUIRED_SOURCES = (
    "docs/artwork/compendium/PortraitRing-source.png",
    "docs/artwork/compendium/QuestMapLogBrownBand_source.png",
    "docs/artwork/TALKING_HEADS.md",
    "docs/UI_RENDERING.md",
)


def require_file(name):
    assert (ROOT / name).is_file(), f"Missing referenced file: {name}"


for name in REQUIRED_RUNTIME + REQUIRED_SOURCES:
    require_file(name)

for module in MODULES:
    base = ROOT / module
    assert base.is_dir(), f"Missing module: {module}"
    # PNG is not used as a WoW 1.12 runtime texture. Sources belong in docs/.
    non_runtime_png = list(base.rglob("*.png")) + list(base.rglob("*.PNG"))
    assert not non_runtime_png, f"Source PNGs packaged in {module}: {non_runtime_png}"
    for path in base.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in (".lua", ".xml", ".toc"):
            continue
        # Third-party libraries are external, not part of this UI migration.
        if "Libs" in path.parts:
            continue
        code = path.read_text(encoding="utf-8", errors="replace")
        for obsolete in LEGACY_IDENTIFIERS:
            assert obsolete not in code, f"{path}: obsolete UI identifier {obsolete}"

# Read all included Lua/XML paths in the game's addon entrypoints.
for module in MODULES:
    base = ROOT / module
    toc = base / f"{module}.toc"
    require_file(toc.relative_to(ROOT).as_posix())
    for raw in toc.read_text(encoding="utf-8-sig").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if line.lower().endswith((".lua", ".xml")):
            require_file((base / line.replace("\\", "/")).relative_to(ROOT).as_posix())
for path in ROOT.glob("SoftSpoken*/**/*.xml"):
    if "Libs" in path.parts:
        continue
    text = path.read_text(encoding="utf-8", errors="replace")
    for included in re.findall(r'<Include\s+file="([^"]+)"', text):
        require_file((path.parent / included.replace("\\", "/")).relative_to(ROOT).as_posix())

assert not (ROOT / "SoftSpoken/Compendium/Textures/Prototype").exists()
assert not (ROOT / "docs/CLASSICAPI_FRAME_TILING_EXPERIMENT.md").exists()
assert not (ROOT / "SoftSpoken/Textures/TalkingHeads/PortraitBg.tga").exists()
print("PASS: production UI texture sources, load manifests and retired identifiers")
