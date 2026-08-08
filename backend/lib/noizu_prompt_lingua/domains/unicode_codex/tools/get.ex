defmodule NoizuPromptLingua.Domains.UnicodeCodex.Tools.Get do
  use Noizu.MCP.Server.Tool,
    name: "Unicode.Get",
    description:
      "Get one effective Unicode Codex element by slug, including safe display metadata and override layers.",
    hidden: true,
    annotations: [read_only_hint: true],
    category: "Unicode"

  input do
    field :slug, :string,
      required: true,
      description: "Unicode element slug, e.g. escape, bell, top-left-corner."

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
           UnicodeCodex.get_element(Args.get(args, :slug),
             organization_id: org_id,
             project_id: project_id
           ) do
      {:ok, result}
    else
      {:error, :not_found} -> {:error, "Unicode element not found"}
      {:error, :org_not_found} -> {:error, "Organization not found"}
      {:error, :project_not_found} -> {:error, "Project not found"}
      {:error, :project_not_in_org} -> {:error, "Project does not belong to organization"}
    end
  end
end
