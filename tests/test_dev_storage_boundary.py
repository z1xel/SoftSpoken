#!/usr/bin/env python3
"""DEV5: audit first-party runtime saved-data and client mutation boundaries."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
allowed = {
    "SoftSpoken/Persistence.lua",
    "SoftSpoken/Migration.lua",
    "SoftSpoken/Locations/History.lua",
}
protected = re.compile(r"\b(?:SoftSpokenDB|SoftSpokenCharacterDB|SpokenSettings|ImportSavedVariables)\b")
legacy = re.compile(r"\b(?:SpokenQuestsSettings|SSCQuestJournal|SSZCharacter|SSBCharacter|SSBSettings)\b")
native = re.compile(r"\b(?:SetCVar|SaveBindings|SetBinding|SetUserPlaced|SetDontSavePosition|RegisterForSave|EnableAddOn|DisableAddOn|LoadAddOn|ReloadUI|PLAYER_LOGOUT|WriteFile|SaveFile)\b")
violations = []
count = 0
for file in sorted((root / "SoftSpoken").rglob("*.lua")):
    rel = file.relative_to(root).as_posix()
    if "Libs" in file.parts or "Data" in file.parts:
        continue
    count += 1
    for num, line in enumerate(file.read_text(encoding="utf-8-sig").splitlines(), 1):
        code = line.split("--", 1)[0]
        if protected.search(code) and rel not in allowed:
            violations.append(f"{rel}:{num}: {code.strip()}")
        if legacy.search(code) or native.search(code):
            print(f"AUDIT {rel}:{num}: {code.strip()}")
assert not violations, "Unexpected saved-variable access:\n" + "\n".join(violations)
print(f"PASS: DEV storage boundary, {count} first-party Lua files scanned")
