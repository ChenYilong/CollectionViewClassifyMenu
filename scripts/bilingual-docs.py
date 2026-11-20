#!/usr/bin/env python3
"""Bilingual Chinese-English Markdown (docs/Bilingual-Documentation.md): extract, assemble and check.

  extract FILE [-o UNITS.json]            split FILE into the passages that need a translation
  assemble FILE UNITS.json TRANSLATIONS.json [-o OUT]
                                          build the bilingual layout; code, images, links and table structure are kept
  check FILE... [--against GIT_REF]       check the layout; with --against also that code blocks, inline code, links
                                          and images equal those of the same file at GIT_REF (nothing but text changed)

A table, list or paragraph right after `<!-- bilingual:keep -->` is generated data (code names, a score history) and stays as is.

Layout (CYLTabBarController's bilingual standard): a heading is one line "Chinese / English"; prose (a paragraph or a
list item) is one row of a two-column table, Chinese left and English right; a table with more columns is given twice,
a Chinese table and then its English twin; code blocks, HTML, comments and images are shared.

TRANSLATIONS.json maps a unit id to {"zh": ..., "en": ...}: only the language the unit lacks is needed (the other is the
source text itself); a unit that mixes both languages needs both. Python 3 standard library only.
"""
import argparse
import json
import pathlib
import re
import subprocess
import sys

