---
type: Tool
title: Open Knowledge Format (OKF)
description: The page and metadata convention this wiki's bundles follow — typed frontmatter with a minimal required core, specified in the knowledge-catalog repository.
tags: [metadata, standards]
status: stable
stale_after: 2027-04-11
generated: { by: claude-code/glm-5.3, at: 2026-10-11T19:00:00Z }
sources:
  - id: okf-spec
    resource: https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md
    title: Open Knowledge Format specification
    last_modified: 2026-10-11
  - id: karpathy-gist
    resource: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
    title: "LLM Wiki — A pattern for building personal knowledge bases using LLMs"
    author: Andrej Karpathy
    last_modified: 2026-10-11
---

OKF is the page format used by every bundle: Markdown files whose YAML frontmatter
carries typed metadata — `type` being the only field the format itself requires — with
IDs given by page paths[^okf-spec]. This wiki pins version 0.2 and adds repository-level
required fields on top (charter §5).

## Details

- The LLM wiki pattern is format-agnostic in principle[^karpathy-gist]; pinning OKF v0.2
  gives every page a shared shape that [generated
  indexes](/concepts/generated-indexes.md) and the lint can rely on[^okf-spec].
- Machine-readable counterparts of this repository's field table live in `schemas/` —
  validation shape for agents, with the lint as the enforcing gate[^okf-spec].
- `stale_after` is set on this page because a specification moves: re-verify the pinned
  version when the date passes.

## Related

- [LLM wiki pattern](/concepts/llm-wiki-pattern.md) — the pattern that carries these
  conventions.
- [Generated indexes, never hand-edited](/concepts/generated-indexes.md) — the catalog
  layer built on this format.

[^okf-spec]: Open Knowledge Format specification.
[^karpathy-gist]: LLM Wiki gist, Andrej Karpathy.
