---
title: Scripts folder instructions
date: 2026-11-08
tags: [scripts, cocoapods]
---

# Scripts folder instructions

- Release scripts validate the podspec and the matching remote Git tag before publishing.
- Publishing is explicit: never run `pod trunk push` as part of a build or test.
- Keep this folder's overview in `scripts.base` and follow the project instructions.
- CI scripts follow CYLTabBarController: `unit-tests.sh <menu|tag|example>`, `library-warnings.sh`,
  `example-screenshots.sh` and `simulator-id.sh`. Keep them POSIX `sh` and clean under `shellcheck`.
- `example-screenshots.sh` runs in every build CI run; keep it producing one PNG per Example screen.
- `publish-screenshots.sh` copies them to the `ci-screenshots` branch, because artifact storage hosts change between runs.
- Fix issues in the core first (AGENTS.md "Fix issues in the core first"): the core is the code published to a package registry (CocoaPods, Maven / Gradle, npm, pub.dev, ohpm); an example-layer fix is the worst option; when the core cannot fix a core defect, ask the user first and say why; record every example-layer fix and its reason in `docs/example-layer-fixes.md`.
