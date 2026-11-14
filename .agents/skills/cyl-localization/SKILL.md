---
name: cyl-localization
description: Internationalization and localization rules and checks for CollectionViewClassifyMenu and its Example.
---

# Localization

## Structure

| Module | Bundle | Sources | Lookup macro |
| --- | --- | --- | --- |
| Core (pod) | `CYLClassifyMenuResources.bundle` (also holds images and XIBs) | `CollectionViewClassifyMenu/Resources/Localization/<language>.lproj/CYLClassifyMenu.strings` | `CYLMenuLocalizedString(key, comment)`; Swift: `CYLMenuLocalizedString(_:)` (the C function `CYLMenuLocalizedStringForKey`); images: `CYLMenuImage(name)` |
| Demo app of `CollectionViewClassifyMenu.xcodeproj` (not in the pod) | `CYLClassifyMenuDemo.bundle` | `CollectionViewClassifyMenu/Class/Other/Symtem/CYLClassifyMenuDemo.bundle/<language>.lproj/Localizable.strings` | `CYLDemoLocalizedString(key)` (Swift function in `CYLDemoLocalization.swift`; the demo app is Swift, module `CYLClassifyMenuDemo`) |
| Example | `CYLMenuExample.bundle` | `Example/CYLMenuExample/CYLMenuExample.bundle/<language>.lproj/Localizable.strings` | `CYLExampleLocalizedString(key, args...)` (Swift function in `CYLExampleLocalization.swift`) |
| Swift Example | `CYLTagEditorExample.bundle` (also holds `tags.json` and the `fold-styles.*` configuration files per language) | `Example-Swift/CYLTagEditorExample/CYLTagEditorExample.bundle/<language>.lproj/Localizable.strings` | `CYLTagEditorLocalizedString(key, args...)` (Swift function) |

- Several `.lproj` files of one module always go into that module's single
  `.bundle`. A new module gets its own bundle and its own macro.
- The core bundle always stays and changes cautiously: stable keys (identifiers
  such as `CYLMenuExpand`), every key in every language, removals and renames
  only as documented incompatible changes.
- Example keys are the Chinese source text; sample data (review keywords, tags)
  is not translated.
- `CYLMenuResources` picks the `.lproj` itself (`preferredLanguage`, else the
  user's languages, else English), so hosts need not declare the languages.
  The Example follows the same language.
- XIB texts are placeholders; set user-facing text in code through the macro.
- Localized sample data and images go into the `.lproj` of their language inside the example's bundle, read through
  the example's language (`CYLExampleLocalization.stringsBundle`): `search-discover.json` and the hot icon
  `discover-hot.png` (热, 熱, HOT) of `Example/CYLMenuExample`, `tags.json` of `Example-Swift`. Every language has the
  same items in the same order.
- Other platforms: one resource container per module (for example Android
  `res/values-<locale>/` per module, web JSON per package), the core container
  kept stable, and a lookup helper per module.

## Adding a string

1. Add the key to every `.strings` file of the module (en, zh-Hans, zh-Hant).
2. Use it through the module's macro.
3. Run the Example tests: they check that the core languages share the same keys
   and that the Example runs in English (`testExampleSwitchesLanguage`).
4. Check the `@en` / `@zh-Hant` screenshots of the CI run.

## Acceptance criteria

Modelled on CYLTabBarController's rule ("Localization (i18n / l10n) file structure" in its `AGENTS.md`, newest
commit over every branch, see `cyl-dependency`; its core lookup is `CYLLocalizedString`, an example's for instance
`CYLDemoLocalizedString`).

1. **A core lookup macro.** The core has one macro that maps a key to the localized files inside the core's
   resource bundle, so callers never name the bundle: `CYLMenuLocalizedString` over
   `CYLClassifyMenuResources.bundle`. The bundle's form, name and folder name may differ per platform, but it is
   always a folder or package (iOS: a `.bundle` folder; Android: a module's `res/values*/`; web: a package's
   locale folder).
