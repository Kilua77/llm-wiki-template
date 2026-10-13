# Architecture — the assembled system

This document is the **descriptive** view of the whole method: how the pieces
fit together, who writes through which channel, where every check runs, and
what the system deliberately refuses to do. The **normative** contract is
`CHARTE.md` — every rule cited here carries its section number (`§`). If this
document and the charter ever disagree, the charter wins; resync this file.

Written for the agent (or human) that needs to understand the machine before
operating, extending or debugging it. To *build* one from scratch, read
`docs/IMPLEMENTATION-GUIDE.md` instead.

## 1. The system in one picture

```
                        ┌────────────────────────────────────────────────┐
                        │                 THE OWNER                      │
                        │  says yes/no · curates sources · arbitrates    │
                        │  (bundles, syntheses, splits, charter, tiers)  │
                        └───────▲────────────────────────▲───────────────┘
                                │ reports (weekly lint,   │ "yes" on proposals
                                │ metrics, automerge)     │
┌───────────────┐   ┌───────────┴──────────┐   ┌─────────┴──────────────┐
│ LOCAL AGENTS  │   │  THE WIKI REPOSITORY │   │  REMOTE AGENTS         │
│ (have a clone │   │  (Git, one per wiki) │   │ (git API only: no      │
│  + a shell)   │   │                      │   │  clone, no shell)      │
│               │   │  bundles/<b>/…       │   │                        │
│ commit.sh ────┼──▶│  CHARTE.md           │◀──┼─ branch agent/<a>/<s>  │
│  flock → gen- │   │  proposals/          │   │  + PULL REQUEST        │
│  index → lint │   │  tools/  schemas/    │   │        │               │
│  → commit →   │   │  templates/ tests/   │   │        ▼               │
│  rebase-push  │   │  .githooks/          │   │  CI: regenerate index, │
│               │   └──────────┬───────────┘   │  re-commit to the PR,  │
└───────────────┘              │ origin        │  lint --ci             │
                               ▼               └────────────────────────┘
                     ┌──────────────────┐        │ (PR merge)
                     │  the git forge   │◀───────┤
                     │  (optional: the  │        ▼
                     │  wiki can live   │   ┌──────────────────────┐
                     │  local-only too) │   │ DAILY AUTOMERGE cron │
                     └──────────────────┘   │ 4 conditions, else   │
                                            │ held + reported      │
                                            └──────────────────────┘
   Outside the repository, on purpose:
     · the private denylist  (~/.config/wiki-lint/, $WIKI_DENYLIST)
     · the project's binaries and documents (hash + reference only, §13.5)
     · the code repositories the wiki cites (§13.6 — decoupled, often local)
```

Three properties to hold onto:

- **One repository, one charter.** Everything normative lives in `CHARTE.md`;
  every other file is either generated (indexes), mechanical (tools), or a
  pointer (AGENTS.md, skills, this document).
- **The wiki never grows outward by accident.** The denylist and the cited
  binaries stay outside; inside is text-only, deemed releasable to the
  declared audience (§2).
- **No write path bypasses the lint.** Local commits run it through
  `commit.sh`; remote writes meet it twice — CI on the PR, and the full
  denylist-included replay before any automatic merge.

## 2. Write channels

### 2.1 Local channel (the normal path)

```
agent edits files
   │
   ▼
tools/commit.sh "<msg>" "<actor>"
   │  1. re-invoke under flock -o /tmp/llm-wiki.<repo>  ← close-on-exec:
   │     a daemon forked below the lock cannot inherit it (paid-for lesson)
   │  2. python3 tools/gen-index.py        ← indexes are generated, never edited
   │  3. git add -A                        ← absorbs the whole tree — check
   │     `git status` first                                your sandbox!
   │  4. python3 tools/lint.py             ← 7+ checks, errors block
   │  5. git commit (message + Acting-Agent trailer)
   │  6. git pull --rebase && git push     ← 2 attempts; without a remote:
   ▼                                        "committed locally only"
main
```

Failure branches: lint red → no commit, fix and retry; push fails twice →
loud exit 1 (resolve manually). The `.githooks/pre-commit` hook replays
gen-index + lint for anyone committing by hand — `core.hooksPath` is wired by
`tools/init.sh` because **git never copies hooks on clone**.

### 2.2 Remote channel (agents without a clone)

