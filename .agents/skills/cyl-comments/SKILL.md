---
name: cyl-comments
description: Code comment rules for CollectionViewClassifyMenu - documentation comments for public APIs (Objective-C /*! */ blocks, Swift /** */), one uniform format per public API file (one-line comments included, every platform and language), the formats of other platforms, and a check script.
---

# Code comments

## Why

A public API's documentation must reach its callers: Xcode's Quick Help, code completion and the generated Swift
interface of an Objective-C header show only *documentation comments* attached to the declaration. A stack of `//`
lines is not documentation at all, and a stack of `///` lines is fragile (one plain `//` or a blank line in between
detaches it, and tools merge or split it differently), so a comment is written as one block; and because one-line
`///` comments next to blocks would split a file into two formats, one-line comments use the same block.

## iOS / macOS

| Where | Every documentation comment (one line or several) |
| --- | --- |
| Objective-C headers (the pod's public API) | `/*!` block (below) |
| Swift `public` / `open` declarations | `/** … */` block (Swift does not read `/*!` as documentation) |
| Implementation notes (`.m`, private Swift, inside bodies) | `//` lines or `/* … */` (not documentation) |

**One format per file.** The block format is not only for long comments: in a file that holds public API, a
one-line comment uses the same block, laid out the same way, so the whole file reads uniformly and every comment
reaches Quick Help:

```objc
/*!
 * The list's title view, a header.
 */
@property (nonatomic, strong, readonly) CYLTagButton *titleView;
```

No `///`, no `///<` after a member and no plain `//` on a declaration in a public header.

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

- The block sits directly above the declaration (no blank line, no `#pragma` in between), enum cases included.
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

**Every platform and language keeps one format per public API file.** Where the official format is a block
(Objective-C, Swift, Kotlin, Java, JavaScript/TypeScript), one-line comments are blocks too:

```kotlin
/**
 * The tab's title.
 */
val title: String
```

Where the official guide prescribes a line form (Dart, Rust, C#, Go), every comment, long or short, uses that line
form; Python uses docstrings for every public function and class. Never mix two documentation formats in one file.

## Check

`scripts/check-doc-comments.py` lists, in the pod's public headers, every `///` comment (one line or several),
`/**` opener and plain `//` comment placed on a declaration; `--fix` rewrites them as `/*! … */` blocks. The file
header (`//  File.h`, licenses, before the first `#import`) is left alone.

```sh
python3 scripts/check-doc-comments.py          # exit 1 and the locations when something is left
python3 scripts/check-doc-comments.py --fix
```

Run it before committing header changes; CI runs it in the shellcheck job.
