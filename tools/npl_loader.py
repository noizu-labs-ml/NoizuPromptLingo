#!/usr/bin/env python3
"""NPL Loader - Loads all NPL YAML files and outputs formatted markdown."""

from __future__ import annotations

from pathlib import Path
from typing import Any, Optional, Dict
import re

import yaml


def load_yaml_file(path: Path) -> Optional[dict]:
    """Load a single YAML file."""
    if path.exists():
        with open(path, "r") as f:
            return yaml.safe_load(f)
    return None


def load_all_yaml_files(npl_dir: Path) -> dict[str, dict]:
    """Load all YAML files from the NPL directory recursively."""
    data = {}

    if not npl_dir.exists():
        return data

    for yaml_file in npl_dir.rglob("*.yaml"):
        relative_path = yaml_file.relative_to(npl_dir)
        key = str(relative_path).replace("/", ".").replace(".yaml", "")
        content = load_yaml_file(yaml_file)
        if content:
            data[key] = {
                "path": str(yaml_file),
                "relative_path": str(relative_path),
                "content": content
            }

    return data


def slugify(text: str) -> str:
    """Convert text to a slug."""
    text = text.lower()
    text = re.sub(r'[^\w\s-]', '', text)
    text = re.sub(r'[\s_]+', '-', text)
    return text.strip('-')


def format_component(component: dict, level: int = 3) -> list[str]:
    """Format a single component to markdown lines."""
    lines = []
    heading = "#" * level

    name = component.get("name", "Unknown")
    lines.append(f"{heading} {name}")
    lines.append("")

    # Brief description
    brief = component.get("brief", "")
    if brief:
        lines.append(f"*{brief}*")
        lines.append("")

    # Full description
    description = component.get("description", "").strip()
    if description:
        lines.append(description)
        lines.append("")

    # Syntax
    syntax = component.get("syntax")
    if syntax:
        if isinstance(syntax, str):
            lines.append("**Syntax**:")
            lines.append("```")
            lines.append(syntax.strip())
            lines.append("```")
            lines.append("")
        elif isinstance(syntax, list):
            lines.append("**Syntax**:")
            lines.append("")
            for s in syntax:
                if isinstance(s, dict):
                    syn_name = s.get("name", "")
                    syn_syntax = s.get("syntax", "")
                    syn_desc = s.get("description", "")
                    if syn_name:
                        lines.append(f"- **{syn_name}**: `{syn_syntax}`")
                        if syn_desc:
                            lines.append(f"  - {syn_desc}")
                else:
                    lines.append(f"- `{s}`")
            lines.append("")

    # Labels
    labels = component.get("labels", [])
    if labels:
        lines.append(f"**Labels**: {', '.join(f'`{l}`' for l in labels)}")
        lines.append("")

    # Examples (level 0 and 1 only for brevity)
    examples = component.get("examples", [])
    if examples:
        shown_examples = [e for e in examples if e.get("level", 0) <= 1]
        if shown_examples:
            lines.append("**Examples**:")
            lines.append("")
            for ex in shown_examples[:2]:  # Limit to 2 examples
                ex_name = ex.get("name", "")
                ex_brief = ex.get("brief", "")
                ex_example = ex.get("example", "")
                ex_thread = ex.get("thread", [])

                if ex_name:
                    lines.append(f"*{ex_name}*: {ex_brief}")

                if ex_example:
                    lines.append("```")
                    lines.append(ex_example.strip())
                    lines.append("```")
                elif ex_thread:
                    lines.append("```")
                    for msg in ex_thread:
                        role = msg.get("role", "")
                        message = msg.get("message", "").strip()
                        lines.append(f"[{role}]")
                        lines.append(message)
                    lines.append("```")
                lines.append("")

    return lines


def format_section(name: str, data: dict, level: int = 2) -> list[str]:
    """Format a section (YAML file content) to markdown lines."""
    lines = []
    content = data.get("content", {})
    heading = "#" * level

    section_name = content.get("name", name)
    lines.append(f"{heading} {section_name.title()}")
    lines.append("")

    brief = content.get("brief", "")
    if brief:
        lines.append(f"*{brief}*")
        lines.append("")

    description = content.get("description", "").strip()
    if description:
        lines.append(description)
        lines.append("")

    purpose = content.get("purpose", "").strip()
    if purpose:
        lines.append("**Purpose**:")
        lines.append(purpose)
        lines.append("")

    # Components
    components = content.get("components", [])
    if components:
        for component in components:
            lines.extend(format_component(component, level + 1))

    # Concepts (for npl.yaml)
    concepts = content.get("concepts", [])
    if concepts:
        lines.append(f"{'#' * (level + 1)} Core Concepts")
        lines.append("")
        for concept in concepts:
            concept_name = concept.get("name", "")
            concept_desc = concept.get("description", "").strip().split("\n")[0]
            concept_purpose = concept.get("purpose", "").strip()
            lines.append(f"**{concept_name}**")
            lines.append(f": {concept_desc}")
            if concept_purpose:
                lines.append(f"  *Purpose*: {concept_purpose.split('.')[0]}.")
            lines.append("")

    return lines


