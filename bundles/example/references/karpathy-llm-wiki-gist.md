---
type: Reference
title: "LLM Wiki — A pattern for building personal knowledge bases using LLMs (gist)"
description: Karpathy's gist proposing agent-maintained wikis as persistent compounding artifacts between the owner and raw sources, instead of per-query retrieval.
tags: [knowledge-management, agent-patterns]
status: stable
generated: { by: claude-code/glm-5.3, at: 2026-10-11T19:00:00Z }
sources:
  - id: origin
    resource: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
    title: "LLM Wiki — A pattern for building personal knowledge bases using LLMs"
    author: Andrej Karpathy
    last_modified: 2026-10-11
---

An idea file meant to be pasted into an agent (Claude Code, Codex, OpenCode…), describing
a pattern for personal knowledge bases. This reference summarizes what the source says;
an excerpt lives in [raw](/raw/2026-10-11-karpathy-llm-wiki-gist-excerpt.md).

## What the source says

- Instead of retrieving from raw documents at query time (RAG), the LLM **incrementally
  builds and maintains a persistent wiki** — the knowledge is "compiled once and then
  kept current, not re-derived on every query"[^origin].
- The wiki is "a persistent, compounding artifact": cross-references already there,
  contradictions already flagged, synthesis already reflecting everything read[^origin].
- The human "never (or rarely) writes the wiki" — they source, explore and ask; the LLM
  does the summarizing, cross-referencing and bookkeeping[^origin].
- Three layers: immutable **raw sources**, the agent-owned **wiki**, and **the schema**
  (a CLAUDE.md/AGENTS.md-style contract) that makes the agent "a disciplined wiki
  maintainer rather than a generic chatbot"[^origin].
- Three operations — **ingest**, **query** (good answers get filed back into the wiki),
  **lint** (periodic health checks for contradictions, stale claims, orphans)[^origin].
- `index.md` (content catalog) + `log.md` (append-only chronicle) suffice at moderate
  scale — "about 100 sources" — avoiding embedding-based RAG infrastructure[^origin].

## Relation to the corpus

- [LLM wiki pattern](/concepts/llm-wiki-pattern.md) — the concept page carrying this
  pattern.
- [Generated indexes, never hand-edited](/concepts/generated-indexes.md) — how this
  repository implements the index layer the gist describes.

[^origin]: LLM Wiki gist, Andrej Karpathy.
