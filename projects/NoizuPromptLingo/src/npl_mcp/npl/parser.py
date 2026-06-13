"""
Expression parser for NPL loading expressions.

Parses expressions like:
- "syntax" -> load entire syntax section
- "syntax#placeholder" -> load specific component
- "syntax#placeholder:+2" -> load with priority filter
- "syntax directives" -> load multiple sections
- "syntax -syntax#literal" -> load with subtraction

Grammar:
    expression      := term (WS term)*
    term            := addition | subtraction
    addition        := section_ref
    subtraction     := '-' section_ref
    section_ref     := section ('#' component)? (':' priority)?
    section         := 'syntax' | 'directives' | 'pumps' | 'prefixes' |
                       'special-sections' | 'declarations' | 'prompt-sections' | 'fences'
    component       := SLUG
    priority        := '+' NUMBER
    SLUG            := [a-z][a-z0-9-]*
    NUMBER          := [0-9]+
    WS              := ' '+
"""

from dataclasses import dataclass
from enum import Enum
from typing import List, Optional
import re

from .exceptions import NPLParseError


class NPLSection(Enum):
    """All loadable NPL sections."""
    SYNTAX = "syntax"
    DECLARATIONS = "declarations"
    DIRECTIVES = "directives"
    PREFIXES = "prefixes"
    PROMPT_SECTIONS = "prompt-sections"
    SPECIAL_SECTIONS = "special-sections"
    PUMPS = "pumps"
    FENCES = "fences"


# Mapping from string names to enum values (supports case-insensitive lookup)
_SECTION_MAP = {s.value.lower(): s for s in NPLSection}
_VALID_SECTIONS = ", ".join(sorted(s.value for s in NPLSection))


@dataclass
class NPLComponent:
    """A parsed NPL component reference."""
    section: NPLSection
    component: Optional[str]  # None means entire section
    priority_max: Optional[int]  # None means all priorities


@dataclass
class NPLExpression:
    """A parsed NPL loading expression."""
    additions: List[NPLComponent]
    subtractions: List[NPLComponent]


# Regex patterns for parsing
_SECTION_REF_PATTERN = re.compile(
    r'^(?P<section>[a-z][a-z0-9-]*)'          # Section name
    r'(?:#(?P<component>[a-z][a-z0-9-]*))?'   # Optional #component
    r'(?::(?P<priority>\+?\-?[0-9]+|\+[a-z]+))?$'  # Optional :priority (capture invalid too)
)


def _parse_section_ref(term: str, is_subtraction: bool = False) -> NPLComponent:
    """Parse a single section reference.

    Args:
        term: The term to parse (e.g., "syntax#placeholder:+2")
        is_subtraction: Whether this is a subtraction term

    Returns:
        NPLComponent with parsed values

    Raises:
        NPLParseError: If term is invalid
    """
    # Check for invalid separators first
    if '@' in term:
        raise NPLParseError(
            f"Invalid expression: '{term}'. Use '#' to separate section from component, "
            f"not '@'. Example: syntax#placeholder"
        )

    # Check for double colons
    if '::' in term:
        raise NPLParseError(
            f"Invalid expression: '{term}'. Found '::' - use single ':' for priority. "
            f"Example: syntax#placeholder:+2"
        )

    match = _SECTION_REF_PATTERN.match(term)
    if not match:
        raise NPLParseError(
            f"Invalid expression: '{term}'. Expected format: section[#component][:+N]. "
            f"Example: syntax#placeholder:+2"
        )

    section_name = match.group('section').lower()
    component = match.group('component')
    priority_str = match.group('priority')

    # Validate section name
    if section_name not in _SECTION_MAP:
        raise NPLParseError(
            f"Unknown section: '{section_name}'. Valid sections: {_VALID_SECTIONS}"
        )

    section = _SECTION_MAP[section_name]

    # Validate and parse priority
    priority_max = None
    if priority_str is not None:
        # Must start with + and be a number
        if not priority_str.startswith('+'):
            raise NPLParseError(
                f"Invalid priority format: '{priority_str}'. Use :+N where N is a non-negative number. "
                f"Example: syntax#placeholder:+2"
            )

        priority_value = priority_str[1:]  # Remove leading +

        # Check if it's a valid number
        if not priority_value.isdigit():
            raise NPLParseError(
                f"Invalid priority format: '+{priority_value}'. Priority must be a non-negative number. "
                f"Example: syntax#placeholder:+2"
            )

        priority_max = int(priority_value)

    return NPLComponent(
        section=section,
        component=component,
        priority_max=priority_max
    )


def parse_expression(expr: str) -> NPLExpression:
    """Parse an NPL loading expression.

    Args:
        expr: The expression to parse

    Returns:
        NPLExpression with additions and subtractions

    Raises:
        NPLParseError: If expression is invalid

    Examples:
        >>> parse_expression("syntax")
        NPLExpression(additions=[NPLComponent(SYNTAX, None, None)], subtractions=[])

        >>> parse_expression("syntax#placeholder:+2")
        NPLExpression(additions=[NPLComponent(SYNTAX, "placeholder", 2)], subtractions=[])

        >>> parse_expression("syntax -syntax#literal")
        NPLExpression(
            additions=[NPLComponent(SYNTAX, None, None)],
            subtractions=[NPLComponent(SYNTAX, "literal", None)]
        )
    """
    # Check for empty or whitespace-only expression
    if not expr or not expr.strip():
        raise NPLParseError("Expression cannot be empty")

    # Split on whitespace
    terms = expr.strip().split()

    additions: List[NPLComponent] = []
    subtractions: List[NPLComponent] = []

    for term in terms:
        if not term:  # Skip empty terms from multiple spaces
            continue

        if term.startswith('-'):
            # Subtraction term
            sub_term = term[1:]  # Remove leading -
            if not sub_term:
                raise NPLParseError(
                    "Invalid subtraction: '-' must be followed by a section reference. "
                    "Example: -syntax#literal"
                )
            component = _parse_section_ref(sub_term, is_subtraction=True)
            subtractions.append(component)
        else:
            # Addition term
            component = _parse_section_ref(term, is_subtraction=False)
            additions.append(component)

    # Must have at least one addition
    if not additions:
        raise NPLParseError(
            "Expression must include at least one section to load. "
            "Cannot only have subtractions."
        )

    return NPLExpression(additions=additions, subtractions=subtractions)
