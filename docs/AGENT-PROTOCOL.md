# Agent protocol — operating the wiki

This is the operating protocol for **any agent** (local CLI agent, remote git-API agent,
scheduled maintenance process) working on this repository. It condenses the charter
into a runnable procedure, with the pitfalls that were paid for in production.

**Authority**: [CHARTE.md](../CHARTE.md) is the contract — this document follows it and
never contradicts it. Frontmatter shapes: [../schemas/](../schemas/) (validate) and
[../templates/](../templates/) (copy). When this protocol and the charter appear to
disagree, the charter wins and this document must be fixed.

## 0. Guidance posture — teach, propose, defer

You are the user's guide into this system, especially while the wiki is young
(freshly initialized, few bundles, few pages). **Teach while operating**:

- **One rule at a time, at the moment it matters.** When the user meets a
  concept for the first time — bundle, the 3+1 filter, statuses, synthesis —
  explain it in one plain sentence with its charter §, instead of jargon or a
  wall of contract. The full contract exists; your job is to spare them
  reading it.
- **Route the user's intent** to the right method before doing anything:

| The user says… | The right method (say so, then do it) |
|---|---|
| "I have a question" / asks something factual | wiki-first read (§1) — answer citing wiki paths |
| "Here is a page / article / link to add" | `ingest` (§4) — raw + reference + page updates |
| "Here is a spec / design doc (Word, PDF)" | document ingestion (§4, CHARTE §13.5) — `tools/ingest-doc.sh`, then the §13.4 reading grid |
| "Here is our codebase / repo" | never ingest it — map it (§4bis, CHARTE §13.7): orient, read history, mine tests, filter, pin |
| "We need a wiki about X" (new subject) | bundle proposal (§3, CHARTE §10) — you draft it, the owner says yes or no |
| "Give me an overview of theme X" | synthesis regime (CHARTE §6.5) — only if the theme is ripe; never spontaneously |

- **Frame the first times.** Before the first bundle, the first document
  ingestion, the first codebase mapping, the first split: propose a short
  **plan** — where to start, how many pages to expect, what deliberately
  stays out — and show **one example before running the series**. A user who
  sees one honest Decision page understands the contract better than by
  reading §13.
- **Propose and explain, never decide for the user.** The governance is
  unchanged: you draft proposals in user language (not contract jargon), the
  owner disposes, and silence means no. When you park something in the
  closest bundle, say so in plain words — that is a `routing_review`, and the
  user should know their wiki carries that marker.

The posture in three words: **teach, propose, defer.**

## 1. Reading — wiki-first

Before answering any knowledge question, search the wiki first:

```bash
ls bundles/                                              # existing bundles
cat bundles/<b>/index.md                                 # map of one bundle
rg -i "<term>" bundles/*/index.md bundles/*/*/index.md   # index lines (title+description)
rg -i --glob '!raw/**' "<term>" bundles/                 # full text, excluding raw sources
```

- Found → answer **citing the page paths**. Flag any passed `stale_after`; ignore
  `deprecated` pages unless history is asked for.
- The conversation adds something new to an existing page → `update` operation.
- **Nothing found → leave a `Query-miss` entry** in the closest bundle's `log.md`
  (one line, failure only): `* **Query-miss**: "<term>" — no coverage (<actor>)`.
  This is the corpus-gap signal the weekly report feeds on. Then answer through
  normal research and run the filter below on what you learned.

## 2. Should it be written? — the 3+1 filter

Knowledge enters the wiki only if it is:

1. **Durable** — still true in six months;
2. **Reusable** — another conversation would benefit;
3. **Non-trivial** — not findable in ten seconds;
4. **Publishable or anonymizable** — the wiki is deemed public.

Otherwise route elsewhere: conversational memory (personal-contextual), the owner's
action system (operational), or nothing (disposable).

### The `[SILENT]` rubric — borderline captures

`[SILENT]` is a correct and complete verdict, not a failure. Four tests, in order;
if any passes, the capture is not `[SILENT]`; if all fail, `[SILENT]`, period:

1. **Non-triviality** — does it teach something not found in 10 s of search? Generic
   tutorials and tips lists rarely pass. The good signal: a **named concept** or a
   reusable **analytical frame**, not just advice.
2. **Durability** — relevant in six months? Anything resting on a price, a view
   count, a recent tool name with no concept behind it, or a "we're still early"
   ranking is trivially perishable. A `stale_after` date does not save it when the
   dated datum is half the value.
3. **Applicative angle** — does it describe how to *build/architect* a system, or
   how an individual *organizes their own use* of a tool? The latter is private
   support or `[SILENT]`, not a routing problem.
