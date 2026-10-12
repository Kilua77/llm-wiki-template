# Publishability scan (CHARTE §2) — each generic pattern produces its own error.
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)
probe="$sb/bundles/example/concepts/probe.md"
mkprobe() {
  cat > "$probe"
  regen "$sb"
}

probe_and_expect() {  # <label-asserted-in-output> <heredoc-content-on-stdin>
  local label="$1"
  cat > "$probe"
  regen "$sb"
  run_lint "$sb"
  lint_dirty "probe with $label rejected"
  out_has "$label" "…and the error names '$label'"
  rm -f "$probe"
  regen "$sb"
}

probe_and_expect "email address" <<'EOF'
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
Contact someone@somewhere.fr for details.
EOF

probe_and_expect "private key" <<'EOF'
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
-----BEGIN RSA PRIVATE KEY-----
EOF

probe_and_expect "API token" <<'EOF'
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
Token: AKIAIOSFODNN7EXAMPLE
EOF

probe_and_expect "API token" <<'EOF'
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
Token: ghp_16CharactersXXXXXXXXXXXXXXXXXXXXXXXX
EOF

probe_and_expect "bearer token" <<'EOF'
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
Authorization: Bearer abcdefghijklmnopqrstuvwxyzabcdef
EOF

probe_and_expect "private Notion URL" <<'EOF'
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
See https://app.notion.com/somepage for details.
EOF

# public IP flagged, private ranges ignored
probe_and_expect "public IP address" <<'EOF'
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
The server lives at 203.0.113.42 behind 192.168.1.4 and 10.0.0.9.
EOF

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
Loopback 127.0.0.1, LAN 192.168.0.10, range 172.16.3.4 — all private, none flagged.
EOF
regen "$sb"
run_lint "$sb"
lint_clean "private IP ranges not flagged"
rm -f "$probe"; regen "$sb"
run_lint "$sb"
lint_clean "tree clean after probes"

exit_case
