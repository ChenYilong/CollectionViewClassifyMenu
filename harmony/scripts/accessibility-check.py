#!/usr/bin/env python3
"""Fails when a HarmonyOS component a screen reader meets has neither a label nor an explicit choice.

Checks the library (classifymenu) and the example (entry): every Image, TextInput, Toggle, Slider, Search, Canvas,
Checkbox and LoadingProgress has `accessibilityText`, `accessibilityLevel('no')` (decorative) or
`accessibilityGroup` in its attribute chain. Usage: harmony/scripts/accessibility-check.py
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
KINDS = ('Image(', 'TextInput(', 'Toggle(', 'Slider(', 'Search(', 'Canvas(', 'LoadingProgress(', 'Checkbox(')


def findings():
    for base in ('entry/src/main/ets', 'classifymenu/src/main/ets'):
        for path in sorted((ROOT / base).rglob('*.ets')):
            lines = path.read_text(encoding='utf-8').split('\n')
            for n, line in enumerate(lines):
                head = line.strip()
                if not head.startswith(KINDS):
                    continue
                end = n
                depth = head.count('{') - head.count('}')
                while end + 1 < len(lines) and (lines[end + 1].lstrip().startswith('.') or depth > 0):
                    end += 1
                    depth += lines[end].count('{') - lines[end].count('}')
                chain = '\n'.join(lines[n:end + 1])
                if not re.search(r'accessibilityText|accessibilityLevel|accessibilityGroup', chain):
                    yield f'{path.relative_to(ROOT).as_posix()}:{n + 1}: {head[:100]}'


def main():
    found = list(findings())
    for item in found:
        print(item)
    if found:
        print(f'{len(found)} component(s) without an accessibility label or decision')
        return 1
    print('OK: every image, input and control has an accessibility label or is marked decorative.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
