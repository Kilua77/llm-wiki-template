# commit.sh — the standard local write path, in a remote-less sandbox.
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)
git_sandbox "$sb"
page="$sb/bundles/example/concepts/llm-wiki-pattern.md"

# 1. a valid change: commit created with the Acting-Agent trailer
printf '\nTest appendix line.\n' >> "$page"
(cd "$sb" && bash tools/commit.sh "wiki(example): update — test commit" "smoke/test" >"$TESTS_TMP/commit.out" 2>&1)
if [ $? -eq 0 ]; then ok "commit.sh succeeds on a valid change"; else fail "commit.sh failed"; sed 's/^/      /' "$TESTS_TMP/commit.out"; fi
last=$(git -C "$sb" log -1 --format=%B)
echo "$last" | grep -qF "Acting-Agent: smoke/test" && ok "commit carries the Acting-Agent trailer" || fail "trailer missing"
echo "$last" | grep -qF "wiki(example): update — test commit" && ok "commit subject follows wiki(<bundle>): <action> — <object>" || fail "subject malformed"
(cd "$sb" && python3 tools/gen-index.py --check >/dev/null 2>&1)
if [ $? -eq 0 ]; then ok "indexes regenerated as part of the commit"; else fail "indexes stale after commit"; fi
grep -qF "no remote configured" "$TESTS_TMP/commit.out" && ok "remote-less branch taken explicitly" || true

# 2. an invalid page: no commit happens
n_before=$(git -C "$sb" log --oneline | wc -l)
sed -i 's/^status: stable/status: bogus/' "$page"
(cd "$sb" && bash tools/commit.sh "wiki(example): update — should not pass" "smoke/test" >"$TESTS_TMP/commit.out" 2>&1)
if [ $? -ne 0 ]; then ok "commit.sh refuses an invalid page"; else fail "commit.sh committed an invalid page"; fi
n_after=$(git -C "$sb" log --oneline | wc -l)
if [ "$n_before" = "$n_after" ]; then ok "no commit created on refusal"; else fail "a commit was created despite the refusal"; fi

# 3. nothing to commit → non-zero, nothing broken
sed -i 's/^status: bogus/status: stable/' "$page"
(cd "$sb" && bash tools/commit.sh "wiki(example): update — resync" "smoke/test" >/dev/null 2>&1)
(cd "$sb" && bash tools/commit.sh "wiki(example): update — nothing new" "smoke/test" >"$TESTS_TMP/commit.out" 2>&1)
if [ $? -ne 0 ]; then ok "second call with nothing to commit exits non-zero (documented)"; else fail "second call unexpectedly succeeded"; fi

exit_case
