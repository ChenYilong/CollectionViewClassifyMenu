#!/usr/bin/env python3
"""Copy the three Kotlin libraries into android/merged/library, unchanged except for the R import.

The merged library has one namespace (com.cyl.classifymenu), so the classes of the three original packages
(me.kaede.tagview, co.lujun.androidtagview, com.licrafter.tagview) import that R. Run it after changing a library in
android/android-tagview, android/AndroidTagView or android/TagViewGroup; --check reports differences and exits 1.
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
NAMESPACE = "com.cyl.classifymenu"
SOURCES = [
    ("android-tagview/library/src/main", "me/kaede/tagview"),
    ("AndroidTagView/androidtagview/src/main", "co/lujun/androidtagview"),
    ("TagViewGroup/library/src/main", "com/licrafter/tagview"),
]
TARGET = ROOT / "merged/library/src/main"


def converted(text: str) -> str:
    # An explicit import of an original package's R becomes the merged library's R.
    text = re.sub(r"^import (me\.kaede\.tagview|co\.lujun\.androidtagview|com\.licrafter\.tagview)\.R$", f"import {NAMESPACE}.R", text, flags=re.M)
    if re.search(r"\bR\.", text) and f"import {NAMESPACE}.R" not in text:
        text = re.sub(r"^(package [\w.]+\n)", rf"\1\nimport {NAMESPACE}.R\n", text, count=1, flags=re.M)
    return text


def expected_files():
    files = {}
    for module, package in SOURCES:
        base = ROOT / module
        for path in sorted((base / "java" / package).rglob("*.kt")):
            if path.name.startswith("._"):
                continue
            files[TARGET / "java" / path.relative_to(base / "java")] = converted(path.read_text(encoding="utf-8"))
        for path in sorted((base / "res").rglob("*.xml")):
            if path.name.startswith("._"):
                continue
            relative = path.relative_to(base / "res")
            # One values file per original library, so their resources stay apart.
            name = f"{module.split('/')[0].lower().replace('-', '_')}_{relative.name}" if relative.parts[0] == "values" else relative.name
            files[TARGET / "res" / relative.parent / name] = path.read_text(encoding="utf-8")
    return files


def main() -> int:
    check = "--check" in sys.argv
    stale = []
    for path, text in expected_files().items():
        current = path.read_text(encoding="utf-8") if path.exists() else None
        if current != text:
            stale.append(path.relative_to(ROOT))
            if not check:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(text, encoding="utf-8")
    for path in stale:
        print(("stale: " if check else "updated: ") + str(path))
    return 1 if check and stale else 0


if __name__ == "__main__":
    sys.exit(main())
