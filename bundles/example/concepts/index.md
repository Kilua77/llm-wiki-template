# Concepts

* [Generated indexes, never hand-edited](generated-indexes.md) - Every index.md is deterministically regenerated from page frontmatter by tools/gen-index.py — hand edits are silently lost and lint-refused, so navigation always reflects the pages.
* [LLM wiki pattern](llm-wiki-pattern.md) - An agent-maintained wiki sits between the owner and immutable raw sources, so knowledge compounds across sessions instead of being re-derived at every query.
* [Raft safety: a server votes for at most one candidate per term](raft-one-vote-per-term.md) - The voting rule that underpins election safety — one vote per server per term, granted first-come-first-served; violating it can elect two leaders in one term.
* [Raft: consensus through a single elected leader per term (published design decision)](raft-one-leader-per-term.md) - Raft's central design choice — strong leadership with one leader per term and log flow exclusively from the leader — traded Paxos symmetry for understandability.
