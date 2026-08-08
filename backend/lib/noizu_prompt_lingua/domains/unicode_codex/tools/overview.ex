defmodule NoizuPromptLingua.Domains.UnicodeCodex.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Unicode.Overview",
    description:
      "List Unicode Codex tools and effective element count for an optional organization/project scope.",
    annotations: [read_only_hint: true],
    category: "Unicode"

  input do
    field :organization, :string,
      description: "Optional organization slug or UUID. Omit for global-only data."

    field :project, :string,
      description: "Optional project slug or UUID. Project rows override org/global rows."
  end

  alias NoizuPromptLingua.Domains.UnicodeCodex
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    with {:ok, org_id, project_id} <-
           Resolve.scope(Args.get(args, :organization), Args.get(args, :project)) do
      {:ok,
       %{
         domain: "Unicode Codex",
         subdomain: "unicode.tobor.locker",
         precedence: ["project", "organization", "global"],
         effective_element_count:
           UnicodeCodex.count(organization_id: org_id, project_id: project_id),
         tools: %{
           browse: ~w(Unicode.Search Unicode.Get Unicode.Related),
           special_usages: ~w(Unicode.SpecialUsage.List Unicode.SpecialUsage.Get)
         }
       }}
    else
      {:error, :org_not_found} -> {:error, "Organization not found"}
      {:error, :project_not_found} -> {:error, "Project not found"}
      {:error, :project_not_in_org} -> {:error, "Project does not belong to organization"}
    end
  end
end