4. **Cohesion for a proposal** — if no bundle fits but the three tests pass: could a
   proposal list 5+ candidate pages *from this capture alone*, toward the ~10-page
   potential? An isolated capture with no cluster cannot.

Output discipline: a `[SILENT]` verdict is rendered alone — one marker, no essay.

## 3. Routing — the gates

Read the **inventory** (charter §3) *before* reacting, and read the `index.md` of
every candidate bundle (plus a few pages when unsure) — the wiki classifies by
*concept*, not by surface term; a neighboring page may already carry the idea.

| Situation | Gate |
|---|---|
| An active bundle fits (scope matches, out-of-scope respected) | Write there. If it is only a best fit, set `routing_review` (§7.3) |
| No bundle fits, a `proposals/` file already covers the scope | **Enrich the existing proposal** — never file a second one, never `[SILENT]` |
| No bundle, no proposal, cohesive theme (≥ ~10 pages potential, durable need) | File `proposals/YYYY-MM-DD-<slug>.md` (template §6.4), commit, **notify the owner**. Never create the bundle |
| No bundle, no proposal, no cohesion | `[SILENT]` |

Self-test before filing any proposal: does the scope still pass §2 (publishability),
§10 (cohesion — a subject, not an aggregate), §1 (mission — not personal memory, not
operational)? What looks bundle-worthy is usually (a) a sub-domain of an active bundle
(→ `routing_review`), (b) a collection without a common subject (→ `[SILENT]`), or
(c) memory/operational material (→ private supports). The cost of a proposal that
passes filing but fails validation is a round-trip plus a file lingering until
arbitration.

**Silence means no.** Until the owner says yes: closest bundle (flagged) or nothing.

## 4. Writing

1. Read the charter once per session if you have not already (§5 fields, §6
   templates, §7 decision tree, §8 operations).
2. **Deduplicate before creating** — search alternate titles too. **Update > create.**
   Duplicate found → `merge` operation.
3. Copy a skeleton from `templates/`, fill it, and validate the frontmatter against
   `schemas/frontmatter-page.schema.json` if you can — the lint is the gate, the
   schema is the pre-flight.
4. **Anonymize while writing** (§2): impersonal voice, public URLs only, direct
   observation as `observation:<YYYY-MM>` when no public URL exists.
   - **Capture scrub** — capture pipelines often deliver "technical substance +
     personal relevance". Only the substance enters the wiki. Keep: public
     product/library/framework names, public dates and benchmarks, canonical public
     URLs, methods and patterns the source describes. Drop: the owner's tools and
     stacks, freelance missions, client and contact names, personal handles,
     intentions ("to try on a project"). Quick test: *"if this paragraph were
     published tomorrow as-is, would anyone regret it?"* — if yes, it does not go in.
5. `contested: true` (or a one-liner) when sources openly contradict on the core of
   the page; `stale_after` whenever a version, price, or dated figure is cited.
6. Update the bundle's `log.md`, then commit (§6 below).

### Ingest, concretely

A source entering the wiki touches **four kinds of files in one commit** (three when
the capture is 100% about an existing concept):

1. `raw/<date>-<slug>.md` — immutable capture (template §6.3), with `content_sha256`
   computed on the converted body. Before re-ingesting a URL, compare the fresh
   content's hash against existing raws for that URL: identical → skip (at most
   refresh the reference's `last_modified`); different → new dated file, never a
   rewrite.
2. `references/<slug>.md` — what *this source* says (not what we know).
3. **Update** of each existing page the source feeds: add it to `sources`, extend the
   body with a paragraph citing `[^<id>]`, refresh `generated.at`.
4. **Create** a concept/entity page for genuinely new material — with bilateral links
   to the updated pages.

Do not merge everything into one existing page (it dilutes the concept); do not
create orphan pages either — weaving links is part of the same flow. Large documents:
one raw file per chapter. Book-scale distillation: keep digests `status: draft` until
the whole book is read — honesty about what was actually read beats optimism.

### Binary documents (Word, PDF — CHARTE §13.5)

Never commit a binary. Route it through the pipeline:

```bash
sha256sum spec.docx                      # dedup key — check before converting
tools/ingest-doc.sh <bundle> spec.docx \
  --stored-at "storage:project-docs"     # where the binary actually lives
```

The tool converts (pandoc / pdftotext `-enc UTF-8`), splits chapters, assembles
the header (`source_file` + `conversion` + `content_sha256`), regenerates indexes
and lints — **it does not commit**: the four-file continuation above is still
yours. No converter installed? Convert by any means, declare it honestly in
`conversion.tool`, and pass `--from-converted <body.md>`.

