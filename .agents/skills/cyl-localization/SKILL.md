---
name: cyl-localization
description: Internationalization and localization rules and checks for CollectionViewClassifyMenu and its Example.
---

# Localization

## Structure

| Module | Bundle | Sources | Lookup macro |
| --- | --- | --- | --- |
| Core (pod) | `CYLClassifyMenuResources.bundle` (also holds images and XIBs) | `CollectionViewClassifyMenu/Resources/Localization/<language>.lproj/CYLClassifyMenu.strings` | `CYLMenuLocalizedString(key, comment)` |
| Example | `CYLMenuExample.bundle` | `Example/CYLMenuExample/CYLMenuExample.bundle/<language>.lproj/Localizable.strings` | `CYLExampleLocalizedString(key)` |
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
2. **An example lookup macro per example.** Each example has its own macro over its own example-level bundle:
   `CYLExampleLocalizedString` over `CYLMenuExample.bundle`. Swift has no macros, so a Swift example has one global
   function in that role: `CYLTagEditorLocalizedString` over `CYLTagEditorExample.bundle`.
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
grep -rn "define CYLMenuLocalizedString\|define CYLExampleLocalizedString\|func CYLTagEditorLocalizedString" \
  CollectionViewClassifyMenu Example Example-Swift
grep -rn "NSLocalizedString(" CollectionViewClassifyMenu Example Example-Swift --include=*.m --include=*.swift
```

### Known gap

`CYLMenuLocalizedString(key, comment)` is a function-like macro, which Swift cannot call. CYLTabBarController
declares its lookup as a C function (`FOUNDATION_EXTERN NSString *CYLLocalizedString(NSString *key)`), usable from
both languages. Add a core function Swift can call (keeping the macro for Objective-C) before Swift code needs core
strings directly; Swift examples reach them today through `CYLMenuResources.localizedString(forKey:)`.
