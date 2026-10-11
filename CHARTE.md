# Wiki charter

> **Single contract.** Every agent (Claude Code, Hermes, claude.ai, or any other) that
> reads from or writes to this repository follows this document to the letter. Local
> agent skills are only on-ramps that point here. Every convention change happens HERE
> first, in a dedicated commit — never in local skills.
>
> Version: template 1.0, derived from Charte v2.1 (2026-10-11) · Bundle format:
> [OKF v0.2](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) ·
> Pattern: [LLM Wiki (Karpathy)](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
>
> Template lineage: this charter is an instance-neutral English derivation of a
> production charter (v2.1). Upstream and template evolve separately — see
> `docs/METHOD.md` ("Porting upstream changes") for how to carry a change across.

---

## 1. Mission and boundaries

This repository is a **knowledge wiki maintained by agents**: consolidated declarative
knowledge, organized by subject into OKF *bundles*. Agents read, write and maintain; the
owner curates sources and arbitrates. A page states **what is known about a subject,
across all sources** — not what a single source says (that is the role of `references/`),
not a journal, not a todo-list.

**What the wiki is not**:

- **Not a capture surface.** Content captures go to the owner's capture system, not here.
- **Not an action system.** No tasks, no agenda, no daily notes.
- **Not a personal memory.** Observations about the owner go to the agents' conversational
  memory, never here (see §2).
- **Not a configuration repository.** Operational details of a specific machine or account
  stay in their private supports.

**Language**: English by default (page content, titles, tags, frontmatter). Exception: a
subject with a purely non-English context (e.g. French administration, French law) may be
written in that language. The charter language follows the repository language — this
template ships in English.

## 2. Publishability and anonymization

**Absolute rule: everything that enters a bundle is deemed publishable tomorrow, as-is,
publicly.** No restructuring should be necessary before publication. A true but
non-anonymizable piece of information **does not go to the wiki**.

Forbidden in every file of `bundles/` and `proposals/`:

| Category | Forbidden examples | Publishable form |
|---|---|---|
| Identity of the owner and private third parties | first/last name, email, accounts, handles; names of contacts, recruiters | Impersonal writing ("the operator", passive voice, or nothing). *Public* authors of sources remain cited |
| Instance identifiers | hostname, IP, non-standard port, `/home/<user>/…` paths, machine IDs, contracted provider | "a small VPS (2 vCPU, 8 GB RAM, no GPU)" — the transferable knowledge only |
| Private URLs | Notion links, Google Drive, internal dashboards | Cite the original public source; failing that, `observation` (see §5, `sources`) |
| Private life | health, schedule, relationships, personal administrative situation | Nothing — private support |
| Secrets | API keys, tokens, passwords, seeds | Nothing, never, in any form |

**Before → after examples**:

- ❌ "On homesrv01, AcmeAgent runs six gateways" → ✅ "A typical self-hosted deployment
  runs each profile as a systemd user service"
- ❌ "SSH on port 2200 with fail2ban" → ✅ "SSH on a non-default port, brute-force
  protection enabled"
- ❌ "Alice's capture database feeds the wiki" → ✅ "A capture inbox (e.g. a Notion
  database) can feed ingestion via webhook"

**Anonymize while writing, not after.** If you hesitate about the publishability of a
detail: do not write it, or ask the owner.

**Enforcement**: the lint (§8, operation F) scans secrets and personal motifs. The private
denylist lives **outside the repository** (`~/.config/wiki-lint/denylist.txt`, or whatever
`$WIKI_DENYLIST` points to) — never copy it, cite it or commit it. CI only applies generic
patterns; the denylist is the one check that structurally cannot leave the machine.

## 3. Bundle inventory

**Mandatory first consultation to route a piece of information.** A directory under
`bundles/` that does not appear in this table is a wild bundle: the lint fails. A row is
added here only after explicit owner validation (§10).

