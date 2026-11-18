"""Guard the Vanilla-only code against dormant DialogueUI integration returning."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUNTIME = [
    "SoftSpoken_Stories/QuestRuntime.lua",
    "SoftSpoken_Stories/UI/DialogPlayButton.lua",
    "SoftSpoken_Stories/Strings.lua",
    "SoftSpoken/Core.lua",
    "SoftSpoken/API.lua",
    "SoftSpoken/Strings.lua",
]
for path in RUNTIME:
    contents = (ROOT / path).read_text(encoding="utf-8")
    assert "DialogueUI" not in contents and "dialogueui" not in contents, path

for path in (ROOT / "SoftSpoken/Locale").glob("*.lua"):
    contents = path.read_text(encoding="utf-8")
    assert "DUI_" not in contents and "DialogueUI" not in contents, path

voice = (ROOT / RUNTIME[0]).read_text(encoding="utf-8")
api = (ROOT / "SoftSpoken/API.lua").read_text(encoding="utf-8")
core = (ROOT / "SoftSpoken/Core.lua").read_text(encoding="utf-8")

# These are active interfaces, not part of the removed optional bridge.
for expected in (
    "function Addon:InvokeQuestHandler(event, dispatchOrigin, manual)",
    "function Addon:GetVisibleLine(event)",
    "local lastQuestEvent",
    "pcall(QuestIDFor, event)",
    "CacheClassicGossipQuestLists()",
    "SelectOptionByIndex",
):
    assert expected in voice, f"active Stories integration removed: {expected}"
assert "function Spoken:SetPlayerHost(frame)" in api
assert "function Addon:ApplyHost(frame)" in core
assert "function Addon:SetPlayerHost(host)" in core
assert "function Spoken:AddDialogueUISettings(" not in api
print("PASS: dormant DialogueUI bridge, profile defaults, API stub and locale removed; Vanilla paths retained")
