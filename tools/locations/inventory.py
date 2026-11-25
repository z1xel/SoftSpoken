"""Inventory generated Lua content without executing any Lua.

This intentionally supports the literal-table grammar used by the checked-in
datasets. Unexpected syntax fails, rather than silently losing references.
"""
import re
from pathlib import Path
import zipfile

TOKEN = re.compile(r'''(?P<skip>\s+|--\[\[.*?\]\]|--[^\n]*)|(?P<str>"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*')|(?P<num>-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)|(?P<word>[A-Za-z_]\w*)|(?P<punct>[{}\[\]=,;])''', re.S)


class Parser:
    def __init__(self, text, pos):
        self.text, self.pos, self.next = text, pos, None

    def peek(self):
        if self.next is None:
            while True:
                token = TOKEN.match(self.text, self.pos)
                if not token:
                    raise ValueError(f"unexpected Lua near {self.text[self.pos:self.pos+80]!r}")
                self.pos = token.end()
                if token.lastgroup != "skip":
                    self.next = (token.lastgroup, token.group())
                    break
        return self.next

    def pop(self, expected=None):
        token = self.peek()
        if expected is not None and token[1] != expected:
            raise ValueError(f"expected {expected}, got {token}")
        self.next = None
        return token

    @staticmethod
    def string(value):
        def unescape(m):
            ch = m[1]
            if ch.isdigit():
                return chr(int(ch))
            return {"n":"\n", "r":"\r", "t":"\t", "a":"\a", "b":"\b",
                    "f":"\f", "v":"\v"}.get(ch, ch)
        return re.sub(r"\\(\d{1,3}|.)", unescape, value[1:-1], flags=re.S)

    def value(self):
        kind, val = self.peek()
        if val == "{":
            return self.table()
        self.pop()
        if kind == "str":
            return self.string(val)
        if kind == "num":
            return float(val) if any(c in val for c in ".eE") else int(val)
        if val in ("true", "false", "nil"):
            return {"true": True, "false": False, "nil": None}[val]
        raise ValueError(f"unsupported Lua literal: {val}")

    def table(self):
        self.pop("{")
        result, index = {}, 1
        while self.peek()[1] != "}":
            kind, val = self.peek()
            if val == "[":
                self.pop("[")
                key = self.value()
                self.pop("]")
                self.pop("=")
                value = self.value()
            elif kind == "word" and val not in ("true", "false", "nil"):
                key = self.pop()[1]
                self.pop("=")
                value = self.value()
            else:
                key, value = index, self.value()
                index += 1
            if key in result:
                raise ValueError(f"duplicate literal table key {key!r}")
            result[key] = value
            if self.peek()[1] in (",", ";"):
                self.pop()
            elif self.peek()[1] != "}":
                raise ValueError("missing table separator")
        self.pop("}")
        return result


def table(text, name):
    found = re.search(r"(?m)^\s*(?:local\s+)?" + re.escape(name) + r"\s*=\s*(?=\{)", text)
    if not found:
        raise ValueError(f"missing Lua table {name}")
    return Parser(text, found.end()).table()


def inventory(root, pack=None):
    root = Path(root) / "SoftSpoken"
    def read(path):
        return (root / path).read_text(encoding="utf-8-sig")
    refs = []
    def add(owner, record, namespace, value, area=None):
        if type(value) is not int:
            raise ValueError(f"{owner}/{record}: invalid numeric reference {value!r}")
        entry = dict(owner=owner, record=str(record), namespace=namespace, value=value)
        if area is not None:
            if not isinstance(area, str):
                raise ValueError("invalid legacy subzone key")
            entry["area"] = area
        refs.append(entry)

    for name, variable in [("Zones","zones"),("Subzones","subzones"),("Pictures","SSZPictures")]:
        rows = table(read(f"Modules/Places/Data/{name}.lua"), variable)
        for mid, entry in rows.items():
            if name == "Zones":
                add("Places."+name, mid, "legacyPlace", mid, "")
            else:
                for key in entry:
                    add("Places."+name, mid, "legacyPlace", mid, key)
    for path, name, ns in [("Compendium/UI/MapNames.lua","MapNames","upstreamUiMap"),
                           ("Compendium/UI/DungeonNames.lua","DungeonNames","instanceMap"),
                           ("Modules/Stories/Data/TurtleAreaMeta.lua","SSCTurtleAreaMeta","areaTable")]:
        for key in table(read(path), name):
            add(name, key, ns, key)
    # Extract nested quest table independently from outer metadata.
    quests = table(read("Modules/Stories/Data/Compendium.lua"), "quests")
    sorts = []
    for qid, entry in quests.items():
        for mid in entry.get("zones", {}).values():
            add("Stories.zones", qid, "upstreamUiMap", mid)
        for field, ns in [("turtleArea","areaTable"),("dungeon","instanceMap")]:
            if field in entry:
                add("Stories."+field, qid, ns, entry[field])
        if "sort" in entry:
            sorts.append(qid)
    books = table(read("Modules/Writings/Data/Places.lua"), "SSBPlaces")["books"]
    for bid, entry in books.items():
        for mid in entry.get("zones", {}).values():
            add("Writings.zones", bid, "upstreamUiMap", mid)
        for index, acquisition in entry.get("from", {}).items():
            for position, mid in acquisition.items():
                if type(position) is int and position >= 3:
                    add("Writings.from", f"{bid}/{index}/{position}", "upstreamUiMap", mid)
    if pack:
        with zipfile.ZipFile(pack) as z:
            data = table(z.read("Data/Sounds.lua").decode("utf-8-sig"), "pack")
        for mid in data["zones"]:
            add("VoicePack.zones", mid, "legacyPlace", mid, "")
        for mid, entries in data["subzones"].items():
            for key in entries:
                add("VoicePack.subzones", mid, "legacyPlace", mid, key)
    return {"references": sorted(refs, key=lambda r: (r["owner"],r["record"],r["namespace"],r["value"],r.get("area",""))),
            "questSortsExcluded": sorted(sorts)}
