---
type: Constraint
title: "Raft safety: a server votes for at most one candidate per term"
description: The voting rule that underpins election safety — one vote per server per term, granted first-come-first-served; violating it can elect two leaders in one term.
tags: [distributed-systems, consensus]
status: stable
stale_after: 2027-04-13
code_refs:
  - repo: https://github.com/etcd-io/raft
    commit: 638f42739b77572b5708eb0d8a776a272ade71ed
    path: raft_paper_test.go
    note: test scenarios replaying the paper's figures, including election safety
applies_to:
  - /concepts/raft-one-leader-per-term.md
generated: { by: claude-code/glm-5.3, at: 2026-10-13T00:05:00Z }
sources:
  - id: paper
    resource: https://raft.github.io/raft.pdf
    title: "In Search of an Understandable Consensus Algorithm (Extended Version)"
    author: Diego Ongaro and John Ousterhout
    last_modified: 2014-07-07
---

Each Raft server grants at most one vote per term, on a first-come-first-served
basis, and persists that vote before answering[^paper]. This is the rule the
[election-safety property](/concepts/raft-one-leader-per-term.md) rests on:
because a majority requires overlapping voters, two candidates cannot both
collect majorities in the same term if no server votes twice. A violation
(double voting, or a vote lost to a restart) can elect two leaders in one
term and split the log — this constraint is therefore enforced in persistent
state, not just in protocol code[^paper].

## Details

Origin: the paper's RequestVote rules (Figure 2) and the Election Safety
property (Figure 3). Exact scope: one term, one vote, granted to the first
candidate whose log is at least as up-to-date. What it rules out: vote
re-grant after a crash without durable `votedFor`, and any optimization that
lets a server answer two RequestVote RPCs in one term[^paper]. The reference
test suite pinning the paper's figures is referenced above in `code_refs`
(CHARTE §13.6 — tests as specification).

## Open questions

None recorded for the demo page.

[^paper]: In Search of an Understandable Consensus Algorithm (Extended Version)
