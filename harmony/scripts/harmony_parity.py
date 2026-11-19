#!/usr/bin/env python3
"""Write docs/harmony.md: the iOS public API and the iOS example's demos, each with its HarmonyOS counterpart.

  harmony_parity.py            write docs/harmony.md from the Swift core and harmony/parity-map.json
  harmony_parity.py --check    exit 1 when docs/harmony.md is out of date
  harmony_parity.py --list     print every public iOS symbol, one per line
  harmony_parity.py --todo     print the TODO rows (API first, then demos)

The API is every `public` / `open` declaration of the pod's Swift sources (CollectionViewClassifyMenu.podspec:
source_files minus exclude_files), overrides of UIKit members left out: types, properties, methods (with their
argument labels), initializers, enum cases, static members. The demos are the screens of the iOS example
(Example/CYLMenuExample), listed in parity-map.json "demos" in the order of the example.

parity-map.json: {"api": {"<symbol>": "<ArkTS counterpart>"}, "demos": [{"ios": ..., "shows": ..., "harmony": ...}]}.
A row without a counterpart is TODO. The score is aligned rows / all rows of both tables, out of 100.
"""
import fnmatch
import glob
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
PODSPEC = ROOT / "CollectionViewClassifyMenu.podspec"
MAP = ROOT / "harmony/parity-map.json"
DOC = ROOT / "docs/harmony.md"

DECL = re.compile(
    r"^(?:@[A-Za-z]+(?:\([^)]*\))?\s+)*"
    r"(?P<access>public|open)\s+"
    r"(?P<mods>(?:(?:final|static|class|override|required|convenience|dynamic|lazy|weak|mutating|nonmutating|"
    r"private\(set\)|fileprivate\(set\)|internal\(set\))\s+)*)"
    r"(?P<kind>class|struct|enum|protocol|extension|func|var|let|init|subscript|typealias|case)\b\s*(?P<rest>.*)$")
EXTENSION = re.compile(r"^(?:public\s+)?extension\s+(?P<name>[A-Za-z_][\w.]*)")
PROTOCOL_MEMBER = re.compile(r"^(?:@[A-Za-z]+(?:\([^)]*\))?\s+)*(?:optional\s+)?(?P<static>static\s+)?(?P<kind>func|var|init)\b\s*(?P<rest>.*)$")
CASE = re.compile(r"^case\s+(?P<rest>.*)$")


def podspec_patterns(key):
    text = PODSPEC.read_text(encoding="utf-8")
    block = re.search(r"s\.%s\s*=\s*\[(.*?)\]" % key, text, re.S)
    return re.findall(r"'([^']+)'", block.group(1)) if block else []


def expand(pattern):
    """A podspec glob ({a,b} alternatives, **) as files."""
    match = re.search(r"\{([^}]*)\}", pattern)
    if match:
        return [f for alt in match.group(1).split(",") for f in expand(pattern[:match.start()] + alt + pattern[match.end():])]
    return glob.glob(str(ROOT / pattern), recursive=True)


def sources():
    excluded = podspec_patterns("exclude_files")
    files = set()
    for pattern in podspec_patterns("source_files"):
        files.update(pathlib.Path(f) for f in expand(pattern))
    keep = []
    for f in sorted(files):
        rel = f.relative_to(ROOT).as_posix()
        if any(fnmatch.fnmatch(rel, e) or fnmatch.fnmatch(f.name, e.replace("**/", "")) or rel in
               {pathlib.Path(x).relative_to(ROOT).as_posix() for x in expand(e)} for e in excluded):
            continue
        keep.append(f)
    return keep


def strip(text):
    text = re.sub(r"/\*.*?\*/", lambda m: "\n" * m.group(0).count("\n"), text, flags=re.S)
    text = re.sub(r'"(?:\\.|[^"\\])*"', '""', text)
    text = re.sub(r"//[^\n]*", "", text)
    # A declaration whose parameters span lines becomes one line.
    lines, buffer, balance = [], "", 0
    for line in text.split("\n"):
        buffer = (buffer + " " + line.strip()) if buffer else line
        balance += line.count("(") - line.count(")")
        if balance <= 0:
            lines.append(buffer)
            buffer, balance = "", 0
    if buffer:
        lines.append(buffer)
    return "\n".join(lines)


def func_name(rest):
    name = re.match(r"([^\s(<]+)", rest).group(1)
    params = rest[rest.index("("):] if "(" in rest else "()"
    depth, inner = 0, ""
    for ch in params:
        if ch == "(":
            depth += 1
            if depth == 1:
                continue
        elif ch == ")":
            depth -= 1
            if depth == 0:
                break
        inner += ch if depth >= 1 else ""
    labels, depth, part = [], 0, ""
    for ch in inner + ",":
        if ch in "(<[":
            depth += 1
        elif ch in ")>]":
            depth -= 1
        if ch == "," and depth == 0:
            if ":" in part:
                labels.append(part.split(":")[0].split()[0] + ":")
            part = ""
        else:
            part += ch
    return "%s(%s)" % (name, "".join(labels))


