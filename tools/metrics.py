#!/usr/bin/env python3
"""Weekly metrics block from log.md telemetry (CHARTE §8.F).

Prints a ready-to-paste markdown block on stdout — the automatable part of
the weekly lint's closing metrics. Everything is computed from the bundles'
log.md files and page frontmatters with the standard library only: no
network, no PyYAML required, no writes. The exit code is always 0: a
threshold reached is a signal for the owner (CHARTE §11), never a failure.

Usage:
  python3 tools/metrics.py [--since YYYY-MM-DD] [--weeks N] [--all]

Signals:
  - actions per bundle in the window (by log action, vocabulary of CHARTE §9)
  - the window's Query-miss entries (the corpus gaps)
  - pages per bundle against PAGES_PER_BUNDLE_THRESHOLD (env-overridable)
  - dead weight: pages never cited in any log entry
  - contested pages, aged by their first log mention, escalated past
    CONTESTED_ESCALATE_DAYS
  - routing_review pages with ages and candidate clusters
"""
import os
import re
import sys
from datetime import date, timedelta
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
BUNDLES = REPO / "bundles"

PAGES_PER_BUNDLE_THRESHOLD = int(os.environ.get("WIKI_PAGES_THRESHOLD", "100"))
CONTESTED_ESCALATE_DAYS = 60

SECTION_DATE_RE = re.compile(r"^## (\d{4}-\d{2}-\d{2})\s*$", re.M)
ENTRY_RE = re.compile(r"^\* \*\*([A-Za-z-]+)\*\*")
LINK_RE = re.compile(r"\]\(([^)]+)\)")


def parse_args(argv):
    since = None
    if "--all" in argv:
        return date(1970, 1, 1)
    if "--since" in argv:
        i = argv.index("--since")
        try:
            since = date.fromisoformat(argv[i + 1])
        except (IndexError, ValueError):
            sys.exit("metrics.py: --since expects YYYY-MM-DD")
    if "--weeks" in argv:
        i = argv.index("--weeks")
        try:
            weeks = int(argv[i + 1])
        except (IndexError, ValueError):
            sys.exit("metrics.py: --weeks expects an integer")
        since = date.today() - timedelta(weeks=weeks)
    return since if since else date.today() - timedelta(days=7)


def iter_bundles():
    if not BUNDLES.is_dir():
        return
    for b in sorted(p for p in BUNDLES.iterdir() if p.is_dir()):
        yield b


def log_entries(bundle: Path):
    """Yield (entry_date, action, line) from a bundle's log.md, all dates."""
    log = bundle / "log.md"
    if not log.is_file():
        return
    current = None
    for line in log.read_text(encoding="utf-8").splitlines():
        m = SECTION_DATE_RE.match(line)
        if m:
            current = date.fromisoformat(m.group(1))
            continue
        e = ENTRY_RE.match(line)
        if e and current is not None:
            yield current, e.group(1), line


def frontmatter_of(path: Path) -> str:
    try:
        text = path.read_text(encoding="utf-8")
    except OSError:
        return ""
    if not text.startswith("---\n"):
        return ""
    end = text.find("\n---", 4)
    return text[4:end] if end != -1 else ""


def first_mention(bundle: Path, basename: str):
    """First log date whose text mentions the page's basename (documented
    heuristic for aging contested pages: the field itself carries no date)."""
    dates = [d for d, _a, line in log_entries(bundle) if basename in line]
    return min(dates) if dates else None


def main() -> int:
    since = parse_args(sys.argv[1:])
    today = date.today()

    actions: dict = {}
    misses = []
    deadweight = []
    pages_per_bundle = []
    contested = []
    routing = []

    for bundle in iter_bundles():
        name = bundle.name
        cited = set()

        for d, action, line in log_entries(bundle):
            for m in LINK_RE.finditer(line):
                cited.add(Path(m.group(1)).name)
            if d >= since:
                actions.setdefault(name, {}).setdefault(action, 0)
                actions[name][action] += 1
                if action == "Query-miss":
                    term = re.search(r'"([^"]+)"', line)
                    actor = re.search(r"\(([^)]+)\)\s*$", line)
                    misses.append(
                        f'- "{term.group(1) if term else line}" — {name}'
                        f" ({actor.group(1) if actor else '?'})")

        # pages = every .md except generated/reserved files
        pages = [f for f in bundle.rglob("*.md")
                 if f.name not in ("index.md", "log.md")]
        pages_per_bundle.append((name, len(pages)))
        deadweight += [str(f.relative_to(REPO)) for f in pages
                       if f.name not in cited]

        for f in pages:
            fm = frontmatter_of(f)
            if re.search(r"^contested:", fm, re.M):
                first = first_mention(bundle, f.name)
                age = (today - first).days if first else None
                contested.append((str(f.relative_to(REPO)), age))
            m = re.search(r"^routing_review:.*?since:\s*(\d{4}-\d{2}-\d{2})", fm, re.M)
            if m:
                cand = re.search(r"candidate:\s*([\w-]+)", fm)
                routing.append((str(f.relative_to(REPO)),
                                (today - date.fromisoformat(m.group(1))).days,
                                cand.group(1) if cand else None))

    print(f"## Metrics ({since} → {today})")
    print()

    print("### Actions per bundle")
    if actions:
        vocab = ["Creation", "Ingest", "Update", "Merge", "Deprecation", "Lint", "Query-miss"]
        print("| Bundle | " + " | ".join(vocab) + " |")
        print("|---" * (len(vocab) + 1) + "|")
        for name, counts in sorted(actions.items()):
            row = [str(counts.get(v, "")) for v in vocab]
            print(f"| {name} | " + " | ".join(row) + " |")
    else:
        print("*(no action logged in the window)*")
    print()

    print("### Query-miss (the gaps)")
    print("\n".join(misses) if misses else "*(none — no failed search this window)*")
    print()

    print(f"### Pages per bundle (threshold: {PAGES_PER_BUNDLE_THRESHOLD})")
    for name, n in sorted(pages_per_bundle, key=lambda t: -t[1]):
        flag = " ⚠ threshold reached — owner decides the search tier-up (CHARTE §11)" \
               if n >= PAGES_PER_BUNDLE_THRESHOLD else ""
        print(f"- {name}: {n}{flag}")
    print()

    print("### Dead weight (never cited in any log entry)")
    print("\n".join(f"- {p}" for p in sorted(deadweight))
          if deadweight else "*(none)*")
    print()

    print("### Contested")
    for p, age in sorted(contested):
        if age is None:
            print(f"- {p} (no log mention yet)")
        else:
            suffix = f" — **escalate: {age}d > {CONTESTED_ESCALATE_DAYS}d, name it in the report**" \
                     if age > CONTESTED_ESCALATE_DAYS else ""
            print(f"- {p} ({age}d since first log mention){suffix}")
    if not contested:
        print("*(none)*")
    print()

    print("### Routing review")
    clusters: dict = {}
    for p, age, cand in sorted(routing):
        print(f"- {p} — {age}d" + (f", candidate `{cand}`" if cand else ""))
        if cand:
            clusters.setdefault(cand, []).append(p)
    for cand, ps in sorted(clusters.items()):
        if len(ps) >= 3:
            print(f"- ⚠ {len(ps)} pages point at `{cand}` — threshold reached, "
                  f"open a proposal (CHARTE §10): {', '.join(ps)}")
    if not routing:
        print("*(none)*")

    return 0


if __name__ == "__main__":
    sys.exit(main())