HAN = re.compile(r"[㐀-鿿]")
FENCE = re.compile(r"^(\s*)(`{3,}|~{3,})")
HEADING = re.compile(r"^(#{1,6})\s+(.*?)\s*#*\s*$")
HRULE = re.compile(r"^\s*([-*_])(\s*\1){2,}\s*$")
LIST_ITEM = re.compile(r"^(\s*)([-*+]|\d+[.)])\s+(.*)$")
TABLE_SEPARATOR = re.compile(r"^\s*\|?\s*:?-{2,}:?\s*(\|\s*:?-{2,}:?\s*)*\|?\s*$")
IMAGE_ONLY = re.compile(r"^\s*!\[[^\]]*\]\([^)]*\)\s*$")
CODE_SPAN = re.compile(r"(`+)(.+?)\1")
LINK_TARGET = re.compile(r"\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
IMAGE_REF = re.compile(r"!\[[^\]]*\]\(([^)\s]+)")
URL = re.compile(r"https?://[^\s)>\]|]+")
HTML_TAG = re.compile(r"</?[A-Za-z][^>]*>")
HEADER_ROW = "| 中文 | English |"
DISPLAY_HEADER = ["| 中文 | English |", "|:---|:---|"]


def strip_untranslatable(text):
    """The text without code spans, link targets, URLs and HTML tags."""
    text = CODE_SPAN.sub(" ", text)
    text = LINK_TARGET.sub("] ", text)
    text = URL.sub(" ", text)
    return HTML_TAG.sub(" ", text)


def has_latin_words(text):
    return re.search(r"[A-Za-z]{3,}", strip_untranslatable(text)) is not None


def translatable(text):
    stripped = strip_untranslatable(text)
    return HAN.search(stripped) is not None or re.search(r"[A-Za-z]{3,}", stripped) is not None


def same_both_ways(zh, en):
    """A short proper noun or token (at most two words) may be the same in both languages."""
    return zh == en and len(zh.split()) <= 2


def need_of(text):
    """Which translation a unit needs: "zh" (English source), "en" (Chinese source) or "both" (mixed)."""
    stripped = strip_untranslatable(text)
    han = HAN.search(stripped) is not None
    latin = re.search(r"[A-Za-z]{3,}", stripped) is not None
    if han and latin:
        return "both"
    return "en" if han else "zh"


def slug(heading, seen):
    """GitHub's heading anchor: lower case, punctuation dropped, spaces to hyphens, repeats numbered."""
    text = re.sub(r"[`*_~]", "", re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", heading)).strip().lower()
    text = re.sub(r"[^\w\- ]", "", text)
    base = text.replace(" ", "-")
    count = seen.get(base, 0)
    seen[base] = count + 1
    return base if count == 0 else f"{base}-{count}"


def split_cells(line):
    """The cells of a table row: split on pipes that are not escaped."""
    row = line.strip()
    if row.startswith("|"):
        row = row[1:]
    if row.endswith("|") and not row.endswith("\\|"):
        row = row[:-1]
    return [cell.strip() for cell in re.split(r"(?<!\\)\|", row)]


def starts_block(line):
    stripped = line.strip()
    return (not stripped or FENCE.match(line) or HEADING.match(line) or LIST_ITEM.match(line) or HRULE.match(line)
            or stripped.startswith(("|", ">", "<")))


def parse(text):
    """Blocks: raw (kept as is), heading, prose (a paragraph, list item or quote) and table."""
    lines = text.split("\n")
    blocks = []
    i = 0
    stack = []
    if lines and lines[0].strip() == "---":
        end = next((k for k in range(1, len(lines)) if lines[k].strip() == "---"), None)
        if end is not None:
            blocks.append({"t": "raw", "lines": lines[:end + 1]})
            i = end + 1
    while i < len(lines):
        line = lines[i]
        fence = FENCE.match(line)
        if fence:
            marker = fence.group(2)
            j = i + 1
            while j < len(lines) and not (lines[j].strip().startswith(marker[0] * len(marker))
                                          and set(lines[j].strip()) == {marker[0]}):
                j += 1
            blocks.append({"t": "raw", "lines": lines[i:j + 1]})
            i = j + 1
            stack = []
            continue
        stripped = line.strip()
        if not stripped:
            blocks.append({"t": "raw", "lines": [line]})
            i += 1
            continue
        if stripped.startswith("<!--"):
            j = i
            while j < len(lines) and "-->" not in lines[j]:
                j += 1
            blocks.append({"t": "raw", "lines": lines[i:j + 1]})
            i = j + 1
            continue
        heading = HEADING.match(line)
        if heading:
            blocks.append({"t": "heading", "level": len(heading.group(1)), "text": heading.group(2)})
            i += 1
            stack = []
            continue
        if HRULE.match(line) or IMAGE_ONLY.match(line):
            blocks.append({"t": "raw", "lines": [line]})
            i += 1
            continue
        if stripped.startswith("|") and i + 1 < len(lines) and TABLE_SEPARATOR.match(lines[i + 1]):
            j = i
            while j < len(lines) and lines[j].strip().startswith("|"):
                j += 1
            rows = [split_cells(r) for r in lines[i:j]]
            blocks.append({"t": "table", "header": rows[0], "align": lines[i + 1], "rows": rows[2:], "lines": lines[i:j]})
            i = j
            stack = []
            continue
        if stripped.startswith("<"):
            j = i
            while j < len(lines) and lines[j].strip():
                j += 1
            blocks.append({"t": "raw", "lines": lines[i:j]})
            i = j
            continue
        if stripped.startswith(">"):
            j = i
            while j < len(lines) and lines[j].strip().startswith(">"):
                j += 1
            quote = " ".join(re.sub(r"^\s*>\s?", "", l) for l in lines[i:j]).strip()
            if HAN.search(quote) or not translatable(quote):
                blocks.append({"t": "raw", "lines": lines[i:j]})
            else:
                blocks.append({"t": "prose", "kind": "q", "depth": 0, "marker": "", "text": quote})
            i = j
            stack = []
            continue
        item = LIST_ITEM.match(line)
        if item:
            indent = len(item.group(1).expandtabs(4))
            while stack and indent < stack[-1]:
                stack.pop()
            if not stack or indent > stack[-1]:
                stack.append(indent)
            parts = [item.group(3).strip()]
            j = i + 1
            while j < len(lines) and lines[j].strip() and not starts_block(lines[j]):
                parts.append(lines[j].strip())
                j += 1
            marker = item.group(2) if item.group(2)[0].isdigit() else ""
            blocks.append({"t": "prose", "kind": "li", "depth": len(stack) - 1, "marker": marker,
                           "text": " ".join(parts), "raw": lines[i:j]})
            i = j
            continue
        j = i
        parts = []
        while j < len(lines) and lines[j].strip() and (j == i or not starts_block(lines[j])):
            parts.append(lines[j].strip())
            j += 1
        blocks.append({"t": "prose", "kind": "p", "depth": 0, "marker": "", "text": " ".join(parts), "raw": lines[i:j]})
        i = j
        stack = []
    return mark_keep(blocks)


def mark_keep(blocks):
    """A table, a run of list items or a paragraph right after `<!-- bilingual:keep -->` is generated data (code names, history):
    kept as it is, never extracted, assembled or checked."""
    state = None
    for block in blocks:
        if block["t"] == "raw":
            if any("bilingual:keep" in l for l in block["lines"]):
                state = "next"
            elif state == "next" and any(l.strip() for l in block["lines"]):
                state = None
            continue
        if state == "next":
            if block["t"] == "table":
                block["keep"], state = True, None
            elif block["t"] == "prose" and block["kind"] == "li":
                block["keep"], state = True, "list"
            elif block["t"] == "prose":
                block["keep"], state = True, None
            else:
                state = None
        elif state == "list":
            if block["t"] == "prose" and block["kind"] == "li":
                block["keep"] = True
            else:
                state = None
    return blocks


def is_bilingual_table(block):
    return block["t"] == "table" and [c.strip() for c in block["header"]] == ["中文", "English"]


def units_of(blocks):
    """The unique passages to translate, in order: {"id", "kind", "text", "need"} (cells carry their header as context)."""
    units, by_text = [], {}

    def add(kind, text, context=""):
        if not translatable(text):
            return
        key = (text,)
        if key not in by_text:
            by_text[key] = f"u{len(units) + 1:04d}"
            unit = {"id": by_text[key], "kind": kind, "text": text, "need": need_of(text)}
            if context:
                unit["context"] = context
            units.append(unit)

    for block in blocks:
        if block.get("keep"):
            continue
        if block["t"] == "heading":
            add("heading", block["text"])
        elif block["t"] == "prose":
            add(block["kind"], block["text"])
        elif block["t"] == "table" and not is_bilingual_table(block):
            context = " | ".join(block["header"])[:120]
            for cell in block["header"]:
                add("cell", cell, "table header")
            for row in block["rows"]:
                for cell in row:
                    add("cell", cell, context)
    return units, by_text


def unit_id(by_text, text):
    return by_text.get((text,))


def spans(text):
    """Inline code, link targets and image paths of a text (a multiset as a sorted list); anchors are skipped."""
    found = [m.group(2) for m in CODE_SPAN.finditer(text)]
    found += [t for t in LINK_TARGET.findall(text) if not t.startswith("#")]
    found += IMAGE_REF.findall(text)
    return sorted(item.replace("\\|", "|") for item in found)


def escape_cell(text):
    return re.sub(r"(?<!\\)\|", r"\\|", text.replace("\n", " "))


def row(zh, en, prefix=""):
    return f"| {prefix}{escape_cell(zh)} | {prefix}{escape_cell(en)} |"


def build(blocks, units, by_text, translations):
    """The bilingual Markdown and a list of problems with the translations."""
    problems = []
    texts = {u["id"]: u for u in units}

    def pair(text):
        uid = unit_id(by_text, text)
        if uid is None:
            return text, text
        unit, tr = texts[uid], translations.get(uid, {})
        zh = text if unit["need"] == "en" else tr.get("zh")
        en = text if unit["need"] == "zh" else tr.get("en")
        if not zh or not en:
            problems.append(f"{uid}: missing translation ({unit['need']}): {text[:60]}")
            return text, text
        if not HAN.search(strip_untranslatable(zh)) and not same_both_ways(zh, en):
            problems.append(f"{uid}: the Chinese text has no Chinese: {zh[:60]}")
        if unit["need"] != "zh" and HAN.search(strip_untranslatable(en)) and "「" not in en:
            problems.append(f"{uid}: the English text has Chinese: {en[:60]}")
        for label, value in (("zh", zh), ("en", en)):
            if spans(value) != spans(text):
                problems.append(f"{uid}: {label} changes code, links or images: {value[:60]} (source {text[:60]})")
        return zh, en

    out, run = [], []

    def flush():
        if run:
            out.extend(DISPLAY_HEADER + run)
            run.clear()

    for block in blocks:
        if block.get("keep"):
            if run:
                flush()
                out.append("")
            out.extend(block["lines"] if block["t"] == "table" else block["raw"])
            continue
        if block["t"] == "prose" and translatable(block["text"]):
            zh, en = pair(block["text"])
            prefix = ("↳ " * block["depth"]) + (block["marker"] + " " if block["marker"] else "")
            run.append(row(zh, en, prefix))
            continue
        flush_needed = block["t"] != "raw" or any(l.strip() for l in block["lines"])
        if block["t"] == "raw" and not any(l.strip() for l in block["lines"]):
            # A blank line inside a run of rows ends nothing; keep the run together unless it is the last blank line.
            if run:
                continue
            out.extend(block["lines"])
            continue
        if flush_needed:
            if run:
                flush()
                out.append("")
        if block["t"] == "heading":
            if translatable(block["text"]):
                zh, en = pair(block["text"])
                out.append(f"{'#' * block['level']} {zh}" if same_both_ways(zh, en) else f"{'#' * block['level']} {zh} / {en}")
            else:
                out.append(f"{'#' * block['level']} {block['text']}")
        elif block["t"] == "prose":
            out.extend(block["raw"])
        elif block["t"] == "table":
            if is_bilingual_table(block) or not any(translatable(c) for r in [block["header"]] + block["rows"] for c in r):
                out.extend(block["lines"])
            else:
                zh_rows = [[pair(c)[0] for c in r] for r in [block["header"]] + block["rows"]]
                en_rows = [[pair(c)[1] for c in r] for r in [block["header"]] + block["rows"]]
                for rows in (zh_rows, en_rows):
                    out.append("| " + " | ".join(escape_cell(c) for c in rows[0]) + " |")
                    out.append(block["align"])
                    out.extend("| " + " | ".join(escape_cell(c) for c in r) + " |" for r in rows[1:])
                    if rows is zh_rows:
                        out.append("")
        else:
            out.extend(block["lines"])
    flush()
    return "\n".join(out), problems


def anchor_map(old_blocks, new_text):
    """Old heading anchor -> new heading anchor, so in-page links keep working."""
    old = [b["text"] for b in old_blocks if b["t"] == "heading"]
    new = [m.group(2) for m in (HEADING.match(l) for l in new_text.split("\n")) if m]
    seen_old, seen_new, mapping = {}, {}, {}
    for a, b in zip(old, new):
        mapping[slug(a, seen_old)] = slug(b, seen_new)
    return mapping


def cmd_extract(args):
    text = pathlib.Path(args.file).read_text(encoding="utf-8")
    units, _ = units_of(parse(text))
    payload = {"source": args.file, "units": units}
    data = json.dumps(payload, ensure_ascii=False, indent=1)
    if args.output:
        pathlib.Path(args.output).write_text(data, encoding="utf-8")
        counts = {k: sum(1 for u in units if u["need"] == k) for k in ("zh", "en", "both")}
        print(f"{args.file}: {len(units)} units ({counts['zh']} need zh, {counts['en']} need en, {counts['both']} need both) -> {args.output}")
    else:
        print(data)
    return 0


def cmd_assemble(args):
    text = pathlib.Path(args.file).read_text(encoding="utf-8")
    blocks = parse(text)
    units, by_text = units_of(blocks)
    translations = json.loads(pathlib.Path(args.translations).read_text(encoding="utf-8"))
    supplied = json.loads(pathlib.Path(args.units).read_text(encoding="utf-8"))["units"]
    if [u["text"] for u in supplied] != [u["text"] for u in units]:
        print("error: the units file does not match the document (extract again)", file=sys.stderr)
        return 1
    result, problems = build(blocks, units, by_text, translations)
    mapping = anchor_map(blocks, result)
    result = re.sub(r"\]\(#([^)\s]+)\)", lambda m: "](#" + mapping.get(m.group(1), m.group(1)) + ")", result)
    if problems:
        print(f"{args.file}: {len(problems)} problem(s), nothing written:")
        for p in problems[:40]:
            print("  " + p)
        return 1
    pathlib.Path(args.output or args.file).write_text(result.rstrip("\n") + "\n", encoding="utf-8")
    print(f"{args.file}: bilingual ({len(units)} passages)")
    return 0


FENCED = re.compile(r"(?ms)^[ \t]*(`{3,}|~{3,}).*?^[ \t]*\1[ \t]*$")


def outside_fences(text):
    """The text without its fenced code blocks (their backticks are not inline code)."""
    return FENCED.sub("", text)


def document_spans(text):
    """Inline code, link targets and image paths of a document's passages (soft-wrapped lines joined, fences skipped)."""
    found = set()
    for block in parse(text):
        if block["t"] in ("heading", "prose"):
            found |= set(spans(block["text"]))
        elif block["t"] == "table":
            for cells in [block["header"]] + block["rows"]:
                for cell in cells:
                    found |= set(spans(cell))
        elif block["t"] == "raw" and not (block["lines"] and FENCE.match(block["lines"][0])):
            found |= set(spans(" ".join(block["lines"])))
    return found


def fenced_blocks(text):
    return ["\n".join(b["lines"]).strip() for b in parse(text) if b["t"] == "raw" and b["lines"] and FENCE.match(b["lines"][0])]


def check_file(path, against):
    text = pathlib.Path(path).read_text(encoding="utf-8")
    blocks = parse(text)
    problems = []
    for index, block in enumerate(blocks):
        if block.get("keep"):
            continue
        if block["t"] == "heading" and translatable(block["text"]):
            parts = block["text"].split(" / ")
            if len(parts) >= 2:
                if not HAN.search(parts[0]) or not has_latin_words(" / ".join(parts[1:])):
                    problems.append(f"heading is not '中文 / English': {block['text'][:70]}")
            elif HAN.search(block["text"]) or len(block["text"].split()) > 2:
                problems.append(f"heading is not '中文 / English': {block['text'][:70]}")
        elif block["t"] == "prose" and translatable(block["text"]):
            problems.append(f"prose outside a bilingual table: {block['text'][:70]}")
        elif block["t"] == "table":
            if is_bilingual_table(block):
                for cells in block["rows"]:
                    if len(cells) != 2 or not cells[0] or not cells[1]:
                        problems.append(f"row without both languages: {' | '.join(cells)[:70]}")
                        continue
                    if same_both_ways(cells[0], cells[1]):
                        continue
                    if translatable(cells[0]) and not HAN.search(strip_untranslatable(cells[0])):
                        problems.append(f"left cell has no Chinese: {cells[0][:70]}")
                    if translatable(cells[1]) and not has_latin_words(cells[1]):
                        problems.append(f"right cell has no English: {cells[1][:70]}")
                    right = strip_untranslatable(cells[1])
                    if HAN.search(re.sub(r"「[^」]*」|\"[^\"]*\"", " ", right)):
                        problems.append(f"right cell has Chinese: {cells[1][:70]}")
            elif any(translatable(c) for r in [block["header"]] + block["rows"] for c in r):
                twin = next((b for b in blocks[index + 1:] if b["t"] != "raw" or any(l.strip() for l in b["lines"])), None)
                previous = next((b for b in reversed(blocks[:index]) if b["t"] != "raw" or any(l.strip() for l in b["lines"])), None)
                chinese_first = any(HAN.search(strip_untranslatable(c)) for r in [block["header"]] + block["rows"] for c in r)
                partner = twin if chinese_first else previous
                if not (partner and partner["t"] == "table" and len(partner["rows"]) == len(block["rows"])
                        and len(partner["header"]) == len(block["header"])):
                    problems.append(f"table without its twin in the other language: {' | '.join(block['header'])[:70]}")
    if against:
        old = subprocess.run(["git", "show", f"{against}:{path}"], capture_output=True, text=True)
        if old.returncode != 0:
            problems.append(f"cannot read {path} at {against}")
        else:
            if fenced_blocks(old.stdout) != fenced_blocks(text):
                problems.append("the code blocks differ from the original")
            before, after = document_spans(old.stdout), document_spans(text)
            if before != after:
                missing = sorted(before - after)
                added = sorted(after - before)
                problems.append(f"inline code, links or images differ: missing {missing[:4]} added {added[:4]}")
    return problems


def cmd_check(args):
    status = 0
    for path in args.files:
        problems = check_file(path, args.against)
        if problems:
            status = 1
            print(f"{path}: {len(problems)} problem(s)")
            for p in problems[:30]:
                print("  " + p)
        else:
            print(f"{path}: OK")
    return status


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)
    extract = sub.add_parser("extract")
    extract.add_argument("file")
    extract.add_argument("-o", "--output")
    extract.set_defaults(func=cmd_extract)
    assemble = sub.add_parser("assemble")
    assemble.add_argument("file")
    assemble.add_argument("units")
    assemble.add_argument("translations")
    assemble.add_argument("-o", "--output")
    assemble.set_defaults(func=cmd_assemble)
    check = sub.add_parser("check")
    check.add_argument("files", nargs="+")
    check.add_argument("--against", help="a git ref: compare code blocks, inline code, links and images with the file there")
    check.set_defaults(func=cmd_check)
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