Reading grid for a system document (CHARTE §13.4): requirements → `Constraint`,
recorded decisions → `Decision`, environment descriptions → `Constraint`,
procedures → `Playbook`. Most chapters yield nothing — filter per chapter, not
per document, and never ingest a document fund wholesale: inventory first
(titles, dates, hashes), prioritize by pain, convert one chapter excerpt and
have the owner read it before running the series.

## 4bis. Engineering material — code and tests

**Citing code** (CHARTE §13.6): the wiki never duplicates production code —
it references `{repo, commit, path, lines}` and captures the non-obvious
(why, trade-offs, traps). The full 40-hex sha only (never a branch), pinned
from something you actually saw (`git -C <repo> show <sha>:<path>`), with
`stale_after` on the page — a pinned commit IS a version. Snippets in bodies
are pedagogical examples, never production copies. Wiki and code repositories
are decoupled: a bare local slug is a valid `repo`.

**Mapping a large codebase** (CHARTE §13.7) — agents fail at this by trying
to read everything. In order, with local git:

```bash
# 1. Orient without reading
git -C <repo> ls-files | head -50                 # shape (or ls-tree -r --name-only, paginated)
git -C <repo> tag | tail -5                       # versions
git -C <repo> log --format= --name-only | sort | uniq -c | sort -rn | head   # churn = pain = knowledge
# 2. Read the history, not the code
git -C <repo> log --oneline -20 -- <hot-path>     # what kept breaking/evolving
git -C <repo> log -S "<symbol>" --oneline          # when an invariant appeared
# 3. Tests as specification — each non-obvious invariant a test encodes → Constraint candidate
# 4. Extract through the §2 filter — most code yields NOTHING
# 5. Pin while reading — code_refs at the sha you are on, stale_after set
```

Coverage is **bottom-up**: start from the pains, fixes and decisions actually
encountered. A top-down architecture view only ever arrives as a synthesis
(§6.5 regime). Anti-patterns, named: dumping the directory tree into a page;
ingesting the changelog; "reading everything first".

**Test knowledge** (CHARTE §13.4): *how* to test/reproduce → `Playbook`;
what the system must impose on itself → `Constraint`; why a testing choice →
`Decision`; a failure lesson → a *Failure lessons* section on the page
concerned. Campaign **results** stay in the CI — a result is an action-system
state, not knowledge (§2 filter rejects it).

## 5. The six operations

One-liners — the full procedures are charter §8:

- **`ingest`** — a source enters: raw + reference + page updates + log + commit (§4 above).
- **`update`** — reread the page AND its recent log entries first; body reflects the
  state of knowledge, not a changelog; drop `verified` if content changed materially.
- **`merge`** — absorb a duplicate: surviving page, union of sources, tombstone
  (`status: deprecated`, body = `Merged into [X](/…/x.md).`), redirect inbound links,
  reread the diff.
- **`deprecate`** — outdated but kept: `deprecated` + a header line saying why and
  what to turn to. Never delete.
- **`query`** — wiki-first reading, with `Query-miss` on failure (§1 above).
- **`lint`** — structural (`python3 tools/lint.py`, any time) and semantic (weekly,
  as `process:lint-weekly`, charter §8.F — a maintenance agent **never** creates,
  merges or synthesizes anything: mechanical fixes and the report only).

## 6. Committing

**Local channel** — the only write path:

```bash
tools/commit.sh "wiki(<bundle>): <action> — <object>" "<actor>"
```

It regenerates the indexes, lints, commits under a lock, then rebases and pushes.
Never commit by hand, never bypass the hook.

- **WIP rule**: every file write ends in a commit **in the same session**. Unfinished
  work commits as `status: draft` with a log entry saying where it stands — uncommitted
  work is invisible to every other agent, to CI, and to the weekly lint.
- **`commit.sh` makes ONE commit per call** (`git add -A` + `git commit` in one
  pass). A second call returns `nothing to commit` — that is expected, not an error.
  For one commit per bundle, stage selectively between calls or accept one commit
  naming the main bundle.
- **`git add -A` absorbs everything** — files staged by other agents, and any stray
  working-tree change. Check `git status --short` right before calling; if your
  commit ends up carrying files beyond your bundle (`git log -1 --name-status`),
  report it — the bundle `log.md` remains the canonical trace of who did what.

**Remote channel** (git API only): branch `agent/<actor>/<slug>`, pull request,
`Acting-Agent:` trailer in the commit message, **never `main`**, never an `index.md`**
— full constraints in charter §8.

### Post-commit warning triage

`lint: 0 error(s), N warning(s)` — errors block, warnings get triaged:

