# Code, Swift core and bugs

Tag: `code`. The full rules of this tag. [AGENTS.md](../../AGENTS.md) keeps the short form under the heading
`[code] Code, Swift core and bugs`; read this file when a task touches the tag. Moved from AGENTS.md word for word on 2026-11-22, when
AGENTS.md was limited to 200 lines; section names are unchanged, so a reference such as AGENTS.md "Code and naming" now
means the section of that name here.


## Code and naming

- Use the `CYL` prefix for project-specific Objective-C classes and protocols;
  category names use `CYL` and category methods use `cyl_`. Preserve existing
  public APIs unless a requested naming migration explicitly changes them;
  document incompatible changes and update XIBs and callers.
- Use descriptive English identifiers and conventional Objective-C naming.
  Keep existing names and localization unless a change is necessary.
- Document user-visible changes and verify them with a targeted build or test.
- Code comments: a public API (everything in the pod's headers, and any
  `public`/`open` Swift declaration) is documented with a documentation comment
  that callers see in Xcode's Quick Help and in the Swift interface of the
  Objective-C headers. A comment of more than one line is one block, never a
  stack of single-line comments: in Objective-C headers use
  ```objc
  /*!
   * What it does, and what callers must know.
   */
  ```
  In Swift source, where the compiler does not treat `/*!` as documentation,
  use `/** … */` with the same layout. Plain `//` comments are for
  implementation notes only, never for public API docs.
- The format required for multi-line public API comments also applies to
  one-line public API comments:
  - One-line comments use the block format too: a one-line public API comment
    is written like a multi-line one, as the three lines `/*!`, ` * text`,
    ` */`, above the declaration. Never put `/*! text */` on one line, and
    never add a trailing `/**< */`, `/*!< */`, `///<` or `//` after a
    declaration or an enum value.
  - Each file that holds public API uses one comment format, for long and
    short comments alike.
  - This applies to every platform and language, always with the block form of
    the platform's documentation tool, laid out the same way (opener, one line
    per text line, closer on its own line):
    - Kotlin, Java, TypeScript, JavaScript: `/** */`.
    - Python: a triple-quoted docstring whose quotes stand on lines of their
      own.
    - Go: `/* */`.
    - C#: `/** */` with XML tags.
    - Rust: `/** */`.
    - A language without a block form uses its only documentation comment form
      throughout the file.
  - Every comment format follows the official rules of its language and
    documentation tool, which take precedence: the syntax inside a comment
    (tags, Markdown, XML elements, docstring content) is the official one,
    and a form the official tool does not read as documentation is never
    used. The forms above are this project's choice among the officially
    valid ones. References: `.agents/skills/cyl-comments/`.
  Details and the check: `.agents/skills/cyl-comments/`.
- Use English Conventional Commit messages, such as `fix: 🐛 ...` and
  `docs: 📝 ...`.
- **Commit messages: git cz style, English only.** Every commit is written in the `git cz` (commitizen, cz-emoji)
  style: the subject is `<type>(<optional scope>): <emoji> <summary>`, with the type one of `feat`, `fix`, `docs`,
  `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore` or `revert` (for example `feat: ✨ …`, `fix(harmony): 🐛
  …`), followed by a body and the author line. The whole message (subject, body and trailers) is in English: no
  Chinese characters, and no other non-English text, are allowed anywhere in a commit message. Write a user's
  non-English prompt only in the task log in `docs/` (quoted verbatim there), never in a commit. Check:
  `scripts/check-commit-message.sh [range]`.
- Every commit message's description (the body) must contain the author line
  `By @ChenYilong <luohanchenyilong@163.com>`, exactly as written, on its own
  line after the description and before any trailers. Details:
  `.agents/skills/cyl-commit/`.


## Swift examples and a Swift-friendly core

