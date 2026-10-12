# Meta — the harness itself must be able to see red: a known-bad fixture
# fails the lint through the very helpers every other case relies on.
# An assertion that can never fire is not an assertion.
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)
mkdir -p "$sb/bundles/_meta/concepts"
printf '# Log\n' > "$sb/bundles/_meta/log.md"
cat > "$sb/bundles/_meta/concepts/broken.md" <<'EOF'
---
type: Concept
title: Broken
description: Known-bad fixture.
tags: [smoke]
status: draft
generated: { by: smoke/test, at: 2026-10-13T00:00:00Z }
sources:
  - { id: o, resource: "https://example.org/x", title: X }
---
Links [nowhere](/concepts/ghost.md).
EOF
regen "$sb"
run_lint "$sb"
lint_dirty "known-bad fixture fails through the harness helpers"
out_has "broken link" "…and the helpers surface the reason"

exit_case
