#!/usr/bin/env bash
# Standard write path for every agent (CHARTE.md §8):
#   tools/commit.sh "wiki(<bundle>): <action> — <object>" "<acting-agent>"
# Regenerates indexes, lints, commits under a lock, then rebases and pushes.
set -euo pipefail

# Re-invoke under the lock in command mode with close-on-exec (-o): the lock
# fd lives only in the flock parent process — never in this script or its
# children. Anything forked below (notably git's credential-cache--daemon,
# which outlives the script) cannot inherit the descriptor and hold the lock
# forever. (Paid-for lesson: a daemon forked under a file lock inherits it —
# hence close-on-exec.)
#
# The lock is named after the repository so that several wikis living on the
# same machine serialize independently instead of blocking each other.
if [ -z "${WIKI_COMMIT_LOCKED:-}" ]; then
  LOCK="/tmp/llm-wiki.$(basename "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)")"
  exec flock -o "$LOCK" env WIKI_COMMIT_LOCKED=1 bash "$(readlink -f "$0")" "$@"
fi

cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"

msg="${1:?usage: tools/commit.sh \"message\" \"acting-agent\"}"
agent="${2:?acting-agent required, e.g. <agent>/<model>}"

# Preflight — fail fast with a clear message instead of a mid-commit traceback.
python3 -c "import yaml" 2>/dev/null || {
  echo "commit.sh: PyYAML missing — run: pip3 install --user -r tools/requirements.txt" >&2
  exit 1
}

python3 tools/gen-index.py >/dev/null
git add -A
python3 tools/lint.py
git commit -m "$msg" -m "Acting-Agent: $agent"

if git remote get-url origin >/dev/null 2>&1; then
  for attempt in 1 2; do
    if git pull --rebase origin main && git push origin main; then
      break
    elif [ "$attempt" = 2 ]; then
      echo "commit.sh: push failed twice — resolve manually" >&2
      exit 1
    fi
  done
else
  echo "commit.sh: no remote configured, committed locally only"
fi
