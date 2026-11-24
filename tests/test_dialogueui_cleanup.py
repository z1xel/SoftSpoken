"""Guard the Vanilla-only code against dormant DialogueUI integration returning."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUNTIME = [
    "SoftSpoken/Modules/Stories/QuestRuntime.lua",
    "SoftSpoken/Modules/Stories/Utils.lua",
    "SoftSpoken/Modules/Stories/ReportButton.lua",
    "SoftSpoken/Modules/Stories/QuestOverlayUI.lua",
    "SoftSpoken/Modules/Stories/UI/DialogPlayButton.lua",
    "SoftSpoken/Modules/Stories/Strings.lua",
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

# Retired Contribute/DialogueUI controllers must not be wired back into
# Stories. These guards intentionally do not block Core's compatibility API
# or the supported 1.12 copyable report popup.
retired_ui_patterns = (
    "questContributeButtons", "ContributeButtonFor(",
    'rawget(VoiceOver, "Contribute")',
    'rawget(VoiceOver, "ContributeButton")',
    "ContributeButton:Setup()", "Utils:DialogueUIPage()",
    "Spoken:ShowContribution(", "Spoken:ShowReport(",
)
for path in (
    "SoftSpoken/Modules/Stories/QuestOverlayUI.lua",
    "SoftSpoken/Modules/Stories/NarrationSource.lua",
    "SoftSpoken/Modules/Stories/QuestRuntime.lua",
    "SoftSpoken/Modules/Stories/ReportButton.lua",
):
    contents = (ROOT / path).read_text(encoding="utf-8")
    for token in retired_ui_patterns:
        assert token not in contents, f"{path}: retired UI/controller token {token}"

report = (ROOT / "SoftSpoken/Modules/Stories/ReportButton.lua").read_text(encoding="utf-8")
assert "function ReportButton:CurrentTarget()" in report
assert "function ReportButton:ShowAddress(url)" in report
assert "function ReportButton:ShowLink(target, language)" in report
assert "StaticPopup_Show(COPY_DIALOG)" in report

voice = (ROOT / RUNTIME[0]).read_text(encoding="utf-8")
api = (ROOT / "SoftSpoken/API.lua").read_text(encoding="utf-8")
core = (ROOT / "SoftSpoken/Core.lua").read_text(encoding="utf-8")

# These are active interfaces, not part of the removed optional bridge.
for expected in (
    "function StoriesAddon:InvokeQuestHandler(event, dispatchOrigin, manual)",
    "function StoriesAddon:GetVisibleLine(event)",
    "local lastQuestEvent",
    "pcall(QuestIDFor, event)",
    "CacheClassicGossipQuestLists()",
    "SelectOptionByIndex",
):
    assert expected in voice, f"active Stories integration removed: {expected}"
assert "function Spoken:SetPlayerHost(frame)" in api
assert "function CoreController:ApplyHost(frame)" in core
assert "function CoreController:SetPlayerHost(host)" in core
assert "function Spoken:AddDialogueUISettings(" not in api
print("PASS: retired DialogueUI/Contribute branches removed; Vanilla reporting and quest-log controls retained")
