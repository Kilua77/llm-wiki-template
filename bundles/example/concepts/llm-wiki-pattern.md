---
type: Concept
title: LLM wiki pattern
description: An agent-maintained wiki sits between the owner and immutable raw sources, so knowledge compounds across sessions instead of being re-derived at every query.
tags: [knowledge-management, agent-patterns]
status: stable
generated: { by: claude-code/glm-5.3, at: 2026-10-11T19:00:00Z }
sources:
  - id: karpathy-gist
    resource: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
    title: "LLM Wiki — A pattern for building personal knowledge bases using LLMs"
    author: Andrej Karpathy
    last_modified: 2026-10-11
  - id: okf-spec
    resource: https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md
    title: Open Knowledge Format specification
    last_modified: 2026-10-11
---

The LLM wiki pattern replaces per-query retrieval over raw documents with a **persistent,
compounding wiki that agents build and maintain**: each ingested source updates entity
and concept pages, flags contradictions and strengthens the evolving synthesis —
knowledge is compiled once and kept current, not re-derived on every
question[^karpathy-gist].

## Details

- The owner sources and arbitrates; agents do the summarizing, cross-referencing, filing
  and bookkeeping. The owner "never (or rarely) writes the wiki"[^karpathy-gist] — in
  this repository that split is contractual (charter §10: agents propose bundles, the
  owner validates).
- Three layers: immutable raw sources, the agent-owned wiki, and a schema document —
  here the charter plus its machine-readable counterparts in `schemas/`[^karpathy-gist].
- Bundles follow the [Open Knowledge Format](/entities/open-knowledge-format.md) page
  and metadata conventions[^okf-spec].
- Navigation at moderate scale is index-first — see [Generated indexes, never
  hand-edited](/concepts/generated-indexes.md) — which the source reports as sufficient
  around a hundred sources, avoiding embedding-based RAG infrastructure[^karpathy-gist].

## Open questions

- None open in this bundle — this page demonstrates the format.

## Related

- [Open Knowledge Format](/entities/open-knowledge-format.md) — the metadata standard
  the bundles follow.
- [Generated indexes, never hand-edited](/concepts/generated-indexes.md) — how
  navigation stays trustworthy.

[^karpathy-gist]: LLM Wiki gist, Andrej Karpathy.
[^okf-spec]: Open Knowledge Format specification.
