#!/usr/bin/env bash
# Run the FULL local lint — private denylist included — against every open pull
# request.
#
# CI cannot do this: the denylist lives outside the repo on purpose (CHARTE §2),
# so the CI check on a remote-channel pull request (CHARTE §8) is blind to
# private motifs. This script is the mechanism that closes that gap. It is
# report-only: it never writes to the repo, never pushes, never merges.
#
# Output is safe to forward to a chat channel — the lint reports that a
# denylisted term was found, never which one.
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/wiki-pr-review.XXXXXX")"
cleanup() {
  git -C "$REPO_DIR" worktree prune >/dev/null 2>&1
  rm -rf "$WORK"
}
trap cleanup EXIT

cd "$REPO_DIR"

prs=$(gh pr list --state open --json number,headRefOid,title \
        --jq '.[] | [.number, .headRefOid, .title] | @tsv' 2>/dev/null) || {
  echo "gh unavailable or not authenticated."; exit 2; }

if [ -z "$prs" ]; then
  echo "No open pull requests."
  exit 0
fi

fail=0
while IFS=$'\t' read -r n sha title; do
  [ -n "$n" ] || continue
  echo "=== PR #$n — $title (${sha:0:7})"

  if ! git fetch -q origin "refs/pull/$n/head" 2>/dev/null; then
    echo "    cannot fetch the branch"; fail=1; continue
  fi

  wt="$WORK/pr-$n"
  if ! git worktree add -q --detach "$wt" FETCH_HEAD 2>/dev/null; then
    echo "    cannot create worktree"; fail=1; continue
  fi

  if (cd "$wt" && python3 tools/lint.py); then
    echo "    full local lint, denylist included: OK"
  else
    echo "    FAILED — do not merge this PR"
    fail=1
  fi

  git worktree remove -f "$wt" >/dev/null 2>&1
done <<< "$prs"

exit $fail