2. **An example lookup per example.** Each example has its own lookup over its own example-level bundle. The
   examples are Swift, which has no macros, so each has one global function in that role:
   `CYLExampleLocalizedString` over `CYLMenuExample.bundle`, `CYLTagEditorLocalizedString` over
   `CYLTagEditorExample.bundle`, `CYLDemoLocalizedString` over `CYLClassifyMenuDemo.bundle`.
3. **At least two lookups, one per level.** A project passes only with at least two different lookup macros (or
   Swift functions), each reading a different bundle: the core's and at least one example's. Nothing else reads a
   bundle's strings or calls `NSLocalizedString` directly.
4. **Same keys everywhere.** Each bundle has the same keys and the same format specifiers in every language
   (`LC_ALL=C sort` finds duplicates); the core keys are stable identifiers.
5. **Declared like CYLTabBarController's.** A lookup that takes a format is declared so the compiler checks it
   (`NS_FORMAT_ARGUMENT(1)`, and `CYL_RETURNS_LOCALIZED_STRING` where available); Swift code uses
   `String(format:)` through the function's variadic arguments.

### Check

```sh
# Exactly the lookups below, one per level; no other bundle reads or NSLocalizedString calls.
grep -rn "func CYLMenuLocalizedString\|func CYLExampleLocalizedString\|func CYLDemoLocalizedString\|func CYLTagEditorLocalizedString" \
  CollectionViewClassifyMenu Example Example-Swift
grep -rn "NSLocalizedString(" CollectionViewClassifyMenu Example Example-Swift --include=*.m --include=*.swift
```

### Swift and the core

`CYLMenuLocalizedString(key, comment)` is a function-like macro, which Swift cannot call. Like CYLTabBarController's
`CYLLocalizedString`, the core also declares a C function, `CYLMenuLocalizedStringForKey`, imported into Swift as
`CYLMenuLocalizedString(_:)` (`NS_SWIFT_NAME`). Both read the same bundle; tests check both
(`testCoreLookupIsCallableFromSwift`, `testCoreAndDemoLookupsReadTheirOwnBundles`). Core images go through
`CYLMenuImage(name)`, never `[UIImage imageNamed:]` or the bundle.

Since the core moved to Swift (2026-11-14, step 10 of `docs/Swift-Migration.md`) the macros and the C function are
gone: the core's lookup is the Swift function `CYLMenuLocalizedString(_:)` (in `CYLMenuResources.swift`), images go
through `CYLMenuResources.image(named:)`, and Objective-C (the core's tests) calls
`+[CYLMenuResources localizedStringForKey:]` and `+imageNamed:`. The check above looks for
`func CYLMenuLocalizedString` instead of `define CYLMenuLocalizedString`.

## No user-facing text in code

From CYLTabBarController's "No Chinese text in code" rule: every literal a user sees or hears (titles, placeholders,
alerts, accessibility labels, values and hints) goes through its level's lookup; values are formatted with
`[NSString stringWithFormat:]` / `String(format:)`. Exceptions: keys stored in tables and looked up later, resource
identifiers (image or file names), sample data loaded as data, and tests. Never highlight part of a localized text
by a fixed range: find the localized part with `rangeOfString:` (as `CYLMainViewController` does for "两行").

```sh
# Chinese literals outside lookups, comments and tests (review each hit):
python3 - <<'PY'
import re, pathlib
for p in pathlib.Path('.').rglob('*'):
    if p.suffix not in ('.m', '.swift') or 'Pods' in p.parts or 'Tests' in str(p):
        continue
    for i, line in enumerate(p.read_text(errors='ignore').splitlines(), 1):
        code = line.split('//')[0]
        if re.search(r'"[^"]*[\u4e00-\u9fff]', code) and not re.search(r'Localized(String)?\w*\(', code):
            print(f'{p}:{i}: {line.strip()}')
PY
```

### Known gaps

- `CYLDemoDataSource.swift` (shared by the demo app and `Example/CYLMenuExample`, which have different bundles)
  keeps its sample sections ("全部", "地区过滤", "菜品过滤") as Chinese sample data; so does the `TagCollectionView`
  demo's tag data. Localize them through a lookup both apps can reach if they become real UI text.
