@AGENTS.md

HarmonyOS: when `hdc install` fails with code 9568347 ("the Abi type supported by the device does not match"), the HAP's
Rive and PAG libraries are arm64-only and the emulator is x86_64. Follow AGENTS.md, "HarmonyOS: the HAP will not install
on an x86_64 emulator (arm64-only Rive and PAG)": the fix belongs in CYLTabBarController's `CYLAnimatedItemView`
component (an ABI gate, lazy Rive / PAG engines and an `x86_64Emulator` product), so every example and library that
depends on it can be fully tested on an x86_64 emulator. Until it lands, run Rive and PAG checks on an arm64 emulator or
a device, and never change the default build to make the HAP install.
