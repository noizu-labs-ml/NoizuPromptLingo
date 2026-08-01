defmodule NoizuPromptLingua.MCP.Clients.Tools.ClientGet do
  use Noizu.MCP.Server.Tool,
    name: "Client.Get",
    description: "Get a client by UUID (or org + slug).",
    hidden: true,
    category: "Clients",
    annotations: [read_only_hint: true]

  alias NoizuPromptLingua.MCP.{Args, Resolve}

  input do
    field :id, :string, description: "Client UUID"
    field :organization, :string, description: "Org slug/UUID (required with slug)"
    field :slug, :string, description: "Client slug within organization"
  end

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)
    slug = Args.get(args, :slug)
    org_ref = Args.get(args, :organization)

    client =
      cond do
        is_binary(id) and id != "" ->
          NoizuPromptLingua.Clients.get(id)

        is_binary(slug) and slug != "" ->
          org_id = Resolve.organization_id(org_ref)
          org_id && NoizuPromptLingua.Clients.resolve(org_id, slug)

        true ->
          nil
      end

    case client do
      nil ->
        {:error, "Client not found"}

      c ->
        {:ok,
         %{
           id: c.id,
           name: c.name,
           slug: c.slug,
           status: c.status,
           organization_id: c.organization_id,
           notes: c.notes,
           currency: c.currency,
           default_hourly_rate_cents: c.default_hourly_rate_cents,
           external_ids: c.external_ids,
           settings: c.settings
         }}
    end
  end
end
