---
type: Decision
title: <the decision, phrased as a stance — "X does Y (published design decision)">
description: One sentence: what was decided and the dominant reason.
tags: [<kebab-case-tags>]
status: stable
stale_after: <YYYY-MM-DD>          # REQUIRED — a Decision cites pinned code (§13.2)
generated: { by: <agent>/<model>, at: <ISO-8601> }
code_refs:                         # REQUIRED on a Decision (§13.2)
  - repo: <public URL or bare local slug>
    commit: <full 40-hex sha — never a branch>
    path: <relative path, no leading slash>
    lines: <start-end>             # optional
applies_to:                        # optional, recommended (§13.2)
  - /concepts/<related-area>.md
sources:
  - id: <stable-slug>
    resource: <public URL or "observation:<YYYY-MM>">
    title: <source title>
    author: <source author>
    last_modified: <YYYY-MM-DD>
---

[Self-contained summary, 2–5 sentences. A hurried agent stops here.]

## Context        — the forces at play: constraints, options considered, why now

Every factual claim carries an inline citation[^<stable-slug>]. Internal links
are bundle-relative: [Related area](/concepts/related-area.md).

## Decision       — what was chosen, phrased unambiguously

## Consequences   — what becomes easier, what becomes harder, what was accepted

## Open questions        <!-- optional -->

[^<stable-slug>]: <source title>
