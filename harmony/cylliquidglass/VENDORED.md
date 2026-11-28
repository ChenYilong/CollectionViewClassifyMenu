# cylliquidglass (vendored)

CYLTabBarController's Liquid Glass base library for HarmonyOS NEXT (`CYLLiquidGlass.isActive()`, the component
`CYLLiquidGlassView`, the glass material and capsule the tab bar draws), copied unmodified so that `@cyl/classifymenu`
can draw the Liquid Glass tag background (`CYLTagBackgroundStyle.liquidGlass`) while it is not published to ohpm.
Like `cylanimateditem`, an unpublished HarmonyOS module is taken by commit.

| Field | Value |
|:---|:---|
| Source repository | <https://github.com/ChenYilong/CYLTabBarController> |
| Commit | [`8fa168fa3554bf11bc6583a4ee356068f60ac785`](https://github.com/ChenYilong/CYLTabBarController/tree/8fa168fa3554bf11bc6583a4ee356068f60ac785/CrossPlatform/harmonyos-cyltabbar/cylliquidglass) |
| Source path | `CrossPlatform/harmonyos-cyltabbar/cylliquidglass` |
| License | MIT, CYLTabBarController's own: [`LICENSE`](LICENSE), kept as it ships upstream |
| Changes | None. Only this file (`VENDORED.md`) was added. |

## How it is used

- `harmony/build-profile.json5` registers it as the module `cylliquidglass`, and `harmony/classifymenu/oh-package.json5`
  depends on it with `"cylliquidglass": "file:../cylliquidglass"`.
- `CYLTagButton` draws a `CYLLiquidGlassView` behind its content while `style.resolvedBackgroundStyle()` is `liquidGlass`
  (`CYLLiquidGlass.isActive()`), tinted with the state's background color.

## Updating

Copy the folder from a newer commit (`git archive <sha> CrossPlatform/harmonyos-cyltabbar/cylliquidglass`), keep this
file, and update the commit above. Do not edit the copied files: change them in CYLTabBarController and copy again.
