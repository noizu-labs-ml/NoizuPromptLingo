defmodule NoizuPromptLingua.Domains.UnicodeCodex.Tools.SpecialUsageGet do
  use Noizu.MCP.Server.Tool,
    name: "Unicode.SpecialUsage.Get",
    description: "Get one effective Unicode/NPL special usage definition by slug.",
    hidden: true,
    annotations: [read_only_hint: true],
    category: "Unicode.SpecialUsage"

  input do
    field :slug, :string, required: true, description: "Special usage slug."

    field :organization, :string,
      description: "Optional organization slug or UUID. Omit for global-only data."

    field :project, :string, description: "Optional project slug or UUID."
  end

  alias NoizuPromptLingua.Domains.UnicodeCodex
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    with {:ok, org_id, project_id} <-
           Resolve.scope(Args.get(args, :organization), Args.get(args, :project)),
         {:ok, result} <-
           UnicodeCodex.get_special_usage(Args.get(args, :slug),
             organization_id: org_id,
             project_id: project_id
           ) do
      {:ok, result}
    else
      {:error, :not_found} -> {:error, "Unicode special usage not found"}
      {:error, :org_not_found} -> {:error, "Organization not found"}
      {:error, :project_not_found} -> {:error, "Project not found"}
      {:error, :project_not_in_org} -> {:error, "Project does not belong to organization"}
    end
  end
end
