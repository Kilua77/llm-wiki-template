# init.sh — personalizing a fresh clone: default mode, --keep-example, refusals.
. "$(dirname "$0")/../lib.sh"

# default mode: demo bundle and its inventory row removed, hooks wired,
# marker gone, initial commit made, lint clean
sb=$(new_sandbox)
git_sandbox "$sb"
(cd "$sb" && bash tools/init.sh --yes >"$TESTS_TMP/init.out" 2>&1)
if [ $? -eq 0 ]; then ok "init.sh --yes succeeds"; else fail "init.sh --yes failed"; sed 's/^/      /' "$TESTS_TMP/init.out"; fi
[ -d "$sb/bundles/example" ] && fail "example bundle still present" || ok "example bundle removed"
file_lacks "$sb/CHARTE.md" "| \`example\`" "example inventory row removed"
[ -f "$sb/.wiki-template" ] && fail "marker still present" || ok "template marker removed"
hp=$(git -C "$sb" config core.hooksPath)
if [ "$hp" = ".githooks" ]; then ok "core.hooksPath wired to .githooks"; else fail "core.hooksPath is '$hp'"; fi
n=$(git -C "$sb" log --oneline 2>/dev/null | wc -l)
if [ "$n" -ge 2 ]; then ok "initial commit created (log has $n entries)"; else fail "no initial commit ($n entries)"; fi
run_lint "$sb"
lint_clean "lint clean after default init"

# --keep-example: everything kept, lint clean
sb2=$(new_sandbox)
git_sandbox "$sb2"
(cd "$sb2" && bash tools/init.sh --yes --keep-example >"$TESTS_TMP/init.out" 2>&1)
if [ $? -eq 0 ]; then ok "init.sh --keep-example succeeds"; else fail "init.sh --keep-example failed"; sed 's/^/      /' "$TESTS_TMP/init.out"; fi
[ -d "$sb2/bundles/example" ] && ok "example bundle kept" || fail "example bundle removed despite --keep-example"
file_has "$sb2/CHARTE.md" "| \`example\`" "example inventory row kept"
run_lint "$sb2"
lint_clean "lint clean after --keep-example init"

# dirty tree → refusal before touching anything
sb3=$(new_sandbox)
git_sandbox "$sb3"
echo "junk" > "$sb3/uncommitted.txt"
out=$(cd "$sb3" && bash tools/init.sh --yes 2>&1)
if [ $? -ne 0 ]; then ok "dirty tree refused"; else fail "dirty tree accepted"; fi
echo "$out" | grep -q "working tree not clean" && ok "…with the dedicated message" || fail "missing the dedicated message"
[ -f "$sb3/.wiki-template" ] && ok "nothing was touched (marker intact)" || fail "marker removed despite refusal"
[ -d "$sb3/bundles/example" ] && ok "demo intact after refusal" || fail "demo removed despite refusal"

# missing marker → refusal
sb4=$(new_sandbox)
git_sandbox "$sb4"
rm -f "$sb4/.wiki-template"
cmd_fail "missing template marker refused" bash "$sb4/tools/init.sh" --yes

exit_case
