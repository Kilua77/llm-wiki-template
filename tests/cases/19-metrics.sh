# metrics.py (CHARTE §8.F) — the weekly metrics block, from log telemetry.
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)
B="$sb/bundles/_m"
mkdir -p "$B/concepts"

cat > "$B/concepts/alpha.md" <<'EOF'
---
type: Concept
title: Alpha
description: Cited page.
tags: [smoke]
status: stable
generated: { by: smoke/test, at: 2026-10-13T00:00:00Z }
sources:
  - { id: o, resource: "https://example.org/a", title: A }
---
Content.
EOF
cat > "$B/concepts/never-logged.md" <<'EOF'
---
type: Concept
title: Never logged
description: Dead-weight page, never cited in any log entry.
tags: [smoke]
status: draft
generated: { by: smoke/test, at: 2026-10-13T00:00:00Z }
sources:
  - { id: o, resource: "https://example.org/n", title: N }
---
Content.
EOF
# link targets for the log entries (the lint checks links in log.md too)
mkdir -p "$B/references"
cat > "$B/references/some.md" <<'EOF'
---
type: Reference
title: Some source
description: Log link target.
tags: [smoke]
status: stable
generated: { by: smoke/test, at: 2026-10-13T00:00:00Z }
sources:
  - { id: o, resource: "https://example.org/some", title: Some }
---
Digest.
EOF
cat > "$B/concepts/old.md" <<'EOF'
---
type: Concept
title: Old page
description: Log link target, old entry.
tags: [smoke]
status: stable
generated: { by: smoke/test, at: 2026-09-01T00:00:00Z }
sources:
  - { id: o, resource: "https://example.org/old", title: Old }
---
Content.
EOF
TODAY=$(date +%F)
OLD=$(date -d "-40 days" +%F 2>/dev/null || python3 -c "from datetime import date,timedelta;print((date.today()-timedelta(days=40)).isoformat())")
cat > "$B/log.md" <<EOF
# Log

## $TODAY
* **Creation**: [Alpha](concepts/alpha.md) — created. (smoke/test)
* **Ingest**: [Some source](references/some.md) — ingested. (smoke/test)
* **Query-miss**: "qmd hybrid latency" — no coverage (smoke/test)
* **Update**: [Alpha](concepts/alpha.md) — refreshed. (smoke/test)

## $OLD
* **Creation**: [Old page](concepts/old.md) — long ago. (smoke/test)
EOF
regen "$sb"

# 1. actions counted in the window; old entries excluded by the 7-day default
out="$TESTS_TMP/metrics.out"
(cd "$sb" && python3 tools/metrics.py) > "$out"
file_has "$out" "| _m | 1 | 1 | 1 |" "actions per bundle table counts the window's entries"
file_has "$out" '"qmd hybrid latency" — _m (smoke/test)' "Query-miss extracted with term and actor"
file_has "$out" "never-logged.md" "dead weight (never cited in any log entry) listed"
if grep -q "concepts/old.md" "$out"; then fail "old page counted as dead weight (it IS cited — old.md is named in the old entry)"; else ok "pages cited even in old entries are not dead weight"; fi

# 2. --all widens the window; exit code stays 0
(cd "$sb" && python3 tools/metrics.py --all) > "$out"
file_has "$out" "| _m | 2 | 1 | 1 |" "--all counts entries outside the default window"

# 3. threshold signal: warning line, exit 0 (owner decision, not a failure)
WIKI_PAGES_THRESHOLD=2 sh -c "cd '$sb' && python3 tools/metrics.py" > "$out"; rc=$?
file_has "$out" "⚠ threshold reached — owner decides the search tier-up" "threshold warning fired"
if [ "$rc" = "0" ]; then ok "threshold never fails the run (exit 0)"; else fail "metrics exited $rc on threshold"; fi

# 4. contested + routing_review listing with aging
python3 - "$B/concepts/alpha.md" <<'EOF'
import sys
p = sys.argv[1]
t = open(p).read().replace("generated:",
  "contested: sources disagree on the core claim\nrouting_review: { reason: closest fit, candidate: elsewhere, since: 2026-09-01 }\ngenerated:", 1)
open(p, "w").write(t)
EOF
(cd "$sb" && python3 tools/metrics.py) > "$out"
file_has "$out" "### Contested" "contested section present"
file_has "$out" "d since first log mention" "contested age computed from the first log mention"
file_has "$out" "### Routing review" "routing review section present"
file_has "$out" ", candidate \`elsewhere\`" "routing candidate shown"

run_lint "$sb"  # the fixtures stay lint-clean apart from the sandbox warning
lint_clean "fixtures lint clean (informational fields only)"

exit_case
