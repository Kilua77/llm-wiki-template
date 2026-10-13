---
type: Reference
title: In Search of an Understandable Consensus Algorithm (Raft paper)
description: The Raft paper's own claims — decomposing consensus into leader election and log replication to make it understandable, in contrast with Paxos.
tags: [distributed-systems, consensus]
status: stable
stale_after: 2027-04-13
generated: { by: claude-code/glm-5.3, at: 2026-10-13T00:05:00Z }
sources:
  - id: paper
    resource: https://raft.github.io/raft.pdf
    title: "In Search of an Understandable Consensus Algorithm (Extended Version)"
    author: Diego Ongaro and John Ousterhout
    last_modified: 2014-07-07
---

What this source says: Raft decomposes the consensus problem into two
sub-problems — leader election and log replication — and separates safety
(from overlapping majorities) from liveness (from timing), explicitly
optimizing for understandability as a design goal, in contrast with
Paxos[^paper]. Key mechanisms the paper claims: at most one leader per term,
at most one vote per server per term (first-come-first-served), a leader
commits an entry once servers of a majority store it, and a new leader
forces its log on followers (never the reverse)[^paper].

The raw conversion of the document lives in
[the Raft raw capture](/raw/2026-10-13-raft.md) — binary hash and converter
recorded in its header (CHARTE §13.2). Two engineering-convention demo pages
derive from this source: the
[one-leader-per-term decision](/concepts/raft-one-leader-per-term.md) and the
[one-vote-per-term constraint](/concepts/raft-one-vote-per-term.md).

[^paper]: In Search of an Understandable Consensus Algorithm (Extended Version)
