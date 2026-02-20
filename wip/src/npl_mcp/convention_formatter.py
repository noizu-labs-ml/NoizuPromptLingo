import yaml
from pathlib import Path
from typing import Any
from dataclasses import dataclass, field
import re
import itertools


@dataclass
class ExampleCoverage:
    """Track which components an example covers."""
    example: dict[str, Any]
    covered_components: set[str]


@dataclass
class ComponentSpec:
    """Specification for which components to include from a convention and at what priority levels.

    Args:
        spec: Fully-qualified component spec string. Supports:
              "syntax:*"                  → all components from syntax
              "pumps:npl-intent,npl-poa"  → specific components from pumps
              "syntax"                    → shorthand for syntax:*
              "*"                         → all conventions, all components
        component_priority: Maximum component priority to include (default 0).
        example_priority: Maximum example priority to include (default 0).
    """
    spec: str
    component_priority: int = 0
    example_priority: int = 0


def _heading(level: int, offset: int = 0) -> str:
    """Generate a markdown heading prefix at the given level plus offset."""
    return "#" * (level + offset)


class ConventionFormatter:
    """Formatter for NPL convention specifications."""

    def __init__(self, conventions_dir: str | Path | None = None):
        """
        Initialize the formatter with a conventions directory.

        Args:
            conventions_dir: Path to directory containing convention YAML files.
                           Defaults to 'conventions' relative to project root.
        """
        if conventions_dir is None:
            project_root = Path(__file__).parent.parent.parent
            conventions_dir = project_root / "conventions"

        self.conventions_dir = Path(conventions_dir)

    def _count_backticks(self, text: str) -> int:
        """
        Count longest sequence of backticks at start of any line.

        Args:
            text: The text to scan for backtick sequences.

        Returns:
            The maximum number of consecutive backticks found at start of any line.
        """
        max_backticks = 0
        for line in text.split('\n'):
            match = re.match(r'^(`+)', line)
            if match:
                backtick_count = len(match.group(1))
                if backtick_count > max_backticks:
                    max_backticks = backtick_count
        return max_backticks

    def _format_snippet_xml(self, content: str) -> str:
        """Format snippet using XML tags."""
        return f"<npl-example>\n<snippet>\n{content}\n</snippet>\n</npl-example>"

    def _format_snippet_fence(self, content: str) -> str:
        """Format snippet using fence blocks with appropriate backticks."""
        backticks_needed = max([self._count_backticks(content) + 2, 3])
        fence = '`' * backticks_needed
        result = f"{fence}example\nsnippet: |\n"
        for line in content.split('\n'):
            result += f"  {line}\n"
        result += fence
        return result

    def _format_thread_xml(self, messages: list[dict[str, str]]) -> str:
        """Format thread using XML tags."""
        result = "<npl-example>\n<thread>\n"
        for msg in messages:
            role = msg.get("role", "")
            message = msg.get("message", "").strip()
            result += f"<msg role=\"{role}\">\n{message}\n</msg>\n"
        result += "</thread>\n</npl-example>"
        return result

    def _format_thread_fence(self, messages: list[dict[str, str]]) -> str:
        """Format thread using fence blocks with appropriate backticks."""
        # Combine all messages to find the max backtick count
        all_text = ""
        for msg in messages:
            all_text += msg.get("message", "") + "\n"

        backticks_needed = max(self._count_backticks(all_text) + 2, 3)
        fence = '`' * backticks_needed

        result = f"{fence}example\nthread\n"
        for msg in messages:
            role = msg.get("role", "")
            message = msg.get("message", "").strip()
            result += f"  role: {role}\n  message: |\n"
            for line in message.split('\n'):
                result += f"    {line}\n"
        result += fence
        return result

    def _get_example_coverage(self, example: dict[str, Any], cat_components: list[dict[str, Any]]) -> set[str]:
        """Determine which components an example covers."""
        covers = example.get("covers", [])
        # Use explicit 'covers' field
        if covers:
            cat_component_names = {c.get("name") for c in cat_components}
            return set(covers) & cat_component_names

        # Fallback: try to map labels to components via syntax matching
        labels = example.get("labels", [])
        cat_component_names = {c.get("name") for c in cat_components}
        covered = set()

        for label in labels:
            for comp in cat_components:
                comp_syntaxes = comp.get("syntax", [])
                for syn in comp_syntaxes:
                    if syn.get("syntax") == label:
                        covered.add(comp.get("name"))
                        break  # Found this label, move to next label
        return covered

    def _find_minimal_example_set(
        self,
        cat: dict[str, Any],
        cat_components: list[dict[str, Any]],
        example_priority: int = 0,
        known_components: set[str] | None = None
    ) -> list[dict[str, Any]]:
        """Find minimal set of examples covering as many components as possible.

        First checks category-level examples, then falls back to component examples.
        Filters all examples by example_priority. When known_components is provided,
        penalizes examples that reference unknown components (not in the known set).

        Args:
            cat: Category dict from the YAML.
            cat_components: Components being rendered in this category.
            example_priority: Maximum example priority to include.
            known_components: Convention-wide set of all component names the agent knows
                            about (being rendered + already rendered). None means all known.
        """
        cat_component_names = {c.get("name") for c in cat_components}

        def _unknown_count(ex: dict[str, Any]) -> int:
            """Count how many components an example references that aren't known."""
            if known_components is None:
                return 0
            full_covers = set(ex.get("covers", []))
            return len(full_covers - known_components)

        # First, check for category-level examples
        cat_examples = cat.get("examples", [])
        if cat_examples:
            # Calculate coverage for category examples, filtered by priority
            example_coverage: list[tuple[dict[str, Any], set[str]]] = []
            for ex in cat_examples:
                if ex.get("priority", 0) > example_priority:
                    continue
                covered = self._get_example_coverage(ex, cat_components)
                if covered:
                    example_coverage.append((ex, covered))

            if example_coverage:
                # Sort by coverage (desc), then unknown refs (asc)
                example_coverage.sort(key=lambda x: (-len(x[1]), _unknown_count(x[0])))

                # Greedy set cover
                covered_so_far: set[str] = set()
                selected: list[dict[str, Any]] = []

                for ex, covered in example_coverage:
                    newly_covered = covered - covered_so_far
                    if newly_covered:
                        selected.append(ex)
                        covered_so_far |= covered
                        if covered_so_far >= cat_component_names or len(selected) >= 3:
                            break

                return selected

        # Fallback: collect examples from individual components
        all_examples: list[dict[str, Any]] = []
        for comp in cat_components:
            for ex in comp.get("examples", []):
                if ex.get("priority", 0) <= example_priority:
                    all_examples.append(ex)

        # Prefer thread examples
        thread_examples = [ex for ex in all_examples if ex.get("thread")]
        if thread_examples:
            all_examples = thread_examples

        # Calculate coverage for each example
        example_coverage = []
        for ex in all_examples:
            covered = self._get_example_coverage(ex, cat_components)
            if covered:
                example_coverage.append((ex, covered))

        if not example_coverage:
            return []

        # Sort by coverage (desc), priority (asc), unknown refs (asc)
        example_coverage.sort(
            key=lambda x: (-len(x[1]), x[0].get("priority", 0), _unknown_count(x[0]))
        )

        # Greedy set cover
        covered_so_far: set[str] = set()
        selected: list[dict[str, Any]] = []

        for ex, covered in example_coverage:
            newly_covered = covered - covered_so_far
            if newly_covered:
                selected.append(ex)
                covered_so_far |= covered
                if covered_so_far >= cat_component_names or len(selected) >= 3:
                    break

        return selected

    def format_convention(
        self,
        convention: str,
        components: list[str] | None = None,
        rendered_components: set[str] | None = None,
        component_priority: int = 0,
        example_priority: int = 0,
        flags: dict[str, Any] | None = None,
        heading_offset: int = 0
    ) -> str:
        """
        Format a convention specification.

        Args:
            convention: The name of the convention (e.g., "declarations", "directives", "syntax", "prefixes")
            components: Optional list of component names to include.
                       If None, shows all components (subject to component_priority).
            rendered_components: Set of component names already rendered elsewhere.
                               These are excluded from output but count as "known" for
                               example selection (examples referencing them are OK).
            component_priority: Maximum component priority to include (default 0).
                              Components with priority > this value are excluded.
            example_priority: Maximum example priority to include (default 0).
                            Examples with priority > this value are excluded.
            flags: Dictionary of formatting options.
                  - xml: If True, use <npl-example>XML tags; otherwise use fenced code blocks.
                  - concise: If True, use brief descriptions and reduce header nesting.
            heading_offset: Number of additional '#' to prepend to all headings (default 0).

        Returns:
            A formatted string containing the convention specification.
        """
        yaml_path = self.conventions_dir / f"{convention}.yaml"

        try:
            with open(yaml_path) as f:
                data = yaml.safe_load(f)
        except FileNotFoundError:
            return f"""
FORMAT CONVENTION {convention}
(Error: File not found at {yaml_path})
"""
        except Exception as e:
            return f"""
FORMAT CONVENTION {convention}
(Error: {e})
"""

        # Build component name set for filtering
        component_names = set(components) if components else None

        title = data.get("title") or data.get("name", convention)
        description = data.get("description", "").strip()
        brief = data.get("brief", "").strip()
        purpose = data.get("purpose", "").strip()
        categories = data.get("categories", [])
        all_components = data.get("components", [])

        # Get formatting flags, defaults to xml=False, concise=True
        if flags is None:
            flags = {}
        use_xml = flags.get("xml", False)
        use_concise = flags.get("concise", True)

        # In concise mode, prefer brief over description
        if use_concise and brief:
            description = brief

        # Heading helpers with offset
        h = heading_offset

        # Compute convention-wide set of components being rendered (for known_components)
        rendering_names: set[str] = set()
        for c in all_components:
            if component_names and c.get("name") not in component_names:
                continue
            if c.get("priority", 0) > component_priority:
                continue
            if rendered_components and c.get("name") in rendered_components:
                continue
            rendering_names.add(c.get("name"))

        # Known components = being rendered + already rendered
        known_components = set(rendering_names)
        if rendered_components:
            known_components |= rendered_components

        # Build categories section with components
        categories_section = ""
        if categories:
            for cat in categories:
                cat_name = cat.get("name", "")
                cat_title = cat.get("title", cat_name)
                cat_desc = cat.get("description", "").strip()

                # Filter to components being rendered in this category
                cat_components = [
                    c for c in all_components
                    if c.get("category") == cat_name and c.get("name") in rendering_names
                ]

                # Skip category if no components to render
                if not cat_components:
                    continue

                cat_header = _heading(3, h)
                comp_header = _heading(4, h)

                categories_section += f"{cat_header} {cat_title}\n\n{cat_desc}\n\n"

                # Find minimal set of category-level examples (to show at end)
                cat_examples = self._find_minimal_example_set(
                    cat, cat_components, example_priority, known_components
                )

                # Add individual components FIRST
                for comp in cat_components:
                    comp_name = comp.get("name", "")
                    comp_heading = comp.get("friendly-name") or comp["name"]
                    comp_brief = comp.get("brief", "").strip()
                    comp_desc = comp.get("description", "").strip()
                    comp_syntaxes = comp.get("syntax", [])
                    comp_examples = comp.get("examples", [])

                    # In concise mode, prefer brief over description
                    if use_concise and comp_brief:
                        comp_desc = comp_brief

                    # Filter examples by example_priority
                    filtered_examples: list[dict[str, Any]] = []
                    for ex in comp_examples:
                        if ex.get("priority", 0) > example_priority:
                            continue
                        filtered_examples.append(ex)

                    categories_section += f"{comp_header} {comp_heading}\n\n{comp_desc}\n\n"

                    # Syntax section
                    if comp_syntaxes:
                        if not use_concise:
                            categories_section += f"{_heading(5, h)} Syntax\n\n"
                        for syn in comp_syntaxes:
                            syn_syntax = syn.get("syntax", "")
                            syn_desc = syn.get("description", "")
                            # Keep escape sequences as literal (don't decode), just show syntax as-is
                            # Don't expand \n - keep it in the string
                            categories_section += f'"{syn_syntax}"\n'
                            # Add description with ":" prefix (multiline supported)
                            desc_lines = syn_desc.split('\n')
                            formatted_desc = '\n'.join(f': {line}' for line in desc_lines if line)
                            if formatted_desc:
                                categories_section += f"{formatted_desc}\n"
                            categories_section += "\n"

                    # Examples section (only if there are filtered examples)
                    if filtered_examples:
                        if not use_concise:
                            categories_section += f"{_heading(5, h)} Examples\n\n"
                        for ex in filtered_examples:
                            ex_example = ex.get("example", "").strip()
                            ex_thread = ex.get("thread", [])

                            if use_concise:
                                # Concise mode: just examples
                                if ex_example:
                                    if use_xml:
                                        categories_section += self._format_snippet_xml(ex_example) + "\n\n"
                                    else:
                                        categories_section += self._format_snippet_fence(ex_example) + "\n\n"
                                if ex_thread:
                                    if use_xml:
                                        categories_section += self._format_thread_xml(ex_thread) + "\n\n"
                                    else:
                                        categories_section += self._format_thread_fence(ex_thread) + "\n\n"
                            else:
                                # Standard mode with full headings
                                ex_title = ex.get("title") or ex.get("brief", "")
                                ex_description = ex.get("description", "").strip()
                                ex_purpose = ex.get("purpose", "").strip()

                                categories_section += f"{_heading(6, h)} {ex_title}\n\n{ex_description}\n\n```purpose\n{ex_purpose}\n```\n\n"

                                if ex_example:
                                    if use_xml:
                                        categories_section += self._format_snippet_xml(ex_example) + "\n\n"
                                    else:
                                        categories_section += self._format_snippet_fence(ex_example) + "\n\n"

                                if ex_thread:
                                    if use_xml:
                                        categories_section += self._format_thread_xml(ex_thread) + "\n\n"
                                    else:
                                        categories_section += self._format_thread_fence(ex_thread) + "\n\n"

                    categories_section += "\n"

                # Add category-level examples section at END of section
                if cat_examples:
                    examples_header = _heading(4, h)
                    categories_section += f"{examples_header} {cat_title} Examples\n\n"
                    for ex in cat_examples:
                        ex_brief = ex.get("brief", "")
                        ex_thread = ex.get("thread", [])
                        ex_example = ex.get("example", "")

                        # Include brief description
                        if ex_brief:
                            categories_section += f"**{ex_brief}**\n\n"

                        if use_concise:
                            # Concise mode: just examples
                            if ex_example:
                                if use_xml:
                                    categories_section += self._format_snippet_xml(ex_example) + "\n\n"
                                else:
                                    categories_section += self._format_snippet_fence(ex_example) + "\n\n"
                            if ex_thread:
                                if use_xml:
                                    categories_section += self._format_thread_xml(ex_thread) + "\n\n"
                                else:
                                    categories_section += self._format_thread_fence(ex_thread) + "\n\n"
                        else:
                            # Standard mode
                            if ex_example:
                                if use_xml:
                                    categories_section += self._format_snippet_xml(ex_example) + "\n\n"
                                else:
                                    categories_section += self._format_snippet_fence(ex_example) + "\n\n"
                            if ex_thread:
                                if use_xml:
                                    categories_section += self._format_thread_xml(ex_thread) + "\n\n"
                                else:
                                    categories_section += self._format_thread_fence(ex_thread) + "\n\n"
                    categories_section += "\n"

        # Build purpose section (always included)
        purpose_section = f"""
```purpose
{purpose}
```"""

        title_header = _heading(1, h)

        return f"""
{title_header} {title}

{description}
{purpose_section}

{categories_section}
"""


