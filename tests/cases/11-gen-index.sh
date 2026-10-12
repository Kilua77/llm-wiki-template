# gen-index (CHARTE §4): --check, hand-edit detection, determinism.
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)

(cd "$sb" && python3 tools/gen-index.py --check >"$TESTS_TMP/gi.out" 2>&1)
if [ $? -eq 0 ]; then ok "--check green on the pristine tree"; else fail "--check red on the pristine tree"; sed 's/^/      /' "$TESTS_TMP/gi.out"; fi

# a hand-edited index is detected both by --check and by the lint
printf '\n* [Hand edit](concepts/hand.md) - smuggled\n' >> "$sb/bundles/example/concepts/index.md"
(cd "$sb" && python3 tools/gen-index.py --check >"$TESTS_TMP/gi.out" 2>&1)
if [ $? -ne 0 ]; then ok "--check detects the hand-edited index"; else fail "--check missed the hand-edited index"; fi
run_lint "$sb"
lint_dirty "lint fails on a stale index"
out_has "stale index" "…with the stale-index message"

# determinism: regenerating twice yields byte-identical files
(cd "$sb" && python3 tools/gen-index.py >/dev/null)
find "$sb/bundles" -name index.md -exec sha256sum {} + | sort > "$TESTS_TMP/idx-1"
(cd "$sb" && python3 tools/gen-index.py >/dev/null)
find "$sb/bundles" -name index.md -exec sha256sum {} + | sort > "$TESTS_TMP/idx-2"
if cmp -s "$TESTS_TMP/idx-1" "$TESTS_TMP/idx-2"; then ok "regeneration is deterministic (byte-identical)"; else fail "regeneration is not deterministic"; fi
run_lint "$sb"
lint_clean "after regeneration the tree is clean"

exit_case
