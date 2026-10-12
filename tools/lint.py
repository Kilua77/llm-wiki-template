#!/usr/bin/env python3
"""Structural lint for the wiki (CHARTE.md §8.F).

Checks, in order:
  1. bundle inventory — every dir under bundles/ must be listed in CHARTE.md
     (between the inventory markers); `_`-prefixed dirs are local sandboxes
     (warning locally, error with --ci)
  2. OKF conformance + Charte requirements on every non-reserved .md,
     including the engineering fields of CHARTE §13.2 (code_refs, applies_to,
     source_file/conversion)
  3. reserved files: generated index.md untouched rules, log.md shape
  4. internal markdown links resolve
  5. publishability scan (generic secret/PII patterns; plus the private
     denylist at ~/.config/wiki-lint/denylist.txt, or $WIKI_DENYLIST,
     unless --ci)
  6. index freshness (delegates to gen-index --check)
  7. orphan pages (warning only)
  8. document re-ingestion — two raws of one bundle never share a
     source_file.sha256 (CHARTE §13.2)
  9. `contested` pages listed (CHARTE §8.F rotation pickup)

Exit code: 1 if any error, 0 otherwise (warnings never fail the run).

The denylist location can be overridden with the WIKI_DENYLIST environment
variable (useful to run several wikis on one machine, or to point tests at a
scratch file). The denylist itself always stays OUT of the repository.
"""
import os
import re
import subprocess
import sys
from datetime import date, datetime
from pathlib import Path

import yaml

REPO = Path(__file__).resolve().parent.parent
BUNDLES = REPO / "bundles"
PROPOSALS = REPO / "proposals"
CHARTE = REPO / "CHARTE.md"
DENYLIST = Path(os.environ.get("WIKI_DENYLIST",
                               Path.home() / ".config" / "wiki-lint" / "denylist.txt"))
RESERVED = {"index.md", "log.md"}
STATUSES = {"draft", "stable", "deprecated"}
REQUIRED = ["type", "title", "description", "tags", "status", "generated", "sources"]

SHA40_RE = re.compile(r"^[0-9a-f]{40}$")
LINES_RE = re.compile(r"^\d+(-\d+)?$")

CI = "--ci" in sys.argv
errors: list[str] = []
warnings: list[str] = []
notices: list[str] = []
ROUTING_REVIEW: list[tuple[Path, dict]] = []


def err(msg: str) -> None:
    errors.append(msg)


def warn(msg: str) -> None:
    warnings.append(msg)


def rel(p: Path) -> str:
    return str(p.relative_to(REPO))


def is_plain_date(v) -> bool:
    """A YYYY-MM-DD date — and nothing else: datetime is a subclass of date
    in Python, so an `isinstance(v, date)` check silently admits datetimes
    (which then crash date comparisons downstream instead of failing cleanly)."""
    return isinstance(v, date) and not isinstance(v, datetime)


def split_frontmatter(path: Path):
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        return None, text
    end = text.find("\n---", 4)
    if end == -1:
        return None, text
    try:
        fm = yaml.safe_load(text[4:end])
    except yaml.YAMLError as e:
        err(f"{rel(path)}: unparsable YAML frontmatter ({e})")
        return None, text
    return (fm if isinstance(fm, dict) else None), text[end + 4 :]


def inventory_names() -> set[str]:
    text = CHARTE.read_text(encoding="utf-8")
    m = re.search(r"<!-- inventory:start -->(.*?)<!-- inventory:end -->", text, re.S)
    if not m:
        err("CHARTE.md: inventory markers not found")
        return set()
    names = set()
    for line in m.group(1).splitlines():
        line = line.strip()
        if not line.startswith("|") or set(line) <= {"|", "-", " "}:
            continue
        first = line.split("|")[1].strip().strip("`")
        if first and first.lower() != "bundle":
            names.add(first)
    return names


