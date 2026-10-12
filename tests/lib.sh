# Test harness for the llm-wiki-template tooling — sourced by every case file.
#
# Hermetic by construction:
#   - every case runs against a throwaway sandbox COPY OF THE WORKING TREE
#     (uncommitted changes included — that is precisely what is being tested);
#   - no network, no remote, nothing written to $HOME: WIKI_DENYLIST is always
#     redirected to a scratch path inside the test area, so a real denylist on
#     the host machine cannot leak into the results;
#   - lint output is always written to a FILE and then grepped — never piped
#     into `grep -q` (under `set -o pipefail`, an early-exiting grep SIGPIPEs
#     the producer and inverts verdicts).

TEMPLATE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TESTS_TMP="$(mktemp -d "${TMPDIR:-/tmp}/llm-wiki-tests.XXXXXX")"
SANDBOX_N=0
FAILED=0
PASSED=0

# Point the denylist at a path that does not exist: cases that need a real one
# export their own before calling run_lint.
export WIKI_DENYLIST="$TESTS_TMP/no-denylist-by-default"

cleanup_all() { rm -rf "$TESTS_TMP"; }
trap cleanup_all EXIT

fail() { echo "  FAIL: $*"; FAILED=1; }
ok()   { echo "  ok: $*"; PASSED=$((PASSED + 1)); }

# new_sandbox — fresh copy of the working tree, no .git. Always called as
# `sb=$(new_sandbox)`, i.e. inside a command substitution: the counter would
# not survive that, so uniqueness comes from mktemp instead.
new_sandbox() {
  local sb
  sb="$(mktemp -d "$TESTS_TMP/sb.XXXXXX")"
  cp -a "$TEMPLATE_ROOT/." "$sb/"
  rm -rf "$sb/.git"
  echo "$sb"
}

# git_sandbox <sb> — turn a sandbox into a committed local git repository
# (no remote: commit.sh then takes its "committed locally only" branch).
git_sandbox() {
  git -C "$1" init -q
  git -C "$1" config user.email "tests@invalid"
  git -C "$1" config user.name "Template Tests"
  git -C "$1" add -A
  git -C "$1" commit -qm "template import"
}

# run_lint <sb> [args...] — run the sandbox lint, capture output in a file.
# Never returns non-zero: assertions inspect $LINT_RC and $LINT_OUT.
# The output file lives OUTSIDE the sandbox: `git add -A` in commit.sh absorbs
# everything in the tree, and a stray output file would silently feed the
# "nothing to commit" verdicts.
run_lint() {
  local sb="$1"; shift
  LINT_OUT="$TESTS_TMP/lint.out"
  (cd "$sb" && python3 tools/lint.py "$@") >"$LINT_OUT" 2>&1
  LINT_RC=$?
  return 0
}

regen() { (cd "$1" && python3 tools/gen-index.py >/dev/null); }

lint_clean()  { if [ "$LINT_RC" -eq 0 ]; then ok "$1"; else fail "$1 (exit $LINT_RC)"; cat "$LINT_OUT" | sed 's/^/        /'; fi; }
lint_dirty()  { if [ "$LINT_RC" -ne 0 ]; then ok "$1"; else fail "$1 (lint unexpectedly passed)"; fi; }

# Output assertions: PATTERN first, human description second.
out_has()     { if grep -qF -- "$1" "$LINT_OUT"; then ok "$2"; else fail "$2 (missing: '$1')"; fi; }
out_has_re()  { if grep -qE -- "$1" "$LINT_OUT"; then ok "$2"; else fail "$2 (missing regex: '$1')"; fi; }
out_lacks()   { if grep -qF -- "$1" "$LINT_OUT"; then fail "$2 (unexpected: '$1')"; else ok "$2"; fi; }

cmd_ok()   { local d="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$d"; else fail "$d"; fi; }
cmd_fail() { local d="$1"; shift; if "$@" >/dev/null 2>&1; then fail "$d (command succeeded)"; else ok "$d"; fi; }

# File assertions: FILE, PATTERN, human description.
file_has()  { if grep -qF -- "$2" "$1"; then ok "$3"; else fail "$3 (missing in $1: '$2')"; fi; }
file_lacks() { if grep -qF -- "$2" "$1"; then fail "$3 (unexpected in $1: '$2')"; else ok "$3"; fi; }

exit_case() { echo "  ($PASSED assertions)"; exit "$FAILED"; }
