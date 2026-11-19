#!/usr/bin/env python3
"""Checks the localization of the Android, HarmonyOS and mini program ports, the twin of scripts/check-localization.py
(iOS, Flutter, React Native; AGENTS.md "Internationalization and localization").

Usage: python3 scripts/check-localization-ports.py

Every table these ports read is an iOS table, or a file generated from one (Android reads the iOS bundles as assets;
HarmonyOS `CYLExampleStrings.ets` / `CYLCoreStrings.ets` and the mini program `strings.js` / `core-tables.js` are
exported from them). check-localization.py checks those tables (same keys in every language, format specifiers). Here:
  1. code: a Chinese literal is a lookup's argument, a key of the iOS tables (stored and looked up later), or marked
     NOLOCALIZE (on its line, or between NOLOCALIZE-BEGIN and NOLOCALIZE-END): user content and sample data that stay as
     written (reviews, product titles, the places database's source titles, deliberately multilingual sample tags);
  2. the ports' own tables (Android `res/values*`, HarmonyOS `resources/*/element/string.json`): the same names in every
     language, no Chinese in the English (default) table, and no Simplified-only character in the Traditional Chinese
     table. Simplified-only characters are learned from the iOS tables: where a key (Simplified) and its zh-Hant value
     differ at the same position, the key's character is Simplified-only.
Exits 1 when anything is found.
"""
import json
import pathlib
import re
import sys

# Problems quote source lines (emoji, CJK): print UTF-8 on any console (a GBK Windows console crashed on an emoji).
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

ROOT = pathlib.Path(__file__).resolve().parent.parent
HAN = re.compile("[一-鿿]")

IOS_TABLES = {
    "Example/CYLMenuExample/CYLMenuExample.bundle": "Localizable.strings",
    "Example-Swift/CYLTagEditorExample/CYLTagEditorExample.bundle": "Localizable.strings",
    "CollectionViewClassifyMenu/Resources/Localization": "CYLClassifyMenu.strings",
}

PORTS = [
    {
        "name": "Android",
        "sources": ["android/merged/library/src/main/java", "android/merged/example/src/main/java"],
        "suffixes": [".kt", ".java"],
        "lookups": ["CYLExampleLocalizedString", "CYLMenuLocalizedString", "CYLTagEditorLocalizedString",
                    "CYLMenuLocalizedStringForKey"],
        "generated": [],
    },
    {
        "name": "HarmonyOS",
        "sources": ["harmony/classifymenu/src/main/ets", "harmony/entry/src/main/ets"],
        "suffixes": [".ets", ".ts"],
        "lookups": ["CYLExampleLocalizedString", "CYLMenuLocalizedString"],
        "generated": ["CYLExampleStrings.ets", "CYLCoreStrings.ets"],
    },
    {
        "name": "mini program",
        "sources": ["CrossPlatform/wechat-miniprogram/miniprogram/pages",
                    "CrossPlatform/wechat-miniprogram/miniprogram/components",
                    "CrossPlatform/wechat-miniprogram/miniprogram/custom-tab-bar",
                    "CrossPlatform/wechat-miniprogram/miniprogram/utils",
                    "CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram/miniprogram_dist"],
        "suffixes": [".js", ".wxml"],
        "lookups": ["t", "CYLMenuLocalizedString", "localizedString", "resultString"],
        # Generated tables, and CYLTabBarController's vendored component (checked in its own repository).
        "generated": ["strings.js", "core-tables.js", "cyl-animated-item", "cyl-animation-placeholder"],
    },
]

ENTRY = re.compile(r'^\s*"((?:[^"\\]|\\.)*)"\s*=\s*"((?:[^"\\]|\\.)*)"\s*;', re.M)


def read_strings(path):
    text = re.sub(r"/\*.*?\*/", "", path.read_text(encoding="utf-8"), flags=re.S)
    return {m.group(1): m.group(2) for m in ENTRY.finditer(text)}


def ios_tables():
    """{language: {key: value}} of every iOS table the ports read."""
    tables = {}
    for folder, name in IOS_TABLES.items():
        for lang in ("en", "zh-Hans", "zh-Hant"):
            path = ROOT / folder / f"{lang}.lproj" / name
            if path.exists():
                tables.setdefault(lang, {}).update(read_strings(path))
    return tables


def simplified_only(tables):
    """Characters of the Simplified keys that zh-Hant writes differently at the same position."""
    chars = set()
    for key, value in tables.get("zh-Hant", {}).items():
        if len(key) == len(value):
            for a, b in zip(key, value):
                if a != b and HAN.match(a) and HAN.match(b):
                    chars.add(a)
    # A character that zh-Hant also uses as written somewhere is not Simplified-only.
    used = set("".join(tables.get("zh-Hant", {}).values()))
    return chars - used


def strip_comments(text):
    """Comments blanked (line numbers kept), strings left as they are."""
    def blank(match):
        s = match.group(0)
        return s if s[0] in "\"'`" else re.sub(r"[^\n]", " ", s)
    return re.sub(r'"(?:[^"\\\n]|\\.)*"|\'(?:[^\'\\\n]|\\.)*\'|`(?:[^`\\]|\\.)*`|//[^\n]*|/\*.*?\*/|<!--.*?-->',
                  blank, text, flags=re.S)


