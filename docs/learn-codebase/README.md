# learn-codebase exports and claude-mem memory

Read this file in full before you run `/claude-mem:learn-codebase` in this repository.

It explains where the export goes, how to make claude-mem ingest it again on another computer, and how to remove private
data before committing it. It comes from the first export (2026-11-29, claude-mem 17.0.2). Facts about the folder watcher
were read from the claude-mem 17.0.2 source; check them again after an upgrade.

Placeholders: `<repo>` is the absolute path of your clone, `<home>` is your home folder, `<port>` is
`CLAUDE_MEM_WORKER_PORT` from your claude-mem settings. Never commit their real values.

Run the commands from the repository root in bash (Git Bash on Windows; PowerShell has no heredocs), with
`PYTHONUTF8=1` set on Windows. They use `py -3 -I` (Windows, where `python3` may be only a Microsoft Store
stub). On macOS and Linux use `python3 -I`.

## Order of work

1. Export into the repository.
2. Remove private data.
3. Split Markdown files over 64 KB.
4. Add the watch root and restart the worker.
5. Check that the files were ingested.
6. Commit.

Keep this order. The watcher stores what it reads in the claude-mem database (which cloud sync, if enabled, may upload),
so private data should be gone **before** the watcher sees a file. This README sits in the watched folder, so keep it
free of private data too.

**If a watch root for this folder already exists** (a second export on the same computer, or a clone at the same path),
the watcher reads new files as soon as they stop changing. Remove this repository's entry from the setting and restart
the worker first (step 4), or write and scrub the export in a git-ignored folder outside `docs/learn-codebase/` and move
it in after step 3.

## 1. Where the export goes

Each export gets its own dated folder:

```text
docs/learn-codebase/learn-codebase-YYYY-MM-DD/
```

The skill has no option for an output path: it only tells the agent to read every source file. Say where to write in your
request. A prompt to copy:

```text
/claude-mem:learn-codebase
Read docs/learn-codebase/README.md first. Export what you learn, as completely as possible, to
docs/learn-codebase/learn-codebase-YYYY-MM-DD/ in this repository (not to the claude-mem deliverables folder).
Write in English. Record the commit the export describes. Use repository-relative paths only. Include no private data.
Keep every .md file at 64 KB or less. Do not commit before the privacy pass.
```

- claude-mem does **not** scan `<home>/.claude-mem/deliverables/`. A file placed there is not ingested as memory.
- Do not register files of this folder as a `work_product` of a claude-mem work list: claude-mem may copy them into the
  deliverables folder, and the two copies then drift apart.
- Start the export's own `README.md` with the commit, the branch, the date, what was and was not read, and what was
  verified by building or running.

If an export already is in `<home>/.claude-mem/deliverables/CollectionViewClassifyMenu/`:

1. List the folder and read what you are about to move.
2. Copy it into `docs/learn-codebase/`.
3. Compare the file hashes of both copies.
4. Delete the original only when every hash matches.

Move only this project's folder. Leave other projects' folders alone, and leave the automatic copies that claude-mem
keeps under `deliverables/GitHub/`: they may be referenced by database records. Update any note that holds the old path.

## 2. Remove private data

**This repository is public.** Check it again with `gh repo view --json visibility`. A pushed commit cannot be taken back
without rewriting history, which needs the owner's approval.

### What to remove or rewrite

| Data | Action |
|:---|:---|
| Email addresses | remove |
| Tokens, API keys, passwords, cookies, content of `settings.json` or `.env` | remove; if one was ever pushed, tell the owner so it can be revoked |
| Home paths (`C:\Users\...`, `/Users/...`, `/home/...`) | write `<home>` or `<repo>` |
| Cloud-drive and organization folder names (`OneDrive - ...`) | write `<org>` or drop the path |
| `AppData`, temporary and scratchpad paths of the machine | remove |
| Agent session names, claude-mem observation IDs, messages between sessions | remove |
| Chat transcripts, context summaries, system prompt text, copies of local memory notes | do not commit |
| Raw reading notes and appendices | keep local unless the owner approves publishing them |
| Unverified bug or defect lists, anything that looks like a security weakness | ask the owner before publishing; label what was not run |

Text copied from tracked source files (for example an author name in a copyright header, the owner's public GitHub
handle in package names and URLs, or an example path with placeholders) is already public. Expect such hits, and check
that a hit really comes from the source before you leave it.

