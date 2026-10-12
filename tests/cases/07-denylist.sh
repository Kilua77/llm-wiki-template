# Private denylist behaviour (CHARTE §2) — scratch file through WIKI_DENYLIST,
# never the host's real one; loud warning when absent; ignored in --ci.
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)
probe="$sb/bundles/example/concepts/probe.md"
mk() {
  cat > "$probe" <<'EOF'
---
type: Concept
title: Probe
description: Probe page.
tags: [smoke]
status: draft
generated: { by: smoke/test, at: 2026-10-13T00:00:00Z }
sources:
  - { id: o, resource: "https://example.org/p", title: P }
---
The zephyr-project codename appears here.
EOF
  regen "$sb"
}

# 1. a denylisted term fails the local lint
deny="$TESTS_TMP/denylist.txt"
printf 'zephyr-project\n' > "$deny"
mk
WIKI_DENYLIST="$deny" run_lint "$sb"
lint_dirty "denylised term fails the local lint"
out_has "denylisted term" "…with the denylist message"

# 2. denylist absent → loud warning, exit 0
export WIKI_DENYLIST="$TESTS_TMP/absent-denylist"
run_lint "$sb"
lint_clean "absent denylist: warning, not an error (exit 0)"
out_has "denylist missing" "…and the warning is loud"
unset WIKI_DENYLIST

# 3. --ci ignores the denylist entirely (CI cannot see it)
WIKI_DENYLIST="$deny" run_lint "$sb" --ci
lint_clean "--ci ignores the denylist (structural CI cannot see it)"
out_lacks "denylisted term" "…no denylist hit in CI mode"
unset WIKI_DENYLIST
# restore the harness default so the host's real denylist never leaks back in
export WIKI_DENYLIST="$TESTS_TMP/no-denylist-by-default"

rm -f "$probe"; regen "$sb"
exit_case
