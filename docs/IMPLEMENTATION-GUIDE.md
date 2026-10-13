# Implementation guide — building a wiki from this template, phase by phase

This is the complete build manual. Every phase ends with **exit criteria**:
a command and the result you must see before moving on. If an exit criterion
cannot be met with the content of this repository alone, that is a bug in
the template — report it, do not improvise around it.

Two readers: an **implementer agent** (runs the phases), and the **owner**
(human gestures are listed in Annex A and flagged per phase). The quickstart
short form lives in `docs/SETUP.md`; the assembled view of the finished
system in `docs/ARCHITECTURE.md`; the operating protocol for daily agent
work in `docs/AGENT-PROTOCOL.md`.

The order matters: gates are proven **before** content arrives, and the
weekly loop starts **before** the corpus is big enough to need it.

## Phase 0 — Prerequisites

Check (all must run):

```bash
git --version && python3 --version && python3 -c "import yaml; print('pyyaml ok')"
flock --version | head -1 && bash -c 'echo bash ok'
```

Optional but recommended: `rg` (ripgrep, search recipes §11), `gh` (forge
integration, phase 3), `pandoc` + `pdftotext` (document ingestion §13.5),
`python3 -c "import jsonschema"` (schema pre-flight). Missing pandoc or
pdftotext is fine — `ingest-doc.sh --from-converted` is the documented
fallback.

**Exit**: every mandatory command prints a version. Note which optional
tools are absent — phases 3 and 8 adapt accordingly.

## Phase 1 — Scaffold

```bash
git clone <this-template> my-wiki && cd my-wiki
tools/init.sh                 # or: tools/init.sh --keep-example
```

`init.sh` removes the demonstrative bundle and its inventory row (unless
`--keep-example`), regenerates indexes, runs the lint with rollback on
failure, wires `core.hooksPath=.githooks` (git never copies hooks on clone),
deletes the template marker and makes the initial commit.

**Exit criteria**:
- `ls .wiki-template` → *No such file* (the clone is now a wiki)
- `python3 tools/lint.py` → `lint: 0 error(s)`
- `git config core.hooksPath` → `.githooks`
- `git log --oneline | head -1` → an initial commit exists
- With `--keep-example`: `bundles/example/` still present, lint still clean

## Phase 2 — Prove the gates

Create the private denylist (the one publishability check that cannot live
in the repository):

```bash
mkdir -p ~/.config/wiki-lint && ${EDITOR:-vi} ~/.config/wiki-lint/denylist.txt
```

One lowercase term per line, `#` comments allowed — the private motifs of
your declared audience (§2). Then run the voluntary leak test, automated:

```bash
bash tests/run-tests.sh 08-canary
```

Or by hand (SETUP.md B8): plant a scratch page carrying one denylisted term
plus the generic probes (an email, a token shape, a private-dashboard URL, a
public IP); every probe must produce **its own error line**; delete the page.

**Exit criteria**:
- the canary case passes (or the manual recipe shows one error per probe)
- with the denylist temporarily renamed: the lint warns loudly
  (`denylist missing … refuse to commit until restored`) and still exits 0

## Phase 3 — Remote + CI (optional: the local-only path is complete already)

Follow `docs/SETUP.md` B1–B5: private repository, `INDEX_DEPLOY_KEY` secret,
CI workflow, ruleset on `main` (PR required, admin/deploy-key derogations —
`docs/ruleset-main.json`), then a **test pull request** from a non-bypass
account. Read the workflow comments as you go — each one is a paid-for
lesson (a `GITHUB_TOKEN` push does not re-trigger CI; a missing deploy key
must fail loudly, not pass green over a stale index).

**Exit criteria**:
- the test PR goes green and merges
- you have seen CI **refuse** once: push a PR that changes a page without
  regenerating its index and without the deploy key configured → the check
  fails with the stale-index error (that refusal is the system working)

## Phase 4 — First bundle, by the book

Have an agent file the proposal (`proposals/YYYY-MM-DD-<slug>.md`, §6.4),
the owner answers **yes**, then the owner runs:

```bash
tools/new-bundle.sh <name> --scope "…" --anti-scope "…" --from-proposal <slug>
```

Then the mandatory **relocation sweep** (§10.5): review every
`routing_review` page and everything the new scope could claim; move with
traced operations or keep with an updated reason. Finish with
`tools/commit.sh "wiki(<name>): creation — …" "human:owner"`.

**Exit criteria**:
- the inventory row exists in CHARTE.md; the skeleton in place
- the proposal archived under `proposals/validated/`
- the sweep traced in the logs of **both** bundles (entries moved), or
  explicitly "nothing to relocate" in the commit message
- lint clean; `tools/commit.sh` round-trip done

## Phase 5 — Agent on-ramps

