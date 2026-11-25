# macOS-only: Xcode and CocoaPods

Tag: `macos`. The full rules of this tag. [AGENTS.md](../../AGENTS.md) keeps the short form under the heading
`[macos] macOS-only: Xcode and CocoaPods`; read this file when a task touches the tag. Moved from AGENTS.md word for word on 2026-11-22, when
AGENTS.md was limited to 200 lines; section names are unchanged, so a reference such as AGENTS.md "Xcode and CocoaPods" now
means the section of that name here.


## Xcode and CocoaPods

- The minimum supported iOS version is 15.0. Keep the project and podspec
  consistent.
- Preserve `objectVersion = 46` and `compatibilityVersion = "Xcode 3.2"` for
  compatibility with the reference project; do not introduce folder-synced
  groups without verifying supported Xcode versions.
- Do not commit Xcode user state, derived data or generated dependencies.
- Validate the podspec with `pod lib lint CollectionViewClassifyMenu.podspec`
  and build the affected target. Report any warnings or checks that could not
  be completed.
- Project-specific Xcode and verification guidance lives in
  `.agents/skills/cyl-xcode-compat/` and `.agents/skills/cyl-verify/`.
- Before you run the iOS simulator, read "Simulators and emulators: stop them when the work is done" in
  [sessions.md](sessions.md#simulators-and-emulators-stop-them-when-the-work-is-done): after the tests or screenshots, terminate the app and shut your own simulator down.

