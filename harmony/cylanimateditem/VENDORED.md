# cylanimateditem (vendored)

CYLTabBarController's shared animated icon + title component for HarmonyOS NEXT (`CYLAnimatedItemView`), copied
unmodified so that `@cyl/classifymenu` can use it while it is not published to ohpm. Its guide,
`docs/Animated-Item.md` in CYLTabBarController, says an unpublished HarmonyOS module is taken by commit: copied, or
depended on with `file:`, at a pinned commit.

| Field | Value |
|:---|:---|
| Source repository | <https://github.com/ChenYilong/CYLTabBarController> |
| Commit | [`6f563ef4f34bcde96f10022d3f0d5f949a7c3a62`](https://github.com/ChenYilong/CYLTabBarController/tree/6f563ef4f34bcde96f10022d3f0d5f949a7c3a62/CrossPlatform/harmonyos-cyltabbar/cylanimateditem) (2026-11-25; was `230b5266`, `dea0951e` on the PR #36 line and `b3c87fd1` on the engine line, then `618ac11a`, `62715829`, `882ece17`, `022da59a`, `c8fee654`, `143fadff`, `c4a1f8fd`, `7755741d`, `43c9eaa2`, `db883bfa`) |
| Source path | `CrossPlatform/harmonyos-cyltabbar/cylanimateditem` |
| License | MIT, CYLTabBarController's own: [`LICENSE`](LICENSE), kept as it ships upstream |
| Changes | None. Only this file (`VENDORED.md`) was added; `README.md` is upstream's own (since `62715829`). |

## How it is used

- `harmony/build-profile.json5` registers it as the module `cylanimateditem` (as CYLTabBarController's HarmonyOS
  project does), and `harmony/classifymenu/oh-package.json5` depends on it with `"cylanimateditem":
  "file:../cylanimateditem"`.
- It depends on no animation library. `@cyl/classifymenu` draws a tag's animated icon with `CYLAnimatedItemView`
  (`CYLTagAnimatedIcon` in `classifymenu/src/main/ets/components/CYLTagAnimation.ets`); the app registers the engines it
  plays (`CYLAnimatedItemLottie.register()` and its siblings, one call each). A registered engine brings its own view, so
  the host registers no `CYLTagAnimationBuilder`; that builder is only for a custom type no engine plays. The example
  registers the engines in `entry/src/main/ets/animation/CYLExampleAnimationViews.ets`.
- `src/main/ets/CYLAnimatedItemView.ets` imports `BuildProfile` from the module root: hvigor generates that file when
  it builds the module.

## Updating

Copy the folder from a newer commit (`git archive <sha> CrossPlatform/harmonyos-cyltabbar/cylanimateditem`), keep this
file, and update the commit above. Do not edit the copied files: change them in CYLTabBarController and copy again.
