# ingest-doc.sh (CHARTE §13.5) — hash+reference ingestion of binary documents.
# The --from-converted path exercises the whole pipeline without pandoc;
# the real docx conversion runs only when pandoc is installed (CI does).
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)
mkdir -p "$TESTS_TMP/docs"
printf 'fake docx payload for hash purposes' > "$TESTS_TMP/docs/System Spec v3.docx"
cat > "$TESTS_TMP/docs/converted.md" <<'EOF'
# Introduction

This is the converted body — unretouched by convention.

# Details

Second chapter for the split test.
EOF
BIN_SHA="$(sha256sum "$TESTS_TMP/docs/System Spec v3.docx" | cut -d' ' -f1)"

# 1. --from-converted: raw created, both hashes correct, lint green
out=$(cd "$sb" && bash tools/ingest-doc.sh example "$TESTS_TMP/docs/System Spec v3.docx" \
       --from-converted "$TESTS_TMP/docs/converted.md" --actor smoke/test 2>&1)
raw="$sb/bundles/example/raw/"*-system-spec-v3.md
if ls $raw >/dev/null 2>&1; then ok "raw file created from a spaced filename (slugified)"; else fail "no raw created: $out"; fi
rawfile=$(ls $raw | head -1)
file_has "$rawfile" "sha256: $BIN_SHA" "source_file.sha256 = hash of the ORIGINAL binary"
file_has "$rawfile" "stored_at: \"storage:project-docs\"" "stored_at carries the default storage slug"
check=$(python3 - "$rawfile" <<'EOF'
import hashlib, re, sys
t = open(sys.argv[1]).read()
claimed = re.search(r"^content_sha256: ([0-9a-f]{64})$", t, re.M).group(1)
actual = hashlib.sha256(t.split("---", 2)[2].encode()).hexdigest()
print("MATCH" if claimed == actual else f"MISMATCH {claimed} != {actual}")
EOF
)
if [ "$check" = "MATCH" ]; then ok "content_sha256 matches the templates/raw.md convention"; else fail "content_sha256 mismatch: $check"; fi
run_lint "$sb"
lint_clean "lint green after ingestion (source_file + conversion accepted)"

# 2. re-running is a no-op (document-level dedup)
out2=$(cd "$sb" && bash tools/ingest-doc.sh example "$TESTS_TMP/docs/System Spec v3.docx" \
        --from-converted "$TESTS_TMP/docs/converted.md" 2>&1)
rc=$?
n=$(ls "$sb/bundles/example/raw/" | grep -c "system-spec")
if [ "$rc" = "0" ] && [ "$n" = "1" ]; then ok "re-ingestion of the same binary is a no-op (exit 0, one raw)"; else fail "dedup broken (rc=$rc, $n raws): $out2"; fi
echo "$out2" | grep -qF "already ingested" && ok "…and says so explicitly" || fail "missing the dedup message"

# 3. a different binary → a second dated raw, not a rewrite
printf 'different payload' > "$TESTS_TMP/docs/System Spec v4.docx"
(cd "$sb" && bash tools/ingest-doc.sh example "$TESTS_TMP/docs/System Spec v4.docx" \
   --from-converted "$TESTS_TMP/docs/converted.md" >/dev/null 2>&1)
n=$(ls "$sb/bundles/example/raw/" | grep -c "system-spec")
if [ "$n" = "2" ]; then ok "a different binary produces a second raw (never a rewrite)"; else fail "expected 2 raws, found $n"; fi

# 4. chapter split: one raw per level-1 heading
sb2=$(new_sandbox)
cat > "$TESTS_TMP/docs/3chap.md" <<'EOF'
# Alpha

first

# Beta

second

# Gamma

third
EOF
printf 'payload 3ch' > "$TESTS_TMP/docs/spec-3ch.docx"
(cd "$sb2" && bash tools/ingest-doc.sh example "$TESTS_TMP/docs/spec-3ch.docx" \
   --from-converted "$TESTS_TMP/docs/3chap.md" --chapter-split >/dev/null 2>&1)
n=$(ls "$sb2/bundles/example/raw/"*-ch*.md 2>/dev/null | wc -l)
if [ "$n" = "3" ]; then ok "--chapter-split yields one raw per chapter (3)"; else fail "expected 3 chapter raws, found $n"; fi
run_lint "$sb2"
lint_clean "lint green after chapter-split ingestion"

# 5. unsupported extension / wild bundle → explicit refusals
sb3=$(new_sandbox)
printf 'x' > "$TESTS_TMP/docs/spec.xlsx"
out=$(cd "$sb3" && bash tools/ingest-doc.sh example "$TESTS_TMP/docs/spec.xlsx" 2>&1)
if [ $? -ne 0 ]; then ok "unsupported extension refused"; else fail "xlsx accepted"; fi
out=$(cd "$sb3" && bash tools/ingest-doc.sh wildbundle "$TESTS_TMP/docs/spec-3ch.docx" 2>&1)
if [ $? -ne 0 ]; then ok "wild bundle refused"; else fail "wild bundle accepted"; fi

# 6. real docx conversion when pandoc is available (CI), skipped loudly otherwise
if command -v pandoc >/dev/null 2>&1; then
  sb4=$(new_sandbox)
  pandoc -f markdown -t docx -o "$TESTS_TMP/docs/real.docx" "$TESTS_TMP/docs/3chap.md"
  (cd "$sb4" && bash tools/ingest-doc.sh example "$TESTS_TMP/docs/real.docx" --stored-at "https://example.org/real.docx" >/dev/null 2>&1)
  n=$(ls "$sb4/bundles/example/raw/"*.md 2>/dev/null | wc -l)
  if [ "$n" -ge 1 ]; then ok "real docx conversion produced a raw"; else fail "real docx conversion failed"; fi
  file_has "$(ls "$sb4/bundles/example/raw/"2026-10-13-*.md | head -1)" "stored_at: \"https://example.org/real.docx\"" "…with the explicit stored_at"
else
  echo "  SKIP: pandoc not installed — real docx path covered in CI"
fi

exit_case
