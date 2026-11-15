# HarmonyOS NEXT: CYLTagListView

- `classifymenu/`: the ArkTS library (HAR): `CYLTagListView`, its JSON configuration, Lottie icons
  (`@ohos/lottie` 2.0.38), `animationSpeed`, `animationLoops` and `CYLTagListController.playAll()`.
- `entry/`: the example (Tags with the playback controls, Classify on the shared `cyl_places.sqlite`).
- Build, tests and screenshots: `docs/android.md` (HarmonyOS NEXT).

## Bundled animation files

`entry/src/main/resources/rawfile/tab_*.json` are unmodified copies of CYLTabBarController's Lottie tab icons
(<https://github.com/ChenYilong/CYLTabBarController>, commit `4934a0c`, path
`Example/Classes/Other/LottieResources/`; license: CYLTabBarController's MIT license), the same files as the
Flutter and React Native examples.

| File | SHA-256 |
| --- | --- |
| `tab_home_animate.json` | `1cd3f6bcf2c87d38dd86ca1485fd6c9b7c645983241e1017bc4bca0bed9165b7` |
| `tab_me_animate.json` | `a1cc33e064d953af7c567f2fea2f45cc7374d8e35f52855066f83767c976dd6b` |
| `tab_message_animate.json` | `740dce5ae56b9b45902ca58e739e212724541d40dbb666f949a9e363402116db` |
| `tab_search_animate.json` | `81080fc0dc59c37d23b0c59c03a8fe42d63c8c29a93a5facc74c7d75fc345d37` |
