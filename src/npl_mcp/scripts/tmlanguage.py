"""Generate a TextMate language grammar (tmLanguage JSON) for NPL.

Reads ``conventions/*.yaml`` and emits a TextMate JSON grammar suitable
for IDE syntax highlighting (VS Code, TextMate, Sublime Text).

Usage::

    uv run npl-tmlanguage                   # writes tools/npl.tmLanguage.json
    uv run npl-tmlanguage --out path.json   # custom destination
    uv run npl-tmlanguage --stdout          # print to stdout
    uv run npl-tmlanguage --check           # exit 1 if regen would change the file

The generated grammar is intentionally hand-scaffolded (the structural
regexes are stable; the data-dependent parts are the pump tag names
extracted from ``pumps.yaml``).  Re-run whenever ``pumps.yaml`` changes.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any, Iterable

import yaml


REPO_ROOT = Path(__file__).resolve().parent.parent.parent.parent
DEFAULT_CONVENTIONS = REPO_ROOT / "conventions"
DEFAULT_OUT = REPO_ROOT / "tools" / "npl.tmLanguage.json"


def _load_yaml(path: Path) -> dict:
    if not path.exists():
        return {}
    with path.open(encoding="utf-8") as fh:
        data = yaml.safe_load(fh)
    return data if isinstance(data, dict) else {}


def _iter_syntax_strings(section: dict) -> Iterable[str]:
    for comp in section.get("components", []) or []:
        if not isinstance(comp, dict):
            continue
        for entry in comp.get("syntax", []) or []:
            if isinstance(entry, dict):
                s = entry.get("syntax", "")
                if isinstance(s, str):
                    yield s


def extract_pump_tags(pumps: dict) -> list[str]:
    """Return sorted list of NPL pump tag names (e.g. ``npl-intent``).

    Parses each pump's syntax string for ``<npl-...>`` or ``<npl-... />``
    patterns and returns their tag names, de-duplicated.
    """
    tags: set[str] = set()
    for s in _iter_syntax_strings(pumps):
        for tag in re.findall(r"<(npl-[a-z0-9-]+)", s):
            tags.add(tag)
    return sorted(tags)


def build_grammar(conventions_dir: Path) -> dict[str, Any]:
    """Build a tmLanguage grammar dict from a conventions directory.

    Structurally the grammar has:
      * ``framework-markers`` — ``⌜NPL@X.Y⌝`` / ``⌞NPL@X.Y⌟`` sentinels
      * ``agent-markers``     — ``⌜name|...⌝`` / ``⌞name⌟`` sentinels
      * ``pumps``             — ``<npl-*>`` XML-like tags (slug list from pumps.yaml)
      * ``directives``        — ``⟪emoji: ...⟫`` bracket markers
      * ``prefixes``          — ``emoji➤`` line-prefix markers
      * ``placeholders``      — ``{term}`` substitution markers
      * ``qualifiers``        — ``|<...>`` modifiers
      * ``in-fill``           — ``[...:count| qualifier]`` generation markers
      * ``attention``         — ``🎯`` attention lines
      * ``highlights``        — ``!<...>`` emphasis
    """
    pumps = _load_yaml(conventions_dir / "pumps.yaml")
    pump_tags = extract_pump_tags(pumps)

    # Pump tag alternation: tag names are constrained to ``npl-[a-z0-9-]+`` by
    # the extractor, so no escaping is needed. Fall back to a permissive regex
    # when the conventions directory has no pumps.
    pump_alt = "|".join(pump_tags) if pump_tags else r"npl-[a-z0-9-]+"

    grammar: dict[str, Any] = {
        "$schema": "https://raw.githubusercontent.com/martinring/tmlanguage/master/tmlanguage.json",
        "name": "NPL (Noizu Prompt Lingua)",
        "scopeName": "source.npl",
        "fileTypes": ["npl", "npl.md"],
        "patterns": [
            {"include": "#framework-markers"},
            {"include": "#agent-markers"},
            {"include": "#pumps"},
            {"include": "#directives"},
            {"include": "#prefixes"},
            {"include": "#placeholders"},
            {"include": "#in-fill"},
            {"include": "#qualifiers"},
            {"include": "#highlights"},
            {"include": "#attention"},
        ],
        "repository": {
            "framework-markers": {
                "patterns": [
                    {
                        "name": "keyword.control.framework.npl",
                        "match": r"⌜(?:extend:)?NPL@[0-9]+(?:\.[0-9]+)*(?:\|[^⌝]*)?⌝",
                    },
                    {
                        "name": "keyword.control.framework.npl",
                        "match": r"⌞(?:extend:)?NPL@[0-9]+(?:\.[0-9]+)*⌟",
                    },
                ]
            },
            "agent-markers": {
                "patterns": [
                    {
                        "name": "entity.name.class.agent.npl",
                        "match": r"⌜[^⌝\n]+⌝",
                    },
                    {
                        "name": "entity.name.class.agent.npl",
                        "match": r"⌞[^⌟\n]+⌟",
                    },
                ]
            },
            "pumps": {
                "patterns": [
                    {
                        "name": "meta.tag.pump.block.npl",
                        "begin": fr"<({pump_alt})(?:\s+[^>]*)?>",
                        "end":   fr"</({pump_alt})\s*>",
                        "contentName": "meta.embedded.pump.npl",
                        "beginCaptures": {"1": {"name": "entity.name.tag.pump.npl"}},
                        "endCaptures":   {"1": {"name": "entity.name.tag.pump.npl"}},
                    },
                    {
                        "name": "meta.tag.pump.self-closing.npl",
                        "match": fr"<({pump_alt})(?:\s+[^/>]*)?/>",
                        "captures": {"1": {"name": "entity.name.tag.pump.npl"}},
                    },
                ]
            },
            "directives": {
                "patterns": [
                    {
                        "name": "support.function.directive.npl",
                        "match": r"⟪[^⟫\n]*⟫",
                    }
                ]
            },
            "prefixes": {
                "patterns": [
                    {
                        "name": "keyword.operator.prefix.npl",
                        "match": r"[^\s]+?➤",
                    }
                ]
            },
            "placeholders": {
                "patterns": [
                    {
                        "name": "variable.other.placeholder.npl",
                        "match": r"\{[A-Za-z_][A-Za-z0-9_.\-\s]*(?::[^}\n]+)?\}",
                    }
                ]
            },
            "in-fill": {
                "patterns": [
                    {
                        "name": "variable.other.infill.npl",
                        "match": r"\[\.\.\.(?::[^\]\n]+)?(?:\|[^\]\n]*)?\]",
                    }
                ]
            },
            "qualifiers": {
                "patterns": [
                    {
                        "name": "storage.modifier.qualifier.npl",
                        "match": r"\|<[^>\n]+>",
                    }
                ]
            },
            "highlights": {
                "patterns": [
                    {
                        "name": "markup.bold.highlight.npl",
                        "match": r"!<[^>\n]+>",
                    }
                ]
            },
            "attention": {
                "patterns": [
                    {
                        "name": "markup.bold.attention.npl",
                        "match": r"🎯[^\n]*",
                    }
                ]
            },
        },
    }
    return grammar


def render_grammar(conventions_dir: Path, indent: int = 2) -> str:
    """Build the grammar and render as a JSON string (trailing newline)."""
    grammar = build_grammar(conventions_dir)
    return json.dumps(grammar, indent=indent, ensure_ascii=False) + "\n"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="npl-tmlanguage",
        description="Generate a TextMate language grammar JSON for NPL from conventions/*.yaml.",
    )
    parser.add_argument(
        "--conventions",
        type=Path,
        default=DEFAULT_CONVENTIONS,
        help="Directory containing convention YAMLs (default: repo/conventions).",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=DEFAULT_OUT,
        help="Output JSON path (default: repo/tools/npl.tmLanguage.json).",
    )
    parser.add_argument(
        "--stdout",
        action="store_true",
        help="Print to stdout instead of writing to disk.",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Exit 1 if regenerated output would differ from the file on disk.",
    )
    parser.add_argument(
        "--indent",
        type=int,
        default=2,
        help="JSON indent width (default: 2).",
    )
    args = parser.parse_args(argv)

    rendered = render_grammar(args.conventions, indent=args.indent)

    if args.stdout:
        sys.stdout.write(rendered)
        return 0

    if args.check:
        if not args.out.exists():
            print(f"{args.out} does not exist — regeneration required.", file=sys.stderr)
            return 1
        existing = args.out.read_text(encoding="utf-8")
        if existing == rendered:
            print(f"{args.out} is up to date.")
            return 0
        print(
            f"{args.out} is stale — regenerate with `uv run npl-tmlanguage`.",
            file=sys.stderr,
        )
        return 1

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(rendered, encoding="utf-8")
    print(f"Wrote {len(rendered)} chars to {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
