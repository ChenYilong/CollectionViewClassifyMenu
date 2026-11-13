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
