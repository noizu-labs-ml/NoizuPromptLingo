"""Project Management MCP Tools.

This package provides tools for accessing project management artifacts:
- User stories from project-management/user-stories/
- PRDs from project-management/PRDs/
- Personas from project-management/personas/
"""

from .exceptions import NotFoundError, ValidationError, ParseError
from .stories import get_story, list_stories, update_story_metadata
from .prds import get_prd, get_prd_functional_requirement, get_prd_acceptance_test
from .personas import get_persona, list_personas

__all__ = [
    # Exceptions
    "NotFoundError",
    "ValidationError",
    "ParseError",
    # Story tools
    "get_story",
    "list_stories",
    "update_story_metadata",
    # PRD tools
    "get_prd",
    "get_prd_functional_requirement",
    "get_prd_acceptance_test",
    # Persona tools
    "get_persona",
    "list_personas",
]
