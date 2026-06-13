#!/usr/bin/env python3
"""
Regenerate docs/user-stories/index.md from YAML frontmatter of every US-*.md.

Groups by wave (from `wave` field), within each wave sorts by (priority, id).
Columns: ID, Title, Category, Priority, Story Points, Primary Persona, Status.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path
from collections import defaultdict

REPO_ROOT = Path(__file__).resolve().parent.parent
STORIES_DIR = REPO_ROOT / "docs" / "user-stories"
INDEX_PATH = STORIES_DIR / "index.md"

FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---", re.DOTALL)


def parse_frontmatter(path: Path) -> dict | None:
    text = path.read_text(encoding="utf-8")
    match = FRONTMATTER_RE.match(text)
    if not match:
        return None

    fields: dict[str, object] = {}
    for line in match.group(1).splitlines():
        if ":" not in line or line.startswith(("  ", "\t", "-")):
            continue
        key, _, value = line.partition(":")
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if value in ("null", "~", ""):
            fields[key] = None
        else:
            fields[key] = value

    # most_impacted_personas is a list — pick the first if present
    block = match.group(1)
    mp = re.search(r"^most_impacted_personas:\s*\n((?:\s+-\s+.*\n?)+)", block, re.MULTILINE)
    if mp:
        first = re.match(r"\s+-\s+(\S+)", mp.group(1))
        if first:
            fields["primary_persona"] = first.group(1)

    return fields


def wave_label(wave: str | None) -> str:
    match wave:
        case "1":
            return "Wave 1 — P0 (MVP-blocking)"
        case "2":
            return "Wave 2 — P1 (Post-MVP polish)"
        case "3":
            return "Wave 3 — P2/P3 (Post-launch growth)"
        case _:
            return f"Wave {wave or 'unassigned'}"


def priority_rank(priority: str | None) -> int:
    return {"P0": 0, "P1": 1, "P2": 2, "P3": 3}.get(priority or "", 9)


def main() -> int:
    files = sorted(STORIES_DIR.glob("US-*.md"))
    if not files:
        print(f"no US-*.md under {STORIES_DIR}", file=sys.stderr)
        return 1

    by_wave: dict[str | None, list[tuple[str, dict, Path]]] = defaultdict(list)

    for p in files:
        fm = parse_frontmatter(p)
        if not fm:
            print(f"skipping {p.name}: no frontmatter", file=sys.stderr)
            continue
        by_wave[fm.get("wave")].append((fm.get("id") or p.stem, fm, p))

    total = sum(len(v) for v in by_wave.values())
    shipped = sum(1 for _, v in by_wave.items() for _, fm, _ in v if fm.get("status") == "shipped")
    in_progress = sum(
        1 for _, v in by_wave.items() for _, fm, _ in v if fm.get("status") == "in-progress"
    )

    lines: list[str] = [
        "# User Stories Index",
        "",
        "Regenerated catalog of all stories. One row per file.",
        "Regenerated from YAML frontmatters on disk by `scripts/regen-user-stories-index.py`.",
        "",
        f"**Progress:** {shipped} shipped / {in_progress} in-progress / {total} total",
        "",
    ]

    for wave in sorted(by_wave.keys(), key=lambda w: (w is None, w or "")):
        rows = sorted(
            by_wave[wave],
            key=lambda t: (priority_rank(t[1].get("priority")), t[0]),
        )
        lines.append(f"## {wave_label(wave)}")
        lines.append("")
        lines.append("| ID | Title | Category | Pri | SP | Primary persona | Status |")
        lines.append("|---|---|---|---|---|---|---|")

        for story_id, fm, path in rows:
            lines.append(
                "| [{id}]({file}) | {title} | {cat} | {pri} | {sp} | {persona} | {status} |".format(
                    id=story_id,
                    file=path.name,
                    title=(fm.get("title") or "").strip().replace("|", "\\|"),
                    cat=fm.get("category") or "—",
                    pri=fm.get("priority") or "—",
                    sp=fm.get("story_points") or "—",
                    persona=fm.get("primary_persona") or "—",
                    status=fm.get("status") or "—",
                )
            )
        lines.append("")

    INDEX_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"wrote {INDEX_PATH} ({total} stories; {shipped} shipped, {in_progress} in-progress)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
