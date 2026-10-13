# The MCP access layer — implementation guide (no code shipped)

An **optional** layer: a small self-hosted MCP server in front of the wiki
repository, giving hosted clients (assistants without a clone) three
purposeful tools instead of raw file-by-file git access. **No part of the
template requires it.** In the nominal setup — a local agent, the project's
code local, often without a forge — you never need this layer at all; it
exists for the case where a hosted assistant should read the wiki and
propose edits token-efficiently.

Design stance: this is an **ergonomics** improvement, not a security one.
The write channel does not change (`propose_edit` rides branch + PR), so the
ruleset, CI and automerge apply unmodified — the server opens no new write
path and cannot bypass any gate.

## 1. Tool contracts

Three tools, calibrated on the charter's own protocol:

### `search(query, bundle?)`
Ranked page paths with title + description lines (agents scan those before
opening — §5). Implementation: the §11 tiers server-side — index files +
full text via ripgrep, excluding `raw/`; BM25 (`qmd search`) when a bundle
passes the threshold. The tool returns paths + index lines, never bodies.

### `read_page(path)`
Frontmatter + body of one page, **from the pushed state**, not the working
tree: `git show origin/main:<path>` after a lightweight fetch. Freshness is
guaranteed by construction; the server never touches a working tree for
reads. Path confinement is absolute: no `..`, no leading `/`, an allowlist
of `bundles/` (and optionally `CHARTE.md`) — traversal attempts are rejected,
not normalized.

### `propose_edit(path, description, patch)`
A unified diff proposed by the client. Server-side: throwaway worktree at
`refs/pull/…` head → apply patch → minimal frontmatter lint → branch
`agent/mcp/<slug>` → **pull request**, never `main`, never an `index.md`.
The PR then faces exactly what any remote PR faces: CI, and the automerge's
four conditions or the owner. The server holds no merge power.

## 2. Deployment topology — outbound-only

The server runs on the wiki's host, listening on `127.0.0.1` only, and
reaches the outside through an **outbound tunnel** (e.g. a Cloudflare named
tunnel to a subdomain you control). No inbound port is opened; the host
firewall stays as it was. Alternatives considered and rejected upstream:
reverse-proxying on :443 (an open port for zero benefit) and third-party
tunnel services (a third party in the control path — the same reason
Composio-style delegation was retired there).

The tunnel can be **stopped** at any time (`cloudflared` disabled) with zero
impact on the local loop — the layer is additive by construction.

## 3. AuthN/AuthZ — delegation to the forge

Do not build an identity system; **delegate**:

- The server is a *resource server* per **RFC 9728** (Protected Resource
  Metadata): it advertises its authorization server, which is the forge the
  wiki already uses (GitHub in the reference setup).
- The existing **GitHub App** (the one that opens PRs for remote agents,
  scoped to this repository only) doubles as the authorization server side:
  clients authenticate with the forge, present a token, the server validates
  audience + expiry.
- An **owner allowlist** on top: the server serves a fixed list of accounts
  regardless of what the forge accepts — the wiki's owner decides who reads.
- Tunnel access token kept with the server's own secrets, file mode 600,
  outside the repository.

## 4. Security model, stated plainly

| Concern | Mechanism |
|---|---|
| Path traversal | allowlist + reject (never normalize) `..`/absolute |
| Stale reads | `git show origin/main:` + periodic fetch |
| Unvetted writes | impossible — writes are PRs; CI + automerge unchanged |
| Unknown readers | owner allowlist at the server |
| Audit | the PR trail + `log.md` (the server adds no parallel trace — everything it does is visible in the forge) |
| Rate/abuse | per-token rate limits; the tunnel provider's own limits |

## 5. Paid-for pitfalls (each one cost a session upstream)

- **JWT of a GitHub App is RS256**, not HS256 — the wrong algorithm gives
  opaque 401s from the token endpoint.
- **`git grep` on a ref returns exit 1 on no match** — distinguish "no
  results" from "failure" before mapping to tool output.
- **`git ls-tree` needs directory markers** to walk a tree; missing them
  yields silently empty listings.
- **Pathspec exclusion needs `**`** — `'bundles/**'` vs `'bundles/*'` differs
  one level deep.
- **FastMCP derives the tool schema from the function signature** — custom
  decorators without `functools.wraps` produce empty/wrong schemas and the
  client sees garbage parameters.
- **Tunnel login (headless) expires fast** (~minutes for the interactive
  flow; the downloaded certificate persists — the certificate is the durable
  artifact, not the session).
- **CNAME invisibility**: under a proxied zone, `dig CNAME` shows nothing
  (flattening) — verify with `dig A @1.1.1.1` against the tunnel's edge IPs.
- **Fetch cadence**: `git show origin/main:` is only as fresh as the last
  fetch — schedule it, and state the freshness in `read_page` output if the
  wiki moves fast.
- **Tool descriptions drift from the charter**: re-sync the three tool
  descriptions whenever their grounding § changes, in the same commit.

## 6. Implementation checklist and exit criteria

Build order, each with its exit:

1. Server skeleton (FastMCP or equivalent), bound to `127.0.0.1:<port>`;
   three tools against a **local clone**. *Exit*: a local MCP client lists
   the three tools; `search` returns ranked paths for a known term; a
   traversal attempt on `read_page` is refused.
2. Real write path: `propose_edit` produces a real branch + PR through the
   GitHub App. *Exit*: a PR exists, CI ran on it, and closing it leaves no
   worktree behind (`git worktree prune`).
3. Outbound tunnel + domain. *Exit*: the handshake completes from outside;
   a `kill -9` of the server recovers (< 10 s) through the tunnel's
   health-checked edge.
4. OAuth delegation (RFC 9728) + owner allowlist. *Exit*: a disallowed
   account is refused even with a valid forge token; an allowed one passes.
5. Soak: one week of pilot use with a usage counter (JSONL: tool, ts, ok).
   *Exit*: a hosted assistant answers a knowledge question **citing wiki
   paths**, and a proposed edit arrives as a green PR — merged by automerge
   only if routine.

Keep the server's code **outside the wiki repository** (like the denylist,
it is per-instance configuration, not method), and mirror its README of
operating notes there.