def check_bundles_registered():
    if not BUNDLES.is_dir():
        return
    listed = inventory_names()
    for d in sorted(p for p in BUNDLES.iterdir() if p.is_dir()):
        if d.name in listed:
            continue
        if d.name.startswith("_"):
            (err if CI else warn)(
                f"bundles/{d.name}: sandbox bundle (allowed locally, forbidden in CI)"
            )
        else:
            err(f"bundles/{d.name}: not in CHARTE.md inventory — unapproved bundle (CHARTE §10)")


def check_doc(path: Path):
    fm, _body = split_frontmatter(path)
    if fm is None:
        err(f"{rel(path)}: missing frontmatter (OKF requires `type`)")
        return
    if not fm.get("type"):
        err(f"{rel(path)}: empty or missing `type`")
    for field in REQUIRED:
        if field not in fm or fm[field] in (None, "", []):
            err(f"{rel(path)}: missing required field `{field}` (CHARTE §5)")
    status = fm.get("status")
    if status is not None and status not in STATUSES:
        err(f"{rel(path)}: invalid status `{status}` (draft|stable|deprecated)")
    sa = fm.get("stale_after")
    if sa is not None and not is_plain_date(sa):
        err(f"{rel(path)}: stale_after must be a YYYY-MM-DD date")
    gen = fm.get("generated")
    if gen is not None and (not isinstance(gen, dict) or not gen.get("by")):
        err(f"{rel(path)}: generated must be a mapping with `by`")
    src = fm.get("sources")
    if isinstance(src, list):
        for i, s in enumerate(src):
            if not isinstance(s, dict) or not s.get("resource"):
                err(f"{rel(path)}: sources[{i}] missing `resource`")
    ver = fm.get("verified")
    if ver is not None:
        items = ver if isinstance(ver, list) else [ver]
        for v in items:
            if not isinstance(v, dict) or not v.get("by"):
                err(f"{rel(path)}: verified entries need `by`")
    rr = fm.get("routing_review")
    if rr is not None:
        if not isinstance(rr, dict) or not rr.get("reason") or not is_plain_date(rr.get("since")):
            err(f"{rel(path)}: routing_review needs `reason` and `since: YYYY-MM-DD` (CHARTE §5)")
        else:
            ROUTING_REVIEW.append((path, rr))
    check_engineering_fields(path, fm)


def bundle_root_of(path: Path):
    """The direct child of bundles/ containing this page (None outside bundles/)."""
    for p in path.parents:
        if p.parent == BUNDLES:
            return p
    return None


