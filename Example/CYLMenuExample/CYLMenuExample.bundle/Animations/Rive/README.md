# Rive files

- `button.riv`, `check.riv`, `confetti.riv`, `house.riv`, `icons.riv`, `menu_button.riv`, `shapes.riv`:
  copied from CYLTabBarController (`feat/cross-platform-components`), Example-SwiftUI-Rive.
- `truck.riv`: [rive-app/rive-ios](https://github.com/rive-app/rive-ios) at
  `454ad8908c4f800910d424a8e27c808a0496f163`, `Example-iOS/Assets/truck.riv` (MIT License,
  `LICENSE-rive-ios.txt`). Played through the legacy runtime (`legacy` option), as Rive's
  SimpleAnimation example plays it. It replaces `confetti.riv` in the demo: the confetti only
  draws while its explosion plays, so its tag looked empty at rest.

## Modified files

- `truck.riv` (2026-11-12): the artboard's fill, named `Background` (`#ffeb3a60`, red), drew a
  rectangle behind the truck on its tag. Its alpha is set to 0 (one byte, offset 55); nothing else
  changed. Same fix as CYLTableViewPlaceHolder's `CYLRefreshIcon.riv`
  ([PR #22](https://github.com/ChenYilong/CYLTableViewPlaceHolder/pull/22)); the MIT License allows it.
  SHA-256 before: `af37da1ba63af80a7cbbfeed520acdb070b547f2fdff2e1d37c2b3e0d8b2714b`;
  after: `c961c6c4853823ab058f7e114f2e3f3d6d7c9d68844a0e2e971daa2f1fa8b131`.
- Checked and unchanged: `button.riv`, `menu_button.riv` and `shapes.riv` have a dark artboard fill
  that is switched off (`isVisible` 0); `check.riv`'s artboard fill is fully transparent; `icons.riv`'s
  tab icon artboards and `confetti.riv` have no background fill.
- `house.riv` draws its own sky (`Rectangle-6`, a purple gradient) and a grey artboard fill, so its tag
  shows a square scene. It is not changed: it comes from the Design+Code course download, which has no
  license file, and the exception below needs a license that allows modification.
