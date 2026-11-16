#!/usr/bin/env python3
"""iOS -> Android API table: every public symbol of the iOS core and its Android counterpart.

  ios_public_api.py --list          print every public iOS symbol, one per line
  ios_public_api.py                 write docs/android-api.md
  ios_public_api.py --check         exit 1 when docs/android-api.md is out of date

The iOS core is Swift since the migration (docs/Swift-Migration.md): the symbols are the public / open declarations of
CollectionViewClassifyMenu/Class and of the podspec's TagCollectionView files (types, properties, methods with their
Objective-C selector, enum cases, global constants and functions). Protocol conformance (UIKit data sources and
delegates, and the library's own delegate protocols implemented by its classes) is left out, as the Objective-C headers
did. A symbol has an Android counterpart when android/merged/api-map.json maps it (by its key, or by the key the same
symbol had in the Objective-C headers), or when the Android core (android/merged/library) declares the same name on the
same type. Everything else is TODO. Score = symbols with a counterpart / all symbols x 100.
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
MAP = ROOT / "android/merged/api-map.json"
DOC = ROOT / "docs/android-api.md"
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))

PREPOSITION = re.compile(r"^(with|in|at|to|for|from|of|by|on|into|onto|under|over|after|before|between|as|using|via)(?=[A-Z]|$)")
TYPE = re.compile(r"\b(class|struct|enum|protocol|extension|actor)\s+(?!(?:func|var|let|subscript)\b)(\w+)")


def swift_files(root):
    core = root / "CollectionViewClassifyMenu/Class"
    tag = root / "TagCollectionView/TagCollectionView"
    files = sorted(core.rglob("*.swift"))
    files += [tag / "CYLTagView.swift"] + sorted((tag / "Model").glob("*.swift")) + sorted((tag / "Views").glob("*.swift"))
    return [f for f in files if f.exists() and not f.name.startswith("._")]


def strip(text):
    text = re.sub(r"/\*.*?\*/", lambda m: "\n" * m.group(0).count("\n"), text, flags=re.S)
    text = re.sub(r'"(?:\\.|[^"\\\n])*"', '""', text)
    return re.sub(r"//[^\n]*", "", text)


def cap(s):
    return s[:1].upper() + s[1:]


def split_params(sig):
    depth, cur, out = 0, "", []
    for ch in sig:
        if ch in "([<":
            depth += 1
        elif ch in ")]>":
            depth -= 1
        if ch == "," and depth == 0:
            out.append(cur)
            cur = ""
        else:
            cur += ch
    out.append(cur)
    return [p.strip() for p in out if p.strip()]


def param_words(params):
    """[[label, internal name?], ...] of a parameter list."""
    return [p.split(":")[0].strip().split() or ["_"] for p in params]


def objc_selector(name, params, is_init):
    """Swift's own Objective-C name: `foo(_:bar:)` -> foo:bar:, `foo(bar:)` -> fooWithBar:, `foo(in:)` -> fooIn:."""
    words = param_words(params)
    if not words:
        return "init" if is_init else name
    first = words[0][0]
    if is_init:
        head = "init:" if first == "_" else "initWith" + cap(first) + ":"
    elif first == "_":
        head = name + ":"
    else:
        head = name + ("" if PREPOSITION.match(first) else "With") + cap(first) + ":"
    return head + "".join(("" if w[0] == "_" else w[0]) + ":" for w in words[1:])


def legacy_selector(name, params, is_init):
    """The header's selector before the migration: a preposition label kept its parameter name
    (`tagButton(at indexPath:)` -> tagButtonAtIndexPath:, `init(title:)` -> initWithTitle:)."""
    words = param_words(params)
    if not words:
        return "init" if is_init else name
    label = words[0][0]
    inner = words[0][1] if len(words[0]) > 1 else label
    if is_init:
        head = "initWith" + cap(inner if label == "_" else label) + ":"
    elif label == "_":
        head = name + ":"
    else:
        head = name + cap(label) + (cap(inner) if inner != label else "") + ":"
    tail = "".join(((w[0] if w[0] != "_" else (w[1] if len(w) > 1 else "")) + ":") for w in words[1:])
    return head + tail


