#!/usr/bin/env python3
"""Regenerate every index.md of every bundle from page frontmatter.

Indexes are OKF §10 listings: `* [Title](path) - description`. They are always
generated, never hand-edited (CHARTE.md §4). Deterministic output (sorted by
title) so diffs stay clean.

Usage:
  python3 tools/gen-index.py            # write, print changed paths
  python3 tools/gen-index.py --check    # exit 1 if any index is stale
"""
import sys
from pathlib import Path

import yaml

REPO = Path(__file__).resolve().parent.parent
BUNDLES = REPO / "bundles"
RESERVED = {"index.md", "log.md"}


def frontmatter(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        return {}
    end = text.find("\n---", 4)
    if end == -1:
        return {}
    try:
        data = yaml.safe_load(text[4:end])
    except yaml.YAMLError:
        return {}
    return data if isinstance(data, dict) else {}


def entries(directory: Path, link_prefix: str) -> list[str]:
    out = []
    for f in sorted(directory.glob("*.md")):
        if f.name in RESERVED:
            continue
        fm = frontmatter(f)
        title = fm.get("title") or f.stem
        desc = (fm.get("description") or "").strip()
        line = f"* [{title}]({link_prefix}{f.name})"
        if desc:
            line += f" - {desc}"
        out.append(line)
    return sorted(out, key=str.lower)


def render_subdir_index(subdir: Path) -> str:
    lines = [f"# {subdir.name.capitalize()}", ""]
    lines += entries(subdir, "") or ["*(empty)*"]
    return "\n".join(lines) + "\n"


def render_root_index(bundle: Path) -> str:
    lines = ["---", 'okf_version: "0.2"', "---", "", f"# {bundle.name}", ""]
    root_entries = entries(bundle, "")
    if root_entries:
        lines += root_entries + [""]
    for subdir in sorted(p for p in bundle.iterdir() if p.is_dir()):
        lines += [f"## {subdir.name.capitalize()}", ""]
        lines += entries(subdir, f"{subdir.name}/") or ["*(empty)*"]
        lines += [""]
    return "\n".join(lines).rstrip() + "\n"


def targets() -> dict[Path, str]:
    result = {}
    if not BUNDLES.is_dir():
        return result
    for bundle in sorted(p for p in BUNDLES.iterdir() if p.is_dir()):
        result[bundle / "index.md"] = render_root_index(bundle)
        for subdir in sorted(p for p in bundle.iterdir() if p.is_dir()):
            result[subdir / "index.md"] = render_subdir_index(subdir)
    return result


def main() -> int:
    check = "--check" in sys.argv
    stale = []
    for path, content in targets().items():
        current = path.read_text(encoding="utf-8") if path.exists() else None
        if current != content:
            stale.append(path)
            if not check:
                path.write_text(content, encoding="utf-8")
                print(f"regenerated {path.relative_to(REPO)}")
    if check and stale:
        for p in stale:
            print(f"stale index: {p.relative_to(REPO)} (run tools/gen-index.py)")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
