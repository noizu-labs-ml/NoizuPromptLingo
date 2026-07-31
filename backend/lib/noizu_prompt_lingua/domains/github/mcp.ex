defmodule NoizuPromptLingua.Domains.Github.MCP do
  @moduledoc """
  GitHub integration MCP server. Provides tools to browse repositories, manage
  branches, and interact with pull requests and issues. All operations are scoped
  to an organization and enforce repo ACL via the can_access/3 checks.
  """
  use Noizu.MCP.Server,
    name: "tobor_github",
    version: "0.1.0",
    instructions:
      "GitHub operations within an organization. Use the caller_user_id parameter " <>
        "to identify the requesting user; all repo access is verified against its ACL. " <>
        "Pass repo as either the UUID or the full repo_full_name (e.g. \"owner/name\")."

  # Discovery
  tool(NoizuPromptLingua.Domains.Github.Tools.Overview, category: "GitHub")

  # Repos
  tool(NoizuPromptLingua.Domains.Github.Tools.RepoList, category: "GitHub")

  # Branches
  tool(NoizuPromptLingua.Domains.Github.Tools.BranchList, category: "GitHub")
  tool(NoizuPromptLingua.Domains.Github.Tools.BranchGet, category: "GitHub")
  tool(NoizuPromptLingua.Domains.Github.Tools.BranchCreate, category: "GitHub")

  # Pull Requests
  tool(NoizuPromptLingua.Domains.Github.Tools.PullList, category: "GitHub.Pulls")
  tool(NoizuPromptLingua.Domains.Github.Tools.PullGet, category: "GitHub.Pulls")
  tool(NoizuPromptLingua.Domains.Github.Tools.PullCreate, category: "GitHub.Pulls")
  tool(NoizuPromptLingua.Domains.Github.Tools.PullMerge, category: "GitHub.Pulls")
  tool(NoizuPromptLingua.Domains.Github.Tools.PullComment, category: "GitHub.Pulls")

  # Issues
  tool(NoizuPromptLingua.Domains.Github.Tools.IssueList, category: "GitHub.Issues")
  tool(NoizuPromptLingua.Domains.Github.Tools.IssueGet, category: "GitHub.Issues")
  tool(NoizuPromptLingua.Domains.Github.Tools.IssueCreate, category: "GitHub.Issues")
  tool(NoizuPromptLingua.Domains.Github.Tools.IssueComment, category: "GitHub.Issues")

  # Discovery tools
  tool(NoizuPromptLingua.Tools.ToolSummary, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolSearch, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolDefinition, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolCall, category: "Discovery")
  tool(NoizuPromptLingua.Tools.ToolHelp, category: "Discovery")
end