def check_engineering_fields(path: Path, fm: dict) -> None:
    """CHARTE §13.2 — shapes and couplings of the engineering fields.

    No network: the lint checks that a commit sha is well-formed, not that it
    exists — fabrication is guarded by convention (§13.6), not by HTTP.
    """
    ptype = fm.get("type")
    is_raw = ptype == "Raw Source"

    cr = fm.get("code_refs")
    if cr is not None:
        if not isinstance(cr, list) or not cr:
            err(f"{rel(path)}: code_refs must be a non-empty list (CHARTE §13.2)")
            cr = []
        for i, ref in enumerate(cr):
            if not isinstance(ref, dict):
                err(f"{rel(path)}: code_refs[{i}] must be a mapping (CHARTE §13.2)")
                continue
            if not str(ref.get("repo") or "").strip():
                err(f"{rel(path)}: code_refs[{i}] missing `repo` — public URL or bare slug (CHARTE §13.2)")
            if not SHA40_RE.fullmatch(str(ref.get("commit") or "")):
                err(f"{rel(path)}: code_refs[{i}].commit must be a FULL 40-hex sha — never a branch (CHARTE §13.2)")
            rp = str(ref.get("path") or "")
            if not rp or rp.startswith("/") or ".." in rp.split("/"):
                err(f"{rel(path)}: code_refs[{i}].path must be relative, no leading slash, no `..` (CHARTE §13.2)")
            lines = ref.get("lines")
            if lines is not None:
                ls = str(lines)
                if not LINES_RE.fullmatch(ls):
                    err(f"{rel(path)}: code_refs[{i}].lines must be `start` or `start-end` (CHARTE §13.2)")
                else:
                    first, _, last = ls.partition("-")
                    if last and int(first) > int(last):
                        err(f"{rel(path)}: code_refs[{i}].lines start > end (CHARTE §13.2)")
        if fm.get("stale_after") is None:
            err(f"{rel(path)}: code_refs require stale_after — a pinned commit IS a version (CHARTE §13.2)")
    if ptype == "Decision" and not cr:
        err(f"{rel(path)}: a Decision must carry code_refs — cite the code it concerns (CHARTE §13.2)")

    at = fm.get("applies_to")
    if at is not None:
        if not isinstance(at, list) or not at or not all(isinstance(x, str) and x for x in at):
            err(f"{rel(path)}: applies_to must be a non-empty list of paths (CHARTE §13.2)")
        else:
            root = bundle_root_of(path)
            for target in at:
                clean = str(target).split("#")[0]
                if root is not None and clean.startswith("/"):
                    resolved = root / clean.lstrip("/")
                else:
                    resolved = path.parent / clean
                if not resolved.resolve().exists():
                    err(f"{rel(path)}: applies_to a page that does not exist -> {target} (CHARTE §13.2)")

    sf, cv = fm.get("source_file"), fm.get("conversion")
    if (sf is None) != (cv is None):
        err(f"{rel(path)}: source_file and conversion are inseparable — both or neither (CHARTE §13.2)")
    if sf is not None:
        if not is_raw:
            err(f"{rel(path)}: source_file/conversion are reserved to raws ingested from binary documents (CHARTE §13.2)")
        if not isinstance(sf, dict):
            err(f"{rel(path)}: source_file must be a mapping (CHARTE §13.2)")
        else:
            if not str(sf.get("name") or "").strip():
                err(f"{rel(path)}: source_file missing `name` (CHARTE §13.2)")
            if not re.fullmatch(r"[0-9a-f]{64}", str(sf.get("sha256") or "")):
                err(f"{rel(path)}: source_file.sha256 must be 64 hex chars (CHARTE §13.2)")
            if not str(sf.get("stored_at") or "").strip():
                err(f"{rel(path)}: source_file missing `stored_at` — public URL or storage:<slug> (CHARTE §13.2)")
            sb = sf.get("size_bytes")
            if sb is not None and not isinstance(sb, int):
                err(f"{rel(path)}: source_file.size_bytes must be an integer (CHARTE §13.2)")
        if (not isinstance(cv, dict) or not str(cv.get("tool") or "").strip()
                or not is_plain_date(cv.get("date"))):
            err(f"{rel(path)}: conversion needs `tool` and `date: YYYY-MM-DD` (CHARTE §13.2)")


def check_source_file_dedup() -> None:
    """CHARTE §13.2 — one binary document, one raw per bundle: the same
    source_file.sha256 in two raws of a bundle is a re-ingestion."""
    if not BUNDLES.is_dir():
        return
    for bundle in sorted(p for p in BUNDLES.iterdir() if p.is_dir()):
        rawdir = bundle / "raw"
        if not rawdir.is_dir():
            continue
        seen: dict[str, Path] = {}
        for f in sorted(rawdir.glob("*.md")):
            fm, _ = split_frontmatter(f)
            sf = (fm or {}).get("source_file")
            if not isinstance(sf, dict):
                continue
            h = str(sf.get("sha256") or "")
            if not h:
                continue
            if h in seen:
                err(f"{rel(f)}: document re-ingestion — source_file.sha256 already "
                    f"captured by {rel(seen[h])} (CHARTE §13.2)")
            else:
                seen[h] = f