### Scan

The script reads every file, not only Markdown (the first export also had a `.tsv` inventory). It adds your user name,
home folder and `git config user.email` / `user.name` to the search. Pass more private words (employer, school, machine
name, other accounts) as arguments; do not write them into the repository.

```sh
py -3 -I - "private word" "another one" <<'EOF'
import os, pathlib, re, subprocess, sys
root = 'docs/learn-codebase'
home = pathlib.Path.home()
words = [home.name, *sys.argv[1:]]
for key in ('user.name', 'user.email'):
    words.append(subprocess.run(['git', 'config', key], capture_output=True, text=True).stdout.strip())
patterns = {
    'email': r'[\w.+-]+@(?!\dx\b)[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}\b',
    'home path': r'(?i)[a-z]:[\\/]+users[\\/]|/(?:Users|home)/\w',
    'cloud or temp path': r'OneDrive|AppData|/tmp/|scratchpad',
    'secret': r"""(?i)(api[_-]?key|token|secret|password)["']?\s*[:=]\s*["']?[A-Za-z0-9_\-]{12,}""",
    'session or memory': r'(?i)\.claude[/\\]|claude-mem #\d+|another session|memory note',
}
words = [w for w in words if len(w) > 2]
if words:
    patterns['private word'] = '(?i)' + '|'.join(map(re.escape, words))
hits = 0
for folder, _, names in os.walk(root):
    for name in names:
        path = os.path.join(folder, name)
        lines = open(path, encoding='utf-8', errors='replace').read().split('\n')
        for number, line in enumerate(lines, 1):
            for kind, pattern in patterns.items():
                if re.search(pattern, line):
                    hits += 1
                    print(f'{kind}: {path}:{number}')
print('hits:', hits)
EOF
```

The output shows places, not the matched text. Open each hit and fix it, or confirm that it is harmless (this README
names some of the patterns, so a few hits in it are expected). A clean scan does not prove that a file is safe: also read
the new files, above all the notes and findings.

## 3. Respect the watcher's limits

In claude-mem 17.0.2 the folder watcher:

- reads only files ending in `.md`, at most **64 KB** each; larger files are skipped without a visible error;
- skips symbolic links and names that start with a dot;
- goes at most 8 folder levels deep and reads at most **500 files per root**, so old dated exports count too;
- stores a file once its content is stable, and stores **every changed version as a new record**. Finish your edits
  first and then make them in one batch.

Split large files at their `## ` headings into `name-part1.md`, `name-part2.md`, ... Check that the parts together keep
all the text, then fix every link or mention of the old file name. List the files that are still too large:

```sh
py -3 -I -c "import pathlib; [print(p) for p in pathlib.Path('docs/learn-codebase').rglob('*.md') if p.stat().st_size > 65536]"
```

## 4. Set `CLAUDE_MEM_MEMORY_WATCH_ROOTS`

The setting is per computer and is not part of the repository, so set it again after a new clone or on a new computer. It
is in `<home>/.claude-mem/settings.json` (or in the folder set by `CLAUDE_MEM_DATA_DIR`).

- The value is a **string** that contains a JSON array, so its quotes and backslashes are escaped in `settings.json`.
- At most **8** entries, for all projects together. An invalid value turns the watcher off for all of them.
- Each entry needs `path` (absolute, or starting with `~/`) and `project`.
- Point it at `docs/learn-codebase`, not at all of `docs/`.
- Use the project name `CollectionViewClassifyMenu`.

Decoded, one entry looks like this:

```json
[{"path": "<repo>/docs/learn-codebase", "project": "CollectionViewClassifyMenu"}]
```

`settings.json` is shared by every session and project on the computer and may hold secrets: do not print the whole file,
do not copy it (or a backup of it) into the repository, and change only this key. The script below keeps the other
entries, replaces an older entry for this project's folder (for example after the clone moved), and stops if the file
changed while it ran.

