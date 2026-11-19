# 中英文双语文档 / Bilingual Documentation

| 中文 | English |
|:---|:---|
| 本文说明本仓库文档的中英文双语规则，规则复制自 [CYLTabBarController 的双语文档规范](https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Bilingual-Documentation.md)，并按本仓库的情况调整。 | This page explains the bilingual Chinese–English rules of this repository's documentation. The rules are copied from [CYLTabBarController's bilingual documentation standard](https://github.com/ChenYilong/CYLTabBarController/blob/feat/cross-platform-components/docs/Bilingual-Documentation.md) and adapted to this repository. |
| 除代码和截图外，文档的每一段都同时提供中文和英文，世界各地的开发者都可以直接阅读。 | Except for code and screenshots, every passage of the documentation comes in both Chinese and English, so developers anywhere can read it directly. |

## 如何阅读 / How to read

| 中文 | English |
|:---|:---|
| 标题写成一行：`## 中文标题 / English title`。 | A heading is one line: `## 中文标题 / English title`. |
| 正文使用两列表格：左列中文，右列英文，每行内容相同。段落是一行；列表的每一项也是一行（子项以 `↳` 开头）。 | Body text is a two-column table: Chinese on the left, English on the right, the same content in each row. A paragraph is one row; each list item is also one row (sub-items start with `↳`). |
| 多列的表格（API、对比、状态）先给中文表，紧接着给内容相同的英文表；只有代码、数字或链接的单元格在两个表中相同。 | Tables with more columns (API, comparisons, status) come as a Chinese table followed by an English table with the same rows; cells with only code, numbers or links are the same in both. |
| 代码块、代码示例和截图两种语言共用，不翻译。代码里的注释保持原样。 | Code blocks, code samples and screenshots are shared between the two languages and not translated. Comments inside code stay as they are. |
| 行内代码（反引号）、链接地址和图片路径在中英文中完全一致。 | Inline code (backticks), link targets and image paths are identical in both languages. |

## 范围 / Scope

| 中文 | English |
|:---|:---|
| 已改为双语：`README.md`、本文，以及[已转换文档列表](#已转换的文档--converted-documents)中的 `docs/` 文档。 | Bilingual now: `README.md`, this page, and the `docs/` documents in the [list of converted documents](#已转换的文档--converted-documents). |
| 保持英文（负责人 2026-11-20 的决定）：`AGENTS.md`、各文件夹的 `instructions.md` 和 `.agents/skills/`，它们是写给智能体的指令；第三方文件（`LICENSE`、`THIRD-PARTY-NOTICES.md`、安装的第三方 skill）也保持原样。 | Stays English (the owner's decision of 2026-11-20): `AGENTS.md`, the `instructions.md` files and `.agents/skills/`, which are instructions for the agents; third-party files (`LICENSE`, `THIRD-PARTY-NOTICES.md`, installed third-party skills) also stay as they are. |
| 自动生成的 API 表（`android-api.md`、`android-ios-api.md`、`harmony.md`）里的名称是代码，保持原样；它们的标题和说明改为双语（由生成脚本输出）。 | The names in the generated API tables (`android-api.md`, `android-ios-api.md`, `harmony.md`) are code and stay as they are; their headings and introductions become bilingual (written by the generator scripts). |
| 任务记录里逐字引用的用户指令保持原样，旁边附上另一种语言的版本。 | User prompts quoted verbatim in task logs stay as written, with the other language beside them. |

## 新文档的规则 / Rules for new documents

| 中文 | English |
|:---|:---|
| 新建或修改 `README.md` 与 `docs/` 中的文档时，按上面的格式同时写中文和英文，不要只留一种语言。 | When you add or change `README.md` or a document in `docs/`, write both Chinese and English in the format above; do not leave a passage in one language only. |
| 用 `python3 scripts/bilingual-docs.py check <文件>` 检查格式；`--against <git 引用>` 还会核对代码块、行内代码、链接和图片没有被改动。 | Check the format with `python3 scripts/bilingual-docs.py check <file>`; `--against <git ref>` also checks that code blocks, inline code, links and images were not changed. |
| 把已有的英文或中文文档转换为双语：`extract` 拆出待翻译的段落，翻译后用 `assemble` 按固定版式组装；代码、表格结构、图片和链接由脚本原样保留。 | To convert an existing English or Chinese document: `extract` splits out the passages to translate, and after translation `assemble` builds the layout; the script keeps code, table structure, images and links as they are. |
| 附件放在 Markdown 文件旁边的 `assets/` 文件夹，使用最短的相对路径。截图规则不变（见 [screenshots.md](screenshots.md)）。 | Attachments live in an `assets/` folder next to the Markdown file and are linked with the shortest relative path. The screenshot rules are unchanged (see [screenshots.md](screenshots.md)). |

## 已转换的文档 / Converted documents

| 中文 | English |
|:---|:---|
| 第一批（本 PR）：见下表；其余文档在后续 PR 中转换，转换前仍是单一语言。 | First batch (this PR): see the list below; the other documents follow in later PRs and stay single-language until then. |

- `README.md`
- `docs/Bilingual-Documentation.md`
- `docs/Swift-Coding-Standard.md`
- `docs/Swift-Migration.md`
- `docs/example-animation-controls.md`
- `docs/example-demo-rules.md`
- `docs/example-layer-fixes.md`
- `docs/rive.md`
- `docs/screenshots.md`
- `docs/CYLCollectionViewLeftAlignedLayout.md`
- `docs/androidtagview-api.md`
- `docs/android-tagview-api.md`
- `docs/tagviewgroup-api.md`
- `docs/android-api.md`
- `docs/android-ios-api.md`
- `docs/harmony.md`

| 中文 | English |
|:---|:---|
| 最后三个是自动生成的文档，只有标题和说明是双语，表格保持代码名称。 | The last three are generated documents: only the headings and intros are bilingual, the tables stay code names. |

## 任务记录 / Task log

| 中文 | English |
|:---|:---|
| TODO（2026-11-20，分支 `docs/bilingual-en-zh`）：新建 PR，把文档翻译为中英文双语展示，复制 CYLTabBarController 的文档中英文规范，除代码和截图外都要处理。 | TODO (2026-11-20, branch `docs/bilingual-en-zh`): open a new PR that makes the documentation bilingual Chinese–English, copying CYLTabBarController's bilingual documentation standard; everything except code and screenshots must be handled. |
| 用户指令（逐字）：「新建pr进行文档中文 英文翻译展示，复制CYLTabBarController里的文档中英文规范，除代码及截图外，都需要处理」 | User prompt (verbatim): 「新建pr进行文档中文 英文翻译展示，复制CYLTabBarController里的文档中英文规范，除代码及截图外，都需要处理」 |
| 负责人的决定（被问到范围时）：先做核心文档（README、本规范、`docs/` 的功能文档，生成的 API 表只改标题和说明）；`AGENTS.md`、`instructions.md` 和 skill 保持英文；其余文档在后续 PR 中转换。 | The owner's decisions (asked about scope): core documents first (README, this standard, the feature documents in `docs/`, generated API tables only get bilingual headings and intros); `AGENTS.md`, `instructions.md` and skills stay English; the other documents follow in later PRs. |
| 验收（满分 100）：规范与脚本（30）；`README.md` 双语（20）；`docs/` 功能文档双语，结构检查通过（30）；生成表的标题和说明双语（10）；`AGENTS.md` 追加规则、已通知其他会话（10）。及格 60。 | Acceptance (100): the standard and the script (30); `README.md` bilingual (20); the `docs/` feature documents bilingual with the structure check passing (30); the generated tables' headings and intros bilingual (10); the rule appended to `AGENTS.md` and the other sessions told (10). Pass: 60. |
