"""
Knowledge base operations for npl_persona.

Handles kb add, search, get, update-domain, and share operations.
"""

import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional

from .config import DATE_FORMAT, SECTIONS, DEPTH_LEVELS, DEFAULT_SEARCH_RESULTS
from .paths import resolve_persona
from .io import read_file, write_file
from .templates import generate_knowledge_entry


class KnowledgeManager:
    """Manages knowledge base operations for personas."""

    def add_entry(
        self,
        persona_id: str,
        topic: str,
        content: Optional[str] = None,
        source: Optional[str] = None
    ) -> bool:
        """
        Add knowledge base entry.

        Args:
            persona_id: Persona identifier
            topic: Knowledge topic
            content: Learning content
            source: Knowledge source

        Returns:
            True on success, False on failure
        """
        location = resolve_persona(persona_id)

        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        kb_file = base_path / f"{persona_id}.knowledge-base.md"

        if not kb_file.exists():
            print(f"Error: Knowledge base file not found: {kb_file}", file=sys.stderr)
            return False

        # Read existing
        result = read_file(kb_file)
        if result.is_err():
            print(f"Error reading knowledge base: {result.error}", file=sys.stderr)
            return False

        kb_content = result.value

        # Create entry
        entry = generate_knowledge_entry(topic, content, source)

        # Insert after "## 🔄 Recently Acquired Knowledge"
        section_header = SECTIONS["recently_acquired"]
        if section_header in kb_content:
            parts = kb_content.split(section_header, 1)
            new_content = parts[0] + section_header + entry + parts[1]
        else:
            new_content = kb_content + "\n" + section_header + entry

        # Write back
        result = write_file(kb_file, new_content)
        if result.is_err():
            print(f"Error writing knowledge base: {result.error}", file=sys.stderr)
            return False

        print(f"✅ Knowledge entry added: {topic}")
        return True

    def search(
        self,
        persona_id: str,
        query: str,
        domain: Optional[str] = None
    ) -> bool:
        """
        Search knowledge base.

        Args:
            persona_id: Persona identifier
            query: Search query
            domain: Optional domain to filter by

        Returns:
            True on success, False on failure
        """
        location = resolve_persona(persona_id)

        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        kb_file = base_path / f"{persona_id}.knowledge-base.md"

        if not kb_file.exists():
            print(f"Error: Knowledge base file not found: {kb_file}", file=sys.stderr)
            return False

        result = read_file(kb_file)
        if result.is_err():
            print(f"Error reading knowledge base: {result.error}", file=sys.stderr)
            return False

        content = result.value

        # Simple text search
        query_lower = query.lower()
        matches = []

        # Search by domain if specified
        if domain:
            domain_pattern = f"### {domain}(.*?)(?=###|\\Z)"
            domain_matches = re.findall(domain_pattern, content, re.DOTALL | re.IGNORECASE)
            search_content = "\n".join(domain_matches) if domain_matches else content
        else:
            search_content = content

        # Find matching sections
        for line in search_content.split("\n"):
            if query_lower in line.lower():
                matches.append(line.strip())

        if not matches:
            domain_note = f" in domain {domain}" if domain else ""
            print(f"No matches found for '{query}'{domain_note}")
            return True

        print(f"# Knowledge base search results for '{query}' ({len(matches)} matches)\n")
        for i, match in enumerate(matches[:DEFAULT_SEARCH_RESULTS], 1):
            print(f"{i}. {match}")

        if len(matches) > DEFAULT_SEARCH_RESULTS:
            print(f"\n... and {len(matches) - DEFAULT_SEARCH_RESULTS} more matches")

        return True

    def get_entry(self, persona_id: str, topic: str) -> bool:
        """
        Get specific knowledge entry.

        Args:
            persona_id: Persona identifier
            topic: Topic to retrieve

        Returns:
            True on success, False on failure
        """
        location = resolve_persona(persona_id)

        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        base_path, scope = location
        kb_file = base_path / f"{persona_id}.knowledge-base.md"

        if not kb_file.exists():
            print(f"Error: Knowledge base file not found: {kb_file}", file=sys.stderr)
            return False

        result = read_file(kb_file)
        if result.is_err():
            print(f"Error reading knowledge base: {result.error}", file=sys.stderr)
            return False

        content = result.value

        # Find topic section
        topic_pattern = f"###[^\\n]*{re.escape(topic)}[^\\n]*(.*?)(?=###|\\Z)"
        matches = re.findall(topic_pattern, content, re.DOTALL | re.IGNORECASE)

        if not matches:
            print(f"Knowledge entry '{topic}' not found")
            return False

        print(f"# Knowledge: {topic}\n")
        for match in matches:
            print(match.strip())
            print()

        return True

    def update_domain(
        self,
        persona_id: str,
        domain: str,
        confidence: int
    ) -> bool:
        """
        Update domain expertise confidence level.

        Args:
            persona_id: Persona identifier
            domain: Domain name
            confidence: Confidence level (0-100)

        Returns:
            True on success, False on failure
        """
        location = resolve_persona(persona_id)

        if not location:
            print(f"Error: Persona '{persona_id}' not found", file=sys.stderr)
            return False

        if confidence < 0 or confidence > 100:
            print(f"Error: Confidence must be 0-100", file=sys.stderr)
            return False

        base_path, scope = location
        kb_file = base_path / f"{persona_id}.knowledge-base.md"

        if not kb_file.exists():
            print(f"Error: Knowledge base file not found: {kb_file}", file=sys.stderr)
            return False

        result = read_file(kb_file)
        if result.is_err():
            print(f"Error reading knowledge base: {result.error}", file=sys.stderr)
            return False

        content = result.value

        # Find and update domain confidence
        domain_section_pattern = f"### {re.escape(domain)}(.*?)```knowledge(.*?)```"
        matches = list(re.finditer(domain_section_pattern, content, re.DOTALL | re.IGNORECASE))

        updated = False
        for match in matches:
            old_block = match.group(2)
            # Update confidence line
            new_block = re.sub(r"confidence:\s*\d+%", f"confidence: {confidence}%", old_block)
            # Update last_updated
            new_block = re.sub(
                r"last_updated:.*",
                f"last_updated: {datetime.now().strftime(DATE_FORMAT)}",
                new_block
            )

            content = content.replace(
                match.group(0),
                f"### {domain}{match.group(1)}```knowledge{new_block}```"
            )
            updated = True
            break

        if not updated:
            print(f"Warning: Domain '{domain}' not found, creating new entry")

            # Determine depth from confidence
            depth = "surface"
            for level, threshold in sorted(DEPTH_LEVELS.items(), key=lambda x: x[1], reverse=True):
                if confidence >= threshold:
                    depth = level
                    break

            new_domain = f"""
### {domain}
```knowledge
confidence: {confidence}%
depth: {depth}
last_updated: {datetime.now().strftime(DATE_FORMAT)}
```

**Key Concepts**:
- TBD: (to be documented)

**Practical Applications**:
1. TBD

"""
            # Insert after Core Knowledge Domains
            if SECTIONS["knowledge_domains"] in content:
                parts = content.split(SECTIONS["recently_acquired"], 1)
                content = parts[0] + new_domain + SECTIONS["recently_acquired"] + (parts[1] if len(parts) > 1 else "")
                updated = True

        if updated:
            result = write_file(kb_file, content)
            if result.is_err():
                print(f"Error writing knowledge base: {result.error}", file=sys.stderr)
                return False
            print(f"✅ Updated {domain} domain: {confidence}% confidence")
            return True

        return False

    def share_knowledge(
        self,
        from_persona: str,
        to_persona: str,
        topic: str,
        translate: bool = False
    ) -> bool:
        """
        Share knowledge between personas.

        Args:
            from_persona: Source persona ID
            to_persona: Target persona ID
            topic: Topic to share
            translate: Whether to translate to target context

        Returns:
            True on success, False on failure
        """
        # Find source persona
        from_location = resolve_persona(from_persona)
        if not from_location:
            print(f"Error: Source persona '{from_persona}' not found", file=sys.stderr)
            return False

        # Find target persona
        to_location = resolve_persona(to_persona)
        if not to_location:
            print(f"Error: Target persona '{to_persona}' not found", file=sys.stderr)
            return False

        from_base, _ = from_location
        to_base, _ = to_location

        # Extract knowledge from source
        from_kb = from_base / f"{from_persona}.knowledge-base.md"
        result = read_file(from_kb)
        if result.is_err():
            print(f"Error reading source knowledge base: {result.error}", file=sys.stderr)
            return False

        from_content = result.value

        # Find topic
        topic_pattern = f"###[^\\n]*{re.escape(topic)}[^\\n]*(.*?)(?=###|\\Z)"
        matches = re.findall(topic_pattern, from_content, re.DOTALL | re.IGNORECASE)

        if not matches:
            print(f"Error: Topic '{topic}' not found in {from_persona}'s knowledge base", file=sys.stderr)
            return False

        knowledge_text = matches[0].strip()

        print(f"Extracting knowledge from {from_persona}...")
        if translate:
            print(f"Translating to {to_persona}'s context...")
            knowledge_text = f"(Shared from @{from_persona})\n{knowledge_text}"

        # Add to target knowledge base
        to_kb = to_base / f"{to_persona}.knowledge-base.md"
        result = read_file(to_kb)
        if result.is_err():
            print(f"Error reading target knowledge base: {result.error}", file=sys.stderr)
            return False

        to_content = result.value

        entry = f"""
### {datetime.now().strftime(DATE_FORMAT)} - {topic} (shared)
**Source**: @{from_persona}
**Learning**: {knowledge_text}
**Integration**: Shared knowledge from team member
**Application**: TBD - Apply in relevant contexts

"""

        section_header = SECTIONS["recently_acquired"]
        if section_header in to_content:
            parts = to_content.split(section_header, 1)
            new_content = parts[0] + section_header + entry + parts[1]
        else:
            new_content = to_content + "\n" + section_header + entry

        result = write_file(to_kb, new_content)
        if result.is_err():
            print(f"Error writing target knowledge base: {result.error}", file=sys.stderr)
            return False

        print(f"✅ Knowledge transferred: {from_persona} → {to_persona}")
        return True
