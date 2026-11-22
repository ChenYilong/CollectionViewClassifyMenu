@AGENTS.md

## [behavioral] Behavioral guidelines: read in full first

You must read [docs/instructions/behavioral.md](docs/instructions/behavioral.md) in full, every line, before any task.

Rules are filed under tag headings, as in AGENTS.md (`## [<tag>] <title>`); the details of each tag are in
`docs/instructions/<tag>.md`.

## [git] Read the git rules before any git operation

Before any git operation (commit, push, merge, branch, rebase, reset, `gh pr`), read [docs/instructions/git.md](docs/instructions/git.md) in full, every
line, then run the operation.

## [harmonyos] HarmonyOS x86_64 emulator

When `hdc install` fails with code 9568347 ("the Abi type supported by the device does not match"), the default HAP's
Rive and PAG libraries are arm64-only. Install the `emulator` target's HAP
(`entry/build/default/outputs/emulator/entry-emulator-unsigned.hap`, built by `harmony/scripts/build.sh`) or use
`harmony/cylanimateditem/tools/cyl_hap_x86_64.py install`; `harmony/scripts/ui-test.sh` picks the emulator target by
itself. CYLTabBarController's `CYLAnimatedItemView` shows PAG and Rive items as still images there. PAG and Rive playback
still needs an arm64 emulator or a device. Full rule: [docs/instructions/harmonyos.md](docs/instructions/harmonyos.md).

## [harmonyos] Rive and PAG tests that need arm64

Plan 1 adds x86_64 builds of the Rive and PAG native libraries (from GitHub) in CYLTabBarController's
`CYLAnimatedItemView`, used only when the running system is x86_64 and, until verified, only in debug builds. First it
must compile and not crash or affect other features, then Rive and PAG must play. Removing the debug guard needs the
owner's approval. If plan 1 fails, plan 2: forward the tests to the macOS (arm64) session. Full rule: same file.

## [instructions] Keeping the instructions organized

AGENTS.md stays at 200 lines or fewer, every rule under a visible `## [<tag>] <title>` heading; overflow goes into
`docs/instructions/<tag>.md`, linked by relative path. Details: `.agents/skills/cyl-instructions/SKILL.md`.
