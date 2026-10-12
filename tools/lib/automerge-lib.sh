# Pure predicates of the routine automerge (CHARTE §8) — extracted so they can
# be tested without `gh`, worktrees or a remote. Sourced by tools/automerge.sh
# and by tests/cases/20-automerge-lib.sh. The caller MUST define REPO_DIR
# (the repository root) before calling is_structural.

# Owner-only territory (CHARTE §8 — routine automerge). A pull request
# touching any of these is never merged by a machine, however green it is.
# Echoes the reason and returns 0 when structural; returns 1 otherwise.
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
