@AGENTS.md

HarmonyOS x86_64 emulator: when `hdc install` fails with code 9568347 ("the Abi type supported by the device does not
match"), the default HAP's Rive and PAG libraries are arm64-only. Install the `emulator` target's HAP
(`entry/build/default/outputs/emulator/entry-emulator-unsigned.hap`, built by `harmony/scripts/build.sh`) or use
`harmony/cylanimateditem/tools/cyl_hap_x86_64.py install`; `harmony/scripts/ui-test.sh` picks the emulator target by
itself. CYLTabBarController's `CYLAnimatedItemView` shows PAG and Rive items as still images there. PAG and Rive playback
still needs an arm64 emulator or a device. Full rule: AGENTS.md, "HarmonyOS: the HAP will not install on an x86_64
emulator (arm64-only Rive and PAG)".

Rive and PAG tests that need arm64: plan 1 adds x86_64 builds of the Rive and PAG native libraries (from GitHub) in
CYLTabBarController's `CYLAnimatedItemView`, used only when the running system is x86_64 and, until verified, only in
debug builds. First it must compile and not crash or affect other features, then Rive and PAG must play. Removing the
debug guard needs the owner's approval. If plan 1 fails, plan 2: forward the tests to the macOS (arm64) session. Full
rule: AGENTS.md, same section.
