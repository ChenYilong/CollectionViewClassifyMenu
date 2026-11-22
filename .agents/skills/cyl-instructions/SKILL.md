---
name: cyl-instructions
description: Keep this project's instruction files (AGENTS.md, CLAUDE.md, docs/instructions.md, scripts/instructions.md, harmony/instructions.md) organized by tag, each under 200 lines, with the full rules in docs/instructions/<tag>.md. Use when adding, moving or looking up a rule.
---

# Instructions by tag

## Rule (owner's request, 2026-11-22)

- Every rule in an instruction file sits under a visible tag heading: `## [<tag>] <title>`. A heading is never hidden
  or folded away.
- Tags in use: `guidelines`, `instructions`, `workflow`, `sessions`, `windows`, `macos`, `testing`, `harmonyos`, `code`,
  `dependencies`, `examples`, `i18n`, `accessibility`, `docs`, `git`. Add a new tag only when no existing one fits,
  and add it to the tag table in AGENTS.md.
- Every instruction file stays at 200 lines or fewer. When a tag's text would push a file over, move the overflow into
  `docs/instructions/<tag>.md` (one file per tag) and link it from the tag heading with a relative path, so the details
  are read only when the task touches that tag.
- The tag files keep the moved sections word for word, with their original headings, so a reference such as
  AGENTS.md "Fix issues in the core first" still finds its section (now in `docs/instructions/code.md`).

## Required reading

- `docs/instructions/Behavioral_guidelines_to_reduce_common_LLM_coding_mistakes.md` is linked at the top of AGENTS.md and CLAUDE.md under `## [guidelines]` and must be read in full, every
  line, before any task. Keep that link at the top of both files.

## Adding a rule

1. Pick the tag. Write the full rule in `docs/instructions/<tag>.md` (under an existing section or a new `##` section).
2. Add a one-line short form under `## [<tag>]` in AGENTS.md (and in a folder's `instructions.md` when it concerns that
   folder), with a link to the section.
3. Check the sizes: `wc -l AGENTS.md CLAUDE.md docs/instructions.md scripts/instructions.md harmony/instructions.md`
   (each 200 or fewer).
4. Write it in English.

## Looking up a rule

- Read the tag table at the top of AGENTS.md, then the headings whose tags match the task (for example `testing` and
  `harmonyos` for a HarmonyOS UI test, `windows` on a Windows session, `macos` for Xcode work), then the linked
  `docs/instructions/<tag>.md`.
