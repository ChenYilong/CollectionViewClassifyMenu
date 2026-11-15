# React Native example on HarmonyOS NEXT

The pages of `../example` (Tags with speed, Loop and Play all; Classify on the shared database; the Post page of the
raised plus button) on React Native for OpenHarmony (RNOH) 0.86.1, which needs React Native 0.86.3: the iOS/Android
example uses 0.88, so this is its own small app. The tab bar is CYLTabBarController's HarmonyOS library, built from
`harmony/entry/src/main/resources/rawfile/cyl_tabbar_configuration.json`; each page is a React Native surface. `CylTagListView` is an ArkTS
component here (`harmony/entry/src/main/ets/CylTagListRNView.ets`) over the core's `CYLTagListView`
(`harmony/classifymenu`), wired through the glue that `codegen-harmony` generates from the library's spec.

```sh
npm install --legacy-peer-deps
(cd harmony && ohpm install --all)
sh scripts/setup.sh            # the library, the Tags page, Lottie rawfiles, codegen, the JS bundle; Node 20+
cd harmony && node "$DEVECO/tools/hvigor/bin/hvigorw.js" assembleHap --no-daemon
hdc install -r entry/build/default/outputs/default/entry-default-unsigned.hap
hdc shell aa start -a EntryAbility -b com.cyl.classifymenu.rn
```

`DEVECO` is `/Applications/DevEco-Studio.app/Contents` (also set `DEVECO_SDK_HOME=$DEVECO/sdk`). Unsigned HAPs
install on the emulator. The app loads only its bundled `bundle.harmony.js` (no Metro server). Details and results:
`docs/cross-platform.md` (TODO summary).
