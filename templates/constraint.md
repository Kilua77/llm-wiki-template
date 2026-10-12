---
type: Constraint
title: <the constraint, phrased as a bound — "X must/never Y">
description: One sentence: the bound and what it constrains.
tags: [<kebab-case-tags>]
status: stable
stale_after: <YYYY-MM-DD>          # required if the bound can move (quota, version…)
generated: { by: <agent>/<model>, at: <ISO-8601> }
applies_to:                        # optional, recommended (§13.2)
  - /concepts/<area>.md
code_refs:                         # optional — where the invariant lives in code/tests (§13.2)
  - repo: <public URL or bare local slug>
    commit: <full 40-hex sha>
    path: <relative path, no leading slash>
sources:
  - id: <stable-slug>
    resource: <public URL or "observation:<YYYY-MM>">
    title: <source title>
    author: <source author>
    last_modified: <YYYY-MM-DD>
---

[Self-contained summary: the bound, its source, and what it forbids. A hurried agent stops here.]

## Details        — origin of the bound (spec, platform, measurement), exact scope, what it rules out

Every factual claim carries an inline citation[^<stable-slug>]. Internal links
are bundle-relative: [Related area](/concepts/related-area.md).

## Open questions        <!-- optional -->

[^<stable-slug>]: <source title>
