---
type: Raw Source
title: <original title>
description: Raw capture of <source>, ingested <YYYY-MM-DD>. Immutable.
tags: [raw]
status: stable
content_sha256: <sha256 of the converted body, without the frontmatter>
generated: { by: <agent>/<model>, at: <ISO-8601> }
sources:
  - { id: origin, resource: <public origin URL>, title: <original title> }
---
[converted content, unretouched]

<!--
How to compute content_sha256:
  python3 - <<'EOF'
  import hashlib, sys
  text = open("<this file>").read()
  body = text.split("---", 2)[2]          # everything after the closing fence
  print(hashlib.sha256(body.encode()).hexdigest())
  EOF

Set at ingestion only — the raw is immutable, the hash is never recomputed.
Before ingesting a URL: compare the hash of the freshly fetched content against
the content_sha256 of existing raws for the same URL. Identical → do not
re-ingest (at most update the reference's last_modified). Different → new dated
file, never a rewrite.

If the raw comes from a BINARY document (DOCX/PDF/EPUB, CHARTE §13.5), the header
additionally carries the inseparable pair (required there, forbidden elsewhere):

source_file:
  name: <basename of the original binary>
  sha256: <sha256 of the ORIGINAL binary — the document dedup key>
  stored_at: <public URL of the original, or "storage:<slug>">
conversion:
  tool: "<converter and version, e.g. 'pdftotext 24.04.0 (poppler)'>"
  date: YYYY-MM-DD

Document-level dedup uses the binary's sha256 (source_file.sha256), not
content_sha256. tools/ingest-doc.sh computes both and assembles the header.
-->

