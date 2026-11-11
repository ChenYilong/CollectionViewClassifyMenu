#!/usr/bin/env python3
"""Usage: scripts/check-doc-comments.py [--fix] [header ...]

[EN] Public API documentation comments (AGENTS.md, "Code comments"; .agents/skills/cyl-comments): a comment of more
     than one line in a public Objective-C header is one /*! ... */ block, never stacked /// lines, so Xcode's Quick
     Help and the Swift interface show it. Lists stacked /// lines and /** openers in the pod's public headers (or the
     given headers) and exits 1 when there are any; --fix rewrites them as /*! ... */ blocks.
[CN] 公开 API 的文档注释：公开 Objective-C 头文件中超过一行的注释写成一个 /*! ... */ 注释块，不堆叠 /// 单行注释，
     以便 Xcode 快速帮助与 Swift 接口能显示。列出 pod 公开头文件（或指定头文件）中堆叠的 /// 与 /** 开头，存在时退出码为 1；
     --fix 将其改写为 /*! ... */ 注释块。
"""
import re
import subprocess
import sys

# [EN] The pod's public headers (CollectionViewClassifyMenu.podspec source_files). [CN] pod 的公开头文件。
PUBLIC_HEADERS = [
    'CollectionViewClassifyMenu/Class/*.h',
    'TagCollectionView/TagCollectionView/CYLTagView.h',
    'TagCollectionView/TagCollectionView/Model/*.h',
    'TagCollectionView/TagCollectionView/Views/*.h',
]
STACKED = re.compile(r'^(\s*)///(?![/<])')


def convert(lines, path, report):
    out, i, found = [], 0, 0
    while i < len(lines):
        match = STACKED.match(lines[i])
        if match:
            indent = match.group(1)
            end = i
            while end < len(lines) and re.match(r'^' + re.escape(indent) + r'///(?![/<])', lines[end]):
                end += 1
            if end - i >= 2:
                body = [re.sub(r'^\s*/// ?', '', line) for line in lines[i:end]]
                if any('*/' in line for line in body):
                    raise SystemExit(f'{path}:{i + 1}: "*/" inside the comment; fix it by hand')
                out.append(indent + '/*!')
                out += [indent + (' * ' + line if line.strip() else ' *') for line in body]
                out.append(indent + ' */')
                report(f'{path}:{i + 1}: {end - i} stacked /// lines; use one /*! ... */ block')
                found += 1
                i = end
                continue
        if re.match(r'^\s*/\*\*(\s|$)', lines[i]):
            out.append(re.sub(r'/\*\*', '/*!', lines[i], count=1))
            report(f'{path}:{i + 1}: /** opener; use /*! in Objective-C headers')
            found += 1
            i += 1
            continue
        out.append(lines[i])
        i += 1
    return out, found


def main(argv):
    fix = '--fix' in argv
    paths = [arg for arg in argv if arg != '--fix']
    if not paths:
        paths = subprocess.run(['git', 'ls-files', *PUBLIC_HEADERS], check=True,
                               capture_output=True, text=True).stdout.split()
    total = 0
    for path in paths:
        with open(path, encoding='utf-8') as handle:
            lines = handle.read().split('\n')
        out, found = convert(lines, path, print)
        total += found
        if fix and found:
            with open(path, 'w', encoding='utf-8') as handle:
                handle.write('\n'.join(out))
    if total and not fix:
        print(f'{total} public API comment(s) to fix: python3 scripts/check-doc-comments.py --fix')
        return 1
    print(f'{len(paths)} headers checked' + (f', {total} fixed' if fix else ', public API comments OK'))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
