#!/usr/bin/env python3
"""Fails when a screenshot added or changed in docs/assets/ or assets/ is not stitched and labeled by the rules.

AGENTS.md "CI/CD and Example screenshots": every screenshot shown in docs/ or README.md has a header (Purpose,
Platform, Host, IDE), a caption above every panel and a footer (Result, Versions, Taken). Images are made with
scripts/stitch-screenshots.py (any host) or scripts/stitch-screenshots.swift (macOS); both write the header and footer
into the PNG's "Description" text chunk, starting with "cyl-stitch-screenshots". This check reads it back.

    python3 scripts/check-screenshots.py                # the staged files (before a commit)
    python3 scripts/check-screenshots.py --range A..B   # the files a range changes (CI: base..head)
    python3 scripts/check-screenshots.py FILE ...       # these files

Exit 0: every image passes (or none changed); 1: at least one does not, with the reason and the fix.
Images that are not screenshots (a diagram, an icon) or that a script regenerates are listed, with the reason, in
scripts/screenshot-check-exempt.txt (one glob per line).
"""
import fnmatch
import os
import subprocess
import sys

from PIL import Image

MARKER = 'cyl-stitch-screenshots'
HEADER_FIELDS = ('Purpose:', 'Platform:', 'Host:', 'IDE:')
FOOTER_FIELDS = ('Result:', 'Versions:', 'Taken:')
IMAGE_EXTENSIONS = ('.png', '.jpg', '.jpeg', '.gif', '.webp')
ROOT = subprocess.run(['git', 'rev-parse', '--show-toplevel'], capture_output=True, text=True).stdout.strip() or '.'
EXEMPT_FILE = os.path.join(ROOT, 'scripts', 'screenshot-check-exempt.txt')


def changed_files(argv):
    if argv[:1] == ['--range']:
        diff = ['git', 'diff', '--name-only', '--diff-filter=AM', argv[1]]
    elif argv:
        return argv
    else:
        diff = ['git', 'diff', '--cached', '--name-only', '--diff-filter=AM']
    return subprocess.run(diff, capture_output=True, text=True, cwd=ROOT, check=True).stdout.split()


def exempt_patterns():
    if not os.path.exists(EXEMPT_FILE):
        return []
    with open(EXEMPT_FILE, encoding='utf-8') as handle:
        return [line.split('#', 1)[0].strip() for line in handle if line.split('#', 1)[0].strip()]


def problems(path):
    if not path.lower().endswith('.png'):
        return ['not a PNG: stitch it with scripts/stitch-screenshots.py (it writes PNG)']
    with Image.open(os.path.join(ROOT, path)) as image:
        description = image.info.get('Description', '')
    if not description.startswith(MARKER):
        return ['no label: not made by scripts/stitch-screenshots.py / .swift (no "cyl-stitch-screenshots" description)']
    missing = [field for field in HEADER_FIELDS + FOOTER_FIELDS if field not in description]
    return [f'the label lacks {", ".join(missing)}'] if missing else []


def main():
    files = [f.replace('\\', '/') for f in changed_files(sys.argv[1:])]
    images = [f for f in files if f.lower().endswith(IMAGE_EXTENSIONS)
              and (f.startswith('docs/assets/') or f.startswith('assets/'))]
    patterns = exempt_patterns()
    failed = 0
    for path in images:
        if any(fnmatch.fnmatch(path, pattern) for pattern in patterns):
            continue
        found = problems(path)
        if found:
            failed += 1
            print(f'{path}: ' + '; '.join(found))
    if failed:
        print(f'\n{failed} screenshot(s) do not follow AGENTS.md "CI/CD and Example screenshots". Re-read the rules '
              '(git pull; .agents/skills/cyl-screenshots/SKILL.md), then stitch with:\n'
              '  python3 scripts/stitch-screenshots.py --out <file.png> --header "Purpose: ..." '
              '--header "Platform: ... | Host: ... | IDE: ..." --footer "Result: ..." --footer "Versions: ..." '
              '--footer "Taken: ..." "1. <caption>::<image>" ...')
        return 1
    print(f'Screenshots OK ({len(images)} checked).')
    return 0


if __name__ == '__main__':
    sys.exit(main())
