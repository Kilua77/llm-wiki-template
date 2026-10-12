# Synthesis invariants (CHARTE §6.5) — the strictest regime in the charter.
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)
B="$sb/bundles/_t"
mkdir -p "$B/concepts" "$B/syntheses"

build() {  # canonical fixture: one knowledge page, one synthesis covering it
  rm -rf "$B"; mkdir -p "$B/concepts" "$B/syntheses"
  cat > "$B/log.md" <<'EOF'
# Log
EOF
  cat > "$B/concepts/base-a.md" <<'EOF'
---
type: Concept
title: Base A
description: Covered knowledge page.
tags: [synth-test]
status: stable
generated: { by: smoke/test, at: 2026-01-01T00:00:00Z }
sources:
  - { id: o, resource: "https://example.org/a", title: A }
---
Root page. Links: [the synthesis](/syntheses/synth.md).
EOF
  cat > "$B/syntheses/synth.md" <<'EOF'
---
type: Synthesis
title: Synth
description: Test synthesis.
tags: [synth-test]
status: draft
covers: [/concepts/base-a.md]
generated: { by: smoke/test, at: 2026-02-01T00:00:00Z }
sources:
  - { id: o, resource: "https://example.org/s", title: S }
---
Covers [Base A](/concepts/base-a.md).
EOF
  regen "$sb"
}

build
run_lint "$sb"
lint_clean "canonical synthesis fixture passes"

# 1. covers removed
sed -i '/^covers:/d' "$B/syntheses/synth.md"
run_lint "$sb"
lint_dirty "synthesis without covers rejected"
out_has "must declare \`covers\`" "…with the §6.5 message"

# 2. covers a ghost
build
sed -i 's|/concepts/base-a.md|/concepts/ghost.md|' "$B/syntheses/synth.md"
run_lint "$sb"
lint_dirty "covers pointing at a ghost rejected"
out_has "covers a page that does not exist" "…and names the target"

# 3. target exists but is not linked in the body
build
sed -i 's|Covers \[Base A\](/concepts/base-a.md).|No links here.|' "$B/syntheses/synth.md"
run_lint "$sb"
lint_dirty "unlinked covers target rejected"
out_has "without linking it in the body" "…with the linkage message"

# 4. synthesis of a synthesis
build
cat > "$B/syntheses/synth2.md" <<'EOF'
---
type: Synthesis
title: Synth 2
description: Derives from the other synthesis.
tags: [synth-test]
status: draft
covers: [/syntheses/synth.md]
generated: { by: smoke/test, at: 2026-03-01T00:00:00Z }
sources:
  - { id: o, resource: "https://example.org/s2", title: S2 }
---
Covers [Synth](/syntheses/synth.md).
EOF
regen "$sb"
run_lint "$sb"
lint_dirty "synthesis of a synthesis rejected"
out_has "covers another synthesis" "…with the no-nesting message"

# 5. behind its input (covered page newer than the synthesis)
build
sed -i 's/at: 2026-01-01T00:00:00Z/at: 2026-06-01T00:00:00Z/' "$B/concepts/base-a.md"
run_lint "$sb"
lint_dirty "synthesis behind its input rejected"
out_has "behind its input" "…with the derived-freshness message"

# 6. stable without a human review
build
sed -i 's/^status: draft/status: stable/' "$B/syntheses/synth.md"
run_lint "$sb"
lint_dirty "stable synthesis without human verified rejected"
out_has "without a human \`verified\`" "…with the review message"

# 7. citing a synthesis as a source
build
cat > "$B/concepts/base-b.md" <<'EOF'
---
type: Concept
title: Base B
description: Cites a synthesis as a source — forbidden.
tags: [synth-test]
status: draft
generated: { by: smoke/test, at: 2026-02-15T00:00:00Z }
sources:
  - { id: s, resource: "/syntheses/synth.md", title: Synth }
---
Links [the synthesis](/syntheses/synth.md).
EOF
regen "$sb"
run_lint "$sb"
lint_dirty "page citing a synthesis in sources rejected"
out_has "a synthesis is never a source" "…with the loop-cutter message"

# 8. adrift from its theme (≥ 3 uncovered same-tag pages) — warning, not error
build
for p in base-b base-c base-d; do
  cat > "$B/concepts/$p.md" <<EOF
---
type: Concept
title: $p
description: Same-tag uncovered page.
tags: [synth-test]
status: draft
generated: { by: smoke/test, at: 2026-02-10T00:00:00Z }
sources:
  - { id: o, resource: "https://example.org/$p", title: $p }
---
Uncovered.
EOF
done
regen "$sb"
run_lint "$sb"
lint_clean "adrift synthesis stays a warning (exit 0)"
out_has "adrift from its theme" "…and the adrift warning fires"

# 9. theme maturity signal (informational NOTE, proposes nothing)
build
for i in 1 2 3 4 5; do
  cat > "$B/concepts/ripe-$i.md" <<EOF
---
type: Concept
title: Ripe $i
description: Page of a mature theme.
tags: [ripe-theme]
status: draft
generated: { by: smoke/test, at: 2026-02-10T00:00:00Z }
sources:
  - { id: o, resource: "https://example.org/r$i", title: R }
---
Content $i.
EOF
done
for i in 6 7 8 9; do
  cat > "$B/concepts/other-$i.md" <<EOF
---
type: Concept
title: Other $i
description: Unrelated page to keep the tag minority.
tags: [unrelated]
status: draft
generated: { by: smoke/test, at: 2026-02-10T00:00:00Z }
sources:
  - { id: o, resource: "https://example.org/o$i", title: O }
---
Content $i.
EOF
done
regen "$sb"
run_lint "$sb"
lint_clean "mature theme without synthesis stays a NOTE (exit 0)"
out_has "no synthesis — a synthesis MAY be proposed" "…and proposes, never creates"

exit_case
