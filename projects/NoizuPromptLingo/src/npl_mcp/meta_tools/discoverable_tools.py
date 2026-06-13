"""Register implemented tools as discoverable (hidden from MCP, callable via ToolCall).

Import this module to trigger registration of all implemented catalog tools.
"""

from __future__ import annotations

from .catalog import register_discoverable


def register_all() -> None:
    """Register all implemented tools that are not MCP-registered."""

    # ------------------------------------------------------------------
    # Browser tools
    # ------------------------------------------------------------------
    from npl_mcp.browser.to_markdown import to_markdown

    register_discoverable(
        "ToMarkdown",
        category="Browser",
        fn=to_markdown,
        category_description=(
            "Headless browser automation, markdown conversion, "
            "screenshots, downloads, connectivity, REST client"
        ),
    )

    from npl_mcp.browser.ping import ping

    register_discoverable("Ping", category="Browser", fn=ping)

    from npl_mcp.browser.download import download

    register_discoverable("Download", category="Browser", fn=download)

    from npl_mcp.browser.screenshot import screenshot

    register_discoverable("Screenshot", category="Browser", fn=screenshot)

    from npl_mcp.browser.rest import rest

    register_discoverable("Rest", category="Browser", fn=rest)

    # ------------------------------------------------------------------
    # Utility tools
    # ------------------------------------------------------------------
    from npl_mcp.browser.secrets import secret_set

    register_discoverable(
        "Secret",
        category="Utility",
        fn=secret_set,
        category_description="Secret management and miscellaneous utilities",
    )

    # ------------------------------------------------------------------
    # Instructions tools
    # ------------------------------------------------------------------
    from npl_mcp.instructions.instructions import (
        instructions_active_version,
        instructions_update,
        instructions_versions,
    )

    register_discoverable(
        "Instructions.Update",
        category="Instructions",
        fn=instructions_update,
        category_description="Agent instruction versioning and retrieval",
    )

    register_discoverable(
        "Instructions.ActiveVersion",
        category="Instructions",
        fn=instructions_active_version,
    )

    register_discoverable(
        "Instructions.Versions",
        category="Instructions",
        fn=instructions_versions,
    )

    # ------------------------------------------------------------------
    # Project Management tools
    # ------------------------------------------------------------------
    from npl_mcp.pm_tools.db_projects import (
        project_create,
        project_get,
        project_list,
    )

    register_discoverable(
        "Proj.Projects.Create",
        category="Project Management",
        fn=project_create,
        category_description=(
            "Project, persona, and user-story CRUD for product management"
        ),
    )

    register_discoverable(
        "Proj.Projects.Get",
        category="Project Management",
        fn=project_get,
    )

    register_discoverable(
        "Proj.Projects.List",
        category="Project Management",
        fn=project_list,
    )

    from npl_mcp.pm_tools.db_personas import (
        persona_create,
        persona_delete,
        persona_get,
        persona_list,
        persona_update,
    )

    register_discoverable(
        "Proj.UserPersonas.Create",
        category="Project Management",
        fn=persona_create,
    )

    register_discoverable(
        "Proj.UserPersonas.Get",
        category="Project Management",
        fn=persona_get,
    )

    register_discoverable(
        "Proj.UserPersonas.Update",
        category="Project Management",
        fn=persona_update,
    )

    register_discoverable(
        "Proj.UserPersonas.Delete",
        category="Project Management",
        fn=persona_delete,
    )

    register_discoverable(
        "Proj.UserPersonas.List",
        category="Project Management",
        fn=persona_list,
    )

    from npl_mcp.pm_tools.db_stories import (
        story_create,
        story_delete,
        story_get,
        story_list,
        story_update,
    )

    register_discoverable(
        "Proj.UserStories.Create",
        category="Project Management",
        fn=story_create,
    )

    register_discoverable(
        "Proj.UserStories.Get",
        category="Project Management",
        fn=story_get,
    )

    register_discoverable(
        "Proj.UserStories.Update",
        category="Project Management",
        fn=story_update,
    )

    register_discoverable(
        "Proj.UserStories.Delete",
        category="Project Management",
        fn=story_delete,
    )

    register_discoverable(
        "Proj.UserStories.List",
        category="Project Management",
        fn=story_list,
    )

    # ------------------------------------------------------------------
    # Scripts tools — PRD-008
    # ------------------------------------------------------------------
    from npl_mcp.scripts.wrapper import (
        dump_files,
        git_tree,
        git_tree_depth,
        npl_load as scripts_npl_load,
        web_to_md,
    )

    register_discoverable(
        "dump_files",
        category="Scripts",
        fn=dump_files,
        category_description="Shell script wrappers for file dumping, directory trees, NPL resource loading",
    )

    register_discoverable(
        "git_tree",
        category="Scripts",
        fn=git_tree,
    )

    register_discoverable(
        "git_tree_depth",
        category="Scripts",
        fn=git_tree_depth,
    )

    register_discoverable(
        "npl_load",
        category="Scripts",
        fn=scripts_npl_load,
    )

    register_discoverable(
        "web_to_md",
        category="Scripts",
        fn=web_to_md,
    )


register_all()
