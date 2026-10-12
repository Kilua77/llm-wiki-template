#!/usr/bin/env bash
# Ingest a binary document (DOCX, PDF) into a bundle's raw/ — CHARTE §13.5.
#
#   tools/ingest-doc.sh <bundle> <file.docx|file.pdf> [options]
#
# What it does: hashes the ORIGINAL binary (the document dedup key), converts
# to markdown, splits large documents chapter by chapter, assembles the raw
# header (§6.3 + §13.2: source_file + conversion, content_sha256 with the
# byte-exact convention of templates/raw.md), and lints. It does NOT commit:
# the §8.A continuation (reference digest, knowledge pages, log entry) is
# agent work, not script work.
#
# Options:
#   --slug <s>            raw slug (default: slugified file basename)
#   --title <t>           document title in the header (default: the slug)
#   --stored-at <loc>     where the binary lives — public URL or storage:<slug>
#                         (default "storage:project-docs"; adjust it)
#   --chapter-split       one raw per level-1 heading (also automatic above
#                         CHAPTER_SPLIT_LINES)
#   --from-converted <f>  body already converted to markdown (the fallback when
#                         pandoc/poppler are absent — the binary is still
#                         required, for its hash)
#   --actor <a>           acting agent for the generated.at field
#
# Dependencies (optional, declared in README/SETUP): pandoc for .docx,
# poppler-utils (pdftotext) for .pdf. Missing both and no --from-converted:
# loud failure naming the package to install.
#
# Never writes outside bundles/<bundle>/raw/. Never re-ingests: a matching
# source_file.sha256 is a no-op (exit 0).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHAPTER_SPLIT_LINES=1500   # auto chapter-split threshold

BUNDLE=""
FILE=""
SLUG=""
TITLE=""
STORED_AT="storage:project-docs"
SPLIT=0
CONVERTED=""
ACTOR="agent/unspecified"

usage() {
  sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'
}

while [ $# -gt 0 ]; do
  case "$1" in
    --slug) SLUG="${2:?--slug requires an argument}"; shift ;;
    --title) TITLE="${2:?--title requires an argument}"; shift ;;
    --stored-at) STORED_AT="${2:?--stored-at requires an argument}"; shift ;;
    --chapter-split) SPLIT=1 ;;
    --from-converted) CONVERTED="${2:?--from-converted requires a path}"; shift ;;
    --actor) ACTOR="${2:?--actor requires an argument}"; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "ingest-doc.sh: unknown option: $1" >&2; exit 64 ;;
    *) if [ -z "$BUNDLE" ]; then BUNDLE="$1"; elif [ -z "$FILE" ]; then FILE="$1";
       else echo "ingest-doc.sh: unexpected argument: $1" >&2; exit 64; fi ;;
  esac
  shift
done

[ -n "$BUNDLE" ] && [ -n "$FILE" ] || { usage >&2; exit 64; }
[ -f "$FILE" ] || { echo "ingest-doc.sh: no such file: $FILE" >&2; exit 1; }
[ -d "$HERE/bundles/$BUNDLE" ] || {
  echo "ingest-doc.sh: no such bundle: bundles/$BUNDLE" >&2; exit 1; }
grep -qF "| \`$BUNDLE\`" "$HERE/CHARTE.md" || {
  echo "ingest-doc.sh: bundle '$BUNDLE' is not in the CHARTE.md inventory" \
       "(wild bundle — CHARTE §10)" >&2; exit 1; }

ext="${FILE##*.}"
ext_lower="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"
if [ -z "$CONVERTED" ]; then
  case "$ext_lower" in
    docx) command -v pandoc >/dev/null 2>&1 || {
            echo "ingest-doc.sh: pandoc not found (package: pandoc) — install it," \
                 "or pass --from-converted <body.md> with a pre-converted body." >&2
            exit 1; } ;;
    pdf)  command -v pdftotext >/dev/null 2>&1 || {
            echo "ingest-doc.sh: pdftotext not found (package: poppler-utils) —" \
                 "install it, or pass --from-converted <body.md>." >&2
            exit 1; } ;;
    *) echo "ingest-doc.sh: unsupported extension '$ext' (docx, pdf — or use" \
            "--from-converted)" >&2; exit 1 ;;
  esac
fi

# 1. hash the ORIGINAL binary — the document-level dedup key (CHARTE §6.3/§13.2)
BIN_SHA="$(sha256sum "$FILE" | cut -d' ' -f1)"
SIZE_BYTES="$(stat -c %s "$FILE" 2>/dev/null || stat -f %z "$FILE")"
RAWDIR="$HERE/bundles/$BUNDLE/raw"
if grep -rqlF "sha256: $BIN_SHA" "$RAWDIR" 2>/dev/null; then
  echo "ingest-doc.sh: already ingested — $BIN_SHA is captured by:"
  grep -rlF "sha256: $BIN_SHA" "$RAWDIR"
  echo "Do not re-ingest (CHARTE §6.3); at most refresh the reference's last_modified."
  exit 0
fi

# 2. convert (declared in conversion.tool — the body lands unretouched)
WORK="$(mktemp -d "${TMPDIR:-/tmp}/wiki-ingest.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
if [ -n "$CONVERTED" ]; then
  [ -f "$CONVERTED" ] || { echo "ingest-doc.sh: --from-converted: no such file: $CONVERTED" >&2; exit 1; }
  cp "$CONVERTED" "$WORK/body.md"
  TOOL="pre-converted (see source_file.stored_at for the original converter)"
