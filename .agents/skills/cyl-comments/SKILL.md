---
name: cyl-comments
description: Code comment rules for CollectionViewClassifyMenu - public API documentation comments are three-line blocks above the declaration (Objective-C /*! */, Swift /** */), one-line comments included, one format per public API file, never trailing comments, the block form of every platform and language, and a check script.
---

# Code comments

## Why

A public API's documentation must reach its callers: Xcode's Quick Help, code completion and the generated Swift
interface of an Objective-C header show only *documentation comments* attached to the declaration. A stack of `//`
lines is not documentation at all; a stack of `///` lines breaks as soon as a plain `//` or a blank line slips in;
trailing comments after a member are easy to miss and render differently in every tool. So every public API comment,
long or short, is one block above its declaration, and a file never mixes formats.

## The rules

1. **One-line comments use the block format too.** A one-line public API comment is written like a multi-line one:
   three lines, the opener, ` * text` and the closer, above the declaration.
   - Never on one line: no `/*! text */`.
   - Never trailing: no `/**< */`, `/*!< */`, `///<` or `//` after a declaration or an enum value.
2. **One format per file.** Each file that holds public API uses one comment format, for long and short comments
   alike.
3. **Every platform and language**, always with the block form of the platform's documentation tool, laid out the
   same way (opener on its own line, one line per text line, closer on its own line).

| Platform / language | Public API comment |
| --- | --- |
| Objective-C headers (the pod's public API) | `/*!` … ` */` |
| Swift (`public` / `open`) | `/**` … ` */` (Swift does not read `/*!` as documentation) |
| Kotlin, Java, TypeScript, JavaScript | `/**` … ` */` (KDoc, Javadoc, TSDoc / JSDoc) |
| Python | a triple-quoted docstring, the quotes on lines of their own |
| Go | `/*` … ` */` directly above the declaration |
| C# | `/**` … ` */` with XML tags (`<summary>`, `<param>`, `<returns>`) |
| Rust | `/**` … ` */` (outer doc comment) |
| A language without a block form | its only documentation comment form, throughout the file |

Implementation notes (`.m`, private Swift, inside bodies) are not documentation: plain `//` or `/* */` there.

4. **The official rules decide.** Every comment format follows the official specification of its language and
   documentation tool, and the specification wins over anything here: the syntax inside a comment (tags, Markdown,
   XML elements, docstring sections) is the official one, and a form the official tool does not read as
   documentation is never used. The forms in the table are this project's choice among the officially valid ones
   (each tool below reads them as documentation); for Python, PEP 257's multi-line layout (quotes on their own
   lines) is used for one-line docstrings too, which PEP 257 allows.

| Language / tool | Official rules |
| --- | --- |
| Objective-C (Clang, Xcode Quick Help) | Clang documentation comments (`/*!` and `/**`, HeaderDoc / Doxygen commands such as `@param`, `@return`), checked by `-Wdocumentation`: <https://clang.llvm.org/docs/UsersManual.html#comment-parsing-options> |
| Swift | Swift Markup Formatting Reference (`/** */`, `- Parameter`, `- Returns:`): <https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref/> |
| Kotlin | KDoc (`/** */`, Markdown, `@param`, `@return`): <https://kotlinlang.org/docs/kotlin-doc.html> |
| Java | Javadoc documentation comment specification: <https://docs.oracle.com/en/java/javase/21/docs/specs/javadoc/doc-comment-spec.html> |
| TypeScript | TSDoc: <https://tsdoc.org/> |
| JavaScript | JSDoc: <https://jsdoc.app/> |
| Python | PEP 257 docstring conventions: <https://peps.python.org/pep-0257/> |
| Go | Go doc comments (a comment directly before the declaration; `/* */` is read like `//`): <https://go.dev/doc/comment> |
| C# | XML documentation comments (delimited `/** */` form, `<summary>`, `<param>`, `<returns>`): <https://learn.microsoft.com/dotnet/csharp/language-reference/xmldoc/> |
| Rust | rustdoc (outer block doc comments `/** */`, Markdown): <https://doc.rust-lang.org/rustdoc/how-to-write-documentation.html> |

When a rule here and the official specification disagree, follow the specification and fix this skill.

## Examples

```objc
/*!
 * The list's title view, a header.
 */
@property (nonatomic, strong, readonly) CYLTagButton *titleView;

typedef NS_ENUM(NSInteger, CYLMenuSelectionMode) {
    /*!
     * Items behave like buttons: taps are reported, nothing stays selected.
     */
    CYLMenuSelectionModeNone = 0,
};

/*!
 * Expands or collapses one section. A section with no more rows than `defaultVisibleRows` cannot fold.
 *
 * @param expanded YES to show every row.
 * @param animated Animates the change unless Reduce Motion is on.
 */
- (void)setExpanded:(BOOL)expanded forSection:(NSInteger)section animated:(BOOL)animated;
```

```swift
/**
 * Expands the first section of every list.
 */
public func expandAll()
```

```kotlin
/**
 * The tab's title.
 */
val title: String
```

```python
def reload_menu():
    """
    Reloads every section from the data source.
    """
```

```go
/*
 * Reload reloads every section from the data source.
 */
func Reload() {}
```

```csharp
/**
 * <summary>The tab's title.</summary>
 */
public string Title { get; }
```

```rust
/**
 * Reloads every section from the data source.
 */
pub fn reload() {}
```

Not allowed:

```objc
/*! The list's title view. */                               // one-line block
@property (nonatomic, strong) CYLTagButton *titleView;
/// The list's title view.                                    // line comment
@property (nonatomic, strong) CYLTagButton *titleView;
@property (nonatomic, strong) CYLTagButton *titleView; ///< The list's title view.   // trailing
CYLMenuSelectionModeNone = 0, /*!< Buttons only. */          // trailing on an enum value
```

- The block sits directly above the declaration (no blank line, no `#pragma` in between).
- Clang tags (`@param`, `@return`, `@see`, `@note`, `@warning`) and Swift Markdown fields (`- Parameter`,
  `- Returns:`) are optional; use them when they add information.
- File header comments (`//  File.h`, licenses, before the first `#import`) stay as they are.
- No commented-out code in public headers; delete it (Git keeps the history).

## Check

`scripts/check-doc-comments.py` checks the pod's public headers and lists every violation: `///` comments (one line
or several), `/**` openers, plain `//` comments placed on a declaration, one-line `/*! text */` blocks and trailing
comments (`/**< */`, `/*!< */`, `///<`, `//`) after a declaration or an enum value. `--fix` rewrites them as
three-line `/*! … */` blocks above the declaration. CI runs it in the shellcheck job.

```sh
python3 scripts/check-doc-comments.py          # exit 1 and the locations when something is left
python3 scripts/check-doc-comments.py --fix
```