def symbols():
    rows, seen = [], set()
    for path in sources():
        stack = []  # (name, depth at which its body opened, public)
        depth = 0
        pending = None
        for line in strip(path.read_text(encoding="utf-8")).split("\n"):
            s = line.strip()
            owner = stack[-1] if stack else None
            m = DECL.match(s)
            ext = EXTENSION.match(s)
            case = CASE.match(s)
            symbol, opens = None, None
            if m and "override" not in m.group("mods"):
                kind, rest = m.group("kind"), m.group("rest")
                static = "static " if re.search(r"\b(static|class)\b", m.group("mods")) else ""
                prefix = owner[0] + "." if owner else ""
                if kind in ("class", "struct", "enum", "protocol"):
                    name = re.match(r"[A-Za-z_]\w*", rest).group(0)
                    symbol, opens = (prefix + name, kind), (prefix + name, True)
                elif kind == "extension":
                    name = re.match(r"[A-Za-z_][\w.]*", rest).group(0)
                    opens = (name, True)
                elif kind in ("func", "init", "subscript"):
                    sig = func_name(("init" + rest) if kind == "init" else ("subscript" + rest) if kind == "subscript" else rest)
                    symbol = (prefix + static + sig if not static else "%s%s%s" % (prefix, "static ", sig), kind if kind != "func" else "method")
                    opens = ("", False) if "{" in s else None
                elif kind in ("var", "let"):
                    name = re.match(r"[A-Za-z_]\w*", rest).group(0)
                    symbol = (prefix + ("static " if static else "") + name, "property")
                elif kind == "typealias":
                    symbol = (prefix + re.match(r"[A-Za-z_]\w*", rest).group(0), "typealias")
                elif kind == "case":
                    for name in re.findall(r"(?:^|,)\s*([A-Za-z_]\w*)", rest):
                        sym = (prefix + name, "case")
                        if sym[0] not in seen:
                            seen.add(sym[0]); rows.append(sym + (path.name,))
            elif ext and not m:
                opens = (ext.group("name"), False)
            elif owner and owner[2] and owner[3] == "protocol" and PROTOCOL_MEMBER.match(s):
                pm = PROTOCOL_MEMBER.match(s)
                kind, rest = pm.group("kind"), pm.group("rest")
                static = "static " if pm.group("static") else ""
                if kind in ("func", "init"):
                    sym = (owner[0] + "." + static + func_name(("init" + rest) if kind == "init" else rest), "method" if kind == "func" else "init")
                else:
                    sym = (owner[0] + "." + static + re.match(r"[A-Za-z_]\w*", rest).group(0), "property")
                if sym[0] not in seen:
                    seen.add(sym[0]); rows.append(sym + (path.name,))
            elif case and owner and owner[2] and owner[3] == "enum":
                for name in re.findall(r"(?:^|,)\s*([A-Za-z_]\w*)", case.group("rest")):
                    sym = owner[0] + "." + name
                    if sym not in seen:
                        seen.add(sym); rows.append((sym, "case", path.name))
            elif re.match(r"^(?:@[A-Za-z]+\s+)*(?:final\s+)?(?:class|struct|enum|protocol)\s", s):
                name = re.search(r"(?:class|struct|enum|protocol)\s+([A-Za-z_]\w*)", s).group(1)
                opens = ((owner[0] + "." if owner else "") + name, False)
            if symbol and symbol[0] not in seen:
                seen.add(symbol[0]); rows.append(symbol + (path.name,))
            if opens is not None:
                kind = m.group("kind") if m else ""
                pending = (opens[0], opens[1], kind)
            for ch in s:
                if ch == "{":
                    depth += 1
                    if pending is not None:
                        name, public, kind = pending
                        stack.append((name if name else (owner[0] if owner else ""), depth, public and bool(name), kind, bool(name)))
                        pending = None
                elif ch == "}":
                    if stack and stack[-1][1] == depth:
                        stack.pop()
                    depth -= 1
            if pending is not None and not s.endswith(("{", ",", "(", "->")) and "{" not in s and m and m.group("kind") in ("func", "init", "var", "let", "case", "typealias", "subscript"):
                pending = None
            stack = [e for e in stack if e[4] or True]
    return rows


def load_map():
    return json.loads(MAP.read_text(encoding="utf-8"))


def cell(text):
    return text.replace("|", "\\|")


