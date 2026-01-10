#!/usr/bin/env python3
"""
Add short codes to NPL YAML element files.
Run this once to update all files with element codes.
"""

import yaml
from pathlib import Path

NPL_DIR = Path(__file__).parent.parent

# Element codes mapping: name -> code
ELEMENT_CODES = {
    # Syntax (already done, but included for reference)
    "highlight": "HL",
    "attention": "ATN",
    "placeholder": "PH",
    "in-fill": "FIL",
    "qualifier": "QL",
    "agent-alias": "ALIAS",
    "validation": "VAL",
    "inference": "INF",
    "literal-output": "LIT",
    "omission": "OMT",
    "direct-message": "DM",
    "math-and-logic": "MATH",
    "example-conversation": "CONV",

    # Fences
    "example": "EX",
    "note": "NOTE",
    "diagram": "DIAG",
    "syntax": "SYN",
    "format": "FMT",
    "template": "TPL",
    "alg": "ALG",
    "alg-pseudo": "ALGP",
    "artifact": "ART",
    "mermaid": "MMD",
    "graphviz": "GVZ",
    "plantuml": "UML",

    # Directives
    "table-directive": "TBL",
    "temporal-directive": "TIME",
    "template-directive": "TPLD",
    "interactive-directive": "INTR",
    "identifier-directive": "ID",
    "explanatory-directive": "EXPL",
    "section-reference-directive": "REF",
    "explicit-instruction-directive": "CMD",

    # Prefixes
    "word-riddle": "RIDL",
    "speech": "SPCH",
    "data-analysis": "DATA",
    "sentiment-analysis": "SENT",
    "audio-description": "AUD",
    "visual-observation": "VIS",
    "conversational": "CHAT",
    "writing": "WRITE",
    "classification": "TAG",
    "image-generation": "IMG",
    "question": "ASK",
    "code": "CODE",
    "document": "DOC",
    "experimental": "TEST",
    "translation": "I18N",

    # Pumps
    "intent": "INT",
    "cot": "COT",
    "reflection": "REFL",
    "tangent": "TAN",
    "panel": "PNL",
    "critique": "CRIT",
    "rubric": "RUB",
    "mood": "MOOD",

    # Special Sections
    "npl-declaration": "NPL",
    "agent": "AGT",
    "npl-extension": "EXT",
    "runtime-flags": "FLAG",
    "secure-prompt": "SEC",
    "named-template": "NTPL",

    # Formatting
    "input-syntax": "ISYN",
    "output-syntax": "OSYN",
    "input-example": "IEX",
    "output-example": "OEX",
    "format-template": "FTPL",

    # Instructing
    "handlebars": "HB",
    "alg-speak": "ALGS",
    "annotation": "ANNO",
    "symbolic-logic": "LOGIC",
    "formal-proof": "PROOF",
    "second-order": "META",
}

# Headers for each category
HEADERS = {
    "fences": {
        "title": "NPL Fence Blocks",
        "purpose": "Code fence types provide semantic containers for structured content. Use fences to delimit examples, notes, diagrams, algorithms, and other block-level content with clear boundaries and optional type information.",
        "usage": "Wrap content in triple backticks with fence type. Use N+1 backticks for nested fences."
    },
    "directives": {
        "title": "NPL Directives",
        "purpose": "Emoji-prefixed directives provide fine-grained control over agent behavior and output formatting. Each directive uses a specific emoji to signal its function.",
        "usage": "Use directive syntax ⟪emoji: content⟫ to invoke specific behaviors."
    },
    "prefixes": {
        "title": "NPL Response Prefixes",
        "purpose": "Response mode indicators shape how output is generated. Prefixes signal the type of processing or output format expected.",
        "usage": "Prefix instructions with emoji➤ pattern to activate specific response modes."
    },
    "pumps": {
        "title": "NPL Intuition Pumps",
        "purpose": "Structured reasoning techniques that guide problem-solving and response construction. Pumps are implemented as XHTML tags or named fences.",
        "usage": "Include pump blocks in prompts to activate specific reasoning patterns."
    },
    "special-sections": {
        "title": "NPL Special Sections",
        "purpose": "Structured sections with semantic boundaries for agent definitions, runtime configuration, and protected instructions.",
        "usage": "Use corner brackets ⌜...⌝ and ⌞...⌟ to delimit special sections."
    },
    "formatting": {
        "title": "NPL Formatting Patterns",
        "purpose": "Input/output format specifications define expected data structures and templates for consistent formatting.",
        "usage": "Use format fences to specify exact input/output structures."
    },
    "instructing": {
        "title": "NPL Instructing Patterns",
        "purpose": "Specialized syntax patterns for directing agent behavior through algorithms, control structures, and meta-level instructions.",
        "usage": "Use instructing patterns for complex procedural guidance."
    }
}

# Config labels to add based on element type
CONFIG_LABELS = {
    # Basic config - most common elements
    "basic": ["HL", "ATN", "PH", "FIL", "QL", "VAL", "INF", "EX", "FMT", "NOTE"],
    # Minimal config - absolute essentials
    "minimal": ["HL", "ATN", "PH", "FIL"],
    # Agents config
    "agents": ["AGT", "ALIAS", "DM", "FLAG", "INT", "COT", "REFL", "PNL"],
    # Docs config
    "docs": ["HL", "VAL", "OMT", "CONV", "EX", "NOTE", "DIAG", "SYN", "FMT"],
    # Technical/code config
    "technical": ["CODE", "MATH", "ALG", "ALGP", "HB", "LOGIC"],
}


def add_codes_to_file(filepath: Path) -> bool:
    """Add codes to elements in a YAML file."""
    if not filepath.exists():
        print(f"File not found: {filepath}")
        return False

    with open(filepath, 'r') as f:
        content = f.read()

    data = yaml.safe_load(content)

    if not data or 'elements' not in data:
        print(f"No elements in {filepath}")
        return False

    modified = False

    # Add header if missing
    category = data.get('category', '')
    if category in HEADERS and 'header' not in data:
        data['header'] = HEADERS[category]
        modified = True

    # Add codes to elements
    for element in data['elements']:
        name = element.get('name', '')
        if name in ELEMENT_CODES:
            code = ELEMENT_CODES[name]
            if 'code' not in element:
                element['code'] = code
                modified = True

            # Add config labels
            labels = element.get('labels', [])
            for config, codes in CONFIG_LABELS.items():
                if code in codes and config not in labels:
                    labels.append(config)
                    modified = True
            element['labels'] = labels

    if modified:
        # Custom YAML dumper to preserve formatting
        with open(filepath, 'w') as f:
            yaml.dump(data, f, default_flow_style=False, allow_unicode=True, sort_keys=False, width=100)
        print(f"Updated: {filepath}")
        return True
    else:
        print(f"No changes: {filepath}")
        return False


def main():
    files = [
        "fences.yaml",
        "directives.yaml",
        "prefixes.yaml",
        "pumps.yaml",
        "special-sections.yaml",
        "formatting.yaml",
        "instructing.yaml",
    ]

    for filename in files:
        filepath = NPL_DIR / filename
        add_codes_to_file(filepath)

    print("\nDone! Codes and headers added to all files.")
    print("\nCode summary:")
    for name, code in sorted(ELEMENT_CODES.items(), key=lambda x: len(x[1])):
        print(f"  {code:6} -> {name}")


if __name__ == "__main__":
    main()
