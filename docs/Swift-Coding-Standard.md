# Swift coding standard

The rules for Swift code in this project: the core library while and after it moves from Objective-C to Swift
(`docs/Swift-Migration.md`), the examples and the tests. Official rules come first: the
[Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) and Apple's documentation
for Swift / Objective-C interoperability. This document only records this project's choices among them.

Skills that apply (in `.agents/skills/`):

- `swift-api-design-guidelines-skill`: naming, argument labels, documentation comments (Swift API Design Guidelines).
- `migration-patterns` (`objc-to-swift.md`): mapping Objective-C idioms to Swift, incremental migration, `@objc`.
- `swift-concurrency`: actors, `@MainActor`, `Sendable`, the Swift 6 language mode.
- `cyl-swift`: this project's Swift-facing names (`NS_SWIFT_NAME`, `cyl_` methods) and how to check imported names.
- `cyl-comments`: the documentation comment format.

## 1. Core quality first; the examples adapt

**Priority (rule of 2026-11-13, replaces "compatibility first"):** the Swift code of the core follows this standard and
the Swift API Design Guidelines, with no burden kept for the examples. The examples have the lowest weight of all code
in the project.

1. **When the migration breaks an example, change the example.** A compile error or a test failure in an example
   (`Example/`, `Example-Swift/`, the demo app, the `TagCollectionView` demo, their tests) is fixed in the example's
   code first. The core never keeps an old name, an implicitly unwrapped optional, an Objective-C-style signature, an
   `NSArray` / `NSDictionary` type, a factory method or any other construct only because an example uses it.
2. **No compatibility work for the examples.** Where an example needs no change, nothing is added for compatibility;
   where it does, the example changes. Never lower the quality of the core's Swift code to fit an example's usage.
3. **The Swift API may change to become idiomatic.** Names, argument labels, optionality (`T?` / `T` instead of the
   imported `T!`), value types and Swift collections follow the guidelines. `scripts/swift-api-check.sh` reports every
   change against `scripts/swift-api-baseline.json`; a change is accepted when this standard asks for it, listed in
   `docs/Swift-Migration.md` ("Swift API changes"), and the baseline is refreshed (`--baseline`) in the same commit.
   A change the standard does not ask for is a bug.
4. **Objective-C names** (`@objc(CYLName)`, `@objc(selector:)`) are kept where the core's own Objective-C tests, XIB
   `customClass` entries, selectors or key-value coding need them; nothing else is exposed to Objective-C only for
   compatibility. The core's own tests are not examples: keep them passing, and update them with the API.
5. **Types keep the `CYL` prefix** (Objective-C has no namespaces, and the Swift names imported so far have it).
   Swift-only helpers (`private` / `fileprivate` / `internal`) do not need the prefix.
6. **Categories become extensions**; a member that Objective-C code of the core still calls keeps its `cyl_`
   Objective-C name (`@objc(cyl_setWidth:)`). Swift names follow the Swift API Design Guidelines (`cyl-swift` for the
   underscore rule).
7. **`NS_TYPED_ENUM` string constants** become `struct … : RawRepresentable, Hashable` (or the `extension
   NSNotification.Name` form) with `static let` members, and `@objc` global constants where Objective-C used them.
   `NS_ENUM` becomes `@objc public enum …: Int` with the same raw values; `NS_OPTIONS` becomes an `OptionSet`
   (plus `@objc` access where Objective-C needs it). `NS_ERROR_ENUM` keeps its error domain and codes.
8. **Initializers:** an Objective-C designated initializer becomes a designated `init`; a factory method imported as
   an initializer stays one (`convenience init`); `NS_UNAVAILABLE` becomes `@available(*, unavailable)`.
9. **Nib and storyboard names, accessibility identifiers, localization keys and resource names stay unchanged**
   (tests and XIBs depend on them). A class created from a XIB keeps `@objc(CYLName)` so the XIB's `customClass` still
   resolves (also set `customModule` when the XIB is edited).

## 2. Files and structure

- One public type per file, named after the type (`CYLTagButton.swift`); extensions of another type in
  `Type+Topic.swift` (`UIView+CYLGeneral.swift`). Mind the case-insensitive file system (a name differing only in
  case overwrites a file).
