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
- `house.riv` (2026-11-12, at the maintainer's request): its sky (`Rectangle-6`, a purple radial
  gradient, stops `#ffe0c0f9` and `#ff808efb`) and its artboard fill (`#ff5d5d5d`) drew a square scene
  behind the house on its tag. The alpha of these three colors is set to 0 (three bytes, offsets 8770,
  8780 and 8795); nothing else changed. The ground under the house (`Rectangle-6-Copy`) is part of the
  drawing and stays. The file comes from the Design+Code course download, which has no license file:
  the copyright stays with its author, and the change was made because the maintainer decided so.
  SHA-256 before: `632474611244a3ea9cdf455719624bcc0e6684de09f734ade923fe474ba94039`;
  after: `2e06b33ce5ff2d8863053b0dff1fcf2f62b537cc51e38c48e11a01b927e28c65`.
