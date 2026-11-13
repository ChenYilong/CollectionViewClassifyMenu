#!/usr/bin/env python3
"""
Usage: scripts/swift-migrate-pbxproj.py [--project <path/project.pbxproj>] <Name> [<Name> ...]

The root CollectionViewClassifyMenu.xcodeproj lists the core's files in its groups (the pod compiles them). After
<Name>.h / <Name>.m are replaced by <Name>.swift (docs/Swift-Migration.md), this rewrites the project: the .m file
reference becomes <Name>.swift (same ID, type sourcecode.swift) and the .h reference is removed from the file
references and from its group. objectVersion and everything else stay unchanged. --project picks another project
that lists core files (TagCollectionView/TagCollectionView.xcodeproj/project.pbxproj); default: the root project.
"""
import re
import sys

PROJECT = "CollectionViewClassifyMenu.xcodeproj/project.pbxproj"


def main(args):
    project = PROJECT
    if args[:1] == ["--project"]:
        project, args = args[1], args[2:]
    names = args
    text = open(project, encoding="utf-8").read()
    for name in names:
        header = re.search(r'^\t\t(\w+) /\* %s\.h \*/ = \{isa = PBXFileReference;[^\n]*\n' % re.escape(name), text, re.M)
        if header:
            ref = header.group(1)
            text = text.replace(header.group(0), "")
            text = re.sub(r'^\t+%s /\* %s\.h \*/,\n' % (ref, re.escape(name)), "", text, flags=re.M)
        source = re.search(r'^\t\t(\w+) /\* %s\.m \*/ = \{isa = PBXFileReference;[^\n]*\n' % re.escape(name), text, re.M)
        if source:
            ref = source.group(1)
            line = ('\t\t%s /* %s.swift */ = {isa = PBXFileReference; fileEncoding = 4; '
                    'lastKnownFileType = sourcecode.swift; path = "%s.swift"; sourceTree = "<group>"; };\n'
                    % (ref, name, name))
            text = text.replace(source.group(0), line)
            text = re.sub(r'(\b%s) /\* %s\.m \*/' % (ref, re.escape(name)), r'\1 /* %s.swift */' % name, text)
        if not header and not source:
            print("warning: %s not found in %s" % (name, project), file=sys.stderr)
    open(project, "w", encoding="utf-8").write(text)


if __name__ == "__main__":
    main(sys.argv[1:])
