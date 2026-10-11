---
type: Synthesis
title: <title>
description: One sentence on the question this synthesis answers across pages.
tags: [<kebab-case-tags>]
status: draft              # `stable` only after human review (verified human:)
covers:                    # REQUIRED — the pages it derives from, bundle-relative paths
  - /concepts/page-a.md
  - /entities/page-b.md
generated: { by: <agent>/<model>, at: <ISO-8601> }
stale_after: <YYYY-MM-DD>
sources:
  - id: observation
    resource: "observation:<YYYY-MM>"
    title: Direct observation
---

[The question no single covered page answers, answered in 2–5 sentences.]

## <Theme section>

The summary of a covered page reuses its **lead summary**, not its detail — and links
it: [Page A](/concepts/page-a.md). Every claim remains verifiable in the covered page,
which keeps its citations.

<!-- Hard rules (CHARTE §6.5): never write here first (detail pages first, then the
     synthesis); every covers target must be linked in this body; no synthesis of a
     synthesis; update the synthesis in the same commit when a covered page changes —
     the lint refuses the commit otherwise; `stable` requires verified human:. -->
