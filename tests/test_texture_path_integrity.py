#!/usr/bin/env python3
"""Validate addon-local texture paths on the exact (case-sensitive) install tree.

This checks literal Interface/AddOns/SoftSpoken paths, straightforward local
texture-root concatenations, all mapped Places illustrations and Core zone badges.
It cannot validate textures supplied by the game client or external voice packs.
"""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
MODULES = ("SoftSpoken", "SoftSpoken_Stories", "SoftSpoken_Places", "SoftSpoken_Writings")
ASSET_SUFFIXES = (".tga", ".blp")
all_assets = {
    p.relative_to(ROOT).as_posix()
    for module in MODULES
    for p in (ROOT / module).rglob("*")
    if p.is_file() and p.suffix.lower() in ASSET_SUFFIXES
}
folded_assets = {p.lower(): p for p in all_assets}
issues = []
counts = {"literal": 0, "concatenated": 0, "places": 0, "zones": 0, "required": 0}

REF = re.compile(
    r"Interface\\AddOns\\(?:SoftSpoken(?:_Stories|_Places|_Writings)?)"
    r"(?:\\[A-Za-z0-9_!+.\-]*)*\\?"
)
ROOT_ASSIGN = re.compile(r"""\b([A-Za-z_]\w*)\s*=\s*(?:\[\[|["'])""")

def check(path, owner, line, kind):
    path = path.replace("\\", "/")
    if path.endswith("/") or path.endswith("-"):
        # Some Blizzard atlas filenames are assembled from a shared prefix
        # (e.g. UI-ChatIM-SizeGrabber- + Up/Down/Highlight).
        exists = any(p.startswith(path) for p in all_assets)
        matches = [path] if exists else []
    elif path.lower().endswith(ASSET_SUFFIXES):
        matches = [path] if path in all_assets else []
    else:
        matches = [path + ext for ext in ASSET_SUFFIXES if path + ext in all_assets]
    if not matches:
        name_candidates = [path] if path.lower().endswith(ASSET_SUFFIXES) else [
            path + ext for ext in ASSET_SUFFIXES
        ]
        alt = [folded_assets[p.lower()] for p in name_candidates if p.lower() in folded_assets]
        issues.append(f"{owner}:{line} {kind}: {path} not found (case-only matches: {alt})")
    counts[kind] += 1

for module in MODULES:
    for file in (ROOT / module).rglob("*"):
        if not file.is_file() or file.suffix.lower() not in (".lua", ".toc", ".xml"):
            continue
        if "Libs" in file.relative_to(ROOT).parts:
            continue  # Third-party libraries have their own bundled resources.
        code = file.read_text(encoding="utf-8-sig", errors="replace")
        # Lua's escaped-backslash spelling and [[literal]] spelling normalize alike.
        code = code.replace("\\\\", "\\")
        roots = {}
        for line_number, raw_line in enumerate(code.splitlines(), 1):
            line = raw_line.split("--", 1)[0]
            for match in REF.finditer(line):
                asset = match.group(0).split("AddOns\\", 1)[1]
                if "/" not in asset.replace("\\", "/"):
                    continue
                check(asset, file.relative_to(ROOT), line_number, "literal")
            definition = ROOT_ASSIGN.search(line)
            if definition:
                match = REF.search(line[definition.end():])
                if match:
                    roots[definition.group(1)] = match.group(0).split("AddOns\\", 1)[1]
        for variable, root in roots.items():
            concat = re.compile(r"\b" + re.escape(variable) + r"""\s*\.\.\s*["']([A-Za-z0-9_!+.\-]+)["']""")
            for match in concat.finditer(code):
                line_number = code.count("\n", 0, match.start()) + 1
                check(root + match.group(1), file.relative_to(ROOT), line_number, "concatenated")

# These 12 assets previously lived under Stories, including the four native
# quest-log glyphs which are now physically hosted only by Core.
required = (
    "QuestLogPlayButton", "QuestLogStopButton",
    "QuestLogPlayButtonNative", "QuestLogPlayButtonNativeDown",
    "QuestLogStopButtonNative", "QuestLogStopButtonNativeDown",
    "StopGossip", "StopGossipMore",
    "SoundQueueBulletAccept", "SoundQueueBulletProgress",
    "SoundQueueBulletComplete", "SoundQueueBulletGossip",
)
for filename in required:
    check("SoftSpoken/Textures/" + filename, "Stories consolidation", 0, "required")
# Writings' default book portrait is a power-of-two, 32-bit TGA, not a
# client inventory texture. Check the binary header as well as the path.
book_art = "SoftSpoken/Textures/WritingsBook.tga"
check(book_art, "Writings narration portrait", 0, "required")
book_path = ROOT / book_art
if book_path.is_file():
    header = book_path.read_bytes()[:18]
    if len(header) != 18:
        issues.append(f"{book_art}: truncated TGA header")
    else:
        width = int.from_bytes(header[12:14], "little")
        height = int.from_bytes(header[14:16], "little")
        if header[2] not in (2, 10) or header[16] != 32 or any(
            size < 1 or size & (size - 1) for size in (width, height)
        ):
            issues.append(f"{book_art}: expected power-of-two 32-bit true-color TGA")

for old in ("SoftSpoken_Stories/Textures", "SoftSpoken_Places/Textures/Art",
            "SoftSpoken_Places/Textures/ClassicFrames", "SoftSpoken_Places/Textures/Controls"):
    if (ROOT / old).exists():
        issues.append(f"Retired texture directory still installed: {old}")

# Places assembles image paths from a generated Lua mapping rather than from
# literal per-image paths. Check *every* mapped filename, including cross-zone
# references to another zone's illustration.
place_text = (ROOT / "SoftSpoken_Places/Data/Pictures.lua").read_text(encoding="utf-8")
pictures = re.findall(r'\[[^\]\n]+\]\s*=\s*"([^"]+)"', place_text)
if len(pictures) < 700:
    issues.append(f"Unexpected Places picture mapping count: {len(pictures)}")
for name in pictures:
    check("SoftSpoken_Places/Textures/Pictures/" + name, "Places image registry", 0, "places")

# Core constructs ZoneIcon paths by appending a mapped name.
core_api = (ROOT / "SoftSpoken/API.lua").read_text(encoding="utf-8")
try:
    zone_map = core_api.split("local ZONE_ICONS = {", 1)[1].split("\n}", 1)[0]
except IndexError:
    zone_map = ""
zones = re.findall(r'=\s*"([^"]+)"', zone_map)
if len(zones) < 50:
    issues.append(f"Unexpected Core zone-icon mapping count: {len(zones)}")
for name in zones:
    check("SoftSpoken/Textures/Zones/" + name, "Core ZoneIcon registry", 0, "zones")

if issues:
    raise SystemExit("Texture path integrity FAILED:\n" + "\n".join(issues))
print("PASS: addon texture paths resolve with exact casing; "
      + ", ".join(f"{k}={v}" for k, v in counts.items()))
