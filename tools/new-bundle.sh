#!/usr/bin/env bash
# Owner-side helper mechanizing CHARTE §10.4 — create a VALIDATED bundle.
#
# An agent NEVER runs this: bundles are created by the owner, after an explicit
# "yes" to a filed proposal (§10). The script refuses to run without either a
# proposal to consume (--from-proposal) or the explicit --i-am-the-owner flag.
#
# It creates the skeleton, adds the inventory row (the authoritative registry —
# the lint refuses any non-inventoried directory), archives the proposal, and
# regenerates the indexes. It does NOT commit: the mandatory relocation sweep
# (§10.5) belongs to the same commit, and it is a judgment call, not a script.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME=""
SCOPE=""
ANTI=""
PROPOSAL=""
OWNER=0

usage() {
  cat <<'USAGE'
Usage: tools/new-bundle.sh <name> --scope "<one sentence>" --anti-scope "<one sentence>"
                           [--from-proposal <slug>] [--i-am-the-owner]

  <name>                  kebab-case bundle name
  --scope                 one-sentence scope for the inventory row
  --anti-scope            what does NOT go there (out-of-scope column)
  --from-proposal <slug>  archive proposals/<date>-<slug>.md to proposals/validated/
  --i-am-the-owner        required when creating a bundle with no filed proposal

Run by the owner only, after an explicit yes (CHARTE §10). Does not commit —
finish with the relocation sweep (§10.5), then tools/commit.sh.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --scope) SCOPE="${2:?--scope requires an argument}"; shift ;;
    --anti-scope) ANTI="${2:?--anti-scope requires an argument}"; shift ;;
    --from-proposal) PROPOSAL="${2:?--from-proposal requires a slug}"; shift ;;
    --i-am-the-owner) OWNER=1 ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "new-bundle.sh: unknown argument: $1" >&2; usage >&2; exit 64 ;;
    *) [ -z "$NAME" ] && NAME="$1" || { echo "new-bundle.sh: unexpected argument: $1" >&2; exit 64; } ;;
  esac
  shift
done

[ -n "$NAME" ] && [ -n "$SCOPE" ] && [ -n "$ANTI" ] || { usage >&2; exit 64; }
[[ "$NAME" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || {
  echo "new-bundle.sh: name must be kebab-case (got: $NAME)" >&2; exit 1; }
case "$SCOPE$ANTI" in
  *\|*) echo "new-bundle.sh: pipes are not allowed in scope text (markdown table)" >&2; exit 1 ;;
esac

cd "$HERE"
[ -d "bundles/$NAME" ] && { echo "new-bundle.sh: bundles/$NAME already exists" >&2; exit 1; }
ROWPAT="$(printf '| `%s`' "$NAME")"
grep -qF "$ROWPAT" CHARTE.md && { echo "new-bundle.sh: $NAME already in the inventory" >&2; exit 1; }

# A validated bundle consumes a filed proposal — or an explicit owner override.
PROPFILE=""
if [ -n "$PROPOSAL" ]; then
  PROPFILE="$(ls proposals/*-"$PROPOSAL".md 2>/dev/null || true)"
  [ "$(echo "$PROPFILE" | grep -c .)" = 1 ] || {
    echo "new-bundle.sh: no unique proposals/*-$PROPOSAL.md found" >&2; exit 1; }
elif [ "$OWNER" != 1 ]; then
  echo "new-bundle.sh: refusing — no filed proposal and no --i-am-the-owner." \
       "CHARTE §10: an agent proposes, the owner decides. File the proposal" \
       "first, or pass --i-am-the-owner if you are the owner acting directly." >&2
  exit 1
fi

# Skeleton (CHARTE §4) + inventory row (the authoritative registry).
mkdir -p "bundles/$NAME"/{concepts,entities,syntheses,references,raw}
printf '# Log\n' > "bundles/$NAME/log.md"
TODAY="$(date +%F)"
python3 - "$NAME" "$SCOPE" "$ANTI" "Active (validated $TODAY)" <<'PY'
import sys
from pathlib import Path

name, scope, anti, status = sys.argv[1:5]
row = f"| `{name}` | {scope} | {anti} | {status} |\n"
p = Path("CHARTE.md")
text = p.read_text(encoding="utf-8")
marker = "<!-- inventory:end -->"
if marker not in text:
    raise SystemExit("new-bundle.sh: inventory markers missing from CHARTE.md")
p.write_text(text.replace(marker, row + marker, 1), encoding="utf-8")
PY

if [ -n "$PROPFILE" ]; then
  mkdir -p proposals/validated
  git mv "$PROPFILE" "proposals/validated/$(basename "$PROPFILE")"
fi

python3 tools/gen-index.py >/dev/null
python3 tools/lint.py || {
  echo "new-bundle.sh: lint failed after creation — fix CHARTE.md and retry" >&2
  exit 1
}

cat <<'NEXT'
Bundle created — do NOT stop here (CHARTE §10.5):

  Relocation sweep, mandatory, same commit or the next: review every page
  carrying routing_review (python3 tools/lint.py lists them) and every page
  the new scope could claim. Move what belongs here (trace it: new path,
  redirect inbound links, drop routing_review, log entry in BOTH bundles),
  or keep it with an updated routing_review.reason. A bundle created without
  this sweep leaves the wiki in the exact state that motivated its creation.

  Then commit:
    tools/commit.sh "wiki($NAME): creation — bundle validated by the owner" "human:owner"
NEXT