```sh
py -3 -I - <<'EOF'
import json, os, pathlib
folder = pathlib.Path('docs/learn-codebase').resolve()
assert folder.is_dir(), 'run from the repository root'
data_dir = os.environ.get('CLAUDE_MEM_DATA_DIR') or pathlib.Path.home() / '.claude-mem'
path = pathlib.Path(data_dir) / 'settings.json'
raw = path.read_text(encoding='utf-8')
settings = json.loads(raw)
roots = json.loads(settings.get('CLAUDE_MEM_MEMORY_WATCH_ROOTS') or '[]')
roots = [r for r in roots if r['project'] != 'CollectionViewClassifyMenu']
roots.append({'path': str(folder), 'project': 'CollectionViewClassifyMenu'})
assert len(roots) <= 8, 'more than 8 watch roots: ask the owner which one to remove'
settings['CLAUDE_MEM_MEMORY_WATCH_ROOTS'] = json.dumps(roots, ensure_ascii=False, separators=(',', ':'))
assert path.read_text(encoding='utf-8') == raw, 'settings changed meanwhile: run again'
temporary = path.with_name(path.name + '.tmp-learn-codebase')
temporary.write_text(json.dumps(settings, ensure_ascii=False, indent=2) + '\n', encoding='utf-8', newline='\n')
os.replace(temporary, path)
print('watch roots:', [r['project'] for r in roots])
EOF
```

The worker reads the setting **when it starts**, so restart it. All sessions on the computer share the worker: tell the
other sessions first.

```sh
curl -X POST http://127.0.0.1:<port>/api/admin/restart
curl http://127.0.0.1:<port>/api/health
```

Wait until the health check answers with a small `uptime`. Other sessions may edit the same setting at about the same
time, so after the restart read the key again and confirm that this project's entry is still there.

## 5. Check the ingestion

Wait some seconds, then compare the Markdown files with the database (read only):

```sh
py -3 -I - <<'EOF'
import json, os, pathlib, sqlite3
folder = pathlib.Path('docs/learn-codebase').resolve()
data_dir = pathlib.Path(os.environ.get('CLAUDE_MEM_DATA_DIR') or pathlib.Path.home() / '.claude-mem')
database = sqlite3.connect((data_dir / 'claude-mem.db').as_uri() + '?mode=ro', uri=True)
wanted = {os.path.normcase(str(p)) for p in folder.rglob('*.md')}
found = {}
query = ("select project, metadata from observations where json_valid(metadata) "
         "and json_extract(metadata, '$.source') = 'memory-file'")
for project, metadata in database.execute(query):
    source = os.path.normcase(os.path.normpath(json.loads(metadata)['sourcePath']))
    if source in wanted:
        found.setdefault(source, set()).add(project)
print('markdown files:', len(wanted), 'ingested:', len(found))
print('projects:', sorted(set().union(*found.values())) if found else [])
for missing in sorted(wanted - set(found)):
    print('missing:', os.path.relpath(missing, folder))
EOF
```

Every file should be ingested under `CollectionViewClassifyMenu` only. If a file is missing, check its size and name
(step 3), the setting (step 4) and that the worker restarted. This uses claude-mem's internal database layout, which an
upgrade may change.

On another computer, cloning the repository and doing steps 4 and 5 is enough to ingest the committed exports; run steps
2 and 3 first if you changed any file. Other memories from the old computer do not come with the repository. They need
claude-mem's own cloud sync or a database backup. If the database was copied from the old computer, a clone at another
path is stored again, as new records.

## 6. Commit

1. Read [docs/instructions/git.md](../instructions/git.md) in full and follow it: `bash scripts/check-branch-pr.sh` (with
   more than two open pull requests, ask the owner first), the `.gitignore` sync, and no push to `master` / `main`.
2. Run the scan of step 2 again.
3. Stage only the intended files under `docs/learn-codebase/` (and the task log), never `git add -A`. Leave out what the
   owner did not approve for publishing.
4. Read `git diff --cached` (at least `--stat` and every notes or findings file) before committing.
5. Write a `git cz` message in English with the author line from [AGENTS.md](../../AGENTS.md) and check it with
   `scripts/check-commit-message.sh`.

A file that you leave out of the commit but keep in this folder is still ingested on this computer, and is not there on
another one. Make sure that no committed file links to it.

## Checklist

- [ ] Export is in `docs/learn-codebase/learn-codebase-YYYY-MM-DD/`, with the commit it describes.
- [ ] Scan hits are fixed or explained; the owner decided on appendices and unverified findings.
- [ ] No `.md` file is over 64 KB; links to split files work.
- [ ] This project's watch root is set, the other entries are kept, the worker was restarted.
- [ ] The ingestion check shows no missing file.
- [ ] Only approved files are staged.
