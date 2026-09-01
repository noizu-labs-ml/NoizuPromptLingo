defmodule NoizuPromptLingua.MCP.Organizations.Tools.OrganizationGet do
  use Noizu.MCP.Server.Tool,
    name: "Organization.Get",
    description: "Get an organization by slug or UUID.",
    hidden: false,
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
      nil ->
        {:error, "Organization '#{ref}' not found"}

      org ->
        # Post-TRP-cutover (W4) orgs are `Shapes.organization` maps
        # (id/slug/name/role/owner); the legacy pm_core schema's `settings`
        # map has no TRP shared-key counterpart (spec §4.1), so the key is
        # preserved with a %{} default instead of dropped — the MCP response
        # shape stays stable and dot-access never crashes on the new shape.
        {:ok,
         %{
           id: org.id,
           name: org.name,
           slug: org.slug,
           settings: Map.get(org, :settings, %{}),
           role: Map.get(org, :role),
           owner: Map.get(org, :owner)
         }}
    end
  end
end
