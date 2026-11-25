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

        session("seed", "Alice")
        session("fail", "Alice")
        session("alice", "Alice")
        session("bob", "Bob")
        session("reload", "Alice")
        session("historyonly", "HistoryOnly")
        session("new", "New")
        session("newreload", "New")
        # Simulate loss of the unified character file only. The original
        # retired files still exist and must not be imported a second time.
        (Path(temp) / "char_Alice_SoftSpoken.lua").unlink()
        session("lost", "Alice")
    print("PASS: multi-process migration / AceDB / logout / reload lifecycle")


if __name__ == "__main__":
    main()