<!-- Each row is one validated bundle. The markers below are parsed by tools/lint.py
     and tools/new-bundle.sh — keep them byte-for-byte. -->
<!-- inventory:start -->
| Bundle | Scope (one sentence) | Out of scope (does NOT go here) | Status |
|---|---|---|---|
| `example` | The LLM wiki pattern itself — a demonstrative bundle exercising every directory type (concept, entity, reference, raw with content_sha256, log with Query-miss) | Any real knowledge — this bundle is a live format demo, removed by `tools/init.sh`; your first real bundle comes from a §10 proposal | Demonstrative (removed at init) |
<!-- inventory:end -->

## 4. Layout and naming

```
bundles/<name>/
├── index.md          # bundle root — GENERATED by tools/gen-index.py — DO NOT EDIT
├── log.md            # append-only bundle journal (§9)
├── concepts/         # ideas, methods, patterns          + GENERATED index.md
├── entities/         # tools, services, organizations    + GENERATED index.md
├── syntheses/        # cross-cutting analyses            + GENERATED index.md
├── references/       # one ingested source = one digest  + GENERATED index.md
└── raw/              # IMMUTABLE sources as markdown     + GENERATED index.md
```

- Files in `kebab-case.md`, **one subject = one file**. The OKF ID of a concept is its
  path without `.md`.
- `raw/`: `YYYY-MM-DD-<slug>.md`. Immutable after ingestion — a new version of a source
  is a new dated file, never a rewrite.
- Extra sub-directories are possible if a bundle needs them (e.g. `playbooks/`): declare
  them in the bundle proposal or via a commit explained in `log.md`.
- No binaries (sources are converted to markdown at ingestion, large PDFs/EPUBs chapter
  by chapter). If a binary is ever indispensable, ask the owner (git-lfs to enable).

## 5. Frontmatter — field by field

OKF v0.2 model. Values in English. Machine-readable counterparts of this table live in
`schemas/`; copyable page skeletons live in `templates/`. When this section changes, the
schemas and templates change in the same commit.

| Field | Requirement | Format and rules |
|---|---|---|
| `type` | **Required** (the only field OKF itself requires) | One of: `Concept`, `Tool`, `Service`, `Practice`, `Person`, `Organization`, `Synthesis`, `Reference`, `Playbook`, `Raw Source`. A new type: propose it through a commit (detail in the log), the weekly lint consolidates |
| `title` | Required here | Human-readable name of the subject |
| `description` | Required here | **One sentence.** It is the index line: agents scan title+description before opening |
| `tags` | Required here (≥1) | Kebab-case list: `[ai-llm, self-hosting]`. A new tag is allowed if no existing one fits; flag it in the commit message |
| `status` | Required here | `draft` (medium confidence, incomplete, open contradiction) · `stable` · `deprecated` (kept for the record) |
| `stale_after` | Required if the knowledge is dated | `YYYY-MM-DD`. Any page citing a version, a service state, a price, a dated figure MUST carry one |
| `generated` | Required here | `{ by: <actor>, at: <ISO-8601> }` — `at` = last significant edit |
| `verified` | Forbidden except after real verification | `{ by: <actor>, at: <date> }` (or a list). `human:` = human review, reserved for the owner or on their explicit instruction. An agent re-checking against an independent source puts its own actor (= the "machine-confirmed" tier). NEVER set `verified` when creating the page |
| `covers` | **Required on a synthesis** (§6.5), forbidden elsewhere | List of bundle-relative paths to the pages the synthesis derives from. The lint checks their existence, their linkage in the body, the absence of a synthesis among them, and that the synthesis is not behind their `generated.at` |
| `routing_review` | Required if the page was **parked in the closest fit** (§7.3) | `{ reason: <one sentence>, candidate: <suspected bundle, or omitted>, since: YYYY-MM-DD }`. Marks a page whose current bundle is a best fit, not a right fit. The lint lists them on every run; the weekly lint (§8.F) and every new-bundle validation (§10) re-judge them. It is removed — the log entry says so — as soon as the page is relocated or the attachment becomes final |
| `contested` | Optional — open contradiction | `true`, or a short sentence describing the between-sources contradiction affecting the core of the page (generalizes §7.5 when *Open questions* is not enough to flag it). The weekly lint (§8.F) lists `contested` pages and resolves them by rotation; it is removed as soon as the contradiction is settled (pages updated, or `deprecated`) |
| `sources` | Required (≥1) | List: `{ id: <stable-slug>, resource: <PUBLIC URL>, title, author, last_modified }`. `resource` required per entry. Direct observation without a public URL: `{ id: observation, resource: "observation:<YYYY-MM>", title: "Direct observation" }` — never a private URL (§2) |

