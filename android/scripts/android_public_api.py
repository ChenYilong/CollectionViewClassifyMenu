#!/usr/bin/env python3
"""Android -> iOS API table: every public symbol of the Android core and its iOS counterpart.

  android_public_api.py          write docs/android-ios-api.md
  android_public_api.py --check  exit 1 when docs/android-ios-api.md is out of date

Android symbols are the public declarations of android/merged/library (class / interface / object / enum class, their
public `fun` / `val` / `var` members and enum entries, and top-level `fun` / `val`). A symbol has an iOS counterpart
when (1) android/merged/api-map.json maps an iOS symbol to it (the iOS -> Android table, docs/android-api.md), or
(2) android/merged/ios-map.json names one by hand, or (3) the iOS Swift core (CollectionViewClassifyMenu/Class,
TagCollectionView) declares a type or member of the same name. Everything else is `TODO`.
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
KOTLIN = ROOT / "android/merged/library/src/main/java/com/cyl/classifymenu"
API_MAP = ROOT / "android/merged/api-map.json"
IOS_MAP = ROOT / "android/merged/ios-map.json"
IOS_DIRS = [ROOT / "CollectionViewClassifyMenu/Class", ROOT / "TagCollectionView"]
DOC = ROOT / "docs/android-ios-api.md"

DECL = re.compile(r"^(\s*)((?:@\w+(?:\([^)]*\))?\s+)*)((?:(?:public|open|abstract|override|data|enum|sealed|inline|operator|infix|const|lateinit|companion|final)\s+)*)"
                  r"(class|interface|object|fun|val|var)\s+(?:<[^>]+>\s*)?(?:[\w.]+\.)?(`?\w+`?)")
HIDDEN = re.compile(r"\b(private|internal|protected)\b")


def kotlin_symbols():
    """[(file, owner, name, kind, line)] of public Kotlin declarations; owner is '' for top-level ones."""
    out = []
    for path in sorted(KOTLIN.rglob("*.kt")):
        if path.name.startswith("._"):
            continue
        stack = []  # (indent, name, is_enum)
        lines = path.read_text(encoding="utf-8").splitlines()
        depth = 0
        for no, line in enumerate(lines, 1):
            stripped = line.strip()
            if stripped.startswith(("//", "*", "/*")):
                continue
            while stack and depth < stack[-1][0]:
                stack.pop()
            m = DECL.match(line)
            prefix = line[:m.start(4)] if m else ""
            if m and not HIDDEN.search(prefix) and depth == (stack[-1][0] if stack else 0):
                kind, name = m.group(4), m.group(5).strip("`")
                owner = stack[-1][1] if stack else ""
                if not (kind in ("fun", "val", "var") and "override" in m.group(3)):
                    out.append((path.name, owner, name, kind, no))
                if kind in ("class", "interface", "object") and name != "companion":
                    stack.append((depth + 1, name if "companion" not in m.group(3) else owner, "enum" in m.group(3)))
            elif stack and stack[-1][2] and re.match(r"^\s+([A-Z][A-Za-z0-9_]*)\s*[,(;]", line) and depth == stack[-1][0]:
                out.append((path.name, stack[-1][1], re.match(r"^\s+(\w+)", line).group(1), "entry", no))
            depth += line.count("{") - line.count("}")
            if m and m.group(4) in ("class", "interface", "object") and "{" not in line and stack and stack[-1][1] == m.group(5):
                stack.pop()
    return out


def mapped_from_api_map():
    """Kotlin symbols ('Owner.name' or 'name') that the iOS -> Android map points at, with their iOS symbol."""
    found = {}
    for ios, kotlin in json.loads(API_MAP.read_text(encoding="utf-8")).items():
        for part in re.split(r"[,;/]| and ", kotlin):
            part = part.strip().split("(")[0].replace("com.cyl.classifymenu.", "").strip()
            if part:
                found.setdefault(part, ios)
                found.setdefault(part.split(".")[-1], ios)
    return found


def ios_names():
    names = set()
    for d in IOS_DIRS:
        for path in d.rglob("*.swift"):
            if path.name.startswith("._"):
                continue
            for m in re.finditer(r"\b(?:class|struct|enum|protocol|func|var|let|case)\s+`?(\w+)", path.read_text(encoding="utf-8")):
                names.add(m.group(1))
    return names


def swift_case(owner, name):
    """`CYLImageTagDirectionLeftCenter` of `CYLImageTagDirection` -> `leftCenter`, the Swift case name."""
    rest = name[len(owner):] if owner and name.startswith(owner) else name
    return rest[:1].lower() + rest[1:] if rest else name


def build():
    symbols = kotlin_symbols()
    api_map = mapped_from_api_map()
    hand = json.loads(IOS_MAP.read_text(encoding="utf-8")) if IOS_MAP.exists() else {}
    ios = ios_names()
    rows, done = [], 0
    for file, owner, name, kind, line in symbols:
        key = f"{owner}.{name}" if owner else name
        if key in hand:
            counterpart = hand[key]
        elif key in api_map:
            counterpart = f"`{api_map[key]}`"
        elif name in ios or swift_case(owner, name) in ios:
            counterpart = f"`{name}` (same name in the iOS core)"
        else:
            counterpart = "TODO"
        done += counterpart != "TODO"
        desc = {"class": "class", "interface": "interface", "object": "object", "fun": "method", "val": "read-only property",
                "var": "property", "entry": "enum case"}[kind]
        rows.append(f"| `{key}` | {desc}, `{file}:{line}` | {counterpart} |")
    total = len(rows)
    score = 100.0 * done / total if total else 100.0
    head = f"""---
title: Android and iOS core API (Android -> iOS)
date: 2026-11-17
tags: [android, ios, api-parity, score]
---

# Android and iOS core API (Android -> iOS)

Every public symbol of the Android core (`android/merged/library`, Kotlin) and its counterpart in the iOS core
(`CollectionViewClassifyMenu/Class`, `TagCollectionView`, Swift). Generated by `android/scripts/android_public_api.py`
from the Kotlin sources, `android/merged/api-map.json` (the reverse table, [android-api.md](android-api.md)) and
`android/merged/ios-map.json` (hand-made entries); do not edit the table by hand. A row without a counterpart is `TODO`.

**Score: {done} / {total} with an iOS counterpart = {score:.1f} / 100.** Full marks when no row is `TODO`; 0 when every
row is. Loop: match existing iOS code to the `TODO` rows, score, implement the missing iOS APIs in the core first (same
logic and names as Android), show them in the iOS example (a port of the Android example), score again, until 100.

| Android API | Description | iOS API |
|---|---|---|
"""
    return head + "\n".join(rows) + "\n", done, total, score


def main():
    text, done, total, score = build()
    if "--check" in sys.argv:
        current = DOC.read_text(encoding="utf-8") if DOC.exists() else ""
        sys.exit(0 if current == text else 1)
    DOC.write_text(text, encoding="utf-8")
    print(f"{done} / {total} = {score:.1f}")


if __name__ == "__main__":
    main()
