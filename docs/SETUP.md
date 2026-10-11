# Setup — from template to your wiki

Two paths. **Path A** gets you a working local wiki in minutes. **Path B** adds the
full remote setup (private GitHub repository, CI, branch protection, optional
automerge and agent app). Steps marked **[manual]** cannot be scripted — they need a
human with forge credentials.

## Path A — local only

1. Get the template — clone it, or use the *Use this template* button on GitHub:
   ```bash
   git clone <this-template> my-wiki && cd my-wiki
   ```
2. Run the initializer:
   ```bash
   tools/init.sh            # removes the example bundle, wires hooks, first commit
   ```
   (`--keep-example` to keep the format demo; `--help` for all flags.)
3. Verify the empty state:
   ```bash
   python3 tools/lint.py    # must exit clean
   ```
4. **Recommended now** — create the private denylist (see B8 below for the full
   rationale and the voluntary leak test): the one publishability check that cannot
   live in the repository.
5. First bundle, by the book: have an agent file `proposals/YYYY-MM-DD-<slug>.md`
   (template §6.4), say yes, then:
   ```bash
   tools/new-bundle.sh <name> --scope "…" --anti-scope "…" --from-proposal <slug>
   ```
   and finish with the relocation sweep it reminds you of, then commit.
6. Point your agents at the repository: `AGENTS.md` is the on-ramp, `CHARTE.md` the
   contract, [AGENT-PROTOCOL.md](AGENT-PROTOCOL.md) the procedure.

## Path B — full remote setup

B1. **[manual] Create the private repository and push**
```bash
gh repo create <name> --private --source . --push     # or init.sh --github <owner>/<name>
```
Keep the repository **private** — publishability of the *content* is a standing
standard, but the decision to publish the repository is a separate, explicit one.

B2. **[manual] Mark it as a template** (optional, if you did not start from the
GitHub button): repository Settings → "Template repository". This lets other people
(forking yourself, starting sibling wikis) skip step B1's cleanup.

B3. **[manual] The CI deploy key** — required for remote pull requests to stay green.
An agent writing through the git API cannot run the index generator, so CI
regenerates the indexes **on the PR branch** and commits them; a push made with
`GITHUB_TOKEN` does not re-trigger workflows, which would leave the required check
pending forever — hence a dedicated SSH deploy key:
```bash
ssh-keygen -t ed25519 -f /tmp/index-deploy-key -N "" -C "index-ci"
gh secret set INDEX_DEPLOY_KEY < /tmp/index-deploy-key        # private key → secret
gh repo deploy-key add /tmp/index-deploy-key.pub -t "index-ci"   # public key → deploy key
```
Without it, any PR whose index needs regeneration fails explicitly ("Refuse a
silently stale index") — that is the designed behavior, not a bug; it says the merge
would carry a stale index. **Skipping B3 is the classic frustration** ("my PRs are
all red"): configure the key.

B4. **[manual] Branch ruleset on `main`** — remote writes by pull request only.
Import [`ruleset-main.json`](ruleset-main.json) (Settings → Rules → Rulesets →
New ruleset → import, or `gh api`), which encodes: PR required (0 approvals), the
`lint` check required, no deletion, no non-fast-forward, bypass for admins and
deploy keys. The bypass is what lets the **local** channel (`commit.sh`) push to
`main` directly while remote agents must go through PRs.

B5. **End-to-end test PR** — from any account that is not a bypass actor: branch,
edit a page, open a PR. Expect: CI runs the lint; if the index changed, CI
regenerates and re-commits on the branch (with the deploy key); the PR merges.

B6. **Optional — routine automerge** (a daily cron on a machine with the `gh` CLI
authenticated):
```bash
# report-only:
tools/automerge.sh
# actually merge routine PRs (all four conditions of charter §8):
tools/automerge.sh --merge
```
The four conditions: CI green at the head; full local lint including the private
denylist replayed on the PR in a throwaway worktree; nothing structural in the diff
(charter, syntheses, proposals, tooling/CI, non-existent bundles); mergeable and not
a draft. Everything else is held and reported — never force-pushed, never closed.
Pair it with `tools/review-prs.sh` (report-only) for on-demand full review.

B7. **Optional — a GitHub App for API-only agents** (e.g. hosted chat assistants
with an MCP git connector). Condensed procedure: create the App (no webhook);
permissions **Contents: read/write** and **Pull requests: read/write** only; install
it on this single repository (scoping happens at install time — no header can narrow
it later); point the agent's connector at the App's credentials; block the tools the
agent should not have. Agents then write branches/PRs under the App's bot identity.

B8. **The private denylist and the voluntary leak test** — the local tier's private
motifs (names, hostnames, private URLs you never want committed). It lives outside
the repository **on purpose**: inside, it would itself leak at publication.
```bash
mkdir -p ~/.config/wiki-lint && ${EDITOR:-vi} ~/.config/wiki-lint/denylist.txt
# one lowercase term per line, # comments allowed; or export WIKI_DENYLIST=<path>
```
Then prove the gate closes — create a scratch page containing a denylisted term plus
the generic probes (an email, a `ghp_…` token shape, a private Notion URL, a public
IP), run `python3 tools/lint.py`, and check that **each** produces its own error.
Remove the scratch page. If the lint stays green with a planted marker, the gate is
open — fix that before writing anything real.

## What lives where (after setup)

| Concern | Where |
|---|---|
| Contract, conventions, inventory | `CHARTE.md` |
| Agent procedure + pitfalls | `docs/AGENT-PROTOCOL.md` |
| Frontmatter shapes (validate / copy) | `schemas/` / `templates/` |
| Write path (local channel) | `tools/commit.sh` |
| Structural gate | `tools/lint.py` (pre-commit, CI, manual) |
| Indexes | generated by `tools/gen-index.py` — never hand-edited |
| Remote channel | branch + PR; CI regenerates indexes; ruleset gates `main` |
| Routine merges (optional) | `tools/automerge.sh` cron |
| Publishability, private tier | denylist outside the repo (`WIKI_DENYLIST`) |
| Weekly maintenance | semantic lint per charter §8.F (any scheduler + an agent) |