class NPLDefinition:
    """Formatter for complete NPL framework definitions.

    Wraps convention output in NPL declaration markers (⌜NPL@{version}⌝ ... ⌞NPL@{version}⌟)
    with a core concepts section and nested convention sections. Reads framework metadata
    from npl.yaml.
    """

    def __init__(self, conventions_dir: str | Path | None = None):
        if conventions_dir is None:
            project_root = Path(__file__).parent.parent.parent
            conventions_dir = project_root / "conventions"
        self.conventions_dir = Path(conventions_dir)
        self.formatter = ConventionFormatter(conventions_dir)
        self._load_npl_config()

    def _load_npl_config(self):
        """Load framework metadata from npl.yaml."""
        npl_path = self.conventions_dir / "npl.yaml"
        with open(npl_path) as f:
            data = yaml.safe_load(f)
        self.npl = data.get("/npl", {})
        # version may parse as float (1.0) — format to preserve decimal
        raw_version = self.npl.get("version", "1.0")
        if isinstance(raw_version, float):
            self.version = f"{raw_version:.1f}"
        else:
            self.version = str(raw_version)
        self.description = self.npl.get("description", "").strip()
        self.concepts = self.npl.get("concepts", [])
        self.section_order = self.npl.get("section_order", {}).get("components", [])

    def _load_dependency_graph(self):
        """Load all convention YAML files and build the component dependency graph.

        Populates:
            _dep_graph: maps "convention.component" → list of "convention.component" require refs
            _convention_components: maps "convention" → list of component name slugs
        """
        if hasattr(self, '_dep_graph'):
            return  # Already loaded

        self._dep_graph: dict[str, list[str]] = {}
        self._convention_components: dict[str, list[str]] = {}

        for conv_name in self.section_order:
            yaml_path = self.conventions_dir / f"{conv_name}.yaml"
            try:
                with open(yaml_path) as f:
                    data = yaml.safe_load(f)
            except (FileNotFoundError, yaml.YAMLError):
                continue

            comps = data.get("components", [])
            self._convention_components[conv_name] = [c.get("name") for c in comps]
            for c in comps:
                key = f"{conv_name}.{c.get('name')}"
                self._dep_graph[key] = c.get("require", [])

    def _resolve_dependencies(
        self,
        conv_map: dict[str, tuple[list[str] | None, int, int]],
        rendered_keys: set[str] | None = None
    ) -> dict[str, tuple[list[str] | None, int, int]]:
        """Expand conv_map to include all transitive dependencies from require fields.

        Walks the dependency graph until stable. Handles circular deps via set membership.
        Auto-added deps inherit the priorities of the component that required them.
        Dependencies already in rendered_keys are skipped (already rendered elsewhere).
        """
        self._load_dependency_graph()

        if rendered_keys is None:
            rendered_keys = set()

        # Expand wildcards (None) to actual component name lists
        expanded: dict[str, tuple[list[str], int, int]] = {}
        for conv, (comps, cp, ep) in conv_map.items():
            if comps is None:
                actual = list(self._convention_components.get(conv, []))
            else:
                actual = list(comps)
            expanded[conv] = (actual, cp, ep)

        # Build included set with priorities keyed by "convention.component"
        included: set[str] = set()
        priorities: dict[str, tuple[int, int]] = {}

        for conv, (comps, cp, ep) in expanded.items():
            for comp in comps:
                key = f"{conv}.{comp}"
                included.add(key)
                if key in priorities:
                    old_cp, old_ep = priorities[key]
                    priorities[key] = (max(old_cp, cp), max(old_ep, ep))
                else:
                    priorities[key] = (cp, ep)

        # Walk dependencies until stable
        changed = True
        while changed:
            changed = False
            for key in list(included):
                reqs = self._dep_graph.get(key, [])
                cp, ep = priorities[key]
                for req in reqs:
                    # Skip deps already rendered elsewhere
                    if req in rendered_keys:
                        continue
                    if req not in included:
                        included.add(req)
                        priorities[req] = (cp, ep)
                        changed = True
                    else:
                        old_cp, old_ep = priorities[req]
                        new_cp, new_ep = max(old_cp, cp), max(old_ep, ep)
                        if new_cp > old_cp or new_ep > old_ep:
                            priorities[req] = (new_cp, new_ep)
                            changed = True

        # Rebuild conv_map from included set
        result: dict[str, tuple[list[str] | None, int, int]] = {}
        for key in included:
            conv, comp = key.split(".", 1)
            cp, ep = priorities[key]
            if conv in result:
                existing_comps, existing_cp, existing_ep = result[conv]
                existing_comps.append(comp)
                result[conv] = (existing_comps, max(existing_cp, cp), max(existing_ep, ep))
            else:
                result[conv] = ([comp], cp, ep)

        return result

    def _parse_component_specs(
        self,
        specs: list[str | ComponentSpec],
        default_component_priority: int = 0,
        default_example_priority: int = 0
    ) -> dict[str, tuple[list[str] | None, int, int]] | None:
        """Parse component specs into per-convention selections with priorities.

        Accepts a mix of plain strings (use default priorities) and ComponentSpec
        objects (carry their own priorities).

        Returns:
            Dict mapping convention name → (component_names, component_priority, example_priority).
            component_names is None for wildcard (all components).
            Returns None if wildcard-all (*) was specified.
        """
        result: dict[str, tuple[list[str] | None, int, int]] = {}

        for spec in specs:
            if isinstance(spec, ComponentSpec):
                raw = spec.spec
                cp = spec.component_priority
                ep = spec.example_priority
            else:
                raw = spec
                cp = default_component_priority
                ep = default_example_priority

            raw = raw.strip()
            if raw == "*":
                return None  # All conventions, all components

            if ":" in raw:
                convention, comp_str = raw.split(":", 1)
                convention = convention.strip()
                comp_str = comp_str.strip()

                if comp_str == "*":
                    comps = None
                else:
                    comps = [c.strip() for c in comp_str.split(",") if c.strip()]
            else:
                # Bare convention name = convention:*
                convention = raw
                comps = None

            if convention in result:
                existing_comps, existing_cp, existing_ep = result[convention]
                # Merge: combine component lists, use max priorities
                if existing_comps is None or comps is None:
                    merged_comps = None
                else:
                    merged_comps = existing_comps + comps
                result[convention] = (merged_comps, max(existing_cp, cp), max(existing_ep, ep))
            else:
                result[convention] = (comps, cp, ep)

        return result

    def _parse_rendered_specs(self, specs: list[str | ComponentSpec]) -> set[str]:
        """Parse rendered component specs into a set of 'convention.component' keys.

        Accepts a mix of plain strings and ComponentSpec objects.
        Specs like "syntax:placeholder,qualifier" or ComponentSpec("pumps:intent-declaration").
        No wildcards — these are components already rendered elsewhere.
        """
        result: set[str] = set()
        for spec in specs:
            raw = spec.spec if isinstance(spec, ComponentSpec) else spec
            raw = raw.strip()
            if ":" in raw:
                convention, comp_str = raw.split(":", 1)
                convention = convention.strip()
                for comp in comp_str.split(","):
                    comp = comp.strip()
                    if comp:
                        result.add(f"{convention}.{comp}")
        return result

    def format(
        self,
        components: list[str | ComponentSpec] | None = None,
        rendered: list[str | ComponentSpec] | None = None,
        component_priority: int = 0,
        example_priority: int = 0,
        extension: bool = False,
        flags: dict[str, Any] | None = None
    ) -> str:
        """
        Format a complete NPL definition with declaration markers.

        Args:
            components: List of component specs (str or ComponentSpec). Supports:
                       - None → all conventions, all components (uses default priorities)
                       - ["syntax:*"] → all syntax components (uses default priorities)
                       - [ComponentSpec("pumps:*", component_priority=0, example_priority=1)]
                       - ["syntax:*", ComponentSpec("pumps:npl-intent", example_priority=2)]
                       - ["*"] → explicit all
            rendered: List of component specs already rendered elsewhere (str or ComponentSpec,
                     fully expanded, no wildcards). These components are excluded from output
                     but treated as "known" for example selection.
            component_priority: Default component priority for str specs and None (default 0).
            example_priority: Default example priority for str specs and None (default 0).
            extension: If True, wraps in extend markers (⌜extend:NPL@...⌝) instead
                      of definition markers. Default False.
            flags: Formatting flags passed to convention sections.

        Returns:
            A formatted string containing the complete NPL definition.
        """
        version = self.version

        if extension:
            open_marker = f"\u231Cextend:NPL@{version}\u231D"
            close_marker = f"\u231Eextend:NPL@{version}\u231F"
        else:
            open_marker = f"\u231CNPL@{version}\u231D"
            close_marker = f"\u231ENPL@{version}\u231F"

        # Parse rendered specs
        rendered_keys = self._parse_rendered_specs(rendered) if rendered else set()

        # Parse component specs and resolve dependencies
        if components is None:
            conv_map = None  # All conventions, all components
        else:
            conv_map = self._parse_component_specs(components, component_priority, example_priority)

        # Resolve transitive dependencies (skip if all conventions included)
        if conv_map is not None:
            conv_map = self._resolve_dependencies(conv_map, rendered_keys)

        # Header
        result = f"{open_marker}\n"
        result += "# Noizu Prompt Lingua (NPL)\n"
        result += f"{self.description}\n\n"

        # Core Concepts
        result += "## Core Concepts\n\n"
        for concept in self.concepts:
            name = concept.get("name", "")
            desc = concept.get("description", "").strip()
            result += f"**{name}**\n: {desc}\n\n"

        # Determine which conventions to render and in what order
        # Each entry is (convention_name, component_names, component_priority, example_priority)
        if conv_map is None:
            # All conventions from section_order with default priorities
            conventions_to_render = [
                (conv, None, component_priority, example_priority)
                for conv in self.section_order
            ]
        else:
            # Render in section_order, but only conventions that appear in conv_map
            conventions_to_render = []
            rendered_convs = set()
            for conv in self.section_order:
                if conv in conv_map:
                    comp_names, cp, ep = conv_map[conv]
                    conventions_to_render.append((conv, comp_names, cp, ep))
                    rendered_convs.add(conv)
            # Append any specs not in section_order (preserves user order for extras)
            for conv in conv_map:
                if conv not in rendered_convs:
                    comp_names, cp, ep = conv_map[conv]
                    conventions_to_render.append((conv, comp_names, cp, ep))

        # Render each convention section
        for conv_name, conv_components, cp, ep in conventions_to_render:
            # Compute rendered component names for this convention
            conv_rendered = {
                key.split(".", 1)[1]
                for key in rendered_keys
                if key.startswith(f"{conv_name}.")
            }

            section = self.formatter.format_convention(
                conv_name,
                components=conv_components,
                rendered_components=conv_rendered if conv_rendered else None,
                component_priority=cp,
                example_priority=ep,
                flags=flags,
                heading_offset=1
            )
            result += section

        result += f"\n{close_marker}\n"
        return result
