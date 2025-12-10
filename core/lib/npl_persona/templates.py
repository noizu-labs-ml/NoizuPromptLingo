"""
Template generators for npl_persona.

Contains all markdown template generation functions, extracted from the
original _generate_* methods.
"""

from datetime import datetime, timedelta
from typing import Optional


def generate_persona_definition(persona_id: str, role: Optional[str] = None) -> str:
    """
    Generate persona definition file content.

    Args:
        persona_id: Persona identifier
        role: Role/title for the persona

    Returns:
        Markdown content for persona definition file
    """
    role = role or "specialist"
    name = persona_id.replace("-", " ").title()

    return f"""⌜persona:{persona_id}|{role}|NPL@1.0⌝
# {name}
`{role}` `expertise`

## Identity
- **Role**: {role.title()}
- **Experience**: TBD years in TBD
- **Personality**: TBD (OCEAN scores)
- **Communication**: TBD

## Voice Signature
```voice
lexicon: [TBD]
patterns: [TBD]
quirks: [TBD]
```

## Expertise Graph
```knowledge
primary: [TBD]
secondary: [TBD]
boundaries: [TBD]
learning: [TBD]
```

## Relationships
⟪🤝: (l,l,c) | Persona,Relationship,Dynamics⟫
| TBD | TBD | TBD |

## Memory Hooks
- journal: `./{persona_id}.journal.md`
- tasks: `./{persona_id}.tasks.md`
- knowledge: `./{persona_id}.knowledge-base.md`

⌞persona:{persona_id}⌟
"""


def generate_journal_template(persona_id: str) -> str:
    """
    Generate journal template content.

    Args:
        persona_id: Persona identifier

    Returns:
        Markdown content for journal file
    """
    return f"""# {persona_id} Journal
`continuous-learning` `experience-log` `reflection-notes`

## Recent Interactions
<!-- Entries will be added here in reverse chronological order -->

## Relationship Evolution
⟪📊: (l,c,r) | Person,Initial,Current⟫
<!-- Relationship tracking will appear here -->

## Personal Development Log
```growth
<!-- Development milestones will be logged here -->
```

## Reflection Patterns
<npl-cot>
<!-- Recurring themes and patterns will emerge here -->
</npl-cot>
"""


def generate_tasks_template(persona_id: str, role: Optional[str] = None) -> str:
    """
    Generate tasks template content.

    Args:
        persona_id: Persona identifier
        role: Role for default responsibilities

    Returns:
        Markdown content for tasks file
    """
    role = role or "specialist"
    quarter = datetime.now().month // 3 + 1

    return f"""# {persona_id} Tasks
`active-goals` `responsibilities` `commitments`

## 🎯 Active Tasks
⟪📅: (l,c,c,r) | Task,Status,Owner,Due⟫
<!-- Tasks will be added here -->

## 🎭 Role Responsibilities
```responsibilities
DAILY:
- [ ] TBD (customize based on {role} role)

WEEKLY:
- [ ] Team sync
- [ ] Progress review

PROJECT-SPECIFIC:
- [ ] TBD
```

## 📈 Goals & OKRs
### Q{quarter} Objectives
**Objective**: TBD
- **KR1**: TBD [0%]
- **KR2**: TBD [0%]
- **KR3**: TBD [0%]

## 🔄 Task History
```completed
<!-- Completed tasks will be archived here -->
```

## 🚫 Blocked Items
⟪⚠️: blocked | task, reason, needs⟫
<!-- Blocked tasks will appear here -->
"""


def generate_knowledge_template(persona_id: str, role: Optional[str] = None) -> str:
    """
    Generate knowledge base template content.

    Args:
        persona_id: Persona identifier
        role: Role for initial domain

    Returns:
        Markdown content for knowledge base file
    """
    role = role or "specialist"
    today = datetime.now().strftime("%Y-%m-%d")
    future = (datetime.now() + timedelta(days=30)).strftime("%Y-%m-%d")

    return f"""# {persona_id} Knowledge Base
`domain-expertise` `learned-concepts` `reference-materials`

## 📚 Core Knowledge Domains
### {role.title()}
```knowledge
confidence: 0%
depth: surface
last_updated: {today}
```

**Key Concepts**:
- TBD: (understanding to be developed)

**Practical Applications**:
1. TBD

## 🔄 Recently Acquired Knowledge
<!-- New learnings will be added here -->

## 🎓 Learning Paths
```learning
ACTIVE:
- TBD: starting → intermediate

PLANNED:
- TBD: Start by {future}

COMPLETED:
- (none yet)
```

## 📖 Reference Library
⟪📚: (l,c,r) | Resource,Type,Relevance⟫
<!-- Resources will be cataloged here -->

## ❓ Knowledge Gaps
```gaps
KNOWN_UNKNOWNS:
- TBD: Need to learn for TBD

UNCERTAIN_AREAS:
- TBD: Partial understanding, need clarification
```

## 🔗 Knowledge Graph Connections
```mermaid
graph LR
    A[Core Concept] --> B[Related Concept]
```
"""


