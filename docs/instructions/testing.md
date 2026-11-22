# Testing, parity and CI

Tag: `testing`. The full rules of this tag. [AGENTS.md](../../AGENTS.md) keeps the short form under the heading
`[testing] Testing, parity and CI`; read this file when a task touches the tag. Moved from AGENTS.md word for word on 2026-11-22, when
AGENTS.md was limited to 200 lines; section names are unchanged, so a reference such as AGENTS.md "Example tests" now
means the section of that name here.


## Example tests

- One test case class per feature, one file each (`CYLTagListSelectionTests`, `CYLReviewFilterScenarioTests`, …);
  never grow a single file that tests everything.
- Shared capabilities are protocols with default implementations in `Example-Shared/TestSupport/`, compiled into
  the test targets of `Example/` and `Example-Swift/`: `CYLWindowHosting` (windows in the app's scene),
  `CYLTagListInspecting` (cells, headers, footers, fold controls, taps), `CYLAccessibilityQuerying` (find views by
  identifier and label), `CYLScreenshotCapturing`, `CYLConditionWaiting` and `CYLViewOverlapInspecting` (the views
  a view covers in its window). Each test target has one small base class (`CYLMenuExampleTestCase`,
  `CYLTagEditorTestCase`) for its language and its screens, and its fixtures in `Support/`.
- Tests reach private views of the core only through `CYLTagListProbe` (key-value coding in one place).
- Tests record screenshots of the states they check with `captureScreenshot(of:named:)` / `captureScreen(named:)`
  (names start with `test-`); `scripts/unit-tests.sh` writes them to `build/test-screenshots/<suite>/`.


## Parity tables and the score loop

- When a feature set must be compared with another platform, another
  component or an upstream project (for example the Android core against the
  iOS core), keep a three-column table in the most related document in
  `docs/` (insert it when the document exists, create the document when it does
  not): column 1 is the source API or feature, column 2 its description,
  column 3 the counterpart API or feature, `TODO` by default.
- Score: full marks (100) when column 3 has no `TODO`, 0 when every row is
  `TODO`, proportional in between (rows with a counterpart / all rows x 100).
  Write the score above the table and keep a score history.
- Loop until 100:
  1. Search the existing code for every `TODO` row and fill in the matching
     API or feature (a platform type maps to the platform's own type, e.g. an
     Android `CYLRect` to iOS `CGRect`).
  2. Score.
  3. Work through the remaining `TODO` rows one by one: implement the missing
     API or feature, and replace the `TODO` with the implementation.
  4. Score again, and repeat from step 1.
- Implement in the core first (AGENTS.md "Fix issues in the core first"): same
  logic, names and behavior as the source platform, so both cores stay
  consistent; then show the usage in the example, ported one for one from the
  source platform's example (for example drag to reorder, or a tag with an
  icon, a title and an always-shown delete icon whose deletion updates the data
  source and relayouts the list).
