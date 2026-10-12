# Computed freshness signals (CHARTE §8.F) — warnings never fail the run.
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)
page="$sb/bundles/example/entities/open-knowledge-format.md"
cp "$page" "$TESTS_TMP/page.bak"

# passed stale_after → WARN, exit 0
sed -i 's/^stale_after: .*/stale_after: 2020-01-01/' "$page"; regen "$sb"
run_lint "$sb"
lint_clean "passed stale_after is a warning (exit 0)"
out_has "stale_after 2020-01-01 passed" "…and the message fires"

# freshness lag: generated.at > 90d behind the freshest source last_modified
cp "$TESTS_TMP/page.bak" "$page"
sed -i 's/last_modified: 2026-10-11/last_modified: 2027-01-15/g' "$page"
regen "$sb"
run_lint "$sb"
lint_clean "freshness lag is a warning (exit 0)"
out_has "freshness lag" "…and the lag message fires"

# long page → split candidate warning
cp "$TESTS_TMP/page.bak" "$page"
{ cat "$page"; for i in $(seq 1 220); do echo "padding line $i"; done; } > "$page.tmp" && mv "$page.tmp" "$page"
regen "$sb"
run_lint "$sb"
lint_clean "long page is a warning (exit 0)"
out_has "split candidate" "…and the split-candidate message fires"

cp "$TESTS_TMP/page.bak" "$page"; regen "$sb"
run_lint "$sb"
lint_clean "restored: tree clean"

exit_case
