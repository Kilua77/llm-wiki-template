# Optional layers

Everything here is documented but **not wired**: the wiki works fully without any of
it. Add a layer when the need is real.

## 1. Private denylist + leak test

Covered in [SETUP.md](SETUP.md) B8. Summary: the local lint tier loads private motifs
from outside the repository (`~/.config/wiki-lint/denylist.txt`, or `$WIKI_DENYLIST`);
CI only applies generic patterns. A missing denylist produces a loud warning, never a
silent skip — restore it before committing.

## 2. Routine automerge + branch ruleset

Covered in [SETUP.md](SETUP.md) B4/B6. The ruleset makes `main` PR-only for remote
writers (with a bypass for the local channel and deploy keys); `automerge.sh` merges
only the routine PRs, under four conditions, report-only by default.

## 3. A GitHub App for API-only agents

Covered in [SETUP.md](SETUP.md) B7. Minimal permissions (Contents + Pull requests),
installed on the single repository.

## 4. Weekly semantic lint as a scheduled job

Charter §8.F defines the checklist; any scheduler works (cron, systemd timer, an
agent platform's job runner) — what matters is that the actor signs as
`process:lint-weekly`, never creates/merges/synthesizes anything, and the report
ends with the metrics block grepped from the `log.md`s.

## 5. Bulk export from other LLM platforms

When valuable knowledge is trapped in past conversations on platforms without repo
access (chat assistants, research tools), run the prompt below in a **new
conversation inside that project/space**, then hand the output files to a local
agent that runs the normal ingest (§8.A of the charter): URL verification,
deduplication, routing, commit. **Never drop the files into `raw/` directly.**

The prompt is generic — replace the search-term list and the suggested-bundle scopes
with your wiki's domains (the bundle inventory of your wiki is the authoritative
list).

```markdown
# Bulk knowledge export for a technical wiki

You are running a one-time bulk export: gather ALL durable technical knowledge you
can access — not just this conversation — into structured files for a technical wiki
maintained by AI agents. The wiki stores consolidated, source-grounded knowledge in
English, organized by topic. Your output will be ingested by another AI agent that
will verify, deduplicate and integrate it — so structure and provenance matter more
than prose polish.

## Step 1 — Explore as broadly as you can

Search for relevant knowledge, in this order:
1. This conversation.
2. Every other conversation in this project/space you can retrieve.
3. Files attached to the project, if any and if you can read them.
4. Conversations outside this project, if your search/memory can reach them.

Run broad retrieval: many searches, in every language the user works in, over the
domain terms of the wiki's bundles — iterate: each result suggests the next query.

Then output an ACCESS REPORT, before anything else:
- What you could search and what you could not (feature limits, disabled memory).
- The list of conversations found containing relevant knowledge (title + date).
- Whether project files were readable.

Never fabricate access. If you could not search past conversations, say so plainly —
do not invent topics or sources to compensate. Conversation titles and dates appear
ONLY in this report, never inside the exported files.

## Step 2 — Deduplicate across conversations

Merge everything into ONE file per topic, taking the union of sources. If sources
disagree, state both positions with their citations — never silently pick a side.
Export the current state of knowledge, not the history of the discussion.

## Step 3 — Output a manifest

A numbered list of the files you plan to produce, then a short `## Not exported`
section (what you deliberately left out and why). Then start Step 4 immediately.

## Step 4 — Generate the files, in batches

Produce the manifest's files in manifest order, at most 5 per response. Each file is
a fenced code block preceded by `filename: <kebab-case-slug>.md`. If files remain,
end with exactly: `BATCH n/m COMPLETE — reply "continue"`; on "continue", resume at
the exact next file — never regenerate earlier ones.

Two file types:
- `reference` — one per significant source: what THAT source says, its key
  techniques, its reported numbers (attributed as *reported by the author*, never as
  established fact). 150–400 words.
- `knowledge` — one per distinct topic, consolidating all sources. Every factual
  claim carries an inline citation `[S1]`… referring to the frontmatter sources.
  Anything not directly grounded in a listed source is marked `[synthesis]` inline.
  200–600 words.

Frontmatter for every file:

---
title: <Human-readable title>
type: reference | knowledge
summary: <One sentence — what this file covers>
tags: [<kebab-case>, ...]
suggested-bundle: <one of the target wiki's bundle names, or none>
sources:
  - id: S1
    url: <public URL>
    title: <source title>
    author: <author or publisher, if known>
    date: <publication date if known, else omit>
exported: <today's date, YYYY-MM-DD>
origin: <platform name>
---

`suggested-bundle` is a routing hint only — when in doubt, use `none`; a local agent
routes against the bundle inventory.

## Hard rules (violating any of these makes the export worthless)

1. English only.
2. Impersonal — never mention the user, their name, their projects, anything
   identifying. Write as general technical knowledge.
3. Real URLs only — list only URLs that actually appeared in the material you
   retrieved. NEVER invent, complete or "reconstruct" a URL from memory. If you are
   not certain a URL is real, omit it — a missing source is recoverable, a
   fabricated one poisons the corpus.
4. Numbers and claims are attributed: "the author reports a 2.4× speedup", never
   "this gives a 2.4× speedup".
5. Mark synthesis honestly.
6. Nothing personal, no secrets.
7. No filler — if little durable knowledge was found, produce few files, or say so
   plainly.
```

## 6. A wiki MCP server (future draft)

A read-mostly MCP server in front of the repository — semantic `search`, `read_page`
(via `git show origin/main:` for freshness without touching the working tree),
`propose_edit` (throwaway worktree → lint → branch + PR) — so that hosted assistants
get purposeful tools instead of raw file-by-file git access. The write channel does
not change (branch + PR), so the ruleset, CI and automerge apply unmodified. Not
shipped with this template; the design travels well (any git repository, an outbound
tunnel, an OAuth delegation to the forge) but the configuration is per-instance
(domain, app credentials, owner allowlist).

## 7. Beyond

Ideas that traveled well in production and may fit yours: a conversation-mining
routine (periodic export of *external* session logs → on-demand distillation → a
thematic proposal, or an honest "no bundle this cycle"); a capture-inbox webhook
that **evaluates** the 3+1 filter before pushing anything (never a blind copy);
book-scale distillation in slices with an explicit progress file. The common shape:
automation proposes, the owner disposes, and nothing bypasses the lint.
