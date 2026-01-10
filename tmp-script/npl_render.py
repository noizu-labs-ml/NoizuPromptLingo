#!/usr/bin/env python3
"""
NPL Element Renderer - outputs elements as markdown

Usage:
    ./npl_render.py c HL,ATN,PH              # By codes
    ./npl_render.py c HL ATN PH              # Space separated
    ./npl_render.py cl agents                # By label group
    ./npl_render.py cl basic,docs            # Multiple labels (intersection)

    -v mention|normal|full                   # Verbosity level
"""

import argparse
import yaml
from pathlib import Path
from typing import Any

NPL_DIR = Path(__file__).parent.parent / "npl-v2"

CATEGORY_FILES = {
    "syntax": "syntax.yaml",
    "fences": "fences.yaml",
    "directives": "directives.yaml",
    "prefixes": "prefixes.yaml",
    "pumps": "pumps.yaml",
    "special-sections": "special-sections.yaml",
    "formatting": "formatting.yaml",
    "instructing": "instructing.yaml",
}

VERBOSITY = {"mention": 0, "normal": 1, "full": 2}


def load_all_elements() -> tuple[dict[str, Any], dict[str, dict]]:
    """
    Load all elements from YAML files.
    Returns: (elements_by_code, category_headers)
    """
    elements = {}
    headers = {}

    for category, filename in CATEGORY_FILES.items():
        filepath = NPL_DIR / filename
        if not filepath.exists():
            continue

        with open(filepath, 'r', encoding='utf-8') as f:
            data = yaml.safe_load(f)

        if not data:
            continue

        # Store category header
        if 'header' in data:
            headers[category] = data['header']

        # Index elements by code
        for el in data.get('elements', []):
            code = el.get('code')
            if code:
                el['_category'] = category
                elements[code.upper()] = el

    return elements, headers


def select_by_codes(elements: dict, codes: list[str]) -> list[dict]:
    """Select elements by their short codes."""
    selected = []
    for code in codes:
        code_upper = code.upper()
        if code_upper in elements:
            selected.append(elements[code_upper])
        else:
            print(f"# Warning: Unknown code '{code}'", flush=True)
    return selected


def select_by_labels(elements: dict, labels: list[str]) -> list[dict]:
    """Select elements that have ALL specified labels (intersection)."""
    selected = []
    labels_set = set(l.lower() for l in labels)

    for el in elements.values():
        el_labels = set(l.lower() for l in el.get('labels', []))
        if labels_set.issubset(el_labels):
            selected.append(el)

    # Sort by category then code for consistent output
    return sorted(selected, key=lambda e: (e.get('_category', ''), e.get('code', '')))


def render_category_header(category: str, header: dict) -> str:
    """Render category header as markdown."""
    lines = []
    title = header.get('title', category.title())
    lines.append(f"# {title}")
    lines.append("")

    if 'purpose' in header:
        purpose = header['purpose'].strip()
        lines.append(purpose)
        lines.append("")

    if 'usage' in header:
        usage = header['usage'].strip()
        lines.append(f"**Usage:** {usage}")
        lines.append("")

    lines.append("---")
    lines.append("")
    return "\n".join(lines)