def report_contested(docs: dict) -> None:
    """List `contested` pages (CHARTE §5) for the weekly rotation (§8.F).
    The lint lists; aging and escalation belong to the weekly metrics."""
    items = [(path, fm.get("contested")) for path, (fm, _) in docs.items()
             if fm.get("contested")]
    if not items:
        return
    notices.append(f"{len(items)} contested page(s) awaiting rotation (CHARTE §8.F):")
    for path, c in sorted(items, key=lambda t: str(t[0])):
        why = f" — {c}" if isinstance(c, str) and c else ""
        notices.append(f"  {rel(path)}{why}")


def check_reserved(path: Path, bundle_root: Path):
    fm, _ = split_frontmatter(path)
    if path.name == "log.md":
        if fm is not None:
            err(f"{rel(path)}: log.md must not have frontmatter")
        if path.parent != bundle_root:
            warn(f"{rel(path)}: log.md outside bundle root")
    elif path.name == "index.md":
        if path.parent == bundle_root:
            if fm is None or set(fm) != {"okf_version"}:
                err(f"{rel(path)}: root index frontmatter must be exactly okf_version")
        elif fm is not None:
            err(f"{rel(path)}: sub-directory index.md must not have frontmatter")


LINK_RE = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")


def check_links(path: Path, bundle_root: Path, body: str):
    for target in LINK_RE.findall(body):
        if target.startswith(("http://", "https://", "mailto:", "#", "observation:")):
            continue
        clean = target.split("#")[0]
        if not clean.endswith(".md"):
            continue
        resolved = (bundle_root / clean.lstrip("/")) if clean.startswith("/") else (path.parent / clean)
        if not resolved.resolve().exists():
            err(f"{rel(path)}: broken link -> {target}")


