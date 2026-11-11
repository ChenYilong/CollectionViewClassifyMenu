#!/usr/bin/env python3
"""Usage: scripts/check-doc-comments.py [--fix] [header ...]

[EN] Public API documentation comments (AGENTS.md, "Code comments"; .agents/skills/cyl-comments): every comment that
     documents a declaration in a public Objective-C header, one line or several, is one /*! ... */ block, so the file
     has one comment format and Xcode's Quick Help and the Swift interface show it. Lists /// lines (single or
     stacked), /** openers and plain // comments placed on a declaration in the pod's public headers (or the given
     headers) and exits 1 when there are any; --fix rewrites them as /*! ... */ blocks.
[CN] 公开 API 的文档注释：公开 Objective-C 头文件中说明声明的注释，无论单行还是多行，都写成一个 /*! ... */ 注释块，
     使文件内注释格式统一，Xcode 快速帮助与 Swift 接口都能显示。列出 pod 公开头文件（或指定头文件）中的 /// 注释（单行或堆叠）、
     /** 开头以及写在声明上的普通 // 注释，存在时退出码为 1；--fix 将其改写为 /*! ... */ 注释块。
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
DOC_LINE = re.compile(r'^(\s*)///(?![/<])')
PLAIN_LINE = re.compile(r'^(\s*)//(?!/)')


def block(indent, body, path, line_number):
    if any('*/' in line for line in body):
        raise SystemExit(f'{path}:{line_number}: "*/" inside the comment; fix it by hand')
    return [indent + '/*!'] + [indent + (' * ' + line if line.strip() else ' *') for line in body] + [indent + ' */']


def documents_declaration(lines, end):
    """The comment ends right above a declaration (not a blank line, a directive or another comment)."""
    if end >= len(lines):
        return False
    following = lines[end].strip()
    return bool(following) and not following.startswith(('#', '//', '/*', '@end'))


def convert(lines, path, report):
    out, i, found = [], 0, 0
    # [EN] The file header (// File.h, licenses) before the first #import/#include is left alone.
    # [CN] 第一个 #import/#include 之前的文件头注释（文件名、许可证）保持不变。
    body_start = next((n for n, line in enumerate(lines) if re.match(r'\s*#\s*(import|include)', line)), len(lines))
    while i < len(lines):
        match = DOC_LINE.match(lines[i])
        if match:
            indent = match.group(1)
            end = i
            while end < len(lines) and re.match(r'^' + re.escape(indent) + r'///(?![/<])', lines[end]):
                end += 1
            body = [re.sub(r'^\s*/// ?', '', line) for line in lines[i:end]]
            out += block(indent, body, path, i + 1)
            report(f'{path}:{i + 1}: /// comment ({end - i} line(s)); use one /*! ... */ block')
            found += 1
            i = end
            continue
        match = PLAIN_LINE.match(lines[i])
        if match and i >= body_start:
            indent = match.group(1)
            end = i
            while end < len(lines) and re.match(r'^' + re.escape(indent) + r'//(?!/)', lines[end]):
                end += 1
            if documents_declaration(lines, end):
                body = [re.sub(r'^\s*// ?', '', line) for line in lines[i:end]]
                out += block(indent, body, path, i + 1)
                report(f'{path}:{i + 1}: plain // comment on a declaration; use one /*! ... */ block')
                found += 1
                i = end
                continue
            out += lines[i:end]
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
