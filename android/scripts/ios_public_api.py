#!/usr/bin/env python3
"""List the public API of the iOS core (the pod's headers) and write the iOS / Android table.

  ios_public_api.py --list          print every public iOS symbol, one per line
  ios_public_api.py                 write docs/android-api.md from the headers and android/merged/api-map.json
  ios_public_api.py --check         exit 1 when docs/android-api.md is out of date

A symbol is a class / protocol / category, a property, a method (with its selector), an enum value, a constant, a
function, a typedef or a macro of CollectionViewClassifyMenu/Class/**/*.h. api-map.json maps a symbol to its Android
counterpart in android/merged: {"<symbol>": "<Kotlin API>"}; a symbol without an entry is a TODO row. The score is
aligned symbols / all symbols, out of 100.
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
HEADERS = ROOT / "CollectionViewClassifyMenu/Class"
# The podspec's other source pattern: TagCollectionView/TagCollectionView/{CYLTagView,Model/*,Views/*}.h.
TAG_COLLECTION = ROOT / "TagCollectionView/TagCollectionView"


def header_files():
    """
    Every public header of the pod, in the podspec's source patterns.
    """
    files = sorted(HEADERS.rglob("*.h"))
    files += [TAG_COLLECTION / "CYLTagView.h"] + sorted((TAG_COLLECTION / "Model").glob("*.h")) + sorted((TAG_COLLECTION / "Views").glob("*.h"))
    return [f for f in files if not f.name.startswith("._")]
MAP = ROOT / "android/merged/api-map.json"
DOC = ROOT / "docs/android-api.md"


def strip_comments(text: str) -> str:
    text = re.sub(r"/\*.*?\*/", " ", text, flags=re.S)
    return re.sub(r"//[^\n]*", " ", text)


def statements(text: str):
    """Split a header into declarations: up to ';' or a line ending a block keyword."""
    buffer = ""
    depth = 0
    for line in text.split("\n"):
        stripped = line.strip()
        if not stripped or stripped.startswith("#import") or stripped.startswith("#include"):
            continue
        if stripped.startswith("#define"):
            yield stripped
            continue
        if stripped.startswith("#") or stripped in ("NS_ASSUME_NONNULL_BEGIN", "NS_ASSUME_NONNULL_END"):
            continue
        if re.match(r"^@(interface|protocol|end|optional|required)\b", stripped) and depth == 0:
            if buffer.strip():
                yield buffer.strip()
                buffer = ""
            yield stripped
            continue
        buffer += " " + stripped
        depth += stripped.count("{") - stripped.count("}")
        if depth <= 0 and (stripped.endswith(";") or stripped.endswith("}")):
            yield buffer.strip()
            buffer = ""
            depth = 0
    if buffer.strip():
        yield buffer.strip()


def selector(declaration: str) -> str:
    body = re.sub(r"\s+", " ", declaration)
    body = re.sub(r"\b(NS_SWIFT_NAME|NS_DESIGNATED_INITIALIZER|NS_UNAVAILABLE|NS_SWIFT_UNAVAILABLE|API_AVAILABLE|API_DEPRECATED|API_DEPRECATED_WITH_REPLACEMENT|NS_REFINED_FOR_SWIFT|__attribute__)\s*(\((?:[^()]|\([^()]*\))*\))?", "", body)
    body = body.rstrip(";").strip()
    kind = body[0]
    body = body[1:].strip()
    body = re.sub(r"^\((?:[^()]|\([^()]*\))*\)\s*", "", body)  # return type
    parts = re.findall(r"(\w+)\s*:", body)
    if parts:
        return kind + "".join(p + ":" for p in parts)
    return kind + re.match(r"(\w+)", body).group(1)


def symbols():
    found = []
    for header in header_files():
        text = strip_comments(header.read_text(encoding="utf-8"))
        owner = None
        relative = header.relative_to(ROOT).as_posix()
        for statement in statements(text):
            m = re.match(r"^@interface\s+(\w+)\s*(?:\((\w*)\))?", statement)
            if m:
                owner = m.group(1) + (f" ({m.group(2)})" if m.group(2) else "")
                found.append((relative, owner, "class" if not m.group(2) else "category", owner))
                continue
            m = re.match(r"^@protocol\s+(\w+)(?!\s*;)", statement)
            if m and not statement.rstrip().endswith(";"):
                owner = m.group(1)
                found.append((relative, owner, "protocol", owner))
                continue
            if statement.startswith("@end"):
                owner = None
                continue
            if statement.startswith("@optional") or statement.startswith("@required") or statement.startswith("@class") or statement.startswith("@protocol"):
                continue
            if statement.startswith("@property"):
                name = re.findall(r"\**\s*(\w+)\s*(?:NS_\w+(?:\([^)]*\))?\s*)*;?$", statement.rstrip(";").strip() + ";")
                prop = re.sub(r"\s*(NS_\w+|API_\w+|__\w+)(\((?:[^()]|\([^()]*\))*\))?", "", statement).rstrip(";").strip()
                prop_name = re.findall(r"(\w+)\s*$", prop)
                if prop_name:
                    found.append((relative, owner, "property", f"{owner}.{prop_name[0]}"))
                continue
            if statement[:1] in "-+" and owner:
                found.append((relative, owner, "method", f"{owner} {selector(statement)}"))
                continue
            if statement.startswith("#define"):
                m = re.match(r"#define\s+(CYL\w+)", statement)
                if m:
                    found.append((relative, None, "macro", m.group(1)))
                continue
            m = re.match(r"^typedef\s+NS_(?:ENUM|OPTIONS|CLOSED_ENUM)\s*\(\s*\w+\s*,\s*(\w+)\s*\)\s*\{(.*)\}", statement, flags=re.S)
            if m:
                found.append((relative, None, "enum", m.group(1)))
                for case in re.findall(r"(CYL\w+)\s*(?:=[^,}]*)?(?:,|$)", m.group(2)):
                    found.append((relative, m.group(1), "enum value", case))
                continue
            m = re.match(r"^typedef\s+NSString\s*\*\s*(\w+)\s+NS_(?:TYPED_ENUM|TYPED_EXTENSIBLE_ENUM|STRING_ENUM|EXTENSIBLE_STRING_ENUM)", statement)
            if m:
                found.append((relative, None, "typedef", m.group(1)))
                continue
            m = re.match(r"^typedef\b.*?\(\s*\^\s*(\w+)\s*\)", statement) or re.match(r"^typedef\b.*?\b(CYL\w+)\s*;", statement)
            if m:
                found.append((relative, None, "typedef", m.group(1)))
                continue
            m = re.match(r"^(?:FOUNDATION_EXPORT|FOUNDATION_EXTERN|UIKIT_EXTERN|extern)\s+[^(]*?\b(\w+)\s*(?:NS_\w+(?:\([^)]*\))?\s*)*;", statement)
            if m:
                found.append((relative, None, "constant", m.group(1)))
                continue
            m = re.match(r"^(?:static\s+inline\s+|NS_INLINE\s+|FOUNDATION_EXPORT\s+)?[\w\s\*]+?\b(CYL\w+|cyl_\w+)\s*\(", statement)
            if m and not statement.startswith("typedef"):
                found.append((relative, None, "function", m.group(1)))
                continue
    # one row per symbol, first declaration wins
    seen = set()
    unique = []
    for row in found:
        if row[3] in seen:
            continue
        seen.add(row[3])
        unique.append(row)
    return unique


def render(rows, mapping):
    aligned = sum(1 for row in rows if mapping.get(row[3]))
    total = len(rows)
    score = 100.0 * aligned / total if total else 100.0
    lines = [
        "---",
        "title: iOS and Android public API",
        "date: 2026-11-12",
        "tags: [android, kotlin, api-parity]",
        "---",
        "",
        "# iOS and Android public API",
        "",
        "Every public symbol of the iOS core (the pod's headers, `CollectionViewClassifyMenu/Class` and `TagCollectionView/TagCollectionView`), and its counterpart",
        "in `android/merged` (Kotlin). Generated by `android/scripts/ios_public_api.py` from the headers and",
        "`android/merged/api-map.json`; do not edit the table by hand. A row without a counterpart is marked `TODO`.",
        "",
        f"**Score: {aligned} / {total} aligned = {score:.1f} / 100.** Full marks when every iOS symbol has an Android",
        "counterpart. The score history is in [android.md](android.md).",
        "",
        "| iOS (header) | Kind | Android (`android/merged`) |",
        "| --- | --- | --- |",
    ]
    for header, owner, kind, symbol in rows:
        target = mapping.get(symbol)
        cell = f"`{target}`" if target else "TODO"
        lines.append(f"| `{symbol}` ({pathlib.Path(header).name}) | {kind} | {cell} |")
    lines.append("")
    return "\n".join(lines), aligned, total, score


def main() -> int:
    rows = symbols()
    if "--list" in sys.argv:
        for header, owner, kind, symbol in rows:
            print(f"{kind}\t{symbol}\t{header}")
        print(f"{len(rows)} symbols", file=sys.stderr)
        return 0
    mapping = json.loads(MAP.read_text(encoding="utf-8")) if MAP.exists() else {}
    unknown = sorted(set(mapping) - {row[3] for row in rows})
    if unknown:
        print("api-map.json names symbols the headers do not declare: " + ", ".join(unknown[:10]), file=sys.stderr)
        return 1
    text, aligned, total, score = render(rows, mapping)
    if "--check" in sys.argv:
        current = DOC.read_text(encoding="utf-8") if DOC.exists() else ""
        if current != text:
            print("docs/android-api.md is out of date", file=sys.stderr)
            return 1
        return 0
    DOC.write_text(text, encoding="utf-8")
    print(f"{aligned} / {total} = {score:.1f}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
