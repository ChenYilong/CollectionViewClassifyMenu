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
