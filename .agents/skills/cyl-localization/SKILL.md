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
