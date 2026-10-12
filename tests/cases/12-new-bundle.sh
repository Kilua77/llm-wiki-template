# new-bundle.sh (CHARTE §10.4) — owner-side mechanization and its refusals.
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)
git_sandbox "$sb"

# refuses without a filed proposal and without the owner override
cmd_fail "refuses without proposal or --i-am-the-owner" \
  bash "$sb/tools/new-bundle.sh" proj-x --scope "Project X" --anti-scope "Nothing else"

out=$(bash "$sb/tools/new-bundle.sh" proj-x --scope "S" --anti-scope "A" 2>&1)
if echo "$out" | grep -qF "an agent proposes, the owner decides"; then
  ok "refusal cites the governance rule"
else
  fail "refusal does not cite the governance rule"
fi
[ -d "$sb/bundles/proj-x" ] && fail "bundle created despite refusal" || ok "no bundle created"

# non-kebab-case name
cmd_fail "non-kebab-case name refused" \
  bash "$sb/tools/new-bundle.sh" Proj_X --scope "S" --anti-scope "A" --i-am-the-owner

# pipe in scope text (markdown table safety)
cmd_fail "pipe in scope text refused" \
  bash "$sb/tools/new-bundle.sh" proj-x --scope "A | B" --anti-scope "A" --i-am-the-owner

# duplicate: create once, then the same name again
bash "$sb/tools/new-bundle.sh" proj-x --scope "Project X knowledge" --anti-scope "Anything else" --i-am-the-owner >/dev/null 2>&1
[ -d "$sb/bundles/proj-x/concepts" ] && ok "bundle skeleton created" || fail "skeleton missing"
file_has "$sb/CHARTE.md" "| \`proj-x\`" "inventory row added"
cmd_fail "duplicate bundle name refused" \
  bash "$sb/tools/new-bundle.sh" proj-x --scope "S" --anti-scope "A" --i-am-the-owner

# the --from-proposal path: file a proposal, consume it, check the archive
sb2=$(new_sandbox)
git_sandbox "$sb2"
cat > "$sb2/proposals/2026-10-13-proj-y.md" <<'EOF'
---
type: Bundle Proposal
title: proj-y
description: Proposed bundle for the proposal path test.
status: draft
generated: { by: smoke/test, at: 2026-10-13T00:00:00Z }
---

## Motivation
No existing bundle fits.

## Scope
Project Y knowledge.

## Out-of-scope
Everything else.

## Initial pages
- Page one

## Overlaps
None.
EOF
(cd "$sb2" && git add -A && git commit -qm proposal)
out=$(cd "$sb2" && bash tools/new-bundle.sh proj-y --scope "Project Y" --anti-scope "Else" --from-proposal proj-y 2>&1)
if [ -d "$sb2/bundles/proj-y/concepts" ]; then ok "--from-proposal creates the skeleton"; else fail "--from-proposal did not create the skeleton: $out"; fi
[ -f "$sb2/proposals/validated/2026-10-13-proj-y.md" ] && ok "proposal archived to validated/" || fail "proposal not archived"
file_has "$sb2/CHARTE.md" "| \`proj-y\`" "inventory row added (proposal path)"
(cd "$sb2" && python3 tools/lint.py >/dev/null 2>&1)
if [ $? -eq 0 ]; then ok "lint clean after --from-proposal creation"; else fail "lint dirty after --from-proposal creation"; fi
out=$(echo "$out" | grep -c "Relocation sweep")
if [ "$out" -ge 1 ]; then ok "final block reminds the §10.5 relocation sweep"; else fail "no relocation-sweep reminder"; fi

exit_case
