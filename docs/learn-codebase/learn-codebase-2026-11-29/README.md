# CollectionViewClassifyMenu: learn-codebase export

Source: /claude-mem:learn-codebase, commit 03707ba2, branch fix/shared-contrast-ios, 2026-11-29. Read-only; nothing built or run.
These describe that commit. Check the current source before relying on them.

本目录是 CollectionViewClassifyMenu 在提交 `03707ba2` 时的代码库阅读笔记（英文）。内容未经构建或运行验证，缺陷条目是待复核的候选项，使用前请对照当前源码。

## Location / 位置
This folder is `docs/learn-codebase/learn-codebase-2026-11-29/` (moved from the claude-mem deliverables folder on
2026-11-29). claude-mem can ingest it as project `CollectionViewClassifyMenu` through its
`CLAUDE_MEM_MEMORY_WATCH_ROOTS` setting (a per-machine setting, not part of the repository). It reads only `.md` files of
at most 64 KB, so larger API reference files are split into `-partN.md` files, and `file-inventory.tsv` is not ingested.
claude-mem 通过本机设置 `CLAUDE_MEM_MEMORY_WATCH_ROOTS` 收录本目录；只读取不超过 64 KB 的 `.md` 文件，因此较大的文件已拆分，`file-inventory.tsv` 不会被收录。

## Start here
| File | Content |
|---|---|
| 01-repo-overview.md | layout, working rules, dependency pins, CI and scripts |
| 02-ios-core.md | iOS architecture and invariants |
| 03-android.md | Android library, ports, example |
| 04-harmonyos.md | HarmonyOS library, example, build |
| 05-miniprogram.md | mini program package, example, tests |
| 06-flutter-react-native.md | wrappers and their examples |
| 07-examples-and-tests.md | examples, test style, test gaps |
| 08-patterns-and-gotchas.md | rules that hold across platforms |
| 09-findings.md | candidate bugs with evidence and confidence (1-13, then V1-V8) |
| 10-coverage-and-method.md | what was and was not read |
| 11-vendored-modules.md | the copied CYLTabBarController and CYLDeallocBlockExecutor modules |
| api-reference/ | script-generated declarations and source comments, per platform and layer |
| file-inventory.tsv | 853 source files: path, lines, area, kind, types, header comment |
| appendix-*.md | raw reading notes (shorthand, some lines superseded by 09), early report, 11-27 iOS core notes |

file-inventory.tsv has a read_mode column (derived by path rules and updated after pass 2, not logged per file; see 10).
api-reference/vendored-*.md cover the copied modules.

## How reliable
- 11 and V1-V8: written after reading the copied modules; cited lines were looked up with grep or read again.
- 01-08: written from this session's reading (through its saved context summaries); not every sentence was re-checked
  against the source. Pins, and the findings marked source-checked, were.
- api-reference and the inventory: made by pattern matching. Comments are verbatim; some declarations may be missing or
  cut at the first line; the "kind" column is guessed from paths.