def generate_journal_entry(
    message: str,
    session_id: Optional[str] = None
) -> str:
    """
    Generate a new journal entry.

    Args:
        message: Entry message/context
        session_id: Optional session ID (generated if not provided)

    Returns:
        Markdown content for journal entry
    """
    date_str = datetime.now().strftime("%Y-%m-%d")
    session_id = session_id or datetime.now().strftime("%Y%m%d-%H%M%S")

    return f"""
### {date_str} - {session_id}
**Context**: {message}
**Participants**: TBD
**My Role**: TBD

<npl-reflection>
{message}
</npl-reflection>

**Outcomes**: TBD
**Growth**: TBD

---
"""


def generate_task_row(
    description: str,
    due: Optional[str] = None,
    priority: str = "med"
) -> str:
    """
    Generate a task table row.

    Args:
        description: Task description
        due: Optional due date (YYYY-MM-DD)
        priority: Task priority (high/med/low)

    Returns:
        Markdown table row for task
    """
    from .config import PRIORITY_ICONS

    priority_icon = PRIORITY_ICONS.get(priority, "🟡")
    due_str = due or "TBD"

    return f"| ⏸️ {priority_icon} | {description} | {due_str} | @owner |"


def generate_knowledge_entry(
    topic: str,
    content: Optional[str] = None,
    source: Optional[str] = None
) -> str:
    """
    Generate a knowledge base entry.

    Args:
        topic: Knowledge topic
        content: Learning content
        source: Knowledge source

    Returns:
        Markdown content for knowledge entry
    """
    date_str = datetime.now().strftime("%Y-%m-%d")
    source_str = f"**Source**: {source}" if source else "**Source**: Direct experience"

    return f"""
### {date_str} - {topic}
{source_str}
**Learning**: {content or 'TBD'}
**Integration**: TBD - How this connects to existing knowledge
**Application**: TBD - Can be used for specific use cases

"""


def generate_team_definition(
    team_id: str,
    scope: str = "project",
    member_rows: str = ""
) -> str:
    """
    Generate team definition file content.

    Args:
        team_id: Team identifier
        scope: Team scope (project/user/system)
        member_rows: Pre-formatted member table rows

    Returns:
        Markdown content for team definition file
    """
    created_date = datetime.now().strftime("%Y-%m-%d")
    title = team_id.replace("-", " ").title()

    if not member_rows:
        member_rows = "| <!-- Members will be added here --> | | | |"

    return f"""⌜team:{team_id}|NPL@1.0⌝
# {title}
`team` `collaboration` `knowledge-sharing`

**Created**: {created_date}
**Scope**: {scope}
**Status**: Active

## Team Composition

⟪👥: (l,l,c,r) | Persona,Role,Joined,Status⟫
{member_rows}

## Team Purpose

{title} focuses on collaborative work across multiple personas.

**Mission**: TBD
**Goals**:
- TBD
- TBD

## Collaboration Patterns

```patterns
DAILY:
- Stand-ups and sync meetings
- Knowledge sharing sessions

WEEKLY:
- Sprint planning
- Retrospectives
- Knowledge synthesis

MONTHLY:
- Team health review
- Skills assessment
- Goal alignment
```

## Team Dynamics

**Communication Style**: TBD
**Decision Making**: TBD
**Conflict Resolution**: TBD

## Knowledge Areas

⟪📚: (l,c,c) | Domain,Primary Owner,Team Proficiency⟫
| <!-- Domains will be tracked here --> | | |

## Team Metrics

- **Collaboration Index**: N/A
- **Knowledge Sharing**: N/A
- **Velocity**: N/A
- **Member Satisfaction**: N/A

## Resources

- **Team History**: `./{team_id}.history.md`
- **Shared Knowledge**: `../shared/team-knowledge-{team_id}.md`

⌞team:{team_id}⌟
"""


def generate_team_history(team_id: str, initial_members: str = "None") -> str:
    """
    Generate team history file content.

    Args:
        team_id: Team identifier
        initial_members: Comma-separated list of initial members

    Returns:
        Markdown content for team history file
    """
    title = team_id.replace("-", " ").title()
    created_date = datetime.now().strftime("%Y-%m-%d")

    return f"""# {title} - Collaboration History
`team-interactions` `knowledge-sharing` `evolution`

## Team Formation

**Date**: {created_date}
**Initial Members**: {initial_members}

---

## Interaction Log

<!-- Team interactions will be logged here -->

## Milestones

<!-- Team milestones will be tracked here -->

## Evolution

<!-- Team growth and changes will be documented here -->
"""


def generate_member_row(
    persona_id: str,
    role: str = "Member",
    status: str = "Active"
) -> str:
    """
    Generate a table row for a team member.

    Args:
        persona_id: Member persona ID
        role: Member role
        status: Member status

    Returns:
        Table row string
    """
    joined_date = datetime.now().strftime("%Y-%m-%d")
    return f"| @{persona_id} | {role} | {joined_date} | {status} |"
