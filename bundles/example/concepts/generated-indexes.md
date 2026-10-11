---
type: Concept
title: Generated indexes, never hand-edited
description: Every index.md is deterministically regenerated from page frontmatter by tools/gen-index.py — hand edits are silently lost and lint-refused, so navigation always reflects the pages.
tags: [tooling, conventions]
status: stable
generated: { by: claude-code/glm-5.3, at: 2026-10-11T19:00:00Z }
sources:
  - id: karpathy-gist
    resource: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
    title: "LLM Wiki — A pattern for building personal knowledge bases using LLMs"
    author: Andrej Karpathy
    last_modified: 2026-10-11
  - id: observation
    resource: "observation:2026-10"
    title: Direct observation of tools/gen-index.py behavior in this repository
---

Each bundle and sub-directory carries an `index.md` catalog (title + description per
page) that is **always generated, never authored**: `tools/gen-index.py` renders it from
frontmatter, sorted by title so diffs stay clean, and `tools/commit.sh` regenerates every
index before each commit[^observation].

## Details

- The index is the entry point of the [LLM wiki pattern](/concepts/llm-wiki-pattern.md)
  search tier: the source describes reading the index first, then drilling into pages,
  working "surprisingly well" at moderate scale[^karpathy-gist].
- Determinism is the design: same pages in, same bytes out — index churn in diffs can
  only mean a page changed[^observation].
- `gen-index.py --check` exits non-zero on a stale index; the lint and CI call it, and CI
  re-commits regenerated indexes on pull-request branches[^observation].
- An empty sub-directory renders as `*(empty)*` rather than being absent — the shape of
  the bundle stays visible[^observation].

## Related

- [LLM wiki pattern](/concepts/llm-wiki-pattern.md) — the pattern this mechanism serves.
- [Open Knowledge Format](/entities/open-knowledge-format.md) — the listing format the
  indexes follow.

[^karpathy-gist]: LLM Wiki gist, Andrej Karpathy.
[^observation]: Direct observation of tools/gen-index.py behavior in this repository.
