# Documentation

Tag: `docs`. The full rules of this tag. [AGENTS.md](../../AGENTS.md) keeps the short form under the heading
`[docs] Documentation`; read this file when a task touches the tag. Moved from AGENTS.md word for word on 2026-11-22, when
AGENTS.md was limited to 200 lines; section names are unchanged, so a reference such as AGENTS.md "Documentation assets" now
means the section of that name here.


## Documentation assets

- Images and other attachments of a Markdown file go into an `assets/` folder
  next to that file (as Obsidian saves new attachments): `README.md` uses
  `assets/`, a file in `docs/` uses `docs/assets/`. Link them with the shortest
  relative path (`![…](assets/<file>)`), never with absolute GitHub URLs or
  external image hosts.
- Name files in English, lowercase with hyphens, after what they show
  (`swift-tag-editor.png`, `scenario1-taobao-review-filter.gif`).
- README screenshots of the examples come from a CI run of the current commit
  (the `ci-screenshots` branch, see "CI/CD and Example screenshots"); replace them
  when the screens change.


## Documentation: bilingual Chinese–English (added 2026-11-20)

- `README.md` and the documents in `docs/` are bilingual, in the format of CYLTabBarController's standard, copied to
  `docs/Bilingual-Documentation.md` (the list of converted documents is there): headings `中文 / English`, body text as
  a two-column table `| 中文 | English |` (one row per paragraph or list item), multi-column tables given twice (Chinese,
  then English). Code blocks, inline code, link targets and screenshots are shared and never translated.
- When you add or change a converted document, write both languages. Check it with
  `python3 scripts/bilingual-docs.py check <file> --against origin/master`. To convert a document: `extract`, translate
  the passages, `assemble` (the script keeps code, table structure, images and links).
- Stays English: this file, every `instructions.md`, `.agents/skills/` and third-party files. Generated documents
  (`docs/android-api.md`, `docs/android-ios-api.md`, `docs/harmony.md`) get their bilingual headings and intros from
  the generator scripts; the tables stay code names (`<!-- bilingual:keep -->`).
