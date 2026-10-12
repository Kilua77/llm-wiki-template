# Enum values, date shapes, verified/routing_review forms (CHARTE §5).
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)
page="$sb/bundles/example/concepts/llm-wiki-pattern.md"
cp "$page" "$TESTS_TMP/page.bak"

# invalid status
sed -i 's/^status: .*/status: finalized/' "$page"; regen "$sb"
run_lint "$sb"
lint_dirty "invalid status rejected"
out_has_re "invalid status .finalized." "…and the status is named"

# stale_after as a datetime (on the page that actually carries one)
okf="$sb/bundles/example/entities/open-knowledge-format.md"
cp "$okf" "$TESTS_TMP/okf.bak"
python3 - "$okf" <<'EOF'
import sys
p = sys.argv[1]
t = open(p).read().replace("stale_after: 2027-04-11", "stale_after: 2027-04-11T00:00:00Z")
open(p, "w").write(t)
EOF
run_lint "$sb"
lint_dirty "stale_after as a datetime rejected"
out_has "stale_after must be a YYYY-MM-DD date" "…with the dedicated message"
cp "$TESTS_TMP/okf.bak" "$okf"

# verified without `by`
cp "$TESTS_TMP/page.bak" "$page"
python3 - "$page" <<'EOF'
import sys
p = sys.argv[1]
t = open(p).read().replace("generated:", "verified: { at: 2026-10-12 }\ngenerated:", 1)
open(p, "w").write(t)
EOF
run_lint "$sb"
lint_dirty "verified entry without \`by\` rejected"
out_has "verified entries need \`by\`" "…with the dedicated message"

# malformed routing_review fails; a well-formed one is listed as a NOTE
cp "$TESTS_TMP/page.bak" "$page"
python3 - "$page" <<'EOF'
import sys
p = sys.argv[1]
t = open(p).read().replace("generated:", "routing_review: { reason: closest fit }\ngenerated:", 1)
open(p, "w").write(t)
EOF
run_lint "$sb"
lint_dirty "routing_review without \`since\` rejected"

cp "$TESTS_TMP/page.bak" "$page"
python3 - "$page" <<'EOF'
import sys
p = sys.argv[1]
t = open(p).read().replace(
    "generated:",
    "routing_review: { reason: closest fit for now, candidate: some-bundle, since: 2026-09-01 }\ngenerated:", 1)
open(p, "w").write(t)
EOF
run_lint "$sb"
lint_clean "well-formed routing_review passes (informational only)"
out_has "awaiting routing review" "…and is listed as a routing-review NOTE"

cp "$TESTS_TMP/page.bak" "$page"
run_lint "$sb"
lint_clean "restored page: tree clean again"

exit_case