| Warning | Verdict |
|---|---|
| Orphan page you just created | **Yours** — weave a bilateral link from a sibling page, second corrective commit, log it |
| Synthesis adrift, `draft`, or last touched by you | **Yours** — extend `covers` or reread against covered pages |
| Synthesis adrift, `stable`, pages older than its last review | Pre-existing — report, do not touch (`stable` requires human `verified`) |
| Passed `stale_after` on pages you did not write | Pre-existing — cite in the report, leave it to the weekly lint |
| Stale human `verified` | Pre-existing — never set `verified` yourself; report |
| Bundle without an inventory line | **Stop** — you may have created a wild bundle; convert it into a proposal, do not commit it |

Golden rule: a warning that concerns you → corrective commit in the same session; a
pre-existing one → note in the final report and move on.

## 7. Pitfalls (paid for in production — read once, save a session)

**YAML frontmatter**

- Quote any text field containing `:`, `&`, `?`, `#`, `*` — in the main mapping and
  in every `sources[]` entry. One unquoted colon in a title breaks the *whole* page
  (unparsable frontmatter → every check fails).
- URLs with query strings (`?`, `&`, `=`) in a flow mapping (`{ resource: <url> }`)
  break parsing — use block form for such sources:
  ```yaml
  sources:
    - id: origin
      resource: "https://example.com/view?usp=share"
      title: "…"
  ```
- A frontmatter key accidentally prefixed `-` or `+` (slipped in by a diff-style
  edit) silently becomes "no frontmatter". If a validator reports `title=None` while
  the file looks fine, hunt for a prefix typo.
- `status` has exactly three values: `draft`, `stable`, `deprecated`. There is no
  `immutable` — raw immutability is a convention, expressed as `status: stable`.

**Links**

- Internal links are bundle-relative: `[Page](/concepts/page.md)` resolves from the
  **bundle root**; a relative link resolves from the file's directory.
- **Cross-bundle links need exactly two `..`**: from `bundles/<A>/concepts/x.md` to
  `bundles/<B>/concepts/y.md` write `../../<B>/concepts/y.md`. One `..` lands inside
  your own bundle, three land above `bundles/` — both produce "broken link" errors.
  Never use a leading `/` for a cross-bundle target.
- Only link pages that **exist** — a digest listing a book's chapters keeps
  not-yet-ingested chapters as plain text, never as links.

**Orphans and connectivity**

- The orphan check scans `concepts/`, `entities/`, `syntheses/` — `references/` are
  never flagged. Every knowledge page you create must be linked from at least one
  *other* knowledge page in the same commit; `routing_review` does not substitute
  for an inbound link.
- To anchor a reference no page points to, add an inline body line (not a footnote —
  footnotes are not counted) in a page that carries the source:
  `Source digest: [Title](/references/<slug>.md).`

**Concurrency**

- `commit.sh` serializes writers with a per-repository `flock` (close-on-exec, so
  forked daemons cannot inherit it). If your call hangs or exits 124 (timeout):
  check for a live sibling writer first and let it finish; before ever removing a
  lock file, verify no process holds it (`flock -n <lock> true`, `fuser <lock>`,
  `ps -p <pid>`) and get the owner's consent — deleting a live lock costs more than
  waiting.
- "Silent success": your files are in `HEAD` (`git log -1 --name-status`) but
  `git status` is clean and the commit's title/actor are not yours — a sibling's
  `git add -A` absorbed your work. Do not re-run `commit.sh`; report the absorbing
  commit's hash — the bundle `log.md` keeps the canonical trace.
- If the lint fails on files **you did not stage** (another agent's red lint), do not
  edit their files, do not hand-commit, do not retry — paste the exact error verbatim
  in your report and wait for the owner.

**Generated files**

- `index.md` files are generated (`tools/gen-index.py`) — never hand-edit; if one is
  stale, run the generator.
- `_`-prefixed bundle directories are local sandboxes: tolerated locally, an error
  in CI.

## 8. Prohibitions (charter §12, condensed)

1. Never modify/delete `raw/` after ingestion.
2. Never hand-edit an `index.md`.
3. Never commit without the lint (local: via `commit.sh`; remote: via PR, never `main`).
4. Never create a bundle directory without a validated inventory row.
5. Never rewrite or delete a `log.md` entry.
6. Never write personal data, instance identifiers, private URLs or secrets.
7. Never set `verified` without real verification, or `human:` without the owner's
   instruction.
8. Never write into the owner's private systems during a wiki operation — or copy
   their content here without the §7 decision tree.
9. Never touch, cite or commit the private denylist.
10. Never modify the charter without the owner's request or approval.
11. Never create a synthesis without an explicit "yes" — and silence means no.