Point every agent that will touch the wiki at `AGENTS.md` (the thin
on-ramp → CHARTE.md → AGENT-PROTOCOL.md). For hosted agents without a
clone, use the remote channel (phase 3) or the MCP layer (phase 7). From
the first session, the wiki-first protocol applies (§8.E): questions are
answered **citing wiki paths**, and failed searches leave a `Query-miss`.

**Exit criteria**:
- at least one agent has answered a question by citing wiki file paths
- at least one `Query-miss` entry exists in some `log.md` (the corpus's
  only usage feedback — its absence means nobody is querying wiki-first yet)

## Phase 6 — Weekly loop

Schedule (cron, systemd timer, whatever runs weekly as the maintenance
agent): `python3 tools/metrics.py` + the semantic pass of §8.F, reported to
the owner, logged as `Lint`. The metrics block is the automatable part; the
judgments (stale re-verification, contested rotation, routing re-judgement)
are the agent's.

**Exit criteria**:
- one report delivered with a `## Metrics (…)` block
- one `Lint` entry in the bundle's `log.md`
- the schedule survives a reboot (it is registered, not ad hoc)

## Phase 7 — Optional layers

Each is additive; skip any without guilt:

- **Automerge** (needs phase 3): cron `tools/automerge.sh` daily, report-only
  first. *Exit*: one run executed against real open PRs, merging nothing
  unless all four conditions hold; a `gh` auth break produces a loud exit 2.
- **GitHub App** for remote agents: SETUP B7. *Exit*: an installation token
  pushes a branch and opens a PR as `app-slug[bot]`, scoped to this repo.
- **MCP access layer**: build per `docs/guides/MCP-SERVER.md`. *Exit*: the
  guide's checklist — a hosted client answers citing wiki paths, and a
  proposed edit arrives as a green PR.

## Phase 8 — Engineering profile (§13)

Already active by default. Install the ingestion dependencies
(`pandoc`, `poppler-utils`), then exercise each convention once, for real:

1. `Decision`: one page from a design choice you actually made, with
   `code_refs` pinned to a sha you verified (`git -C <repo> show <sha>` —
   never a sha you have not seen), `applies_to`, `stale_after`.
2. `Constraint`: one hard bound with its origin (spec, platform, measurement).
3. Document ingestion: `tools/ingest-doc.sh <bundle> <file.pdf>` → verify
   the binary hash, the converter line, the reference digest, the knowledge
   pages (§13.4 routing table), the log entry.
4. Code mapping: apply the §13.7 tiers to one hot zone of the codebase —
   orient without reading, read the history, mine the tests, extract through
   the §7 filter, pin while reading.

**Exit criteria**:
- one artifact of each type exists and passes the lint (CI included)
- `bash tests/run-tests.sh` → all cases green
- the §8.A continuation after `ingest-doc.sh` is fully done (reference,
  pages, links, log, commit) — the script's checklist is empty

## Annex A — Owner gestures (the human UI of the system)

| Gesture | Where |
|---|---|
| Say yes/no (bundles, syntheses, splits) — silence means no | proposals in conversation / PRs |
| Create a bundle | `tools/new-bundle.sh` (after a yes) |
| Grant `verified human:` | page frontmatter, on review |
| Arbitrate a contested of values | weekly report escalation |
| Decide the search tier-up (qmd) at ~100 pages | weekly metrics warning |
| Allow git-lfs for a binary | case by case (§4) |
| Declare the audience | charter header (`Audience:`) |
| Forge setup: repo, deploy key, ruleset, App | SETUP B1–B4, B7 |
| Maintain the private denylist | `~/.config/wiki-lint/denylist.txt` |
| Read the weekly report and answer what needs answering | the weekly loop |

## Annex B — Implementer pitfalls (all paid for at least once)

- **Hooks are never copied on clone.** `init.sh` wires `core.hooksPath`;
  if you skip it, the first manual commit bypasses the lint silently.
- **Deploy key or loud failure.** Without it CI cannot carry regenerated
  indexes into the PR; with `GITHUB_TOKEN` the push would not re-trigger
  the required check — it would hang forever instead of failing.
- **`set -o pipefail` + `grep -q` inverts verdicts.** The producer gets
  SIGPIPE'd by the early-exiting consumer. Write output to a file, then
  grep the file (the whole test harness is built this way).
- **A daemon forked under a file lock inherits it.** `commit.sh` re-invokes
  under `flock -o` (close-on-exec) so git's credential-cache daemon cannot
  hold the repository lock forever.
- **`git add -A` absorbs everything.** Check `git status` before committing;
  a stray sandbox file rides along silently.
- **Command substitution runs in a subshell.** Counters incremented inside
  `$(...)` do not survive (the harness numbers sandboxes with mktemp for
  exactly this reason).
- **pdftotext defaults can betray you.** Always `-enc UTF-8` (and `-layout`
  for prose documents); declare the converter in `conversion.tool`.
- **An unattended pipeline must fail to a signal.** Cron jobs that fail
  silently do not exist. Exit loud, report loud.
