#!/usr/bin/env python3
"""
NPL Element Loader and Validator

Load, validate, and extract NPL elements for prompt construction.
Supports selection by code, name, labels, or category.

Usage:
    # Load specific elements by code
    python npl_loader.py --codes HL,ATTN,PH

    # Load by category
    python npl_loader.py --category syntax

    # Load by labels (config preset)
    python npl_loader.py --labels core,common

    # Load by config preset
    python npl_loader.py --config basic

    # Validate all YAML files
    python npl_loader.py --validate

    # List all elements
    python npl_loader.py --list
"""

import argparse
import json
import sys
from pathlib import Path
from typing import Dict, List, Optional, Set, Any
import re

try:
    import yaml
except ImportError:
    print("Error: PyYAML required. Install with: pip install pyyaml")
    sys.exit(1)

try:
    import jsonschema
    HAS_JSONSCHEMA = True
except ImportError:
    HAS_JSONSCHEMA = False


# Default paths
NPL_DIR = Path(__file__).parent.parent
SCHEMA_PATH = NPL_DIR / "schema" / "npl-element.schema.json"

# Category files
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

# Config presets (label combinations)
CONFIG_PRESETS = {
    "minimal": ["core"],
    "basic": ["core", "common"],
    "standard": ["core", "common", "template"],
    "full": ["*"],
    "agents": ["core", "agent", "pump"],
    "docs": ["core", "common", "documentation"],
    "code": ["core", "code", "technical"],
}


