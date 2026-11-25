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


# Unified persistence identity. The legacy Core variable is retained only to
# protect the shared SavedVariables filename during the migration release.
manifests = {
    "SoftSpoken": {
        "SavedVariables": ["SoftSpokenDB", "SpokenSettings"],
        "SavedVariablesPerCharacter": ["SoftSpokenCharacterDB"],
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
    assert not re.search(r"(?m)^## Dependencies:.*SoftSpoken", text), "Self dependency"
    for legacy in ("SoftSpoken_Stories", "SoftSpoken_Places", "SoftSpoken_Writings"):
        assert not (ROOT / legacy).exists(), f"Legacy addon still installed: {legacy}"

# Public names stay stable even if their private local bindings change.
exports = {
    "SoftSpoken/Environment.lua": [r"^SpokenEnv\s*=", r"^Spoken\s*="],
    "SoftSpoken/Modules/Stories/Environment.lua": [r"^VoiceOver\s*="],
    "SoftSpoken/Modules/Stories/Compendium/QuestState.lua": [r"^SSCQuestState\s*="],
    "SoftSpoken/Compendium/UI/Compendium.lua": [r"^SpokenCompendium\s*="],
    "SoftSpoken/Modules/Places/Runtime.lua": [r"^SpokenPlacesRuntime\s*="],
    "SoftSpoken/Modules/Places/LoreDataRegistry.lua": [r"^SpokenPlacesBridge\s*=", r"^SSZBridge\s*=\s*SpokenPlacesBridge\b"],
    "SoftSpoken/Modules/Writings/Core.lua": [r"^SpokenWritings\s*="],
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
stories_data = "SoftSpoken/Modules/Stories/DataModules.lua"
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
    ("SoftSpoken/Modules/Stories/NarrationSource.lua", "quests"),
    ("SoftSpoken/Modules/Stories/NarrationSource.lua", "gossip"),
    ("SoftSpoken/Modules/Writings/Core.lua", "books"),
):
    require(path, rf'RegisterSource\("{key}"\s*,', f"narration source {key}")
for path, names in {
    "SoftSpoken/Modules/Places/Audio.lua": (
        "SpokenPlacesAudioPacks", "SpokenZonesAudioPacks", "ZoneLoreAudioPacks",
    ),
    "SoftSpoken/Modules/Writings/Audio.lua": (
        "SpokenReadablesAudioPacks", "SpokenBooksAudioPacks",
    ),
}.items():
    source = read(path)
    for name in names:
        assert re.search(rf"\b{name}\b", source), f"{path}: registry {name}"

for path in (
    "SoftSpoken/Modules/Places/UI/Options.lua",
    "SoftSpoken/Modules/Writings/UI/Options.lua",
):
    require(path, r"\bsource\s*=", "public pack inventory source field")

# The controller implementation names are canonical; old aliases are not exported.
for path, assertion in (
    ("SoftSpoken/UI/NarratorWindow.lua", r"^NarratorWindow\s*=\s*\{"),
    ("SoftSpoken/Core.lua", r"^CoreController\s*="),
    ("SoftSpoken/Modules/Stories/NarrationSource.lua", r"^StoriesNarrator\s*=\s*\{"),
    ("SoftSpoken/Modules/Stories/UI/SettingsPage.lua", r"^StoriesSettingsPage\s*=\s*\{"),
    ("SoftSpoken/Modules/Stories/QuestRuntime.lua", r'^StoriesAddon\s*=\s*AceAddon:NewAddon\("SpokenQuests"'),
):
    require(path, assertion, "canonical controller declared")

# The registered AceAddon identity and historical VoiceOver.Addon access remain intact.
require(
    "SoftSpoken/Modules/Stories/QuestRuntime.lua",
    r"^Addon\s*=\s*StoriesAddon\b",
    "legacy VoiceOver.Addon shares the canonical StoriesAddon controller",
)

# Retired *implementation* identifiers must not quietly return.
# Scan first-party Lua, excluding generated data, locale strings and libraries.
retired = {
    "SoftSpoken": (
        r"\bAddon\b", r"\bPlayerFrame\b", r"\bSSCCompendium\b",
        r"\bSSZCompendium\b", r"\bSpokenZones112Compendium\b",
    ),
    "SoftSpoken/Modules/Stories": (
        r"\bSettingsPanel\b", r"\bSSCCompendium\b",
        r"\bVoiceOver\.Player\b", r"(?m)^Player\s*=",
    ),
    "SoftSpoken/Modules/Places": (
        r"\bSSZZonesRuntime\b", r"\bSSCCompendium\b",
        r"\bSSZCompendium\b", r"\bSSZUI\b", r"\bSSZLorePage\b",
        r"\bSSZTextView\b", r"\bSSZClassicFrameSkin\b",
        r"\bSSZOriginalArt\b",
    ),
    "SoftSpoken/Modules/Writings": (
        r"\bSSB\b", r"\bSSCCompendium\b",
    ),
}
for module, patterns in retired.items():
    for file in (ROOT / module).rglob("*.lua"):
        if module == "SoftSpoken" and "Modules" in file.relative_to(ROOT / module).parts:
            continue
        if any(part in ("Libs", "Data", "Locale") for part in file.parts):
            continue
        # Comments and runtime text are not controller identities.
        source = "\n".join(
            line.split("--", 1)[0] for line in file.read_text(encoding="utf-8").splitlines()
        )
        for pattern in patterns:
            assert not re.search(pattern, source), (
                f"{file.relative_to(ROOT)}: retired internal identifier {pattern}"
            )

# Audit every first-party runtime Lua file, including Locale/. The earlier
# controller-rename guard skipped Locale and missed the live Writings crash:
# Locale/enUS.lua still referenced the retired SSB table after Core renamed it.
# Generated Data/ is separate: SSBData/SSBPlaces and SSZBridge are supported
# external data contracts, not deprecated implementation controllers.
for module in ("SoftSpoken", "SoftSpoken/Modules/Stories", "SoftSpoken/Modules/Writings"):
    for file in (ROOT / module).rglob("*.lua"):
        if module == "SoftSpoken" and "Modules" in file.relative_to(ROOT / module).parts:
            continue
        if any(part in ("Libs", "Data") for part in file.parts):
            continue
        for number, line in enumerate(file.read_text(encoding="utf-8").splitlines(), 1):
            code = line.split("--", 1)[0]
            if module == "SoftSpoken/Modules/Writings":
                assert not re.search(r"\bSSB\b", code), (
                    f"{file.relative_to(ROOT)}:{number}: retired Writings module global SSB"
                )
            elif module == "SoftSpoken":
                assert not re.search(r"\bAddon\s*[.:(\[]", code), (
                    f"{file.relative_to(ROOT)}:{number}: retired Core controller Addon"
                )
            else:
                # Stories deliberately retains the assignment Addon = StoriesAddon
                # for older pack integrations. Its own code uses StoriesAddon.
                assert not re.search(r"\bAddon\s*[.:(\[]", code), (
                    f"{file.relative_to(ROOT)}:{number}: legacy Stories controller alias in internal code"
                )

# Coverage is not just source spelling: refactor_compatibility.lua actually
# executes Core.lua followed by Locale/enUS.lua and checks the resulting L keys.
require("SoftSpoken/Modules/Writings/Locale/enUS.lua",
        r"^local Writings\s*=\s*SpokenWritings\s*$",
        "Writings locale bound to canonical controller")
require("SoftSpoken/Modules/Writings/Locale/enUS.lua",
        r"^Writings\.L\s*=\s*Writings\.L\s+or\s+\{\}",
        "Writings locale table initialized before the UI")

# The exception is deliberate: packaged/generated lore still calls SSZBridge.
require(
    "SoftSpoken/Modules/Places/LoreDataRegistry.lua",
    r"^SSZBridge\s*=\s*SpokenPlacesBridge\b",
    "existing lore packs retain SSZBridge registration",
)

print("PASS: serialized contracts, canonical controllers, and retired-name guardrails")
