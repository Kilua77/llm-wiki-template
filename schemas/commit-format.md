# Commit format

Every commit to the wiki follows one shape (CHARTE §9):

```
wiki(<bundle>): <action> — <object>

Acting-Agent: <actor>
```

- Subject: `wiki(<bundle>): <action> — <object>` — e.g.
  `wiki(knowledge-management): ingest — Karpathy LLM wiki gist`.
- A bundle split (CHARTE §10.6) commits under the **child** bundle's name; the pages
  moved log as `Update` ("moved to … following bundle split") in **both** bundles'
  `log.md`s — the action vocabulary stays closed.
- The `Acting-Agent:` trailer is **mandatory**; it carries technical provenance where the
  frontmatter carries business provenance (`generated`, `verified`, `sources`).
- Non-bundle work (tooling, charter, index regeneration) uses conventional prefixes:
  `chore:`, `docs:`, `tools:` — still with the `Acting-Agent:` trailer. CI's own index
  regeneration commits as `chore(index): regenerate` with `Acting-Agent: process:ci-index`.

## Actor grammar (OKF §7)

| Shape | Meaning | Examples |
|---|---|---|
| `human:<id>` | A human — in practice the owner. Ask for their id the first time; never write personal names | `human:owner` |
| `<agent>/<model>` | An AI agent and the model powering it | `claude-code/<model>`, `hermes/<model>`, `claude-ai/<model>` |
| `process:<id>` | An automated process | `process:lint-weekly`, `process:ci-index` |

Actors appear in three places — frontmatter (`generated.by`, `verified[].by`), `log.md`
entries, and commit trailers — and nowhere else. This convention is
publishability-compatible: it identifies roles, never persons.
