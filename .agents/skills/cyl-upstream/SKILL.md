---
name: cyl-upstream
description: Bring an upstream project's open pull requests and open issues into a translation or port (Kotlin, Swift, Flutter, React Native, HarmonyOS, Mini Program) and score the issue fixes up to 100.
---

# Upstream projects used for translation

Applies when a document of this project links to another project's GitHub repository that is the source of a
translation or port, such as the projects ported to Kotlin in `android/` (kaedea/android-tagview,
shellljx/TagViewGroup, whilu/AndroidTagView) or mokagio/UICollectionViewLeftAlignedLayout behind
`CYLCollectionViewLeftAlignedLayout`. A translation of the default branch alone is not enough.

## Rule

- **Upstream projects used for translation.** When a document of this project links to a GitHub repository of
  another project, and that repository is the source of a translation or port (for example the projects ported to
  Kotlin in `android/`), do not translate only its default branch:
  1. **Pull requests.** Visit the upstream's open pull requests and bring them in. If the translation has not started,
     merge the open pull requests into the source first; if it is already done, translate each open pull request's
     change and merge it into our port.
  2. **Issues.** List the upstream's open issues in a table in the related document in `docs/` (create one when none
     fits): column 1 the issue link, column 2 its description, column 3 the fix status (`TODO` by default). Find each
     issue's counterpart in our code and try to fix it.
  3. **Score.** 100 means every listed issue is resolved. Give a score after each fixed issue and continue until 100.
  4. **Order.** For a translation not started yet: merge the open pull requests, fix issues until the score reaches
     60, translate, then fix the remaining issues up to 100. For a finished translation: translate and merge the open
     pull requests, then fix the issues on the translated code up to 100.
  5. The same rule applies to every platform (iOS, Android, Flutter, React Native, HarmonyOS, Mini Program).

## Steps

1. Log the task in `docs/` first (AGENTS.md, "Task log in docs/").
2. List the open pull requests and issues:

   ```sh
   gh pr list -R <owner>/<repo> --state open --json number,title,url
   gh issue list -R <owner>/<repo> --state open --limit 200 --json number,title,url
   gh pr diff <number> -R <owner>/<repo>
   ```

3. Pull requests: before the translation, apply each open pull request's diff to the source copy; after it,
   translate the change into our port. Record each pull request (link, what it changes, merged / translated) in the
   document.
4. Issues: add the table to the related document in `docs/` (create one when none fits):

   | Issue | Description | Status |
   | --- | --- | --- |
   | <link> | <description> | TODO |

   For each issue, find its counterpart in our code, fix it with a test, and set the status to the fix and its test
   (or explain why it does not apply, with the check that shows it). Questions with no defect are listed and not
   scored.
5. Score = fixed issues / scored issues × 100. Add a score row after each fix (date, commit, score) and continue
   until 100. A translation not started yet begins once the score reaches 60.
6. The same steps apply on every platform.

Example: `docs/CYLCollectionViewLeftAlignedLayout.md` (4 pull requests merged, 21 issues fixed, score 100).
