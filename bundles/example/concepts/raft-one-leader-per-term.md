---
type: Decision
title: "Raft: consensus through a single elected leader per term (published design decision)"
description: Raft's central design choice — strong leadership with one leader per term and log flow exclusively from the leader — traded Paxos symmetry for understandability.
tags: [distributed-systems, consensus]
status: stable
stale_after: 2027-04-13
code_refs:
  - repo: https://github.com/etcd-io/raft
    commit: 638f42739b77572b5708eb0d8a776a272ade71ed
    path: raft.go
    note: core state machine — leader/candidate/follower loop and message handling
applies_to:
  - /concepts/raft-one-vote-per-term.md
  - /references/raft-paper.md
generated: { by: claude-code/glm-5.3, at: 2026-10-13T00:05:00Z }
sources:
  - id: paper
    resource: https://raft.github.io/raft.pdf
    title: "In Search of an Understandable Consensus Algorithm (Extended Version)"
    author: Diego Ongaro and John Ousterhout
    last_modified: 2014-07-07
---

Raft separates leader election from log replication and gives the elected
leader full authority: clients talk to the leader, and log entries flow from
the leader to followers — never the reverse. Terms are logical clocks, and at
most one leader can exist per term[^paper]. This is the published decision the
whole algorithm is organized around; it is recorded here as the canonical
demonstration of a `Decision` page under CHARTE §13.

## Context

Paxos-based designs delegate leadership and merge arbitrary partial orders;
the authors judged the resulting mental model too hard to reason about and to
implement correctly. Understandability was an explicit design goal, on par
with correctness and performance[^paper].

## Decision

Strong leadership: elect exactly one leader per term, route all writes
through it, and have the leader overwrite follower logs with its own
(no interleaved merging). Progress comes from overlapping majorities, giving
safety without protocol symmetry[^paper].

## Consequences

Easier to reason about and to implement — the state space is small and the
invariants are local. The cost: a leadership bottleneck by design, and the
[one-vote-per-term safety constraint](/concepts/raft-one-vote-per-term.md)
becomes load-bearing (a double vote in a term can elect two leaders). The
reference implementation's leader loop is pinned above in `code_refs`.

## Open questions

None for the demo page — see the paper's §5.4.2 discussion of the election
restriction for the subtle cases.

[^paper]: In Search of an Understandable Consensus Algorithm (Extended Version)
