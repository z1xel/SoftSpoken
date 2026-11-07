#!/usr/bin/env python3
"""Read-only installed MP3 audit for SoftSpoken (#67 / #70).

Examples:
  python scripts/audio_pack_audit.py "C:/TurtleWoW/Interface/AddOns" --limit 100
  python scripts/audio_pack_audit.py "C:/TurtleWoW/Interface/AddOns" --loudness --limit 50 --csv audit.csv

ffprobe reads durations and stream metadata; --loudness invokes ffmpeg's
loudnorm filter with a null output to measure integrated LUFS and true peak.
No input file is modified, converted, normalized or copied.
"""
import argparse
import csv
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

FIELDS = ["pack", "file", "duration_seconds", "codec", "bit_rate_kbps",
          "integrated_lufs", "true_peak_dbfs", "loudness_range_lu", "error"]


def probe(path, ffprobe="ffprobe"):
    cmd = [ffprobe, "-v", "error", "-show_entries",
           "format=duration,bit_rate:stream=codec_type,codec_name",
           "-of", "json", str(path)]
    p = subprocess.run(cmd, capture_output=True, text=True, timeout=30, check=False)
    if p.returncode:
        raise ValueError("ffprobe failed: " + (p.stderr or "").strip()[:280])
    data = json.loads(p.stdout)
    audio = next((s for s in data.get("streams", []) if s.get("codec_type") == "audio"), {})
    info = data.get("format", {})
    dur = info.get("duration")
    bitrate = info.get("bit_rate")
    return {
        "duration_seconds": round(float(dur), 3) if dur is not None else "",
        "codec": audio.get("codec_name", ""),
        "bit_rate_kbps": round(float(bitrate)/1000, 1) if bitrate is not None else "",
    }


def loudness(path, ffmpeg="ffmpeg"):
    # ffmpeg emits measured INPUT loudness JSON to stderr. -f null means no
    # normalized output is ever written, and the input MP3 remains untouched.
    cmd = [ffmpeg, "-hide_banner", "-nostats", "-i", str(path),
           "-af", "loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json",
           "-f", "null", "-"]
    p = subprocess.run(cmd, capture_output=True, text=True, timeout=180, check=False)
    if p.returncode:
        raise ValueError("ffmpeg loudness failed: " + (p.stderr or "").strip()[-280:])
    matches = re.findall(r'\{\s*"input_i"\s*:.*?\}', p.stderr, flags=re.S)
    if not matches:
        raise ValueError("no loudnorm input measurements returned")
    v = json.loads(matches[-1])
    return {
        "integrated_lufs": v.get("input_i", ""),
        "true_peak_dbfs": v.get("input_tp", ""),
        "loudness_range_lu": v.get("input_lra", ""),
    }


def files_under(root, limit=None):
    found = 0
    for path in sorted(root.rglob("*")):
        if path.is_symlink() or not path.is_file() or path.suffix.lower() != ".mp3":
            continue
        yield path
        found += 1
        if limit is not None and found >= limit:
            break


def audit(root, with_loudness=False, limit=None):
    for path in files_under(root, limit):
        rel = path.relative_to(root)
        row = dict.fromkeys(FIELDS, "")
        row["pack"] = rel.parts[0] if len(rel.parts) > 1 else "(root)"
        row["file"] = str(rel)
        try:
            row.update(probe(path))
            if with_loudness:
                row.update(loudness(path))
        except (OSError, ValueError, json.JSONDecodeError, subprocess.TimeoutExpired) as exc:
            row["error"] = str(exc)[:300]
        yield row


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("root", type=Path, help="folder containing installed voice-pack addon directories")
    ap.add_argument("--loudness", action="store_true", help="measure LUFS/true peak (slower; requires ffmpeg)")
    ap.add_argument("--limit", type=int, default=100,
                    help="maximum MP3 files to scan (default 100; use 0 for all)")
    ap.add_argument("--csv", type=Path, help="output CSV path; defaults to stdout")
    args = ap.parse_args(argv)
    root = args.root.expanduser().resolve()
    if not root.is_dir():
        ap.error("root is not an existing directory: " + str(root))
    if args.limit < 0:
        ap.error("--limit must be nonnegative")
    if not shutil.which("ffprobe"):
        ap.error("ffprobe missing; install FFmpeg and put ffprobe on PATH")
    if args.loudness and not shutil.which("ffmpeg"):
        ap.error("ffmpeg missing; install FFmpeg and put ffmpeg on PATH")
    dest = None
    try:
        if args.csv:
            args.csv.parent.mkdir(parents=True, exist_ok=True)
            dest = args.csv.open("w", newline="", encoding="utf-8")
        writer = csv.DictWriter(dest or sys.stdout, fieldnames=FIELDS)
        writer.writeheader()
        count = 0
        for row in audit(root, args.loudness, args.limit or None):
            writer.writerow(row)
            count += 1
        print(f"Inspected {count} MP3 file(s), no source files changed.", file=sys.stderr)
    finally:
        if dest:
            dest.close()


if __name__ == "__main__":
    main()
