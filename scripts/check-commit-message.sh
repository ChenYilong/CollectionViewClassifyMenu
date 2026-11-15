#!/bin/sh
# Checks commit messages against the git cz rule (AGENTS.md "Commit messages: git cz style, English only"): the
# subject is "<type>(<scope>)?: <emoji> <summary>", the author line is present, and no Chinese (CJK) character
# appears anywhere in the message. Usage: scripts/check-commit-message.sh [revision range, default: HEAD^..HEAD]
set -eu
RANGE=${1:-HEAD^..HEAD}
STATUS=0
for commit in $(git rev-list "$RANGE"); do
  message=$(git log -1 --format=%B "$commit")
  subject=$(printf '%s\n' "$message" | head -n 1)
  if ! printf '%s\n' "$subject" | grep -Eq '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([^)]+\))?!?: .+'; then
    echo "$commit: subject is not git cz style: $subject"; STATUS=1
  fi
  if ! printf '%s\n' "$message" | grep -qxF 'By @ChenYilong <luohanchenyilong@163.com>'; then
    echo "$commit: missing the author line"; STATUS=1
  fi
  if printf '%s' "$message" | perl -CS -ne 'exit 1 if /[\x{3000}-\x{303F}\x{3400}-\x{4DBF}\x{4E00}-\x{9FFF}\x{F900}-\x{FAFF}\x{FF00}-\x{FFEF}]/'; then :; else
    echo "$commit: Chinese characters in the message"; STATUS=1
  fi
done
[ "$STATUS" -eq 0 ] && echo "OK: $(git rev-list --count "$RANGE") commit(s) follow the git cz rule"
exit "$STATUS"