class NPLLoader:
    """Load and manage NPL elements from YAML files."""

    def __init__(self, npl_dir: Path = NPL_DIR):
        self.npl_dir = npl_dir
        self.categories: Dict[str, Dict] = {}
        self.elements: Dict[str, Dict] = {}  # code -> element
        self.name_index: Dict[str, str] = {}  # name -> code
        self.label_index: Dict[str, Set[str]] = {}  # label -> set of codes
        self.schema: Optional[Dict] = None

    def load_schema(self) -> bool:
        """Load JSON Schema for validation."""
        if not HAS_JSONSCHEMA:
            print("Warning: jsonschema not installed, validation disabled")
            return False

        schema_path = self.npl_dir / "schema" / "npl-element.schema.json"
        if not schema_path.exists():
            print(f"Warning: Schema not found at {schema_path}")
            return False

        with open(schema_path) as f:
            self.schema = json.load(f)
        return True

    def load_category(self, category: str) -> bool:
        """Load a single category YAML file."""
        if category not in CATEGORY_FILES:
            print(f"Error: Unknown category '{category}'")
            return False

        filepath = self.npl_dir / CATEGORY_FILES[category]
        if not filepath.exists():
            print(f"Error: File not found: {filepath}")
            return False

        with open(filepath) as f:
            data = yaml.safe_load(f)

        self.categories[category] = data

        # Index elements
        for element in data.get("elements", []):
            code = element.get("code")
            name = element.get("name")
            labels = element.get("labels", [])

            if code:
                element["_category"] = category
                self.elements[code] = element

                if name:
                    self.name_index[name] = code

                for label in labels:
                    if label not in self.label_index:
                        self.label_index[label] = set()
                    self.label_index[label].add(code)

        return True

    def load_all(self) -> bool:
        """Load all category files."""
        success = True
        for category in CATEGORY_FILES:
            if not self.load_category(category):
                success = False
        return success

    def validate(self, category: str = None) -> List[str]:
        """Validate YAML files against schema."""
        errors = []

        if not self.schema:
            if not self.load_schema():
                return ["Schema not available for validation"]

        categories = [category] if category else CATEGORY_FILES.keys()

        for cat in categories:
            if cat not in self.categories:
                self.load_category(cat)

            if cat in self.categories:
                try:
                    jsonschema.validate(self.categories[cat], self.schema)
                except jsonschema.ValidationError as e:
                    errors.append(f"{cat}: {e.message}")
                except Exception as e:
                    errors.append(f"{cat}: {str(e)}")

        return errors

    def get_by_codes(self, codes: List[str]) -> List[Dict]:
        """Get elements by their short codes."""
        return [self.elements[c] for c in codes if c in self.elements]

    def get_by_names(self, names: List[str]) -> List[Dict]:
        """Get elements by their names."""
        codes = [self.name_index[n] for n in names if n in self.name_index]
        return self.get_by_codes(codes)

    def get_by_labels(self, labels: List[str], match_all: bool = False) -> List[Dict]:
        """Get elements matching labels."""
        if "*" in labels:
            return list(self.elements.values())

        matching_codes: Set[str] = set()

        for label in labels:
            if label in self.label_index:
                if match_all and matching_codes:
                    matching_codes &= self.label_index[label]
                else:
                    matching_codes |= self.label_index[label]

        return self.get_by_codes(list(matching_codes))

    def get_by_category(self, category: str) -> List[Dict]:
        """Get all elements in a category."""
        if category not in self.categories:
            self.load_category(category)

        return [e for e in self.elements.values() if e.get("_category") == category]

    def get_by_config(self, config: str) -> List[Dict]:
        """Get elements by config preset name."""
        if config not in CONFIG_PRESETS:
            print(f"Error: Unknown config '{config}'")
            return []

        return self.get_by_labels(CONFIG_PRESETS[config])

    def format_category_header(self, category: str) -> str:
        """Format category header for output."""
        if category not in self.categories:
            return ""

        data = self.categories[category]
        header = data.get("header", {})

        lines = []
        title = header.get("title", data.get("category", category).title())
        lines.append(f"# {title}")
        lines.append(data.get("description", ""))

        if purpose := header.get("purpose"):
            lines.append(f"\n## Purpose\n{purpose}")

        if usage := header.get("usage"):
            lines.append(f"\n## Usage\n{usage}")

        if conventions := header.get("conventions"):
            lines.append("\n## Conventions")
            for conv in conventions:
                lines.append(f"- {conv}")

        return "\n".join(lines)

    def format_element(self, element: Dict, verbose: bool = False) -> str:
        """Format a single element for output."""
        lines = []

        name = element.get("name", "unknown")
        code = element.get("code", "???")
        metadata = element.get("metadata", {})
        syntax = element.get("syntax", {})

        # Definition line
        brief = metadata.get("brief", "")
        lines.append(f"**{name}** (`{code}`)")
        lines.append(f": {brief}")

        # Template
        if template := syntax.get("template"):
            template_clean = template.strip()
            if "\n" in template_clean:
                lines.append("```syntax")
                lines.append(template_clean)
                lines.append("```")
            else:
                lines.append(f"  Syntax: `{template_clean}`")

        if verbose:
            # Description
            if desc := metadata.get("description"):
                lines.append(f"\n  {desc}")

            # Template notes
            if notes := syntax.get("template_notes"):
                lines.append(f"\n  Notes: {notes.strip()}")

            # Primary example
            examples = element.get("examples", {})
            if primary := examples.get("primary"):
                ex = primary[0]
                lines.append("\n  Example:")
                lines.append(f"  ```")
                lines.append(f"  {ex.get('input', '').strip()}")
                lines.append(f"  ```")

        return "\n".join(lines)

    def format_output(self, elements: List[Dict],
                      show_header: bool = True,
                      verbose: bool = False) -> str:
        """Format elements for output, grouped by category."""
        # Group by category
        by_category: Dict[str, List[Dict]] = {}
        for elem in elements:
            cat = elem.get("_category", "unknown")
            if cat not in by_category:
                by_category[cat] = []
            by_category[cat].append(elem)

        output_parts = []

        for category, cat_elements in by_category.items():
            if show_header:
                header = self.format_category_header(category)
                if header:
                    output_parts.append(header)
                    output_parts.append("")

            # Sort elements by code length (shorter = more common)
            cat_elements.sort(key=lambda e: len(e.get("code", "ZZZZ")))

            for elem in cat_elements:
                output_parts.append(self.format_element(elem, verbose))
                output_parts.append("")

        return "\n".join(output_parts)

    def list_elements(self) -> str:
        """List all elements in a table format."""
        lines = ["| Code | Name | Category | Brief |", "|------|------|----------|-------|"]

        # Sort by code length then alphabetically
        sorted_elements = sorted(
            self.elements.values(),
            key=lambda e: (len(e.get("code", "")), e.get("code", ""))
        )

        for elem in sorted_elements:
            code = elem.get("code", "")
            name = elem.get("name", "")
            cat = elem.get("_category", "")
            brief = elem.get("metadata", {}).get("brief", "")[:40]
            lines.append(f"| {code} | {name} | {cat} | {brief} |")

        return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="NPL Element Loader and Validator",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s --codes HL,ATTN,PH         Load specific elements by code
  %(prog)s --category syntax           Load all syntax elements
  %(prog)s --labels core,common        Load elements with these labels
  %(prog)s --config basic              Load using config preset
  %(prog)s --validate                  Validate all YAML files
  %(prog)s --list                      List all available elements
        """
    )

    parser.add_argument("--codes", "-c", type=str,
                        help="Comma-separated element codes to load")
    parser.add_argument("--names", "-n", type=str,
                        help="Comma-separated element names to load")
    parser.add_argument("--labels", "-l", type=str,
                        help="Comma-separated labels to match")
    parser.add_argument("--category", "-t", type=str,
                        help="Load all elements from category")
    parser.add_argument("--config", "-g", type=str,
                        help=f"Use config preset: {', '.join(CONFIG_PRESETS.keys())}")
    parser.add_argument("--validate", "-V", action="store_true",
                        help="Validate YAML files against schema")
    parser.add_argument("--list", "-L", action="store_true",
                        help="List all available elements")
    parser.add_argument("--verbose", "-v", action="store_true",
                        help="Include full descriptions and examples")
    parser.add_argument("--no-header", action="store_true",
                        help="Omit category headers")
    parser.add_argument("--dir", "-d", type=str, default=str(NPL_DIR),
                        help="NPL directory path")
    parser.add_argument("--json", "-j", action="store_true",
                        help="Output as JSON instead of formatted text")

    args = parser.parse_args()

    loader = NPLLoader(Path(args.dir))
    loader.load_all()

    # Validation mode
    if args.validate:
        errors = loader.validate()
        if errors:
            print("Validation errors:")
            for err in errors:
                print(f"  - {err}")
            sys.exit(1)
        else:
            print("All files valid!")
            sys.exit(0)

    # List mode
    if args.list:
        print(loader.list_elements())
        sys.exit(0)

    # Load elements based on selection criteria
    elements = []

    if args.codes:
        codes = [c.strip().upper() for c in args.codes.split(",")]
        elements = loader.get_by_codes(codes)

    elif args.names:
        names = [n.strip() for n in args.names.split(",")]
        elements = loader.get_by_names(names)

    elif args.labels:
        labels = [l.strip() for l in args.labels.split(",")]
        elements = loader.get_by_labels(labels)

    elif args.category:
        elements = loader.get_by_category(args.category)

    elif args.config:
        elements = loader.get_by_config(args.config)

    else:
        parser.print_help()
        sys.exit(1)

    if not elements:
        print("No elements found matching criteria")
        sys.exit(1)

    # Output
    if args.json:
        # Clean up internal fields
        clean_elements = []
        for e in elements:
            clean = {k: v for k, v in e.items() if not k.startswith("_")}
            clean_elements.append(clean)
        print(json.dumps(clean_elements, indent=2))
    else:
        output = loader.format_output(
            elements,
            show_header=not args.no_header,
            verbose=args.verbose
        )
        print(output)


if __name__ == "__main__":
    main()
