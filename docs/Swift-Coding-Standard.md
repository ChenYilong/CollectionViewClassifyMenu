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

## 1. Compatibility first: no break for callers

The migration changes the language, not the API.

1. **The Swift API stays the same.** Every type, method, property, initializer, constant and enum case keeps the
   Swift name, the argument labels, the optionality and the types Swift imported from the Objective-C headers.
   `scripts/swift-api-check.sh` compares the module's API with `scripts/swift-api-baseline.json` (the Objective-C
   core's) and must report no breakage after every migration commit. An intended change needs a documented reason in
   `docs/Swift-Migration.md` and a new baseline (`--baseline`) in the same commit.
2. **The Objective-C API stays available.** Objective-C callers (the core's own tests, any app that uses the pod from
   Objective-C) keep the class names, selectors and constants they had: public classes and protocols are
   `@objc(CYLOriginalName)` and inherit from `NSObject` (or the UIKit class they extended); members that had a
   selector different from the Swift name get `@objc(selector:with:)`. Prefer `@objcMembers` on a class whose members
   are all public API.
3. **Types keep the `CYL` prefix** (Objective-C has no namespaces, and the Swift names imported so far have it).
   Swift-only helpers (`private` / `fileprivate` / `internal`) do not need the prefix.
4. **Categories become extensions** with `@objc` members; a category method's Objective-C name keeps the `cyl_`
   prefix (`@objc(cyl_setWidth:)`), and its Swift name is the one imported before (see `cyl-swift` for the underscore
   rule). A new Swift-facing name follows the Swift API Design Guidelines.
5. **`NS_TYPED_ENUM` string constants** become `struct … : RawRepresentable, Hashable` (or the `extension
   NSNotification.Name` form) with `static let` members, and `@objc` global constants where Objective-C used them.
   `NS_ENUM` becomes `@objc public enum …: Int` with the same raw values; `NS_OPTIONS` becomes an `OptionSet`
   (plus `@objc` access where Objective-C needs it). `NS_ERROR_ENUM` keeps its error domain and codes.
6. **Initializers:** an Objective-C designated initializer becomes a designated `init`; a factory method imported as
   an initializer stays one (`convenience init`); `NS_UNAVAILABLE` becomes `@available(*, unavailable)`.
7. **Nib and storyboard names, accessibility identifiers, localization keys and resource names stay unchanged**
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
- **Optionals instead of nullability:** `nullable` → `T?`, `nonnull` → `T`. A property declared `null_resettable` or
  imported as `T!` keeps `T!`. No force unwraps except for `T!` API kept for compatibility, `@IBOutlet`s and resources
  shipped in the pod's bundle (with a message: `guard let … else { preconditionFailure("…") }`).
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

1. `scripts/swift-api-check.sh`: no Swift API breakage.
2. `scripts/unit-tests.sh menu`, `tag`, `example` and `swift`: every suite passes (the core's Objective-C tests
   import the module with `@import CollectionViewClassifyMenu;`).
3. `scripts/library-warnings.sh`: no new warnings.
4. `pod lib lint` (`scripts/pod-lint.sh`).
5. Update the score and the progress table in `docs/Swift-Migration.md`.