Classic mistakes to avoid: frontmatter without its closing dashes; `stale_after` as a
datetime (it is a date); `verified` set at creation; `sources` with a Notion URL; tags in
Title Case.

## 6. Templates (copy as-is)

### 6.1 Knowledge page (`concepts/`, `entities/`, `syntheses/`…)

```markdown
---
type: Tool
title: Example Tool
description: One sentence saying what this page covers and why it matters.
tags: [ai-llm]
status: stable
stale_after: 2027-02-01
generated: { by: <agent>/<model>, at: 2026-01-15T10:00:00Z }
sources:
  - id: official-docs
    resource: https://example.org/docs
    title: Official documentation
    author: Example Org
    last_modified: 2026-06-01
---

[Self-contained summary, 2–5 sentences. A hurried agent stops here.]

## Details

Every factual claim carries an inline citation[^official-docs]. Internal links
are bundle-relative: [Other Concept](/concepts/other-concept.md).

## Open questions        <!-- optional: uncertainties, unresolved contradictions -->

[^official-docs]: Official documentation
```

### 6.2 Source digest (`references/`)

Identical, with `type: Reference`, `sources[0].resource` = **canonical URL of the source**
(deduplication key: always check that no existing reference carries this URL before
creating one), and a body that summarizes **what this source says** (not what we know
about the subject).

### 6.3 Header of a `raw/` file

```markdown
---
type: Raw Source
title: <original title>
description: Raw capture of <source>, ingested YYYY-MM-DD. Immutable.
tags: [raw]
status: stable
content_sha256: <sha256 of the converted body, without the frontmatter>
generated: { by: <actor>, at: <ISO-8601> }
sources:
  - { id: origin, resource: <public origin URL>, title: <title> }
---
[converted content, unretouched]
```

