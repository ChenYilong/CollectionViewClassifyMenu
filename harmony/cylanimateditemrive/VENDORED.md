# cylanimateditemrive (vendored)

CYLTabBarController's shared HarmonyOS Rive engine, copied unmodified so that every library of this repository plays
`.riv` files through one implementation: `CYLRiveIcon` (one Rive view with the replay, artboard, end-watch and loop fixes),
`CYLRiveLoopPolicy`, `CYLRiveAnimationBuilder` and `cylRegisterRiveEngine`. Its guide, `docs/Animated-Item.md` in
CYLTabBarController ("Shared HarmonyOS Rive engine"), says an unpublished HarmonyOS module is taken by commit.

| Field | Value |
|:---|:---|
| Source repository | <https://github.com/ChenYilong/CYLTabBarController> |
| Commit | [`564af49537aa7aec39e7f25600422ae4b255f11c`](https://github.com/ChenYilong/CYLTabBarController/tree/564af49537aa7aec39e7f25600422ae4b255f11c/CrossPlatform/harmonyos-cyltabbar/cylanimateditemrive) (2026-11-26; was `ecb853d2`, `dfbe9190`, `284f4230`, `fa95e1aa`, `e014028f`, `98966c43`, `b6e02875`, `991f76cd`, `e5c622fa`, `08343e9f`, `6f563ef4`, `230b5266`, `3074c51d`, first vendored 2026-11-23; `cylanimateditem_rive` depends on it) |
| Source path | `CrossPlatform/harmonyos-cyltabbar/cylanimateditemrive` |
| License | MIT, CYLTabBarController's own: [`LICENSE`](LICENSE), kept as it ships upstream |
| Changes | None. Only this file (`VENDORED.md`) was added; `README.md` is upstream's own. |

## How it is used

- `harmony/build-profile.json5` registers it as the module `cylanimateditemrive`; `harmony/entry/oh-package.json5`
  depends on it with `"cylanimateditemrive": "file:../cylanimateditemrive"`. The core `harmony/classifymenu` does not
  depend on it, nor on `@ohos/rive` (the core stays free of animation libraries); `entry` keeps `@ohos/rive` 1.0.4.
- The example registers it with `cylRegisterRiveEngine(hostContext)` in `cylRegisterExampleAnimationEngines`
  (`entry/src/main/ets/animation/CYLExampleAnimationViews.ets`) and plays every Rive tag with `CYLRiveIcon` in the loop
  policy `WhilePlaying`, so the Loop switch (`animationLoops`) is honored by the shared engine. The example has no Rive
  player of its own.
- It depends on `cylanimateditem` (`file:../cylanimateditem`, vendored next to it) and `@ohos/rive` 1.0.4.

## Updating

Copy the folder from a newer commit (`git archive <sha> CrossPlatform/harmonyos-cyltabbar/cylanimateditemrive`), keep this
file, and update the commit above. Do not edit the copied files: change them in CYLTabBarController and copy again.
