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
-->
