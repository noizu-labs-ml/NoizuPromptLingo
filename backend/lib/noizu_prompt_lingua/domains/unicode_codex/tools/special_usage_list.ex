defmodule NoizuPromptLingua.Domains.UnicodeCodex.Tools.SpecialUsageList do
  use Noizu.MCP.Server.Tool,
    name: "Unicode.SpecialUsage.List",
    description: "List effective Unicode/NPL special usage definitions.",
    hidden: true,
    annotations: [read_only_hint: true],
    category: "Unicode.SpecialUsage"

  input do
    field :organization, :string,
      description: "Optional organization slug or UUID. Omit for global-only data."

    field :project, :string, description: "Optional project slug or UUID."
    field :query, :string, description: "Text search over slug, name, title, and description."
    field :topic, :string
    field :flag, :string
    field :include_shadowed, :boolean, default: false
  end

  alias NoizuPromptLingua.Domains.UnicodeCodex
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    with {:ok, org_id, project_id} <-
           Resolve.scope(Args.get(args, :organization), Args.get(args, :project)) do
      {:ok,
       UnicodeCodex.list_special_usages(
         organization_id: org_id,
         project_id: project_id,
         q: Args.get(args, :query),
         topic: Args.get(args, :topic),
         flag: Args.get(args, :flag),
         include_shadowed: Args.get(args, :include_shadowed)
       )}
    else
      {:error, :org_not_found} -> {:error, "Organization not found"}
      {:error, :project_not_found} -> {:error, "Project not found"}
      {:error, :project_not_in_org} -> {:error, "Project does not belong to organization"}
    end
  end
end
