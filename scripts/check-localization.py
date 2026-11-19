#!/usr/bin/env python3
"""Checks the iOS string tables against the code that looks them up (AGENTS.md "Internationalization and localization").

Usage: python3 scripts/check-localization.py [--unused]

For every module (core, demo app, Example, Swift Example):
  1. every key passed as a literal to the module's lookup exists in every translated language of its bundle
     (Example bundles: en and zh-Hant; their keys are the Simplified Chinese source, so zh-Hans needs no entry);
  2. every translation keeps the key's format specifiers (%@, %ld, %d, ...), in order;
  3. no Chinese string literal is shown without the lookup: a literal with Chinese characters outside a lookup call
     and a comment that is not a key of every table (keys stored and looked up later pass) is reported, unless its line
     says NOLOCALIZE, or it sits between NOLOCALIZE-BEGIN and NOLOCALIZE-END comments: user-generated content and sample
     data that stay as written (reviews, a shop's product title, song names, deliberately multilingual sample tags);
  4. with --unused, keys no code mentions are listed (keys built at run time are reported too, so review by hand).
  5. the Flutter and React Native examples: a Chinese literal is a lookup's argument, a key of their generated tables
     (exported from the iOS bundle), or marked NOLOCALIZE.
Exits 1 when 1-3 or 5 find anything.
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent

MODULES = [
    {
        "name": "core",
        "lookup": "CYLMenuLocalizedString",
        "tables": "CollectionViewClassifyMenu/Resources/Localization/{lang}.lproj/CYLClassifyMenu.strings",
        "languages": ["en", "zh-Hans", "zh-Hant"],
        "sources": ["CollectionViewClassifyMenu/Class"],
        "exclude": ["CollectionViewClassifyMenu/Class/ClassifyMenu/Controller/CYLMainViewController.swift",
                    "CollectionViewClassifyMenu/Class/ClassifyMenu/Controller/CYLFilterDemoViewController.swift",
                    "CollectionViewClassifyMenu/Class/ClassifyMenu/Controller/CYLDemoDataSource.swift",
                    "CollectionViewClassifyMenu/Class/Other/Symtem"],
    },
    {
        "name": "demo app",
        "lookup": "CYLDemoLocalizedString",
        "tables": "CollectionViewClassifyMenu/Class/Other/Symtem/CYLClassifyMenuDemo.bundle/{lang}.lproj/Localizable.strings",
        "languages": ["en", "zh-Hans", "zh-Hant"],
        "sources": ["CollectionViewClassifyMenu/Class/ClassifyMenu/Controller/CYLMainViewController.swift",
                    "CollectionViewClassifyMenu/Class/ClassifyMenu/Controller/CYLFilterDemoViewController.swift",
                    "CollectionViewClassifyMenu/Class/ClassifyMenu/Controller/CYLDemoDataSource.swift",
                    "CollectionViewClassifyMenu/Class/Other/Symtem"],
        "exclude": [],
    },
    {
        "name": "Example",
        "lookup": "CYLExampleLocalizedString",
        "tables": "Example/CYLMenuExample/CYLMenuExample.bundle/{lang}.lproj/Localizable.strings",
        "languages": ["en", "zh-Hant"],
        "sources": ["Example/CYLMenuExample", "Example-Shared"],
        "exclude": [],
    },
    {
        "name": "Swift Example",
        "lookup": "CYLTagEditorLocalizedString",
        "tables": "Example-Swift/CYLTagEditorExample/CYLTagEditorExample.bundle/{lang}.lproj/Localizable.strings",
        "languages": ["en", "zh-Hant"],
        "sources": ["Example-Swift/CYLTagEditorExample"],
        "exclude": [],
    },
]

STRINGS_ENTRY = re.compile(r'^\s*"((?:[^"\\]|\\.)*)"\s*=\s*"((?:[^"\\]|\\.)*)"\s*;', re.M)
SPECIFIER = re.compile(r"%(?:\d+\$)?[-+ #0]*\d*(?:\.\d+)?(?:hh|h|ll|l|q|z|t|j)?[@dDuUxXoOfeEgGcCsSp]")
HAN = re.compile(r"[㐀-鿿，。：（）]")
LITERAL = re.compile(r'"((?:[^"\\\n]|\\.)*)"')


def read_table(path):
    if not path.exists():
        return None
    return dict(STRINGS_ENTRY.findall(path.read_text(encoding="utf-8")))


def source_files(module):
    excluded = [ROOT / e for e in module["exclude"]]
    for entry in module["sources"]:
        path = ROOT / entry
        files = [path] if path.is_file() else sorted(path.rglob("*.swift")) + sorted(path.rglob("*.m"))
        for f in files:
            if any(f == e or e in f.parents for e in excluded):
                continue
            yield f


def strip_comments(text):
    # Keeps line numbers: comments become spaces.
    def blank(match):
        return re.sub(r"[^\n]", " ", match.group(0))
    text = re.sub(r"/\*.*?\*/", blank, text, flags=re.S)
    return re.sub(r'//[^\n]*', blank, text)


def specifiers(text):
    return [s.replace("ld", "d").replace("lu", "u").replace("ll", "") for s in SPECIFIER.findall(text)]


CROSS_PLATFORM = [
    {
        "name": "Flutter example",
        "sources": "flutter/cyl_tag_list/example/lib",
        "suffixes": (".dart",),
        "lookups": ["cylString", "cylDataTitle", "cylShortTitle"],
        "tables": ["flutter/cyl_tag_list/example/lib/strings.dart"],
        "generated": ["strings.dart"],
    },
    {
        "name": "React Native example",
        "sources": "react-native/react-native-cyl-tag-list/example/src",
        "suffixes": (".ts", ".tsx"),
        "lookups": ["t", "dataString", "dataTitle", "shortTitle"],
        "tables": ["react-native/react-native-cyl-tag-list/example/src/dataStrings.ts",
                   "react-native/react-native-cyl-tag-list/example/src/i18n.ts"],
        "generated": ["dataStrings.ts", "i18n.ts"],
    },
]


def check_cross_platform():
    """Flutter and React Native examples: a Chinese literal is a lookup's argument, a key of the generated tables
    (looked up later), or marked NOLOCALIZE; tests and the tables themselves are skipped."""
    problems = 0
    for example in CROSS_PLATFORM:
        keys = set()
        for table in example["tables"]:
            keys |= set(re.findall(r"""["']((?:[^"'\\\n]|\\.)*)["']\s*:""", (ROOT / table).read_text(encoding="utf-8")))
        call = re.compile(r"\b(?:" + "|".join(example["lookups"]) + r")\(\s*(['\"])((?:(?!\1)[^\\\n]|\\.)*)\1")
        literal = re.compile(r"(['\"])((?:(?!\1)[^\\\n]|\\.)*)\1")
        for f in sorted((ROOT / example["sources"]).rglob("*")):
            if f.suffix not in example["suffixes"] or f.name in example["generated"] or "__tests__" in f.parts:
                continue
            raw = f.read_text(encoding="utf-8")
            text = strip_comments(raw)
            for number, line in enumerate(text.split("\n"), 1):
                if "NOLOCALIZE" in raw.split("\n")[number - 1]:
                    continue
                spans = [m.span() for m in call.finditer(line)]
                for m in literal.finditer(line):
                    value = m.group(2)
                    if not HAN.search(value) or any(s <= m.start() < e for s, e in spans) or value in keys:
                        continue
                    print(f"[{example['name']}] {f.relative_to(ROOT)}:{number}: Chinese literal outside the lookup: \"{value[:40]}\"")
                    problems += 1
    return problems


def main():
    show_unused = "--unused" in sys.argv
    problems = 0
    for module in MODULES:
        tables = {lang: read_table(ROOT / module["tables"].format(lang=lang)) for lang in module["languages"]}
        for lang, table in tables.items():
            if table is None:
                print(f"[{module['name']}] missing table for {lang}: {module['tables'].format(lang=lang)}")
                problems += 1
        tables = {k: v for k, v in tables.items() if v is not None}
        call = re.compile(re.escape(module["lookup"]) + r'\(\s*@?"((?:[^"\\]|\\.)*)"')
        used = set()
        all_text = ""
        for f in source_files(module):
            raw = f.read_text(encoding="utf-8")
            all_text += raw
            text = strip_comments(raw)
            rel = f.relative_to(ROOT)
            for match in call.finditer(text):
                key = match.group(1)
                used.add(key)
                line = text.count("\n", 0, match.start()) + 1
                for lang, table in tables.items():
                    if key not in table:
                        print(f"[{module['name']}] {rel}:{line}: key missing in {lang}: \"{key}\"")
                        problems += 1
            # Chinese literals outside the lookup.
            lookup_spans = [m.span() for m in call.finditer(text)]
            exempt = False
            for number, line_text in enumerate(text.split("\n"), 1):
                raw_line = raw.split("\n")[number - 1]
                if "NOLOCALIZE-BEGIN" in raw_line:
                    exempt = True
                if "NOLOCALIZE-END" in raw_line:
                    exempt = False
                    continue
                if exempt:
                    continue
                for literal in LITERAL.finditer(line_text):
                    if not HAN.search(literal.group(1)):
                        continue
                    start = sum(len(l) + 1 for l in text.split("\n")[:number - 1]) + literal.start()
                    if any(s <= start < e for s, e in lookup_spans):
                        continue
                    if "NOLOCALIZE" in raw_line:
                        continue
                    if all(literal.group(1) in table for table in tables.values()):
                        # A key stored here and looked up later (titles in a table, a list of keys).
                        continue
                    print(f"[{module['name']}] {rel}:{number}: Chinese literal outside {module['lookup']}: "
                          f"\"{literal.group(1)[:40]}\"")
                    problems += 1
        # Format specifiers.
        for lang, table in tables.items():
            for key, value in table.items():
                source = key
                if module["name"] in ("core", "demo app"):
                    source = tables.get("en", {}).get(key, key)
                if specifiers(source) != specifiers(value) and not (module["name"] in ("core", "demo app") and lang == "en"):
                    print(f"[{module['name']}] {lang}: format specifiers differ: \"{key}\" -> \"{value}\"")
                    problems += 1
        # Languages share keys (core / demo app: all; examples: en and zh-Hant).
        languages = list(tables)
        for a in languages:
            for b in languages:
                if a < b:
                    for key in sorted(set(tables[a]) ^ set(tables[b])):
                        where = a if key in tables[a] else b
                        print(f"[{module['name']}] key only in {where} (not in {b if where == a else a}): \"{key}\"")
                        problems += 1
        if show_unused:
            for key in sorted(set().union(*[set(t) for t in tables.values()]) - used):
                if f'"{key}"' not in all_text:
                    print(f"[{module['name']}] unused key: \"{key}\"")
    problems += check_cross_platform()
    print(f"{problems} problem(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