```
remote agent (git API only)
   │  branch agent/<actor>/<slug>  — NEVER write on main (ruleset enforces)
   │  files + Acting-Agent: <actor> in the commit message
   │  touches NO index.md (the generator cannot run there)
   ▼
pull request ──▶ CI ──▶ regenerate indexes ──▶ re-commit them to the PR
   │                    (deploy key: a GITHUB_TOKEN push would not
   │                     re-trigger CI — required check would hang forever;
   │                     no key → CI fails loudly, refusing a silently
   │                     stale index)
   ▼
daily automerge cron — merges ONLY if all four hold:
   1. CI checks green at the head commit
   2. full local lint, private denylist included, replayed in a throwaway
      worktree (the one check CI structurally cannot do)
   3. diff touches nothing structural (CHARTE.md, */syntheses/*, proposals/*,
      .github/+tools/, any bundle absent from main)
   4. mergeable, not a draft
   anything else → HELD and reported. Never force-pushed, never closed.
```

Merging anything non-routine is the owner's gesture — that is where review
happens. A local agent can replay the same full lint on open PRs at any time
with `tools/review-prs.sh` (report-only).

### 2.3 MCP channel (optional, read-mostly)

A small server in front of the repository offering three semantic tools —
`search`, `read_page`, `propose_edit` — to hosted clients that would
otherwise burn tokens on file-by-file git access. `propose_edit` **rides the
remote channel**: throwaway worktree → lint → branch → PR. Nothing about the
governance changes; the server opens no new write path. See
`docs/guides/MCP-SERVER.md`.

## 3. Lint stages — the full matrix

| Stage | Runs where | Denylist | Fails on | Informational |
|---|---|---|---|---|
| pre-commit hook | every manual commit | yes (local file, if present) | errors | warnings, notices |
| `tools/commit.sh` | every scripted local write | yes | errors | warnings, notices |
| CI `lint.py --ci` | every push and PR | **no** (cannot leave the machine) | errors | warnings, notices |
| automerge / review-prs replay | PR head, in a throwaway worktree | **yes** | errors → PR held | — |
| weekly semantic pass | maintenance agent (`process:lint-weekly`) | yes | nothing (it reports) | the whole report |

What the structural lint checks (`tools/lint.py`): bundle inventory against
the charter markers (§3), frontmatter conformance incl. the §13 engineering
fields, reserved-file rules, internal links, publishability scan (generic
patterns + denylist locally), index freshness, orphans, synthesis invariants
(§6.5), computed freshness (§8.F), document re-ingestion (§13.2), contested
listing. The weekly pass adds the judgments a script cannot make — and closes
with the `tools/metrics.py` block (actions, Query-miss, pages-per-bundle
threshold, dead weight, contested aging, routing clusters).

**The one asymmetry to remember:** the only true anti-leak barrier is local.
CI is structurally blind to the denylist — which is why the automerge replay
exists, and why everything meant to stay private must be anonymized at
writing time (§2), never filtered later.

## 4. Anatomy of one write — `ingest` end to end

A source arrives; an agent ingests it into bundle `b` (§8.A / §13.5):

1. **Route**: the §7 tree — worth writing? releasable? which bundle? If no
   bundle fits: proposal (§10), create nothing while waiting.
2. **Dedup**: for a URL, hash the fetched content against existing
   `content_sha256`; for a document, `sha256sum` the binary against existing
   `source_file.sha256` (same date ⇒ chapters, different date ⇒ new file).
3. **Capture**: `tools/ingest-doc.sh b file.pdf` — converts (pandoc /
   pdftotext), splits chapters, assembles the raw header, regenerates
   indexes, lints. It never commits.
4. **Distill**: write/update the reference digest (`references/`, §6.2 — what
   THE SOURCE says) and every knowledge page touched (what WE know, §6.1);
   engineering material follows §13.4 (requirements → Constraint, decisions →
   Decision, procedures → Playbook). Weave links both ways.
5. **Log**: one `Ingest` entry in `bundles/b/log.md` (§9).
6. **Commit** through a channel — locally `commit.sh "wiki(b): ingest — …"`.
7. If remote: PR → CI (index regenerated onto the branch) → automerge (4
   conditions) or owner review.

Failure branches worth knowing: lint red at step 3/6 → nothing lands until
fixed; CI without a deploy key refuses a stale index **explicitly**; an
automerge condition missed → PR held, reported, never force-merged; a
Query-miss on the routing step leaves a one-line log entry — the corpus's
only usage feedback about itself (§8.E).

## 5. Governance matrix — who decides what

