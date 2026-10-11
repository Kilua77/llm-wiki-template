# `log.md` format

The per-bundle journal (CHARTE §9): append-only, most recent entry first, one file per
bundle at `bundles/<name>/log.md`, **no frontmatter** (the lint enforces this).

## Grammar

```markdown
# Log

## YYYY-MM-DD                     ← most recent date first; create the section if absent
* **<Action>**: [<Title>](<bundle-relative path>) — <one-line summary>. (<actor>)
```

- One entry per line, bullet form, in this exact shape — the metrics block of the weekly
  lint greps these lines (they are the repository's telemetry).
- Paths are bundle-relative: `references/slug.md`, `concepts/page.md`.
- An existing entry is **never edited or deleted** (§12.5); new entries are added under
  today's date.
- `log.md` files merge with `merge=union` (`.gitattributes`) — concurrent append by two
  agents is safe by construction.

## Action vocabulary (closed set)

| Action | When |
|---|---|
| `Creation` | A page was created |
| `Ingest` | A source entered the wiki (raw + reference + page updates) |
| `Update` | A page's knowledge evolved |
| `Merge` | A duplicate was absorbed into a surviving page |
| `Deprecation` | A page was marked outdated-but-kept |
| `Lint` | The weekly semantic lint ran (report summary) |
| `Query-miss` | A wiki search found nothing — the corpus gap signal |

## Special form: `Query-miss`

One line, **only** when a §8.E wiki search found nothing (never on successful searches):

```markdown
* **Query-miss**: "<term>" — no coverage (<actor>)
```

This entry goes to the `log.md` of the **closest bundle** even though no page was touched
— it is the only usage feedback the wiki produces about itself, and what feeds the
"corpus gaps" line of the weekly report.
