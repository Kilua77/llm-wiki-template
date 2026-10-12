# Internal markdown links (CHARTE §8.F structural lint).
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)
page="$sb/bundles/example/concepts/llm-wiki-pattern.md"
cp "$page" "$TESTS_TMP/page.bak"

# broken intra-bundle link
sed -i 's|(/concepts/generated-indexes.md)|(../concepts/no-such-page.md)|' "$page"; regen "$sb"
run_lint "$sb"
lint_dirty "broken internal link rejected"
out_has "broken link -> ../concepts/no-such-page.md" "…and names the target"
cp "$TESTS_TMP/page.bak" "$page"

# valid cross-bundle link uses exactly two ../ (../../<bundle>/…)
mkdir -p "$sb/bundles/_other/concepts" "$sb/bundles/_other/references"
cat > "$sb/bundles/_other/concepts/anchor.md" <<'EOF'
---
type: Concept
title: Anchor
description: Cross-bundle link target.
tags: [smoke]
status: stable
generated: { by: smoke/test, at: 2026-10-13T00:00:00Z }
sources:
  - { id: o, resource: "https://example.org/anchor", title: Anchor }
---
See [the wiki pattern](../../example/concepts/llm-wiki-pattern.md).
EOF
python3 - "$sb" <<'EOF'
import sys, pathlib
p = pathlib.Path(sys.argv[1]) / "bundles/example/concepts/llm-wiki-pattern.md"
t = p.read_text().replace(
    "## Open questions",
    "Cross-bundle: [anchor](../../_other/concepts/anchor.md).\n\n## Open questions", 1)
p.write_text(t)
EOF
regen "$sb"
run_lint "$sb"
lint_clean "valid cross-bundle link (../../<bundle>/…) accepted"

# one ../ too few escapes the bundle and breaks
sed -i 's|../../_other/concepts/anchor.md|../other/concepts/anchor.md|' "$sb/bundles/example/concepts/llm-wiki-pattern.md"; regen "$sb"
run_lint "$sb"
lint_dirty "single-../ cross-bundle link rejected (escapes the bundle)"

# http/mailto/# links are ignored by the resolver
cp "$TESTS_TMP/page.bak" "$sb/bundles/example/concepts/llm-wiki-pattern.md"
python3 - "$sb" <<'EOF'
import sys, pathlib
p = pathlib.Path(sys.argv[1]) / "bundles/example/concepts/llm-wiki-pattern.md"
t = p.read_text().replace(
    "## Open questions",
    "External [docs](https://example.org/x), [mail](mailto:a@example.com), [frag](#section).\n\n## Open questions", 1)
p.write_text(t)
EOF
regen "$sb"
run_lint "$sb"
lint_clean "http/mailto/# links ignored by the resolver"

exit_case
