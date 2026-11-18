# cylanimateditem (vendored)

CYLTabBarController's shared animated icon + title component for HarmonyOS NEXT (`CYLAnimatedItemView`), copied
unmodified so that `@cyl/classifymenu` can use it while it is not published to ohpm. Its guide,
`docs/Animated-Item.md` in CYLTabBarController, says an unpublished HarmonyOS module is taken by commit: copied, or
depended on with `file:`, at a pinned commit.

| Field | Value |
|:---|:---|
| Source repository | <https://github.com/ChenYilong/CYLTabBarController> |
| Commit | [`776b4635791b2197782b4db1b07126c4a16d8d9d`](https://github.com/ChenYilong/CYLTabBarController/tree/776b4635791b2197782b4db1b07126c4a16d8d9d/CrossPlatform/harmonyos-cyltabbar/cylanimateditem) (2026-11-18; was `4f73209c`) |
| Source path | `CrossPlatform/harmonyos-cyltabbar/cylanimateditem` |
| License | MIT, CYLTabBarController's own: [`LICENSE`](LICENSE), kept as it ships upstream |
| Changes | None. Only this README was added. |

## How it is used

- `harmony/build-profile.json5` registers it as the module `cylanimateditem` (as CYLTabBarController's HarmonyOS
  project does), and `harmony/classifymenu/oh-package.json5` depends on it with `"cylanimateditem":
  "file:../cylanimateditem"`.
- It depends on no animation library. `@cyl/classifymenu` draws a tag's animated icon with `CYLAnimatedItemView`
  (`CYLTagAnimatedIcon` in `classifymenu/src/main/ets/components/CYLTagAnimation.ets`); the app registers the types it
  plays (`CYLAnimatedItemEngines.register('Lottie')` and its siblings) and the views that play them
  (`CYLTagAnimationBuilder.register(wrapBuilder(...))`). The example does both in
  `entry/src/main/ets/animation/CYLExampleAnimationViews.ets`.
- `src/main/ets/CYLAnimatedItemView.ets` imports `BuildProfile` from the module root: hvigor generates that file when
  it builds the module.

## Updating

Copy the folder from a newer commit (`git archive <sha> CrossPlatform/harmonyos-cyltabbar/cylanimateditem`), keep this
README, and update the commit above. Do not edit the copied files: change them in CYLTabBarController and copy again.
