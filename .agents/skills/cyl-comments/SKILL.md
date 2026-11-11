---
name: cyl-comments
description: Code comment rules for CollectionViewClassifyMenu - documentation comments for public APIs (Objective-C /*! */ blocks, Swift /** */), no stacked single-line comments, the formats of other platforms, and a check script.
---

# Code comments

## Why

A public API's documentation must reach its callers: Xcode's Quick Help, code completion and the generated Swift
interface of an Objective-C header show only *documentation comments* attached to the declaration. A stack of `//`
lines is not documentation at all, and a stack of `///` lines is fragile (one plain `//` or a blank line in between
detaches it, and tools merge or split it differently), so a comment longer than one line is written as one block.

## iOS / macOS

| Where | One line | More than one line |
| --- | --- | --- |
| Objective-C headers (the pod's public API) | `/// Text.` | `/*!` block (below) |
| Swift `public` / `open` declarations | `/// Text.` | `/** … */` (Swift does not read `/*!` as documentation) |
| Implementation notes (`.m`, private Swift, inside bodies) | `//` | `//` lines or `/* … */` |

```objc
/*!
 * Expands or collapses one section. A section with no more rows than `defaultVisibleRows` cannot fold.
 *
 * @param expanded YES to show every row.
 * @param section The section index.
 * @param animated Animates the change unless Reduce Motion is on.
 */
- (void)setExpanded:(BOOL)expanded forSection:(NSInteger)section animated:(BOOL)animated;
```

```swift
/**
 Expands the first section of every list, as tapping each fold control does.

 - Parameter animated: Animates the change.
 */
public func expandAll(animated: Bool)
```

- The block sits directly above the declaration (no blank line, no `#pragma` in between); `///<` after a member is
  allowed for a one-line note on an enum case or property.
- Clang tags (`@param`, `@return`, `@see`, `@note`, `@warning`) and Swift Markdown fields (`- Parameter`,
  `- Returns:`, `- Throws:`) are optional; use them when they add information.
- File header comments (`//  File.h`, licenses) stay as they are.
- No commented-out code in public headers; delete it (Git keeps the history).

## Other platforms (official formats)

| Platform | Documentation comment |
| --- | --- |
| Android / Kotlin | KDoc `/** … */` (Dokka) |
| Java | Javadoc `/** … */` |
| JavaScript / TypeScript | JSDoc / TSDoc `/** … */` |
| Dart / Flutter | `///` on every line (dartdoc's own recommendation; `/** */` is discouraged) |
| Rust | `///` (outer) and `//!` (module) |
| C# | XML doc `///` |
| Python | docstrings `"""…"""` |
| Go | `//` lines directly above the declaration (godoc reads them) |

Where a platform's official guide prescribes line comments (Dart, Rust, C#, Go), follow it: the rule is "use the form
the platform's documentation tool reads", and only Objective-C/Swift/Kotlin/Java/JS use the block form.

## Check

`scripts/check-doc-comments.py` lists stacked `///` lines and `/**` openers in the pod's public headers; `--fix`
rewrites them as `/*! … */` blocks.

```sh
python3 scripts/check-doc-comments.py          # exit 1 and the locations when something is left
python3 scripts/check-doc-comments.py --fix
```

Run it before committing header changes; CI runs it in the shellcheck job.
