#!/usr/bin/env python3
"""Guard stable external contracts across internal Lua variable-name cleanup.

Avoid assertions on private local names: they may be freely refactored.
Real playback and event dispatch are exercised by the neighboring Lua tests.
"""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def read(path):
    return (ROOT / path).read_text(encoding="utf-8-sig")


def require(path, pattern, label):
    assert re.search(pattern, read(path), re.MULTILINE), (
        f"{path}: missing external contract: {label}"
    )


# These names are serialized in players' WTF files. Do not rename/migrate here.
manifests = {
    "SoftSpoken": {
        "SavedVariables": ["SpokenSettings"],
    },
    "SoftSpoken_Stories": {
        "SavedVariables": ["SpokenQuestsSettings"],
        "SavedVariablesPerCharacter": ["SSCQuestJournal"],
    },
    "SoftSpoken_Places": {
        "SavedVariablesPerCharacter": ["SSZCharacter"],
    },
    "SoftSpoken_Writings": {
        "SavedVariables": ["SSBSettings"],
        "SavedVariablesPerCharacter": ["SSBCharacter"],
    },
}
for module, expected in manifests.items():
    text = read(f"{module}/{module}.toc")
    assert re.search(r"(?m)^## Interface:\s*11200\s*$", text), module
    found = {}
    for kind in ("SavedVariables", "SavedVariablesPerCharacter"):
        found[kind] = [
            name.strip()
            for line in re.findall(rf"(?m)^## {kind}:\s*(.+)$", text)
            for name in line.split(",")
        ]
    for kind in found:
        assert found[kind] == expected.get(kind, []), (
            f"{module}: {kind} changed: {found[kind]!r}"
        )
    if module != "SoftSpoken":
        assert re.search(r"(?m)^## Dependencies:\s*SoftSpoken\s*$", text), (
            f"{module}: Core dependency removed"
        )

# Public names stay stable even if their private local bindings change.
exports = {
    "SoftSpoken/Environment.lua": [r"^SpokenEnv\s*=", r"^Spoken\s*="],
    "SoftSpoken_Stories/Environment.lua": [r"^VoiceOver\s*="],
    "SoftSpoken_Stories/Compendium/QuestState.lua": [r"^SSCQuestState\s*="],
    "SoftSpoken/Compendium/UI/Compendium.lua": [r"^SSCCompendium\s*="],
    "SoftSpoken_Places/Runtime.lua": [r"^SSZZonesRuntime\s*="],
    "SoftSpoken_Writings/Core.lua": [r"^SSB\s*="],
}
for path, patterns in exports.items():
    for pattern in patterns:
        require(path, pattern, pattern)

for method in (
    "IsCompatible",
    "RegisterSource",
    "GetSource",
    "GetQueue",
    "RegisterCallback",
    "GetPlayerFrame",
    "AddSettingsPage",
):
    require("SoftSpoken/API.lua", rf"^function Spoken:{method}\(", method)

# Upstream AI VoiceOver packs register against the VoiceOver global and keep
# their existing metadata spellings and quest lookup table shape.
stories_data = "SoftSpoken_Stories/DataModules.lua"
require(stories_data, r"^function DataModules:Register\(", "DataModules:Register")
require(stories_data, r"^function DataModules:GetQuestID\(", "GetQuestID callable")
for prefix in ("X-VoiceOver-DataModule-", "X-SpokenQuests-DataModule-"):
    assert prefix in read(stories_data), f"missing legacy/current TOC prefix {prefix}"
for table in (
    "QuestIDLookup",
    "NPCIDLookupByQuestID",
    "ObjectIDLookupByQuestID",
    "ItemIDLookupByQuestID",
):
    assert table in read(stories_data), f"missing voice-pack data field {table}"

# The registered source keys and optional pack registry names are external
# contracts. The settings inventory's "source" field also stays unchanged.
for path, key in (
    ("SoftSpoken_Stories/NarrationSource.lua", "quests"),
    ("SoftSpoken_Stories/NarrationSource.lua", "gossip"),
    ("SoftSpoken_Writings/Core.lua", "books"),
):
    require(path, rf'RegisterSource\("{key}"\s*,', f"narration source {key}")
for path, names in {
    "SoftSpoken_Places/Audio.lua": (
        "SpokenPlacesAudioPacks", "SpokenZonesAudioPacks", "ZoneLoreAudioPacks",
    ),
    "SoftSpoken_Writings/Audio.lua": (
        "SpokenReadablesAudioPacks", "SpokenBooksAudioPacks",
    ),
}.items():
    source = read(path)
    for name in names:
        assert re.search(rf"\b{name}\b", source), f"{path}: registry {name}"

for path in (
    "SoftSpoken_Places/UI/Options.lua",
    "SoftSpoken_Writings/UI/Options.lua",
):
    require(path, r"\bsource\s*=", "public pack inventory source field")

# Keep the historical environment members as aliases, not replacements or copies.
for path, assertion in (
    ("SoftSpoken/UI/NarratorWindow.lua", r"^PlayerFrame\s*=\s*NarratorWindow\b"),
    ("SoftSpoken_Stories/NarrationSource.lua", r"^Player\s*=\s*StoriesNarrator\b"),
    ("SoftSpoken_Stories/UI/SettingsPage.lua", r"^SettingsPanel\s*=\s*StoriesSettingsPage\b"),
):
    require(path, assertion, "historical controller alias identity")

print("PASS: serialized names, public globals/API, voice-pack metadata and registries")
