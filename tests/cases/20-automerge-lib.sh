# automerge predicates (CHARTE §8) — sourced from tools/lib/automerge-lib.sh,
# no gh, no worktree, no remote needed. The four-conditions orchestration
# itself is exercised end-to-end by SETUP step B5 (PR test) and CI.
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)
REPO_DIR="$sb"          # what is_structural resolves bundle existence against
. "$sb/tools/lib/automerge-lib.sh"

check_structural() {  # <file> <expected: structural|routine>
  local f="$1" want="$2" reason rc
  reason=$(is_structural "$f"); rc=$?
  if [ "$want" = structural ] && [ "$rc" -eq 0 ]; then
    ok "$f → structural ($reason)"
  elif [ "$want" = routine ] && [ "$rc" -ne 0 ]; then
    ok "$f → routine"
  else
    fail "$f → expected $want, got ${reason:-routine} (rc=$rc)"
  fi
}

check_structural "CHARTE.md"                     structural
check_structural "bundles/example/syntheses/s.md" structural
check_structural "proposals/2026-10-13-new.md"   structural
check_structural ".github/workflows/lint.yml"    structural
check_structural "tools/lint.py"                 structural
check_structural "tools/lib/automerge-lib.sh"    structural
check_structural "bundles/example/concepts/a.md" routine
check_structural "bundles/example/raw/x.md"      routine
check_structural "bundles/example/log.md"        routine
check_structural "README.md"                     routine
check_structural "bundles/brand-new-bundle/concepts/a.md" structural
check_structural "docs/ARCHITECTURE.md"          routine

# the reason is echoed (it feeds the HOLD line of the report)
reason=$(is_structural "CHARTE.md")
if echo "$reason" | grep -qF "modifies the charter"; then ok "structural reasons are human-readable"; else fail "reason not echoed: '$reason'"; fi
reason=$(is_structural "bundles/ghost-bundle/x.md")
if echo "$reason" | grep -qF "creates the bundle"; then ok "new-bundle detection names the bundle"; else fail "reason not echoed: '$reason'"; fi

exit_case