def render(rows, mapping):
    api = mapping.get("api", {})
    demos = mapping.get("demos", [])
    api_done = sum(1 for s, _, _ in rows if api.get(s))
    demo_done = sum(1 for d in demos if d.get("harmony"))
    total = len(rows) + len(demos)
    done = api_done + demo_done
    score = 100.0 * done / total if total else 100.0
    meta = mapping.get("meta", {})
    out = [
        "---", "title: HarmonyOS port", "date: 2026-11-16", "tags: [harmonyos, arkts, api-parity, cross-platform]", "---", "",
        "# HarmonyOS 移植 / HarmonyOS port",
        "",
        "| 中文 | English |",
        "|:---|:---|",
        "| CollectionViewClassifyMenu 的 HarmonyOS（ArkTS / ArkUI）移植：核心库在 `harmony/classifymenu`（HAR 模块），示例应用在 `harmony/entry`。由 `harmony/scripts/harmony_parity.py` 根据 Swift 核心和 `harmony/parity-map.json` 生成，不要手动修改表格。没有 HarmonyOS 对应项的行为 `TODO`。 | The HarmonyOS (ArkTS / ArkUI) port of CollectionViewClassifyMenu: the core library in `harmony/classifymenu` (a HAR module) and the example app in `harmony/entry`. Generated by `harmony/scripts/harmony_parity.py` from the Swift core and `harmony/parity-map.json`; do not edit the tables by hand. A row without a HarmonyOS counterpart is `TODO`. |",
        "",
        "## HarmonyOS 版本 / HarmonyOS version",
        "",
        "<!-- bilingual:keep -->",
    ]
    for key, value in meta.get("versions", []):
        out.append("- **%s:** %s" % (key, value))
    out += [
        "",
        "## 评分 / Score",
        "",
        "<!-- bilingual:keep -->",
        "**Score: %d / %d = %.1f / 100** (API %d / %d, demos %d / %d). 评分：%d / %d = %.1f / 100（API %d / %d，示例 %d / %d）。"
        % (done, total, score, api_done, len(rows), demo_done, len(demos), done, total, score, api_done, len(rows), demo_done, len(demos)),
        "",
        "| 中文 | English |",
        "|:---|:---|",
        "| 两张表一起评分：每去掉一个 TODO，就离满分近一步；没有 TODO 时，移植完成，即 100 / 100。历史见下文。标为 `N/A` 的行天然没有 HarmonyOS 对应项（只存在于 UIKit 的 API，例如 Interface Builder 解码），视为已对齐并说明原因。 | Both tables are scored together: every TODO removed is one row closer to full marks, and the port is done at 100 / 100, when no TODO is left. The history is below. A row marked `N/A` has no HarmonyOS counterpart by nature (UIKit-only API, such as Interface Builder decoding); it counts as aligned and states its reason. |",
        "",
        "## 表 1：iOS 公开 API / Table 1: iOS public API",
        "",
        "| 中文 | English |",
        "|:---|:---|",
        "| 列出 pod 的 Swift 源码（`CollectionViewClassifyMenu.podspec`）中每个 `public` / `open` 声明，不含 UIKit 重写。 | Every `public` / `open` declaration of the pod's Swift sources (`CollectionViewClassifyMenu.podspec`), UIKit overrides left out. |",
        "",
        "<!-- bilingual:keep -->",
        "| iOS (Swift, file) | HarmonyOS (ArkTS, `harmony/classifymenu`) | 类型 / Kind |",
        "| --- | --- | --- |",
    ]
    for symbol, kind, file in rows:
        out.append("| `%s` (%s) | %s | %s |" % (cell(symbol), file, cell(api.get(symbol) or "TODO"), kind))
    out += [
        "",
        "## 表 2：iOS 示例的演示 / Table 2: iOS example demos",
        "",
        "| 中文 | English |",
        "|:---|:---|",
        "| 列出 iOS 示例（`Example/CYLMenuExample`）的每个界面，顺序与示例一致。 | Every screen of the iOS example (`Example/CYLMenuExample`), in the order of the example. |",
        "",
        "<!-- bilingual:keep -->",
        "| iOS demo | HarmonyOS (`harmony/entry`) | 展示内容 / What it shows |",
        "| --- | --- | --- |",
    ]
    for d in demos:
        out.append("| `%s` | %s | %s |" % (cell(d["ios"]), cell(d.get("harmony") or "TODO"), cell(d["shows"])))
    out += ["", "## 评分历史 / Score history", "", "<!-- bilingual:keep -->"]
    for entry in mapping.get("history", []):
        out.append("- " + entry)
    return "\n".join(out) + "\n"


def main():
    args = sys.argv[1:]
    rows = symbols()
    if "--list" in args:
        for s, k, f in rows:
            print(s, k, f, sep="\t")
        return 0
    mapping = load_map()
    if "--todo" in args:
        for s, k, f in rows:
            if not mapping["api"].get(s):
                print("api", s, k, f, sep="\t")
        for d in mapping["demos"]:
            if not d.get("harmony"):
                print("demo", d["ios"], sep="\t")
        return 0
    unknown = sorted(set(mapping.get("api", {})) - {s for s, _, _ in rows})
    if unknown:
        print("parity-map.json maps symbols the Swift core no longer has:", ", ".join(unknown))
        return 1
    text = render(rows, mapping)
    if "--check" in args:
        if not DOC.exists() or DOC.read_text(encoding="utf-8").replace("\r\n", "\n") != text:
            print("docs/harmony.md is out of date (run harmony/scripts/harmony_parity.py)")
            return 1
        print("OK: docs/harmony.md matches the Swift core and harmony/parity-map.json.")
        return 0
    DOC.write_text(text, encoding="utf-8", newline="\n")
    print(next(line for line in text.split("\n") if line.startswith("**Score")).split(". Both")[0])
    return 0


if __name__ == "__main__":
    sys.exit(main())