LITERAL = re.compile(r'"((?:[^"\\\n]|\\.)*)"|\'((?:[^\'\\\n]|\\.)*)\'|`((?:[^`\\\n]|\\.)*)`')


def call_spans(line, lookups):
    """The (start, end) of every lookup call's arguments on the line, to its closing parenthesis."""
    spans = []
    for m in re.finditer(r"(?<![\w.])(?:" + "|".join(lookups) + r")\s*\(", line):
        depth, i = 1, m.end()
        while i < len(line) and depth:
            c = line[i]
            if c in "\"'`":
                q = LITERAL.match(line, i)
                i = q.end() if q else i + 1
                continue
            depth += {"(": 1, ")": -1}.get(c, 0)
            i += 1
        spans.append((m.end(), i))
    return spans


def check_code(port, keys):
    problems = 0
    for source in port["sources"]:
        for f in sorted((ROOT / source).rglob("*")):
            if f.suffix not in port["suffixes"] or any(g in f.as_posix() for g in port["generated"]):
                continue
            raw = f.read_text(encoding="utf-8")
            raw_lines = raw.split("\n")
            text = strip_comments(raw)
            excluded = False
            for number, line in enumerate(text.split("\n"), 1):
                raw_line = raw_lines[number - 1]
                if "NOLOCALIZE-BEGIN" in raw_line:
                    excluded = True
                if "NOLOCALIZE-END" in raw_line:
                    excluded = False
                    continue
                if excluded or "NOLOCALIZE" in raw_line:
                    continue
                spans = call_spans(line, port["lookups"])
                for m in LITERAL.finditer(line):
                    value = next(g for g in m.groups() if g is not None)
                    shown = value
                    if m.group(3) is not None:
                        # A template string: its `${…}` parts are code; only the text around them is shown as written.
                        shown = re.sub(r"\$\{(?:[^{}]|\{[^{}]*\})*\}", "", value)
                    if not HAN.search(shown) or value in keys or any(s <= m.start() < e for s, e in spans):
                        continue
                    print(f"[{port['name']}] {f.relative_to(ROOT).as_posix()}:{number}: Chinese literal outside the "
                          f"lookup: \"{value[:40]}\"")
                    problems += 1
    return problems


def check_own_tables(simplified):
    problems = 0
    # Android res/values* of the library and the example: {folder: {name: value}}.
    for res in ["android/merged/library/src/main/res", "android/merged/example/src/main/res"]:
        folders = {}
        for xml in sorted((ROOT / res).glob("values*/*.xml")):
            for m in re.finditer(r'<string\s+name="([^"]+)"([^>]*)>(.*?)</string>', xml.read_text(encoding="utf-8"), re.S):
                # translatable="false": a name that stays as written (the app's brand, an activity's class name).
                if 'translatable="false"' not in m.group(2):
                    folders.setdefault(xml.parent.name, {})[m.group(1)] = m.group(3)
        problems += compare(f"Android {res.split('/')[2]}", folders, "values", ["values-zh-rTW"], simplified)
    # HarmonyOS string.json of each module.
    for module in ["harmony/classifymenu", "harmony/entry", "harmony/cylanimateditem"]:
        folders = {}
        for path in sorted((ROOT / module / "src/main/resources").glob("*/element/string.json")):
            entries = json.loads(path.read_text(encoding="utf-8")).get("string", [])
            folders[path.parent.parent.name] = {e["name"]: e["value"] for e in entries}
        problems += compare(f"HarmonyOS {module.split('/')[1]}", folders, "en_US" if "en_US" in folders else "base",
                            ["zh_TW"], simplified)
    return problems


def compare(name, folders, english, traditional, simplified):
    problems = 0
    translated = {k: v for k, v in folders.items() if k in ("values", "values-zh-rCN", "values-zh-rTW", "base",
                                                             "en_US", "zh_CN", "zh_TW")}
    if len(translated) > 1:
        reference = set(translated.get("base", translated.get("values", {})))
        for folder, entries in translated.items():
            for key in sorted(reference ^ set(entries)):
                print(f"[{name}] {folder}: \"{key}\" {'missing' if key in reference else 'not in the base table'}")
                problems += 1
    for key, value in folders.get(english, {}).items():
        # A handle ("@iOS程序犭袁", the author's) is a name and stays as written.
        if HAN.search(re.sub(r"@\S+", "", value)) and "NOLOCALIZE" not in key:
            print(f"[{name}] {english}: Chinese in the English table: {key} = \"{value[:40]}\"")
            problems += 1
    for folder in traditional:
        for key, value in folders.get(folder, {}).items():
            found = sorted(set(value) & simplified)
            if found:
                print(f"[{name}] {folder}: Simplified-only {''.join(found)} in {key} = \"{value[:40]}\"")
                problems += 1
    return problems


def main():
    tables = ios_tables()
    keys = set().union(*[set(t) for t in tables.values()]) if tables else set()
    simplified = simplified_only(tables)
    problems = sum(check_code(port, keys) for port in PORTS)
    problems += check_own_tables(simplified)
    print(f"{problems} problem(s) ({len(simplified)} Simplified-only characters learned from the iOS tables)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