- At 100, make the reverse table (column 1 the other platform's API) with its
  own score, and run the same loop.
- Generated tables (for example `docs/android-ios-api.md` from
  `android/scripts/android_public_api.py`, `docs/android-api.md` from
  `android/scripts/ios_public_api.py`) are never edited by hand: change the
  maps or the code, then regenerate.


## CI/CD and Example screenshots

- CI follows CYLTabBarController's `.github/workflows/ios.yml`; the scripts
  live in `scripts/` (see `.agents/skills/cyl-verify/`).
- Runner environment (GitHub CI/CD): the iOS jobs run on **macOS 26** by
  default (`runs-on: ${{ vars.MACOS_RUNNER || 'macos-26' }}`, the image's
  default Xcode 26.x; the repository variable `MACOS_RUNNER` selects another
  runner without editing the workflow). Before changing a runner, an Xcode
  version or a build setting that depends on them, always read
  CYLTabBarController's workflow first to confirm the environment:
  <https://github.com/ChenYilong/CYLTabBarController/blob/master/.github/workflows/ios.yml>,
  and the same file at its newest commit (see "CYLTabBarController reference
  and dependency"). Keep `ios.yml` on the runner they use.
- Local runs ignore that runner rule. A local run does not go through GitHub
  CI/CD: it uses the developer's Mac directly, with Xcode and the iOS
  Simulator started on that machine (`scripts/unit-tests.sh`,
  `scripts/example-screenshots.sh`, `xcodebuild`, `xcrun simctl`). Assume
  **macOS 27 with Xcode 27** there unless `sw_vers` / `xcodebuild -version`
  say otherwise, and pick a simulator that this Xcode provides
  (`scripts/simulator-id.sh`).
- Every CI run that builds code must provide screenshots of the Example app
  (`Example screenshots` job in `ios.yml`: the `example-screenshots` artifact,
  and a copy on the `ci-screenshots` branch under `<branch>/<commit>/`, which
  can be read through the GitHub API when artifact storage is not reachable). When
  reporting such a run, look at the screenshots and show them to the user,
  checking that each README scenario renders as expected.
- If the screenshots are missing or cannot be obtained, first find out why and
  change the CI (workflow or `scripts/example-screenshots.sh`) so that they are
  produced. If that is still not possible, explain the exact reason (for
  example the runner, the simulator or artifact download) to the user.

- **Screenshots: where they go.** Every screenshot, from CI/CD and from local builds alike, is saved in the
  Git repository and shown in the related document in `docs/` (images in `docs/assets/`); when no document fits,
  create one (the default is `docs/screenshots.md`). At the right moment, when you judge that the result looks as
  expected, update `README.md` with the newest images, in the matching section (create it if missing).
- **Screenshots: labels.** Every screenshot shown in `docs/` or `README.md` is labeled with:
  - the platform it ran on: iOS, Android, Flutter, React Native, HarmonyOS or Mini Program;
  - the environment: the operating system version, the simulator / emulator version, and the platform's SDK version
    (iOS, Android, Flutter, React Native, HarmonyOS or Mini Program SDK);
  - this repository's version number or commit URL;
  - the current time (when it was taken).
- **Screenshots: quality.** Use clear original images; never downscale or recompress them.
- **Screenshots: key moments.** Update the README images at key moments: for example when a `TODO` keyword or a
  `Linux` keyword can be removed, when a pull request can be merged, or when you judge the result as expected, with
  no bug and no open issue.
- **Screenshots: crop to the detail.** Screenshots in `README.md` show the key details, cropped; do not use
  full-screen captures unless necessary. Prefer one stitched image that shows several key details.
- **Screenshots: stitching layout.** Stitch in this order of preference: (1) stacked vertically, top to bottom, which
  reads best on a phone; (2) two columns, several rows; (3) last resort, side by side in one row, at most three
  columns per row. Correction (2026-11-12): the original request said both "prefer a horizontal layout" and "a horizontal stitch is the worst", which contradict each other; the user corrected it to vertical first.
- **Screenshots: stitching layout, update (2026-11-18).** Prompt (verbatim): "截图除了 优先选用竖版排列风格。优先两列，多行。且给拼接好的图增加header，footer，header，footer不能与截图区域重叠 覆盖，标注关键信息：关键信息也是英文，测试模拟器平台，模拟器系统版本，操作系统版本，ide 版本，以及测试目的等等。以附带的截图为例。提取截图的附带信息以及风格 完善我的描述规则。" This replaces the order above:
  - The stitched image is portrait (taller than wide). Default: two columns and as many rows as needed, filled left
    to right, then top to bottom, in step or time order. Use one column only for a single panel, or when two columns
    would make the image wider than tall (wide crops). Never more than two columns.
  - Every panel has the same size (the same crop rectangle), keeps its original pixels (no scaling) and shows whole
    elements: never cut through a row of controls.
  - Tool: `scripts/stitch-screenshots.swift`; details and checklist: `.agents/skills/cyl-screenshots/SKILL.md`.
- **Screenshots: header and footer (2026-11-18).** Every stitched image has a header band above the panels, a footer
  band below them and a caption band above each panel. No text is ever drawn on a screenshot; header, footer and
  captions never overlap or cover a panel. White background; a thin gray rule under the header and above the footer.
  All text is in English.
  - Header (red `#FF3B30`, bold): line 1 `Purpose:` what the test checks and the expected result, with the commit of
    the change under test; line 2 `Platform:` the simulator or emulator platform and device model, the simulator OS
    version, then `| Host:` the host operating system version, then `| IDE:` the IDE version.
  - Panel caption (red, bold, above the panel): step number, the state or action, the time offset from the first
    panel, the screen or launch argument, the measurement when there is one.
  - Footer (dark gray, regular): `Result:` the measured outcome (for example changed pixels); `Versions:` this
    repository's branch and commit, the dependency commits (CYLTabBarController) and engine versions; `Taken:` the
    local date and time with the time zone, then `| Stitched by` the script.
  - Fields per platform: iOS: Simulator device, iOS version, Xcode version, macOS version. Android: emulator (AVD)
    and API level, Android Studio or Gradle and JDK, host OS. HarmonyOS: emulator name, HarmonyOS version, DevEco
    Studio version, host OS. Mini Program: WeChat DevTools version and base library version, host OS. Flutter and
    React Native: the Flutter or React Native version plus the fields of the platform it ran on.
  - Example and its lessons: `docs/assets/ios-rive-rest.png` (first version: one red bold header with the platform,
    simulator, Xcode, dependency commit, branch, date and purpose; a red bold caption above each panel in its own
    band; but no host OS, everything crammed into the header, one column, a panel cut through the Shapes row) and its
    redo by these rules, `docs/assets/ios-rive-rest-then-play-grid.png`.
- **Screenshots: columns, update (2026-11-18, later).** Prompt (verbatim): "更新截图规则，优选一列多行 如果一列拼接后长度超过普通手机的一屏幕 则两列多行" This replaces the column order of the update above:
  one column first, panels top to bottom; when the one-column image (header and footer included) would be longer
  than one screen of an ordinary phone, i.e. taller than 19.5:9 (height > 2.17 x width, the shape of an iPhone 17 Pro
  screen, 1206 x 2622 px), use two columns and several rows, filled left to right, then top to bottom. Never more
  than two columns.
  `scripts/stitch-screenshots.swift` chooses this way by default (`--columns auto`). Examples: one column,
  `docs/assets/ios-rive-rest-one-column.png` (two cropped panels); two columns,
  `docs/assets/ios-rive-rest-then-play-grid.png` (four full screens).

- **Screenshots: enforced (2026-11-18).** Prompt (verbatim): "检查为什么没有应用新增的截图Label规范，并强化该策略保证以后截图必须遵循该规范，避免再出现该问题。" Why
  they were missed (Windows session, four images committed 09:54-11:03: `miniprogram-devtools-gif-stills-play-all.png`,
  `miniprogram-devtools-rive-rest-until-played-dcbfdec6.png`, `android-rive-menu-stuck-dcbfdec6.png`,
  `android-rive-menu-stuck-ad3dca0e.png`): (1) the header / footer rules were committed by another session at 11:06 and
  11:10, while that session ran; instructions are read once at session start and nothing told it to read them again;
  (2) the older rules ("labels", 2026-11-12: platform, environment, repository version, time; "quality": no scaling)
  were broken too, because on Windows there was no stitch tool (the Swift one needs macOS) and the images were composed
  by hand (PIL): downscaled, captions only, no environment, commit or time; (3) nothing checked an image before it was
  committed. All four are restitched. So:
  - **Re-read before every screenshot.** Before taking or stitching a screenshot, `git pull` and read
    `.agents/skills/cyl-screenshots/SKILL.md` again: the rules can change while a session runs.
  - **Only the stitch tools make a screenshot for `docs/` or `README.md`:** `scripts/stitch-screenshots.py` (any host,
    Python with Pillow) or `scripts/stitch-screenshots.swift` (macOS), same arguments. Never compose, crop-and-paste,
    annotate or resize an image by hand or with an ad-hoc script. A single raw screen is stitched too (one panel).
  - **The tools refuse an incomplete label:** the header needs `Purpose:`, `Platform:`, `Host:` and `IDE:`, the footer
    `Result:`, `Versions:` and `Taken:`, every panel a caption. They write the label into the PNG.
  - **Checked before every commit:** `scripts/check-screenshots.py` (run by `bash scripts/check-branch-pr.sh`, exit 3
    when a staged screenshot has no label). A failing check is fixed by restitching, never by skipping it. Not checked
    in CI (2026-11-18, prompt verbatim: "Remove label CI screenshots from ci"; the workflow
    `.github/workflows/screenshot-labels.yml` is removed, as in CYLTabBarController `70064275`). Only images that are not screenshots or that a script
    regenerates as a set go into `scripts/screenshot-check-exempt.txt`, with the reason.
