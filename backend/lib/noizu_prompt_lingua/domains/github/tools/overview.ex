defmodule NoizuPromptLingua.Domains.Github.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Github.Overview",
    description: "Overview of available GitHub tools and permissions model.",
    hidden: false,
    category: "GitHub"

  @impl true
  def call(_args, _ctx) do
    {:ok,
     %{
       description: "GitHub integration provides read/write operations on org-scoped repos.",
       acl_model: """
       Each repo has a default_acl (private|org_read|org_write). Additionally,
       group grants (scoped_memberships with member_type='group') can grant read
       or write access to specific groups. A user gets access if they:
       	1. Have org membership AND default_acl permits the requested level, OR
       	2. Are a member of a group that's been granted the requested level.
       """,
       tools: [
         %{category: "Repos", tools: ["RepoList"]},
         %{category: "Branches", tools: ["BranchList", "BranchGet", "BranchCreate"]},
         %{
           category: "Pull Requests",
           tools: ["PullList", "PullGet", "PullCreate", "PullMerge", "PullComment"]
         },
         %{category: "Issues", tools: ["IssueList", "IssueGet", "IssueCreate", "IssueComment"]}
       ],
       required_inputs: [
         %{name: "caller_user_id", description: "UUID of the requesting user", required: true},
         %{name: "organization", description: "Organization slug or UUID", required: true},
         %{name: "repo", description: "Repo UUID or full_name (owner/name)", required: false}
       ]
     }}
  end
end
