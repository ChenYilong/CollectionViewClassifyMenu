#!/usr/bin/env python3
"""Adds rows to harmony/parity-map.json and regenerates docs/harmony.md.

  parity_map.py api '<iOS symbol>=<ArkTS>' ...       map API rows (an unknown symbol is an error)
  parity_map.py demo '<iOS demo>=<HarmonyOS page>'   map a demo row
  parity_map.py history '<text>'                     append a line to the score history (the score is added)
"""
import json
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
MAP = ROOT / "harmony/parity-map.json"
sys.path.insert(0, str(ROOT / "harmony/scripts"))
import harmony_parity  # noqa: E402


def main():
    kind, pairs = sys.argv[1], sys.argv[2:]
    data = json.loads(MAP.read_text(encoding="utf-8"))
    if kind == "api":
        known = {s for s, _, _ in harmony_parity.symbols()}
        for pair in pairs:
            symbol, value = pair.split("=", 1)
            if symbol not in known:
                sys.exit("unknown iOS symbol: " + symbol)
            data["api"][symbol] = value
    elif kind == "demo":
        for pair in pairs:
            demo, value = pair.split("=", 1)
            rows = [d for d in data["demos"] if d["ios"] == demo]
            if not rows:
                sys.exit("unknown iOS demo: " + demo)
            rows[0]["harmony"] = value
    elif kind == "history":
        rows = harmony_parity.symbols()
        done = sum(1 for s, _, _ in rows if data["api"].get(s)) + sum(1 for d in data["demos"] if d.get("harmony"))
        total = len(rows) + len(data["demos"])
        data["history"].append("%s Score %d / %d = %.1f." % (pairs[0], done, total, 100.0 * done / total))
    MAP.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
    subprocess.run([sys.executable, str(ROOT / "harmony/scripts/harmony_parity.py")], check=True)


if __name__ == "__main__":
    main()
