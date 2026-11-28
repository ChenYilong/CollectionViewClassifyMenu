# Earlier notes on the iOS core (2026-11-27)

Notes from the first pass over the iOS core; the coverage lines were updated on 2026-11-29. The technical claims were
not verified again.

CollectionViewClassifyMenu (repo dir `CollectionViewClassifyMenu/`, owner ChenYilong) is a pure-Swift iOS 15+ core (all public API `@objc`) ported to Android/HarmonyOS/Flutter/RN/WeChat mini program. Full read of the iOS core done 2026-11-27 (scope: iOS core and docs; Example/ and the ports were not read in that pass; read 2026-11-29).

Non-obvious facts:
- `CYLTagListView` (TagList/CYLTagListView.swift, ~3.9k lines) is the real component; `CYLClassifyMenuViewController` / `CYLMultipleFilterController` / `CYLTagView` (TagCollectionView/) are legacy views that keep Objective-C names + NSArray state because the root Objective-C tests read them by KVC.
- Every "icon + title" view is `CYLTagButton`, a subclass of CYLTabBarController's `CYLAnimatedItemView` (pod `CYLAnimatedItem`, pinned by commit `4d0e00ae…` in Podfiles and Package.swift). Colors go through the item's precedence chain (explicit vs built-in, `setSubclassTitleColor`, color roles) — appearance colors are null_resettable with `explicit*` accessors.
- Style objects are copied on set (`style = …` copies; mutate then reassign). Per-section/per-item styles must return the same object while unchanged (identity caches with `===`).
- Default section look is `.insetGrouped` card (CYLTagListLayout decoration view); presets tagCloud/tagContainer/gridStyle/wordPicker/classify/filter set `.plain`. Unset backgroundColor resolves to grouped background.
- Column model: column(atWidth) → boardColumn → tagColumn; all widths/rows/fold decisions come from tagColumn. Header widths via `CYLTagListHeaderRoom`.
- Fold: `foldControl` (position none/footer/headerTrailing/headerLeading/tail) and legacy `foldStyle` set each other; `.tail` = inline `CYLTagFoldCell` that steals room from last visible row. Editing disables folding.
- Configuration init: `CYLTagListView(configuration:)`/`(configurationFile:)`; JSON/plist native, other formats via CYLTabBarController's parser found at runtime by NSClassFromString.
- Long press = pluggable `CYLTagLongPressAction` (default first([reorder, report])).
- Strings: core uses `CYLMenuLocalizedString` over `CYLClassifyMenuResources.bundle` (en/zh-Hans/zh-Hant); each example has its own lookup + bundle, keys = Chinese source text.
- Demo-app files live inside the core folder but are excluded by name in podspec and Package.swift (CYLDemoDataSource, CYLFilterDemoViewController, CYLMainViewController, CYLAppDelegate, CYLDemoLocalization, CYLDBManager).

Read coverage of the 2026-11-27 /learn-codebase pass: read in full = README, AGENTS/CLAUDE.md, docs/instructions/*, all core Swift (CollectionViewClassifyMenu/Class), podspec, Package.swift, TagCollectionView, Example-Swift app+tests, Example-Shared/TestSupport, root tests; docs/component-architecture.md (all), tag-long-press-action, tag-liquid-glass-platforms, tag-gesture-migration, example-layer-fixes, example-demo-rules (2nd pass, same day). Key facts from those: tag-gesture-migration plans moving long-press/tap into CYLAnimatedItemView and deleting mini-program cyl-tag-cloud (owner decided); Android glass needs CYLTagListView.backdropSource (non-ancestor view). NOT read (ran out of context): Swift-Coding-Standard, instructions.md, Bilingual-Documentation, cross-platform, Swift-Migration, tag-*.md, issue-progress, harmony/android docs, generated api tables), scripts/, .github/workflows, Example/ (15k lines), all ports. UPDATE 2026-11-29: Example/, all ports, scripts and workflows have since been read (partly without imports/[CN] lines); see 09-findings.md and 10-coverage-and-method.md.

**Why:** saves re-reading ~17k lines next session.
**How to apply:** start from CYLTagListView for any tag-list change; check the port parity docs (docs/android-ios-api.md, harmony/parity-map.json) when changing public API.