def format_npl_output(data: dict[str, dict]) -> str:
    """Format all loaded YAML data into comprehensive markdown output."""
    lines = []

    # Header
    lines.append("\u231cNPL@1.0\u231d")
    lines.append("# Noizu Prompt Lingua (NPL)")
    lines.append("")
    lines.append("A modular, structured framework for advanced prompt engineering and agent simulation with context-aware loading capabilities.")
    lines.append("")
    lines.append("**Convention**: Additional details and deep-dive instructions are available under `${NPL_HOME}/npl/` and can be loaded on an as-needed basis.")
    lines.append("")

    # Define section order
    section_order = [
        "npl",
        "syntax",
        "directives",
        "prefixes",
        "prompt-sections",
        "special-sections",
        "instructional.agent",
    ]

    # Track processed sections
    processed = set()

    # Process in order
    for section_key in section_order:
        if section_key in data:
            lines.extend(format_section(section_key, data[section_key]))
            processed.add(section_key)

    # Process remaining sections
    for key, section_data in sorted(data.items()):
        if key not in processed:
            lines.extend(format_section(key, section_data))

    # Footer
    lines.append("\u231eNPL@1.0\u231f")

    return "\n".join(lines)


def dump_raw_yaml(data: dict[str, dict]) -> str:
    """Dump all YAML contents in a simple format for inspection."""
    lines = []

    for key, section_data in sorted(data.items()):
        lines.append(f"=" * 60)
        lines.append(f"FILE: {section_data.get('relative_path', key)}")
        lines.append(f"=" * 60)

        content = section_data.get("content", {})

        # Basic info
        lines.append(f"Name: {content.get('name', 'N/A')}")
        lines.append(f"Brief: {content.get('brief', 'N/A')}")
        lines.append("")

        # Description
        desc = content.get("description", "").strip()
        if desc:
            lines.append("Description:")
            lines.append(desc)
            lines.append("")

        # Components count
        components = content.get("components", [])
        if components:
            lines.append(f"Components ({len(components)}):")
            for c in components:
                cname = c.get("name", "unnamed")
                cbrief = c.get("brief", "")
                lines.append(f"  - {cname}: {cbrief}")
            lines.append("")

        # Concepts count
        concepts = content.get("concepts", [])
        if concepts:
            lines.append(f"Concepts ({len(concepts)}):")
            for c in concepts:
                cname = c.get("name", "unnamed")
                lines.append(f"  - {cname}")
            lines.append("")

        lines.append("")

    return "\n".join(lines)


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(description="Load and format NPL YAML files")
    parser.add_argument(
        "--path", "-p",
        type=str,
        default=None,
        help="Path to NPL directory (default: ~/.npl/npl or ./npl)"
    )
    parser.add_argument(
        "--raw", "-r",
        action="store_true",
        help="Output raw YAML dump instead of formatted markdown"
    )
    parser.add_argument(
        "--list", "-l",
        action="store_true",
        help="List all YAML files found"
    )

    args = parser.parse_args()

    # Determine NPL directory
    if args.path:
        npl_dir = Path(args.path)
    else:
        # Try ~/.npl/npl first, then ./npl
        home_npl = Path.home() / ".npl" / "npl"
        local_npl = Path.cwd() / "npl"

        if home_npl.exists():
            npl_dir = home_npl
        elif local_npl.exists():
            npl_dir = local_npl
        else:
            print(f"Error: Could not find NPL directory at {home_npl} or {local_npl}")
            print("Use --path to specify the NPL directory location")
            return 1

    if not npl_dir.exists():
        print(f"Error: NPL directory not found at {npl_dir}")
        return 1

    # Load all YAML files
    data = load_all_yaml_files(npl_dir)

    if not data:
        print(f"Error: No YAML files found in {npl_dir}")
        return 1

    if args.list:
        print(f"Found {len(data)} YAML files in {npl_dir}:")
        for key, section_data in sorted(data.items()):
            print(f"  - {section_data.get('relative_path', key)}")
        return 0

    if args.raw:
        output = dump_raw_yaml(data)
    else:
        output = format_npl_output(data)

    print(output)
    return 0


if __name__ == "__main__":
    exit(main())
