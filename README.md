# llm-wiki-template

A ready-to-clone template for an **agent-maintained knowledge wiki**:
[Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
implemented as [OKF v0.2](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
bundles in plain Markdown, versioned with Git — with the full operating method:
contract, tooling, lint, CI, and the agent protocol.

**Quickstart**: clone (or click *Use this template*) → `tools/init.sh` → point your
agents at `AGENTS.md`. Full walkthrough: [docs/SETUP.md](docs/SETUP.md).

## What you get

| Piece | Role |
|---|---|
| [CHARTE.md](CHARTE.md) | The single contract every agent follows — mission, publishability rules, bundle inventory, frontmatter spec, six operations, governance |
| [AGENTS.md](AGENTS.md) / [CLAUDE.md](CLAUDE.md) | Thin on-ramps pointing at the contract |
| `tools/` | `commit.sh` (the standard write path: lock → regenerate → lint → commit → rebase-push), `gen-index.py` (indexes are generated, never hand-edited), `lint.py` (OKF conformance, links, publishability scan), `automerge.sh` + `review-prs.sh` (routine PR merging), `init.sh`, `new-bundle.sh` |
| `schemas/` + `templates/` | Machine-readable frontmatter schemas and copyable page skeletons |
| `bundles/example/` | A live, lint-clean format demo (removed by `init.sh`) |
| [docs/](docs/) | [METHOD.md](docs/METHOD.md) (the method and its design decisions) · [SETUP.md](docs/SETUP.md) (local-only or full remote setup) · [AGENT-PROTOCOL.md](docs/AGENT-PROTOCOL.md) (how an agent operates the wiki) · [OPTIONS.md](docs/OPTIONS.md) (optional layers) |

The model in one line: **agents read, write and maintain; the owner curates sources
and arbitrates; two write channels (local commit / remote pull request) share one
lint; nothing structural happens without an explicit owner "yes".**

## Requirements

Python 3 + PyYAML (`pip3 install -r tools/requirements.txt`; on managed Pythons add
`--user --break-system-packages`), `flock` (util-linux), Git. Optional: `gh` CLI
(remote setup), `ripgrep` (search).

## License

- **Code** — everything under `tools/`, `.githooks/`, `.github/`, `schemas/` — is
  licensed under the [MIT License](LICENSE).
- **Documentation and content** — `CHARTE.md`, `README.md`, `AGENTS.md`, `CLAUDE.md`,
  `docs/`, `templates/`, `bundles/example/` — is licensed
  [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

Deriving your own wiki from this template (including keeping or adapting the
charter) is exactly the intended use — keep the attribution notes, make the
result yours.
