#!/usr/bin/env bash
# Merge routine pull requests, and only those.
#
# A pull request is merged automatically ONLY when all four hold:
#   1. every CI check on its head commit has concluded successfully;
#   2. the FULL local lint passes — private denylist included, the one check CI
#      structurally cannot do (CHARTE §2, §8);
#   3. the diff touches nothing structural (see STRUCTURAL below);
#   4. it is mergeable and not a draft.
#
# Anything else is left open and reported. Report-only by default: pass --merge
# to actually merge. Never force-pushes, never closes, never edits a branch.
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DO_MERGE=0
[ "${1:-}" = "--merge" ] && DO_MERGE=1

# Preflight — this runs from a daily cron: an auth failure must be loud, never silent.
if ! gh auth status >/dev/null 2>&1; then
  echo "automerge.sh: gh not authenticated — cannot inspect PRs; failing loud (a failure must be reported, never silent)." >&2
  exit 2
fi

# Owner-only territory (CHARTE §8 — routine automerge). A pull request
# touching any of these is never merged by a machine, however green it is.
is_structural() {
  local f="$1"
  case "$f" in
    CHARTE.md)                 echo "modifies the charter" ; return 0 ;;
    */syntheses/*)             echo "touches a synthesis" ; return 0 ;;
    proposals/*)               echo "touches a bundle proposal" ; return 0 ;;
    .github/*|tools/*)         echo "modifies tooling or CI" ; return 0 ;;
  esac
  # A file under a bundle directory that does not yet exist on main = new bundle.
  if [[ "$f" == bundles/* ]]; then
    local b="${f#bundles/}"; b="${b%%/*}"
    if [ ! -d "$REPO_DIR/bundles/$b" ]; then
      echo "creates the bundle '$b'"; return 0
    fi
  fi
  return 1
}

WORK="$(mktemp -d "${TMPDIR:-/tmp}/wiki-automerge.XXXXXX")"
cleanup() { git -C "$REPO_DIR" worktree prune >/dev/null 2>&1; rm -rf "$WORK"; }
trap cleanup EXIT
cd "$REPO_DIR"
git fetch -q origin main 2>/dev/null

prs=$(gh pr list --state open --json number,headRefOid,title,isDraft,mergeable \
        --jq '.[] | [.number,.headRefOid,.isDraft,.mergeable,.title] | @tsv') || {
  echo "gh unavailable or not authenticated."; exit 2; }
[ -n "$prs" ] || { echo "No open pull requests."; exit 0; }

held=0
while IFS=$'\t' read -r n sha draft mergeable title; do
  [ -n "$n" ] || continue
  echo "=== PR #$n — $title (${sha:0:7})"

  [ "$draft" = "true" ] && { echo "    HELD: draft"; held=1; continue; }
  [ "$mergeable" = "MERGEABLE" ] || { echo "    HELD: not mergeable ($mergeable)"; held=1; continue; }

  # 1. CI — via `pr view`, the only JSON form gh exposes here for the checks.
  #    An empty conclusion = check still running: hold.
  roll=$(gh pr view "$n" --json statusCheckRollup \
           --jq '[.statusCheckRollup[] | (.conclusion // .state // "")] | @tsv' 2>/dev/null)
  if [ -z "$roll" ]; then echo "    HELD: no check found"; held=1; continue; fi
  bad=0
  for c in $roll; do
    case "$c" in SUCCESS|NEUTRAL|SKIPPED) ;; *) bad=1 ;; esac
  done
  if [ "$bad" != "0" ]; then echo "    HELD: CI not green or still running ($roll)"; held=1; continue; fi

  # 2. full local lint, denylist included
  git fetch -q origin "refs/pull/$n/head" 2>/dev/null || { echo "    HELD: cannot fetch"; held=1; continue; }
  wt="$WORK/pr-$n"
  git worktree add -q --detach "$wt" FETCH_HEAD 2>/dev/null || { echo "    HELD: cannot create worktree"; held=1; continue; }
  if ! (cd "$wt" && python3 tools/lint.py >/dev/null 2>&1); then
    echo "    HELD: local lint failed (denylist included)"
    (cd "$wt" && python3 tools/lint.py 2>&1 | sed 's/^/      /' | tail -5)
    git worktree remove -f "$wt" >/dev/null 2>&1; held=1; continue
  fi
  git worktree remove -f "$wt" >/dev/null 2>&1

  # 3. nothing structural
  blocker=""
  while read -r f; do
    [ -n "$f" ] || continue
    if reason=$(is_structural "$f"); then blocker="$f — $reason"; break; fi
  done < <(gh pr diff "$n" --name-only 2>/dev/null)
  if [ -n "$blocker" ]; then
    echo "    HELD for owner arbitration: $blocker"
    held=1; continue
  fi

  # 4. merge
  if [ "$DO_MERGE" = "1" ]; then
    if gh pr merge "$n" --merge --delete-branch >/dev/null 2>&1; then
      echo "    MERGED (routine: CI green, denylist ok, nothing structural)"
    else
      echo "    HELD: the merge failed"; held=1
    fi
  else
    echo "    ELIGIBLE for automatic merge (re-run with --merge)"
  fi
done <<< "$prs"

exit $held