def render_element(el: dict, verbosity: int, include_header: bool = False,
                   category_header: dict | None = None) -> str:
    """Render single element to markdown."""
    lines = []

    # Category header (if first element in category)
    if include_header and category_header:
        lines.append(render_category_header(el.get('_category', ''), category_header))

    code = el.get('code', '??')
    name = el.get('name', 'unknown')
    meta = el.get('metadata', {})
    syntax = el.get('syntax', {})
    examples = el.get('examples', {})

    # Element heading
    lines.append(f"## `{code}` {name}")
    lines.append("")

    # Brief (always shown)
    brief = meta.get('brief', '')
    if brief:
        lines.append(brief)
        lines.append("")

    # mention mode stops here
    if verbosity == 0:
        # Just show syntax template
        template = syntax.get('template', '')
        if template:
            lines.append("```")
            lines.append(template.strip())
            lines.append("```")
            lines.append("")
        return "\n".join(lines)

    # normal+ : description, purpose, usage
    desc = meta.get('description', '')
    if desc:
        lines.append(desc)
        lines.append("")

    purpose = meta.get('purpose', '')
    if purpose:
        lines.append(f"**Purpose:** {purpose}")
        lines.append("")

    usage = meta.get('usage', '')
    if usage:
        lines.append(f"**Usage:** {usage}")
        lines.append("")

    # Syntax section
    template = syntax.get('template', '')
    if template:
        lines.append("### Syntax")
        lines.append("```")
        lines.append(template.strip())
        lines.append("```")

        notes = syntax.get('template_notes', '')
        if notes:
            lines.append(notes.strip())
        lines.append("")

    # Features (full mode only or if has features)
    features = syntax.get('features', [])
    if verbosity >= 2 and features:
        lines.append("#### Features")
        for feat in features:
            fname = feat.get('name', '')
            ftemplate = feat.get('template', '')
            fnotes = feat.get('template_notes', '')
            lines.append(f"- **{fname}**: `{ftemplate.strip()}`")
            if fnotes:
                lines.append(f"  {fnotes.strip()}")
        lines.append("")

    # Primary examples (normal+)
    primary = examples.get('primary', [])
    if primary:
        lines.append("### Examples")
        lines.append("")
        for ex in primary:
            ex_brief = ex.get('brief', ex.get('name', ''))
            ex_input = ex.get('input', '')
            ex_explanation = ex.get('explanation', '')

            lines.append(f"**{ex_brief}**")
            if ex_input:
                lines.append("```")
                lines.append(ex_input.strip())
                lines.append("```")
            if ex_explanation:
                lines.append(ex_explanation)
            lines.append("")

    # Supplemental examples (full only)
    if verbosity >= 2:
        supplemental = examples.get('supplemental', [])
        if supplemental:
            lines.append("#### Supplemental Examples")
            lines.append("")
            for ex in supplemental:
                ex_brief = ex.get('brief', ex.get('name', ''))
                ex_input = ex.get('input', '')
                ex_explanation = ex.get('explanation', '')

                lines.append(f"**{ex_brief}**")
                if ex_input:
                    lines.append("```")
                    lines.append(ex_input.strip())
                    lines.append("```")
                if ex_explanation:
                    lines.append(ex_explanation)
                lines.append("")

    # Extended section (full only)
    if verbosity >= 2:
        extended = el.get('extended', {})
        if extended:
            lines.append("### Extended")
            lines.append("```yaml")
            lines.append(yaml.dump(extended, default_flow_style=False).strip())
            lines.append("```")
            lines.append("")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="NPL Element Renderer - output elements as markdown"
    )
    parser.add_argument(
        "mode",
        choices=["c", "cl"],
        help="c=by code, cl=by label"
    )
    parser.add_argument(
        "selector",
        nargs="+",
        help="Codes or labels to select"
    )
    parser.add_argument(
        "-v", "--verbosity",
        choices=["mention", "normal", "full"],
        default="normal",
        help="Output verbosity (default: normal)"
    )
    parser.add_argument(
        "--no-headers",
        action="store_true",
        help="Skip category headers"
    )

    args = parser.parse_args()

    elements, headers = load_all_elements()

    if args.mode == "c":
        # Parse codes (handle comma and space separation)
        codes = []
        for s in args.selector:
            codes.extend(c.strip() for c in s.split(",") if c.strip())
        selected = select_by_codes(elements, codes)
    else:  # cl
        labels = []
        for s in args.selector:
            labels.extend(l.strip() for l in s.split(",") if l.strip())
        selected = select_by_labels(elements, labels)

    if not selected:
        print("# No elements found")
        return

    verbosity = VERBOSITY[args.verbosity]

    # Group by category for headers
    current_category = None
    for el in selected:
        cat = el.get('_category', '')
        include_header = not args.no_headers and cat != current_category
        cat_header = headers.get(cat) if include_header else None

        print(render_element(el, verbosity, include_header, cat_header))
        current_category = cat


if __name__ == "__main__":
    main()
