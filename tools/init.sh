#!/usr/bin/env bash
# Personalize a fresh clone of the llm-wiki-template into your own wiki.
#
# What it does, in order:
#   1. preflight — git, python3 + PyYAML, flock, bash >= 4, clean tree, marker present
#   2. asks for confirmation (unless --yes)
#   3. removes the demonstrative `example` bundle and its inventory row
#      (kept with --keep-example)
#   4. regenerates indexes and runs the lint — must exit clean, else rollback
#   5. wires the git hooks (git never copies hooks on clone — the classic miss)
#   6. removes the template marker and makes the initial commit
#   7. optionally creates the private GitHub repository (--github owner/name)
#
# What it NEVER does: write outside this repository (the denylist command is
# printed, never run), create a remote without an explicit flag, touch rulesets,
# secrets or GitHub Apps (those are documented manual steps — docs/SETUP.md).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MARKER="$HERE/.wiki-template"
KEEP_EXAMPLE=0
YES=0
GITHUB=""

usage() {
  cat <<'USAGE'
Usage: tools/init.sh [--keep-example] [--yes] [--github <owner>/<name>]

  --keep-example        keep the demonstrative bundles/example (format demo)
  --yes                 do not ask for confirmation
  --github owner/name   create that private GitHub repository and push to it
                        (requires the gh CLI, authenticated)

Run from a fresh clone of the template. Removes the example bundle, wires the
git hooks, and makes the initial commit. Everything else lives in docs/SETUP.md.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --keep-example) KEEP_EXAMPLE=1 ;;
    --yes) YES=1 ;;
    --github) GITHUB="${2:?--github requires an <owner>/<name> argument}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "init.sh: unknown argument: $1" >&2; usage >&2; exit 64 ;;
  esac
  shift
done

# The marker is what makes this a template clone rather than a live wiki.
[ -f "$MARKER" ] || {
  echo "init.sh: .wiki-template marker not found — this directory is already" \
       "initialized, or is not a fresh template clone." >&2
  exit 1
}

# --- 1. preflight -------------------------------------------------------------
command -v git     >/dev/null 2>&1 || { echo "init.sh: git not found" >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "init.sh: python3 not found" >&2; exit 1; }
command -v flock   >/dev/null 2>&1 || { echo "init.sh: flock(1) not found (util-linux)" >&2; exit 1; }
if [ "${BASH_VERSINFO[0]:-0}" -lt 4 ]; then
  echo "init.sh: bash >= 4 required" >&2; exit 1
fi
python3 -c "import yaml" 2>/dev/null || {
  echo "init.sh: PyYAML missing — run: pip3 install --user -r tools/requirements.txt" >&2
  exit 1
}
cd "$HERE"
[ -z "$(git status --porcelain)" ] || {
  echo "init.sh: working tree not clean — commit or stash first" >&2; exit 1
}

# --- 2. confirmation ----------------------------------------------------------
if [ "$YES" != 1 ]; then
  echo "This will:"
  [ "$KEEP_EXAMPLE" = 1 ] || echo "  - remove bundles/example and its inventory row"
  echo "  - regenerate indexes and run the lint (must be clean)"
  echo "  - set core.hooksPath=.githooks"
  echo "  - remove .wiki-template and make the initial commit"
  [ -n "$GITHUB" ] && echo "  - create the private GitHub repository $GITHUB and push"
  printf "Proceed? [y/N] "
  read -r answer
  case "$answer" in
    y|Y|yes|Yes|YES) ;;
    *) echo "Aborted — nothing was touched."; exit 130 ;;
  esac
fi

rollback() {
  git checkout -- CHARTE.md bundles 2>/dev/null || true
  echo "init.sh: rolled back — the template is unchanged." >&2
}

# --- 3. remove the example bundle and its inventory row -----------------------
if [ "$KEEP_EXAMPLE" != 1 ]; then
  rm -rf bundles/example
  python3 - <<'PY'
from pathlib import Path
p = Path("CHARTE.md")
lines = p.read_text(encoding="utf-8").splitlines(keepends=True)
out = [l for l in lines if not l.startswith("| `example`")]
if len(out) == len(lines):
    raise SystemExit("init.sh: no `example` row found in the inventory — aborting")
p.write_text("".join(out), encoding="utf-8")
PY
fi

# --- 4. indexes + lint (rollback on failure) ----------------------------------
python3 tools/gen-index.py >/dev/null
if ! python3 tools/lint.py; then
  rollback
  exit 1
fi

# --- 5. hooks -----------------------------------------------------------------
git config core.hooksPath .githooks

# --- 6. marker + initial commit ----------------------------------------------
rm -f "$MARKER"
tools/commit.sh "chore(init): personalize repository" "process:init"

# --- 7. optional remote -------------------------------------------------------
if [ -n "$GITHUB" ]; then
  if command -v gh >/dev/null 2>&1; then
    if ! gh repo create "$GITHUB" --private --source . --push; then
      echo "init.sh: gh repo create failed — create the remote manually, then:" \
           "git remote add origin <url> && git push -u origin main" >&2
    fi
  else
    echo "init.sh: gh CLI not found — create the repository on GitHub, then:" \
         "git remote add origin <url> && git push -u origin main" >&2
  fi
fi

cat <<'NEXT'

Initialized — your wiki is live, and your agents are built to guide you.

Your first session: point an agent at AGENTS.md and tell it what you want —

  - "answer this question"        → it searches the wiki first, cites paths
  - "add this page/article"       → it ingests (raw + reference + pages)
  - "ingest this spec (Word/PDF)" → tools/ingest-doc.sh, then it proposes
                                    Constraints/Decisions/Playbooks from it
  - "map our codebase"            → it orients by history and churn, mines the
                                    tests, and extracts only the non-obvious
  - "start a wiki about X"        → it drafts a bundle proposal; you approve

It explains each rule as it applies it (one sentence, with its charter §),
shows one example before running any series, and never decides structural
things for you — silence means no.

Behind the scenes, when you want depth:

  1. docs/IMPLEMENTATION-GUIDE.md — the phased build manual (you are past
     phase 1; gates, remote+CI, weekly loop and the rest follow it)
  2. Your private denylist — the one releasability check that cannot live in
     the repository:
       mkdir -p ~/.config/wiki-lint && ${EDITOR:-vi} ~/.config/wiki-lint/denylist.txt
     One lowercase term per line, # comments allowed. Never commit it.
     (A different location can be exported as WIKI_DENYLIST.)
  3. bash tests/run-tests.sh — prove the whole toolchain, any time
  4. docs/ARCHITECTURE.md — the assembled system in one picture
NEXT
