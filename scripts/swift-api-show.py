#!/usr/bin/env python3
"""
Usage: scripts/swift-api-show.py <TypeName> [baseline.json]

Prints the Swift API of one type as the baseline records it (scripts/swift-api-baseline.json, the Objective-C core):
each member's kind, Swift name, type, and attributes (open, optional, objc names), so a Swift translation can match it.
"""
import json
import sys


def type_of(node):
    children = node.get("children") or []
    kind = node.get("declKind")
    if kind == "Var" and children:
        return children[0].get("printedName", "")
    if kind in ("Func", "Constructor") and children:
        ret = children[0].get("printedName", "")
        args = ", ".join(c.get("printedName", "") for c in children[1:])
        return "(%s) -> %s" % (args, ret)
    return ""


def show(node, depth=0):
    attrs = node.get("declAttributes") or []
    flags = [a for a in attrs if a in ("ObjC", "Optional", "Dynamic", "Final", "Override", "IBAction", "IBOutlet",
                                       "Required", "Convenience", "Available", "DiscardableResult")]
    extra = []
    if node.get("isOpen"):
        extra.append("open")
    if node.get("objc_name"):
        extra.append("objc=" + node["objc_name"])
    if node.get("superclassNames"):
        extra.append("super=" + node["superclassNames"][0])
    if node.get("conformances"):
        extra.append("conforms=" + ",".join(c["name"] for c in node["conformances"] if c.get("name")))
    print("  " * depth + "%s %s %s %s %s" % (node.get("declKind"), node.get("printedName"), type_of(node),
                                             " ".join(flags), " ".join(extra)))
    if node.get("declKind") in ("Class", "Protocol", "Enum", "Struct", "Extension"):
        for child in node.get("children") or []:
            if child.get("kind") not in ("TypeNominal", "TypeNameAlias", "TypeFunc"):
                show(child, depth + 1)


def main():
    name = sys.argv[1]
    path = sys.argv[2] if len(sys.argv) > 2 else "scripts/swift-api-baseline.json"
    root = json.load(open(path))["ABIRoot"]
    for node in root["children"]:
        if node.get("name") == name or node.get("printedName") == name:
            show(node)


if __name__ == "__main__":
    main()
