# Engineering fields (CHARTE §13.2) — shapes, couplings, dedup.
. "$(dirname "$0")/../lib.sh"

sb=$(new_sandbox)
B="$sb/bundles/_t"
mkdir -p "$B/concepts" "$B/raw"
printf '# Log\n' > "$B/log.md"

mkdecision() {  # stdin: extra frontmatter lines
  cat > "$B/concepts/dec.md" <<EOF
---
type: Decision
title: Test decision
description: Fixture decision.
tags: [smoke]
status: draft
$*
generated: { by: smoke/test, at: 2026-10-13T00:00:00Z }
sources:
  - { id: o, resource: "https://example.org/d", title: D }
---
Body links [a page](/concepts/base.md).
EOF
  cat > "$B/concepts/base.md" <<'EOF'
---
type: Concept
title: Base
description: Link target.
tags: [smoke]
status: stable
generated: { by: smoke/test, at: 2026-10-13T00:00:00Z }
sources:
  - { id: o, resource: "https://example.org/b", title: B }
---
Links [the decision](/concepts/dec.md).
EOF
  regen "$sb"
}

# a well-formed Decision passes
mkdecision "stale_after: 2027-10-13
code_refs:
  - repo: myproj
    commit: 4d1a0f2c9b8e7f6a5d4c3b2a1908171615141312
    path: src/main.cpp
    lines: 10-20"
run_lint "$sb"
lint_clean "well-formed Decision with code_refs passes"
out_lacks "code_refs" "no code_refs complaint on the well-formed page"

# Decision without code_refs
mkdecision "stale_after: 2027-10-13"
run_lint "$sb"
lint_dirty "Decision without code_refs rejected"
out_has "must carry code_refs" "…with the §13.2 message"

# malformed sha
mkdecision "stale_after: 2027-10-13
code_refs:
  - repo: myproj
    commit: deadbeef
    path: src/main.cpp"
run_lint "$sb"
lint_dirty "abbreviated commit sha rejected"
out_has "FULL 40-hex sha" "…with the sha message"

# absolute path and .. rejected
mkdecision "stale_after: 2027-10-13
code_refs:
  - repo: myproj
    commit: 4d1a0f2c9b8e7f6a5d4c3b2a1908171615141312
    path: /etc/passwd"
run_lint "$sb"
lint_dirty "leading-slash path rejected"

mkdecision "stale_after: 2027-10-13
code_refs:
  - repo: myproj
    commit: 4d1a0f2c9b8e7f6a5d4c3b2a1908171615141312
    path: ../outside.cpp"
run_lint "$sb"
lint_dirty "..-escaping path rejected"

# lines start > end
mkdecision "stale_after: 2027-10-13
code_refs:
  - repo: myproj
    commit: 4d1a0f2c9b8e7f6a5d4c3b2a1908171615141312
    path: src/main.cpp
    lines: 99-42"
run_lint "$sb"
lint_dirty "inverted lines range rejected"
out_has "start > end" "…with the lines message"

# code_refs without stale_after
mkdecision "code_refs:
  - repo: myproj
    commit: 4d1a0f2c9b8e7f6a5d4c3b2a1908171615141312
    path: src/main.cpp"
run_lint "$sb"
lint_dirty "code_refs without stale_after rejected"
out_has "a pinned commit IS a version" "…with the coupling message"

# applies_to: existing target passes, dangling target fails
mkdecision "stale_after: 2027-10-13
code_refs:
  - repo: myproj
    commit: 4d1a0f2c9b8e7f6a5d4c3b2a1908171615141312
    path: src/main.cpp
applies_to: [/concepts/base.md]"
run_lint "$sb"
lint_clean "applies_to to an existing page passes"

mkdecision "stale_after: 2027-10-13
code_refs:
  - repo: myproj
    commit: 4d1a0f2c9b8e7f6a5d4c3b2a1908171615141312
    path: src/main.cpp
applies_to: [/concepts/ghost.md]"
run_lint "$sb"
lint_dirty "dangling applies_to rejected"
out_has "applies_to a page that does not exist" "…with the existence message"

# source_file/conversion: raw-only, inseparable, dedup by binary hash
H=$(printf 'binary' | sha256sum | cut -d' ' -f1)
mkdecision "stale_after: 2027-10-13
code_refs:
  - repo: myproj
    commit: 4d1a0f2c9b8e7f6a5d4c3b2a1908171615141312
    path: src/main.cpp
source_file:
  name: spec.docx
  sha256: $H
  stored_at: \"storage:project-docs\"
conversion: { tool: \"pandoc 3.1\", date: 2026-10-13 }"
run_lint "$sb"
lint_dirty "source_file on a non-raw page rejected"
out_has "reserved to raws" "…with the raw-only message"

mkdecision "conversion: { tool: \"pandoc 3.1\", date: 2026-10-13 }"
run_lint "$sb"
lint_dirty "conversion without source_file rejected"
out_has "inseparable" "…with the pair message"

mkr() {  # <slug> [skip-conversion]
  cat > "$B/raw/2026-10-13-$1.md" <<EOF
---
type: Raw Source
title: Raw $1
description: Raw capture, fixture.
tags: [raw]
status: stable
content_sha256: $H
source_file:
  name: spec.docx
  sha256: $H
  stored_at: "storage:project-docs"
generated: { by: smoke/test, at: 2026-10-13T00:00:00Z }
sources:
  - { id: o, resource: "https://example.org/$1", title: R }
---
converted body $1
EOF
  if [ "$2" != "skip" ]; then
    python3 - "$B/raw/2026-10-13-$1.md" <<'PY'
import sys
p = sys.argv[1]
t = open(p).read().replace("generated: {", "conversion: { tool: \"pandoc 3.1\", date: 2026-10-13 }\ngenerated: {", 1)
open(p, "w").write(t)
PY
  fi
  regen "$sb"
}

rm -f "$B/concepts/dec.md" "$B/concepts/base.md"; regen "$sb"
mkr doc-a
# same-date same-hash = one split ingestion's chapters: tolerated
sed 's/2026-10-13-doc-a/2026-10-13-doc-b/; s/Raw doc-a/Raw doc-b/' \
  "$B/raw/2026-10-13-doc-a.md" > "$B/raw/2026-10-13-doc-b.md"
regen "$sb"
run_lint "$sb"
lint_clean "same-date same source_file.sha256 tolerated (chapter split)"
# different-date same-hash = re-ingestion: rejected
sed 's/2026-10-13-doc-a/2026-10-11-doc-c/; s/Raw doc-a/Raw doc-c/' \
  "$B/raw/2026-10-13-doc-a.md" > "$B/raw/2026-10-11-doc-c.md"
regen "$sb"
run_lint "$sb"
lint_dirty "same source_file.sha256 under another date rejected (re-ingestion)"
out_has "document re-ingestion" "…with the dedup message"

rm -f "$B/raw/2026-10-13-doc-b.md" "$B/raw/2026-10-11-doc-c.md"; regen "$sb"
mkr doc-c skip
run_lint "$sb"
lint_dirty "raw with source_file but no conversion rejected"

exit_case
