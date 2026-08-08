defmodule NoizuPromptLingua.Domains.UnicodeCodex.Tools.Search do
  use Noizu.MCP.Server.Tool,
    name: "Unicode.Search",
    description:
      "Search effective Unicode Codex elements by text, topic, flag, special usage, or printable/control status.",
    hidden: true,
    annotations: [read_only_hint: true],
    category: "Unicode"

  input do
    field :organization, :string,
      description: "Optional organization slug or UUID. Omit for global-only data."

    field :project, :string, description: "Optional project slug or UUID."

    field :query, :string,
      description: "Text search over slug, name, title, description, aliases, and search terms."

    field :topic, :string, description: "Filter by one topic slug."
    field :flag, :string, description: "Filter by one flag slug."
    field :usage, :string, description: "Filter by special usage slug."
    field :printable, :boolean, description: "Filter printable vs non-printable entries."

    field :include_shadowed, :boolean,
      default: false,
      description: "Return all matching layers instead of only the effective row per slug."

    field :limit, :integer, default: 100
    field :offset, :integer, default: 0
  end

  alias NoizuPromptLingua.Domains.UnicodeCodex
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    with {:ok, org_id, project_id} <-
           Resolve.scope(Args.get(args, :organization), Args.get(args, :project)) do
      {:ok,
       UnicodeCodex.list_elements(
         organization_id: org_id,
         project_id: project_id,
         q: Args.get(args, :query),
         topic: Args.get(args, :topic),
         flag: Args.get(args, :flag),
         usage: Args.get(args, :usage),
         printable: Args.get(args, :printable),
         include_shadowed: Args.get(args, :include_shadowed),
         limit: Args.get(args, :limit),
         offset: Args.get(args, :offset)
       )}
    else
      {:error, :org_not_found} -> {:error, "Organization not found"}
      {:error, :project_not_found} -> {:error, "Project not found"}
      {:error, :project_not_in_org} -> {:error, "Project does not belong to organization"}
    end
  end
end