`content_sha256`: fingerprint of the converted body, set **at ingestion only** — the raw
being immutable, it is never recomputed. Before ingesting a URL, the agent compares the
hash of the freshly fetched content against the `content_sha256` of existing raws for the
same URL: identical → the source has not changed, no need to re-ingest (at most update the
reference's `last_modified`); different → new dated file, never a rewrite.

### 6.4 Bundle proposal (`proposals/YYYY-MM-DD-<slug>.md`)

```markdown
---
type: Bundle Proposal
title: <proposed name>
description: One-sentence scope of the proposed bundle.
status: draft
generated: { by: <actor>, at: <ISO-8601> }
---

## Motivation        — why no existing bundle fits (cite the inventory)
## Scope             — one sentence; ## Out-of-scope — what will not go there
## Tree              — planned sub-directories if they differ from the standard layout
## Initial pages     — 3 to 5 candidate pages (title + description)
## Overlaps          — overlaps with existing bundles and how they are arbitrated
```

### 6.5 Synthesis (`syntheses/`) — a derived page, special regime

A synthesis is the **only type of page derived from other pages of the wiki**. It
duplicates by construction and silently rots when its inputs move: it therefore obeys a
stricter regime than other pages.

**When to write one — never spontaneously.**

1. It answers **a question no single page answers** (relations, trade-offs, order of
   operations, contradictions between sources). Additivity test: remove every sentence
   that reformulates an existing page; if nothing remains, the page must not exist.
2. The theme already counts **≥ 5 pages** in the bundle. A synthesis is never the first
   page of a subject: structure is a **consequence** of content, never a precondition.
3. **Explicit owner approval, as for a bundle (§10) — silence means no.** The agent
   proposes (in conversation, on its channel, or by PR), the owner decides. One synthesis
   per theme: updating > creating.
4. It does not replace `index.md`, which already lists titles and descriptions and always
   stays current. A synthesis that **enumerates** the pages of the bundle is redundant:
   that is the main anti-pattern.

**Writing order (hard rule).** Write **first in the detail page**, only then summarize in
the synthesis. Never the other way: nothing may exist solely in a synthesis.

**Specific frontmatter.**

```yaml
type: Synthesis
status: draft              # `stable` only after human review (verified human:)
covers:                    # REQUIRED — the pages it derives from, bundle-relative paths
  - /concepts/page-a.md
  - /entities/page-b.md
generated: { by: <actor>, at: <ISO-8601> }
stale_after: <YYYY-MM-DD>
```

**Invariants checked by the lint** (`tools/lint.py`):

- `covers` non-empty, every target exists **and is linked in the body**;
- **never a synthesis of a synthesis** — an entry of `covers` cannot be a synthesis;
- **derived freshness**: if the `generated.at` of a covered page is more recent than that
  of the synthesis, it is **behind** → error, reread and update (the review updates
  `generated.at`, which clears the flag);
- **a synthesis is never a source**: no page may cite it in `sources` (this is what cuts
  the derivation loop);
- `status: stable` requires a `verified` entry with a `human:` actor — without human
  review, the synthesis stays `draft`.

**Computed drift (the lint does it, nobody does it by hand).** Two informational signals
complete the invariants above:

- *synthesis adrift from its theme* — pages sharing the synthesis's tags are not in
  `covers`: it has drifted from its subject (extend `covers`, or tighten scope and tags).
  A **new page does not rot** a synthesis, it makes it incomplete: this signal is what
  catches it.
- *tag X has N pages and no synthesis* — a theme has reached the §6.5 threshold without a
  synthesis. The lint **proposes**, it creates nothing: the decision stays with the owner.

**Who does what**, to remove all ambiguity: the **lint** evaluates and alerts on every
commit; the **agent that modifies a covered page** updates the synthesis in the same
commit (the lint refuses the commit otherwise); the **weekly lint** (§8.F) catches up with
drift and relays proposals; the **owner** alone authorizes creation and grants `stable`.

Body: the summary of a covered page reuses its **lead summary**, not its detail. The
synthesis **augments** the pages, it does not replace them: every claim remains
verifiable in the covered page, which keeps its citations.

## 7. Writing decision tree

Run in order, on every urge to write:

1. **Does it need to be written somewhere?** The information must be **durable** (still
   true in 6 months), **reusable** (another conversation could benefit) and **non-trivial**
   (not findable in 10 s). Otherwise: conversational memory (personal-contextual), the
   owner's action system (operational), or nothing.
2. **Is it publishable or anonymizable?** (§2). Not anonymizable → private support, STOP.
   Anonymizable → anonymize **now**, while writing.
3. **Which bundle?** Consult the inventory (§3). "None fits" is judged **after reading
   the `index.md` of candidate bundles**, not from memory — the index lists titles and
   descriptions, it is authoritative. None fits → "new bundle" process (§10) and **create
   nothing while waiting**; failing that, park in the closest bundle — and then
   **mandatory** `routing_review` in the frontmatter (§5, with the reason and the
   suspected bundle if one is identifiable), flag it in the commit message and say it in
   the log entry. A page parked by default without `routing_review` is invisible to
   review: that is the debt we refuse to create.
4. **Existing page or new one?** Mandatory search before creation (§11: index + ripgrep
   on titles/descriptions, think of alternate titles). **Update > create.** Duplicate
   discovered → `merge` operation (§8.C).
5. **Which status?** `draft` if medium confidence or open contradiction; `stable`
   otherwise; `stale_after` set if the knowledge is dated. Contradiction between sources:
   do not settle silently → *Open questions* section + `draft` if the core of the page is
   affected.

## 8. The six operations

Every write operation ends **within the same session**: update of the bundle's `log.md`
(§9), then one commit through the appropriate channel. **Work left uncommitted is
invisible** — to the other agents, to CI, to the weekly lint (§8.F, which detects and
reports any unclean `git status`). If a piece of work cannot be finished, committing it
as `status: draft` is always better than leaving it hanging. **Two write channels exist,
and they share the same lint.**

- **Local channel** — the agent has the working repository:
  **`tools/commit.sh "<message>" "<actor>"`**, which regenerates the indexes, lints,
  commits under a lock and pushes. Never commit by hand, bypassing the hook.
- **Remote channel** — the agent only has the git API (no clone, no shell): **never
  write on `main`.** Create a branch `agent/<actor>/<slug>`, write the files there, open
  a **pull request**. CI replays exactly the same lint (`lint.py --ci`). The merge of a
  **routine** PR is automated: the daily cron `tools/automerge.sh` merges only if **all
  four conditions hold** — CI checks green at the head commit; full local lint passed
  **private denylist included**, replayed on the PR in a throwaway worktree; diff
  touching **nothing structural** (charter, `*/syntheses/*`, `proposals/*`,
  `.github/`+`tools/`, any bundle that does not exist yet on `main`); PR mergeable and
  not a draft. Everything else is **held and reported** — never force-pushed, never
  closed: merging anything non-routine remains an owner gesture, and that is where the
  review happens. `tools/review-prs.sh` (report-only) remains the way for a local agent
  to replay the full lint, denylist included, on open PRs at any time. Two constraints
  specific to this channel, because the index generator cannot run there: **touch no
  `index.md`** (§12.2 remains whole — CI regenerates them, and re-commits them itself
  after the merge) and **carry the actor in the commit message** (`Acting-Agent:
  <actor>`), the branch alone not being enough to identify it.

### A. `ingest` — a source enters the wiki

1. Convert the source to markdown → `bundles/<b>/raw/YYYY-MM-DD-<slug>.md` (header §6.3).
   Large document: one file per chapter.
2. Dedup: `rg -l "resource: <URL>" bundles/<b>/references/` — if a reference already
   exists, update it instead of creating.
3. Create/update `references/<slug>.md` (§6.2): what the source says.
4. Update **every** knowledge page touched (one source often feeds several
   concepts/entities); create the missing ones (tree §7). Weave the links both ways in
   the page bodies.
5. Log entry + `tools/commit.sh "wiki(<b>): ingest — <source title>" "<actor>"`.

### B. `update` — the knowledge evolves

1. Reread the page AND its recent entries in `log.md` (another agent may have just
   touched it: `git log --oneline -5 -- <file>`).
2. Edit the body (state of knowledge, not a changelog), update `generated.at`, `status`,
   `stale_after`; add the source to `sources` if new. If the content changes
   significantly, **remove `verified`** (the verification no longer applies).
3. Log + commit.

### C. `merge` — absorb a duplicate

1. Choose the surviving page (the better named/linked one). Merge the content and the
   `sources` (union, no duplicate URL).
2. Turn the absorbed page into a tombstone: `status: deprecated`, body reduced to
   `Merged into [X](/…/x.md).` — or delete it if it was never linked.
3. Redirect every inbound link:
   `rg -l "<absorbed-path>" bundles/<b>/ | xargs sed -i 's|<absorbed-path>|<surviving-path>|g'`
   then reread the diff.
4. Log (`Merge`) + commit.

### D. `deprecate` — outdated knowledge kept for the record

`status: deprecated`, add at the top of the body a line explaining why and what to turn
to instead. Do not delete (git history does not replace readability). Log + commit.

### E. `query` — wiki-first protocol (read)

1. Search (§11) before answering any knowledge question.
2. Found → answer **citing the wiki files** (paths). Ignore `deprecated` pages unless
   history is asked for; flag a passed `stale_after` in the answer.
3. Absent/partial → answer through normal research, then run the §7 tree: if the
   knowledge produced deserves it, it enters the wiki (operation A or B).
4. **If the search found nothing**: leave a `Query-miss` entry in the `log.md` of the
   closest bundle (§9) — this is what makes the corpus gaps visible, the only usage
   feedback the wiki produces about itself. One line, on failure only (never on
   successful searches).

### F. `lint` — maintenance

- **Structural, tooled** (`python3 tools/lint.py`): minimal OKF conformance, broken
  links, stale indexes, wild bundle, publishability scan, **computed freshness signals**
  (informational, never blocking): passed `stale_after`, freshness lag (a page whose
  `generated.at` trails by more than ~90 days behind the most recent `last_modified` of
  its own `sources`), pages longer than ~200 lines (split candidates — "one subject =
  one file"). Run by the pre-commit hook and CI — an agent may run it at any time.
- **Semantic, weekly** (a maintenance agent, actor `process:lint-weekly`): passed
  `stale_after` and freshness lags (re-verify → update + new date, or `deprecated`),
  dormant `draft`s > 30 days (consolidate or flag), **behind syntheses** (the lint flags
  them): reread the synthesis against its covered pages, update it and refresh
  `generated.at` — never just push the date forward; **`routing_review` pages** (the
  lint lists them with their age): re-judge each against the current inventory — if a
  bundle now claims it, propose the move; if ≥ 3 pages point at the same candidate
  bundle, **open a §10 proposal**; if the attachment has become natural, propose removing
  the marker; otherwise do nothing and say so; **`contested` pages** (§5): resolve them
  by rotation; pages longer than ~200 lines: propose splitting; presumed duplicates
  (propose a `merge`, **never an automatic merge**), contradictions (rotating review of
  a tag cluster), stale `verified` (`generated.at` much later → remove `verified`),
  orphan pages (link them or flag them); **non-empty `git status --porcelain`**: settle
  or document (WIP rule, §8 preamble). At the end of the report, a **metrics block**
  (greps over the `log.md`s — the repository's minimal telemetry): this week's actions
  per bundle, the week's `Query-miss` (the gaps), pages per bundle **against the ~100
  threshold of §11**, pages never cited in any log entry (dead weight). Report to the
  owner + log (`Lint`).

## 9. Logging and provenance

**`log.md`** (per bundle, append-only, most recent first, OKF format):

```markdown
# Log

## 2026-01-15
* **Ingest**: [Source title](references/slug.md) — one-line summary. (<agent>/<model>)
* **Update**: [Page](concepts/page.md) — what changed and why. (<agent>/<model>)
```

Actions: `Creation`, `Ingest`, `Update`, `Merge`, `Deprecation`, `Lint`, `Query-miss`
(one line, only when a §8.E wiki search found nothing:
`* **Query-miss**: "<term>" — no coverage (<actor>)`). An existing entry is never
edited; add under today's date (create the section if needed).

**Commits**: message `wiki(<bundle>): <action> — <object>` + trailer
`Acting-Agent: <actor>`. The frontmatter carries business provenance (`generated`,
`verified`, `sources`); the commit carries technical provenance.

**Actor convention** (OKF §7): human `human:<id>` (the owner: ask for their id the first
time, do not write it in the bundles) · agent `<agent>/<model>` (e.g.
`claude-code/<model>`, `hermes/<model>`, `claude-ai/<model>`) · process `process:<id>`
(e.g. `process:lint-weekly`). Actors appear in frontmatter, log and commits — this is
publishability-compatible (no personal names).

## 10. New bundle — mandatory validation

**An agent NEVER creates `bundles/<new>/`. It proposes; the owner decides.**

1. **Criteria** (all required): outside the scope of every bundle of the §3 inventory ·
   a cohesive theme of its own with a potential of ≥ ~10 pages · a durable need (a
   one-off project is not a bundle).
2. **Self-test, before writing**: (a) do the three criteria of point 1 still hold once
   the proposal is phrased — a comfort aggregate to "make pay off" disparate pages is
   not a bundle; (b) **no equivalent proposal is already waiting** in `proposals/` — if
   one is, update the existing proposal instead of filing a second one; (c) the proposed
   scope does not overlap the out-of-scope of an existing inventory bundle.
   **Proposal**: write `proposals/YYYY-MM-DD-<slug>.md` (§6.4), commit, then **notify
   the owner**: in the conversation if present, otherwise through the agent's messaging
   channel, or by PR for a remote agent.
3. **Validation**: only an explicit "yes" from the owner. **Silence means no.** While
   waiting: the closest existing bundle (flagged) or nothing.
4. **Creation after validation**: the owner runs `tools/new-bundle.sh <name>` (or by
   hand: §4 skeleton + **the §3 inventory row** — the inventory is authoritative, the
   lint refuses any non-inventoried directory) and the proposal is moved to
   `proposals/validated/` or deleted.
5. **Relocation sweep (mandatory, same commit or the next)**: review **all** pages
   carrying `routing_review` (the lint lists them) and those the new scope could claim.
   Each is either moved (traced `merge`/move operation: new path, inbound links
   redirected, `routing_review` removed, log entry in **both** bundles), or kept with an
   updated `routing_review.reason` explaining why it stays. A bundle created without
   this sweep leaves the wiki in the exact state that motivated its creation.

## 11. Search

Current tier: **index + ripgrep** (sufficient below ~100 pages per bundle).

```bash
# Overview of a bundle
cat bundles/<b>/index.md
# Search a subject across index lines (title+description)
rg -i "<term>" bundles/*/index.md bundles/*/*/index.md
# Search frontmatters (titles, descriptions, tags)
rg -i --glob '!raw/**' "^(title|description|tags):.*<term>" bundles/
# Full text, excluding raw sources
rg -i --glob '!raw/**' "<term>" bundles/<b>/
# Dedup before creation (alternate titles! try several phrasings)
rg -il "(<term1>|<term2>|<synonym>)" bundles/<b>/
```

Next tier (when a bundle passes ~100 pages, on the owner's decision): `qmd` in
**BM25-only mode** (`qmd search`). The hybrid mode `qmd query` (local LLMs) is not viable
on this class of machine: measured at several minutes per query on CPU-only hosts.

## 12. What an agent NEVER does

1. Modify or delete a file of `raw/` after ingestion.
2. Edit an `index.md` by hand (they are generated).
3. Commit without lint: on the host machine, bypassing the hook/`tools/commit.sh`;
   remotely, by writing on `main` instead of opening a pull request (§8).
4. Create a directory under `bundles/` without the validated inventory row (§10).
5. Rewrite or delete an entry of `log.md`.
6. Write personal data, an instance identifier, a private URL or a secret (§2) — the
   wiki is deemed public.
7. Set `verified` without real verification, or `human:` without the owner's explicit
   instruction.
8. Write into the owner's private systems (second brain, memory, config) during a wiki
   operation — and conversely, copy their content to the wiki without going through the
   §7 tree.
9. Touch the private denylist, cite it or commit it.
10. Modify this charter without the owner's request or approval (a charter commit is
    always reported).
11. Create a page in `syntheses/` without the owner's explicit "yes", or derive a
    synthesis from another synthesis (§6.5). **Silence means no**, as for a bundle.
