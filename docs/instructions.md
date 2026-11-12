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
  side by side.
