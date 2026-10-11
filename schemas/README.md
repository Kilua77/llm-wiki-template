# Schemas — machine-readable counterparts of the charter

Two kinds of artifacts live here:

| Artifact | Role |
|---|---|
| `frontmatter-page.schema.json` | JSON Schema (draft 2020-12) for the frontmatter of any bundle page — the machine counterpart of the CHARTE §5 field table |
| `frontmatter-proposal.schema.json` | JSON Schema for `proposals/*.md` frontmatter (CHARTE §6.4) |
| `log-format.md` | Grammar of `log.md` entries (actions vocabulary, `Query-miss` special form) |
| `commit-format.md` | Commit subject shape, `Acting-Agent:` trailer, actor grammar |

## How an agent consumes them

Before writing a page into the wiki (or preparing one outside it), validate the
frontmatter you are about to write:

1. Parse the YAML frontmatter (between the `---` fences) into an object.
2. Validate against `frontmatter-page.schema.json` (any JSON Schema validator, e.g.
   Python `jsonschema`). Dates arrive as ISO strings once serialized.
3. Remember what the schema **cannot** check — each field's `description` says so:
   `verified` never at creation, `covers` forbidden outside syntheses, no synthesis ever
   cited as a source, synthesis targets linked in the body, kebab-case tags, public URLs
   only. `tools/lint.py` enforces all of these at commit time; the schema is the
   pre-flight, the lint is the gate.

## Authority rule

**CHARTE.md and `tools/lint.py` are authoritative; these schemas follow.** When §5 of the
charter evolves, the schemas, the `templates/` skeletons and the lint change **in the same
commit** — a schema that drifts from the lint is worse than no schema: it would validate
pages the repository rejects, or reject pages it accepts.

The `templates/` directory at the repository root is the copyable counterpart: schemas
are the shape to validate against, templates are the shape to copy.