- Every iOS example is written in Swift, tests included: `Example/CYLMenuExample`,
  `Example-Swift/CYLTagEditorExample`, the demo app of
  `CollectionViewClassifyMenu.xcodeproj` (module `CYLClassifyMenuDemo`) and the
  `TagCollectionView` demo. Never add Objective-C example code. The core library
  (the pod's sources) is moving from Objective-C to Swift (next item); its own
  tests stay in Objective-C until the migration says otherwise.
- **The core moves to Swift** (since 2026-11-12): the pod's sources are translated
  file by file, following `docs/Swift-Coding-Standard.md` and the Swift skills it
  lists (`swift-api-design-guidelines-skill`, `migration-patterns`,
  `swift-concurrency`, `cyl-swift`). Progress and score (no Objective-C file
  left = 100): `docs/Swift-Migration.md`.
- **Core quality first, examples last (2026-11-13).** When the migration breaks
  an example (a compile error or a test), change the example's code first: the
  examples have the lowest weight in the project, and no compatibility is kept
  for them. Change example code freely so that the core's Swift code carries no
  baggage: never lower the core's Swift quality to fit an example's usage; the
  Swift coding standard (`docs/Swift-Coding-Standard.md`) decides. The Swift API
  may become idiomatic; `scripts/swift-api-check.sh` reports each change, which
  is listed in `docs/Swift-Migration.md` with the baseline refreshed.
  Objective-C names stay only where the core's own Objective-C tests, XIBs,
  selectors or key-value coding need them.
- Until a part of the core is Swift: when an example calls an Objective-C API
  that reads badly in Swift, fix it in the core, never with workarounds in the
  example: the Swift API Design Guidelines decide (`NS_SWIFT_NAME`, nullability,
  lightweight generics, `NS_ENUM`/`NS_OPTIONS`/`NS_TYPED_ENUM` string constants,
  class properties, `NS_DESIGNATED_INITIALIZER`, `NS_SWIFT_UNAVAILABLE`, `throws`
  through `NSError **` as the last parameter).
- `cyl_` methods: follow CYLTabBarController's rule ("Swift-friendly names for
  underscored protocol methods" in its AGENTS.md, and its `docs/Swift-Guide.md`,
  at its newest commit):
  Swift names have no underscore, and the Swift name of an existing public method
  never changes. Add a new method without the underscore that keeps the `cyl`
  prefix (`-cyl_setWidth:` → `-cylSetWidth:`), give only the new one its Swift
  name with `NS_SWIFT_NAME`, and run the same logic for both spellings (for a
  protocol method, call the new one when implemented, otherwise the old one, and
  make an old `@required` method `@optional`).
- Details, the check of imported Swift names and the list of methods still to
  adapt: `.agents/skills/cyl-swift/`.


## Fix issues in the core first

- The core is the code this repository publishes to a package registry: the
  CocoaPods pod and Swift package (`CollectionViewClassifyMenu/`), the Android
  library on Maven / Gradle (`android/merged/library`,
  `android/AndroidTagView/androidtagview`), the npm package
  `react-native-cyl-tag-list` (its `src/`, `android/`, `ios/`, not `example/`
  or `harmony-example/`), the pub.dev plugins (`flutter/cyl_tag_list`,
  `flutter/cyl_tag_list_ohos`, not their `example/`), the ohpm HAR
  (`harmony/classifymenu`, not `harmony/entry`) and the mini program npm
  packages (`CrossPlatform/wechat-miniprogram/packages`). Everything
  else (example apps, demo pages, demo data, screenshot scripts) is the example
  layer.
- When an issue or bug is reported, even one seen only in an example screen or
  screenshot, fix it in the core first, so that every app using the library, and
  every similar case, is fixed and the same problem cannot come back elsewhere.
  Look for the core cause before touching the example: a wrong default, a
  missing option, a measurement or layout rule, a missing localization or
  accessibility hook, a color that does not follow the color mode.
- A fix in the example layer is the worst option. Use it only when the defect
  really is in example code or example data (a demo string, a demo page's own
  layout, a screenshot script), or when the core cannot fix it.
- When a core defect cannot be fixed in the core, stop and ask the user before
  fixing it in the example, and say why the core cannot fix it (for example: a
  third-party library's bug, a platform limitation, an API the core must keep
  for compatibility).
- Record every example-layer fix in `docs/example-layer-fixes.md`: the issue,
  the files changed, and why it could not be solved in the core (or why the
  defect was example-only). Mention that document in the issue's row of its
  progress table.


## Bugs: record, screenshot, fix in CYLTabBarController's animated item

- For every bug: first record it (a `TODO` row in the related document in
  `docs/`, with the steps and what was expected), then take a screenshot of it
  (`docs/assets/`, linked from the row), then fix it, then take the screenshot
  again and mark the row done with both images.
- Animation and icon + title bugs are fixed in CYLTabBarController's shared
  animated item component (`CYLAnimatedItem` / `CYLAnimatedItemView` on iOS,
  `cylanimateditem` on Android and HarmonyOS, `cyl-animated-item` in the mini
  program), not in this repository's examples. This repository only pins the
  fixed commit (by `:commit` or the vendored copy) and adapts its own core
  (`CYLTagButton`) to the component.
- Avoid changing the examples. When a demo needs something the component does
  not offer, CYLTabBarController adds that API to the component and the demo
  uses it; record the request and the CYLTabBarController pull request.
- A fix made here meanwhile (in this repository's core, never the example)
  names the CYLTabBarController change that will replace it, as a `TODO` in
  `docs/animated-item-migration.md`.
