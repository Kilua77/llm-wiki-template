---
type: Tool
title: <title>
description: One sentence saying what this page covers and why it matters.
tags: [<kebab-case-tags>]
status: stable
stale_after: <YYYY-MM-DD>          # only when the knowledge is dated
generated: { by: <agent>/<model>, at: <ISO-8601> }
# Engineering fields (CHARTE §13.2), all optional except code_refs on a Decision:
# code_refs:      [{repo, commit (40-hex), path, lines?, note?}]  → stale_after becomes required
# applies_to:     [/bundle-relative/paths.md]                     → existence checked
sources:
  - id: <stable-slug>
    resource: <public URL>
    title: <source title>
    author: <source author>
    last_modified: <YYYY-MM-DD>
---

[Self-contained summary, 2–5 sentences. A hurried agent stops here.]

## Details

Every factual claim carries an inline citation[^<stable-slug>]. Internal links
are bundle-relative: [Other Concept](/concepts/other-concept.md).

## Open questions        <!-- optional: uncertainties, unresolved contradictions -->

## Related

- [Related page](/concepts/related-page.md) — one clause on the relation.

[^<stable-slug>]: <source title>
