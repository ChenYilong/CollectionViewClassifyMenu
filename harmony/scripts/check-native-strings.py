#!/usr/bin/env python3
"""Checks the native HarmonyOS string resources (resources/<language>/element/string.json).

- Every language folder of a module has the same names as its `base` folder.
- The tab titles copied from CYLTabBarController's HarmonyOS example (`tab_home`, `tab_nearby`, `tab_messages`,
  `tab_me`) match the iOS example strings: `en_US` the English, `zh_CN` the key, `zh_TW` the Traditional Chinese.
Usage: harmony/scripts/check-native-strings.py
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
IOS = ROOT.parent / 'Example/CYLMenuExample/CYLMenuExample.bundle'
TABS = {'tab_home': '首页', 'tab_nearby': '同城', 'tab_messages': '消息', 'tab_me': '我的'}


def strings(path):
    return {item['name']: item['value'] for item in json.loads(path.read_text(encoding='utf-8'))['string']}


def ios(language):
    text = (IOS / f'{language}.lproj/Localizable.strings').read_text(encoding='utf-8')
    return dict(re.findall(r'^"((?:[^"\\]|\\.)*)"\s*=\s*"((?:[^"\\]|\\.)*)"\s*;', text, re.M))


def main():
    errors = []
    for resources in (ROOT / 'entry/src/main/resources', ROOT / 'AppScope/resources'):
        base = strings(resources / 'base/element/string.json')
        for folder in sorted(resources.iterdir()):
            path = folder / 'element/string.json'
            if folder.name == 'base' or not path.exists():
                continue
            names = set(strings(path))
            if names != set(base):
                errors.append(f'{path.relative_to(ROOT)}: names differ from base: {sorted(names ^ set(base))}')
    entry = ROOT / 'entry/src/main/resources'
    expected = {'en_US': ios('en'), 'zh_TW': ios('zh-Hant')}
    for language, table in (('en_US', expected['en_US']), ('zh_TW', expected['zh_TW']), ('zh_CN', None)):
        values = strings(entry / f'{language}/element/string.json')
        for name, key in TABS.items():
            want = key if table is None else table.get(key, key)
            if values.get(name) != want:
                errors.append(f'{language}/{name}: "{values.get(name)}", expected "{want}" (iOS "{key}")')
    for error in errors:
        print(error)
    if errors:
        return 1
    print('OK: native string resources are complete and match the iOS strings.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
