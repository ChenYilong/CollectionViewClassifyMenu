# docs · 文件夹规则

- 本文件夹记录项目文档和 issue 修复进度，继承根目录及项目的指令。
- 修改进度表时保留已有记录，并注明实际验证结果和未完成原因。
- 每次提交 issue 修复后，将该提交地址和重新评估的分数补充到进度表。
- 本文件夹封面为 `docs.base`。
- Task log (English rule, AGENTS.md "Task log in docs/"): before starting any task, add a `TODO` entry to the
  most relevant document here (the general list is in `issue-progress.md`) with the task's detailed context, the
  user's requirements and the user's prompt quoted verbatim; mark it done with the result and evidence when the
  task is finished, so an interrupted task can be resumed from it.
- Screenshots (English rule, AGENTS.md "CI/CD and Example screenshots"): every screenshot, from CI/CD or a local
  build, is saved in the repository and shown in the related document here (images in `assets/`; default document
  `screenshots.md`), labeled with platform (iOS, Android, Flutter, React Native, HarmonyOS, Mini Program), OS version,
  simulator / emulator version, platform SDK version, repository version or commit URL and the time taken; clear
  originals; README images are cropped key details, stitched vertically first, then two columns, then at most three
  side by side. Correction (2026-11-12): the original request said both "prefer a horizontal layout" and "a horizontal stitch is the worst", which contradict each other; the user corrected it to vertical first.
- Upstream projects (English rule, AGENTS.md "Upstream projects (translations and ports)"): when a project linked in
  these docs is the source of a translation, merge (or translate and merge) its open pull requests, and keep a table
  of its open issues here (issue link, description, fix status `TODO` by default), fixing them and scoring after each
  fix until 100; a translation not started yet waits until the score reaches 60.
- Example demo rules (English rule, AGENTS.md "Example demo rules"): `example-demo-rules.md` holds the rules for what
  the examples of every platform demonstrate; animation screens offer Play all (restart from progress 0), a speed
  slider and a loop switch that combine and act in real time.
- Swift (English rule, AGENTS.md "Swift examples and a Swift-friendly core"): `Swift-Coding-Standard.md` is the Swift
  coding standard (compatibility of the Swift and Objective-C API, files, language, concurrency, comments,
  verification); `Swift-Migration.md` logs the core's migration to Swift with its score after every commit.
- Swift migration priority (English rule, AGENTS.md "Core quality first, examples last"): example compile errors and
  test failures caused by the migration are fixed in the example code first; the examples have the lowest weight and
  get no compatibility work; the core's Swift code follows `Swift-Coding-Standard.md` with no baggage kept for them.
- HarmonyOS port (English rule, 2026-11-16, the user's prompt verbatim: "写入instructions相关文档，鸿蒙系统版本，原则如下：API对标iOS端，example对标iOS端。需要一比一复刻。内部实现对标android 内的Kotlin 源码实现迁移到鸿蒙端。"):
  `harmony.md` is the HarmonyOS document. Versions: target HarmonyOS 5.0.0 (API 12), built with the HarmonyOS
  6.0.1 SDK (API 21) and DevEco Studio 6.0.1, run on the Mate 70 Pro emulator (HarmonyOS 6.0.0). Principles:
  (1) the public API matches the iOS core one to one (table 1 of `harmony.md`); (2) the example matches the iOS
  example one to one: the same screens, texts, data and behaviors (table 2); (3) the internal implementation is
  migrated from the Android Kotlin sources (`android/merged/library`, `android/merged/example`) to ArkTS, Swift
  deciding where they differ. Remove one TODO per finished feature and score after each, until 100.
- HarmonyOS accessibility, localization and accessibility-first UI tests (English rule, AGENTS.md "HarmonyOS:
  accessibility, localization and accessibility-first UI tests"; skill `.agents/skills/cyl-harmonyos/`): all code,
  the HarmonyOS code included, supports visual accessibility, screen readers, internationalization and localization
  with localization files; add the support first where it is missing. Automated UI tests locate controls through
  accessibility first (localized label, then description, then id) for taps, complex flows and sequences of
  actions.
- Accessibility and localization on HarmonyOS (English rule, AGENTS.md "Accessibility and localization on HarmonyOS
  (and every platform)"): all code supports screen readers, visual assistance and localization through resource
  files; add support first where it is missing; automated UI tests locate controls, tap and run multi-step flows
  through accessibility and localized text first. The HarmonyOS parity sheet is `harmony.md`.
- Commit messages (English rule, AGENTS.md "Commit messages: git cz style, English only"; skill
  `.agents/skills/cyl-commit/`): `git cz` style (`<type>(<scope>): <emoji> <summary>`), the whole message in English, no
  Chinese characters; a non-English prompt is quoted only in the task log here, never in a commit.
