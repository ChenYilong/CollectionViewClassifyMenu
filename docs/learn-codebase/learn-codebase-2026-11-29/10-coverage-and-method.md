# Coverage and method

- Pass 2 (same day, same commit): read all 94 vendored files (HarmonyOS 75, mini program 19; [CN] comment lines, import
  and blank lines left out), including their tests and the HAP tool. Covered what earlier "lite" reads had skipped: the
  distinct import lines, the one skipped [CN] line, and block comments of the Android ports (copies repeat them; checked
  by script). Score now: 95/100 (own judgement). Details: 11-vendored-modules.md, V1-V8 in 09.
- Still not read: [CN] comment lines in vendored and lite files, generated files (headers or nothing), most of docs/
  (about 45 Markdown files, 1.7 MB), other Markdown, json/xml data, lockfiles, pbxproj, third-party skills, the yarn
  bundle, untracked fetched packages (only a few lines of cyl-lottie and cyl-rive were looked at). Binary files such as
  the x86_64 libraries were not inspected.
- Local machine state: the untracked miniprogram/cyl_components copies have COMMIT 41660d24, while
  scripts/fetch-cyltabbar.js pins b5b36fbf (its --check mode was not run). miniprogram_npm's cyl-animated-item/index.js is
  559 lines and miniprogram_dist's 1128; why was not examined.
- The sections below describe pass 1; where they say vendored modules were not read, pass 2 replaces that.
- Score given in pass 1: 90/100 (own judgement; 60 = every platform core read; 100 = plus tests, examples, scripts, workflows, report).
- Read without import, blank and [CN] lines: Android library, tests, examples, scripts (3 ports also without block
  comments); iOS examples and tests; HarmonyOS tests and scripts; mini program example, tests, scripts; Flutter example;
  RN tests, example, harmony example; last Podfiles and Flutter package files.
- The read_mode column of file-inventory.tsv is derived from these rules by path, not logged per file. "full" means no lines were stripped. The HarmonyOS example app (harmony/entry) was read in full except generated strings.
- Not read: vendored modules, generated and data files, json/xml data, lockfiles, pbxproj, most docs, third-party skills,
  bundled yarn release. miniprogram_dist was first excluded by mistake, then read.
- Sample check: 761 files by extension, up to 12 lines each searched in the session's tool output; 32 were below 75%
  (generated/data, licenses, 11 small config files read afterwards). A sample, not proof.
- Docs: besides README/AGENTS and the instructions, this pass did not re-read docs/. The 2026-11-27 pass
  read several; see appendix-earlier-ios-memory-note.md.
- TODO: run the tests; read the remaining docs if needed; reproduce V1, V2 and V4 on a device or emulator.
- The repo was not changed.
