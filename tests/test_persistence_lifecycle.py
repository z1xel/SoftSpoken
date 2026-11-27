#!/usr/bin/env python3
"""Run each persistence lifecycle phase in a fresh Lua process.

Only generated, disposable fixtures are loaded. This exercises real AceDB
logout cleanup and cross-session persistence, not the native WoW serializer.
"""
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    with tempfile.TemporaryDirectory(prefix="softspoken-persistence-") as temp:
        def session(scenario, player):
            subprocess.run(
                ["lua5.1", "tests/persistence_lifecycle.lua", temp, scenario, player],
                cwd=ROOT, check=True,
            )

        def snapshot():
            return {file.name: file.read_bytes() for file in Path(temp).glob("*.lua")}

        def retired():
            return {name: data for name, data in snapshot().items()
                    if name.rsplit("_", 1)[-1] in ("Stories.lua", "Places.lua", "Writings.lua")}

        session("seed", "Alice")
        old_modules = retired()
        session("fail", "Alice")
        session("dev", "Alice")
        session("devlogout", "Alice")  # fresh process: no DEV data survives
        before_crash = snapshot()
        session("devcrash", "Alice")
        assert snapshot() == before_crash, "DEV abrupt exit changed fixture files"
        session("alice", "Alice")  # first real migration after DEV
        session("dev", "Bob")  # account has Alice's real migrated data
        session("bob", "Bob")
        session("reload", "Alice")
        session("normalcheck", "Alice")
        assert retired() == old_modules, "retired legacy files changed"
        session("historyonly", "HistoryOnly")
        session("dev", "New")  # new character, existing account
        session("new", "New")
        session("newreload", "New")
        # Simulate loss of the unified character file only. The original
        # retired files still exist and must not be imported a second time.
        (Path(temp) / "char_Alice_SoftSpoken.lua").unlink()
        session("lost", "Alice")
    with tempfile.TemporaryDirectory(prefix="softspoken-dev-clean-") as temp:
        session("dev", "Clean")
        session("devlogout", "Clean")
        session("freshnormal", "Clean")
    print("PASS: multi-process migration / DEV / AceDB / logout / reload lifecycle")


if __name__ == "__main__":
    main()
