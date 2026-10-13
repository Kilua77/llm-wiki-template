# Canary — the voluntary leak test of docs/SETUP.md (path B8), automated:
# one scratch page carrying every probe, and EVERY one of them must produce
# its own error line. A gate never seen closing is not a gate.
# Self-contained: it builds its own scratch bundle, so it runs on the
# template AND on an initialized wiki (where the demo bundle is gone).
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)
deny="$TESTS_TMP/canary-denylist.txt"
printf 'zephyr-project\n' > "$deny"

mkdir -p "$sb/bundles/_canary/concepts"
printf '# Log\n' > "$sb/bundles/_canary/log.md"
regen "$sb"
probe="$sb/bundles/_canary/concepts/probe.md"
cat > "$probe" <<'EOF'
---
type: Concept
title: Canary
description: Voluntary leak probes.
tags: [smoke]
status: draft
generated: { by: smoke/test, at: 2026-10-13T00:00:00Z }
sources:
  - { id: o, resource: "https://example.org/c", title: C }
---
- email: someone@somewhere.example.org
- key: -----BEGIN OPENSSH PRIVATE KEY-----
- aws: AKIAIOSFODNN7EXAMPLE
- github: ghp_16CharactersXXXXXXXXXXXXXXXXXXXXXXXX
- bearer: Bearer abcdefghijklmnopqrstuvwxyzabcdef
- notion: https://www.notion.so/leaked-page
- ip: 203.0.113.99
- private motif: zephyr-project
EOF
regen "$sb"

WIKI_DENYLIST="$deny" run_lint "$sb"
lint_dirty "canary page fails the lint"
for label in "email address" "private key" "API token" "bearer token" \
             "private Notion URL" "public IP address" "denylisted term"; do
  out_has "$label" "probe '$label' produced its own error"
done
export WIKI_DENYLIST="$TESTS_TMP/no-denylist-by-default"

rm -f "$probe"; regen "$sb"
run_lint "$sb"
lint_clean "canary removed: tree clean again"

exit_case
