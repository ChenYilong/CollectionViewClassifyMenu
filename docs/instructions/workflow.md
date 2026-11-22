# Tasks and workflow

Tag: `workflow`. The full rules of this tag. [AGENTS.md](../../AGENTS.md) keeps the short form under the heading
`[workflow] Tasks and workflow`; read this file when a task touches the tag. Moved from AGENTS.md word for word on 2026-11-22, when
AGENTS.md was limited to 200 lines; section names are unchanged, so a reference such as AGENTS.md "Task log in docs/" now
means the section of that name here.


## Task log in docs/

- **Record every task in `docs/` before starting it.** Find the most relevant existing document in `docs/`
  (create one only when none fits; `docs/issue-progress.md` holds the general TODO list). Add a `TODO` entry
  first: the task's detailed context, the user's requirements, and the user's prompt quoted verbatim. Then do the
  task. When it is finished, mark the entry done and add the result and its evidence (commits, tests,
  screenshots). Purpose: if the work is interrupted, the context can be found again and the task resumed.
- The same rule is in the vault's root `instructions.md` (section 16). Details: `.agents/skills/cyl-commit/`.


## Task start: TODO, branch, acceptance score

Details and checklist: `.agents/skills/cyl-task-start/SKILL.md`.

- **Check other sessions first.** Before starting, list the other agent sessions and read their current tasks. Step
  one: find out whether any session is editing the same branch (same repository and branch). If none is, continue.
  If one is, check whether its task duplicates this one: if it does, do not repeat it (coordinate with that session,
  or take a part it is not doing); if it does not, continue and avoid touching the same files at the same time.
- **Mark the task at the top.** Before starting any task, write a `TODO` line at the very top of the session (the
  first lines of the first reply) with the task and the current branch, for example
  `TODO (branch feat/harmony): <task>`.
- **Write the task into docs/.** Find the most suitable document in `docs/` (see "Task log in docs/") and write the
  task there, together with its acceptance scoring criteria: what earns full marks (100) and what is a pass (the
  passing score, 60 unless the task says otherwise), each criterion with its points.
- **Score until it passes.** Score the work against those criteria. Below the passing score the task must not be
  interrupted or handed back: keep working and scoring again until it passes.
- **Explain the missing points.** Write the score, and why it is not full marks, into the document. At the end of
  the session, print every missing point as a `TODO` (criterion, points, what is still needed) in the final lines of
  the last reply.
- **Update the document at the end.** Update the entry written when the task started: the final score, the reasons
  for the missing points, the result and its evidence (commits, tests, screenshots).


## Issue progress

- Keep all issues in `docs/issue-progress.md`, including non-UI issues.
- After each issue-fix commit, add its URL and reassess the score. Explain
  unverified scenarios and why a score is below 100.
