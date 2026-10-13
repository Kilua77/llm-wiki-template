# llm-wiki-template

A ready-to-clone template for an **agent-maintained knowledge wiki**:
[Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
implemented as [OKF v0.2](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
bundles in plain Markdown, versioned with Git — with the full operating method:
contract, tooling, lint, CI, and the agent protocol.

**Quickstart**: clone (or click *Use this template*) → `tools/init.sh` → point your
agents at `AGENTS.md`. Full walkthrough: [docs/SETUP.md](docs/SETUP.md).

**Your first session**: point an agent at `AGENTS.md` and simply tell it what you
want — a question answered, a page added, a Word/PDF spec ingested, your codebase
mapped, a new subject started. The agent is built to **guide** you: it proposes the
right method (and explains the rule it applies, in one sentence), shows one example
before any series, and drafts anything structural as a proposal **you** approve.
You do not need to have read the contract to start; you will learn it as you go.

## What you get

| Piece | Role |
|---|---|
| [CHARTE.md](CHARTE.md) | The single contract every agent follows — mission, releasability rules, bundle inventory, frontmatter spec, six operations, governance, and the §13 engineering conventions (Decisions, Constraints, code references, document ingestion) |
| [AGENTS.md](AGENTS.md) / [CLAUDE.md](CLAUDE.md) | Thin on-ramps pointing at the contract |
| `tools/` | `commit.sh` (the standard write path: lock → regenerate → lint → commit → rebase-push), `gen-index.py` (indexes are generated, never hand-edited), `lint.py` (OKF conformance, links, releasability scan, engineering fields), `ingest-doc.sh` (Word/PDF ingestion with binary hash + out-of-repo reference), `metrics.py` (weekly telemetry block), `automerge.sh` + `review-prs.sh` (routine PR merging), `init.sh`, `new-bundle.sh` |
| `schemas/` + `templates/` | Machine-readable frontmatter schemas and copyable page skeletons |
| `bundles/example/` | A live, lint-clean demo of every convention (removed by `init.sh`) |
| `tests/` | The versioned test suite — `bash tests/run-tests.sh`, hermetic (no network, no remote) |
| [docs/](docs/) | [METHOD.md](docs/METHOD.md) (the method and its design decisions) · [ARCHITECTURE.md](docs/ARCHITECTURE.md) (the assembled system) · [IMPLEMENTATION-GUIDE.md](docs/IMPLEMENTATION-GUIDE.md) (phased build manual with exit criteria) · [SETUP.md](docs/SETUP.md) (local-only or full remote setup) · [AGENT-PROTOCOL.md](docs/AGENT-PROTOCOL.md) (how an agent operates the wiki, guidance posture included) · [OPTIONS.md](docs/OPTIONS.md) (optional layers, incl. the [MCP access layer](docs/guides/MCP-SERVER.md)) |

The model in one line: **agents read, write and maintain; the owner curates sources
and arbitrates; two write channels (local commit / remote pull request) share one
lint; nothing structural happens without an explicit owner "yes".**

## Requirements

Python 3 + PyYAML (`pip3 install -r tools/requirements.txt`; on managed Pythons add
`--user --break-system-packages`), `flock` (util-linux), Git. Optional: `gh` CLI
(remote setup), `ripgrep` (search), `pandoc` + `poppler-utils` (Word/PDF ingestion —
`--from-converted` works without them), `jsonschema` (schema pre-flight).

## License

- **Code** — everything under `tools/`, `.githooks/`, `.github/`, `schemas/` — is
  licensed under the [MIT License](LICENSE).
- **Documentation and content** — `CHARTE.md`, `README.md`, `AGENTS.md`, `CLAUDE.md`,
  `docs/`, `templates/`, `bundles/example/` — is licensed
  [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

Deriving your own wiki from this template (including keeping or adapting the
charter) is exactly the intended use — keep the attribution notes, make the
result yours.