| Decision | Owner | Local agent | Remote agent | Process |
|---|---|---|---|---|
| New bundle (§10) | **yes/no** — silence = no | proposes (§6.4) | proposes by PR | weekly lint flags ≥3-page clusters |
| Bundle split (§10.6) | **yes/no** on the split plan | drafts the plan | — | metrics flags ≥ ~100 pages two weeks running |
| Synthesis (§6.5) | **yes/no** · grants `stable` | writes, keeps fresh | PR | lint enforces invariants, signals maturity |
| Charter change (§12.10) | **yes/no** | drafts the commit | — | charter commits always reported |
| Merge of non-routine PR | **yes** | reviews (`review-prs.sh`) | — | automerge holds, never closes |
| `verified human:` (§5) | **only them** (or explicit instruction) | machine-confirmed only | — | stale `verified` stripped by weekly lint |
| Contested of values (§8.F) | **arbitrates** | reconciles or settles by evidence | — | rotation, >60d escalation |
| Search tier-up (§11) | **decides** | measures | — | metrics warns at threshold |
| git-lfs, audience, denylist | **decides/maintains** | never touches the denylist (§12.9) | — | — |
| Routine PR merge | — | — | — | **automerge, 4 conditions** |

The load-bearing convention: **an agent proposes, the owner disposes.**
Everything the machines do is reversible-and-reported or blocked-and-reported.

## 6. File topology

```
authored, normative      CHARTE.md (single contract, §-markers parsed by tools)
authored, descriptive    README.md · AGENTS.md · CLAUDE.md · docs/*
machine counterparts     schemas/ (JSON Schema + grammars) · templates/ (copyable)
mechanics                tools/{lint,gen-index,metrics,ingest-doc,commit,
                                  new-bundle,automerge,review-prs}.sh|.py
                         tools/lib/automerge-lib.sh (pure predicates)
                         .githooks/pre-commit · .github/workflows/lint.yml
generated, never edited  bundles/**/index.md        (gen-index.py)
append-only              bundles/**/log.md          (merge=union via .gitattributes)
content                  bundles/<b>/{concepts,entities,syntheses,references,raw}
proposals                proposals/*.md → validated/ | refused/
tests                    tests/ (run-tests.sh + cases/ — hermetic)
outside the repository   the private denylist · the project's binaries ·
                         the cited code repositories (§13.6 — decoupled)
```

Where a concern lives: *rules* → charter §; *why a rule* → `docs/METHOD.md`
(decision records); *how the pieces sit together* → this file; *step-by-step
building* → `docs/IMPLEMENTATION-GUIDE.md`; *agent operations* →
`docs/AGENT-PROTOCOL.md`; *optional layers* → `docs/OPTIONS.md` and
`docs/guides/`.

## 7. The maintenance loop

```
weekly (process:lint-weekly):
  re-verify stale_after / freshness lags ──▶ update or deprecate
  dormant drafts >30d ──────────────────────▶ consolidate or flag
  syntheses behind ─────────────────────────▶ reread, update generated.at
  routing_review pages ─────────────────────▶ re-judge; ≥3 to one candidate ⇒ proposal
  contested (one per bundle) ───────────────▶ reconcile | settle | escalate
  long pages, presumed duplicates ──────────▶ propose, never execute
  git status non-empty ─────────────────────▶ settle or document (WIP rule)
  close with tools/metrics.py block ───────▶ report to the owner + Lint log entry

daily: automerge cron (§2.2) — silence when nothing to say,
       loud when it fails (an unattended failure must reach a signal)
```

The substrate of it all is the `log.md` grammar (§9): a closed action
vocabulary, append-only, merged by union — which is what makes the telemetry
computable and multi-agent writes safe without worktrees.

## 8. Designed refusals

The system says no on purpose; each refusal is a feature with a reason:

- **No silent stale index.** CI without a deploy key fails loudly rather than
  go green over an index it could not carry (`Refuse a silently stale index`).
- **No wild bundles.** A directory under `bundles/` without an inventory row
  fails the lint — corpus structure is owner-arbitrated (§10).
- **No invisible work.** WIP must land as `draft` in the same session; an
  unclean `git status` is reported by the weekly lint (§8 preamble).
- **No silent unattended failure.** The automerge exits 2 when `gh` auth is
  broken; pipelines wire failure to a signal or they do not exist.
- **Silence means no.** Proposals, syntheses, splits — no answer is a no.
- **No binaries, no denylist in-repo, no writing on `main` remotely, no
  hand-edited index, no rewritten log entry** — §12, each with its incident
  history recorded in `docs/METHOD.md` and the upstream lineage.

## 9. Extension points

Optional layers, each additive and never load-bearing for the core loop:
private denylist + leak test (`docs/SETUP.md` B8, automated in
`tests/cases/08-canary.sh`), ruleset + automerge, GitHub App for remote
agents, scheduled weekly lint + metrics, the MCP access layer
(`docs/guides/MCP-SERVER.md`). Removing the engineering profile itself is a
documented one-commit operation (charter Annex A).
