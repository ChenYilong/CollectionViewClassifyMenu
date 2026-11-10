# Rive files

- `button.riv`, `check.riv`, `confetti.riv`, `house.riv`, `icons.riv`, `menu_button.riv`, `shapes.riv`:
  copied from CYLTabBarController (`feat/cross-platform-components`), Example-SwiftUI-Rive.
- `truck.riv`: [rive-app/rive-ios](https://github.com/rive-app/rive-ios) at
  `454ad8908c4f800910d424a8e27c808a0496f163`, `Example-iOS/Assets/truck.riv` (MIT License,
  `LICENSE-rive-ios.txt`). Played through the legacy runtime (`legacy` option), as Rive's
  SimpleAnimation example plays it. It replaces `confetti.riv` in the demo: the confetti only
  draws while its explosion plays, so its tag looked empty at rest.
