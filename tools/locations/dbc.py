"""Strict WDBC geography reader for the verified 1.12.1 (5875) layouts.

Layout references: VanillaDBDefs d23630b7e5fac1d5086cc7ae9f538a8485f7080a,
CMaNGOS classic DBCfmt (25/42/8/17 fields). No MPQ extraction here.
Different layouts must be explicitly implemented, never guessed by row size.
"""
import hashlib
import math
import struct
from pathlib import Path

LAYOUTS = {"AreaTable": 25, "Map": 42, "WorldMapArea": 8, "WorldMapOverlay": 17}
LOCALES = ("enUS", "koKR", "frFR", "deDE", "zhCN", "zhTW", "esES", "esMX")


def sha256(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def read_dbc(path, table, encoding="utf-8"):
    data = Path(path).read_bytes()
    if len(data) < 20:
        raise ValueError(f"{path}: truncated header")
    magic, count, fields, width, string_size = struct.unpack_from("<4s4I", data)
    if magic != b"WDBC" or fields != LAYOUTS[table] or width != fields * 4:
        raise ValueError(f"{path}: unsupported {table} layout: {magic!r}, {fields}, {width}")
    if string_size < 1 or len(data) != 20 + count * width + string_size:
        raise ValueError(f"{path}: invalid WDBC length")
    strings = data[20 + count * width:]
    if strings[0] != 0 or strings[-1] != 0:
        raise ValueError(f"{path}: malformed string block")

    def string(offset):
        if offset >= len(strings):
            raise ValueError(f"{path}: string offset out of bounds")
        end = strings.index(0, offset)
        return strings[offset:end].decode(encoding, errors="strict")

    def names(row, start):
        return {locale: string(row[start + i]) for i, locale in enumerate(LOCALES)
                if row[start + i]}

    def signed(value):
        return value if value < 2**31 else value - 2**32

    def real(value):
        result = struct.unpack("<f", struct.pack("<I", value))[0]
        if not math.isfinite(result):
            raise ValueError(f"{path}: nonfinite coordinate")
        return result

    result = {}
    for i in range(count):
        row = struct.unpack_from(f"<{fields}I", data, 20 + i * width)
        ident = row[0]
        if ident in result:
            raise ValueError(f"{path}: duplicate ID {ident}")
        if table == "AreaTable":
            item = dict(id=ident, worldMap=row[1], parentArea=row[2],
                        explorationBit=signed(row[3]), flags=row[4],
                        explorationLevel=signed(row[10]), names=names(row, 11))
        elif table == "Map":
            item = dict(id=ident, directory=string(row[1]), instanceType=row[2],
                        mapType=row[3], names=names(row, 4), parentMap=signed(row[19]))
        elif table == "WorldMapArea":
            item = dict(id=ident, worldMap=row[1], areaTable=row[2],
                        directory=string(row[3]), bounds=[real(x) for x in row[4:8]])
        else:
            item = dict(id=ident, worldMapArea=row[1], areaIDs=[x for x in row[2:6] if x],
                        texture=string(row[8]))
        result[ident] = item
    return result


def load_sources(manifest, root):
    """Never treat unpinned or non-effective archives as authoritative."""
    profiles = {}
    for profile, source in sorted(manifest.get("profiles", {}).items()):
        required = ("world", "revision", "provenance", "rights", "locale", "layout")
        if any(not isinstance(source.get(k), str) or not source[k].strip() for k in required):
            raise ValueError(f"{profile}: missing provenance metadata")
        if source["layout"] != "vanilla_5875" or source.get("effectivePatched") is not True:
            raise ValueError(f"{profile}: unverified effective client layout")
        if source.get("rights") not in ("derived-metadata-approved", "synthetic"):
            raise ValueError(f"{profile}: derived output rights not approved")
        if set(source.get("files", {})) != set(LAYOUTS):
            raise ValueError(f"{profile}: requires all four geography tables")
        tables = {}
        for name, entry in sorted(source["files"].items()):
            path = Path(root) / entry["path"]
            if sha256(path) != entry["sha256"]:
                raise ValueError(f"{profile}/{name}: checksum mismatch")
            tables[name] = read_dbc(path, name, source.get("encoding", "utf-8"))
        profiles[profile] = tables
    return profiles
