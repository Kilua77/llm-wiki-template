---
okf_version: "0.2"
---

# example

## Concepts

* [Generated indexes, never hand-edited](concepts/generated-indexes.md) - Every index.md is deterministically regenerated from page frontmatter by tools/gen-index.py — hand edits are silently lost and lint-refused, so navigation always reflects the pages.
* [LLM wiki pattern](concepts/llm-wiki-pattern.md) - An agent-maintained wiki sits between the owner and immutable raw sources, so knowledge compounds across sessions instead of being re-derived at every query.
* [Raft safety: a server votes for at most one candidate per term](concepts/raft-one-vote-per-term.md) - The voting rule that underpins election safety — one vote per server per term, granted first-come-first-served; violating it can elect two leaders in one term.
* [Raft: consensus through a single elected leader per term (published design decision)](concepts/raft-one-leader-per-term.md) - Raft's central design choice — strong leadership with one leader per term and log flow exclusively from the leader — traded Paxos symmetry for understandability.

## Entities

* [Open Knowledge Format (OKF)](entities/open-knowledge-format.md) - The page and metadata convention this wiki's bundles follow — typed frontmatter with a minimal required core, specified in the knowledge-catalog repository.

## Raw

* [In Search of an Understandable Consensus Algorithm (Raft)](raw/2026-10-13-raft.md) - Raw capture of raft.pdf, ingested 2026-10-13. Immutable.
* [LLM Wiki (gist) — excerpt](raw/2026-10-11-karpathy-llm-wiki-gist-excerpt.md) - Raw capture of an excerpt of Karpathy's LLM Wiki gist, ingested 2026-10-11. Immutable.

## References

* [In Search of an Understandable Consensus Algorithm (Raft paper)](references/raft-paper.md) - The Raft paper's own claims — decomposing consensus into leader election and log replication to make it understandable, in contrast with Paxos.
* [LLM Wiki — A pattern for building personal knowledge bases using LLMs (gist)](references/karpathy-llm-wiki-gist.md) - Karpathy's gist proposing agent-maintained wikis as persistent compounding artifacts between the owner and raw sources, instead of per-query retrieval.

## Syntheses

*(empty)*