GENERIC_PATTERNS = [
    (re.compile(r"[\w.+-]+@(?!example\.(?:com|org|net))[\w-]+\.[a-z]{2,}", re.I), "email address"),
    (re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----"), "private key"),
    (re.compile(r"\b(?:AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_\w{20,}|sk-[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]{10,})\b"), "API token"),
    (re.compile(r"(?i)\bbearer\s+[a-z0-9_\-.=]{25,}"), "bearer token"),
    (re.compile(r"https?://(?:app\.notion\.com|www\.notion\.so|notion\.so|[\w-]+\.notion\.site)/\S+"), "private Notion URL"),
]
IPV4 = re.compile(r"\b(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\b")


def public_ip(m: re.Match) -> bool:
    a, b = int(m.group(1)), int(m.group(2))
    if any(int(g) > 255 for g in m.groups()):
        return False
    if a in (0, 10, 127) or (a, b) == (192, 168) or (a == 172 and 16 <= b <= 31):
        return False
    if (a, b) == (255, 255) or m.group(0) in {"8.8.8.8", "1.1.1.1"}:
        return False
    return True


def load_denylist() -> list[str]:
    if CI:
        return []
    if not DENYLIST.exists():
        warn(
            f"private denylist missing ({DENYLIST}) — publishability scan runs "
            "WITHOUT private motifs (CHARTE §2); refuse to commit until restored"
        )
        return []
    return [
        line.strip().lower()
        for line in DENYLIST.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.startswith("#")
    ]


def check_publishability():
    deny = load_denylist()
    scopes = [d for d in (BUNDLES, PROPOSALS) if d.is_dir()]
    for scope in scopes:
        for f in sorted(scope.rglob("*")):
            if not f.is_file() or f.name == ".gitkeep":
                continue
            try:
                text = f.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                err(f"{rel(f)}: binary file in a bundle (CHARTE §4: markdown only)")
                continue
            for n, line in enumerate(text.splitlines(), 1):
                for pat, label in GENERIC_PATTERNS:
                    if pat.search(line):
                        err(f"{rel(f)}:{n}: publishability — {label}")
                for m in IPV4.finditer(line):
                    if public_ip(m):
                        err(f"{rel(f)}:{n}: publishability — public IP address")
                low = line.lower()
                for term in deny:
                    if term in low:
                        err(f"{rel(f)}:{n}: publishability — denylisted term")


def check_indexes():
    r = subprocess.run(
        [sys.executable, str(REPO / "tools" / "gen-index.py"), "--check"],
        capture_output=True, text=True,
    )
    if r.returncode != 0:
        for line in r.stdout.strip().splitlines():
            err(line)


def check_orphans():
    if not BUNDLES.is_dir():
        return
    for bundle in (p for p in BUNDLES.iterdir() if p.is_dir()):
        docs, bodies = [], []
        for f in bundle.rglob("*.md"):
            if f.name in RESERVED or f.parent.name == "raw":
                continue
            _, body = split_frontmatter(f)
            bodies.append((f, body))
            if f.parent.name in {"concepts", "entities", "syntheses"}:
                docs.append(f)
        for doc in docs:
            needle = doc.name
            if not any(needle in body for f, body in bodies if f != doc):
                warn(f"{rel(doc)}: orphan (no inbound links) — link it or flag it")


def _to_dt(value):
    """Normalise a frontmatter timestamp (datetime, date or ISO string) for comparison."""
    if isinstance(value, datetime):
        return value.replace(tzinfo=None)
    if isinstance(value, date):
        return datetime(value.year, value.month, value.day)
    if isinstance(value, str):
        try:
            return datetime.fromisoformat(value.replace("Z", "+00:00")).replace(tzinfo=None)
        except ValueError:
            return None
    return None


def check_syntheses(docs: dict) -> None:
    """CHARTE §6.5: derived pages must declare their inputs, stay ahead of them,
    never derive from another synthesis, and never be cited as a source."""
    def is_synth(fm, path: Path) -> bool:
        return (fm or {}).get("type") == "Synthesis" or path.parent.name == "syntheses"

    for path, (fm, body) in sorted(docs.items(), key=lambda t: str(t[0])):
        # No page may cite a synthesis as a source (CHARTE §6.5 — cuts the derivation loop).
        for s in (fm.get("sources") or []) if isinstance(fm, dict) else []:
            res = str((s or {}).get("resource") or "")
            if "syntheses/" in res and res.endswith(".md"):
                err(f"{rel(path)}: sources cite a synthesis ({res}) — a synthesis is never a source (CHARTE §6.5)")
        if not is_synth(fm, path):
            continue

        covers = fm.get("covers")
        if not isinstance(covers, list) or not covers:
            err(f"{rel(path)}: synthesis must declare `covers` — the pages it derives from (CHARTE §6.5)")
            continue
        if (fm.get("status") == "stable"
                and not any(str((v or {}).get("by", "")).startswith("human:")
                            for v in (fm["verified"] if isinstance(fm.get("verified"), list) else [fm.get("verified")])
                            if isinstance(v, dict))):
            err(f"{rel(path)}: synthesis is `stable` without a human `verified` entry — stays `draft` until reviewed (CHARTE §6.5)")

        bundle_root = path.parent.parent
        own_at = _to_dt((fm.get("generated") or {}).get("at"))
        for target in covers:
            clean = str(target).split("#")[0]
            resolved = (bundle_root / clean.lstrip("/")) if clean.startswith("/") else (path.parent / clean)
            resolved = resolved.resolve()
            if not resolved.exists():
                err(f"{rel(path)}: covers a page that does not exist -> {target}")
                continue
            cfm, _ = docs.get(resolved, (None, ""))
            if cfm is None:
                continue
            if is_synth(cfm, resolved):
                err(f"{rel(path)}: covers another synthesis ({target}) — no synthesis of synthesis (CHARTE §6.5)")
            if Path(clean).name not in body:
                err(f"{rel(path)}: covers {target} without linking it in the body (CHARTE §6.5)")
            src_at = _to_dt((cfm.get("generated") or {}).get("at"))
            if own_at and src_at and src_at > own_at:
                err(
                    f"{rel(path)}: behind its input {rel(resolved)} "
                    f"(input {src_at.date()} > synthesis {own_at.date()}) — reread and update (CHARTE §6.5)"
                )


SYNTH_THEME_MIN = 5      # pages sharing a tag before a synthesis is worth proposing
SYNTH_COVERAGE_WARN = 3  # uncovered same-theme pages before a synthesis is called adrift
SYNTH_TAG_TOO_BROAD = 0.6  # a tag on this share of a bundle is the bundle, not a theme
KNOWLEDGE_DIRS = {"concepts", "entities"}


def report_synthesis_coverage(docs: dict) -> None:
    """CHARTE §6.5/§8.F — computed diff between what a synthesis lists and what exists.

    Two signals, both informational: a synthesis drifting from its theme (pages
    sharing its tags that it does not cover), and a theme ripe enough to deserve
    one. Neither creates anything: proposing stays a human decision.
    """
    def tags_of(fm) -> set:
        t = fm.get("tags")
        return {str(x) for x in t} if isinstance(t, list) else set()

    by_bundle: dict[str, dict] = {}
    for path, (fm, body) in docs.items():
        try:
            bundle = path.relative_to(BUNDLES).parts[0]
        except ValueError:
            continue
        by_bundle.setdefault(bundle, {})[path] = (fm, body)

    for bundle, pages in sorted(by_bundle.items()):
        root = BUNDLES / bundle
        synths = {p: fm for p, (fm, _) in pages.items()
                  if fm.get("type") == "Synthesis" or p.parent.name == "syntheses"}
        knowledge = {p: fm for p, (fm, _) in pages.items()
                     if p.parent.name in KNOWLEDGE_DIRS}

        # 1. Coverage gap — same-theme pages a synthesis does not cover.
        for spath, sfm in sorted(synths.items(), key=lambda t: str(t[0])):
            covered = set()
            for c in (sfm.get("covers") or []):
                clean = str(c).split("#")[0]
                target = (root / clean.lstrip("/")) if clean.startswith("/") else (spath.parent / clean)
                covered.add(target.resolve())
            stags = tags_of(sfm)
            missing = sorted(rel(p) for p, fm in knowledge.items()
                             if p not in covered and stags & tags_of(fm))
            if missing:
                notices.append(
                    f"{rel(spath)}: {len(missing)} same-theme page(s) not covered: {', '.join(missing)}"
                )
            if len(missing) >= SYNTH_COVERAGE_WARN:
                warn(
                    f"{rel(spath)}: synthesis adrift from its theme — {len(missing)} uncovered pages "
                    f"(CHARTE §6.5: reread and extend `covers`, or narrow the synthesis)"
                )

        # 2. Theme maturity — a tag cluster big enough to deserve a synthesis.
        counts: dict[str, list] = {}
        for p, fm in knowledge.items():
            for t in tags_of(fm):
                counts.setdefault(t, []).append(rel(p))
        covered_tags = set()
        for sfm in synths.values():
            covered_tags |= tags_of(sfm)
        for tag, members in sorted(counts.items()):
            # A tag carried by most of the bundle describes the bundle, not a theme:
            # the generated index already covers that ground (CHARTE §6.5).
            if knowledge and len(members) / len(knowledge) >= SYNTH_TAG_TOO_BROAD:
                continue
            if len(members) >= SYNTH_THEME_MIN and tag not in covered_tags:
                notices.append(
                    f"bundles/{bundle}: tag `{tag}` has {len(members)} pages and no synthesis — "
                    f"a synthesis MAY be proposed to the owner (CHARTE §6.5, never created unasked)"
                )


FRESHNESS_LAG_DAYS = 90  # page trailing its freshest source by more than this is stale
LONG_PAGE_LINES = 200    # page longer than this is a split candidate


def report_freshness(docs: dict) -> None:
    """CHARTE §8.F — computed freshness signals, informational only (never errors).

    1. `stale_after` in the past — the page declares its own expiry;
    2. freshness lag — `generated.at` more than FRESHNESS_LAG_DAYS behind the
       freshest `last_modified` of its own sources, computed from frontmatter
       alone, no network;
    3. pages longer than LONG_PAGE_LINES — split candidates.
    """
    today = date.today()
    for path, (fm, body) in sorted(docs.items(), key=lambda t: str(t[0])):
        if (fm.get("status") or "") == "deprecated":
            continue
        sa = fm.get("stale_after")
        if is_plain_date(sa) and sa < today:
            warn(
                f"{rel(path)}: stale_after {sa} passed — re-verify and refresh, or deprecate (CHARTE §8.F)"
            )
        own = _to_dt((fm.get("generated") or {}).get("at"))
        if own:
            src_dates = [
                d for d in (
                    _to_dt(s.get("last_modified"))
                    for s in (fm.get("sources") or [])
                    if isinstance(s, dict)
                ) if d
            ]
            if src_dates and (max(src_dates) - own).days > FRESHNESS_LAG_DAYS:
                warn(
                    f"{rel(path)}: freshness lag — generated {own.date()} is "
                    f">{FRESHNESS_LAG_DAYS}d behind its freshest source "
                    f"{max(src_dates).date()} (CHARTE §8.F)"
                )
        n = len(body.splitlines())
        if n > LONG_PAGE_LINES:
            warn(f"{rel(path)}: {n} lines — split candidate (CHARTE §8.F)")


def report_routing_review() -> None:
    """List pages parked in a best-fit bundle (CHARTE §7.3) so they get rejudged."""
    if not ROUTING_REVIEW:
        return
    today = date.today()
    by_candidate: dict[str, list[str]] = {}
    notices.append(f"{len(ROUTING_REVIEW)} page(s) awaiting routing review (CHARTE §7.3):")
    for path, rr in sorted(ROUTING_REVIEW, key=lambda t: str(t[0])):
        cand = str(rr.get("candidate") or "").strip()
        age = (today - rr["since"]).days
        notices.append(
            f"  {rel(path)} — since {rr['since']} ({age}d)"
            + (f", candidate `{cand}`" if cand else ", no candidate yet")
        )
        if cand:
            by_candidate.setdefault(cand, []).append(rel(path))
    for cand, pages in sorted(by_candidate.items()):
        if len(pages) >= 3:
            warn(
                f"routing: {len(pages)} pages point at bundle `{cand}` — "
                f"threshold reached, open a proposal (CHARTE §10): {', '.join(pages)}"
            )


def main() -> int:
    check_bundles_registered()
    docs: dict = {}
    if BUNDLES.is_dir():
        for bundle in sorted(p for p in BUNDLES.iterdir() if p.is_dir()):
            for f in sorted(bundle.rglob("*.md")):
                if f.name in RESERVED:
                    check_reserved(f, bundle)
                else:
                    check_doc(f)
                if f.parent.name != "raw":
                    fm, body = split_frontmatter(f)
                    check_links(f, bundle, body)
                    if f.name not in RESERVED and isinstance(fm, dict):
                        docs[f.resolve()] = (fm, body)
    check_syntheses(docs)
    report_synthesis_coverage(docs)
    if PROPOSALS.is_dir():
        for f in sorted(PROPOSALS.glob("*.md")):
            fm, _ = split_frontmatter(f)
            if fm is None or not fm.get("type"):
                err(f"{rel(f)}: proposal needs frontmatter with `type`")
    check_publishability()
    check_indexes()
    check_orphans()
    check_source_file_dedup()
    report_contested(docs)
    report_routing_review()
    report_freshness(docs)

    for n in notices:
        print(f"NOTE  {n}")
    for w in warnings:
        print(f"WARN  {w}")
    for e in errors:
        print(f"ERROR {e}")
    print(f"lint: {len(errors)} error(s), {len(warnings)} warning(s)"
          + (" [ci mode]" if CI else ""))
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
