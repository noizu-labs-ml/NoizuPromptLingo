defmodule NoizuPromptLingua.MCP.Organizations.Tools.OrganizationGet do
  use Noizu.MCP.Server.Tool,
    name: "Organization.Get",
    description: "Get an organization by slug or UUID.",
    hidden: true,
    category: "Organizations",
    annotations: [read_only_hint: true]

  alias NoizuPromptLingua.MCP.{Args, Resolve}

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
  end

  @impl true
  def call(args, _ctx) do
    ref = Args.get(args, :organization)

    case Resolve.organization(ref) do
      nil -> {:error, "Organization '#{ref}' not found"}
      org -> {:ok, %{id: org.id, name: org.name, slug: org.slug, settings: org.settings}}
    end
  end
end
