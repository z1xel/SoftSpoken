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
    "SoftSpoken/Compendium/Textures/ClassicFrames/UIFrameMetal.tga",
    "SoftSpoken/Compendium/Textures/ClassicFrames/UIFrameMetalHorizontal.tga",
    "SoftSpoken/Compendium/Textures/ClassicFrames/UIFrameMetalVertical.tga",
    "SoftSpoken/Compendium/Textures/ClassicFrames/UI-Background-Marble.tga",
    "SoftSpoken/Compendium/Textures/Skin/UI-Frame.tga",
    "SoftSpoken/Compendium/Textures/Skin/InsetClassic/UI-Frame.tga",
    "SoftSpoken/Compendium/Textures/Skin/BookPortraitCircleMask.tga",
    "SoftSpoken/Compendium/Textures/Skin/UI-Background-Marble.tga",
    "SoftSpoken/Compendium/Textures/Skin/UI-Background-Rock-Classic.tga",
    "SoftSpoken/Compendium/Textures/Art/PortraitRing.tga",
    "SoftSpoken/Textures/TalkingHeads/PortraitNeutral.tga",
    # Core owns every small UI icon; specialist add-ons only supply data/code.
    "SoftSpoken/Textures/QuestLogPlayButton.blp",
    "SoftSpoken/Textures/QuestLogStopButton.blp",
    "SoftSpoken/Textures/QuestLogPlayButtonNative.tga",
    "SoftSpoken/Textures/QuestLogPlayButtonNativeDown.tga",
    "SoftSpoken/Textures/QuestLogStopButtonNative.tga",
    "SoftSpoken/Textures/QuestLogStopButtonNativeDown.tga",
    "SoftSpoken/Textures/StopGossip.blp",
    "SoftSpoken/Textures/StopGossipMore.blp",
    "SoftSpoken/Textures/SoundQueueBulletAccept.blp",
    "SoftSpoken/Textures/SoundQueueBulletProgress.blp",
    "SoftSpoken/Textures/SoundQueueBulletComplete.blp",
    "SoftSpoken/Textures/SoundQueueBulletGossip.blp",
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

# Shared Compendium classic-frame art is owned by Core, never by the retired
# Places UI-artwork directory. Places/Pictures is independently retained.
for obsolete_dir in ("Art", "ClassicFrames", "Controls"):
    obsolete_path = ROOT / "SoftSpoken_Places/Textures" / obsolete_dir
    assert not obsolete_path.exists(), f"Retired Places UI art reintroduced: {obsolete_path}"

# Texture ownership policy: Stories and Writings have no local texture assets.
# Places retains *only* its location pictures, which remain dynamically mapped.
for module in ("SoftSpoken_Stories", "SoftSpoken_Writings"):
    assert not (ROOT / module / "Textures").exists(), (
        f"{module} must resolve small UI textures from SoftSpoken/Textures"
    )
places = ROOT / "SoftSpoken_Places/Textures"
assert (places / "Pictures").is_dir(), "Places location illustrations must remain available"
assert not any(p.is_file() for p in places.rglob("*") if "Pictures" not in p.relative_to(places).parts), (
    "Only location pictures belong in SoftSpoken_Places/Textures"
)

# Check literal and constructed runtime texture roots, not just file existence.
core_root = "Interface\\AddOns\\SoftSpoken\\Textures\\"
for path in (
    "SoftSpoken_Stories/Player.lua",
    "SoftSpoken_Stories/QuestOverlayUI.lua",
    "SoftSpoken_Stories/UI/QuestLogNativePlay.lua",
    "SoftSpoken_Stories/Compendium/QuestPage_112.lua",
):
    code = (ROOT / path).read_text(encoding="utf-8").replace("\\\\", "\\")
    assert core_root in code, f"{path}: Core's texture root is not in use"
    assert "SoftSpoken_Stories\\Textures" not in code, f"{path}: stale Stories texture path"
    assert "Interface\\AddOns\\%s\\Textures" not in code, f"{path}: dynamic addon-relative texture root remains"

classic_skin = (ROOT / "SoftSpoken/Compendium/UI/ClassicFrameSkin.lua").read_text(encoding="utf-8")
assert r"SoftSpoken\Compendium\Textures\ClassicFrames" in classic_skin.replace("\\\\", "\\"), (
    "Shared classic frame skin must use Core's ClassicFrames texture directory"
)

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
        # Catch direct and dynamically constructed references to legacy Places
        # UI paths while allowing its actively used location picture collection.
        normalized = code.replace("\\\\", "\\").replace("/", "\\").lower()
        needle = "softspoken_places\\textures\\"
        pos = 0
        while True:
            at = normalized.find(needle, pos)
            if at == -1:
                break
            assert normalized.startswith("pictures\\", at + len(needle)), (
                f"{path}: references retired Places UI texture directory"
            )
            pos = at + len(needle)

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
