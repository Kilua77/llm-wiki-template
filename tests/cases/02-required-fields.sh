# Required frontmatter fields (CHARTE §5) — removing any one of the seven
# fails the lint with the field named in the output.
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)
page="$sb/bundles/example/concepts/llm-wiki-pattern.md"
cp "$page" "$TESTS_TMP/page.bak"

for field in type title description tags status generated sources; do
  cp "$TESTS_TMP/page.bak" "$page"
  python3 - "$page" "$field" <<'EOF'
import sys
p, field = sys.argv[1], sys.argv[2]
lines = open(p).read().splitlines(keepends=True)
out, skipping = [], False
for l in lines:
    if not skipping and l.startswith(field + ":"):
        skipping = True          # drop the key line AND its indented block
        continue
    if skipping:
        if l.startswith((" ", "\t")) or not l.strip():
            continue
        skipping = False
    out.append(l)
open(p, "w").writelines(out)
EOF
  run_lint "$sb"
  lint_dirty "removing \`$field\` fails the lint"
  out_has "missing required field \`$field\`" "…and names \`$field\` in the output"
done

cp "$TESTS_TMP/page.bak" "$page"
run_lint "$sb"
lint_clean "restoring the page returns the tree to clean"

exit_case