def symbols(root):
    found = []
    for path in swift_files(root):
        rel = path.relative_to(root).as_posix()
        m = re.match(r"(\w+)\+(\w+)\.swift$", path.name)
        category = m.group(2) if m else None
        text = strip(path.read_text(encoding="utf-8"))
        stack = []  # (body depth, owner, kind, members public, objc enum)
        depth = 0
        attrs = ""
        pending = None  # a type whose "{" is on a later line
        for raw in text.split("\n"):
            line = raw.strip()
            if not line:
                continue
            if pending is not None:
                if "{" in raw:
                    stack.append((depth + 1,) + pending)
                    pending = None
                depth += raw.count("{") - raw.count("}")
                continue
            while stack and depth < stack[-1][0]:
                stack.pop()
            if line.startswith("@") and not re.search(r"\b(func|var|let|class|struct|enum|protocol|extension|init|case)\b", line):
                attrs += " " + line
                depth += raw.count("{") - raw.count("}")
                continue
            full = attrs + " " + line
            attrs = ""
            objc = re.search(r"@objc\((\w+(?::\w*)*:?)\)", full)
            access = re.search(r"\b(public|open)\b", line)
            private = re.search(r"\b(private|fileprivate|internal)\b", line.split("(")[0])
            head = line.split("{")[0]
            tm = TYPE.search(head)
            owner = stack[-1][1] if stack else None
            in_public = stack[-1][3] if stack else False
            if tm and not re.search(r"\b(func|var|let|case|init)\b", head.split(tm.group(0))[0]):
                kind, name = tm.group(1), tm.group(2)
                if kind == "extension":
                    owner_name = f"{name} ({category})" if category else name
                    if access and category:
                        found.append((rel, None, "category", owner_name, []))
                    entry = (owner_name, "extension", bool(access), False)
                else:
                    is_public = bool(access) or (in_public and not private)
                    type_name = objc.group(1) if objc else name
                    if is_public:
                        found.append((rel, None, "class" if kind == "actor" else kind, type_name, [name] if type_name != name else []))
                    entry = (type_name, kind, is_public, kind == "enum" and "@objc" in full)
                if "{" in raw:
                    stack.append((depth + 1,) + entry)
                else:
                    pending = entry
                depth += raw.count("{") - raw.count("}")
                continue
            container = stack[-1][2] if stack else None
            if stack and depth != stack[-1][0]:
                # Inside a method body: locals are not API.
                depth += raw.count("{") - raw.count("}")
                continue
            member_public = owner is not None and (bool(access) or (in_public and not private and container in ("protocol", "extension")))
            top_public = bool(access) and not stack
            if stack and container == "enum" and line.startswith("case ") and stack[-1][3]:
                for case in re.findall(r"(?:case\s+|,\s*)(\w+)", line.split("(")[0] if "(" in line else line):
                    key = (owner + cap(case)) if stack[-1][4] else f"{owner}.{case}"
                    found.append((rel, owner, "enum value", key, [owner + cap(case)]))
            elif (member_public or top_public) and not re.search(r"\b(override|required)\b", line):
                is_static = bool(re.search(r"\b(static|class)\s+(func|var|let)\b", line))
                fm = re.search(r"\bfunc\s+(\w+)\s*(?:<[^>]*>)?\s*\(([^)]*(?:\([^)]*\)[^)]*)*)\)", line)
                im = None if fm else re.search(r"\binit[?!]?\s*\(([^)]*(?:\([^)]*\)[^)]*)*)\)", line)
                vm = None if (fm or im) else re.search(r"\b(?:var|let)\s+(\w+)", line)
                if fm or im:
                    name = fm.group(1) if fm else "init"
                    params = split_params(fm.group(2) if fm else im.group(1))
                    sel = objc.group(1) if objc else objc_selector(name, params, not fm)
                    if owner is None:
                        found.append((rel, None, "function", name, []))
                        continue_depth = True
                    else:
                        sign = "+" if is_static else "-"
                        base = owner.split(" (")[0]
                        legacy = legacy_selector(name, params, not fm)
                        alts = [f"{owner} {sign}{legacy}", f"{owner} {sign}{name}"]
                        if base != owner:
                            alts += [f"{base} {sign}{sel}", f"{base} {sign}{legacy}"]
                        found.append((rel, owner, "method", f"{owner} {sign}{sel}", alts))
                elif vm:
                    name = vm.group(1)
                    if owner is None:
                        found.append((rel, None, "constant", name, []))
                    else:
                        base = owner.split(" (")[0]
                        alts = []
                        if objc:
                            alts.append(f"{owner}.{objc.group(1)}")
                        if re.match(r"^is[A-Z]", name):
                            alts.append(f"{owner}.{name[2].lower()}{name[3:]}")
                        if base.endswith("Key"):
                            alts += [base[:-3] + cap(name), base + cap(name)]
                        if base != owner:
                            alts.append(f"{base}.{name}")
                        found.append((rel, owner, "property", f"{owner}.{name}", alts))
            depth += raw.count("{") - raw.count("}")
    # Protocol conformance (UIKit data sources and delegates, and the library's own delegate protocols implemented by
    # its classes) is not API of its own: the Objective-C headers never declared it.
    protocols = {r[3] for r in found if r[2] == "protocol"}
    protocol_selectors = {r[3].split(" ", 1)[1] for r in found if r[2] == "method" and r[1] in protocols}
    uikit = re.compile(r"^[-+](collectionView|tableView|scrollView|numberOfSectionsIn|textField|gestureRecognizer)")

    def conformance(row):
        if row[2] != "method" or row[1] in protocols:
            return False
        selector = row[3].split(" ", 1)[1]
        return bool(uikit.match(selector)) or selector in protocol_selectors

    found = [row for row in found if not conformance(row)]
    seen, unique = set(), []
    for row in found:
        if row[3] not in seen:
            seen.add(row[3])
            unique.append(row)
    return unique


