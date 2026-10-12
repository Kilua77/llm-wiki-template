#!/usr/bin/env bash
# Run the versioned test suite: every cases/*.sh file, each in its own sandbox.
#
#   tests/run-tests.sh              # everything
#   tests/run-tests.sh publish      # only case files whose name matches
#
# A case file passes when it exits 0 (its assertions use lib.sh). Exit code of
# the runner: 1 if any case failed. Requires: bash, python3 + PyYAML, git.
# Optional: jsonschema (schema cases are skipped without it).
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
FILTER="${1:-}"

pass=0; fail=0; skip=0
shopt -s nullglob
for c in "$HERE"/cases/*.sh; do
  name="$(basename "$c" .sh)"
  if [ -n "$FILTER" ] && [[ "$name" != *"$FILTER"* ]]; then continue; fi
  out="$(bash "$c" 2>&1)"; rc=$?
  if [ "$rc" -eq 0 ]; then
    pass=$((pass + 1)); printf 'PASS  %s\n' "$name"
    [ -z "${VERBOSE:-}" ] || printf '%s\n' "$out" | sed 's/^/      /'
  else
    fail=$((fail + 1)); printf 'FAIL  %s\n' "$name"
    printf '%s\n' "$out" | sed 's/^/      /'
  fi
done
shopt -u nullglob

echo "----------------------------------------"
echo "cases: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