else
  case "$ext_lower" in
    docx) TOOL="$(pandoc --version | head -1)"
          pandoc -f docx -t gfm --wrap=none -o "$WORK/body.md" "$FILE" ;;
    pdf)  TOOL="$(pdftotext -v 2>&1 | head -1)"
          pdftotext -layout -enc UTF-8 "$FILE" "$WORK/body.md" ;;
  esac
fi
[ -s "$WORK/body.md" ] || { echo "ingest-doc.sh: conversion produced an empty body" >&2; exit 1; }

# 3. split chapter by chapter when needed (cut on level-1 headings)
N_LINES="$(wc -l < "$WORK/body.md")"
if [ "$SPLIT" = 1 ] || [ "$N_LINES" -gt "$CHAPTER_SPLIT_LINES" ]; then
  python3 - "$WORK" <<'PY'
import sys
from pathlib import Path
work = Path(sys.argv[1])
body = (work / "body.md").read_text(encoding="utf-8")
lines = body.splitlines(keepends=True)
# leading content before the first "# " is chapter 00
chapters, current = [], []
for l in lines:
    if l.startswith("# ") and current:
        chapters.append("".join(current)); current = []
    current.append(l)
if current:
    chapters.append("".join(current))
chapters = [c for c in chapters if c.strip()]
if len(chapters) <= 1:
    (work / "body.md").write_text(body, encoding="utf-8")
    (work / "single").write_text("1", encoding="utf-8")
else:
    for i, c in enumerate(chapters, 1):
        (work / f"ch-{i:02d}.md").write_text(c, encoding="utf-8")
    (work / "single").write_text("0", encoding="utf-8")
PY
else
  echo 1 > "$WORK/single"
fi

# 4. assemble the raw header(s) — content_sha256 uses the byte-exact
#    convention of templates/raw.md: everything after the closing fence
SLUG="${SLUG:-$(basename "$FILE" | sed -E 's/\.[^.]*$//' | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')}"
TITLE="${TITLE:-$SLUG}"
TODAY="$(date +%F)"
NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

assemble() {  # <body-file> <suffix>
  python3 - "$1" "$2" "$BUNDLE" "$SLUG" "$TITLE" "$TODAY" "$NOW" "$BIN_SHA" \
            "$(basename "$FILE")" "$STORED_AT" "$SIZE_BYTES" "$TOOL" "$ACTOR" "$RAWDIR" <<'PY'
import hashlib, sys
from pathlib import Path

(body_f, suffix, bundle, slug, title, today, now, bin_sha, fname,
 stored_at, size, tool, actor, rawdir) = sys.argv[1:15]
body = Path(body_f).read_text(encoding="utf-8")
if not body.endswith("\n"):
    body += "\n"
# convention of templates/raw.md: text.split("---", 2)[2] — i.e. "\n" + body
content_sha = hashlib.sha256(("\n" + body).encode()).hexdigest()
fm = (
    "---\n"
    f"type: Raw Source\n"
    f"title: {title}{suffix}\n"
    f"description: Raw capture of {fname}, ingested {today}. Immutable.\n"
    "tags: [raw]\n"
    "status: stable\n"
    f"content_sha256: {content_sha}\n"
    "source_file:\n"
    f"  name: {fname}\n"
    f"  sha256: {bin_sha}\n"
    f"  stored_at: \"{stored_at}\"\n"
    f"  size_bytes: {size}\n"
    "conversion:\n"
    f"  tool: \"{tool}\"\n"
    f"  date: {today}\n"
    f"generated: {{ by: {actor}, at: {now} }}\n"
    "sources:\n"
    f"  - {{ id: origin, resource: \"observation:{today[:7]}\", title: \"{title}\" }}\n"
    "---\n"
)
out = Path(rawdir) / f"{today}-{slug}{suffix if suffix else ''}.md"
n = 2
while out.exists():  # name collision: dated suffix, never a rewrite
    out = Path(rawdir) / f"{today}-{slug}{suffix if suffix else ''}-{n}.md"
    n += 1
out.write_text(fm + body, encoding="utf-8")
print(out)
PY
}

echo "ingest-doc.sh: assembling raw file(s)…"
if [ "$(cat "$WORK/single")" = "1" ]; then
  assemble "$WORK/body.md" ""
else
  i=1
  for ch in "$WORK"/ch-*.md; do
    [ -e "$ch" ] || continue
    assemble "$ch" "-ch$(printf '%02d' "$i")"
    i=$((i + 1))
  done
fi

echo "ingest-doc.sh: running the lint…"
(cd "$HERE" && python3 tools/gen-index.py >/dev/null)
(cd "$HERE" && python3 tools/lint.py >/dev/null) || {
  echo "ingest-doc.sh: lint failed — fix the raw file(s) before continuing" >&2
  exit 1
}

cat <<'NEXT'
Ingested. The §8.A continuation is yours (not this script's):

  1. Write or update the reference digest: bundles/<b>/references/<slug>.md (§6.2)
  2. Update every knowledge page the document touches; create the missing ones
     (requirements → Constraint, decisions → Decision, procedures → Playbook — §13.4)
  3. Weave the links both ways
  4. Log the Ingest in bundles/<b>/log.md
  5. tools/commit.sh "wiki(<b>): ingest — <document title>" "<actor>"

NEXT
if [ "$STORED_AT" = "storage:project-docs" ]; then
  echo "ingest-doc.sh: NOTE — stored_at kept its default (storage:project-docs)."
  echo "Point it at where the binary actually lives before committing."
fi