def kotlin_names():
    """{'Owner.name' / 'name'} of the Android core's public declarations."""
    from android_public_api import kotlin_symbols
    names = set()
    for _file, owner, name, _kind, _line in kotlin_symbols():
        names.add(f"{owner}.{name}" if owner else name)
        if not owner:
            names.add(name)
    return names


def counterpart(row, mapping, kotlin):
    for key in [row[3]] + list(row[4]):
        if mapping.get(key):
            return mapping[key]
    owner = (row[1] or "").split(" (")[0]
    kind, key = row[2], row[3]
    if kind in ("class", "struct", "enum", "protocol", "constant", "function"):
        return f"{key} (same name in the Android core)" if key in kotlin else None
    if kind in ("property", "enum value"):
        name = key.rsplit(".", 1)[-1]
    else:
        name = re.split(r":", key.split(" ", 1)[1][1:])[0]
    return f"{owner}.{name} (same name in the Android core)" if f"{owner}.{name}" in kotlin else None


def render(rows, mapping, kotlin):
    cells = [counterpart(row, mapping, kotlin) for row in rows]
    aligned = sum(1 for cell in cells if cell)
    total = len(rows)
    score = 100.0 * aligned / total if total else 100.0
    lines = [
        "---",
        "title: iOS and Android public API",
        "date: 2026-11-17",
        "tags: [android, kotlin, api-parity, score]",
        "---",
        "",
        "# iOS and Android public API (iOS -> Android)",
        "",
        "Every public symbol of the iOS core (Swift: `CollectionViewClassifyMenu/Class` and the podspec's",
        "`TagCollectionView` files) and its counterpart in `android/merged` (Kotlin). Generated by",
        "`android/scripts/ios_public_api.py` from the Swift sources, `android/merged/api-map.json` and the Kotlin sources; do",
        "not edit the table by hand. A row without a counterpart is `TODO`. The reverse table is",
        "[android-ios-api.md](android-ios-api.md).",
        "",
        f"**Score: {aligned} / {total} with an Android counterpart = {score:.1f} / 100.** Full marks when no row is `TODO`; 0",
        "when every row is. Loop (AGENTS.md \"Parity tables and the score loop\"): match existing Android code to the `TODO`",
        "rows, score, implement the missing Android APIs in the core first (same logic and names as iOS), show them in the",
        "Android example, score again, until 100. The score history is in [android.md](android.md).",
        "",
        "| iOS API | Description | Android API |",
        "| --- | --- | --- |",
    ]
    for row, cell in zip(rows, cells):
        lines.append(f"| `{row[3]}` | {row[2]}, `{pathlib.Path(row[0]).name}` | {('`' + cell + '`') if cell else 'TODO'} |")
    lines.append("")
    return chr(10).join(lines), aligned, total, score


def main() -> int:
    rows = symbols(ROOT)
    if "--list" in sys.argv:
        for row in rows:
            print(row[2], row[3], row[0], sep=chr(9))
        print(f"{len(rows)} symbols", file=sys.stderr)
        return 0
    mapping = json.loads(MAP.read_text(encoding="utf-8")) if MAP.exists() else {}
    kotlin = kotlin_names()
    text, aligned, total, score = render(rows, mapping, kotlin)
    if "--check" in sys.argv:
        current = DOC.read_text(encoding="utf-8") if DOC.exists() else ""
        if current != text:
            print("docs/android-api.md is out of date", file=sys.stderr)
            return 1
        return 0
    DOC.write_text(text, encoding="utf-8")
    used = {key for row in rows for key in [row[3]] + list(row[4]) if key in mapping}
    stale = sorted(set(mapping) - used)
    if stale:
        print(f"{len(stale)} api-map.json keys name no Swift symbol (removed or renamed in the migration)", file=sys.stderr)
    print(f"{aligned} / {total} = {score:.1f}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