- Order inside a type: nested types, public properties, initializers, public methods, overrides, private helpers.
  Group with `// MARK: - Topic`. Protocol conformances in extensions (`extension CYLTagListView:
  UICollectionViewDataSource`).
- A file migrates as a whole: the `.h` and `.m` are deleted in the same commit that adds the `.swift` file, and the
  podspec's `source_files` pattern covers `swift`.
- Four spaces, lines at most 120 columns, one blank line between members, no trailing whitespace.

## 3. Language

- **Access control is explicit for the API:** `open` for classes and members that apps subclass or override (every
  class that was public in Objective-C is `open`, as Objective-C classes could be subclassed, unless it is marked
  final in its documentation); `public` for the rest of the API; `internal` (implicit) or `private` for everything
  else. `final` on internal classes.
- **Optionals instead of nullability:** `nullable` → `T?`, `nonnull` → `T`; an Objective-C property without
  nullability (imported as `T!`) gets the type it really has (`T` when it always has a value, `T?` otherwise), not
  `T!`. `T!` only for `@IBOutlet`s. No force unwraps except for resources shipped in the pod's bundle (with a message:
  `guard let … else { preconditionFailure("…") }`).
- **Value types where Objective-C used immutable models only internally**; public models that Objective-C callers use
  stay `NSObject` classes (with `NSCopying` when the Objective-C class had it).
- **Errors:** Objective-C `NSError **` methods become `throws` (the imported Swift form already was); errors are the
  existing `NSError` domain and codes.
- **Collections:** `[T]`, `[K: V]`, `Set<T>`; `NSArray` / `NSDictionary` only where Objective-C callers need the
  reference semantics or KVC.
- **Closures** replace blocks; escaping closures that capture `self` use `[weak self]`.
- **Constants:** `static let` in the owning type; magic numbers get a name.
- **Runtime lookups** that keep the core free of a dependency (CYLTabBarController's `CYLTabBarItemAnimationFactory`
  and `CYLTabBarConfigurationParser`, found with `NSClassFromString` and selectors) stay runtime lookups, wrapped in
  one small type with documented selectors.
- **No new dependencies.** The core links UIKit and Accelerate only.

## 4. Concurrency

- Swift 5 language mode for the pod (`swift_version`), with `@MainActor` on every UIKit-facing type (UIKit's own
  classes already are) and on functions that touch views. Strict concurrency checking (`complete`) must stay free of
  errors in the core; warnings are fixed, not silenced.
- No `DispatchQueue.main.async` hops to work around isolation: isolate the type instead. Animation and layout callbacks
  stay on the main actor.
- Follow `swift-concurrency` for anything asynchronous (`Task`, `async` APIs, `Sendable` models).

## 5. Documentation comments

- Every `public` / `open` declaration has a documentation comment in the block form, three lines or more, above the
  declaration (AGENTS.md "Code and naming", `cyl-comments`):

  ```swift
  /**
   * What it does, and what callers must know.
   */
  ```

- The text is carried over from the Objective-C header and updated where Swift changes it (no "`nil`" for a
  non-optional). `- Parameter`, `- Returns`, `- Throws` use Swift's Markup. `//` comments are for implementation
  notes only.

## 6. Localization, resources, accessibility

- Strings through `CYLMenuLocalizedString(_:)`, which reads `CYLClassifyMenuResources.bundle`; no `NSLocalizedString`
  and no bundle reads elsewhere (AGENTS.md "Internationalization and localization").
- Resources load from the pod's resource bundle (`Bundle(for: CYLMenuResources.self)` → the `.bundle`), as before.
- Accessibility behavior, labels, traits, identifiers and Dynamic Type stay exactly as in Objective-C (AGENTS.md
  "Accessibility").

## 7. Verification after every migration commit

1. `scripts/swift-api-check.sh`: every reported change is one this standard asks for, listed in
   `docs/Swift-Migration.md`, with the baseline refreshed; the examples are updated to the new API.
2. `scripts/unit-tests.sh menu`, `tag`, `example` and `swift`: every suite passes (the core's Objective-C tests
   import the module with `@import CollectionViewClassifyMenu;`).
3. `scripts/library-warnings.sh`: no new warnings.
4. `pod lib lint` (`scripts/pod-lint.sh`).
5. Update the score and the progress table in `docs/Swift-Migration.md`.
