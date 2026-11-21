@AGENTS.md

HarmonyOS x86_64 emulator: when `hdc install` fails with code 9568347 ("the Abi type supported by the device does not
match"), the default HAP's Rive and PAG libraries are arm64-only. Install the `emulator` target's HAP
(`entry/build/default/outputs/emulator/entry-emulator-unsigned.hap`, built by `harmony/scripts/build.sh`) or use
`harmony/cylanimateditem/tools/cyl_hap_x86_64.py install`; `harmony/scripts/ui-test.sh` picks the emulator target by
itself. CYLTabBarController's `CYLAnimatedItemView` shows PAG and Rive items as still images there. PAG and Rive playback
still needs an arm64 emulator or a device. Full rule: AGENTS.md, "HarmonyOS: the HAP will not install on an x86_64
emulator (arm64-only Rive and PAG)".
