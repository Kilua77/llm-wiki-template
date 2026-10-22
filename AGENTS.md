# LLM Wiki — agent on-ramp

This repository is a multi-agent knowledge wiki: [Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f), bundles in the [OKF v0.2](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) format.

**Before any read or write: read [CHARTE.md](CHARTE.md) — the single contract.**
The full operating protocol lives in [docs/AGENT-PROTOCOL.md](docs/AGENT-PROTOCOL.md).

**Teach while operating** (protocol §0): you are the user's guide into this system,
especially while the wiki is young — route their intent to the right method, explain
each rule in one sentence as you apply it, show one example before any series, and
never decide structural things for them. Engineering knowledge (Decisions,
Constraints, code references, Word/PDF ingestion, codebase mapping) follows
charter §13 and protocol §4bis.

**Machine prerequisites for the tools** (`tools/`): Python 3 + PyYAML —
`pip3 install -r tools/requirements.txt` (on a system-managed Python, recent Ubuntu
or Homebrew: `python3 -m pip install --user --break-system-packages -r
tools/requirements.txt`) — plus `flock` for `commit.sh`. If `init.sh` has not been
run yet, git hooks are not wired: `git config core.hooksPath .githooks`.

The five capital prohibitions (detail and nuance in the charter):

1. `raw/` is immutable after ingestion.
2. `index.md` files are generated (`tools/gen-index.py`) — never edit them by hand.
3. No new bundle without explicit owner validation (CHARTE §10). Silence means no.
4. No writing into the owner's private systems during a wiki operation.
5. Nothing personal, no instance identifiers, no private URLs, no secrets:
   **all content is deemed public** (CHARTE §2).

Two write channels, one lint (CHARTE §8):

- **Local agent**, with the working repository:
  `tools/commit.sh "wiki(<bundle>): <action> — <object>" "<actor>"`.
- **Remote agent**, with only the git API: branch `agent/<actor>/<slug>` then a pull
  request — **never `main`**, never an `index.md` (CI regenerates them), and the
  `Acting-Agent:` trailer in the commit message.

---

## 📚 Plans ECMTCP
> **Plans détaillés par bundle** :
> - [Bundle Architecture](docs/plans/01-architecture.md) — Architecture globale, composants, plateformes, acronymes
> - [Bundle Components](docs/plans/02-components.md) — Composants individuels, interfaces, bases de données
> - *À venir* : development, best-practices, testing, infrastructure, meetings
> 
> **Rôle des agents** : Suivre strictement les propositions formalisées pour chaque bundle.
