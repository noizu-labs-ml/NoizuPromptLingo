"""Tool implementation registry.

Maps catalog tool names to real async functions so that ``ToolPin`` can
register a working tool (via ``Tool.from_function()``) instead of a stub
when an implementation exists.
"""

from typing import Callable, Optional

_IMPLEMENTATIONS: dict[str, Callable] = {}


def register_implementation(name: str, fn: Callable) -> None:
    """Register *fn* as the implementation for catalog tool *name*."""
    _IMPLEMENTATIONS[name] = fn


def get_implementation(name: str) -> Optional[Callable]:
    """Return the registered implementation for *name*, or ``None``."""
    return _IMPLEMENTATIONS.get(name)


# ---------------------------------------------------------------------------
# Auto-register known implementations on import
# ---------------------------------------------------------------------------

def _auto_register() -> None:
    from npl_mcp.browser.to_markdown import to_markdown
    from npl_mcp.browser.ping import ping
    from npl_mcp.browser.download import download
    from npl_mcp.browser.screenshot import screenshot
    from npl_mcp.browser.secrets import secret_set
    from npl_mcp.browser.rest import rest
    from npl_mcp.tool_sessions.tool_sessions import (
        tool_session_generate,
        tool_session,
    )
    from npl_mcp.instructions.instructions import (
        instructions_create,
        instructions_get,
        instructions_update,
        instructions_active_version,
        instructions_versions,
        instructions_list,
    )
    from npl_mcp.pm_tools.db_projects import (
        project_create,
        project_get,
        project_list,
    )
    from npl_mcp.pm_tools.db_personas import (
        persona_create,
        persona_get,
        persona_update,
        persona_delete,
        persona_list,
    )
    from npl_mcp.pm_tools.db_stories import (
        story_create,
        story_get,
        story_update,
        story_delete,
        story_list,
    )

    register_implementation("ToMarkdown", to_markdown)
    register_implementation("Ping", ping)
    register_implementation("Download", download)
    register_implementation("Screenshot", screenshot)
    register_implementation("Secret", secret_set)
    register_implementation("Rest", rest)
    register_implementation("ToolSession.Generate", tool_session_generate)
    register_implementation("ToolSession", tool_session)
    register_implementation("Instructions", instructions_get)
    register_implementation("Instructions.Create", instructions_create)
    register_implementation("Instructions.Update", instructions_update)
    register_implementation("Instructions.ActiveVersion", instructions_active_version)
    register_implementation("Instructions.Versions", instructions_versions)
    register_implementation("Instructions.List", instructions_list)
    register_implementation("Proj.Projects.Create", project_create)
    register_implementation("Proj.Projects.Get", project_get)
    register_implementation("Proj.Projects.List", project_list)
    register_implementation("Proj.UserPersonas.Create", persona_create)
    register_implementation("Proj.UserPersonas.Get", persona_get)
    register_implementation("Proj.UserPersonas.Update", persona_update)
    register_implementation("Proj.UserPersonas.Delete", persona_delete)
    register_implementation("Proj.UserPersonas.List", persona_list)
    register_implementation("Proj.UserStories.Create", story_create)
    register_implementation("Proj.UserStories.Get", story_get)
    register_implementation("Proj.UserStories.Update", story_update)
    register_implementation("Proj.UserStories.Delete", story_delete)
    register_implementation("Proj.UserStories.List", story_list)


_auto_register()
