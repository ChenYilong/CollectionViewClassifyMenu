#!/usr/bin/env python3
"""Add to android/merged/api-map.json every iOS symbol whose same-named Kotlin API exists in com.cyl.classifymenu.

  api_map_from_kotlin.py            add the verified mappings, print what is still missing for ported classes
  api_map_from_kotlin.py --dry-run  print only

A symbol maps only when the Kotlin source declares it: a class / interface / object / enum of the same name, a member
(`var`, `val` or `fun` of the property name or of the selector's first keyword) declared in that type's file, an enum
entry, or a top-level `const val` / `val` / `fun`. Existing entries are kept. Initializers and other renamed members
are mapped by hand in api-map.json.
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "android/scripts"))
import ios_public_api  # noqa: E402

KOTLIN = ROOT / "android/merged/library/src/main/java/com/cyl/classifymenu"
MAP = ROOT / "android/merged/api-map.json"


def kotlin_sources():
    files = {}
    for path in sorted(KOTLIN.rglob("*.kt")):
        if not path.name.startswith("._"):
            files[path] = path.read_text(encoding="utf-8")
    return files


def type_file(sources, name):
    pattern = re.compile(rf"^\s*(?:(?:open|abstract|data|enum|sealed|internal|public|fun)\s+)*(?:class|interface|object)\s+{re.escape(name)}\b", re.M)
    for path, text in sources.items():
        if pattern.search(text):
            return path
    return None


def declares_member(text, name):
    return re.search(rf"\b(?:var|val|fun)\s+(?:<[^>]+>\s+)?(?:[\w.]+\.)?{re.escape(name)}\b", text) is not None


def declares_extension(sources, type_name, name):
    pattern = re.compile(rf"\b(?:var|val|fun)\s+(?:<[^>]+>\s+)?{re.escape(type_name)}(?:\.Companion)?\.{re.escape(name)}\b")
    return any(pattern.search(text) for text in sources.values())


def declares_top_level(sources, name):
    pattern = re.compile(rf"^(?:const\s+val|val|var|fun|@JvmField\s+val)\s+(?:[\w.]+\.)?{re.escape(name)}\b|^\s*{re.escape(name)}\s*[(,]|^\s*{re.escape(name)}\s*$", re.M)
    return any(pattern.search(text) for text in sources.values())


def member_name(symbol):
    method = re.match(r"^(.*?) ([-+])(\w+)", symbol)
    if method:
        return method.group(1), method.group(3)
    owner, _, prop = symbol.rpartition(".")
    return owner, prop


def main() -> int:
    sources = kotlin_sources()
    mapping = json.loads(MAP.read_text(encoding="utf-8")) if MAP.exists() else {}
    added, missing = {}, []
    for header, owner, kind, symbol in ios_public_api.symbols():
        if mapping.get(symbol):
            continue
        target = None
        if kind in ("class", "protocol"):
            if type_file(sources, symbol):
                target = f"com.cyl.classifymenu.{symbol}"
        elif kind in ("property", "method"):
            type_name, member = member_name(symbol)
            type_name = type_name.split(" (")[0]
            path = type_file(sources, type_name)
            if path and (declares_member(sources[path], member) or declares_extension(sources, type_name, member)):
                target = f"{type_name}.{member}"
            elif path:
                missing.append(symbol)
        elif kind in ("constant", "enum value", "function", "typedef", "macro", "enum"):
            if kind == "enum" and type_file(sources, symbol):
                target = f"com.cyl.classifymenu.{symbol}"
            elif declares_top_level(sources, symbol):
                target = symbol
        if target:
            added[symbol] = target
    if "--dry-run" not in sys.argv:
        mapping.update(added)
        MAP.write_text(json.dumps(mapping, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"added {len(added)}")
    for symbol in missing:
        print(f"missing in a ported type: {symbol}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
