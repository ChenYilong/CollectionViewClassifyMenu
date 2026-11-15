"""
Check the HarmonyOS code's localization and accessibility text, without a device:
1. every module's string resources have the same keys in base, en_US, zh_CN and zh_TW (base may hold more:
   app metadata);
2. no user-facing literal in ArkTS: Text('…'), Button('…'), .accessibilityText('…'), .accessibilityDescription('…')
   with letters (symbols such as '▼' or '★' are allowed: the screen reader gets a localized text for them).
Usage: python3 scripts/harmonyos-l10n-check.py   (exit 1 on a problem)
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MODULES = [
    ROOT / "harmony/classifymenu/src/main",
    ROOT / "harmony/entry/src/main",
    ROOT / "react-native/react-native-cyl-tag-list/harmony-example/harmony/entry/src/main",
]
LOCALES = ["en_US", "zh_CN", "zh_TW"]
METADATA = {"module_desc", "EntryAbility_desc", "EntryAbility_label", "app_name"}
CALL = re.compile(r"""(?:\bText|\bButton|\.accessibilityText|\.accessibilityDescription)\(\s*(['"`])(.*?)\1""")
INTERPOLATION = re.compile(r"\$\{[^}]*\}")
WORDS = re.compile(r"[A-Za-z\u4e00-\u9fff]")


def literal(line: str) -> bool:
    """
    True when the call's string has words of its own (outside ${...}, which hold lookups and data).
    """
    match = CALL.search(line)
    return match is not None and WORDS.search(INTERPOLATION.sub("", match.group(2))) is not None


def keys(path: Path):
    return {item["name"] for item in json.loads(path.read_text())["string"]}


def main() -> int:
    problems = []
    for module in MODULES:
        resources = module / "resources"
        base = keys(resources / "base/element/string.json") - METADATA
        for locale in LOCALES:
            path = resources / locale / "element/string.json"
            if not path.exists():
                problems.append(f"{path.relative_to(ROOT)}: missing")
                continue
            missing = base - keys(path)
            if missing:
                problems.append(f"{path.relative_to(ROOT)}: missing {sorted(missing)}")
        for source in (module / "ets").rglob("*.ets"):
            if source.name.startswith("._") or "generated" in source.parts:
                continue
            for number, line in enumerate(source.read_text().splitlines(), 1):
                if literal(line):
                    problems.append(f"{source.relative_to(ROOT)}:{number}: literal text: {line.strip()}")
    for problem in problems:
        print(problem)
    print("OK" if not problems else f"{len(problems)} problem(s)")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
