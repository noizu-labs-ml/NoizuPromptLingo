defmodule NoizuPromptLingua.MCP.Clients.Tools.ClientCreate do
  use Noizu.MCP.Server.Tool,
    name: "Client.Create",
    description: "Create a client (customer) under an organization.",
    hidden: true,
    category: "Clients"

  alias NoizuPromptLingua.MCP.{Args, Resolve}

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
    field :name, :string, required: true, description: "Client display name"
    field :slug, :string, required: true, description: "URL slug unique within the org"
    field :notes, :string, description: "Optional notes"
    field :currency, :string, description: "ISO currency (default USD)"
    field :default_hourly_rate_cents, :integer, description: "Optional default rate in cents"
  end

  @impl true
  def call(args, ctx) do
    org_ref = Args.get(args, :organization)
    user_id = Resolve.current_user_id(ctx)

    with {:org, org_id} when not is_nil(org_id) <- {:org, Resolve.organization_id(org_ref)} do
      attrs =
        args
        |> Args.take([:name, :slug, :notes, :currency, :default_hourly_rate_cents])
        |> Map.put(:organization_id, org_id)

      case NoizuPromptLingua.Clients.create(attrs, user_id) do
        {:ok, client} ->
          {:ok, client_payload(client)}

        {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
          {:error, "Failed: #{inspect(changeset.errors)}"}

        {:error, reason} ->
          {:error, "Failed: #{inspect(reason)}"}
      end
    else
      {:org, _} -> {:error, "Organization '#{org_ref}' not found"}
    end
  end

  defp client_payload(c) do
    %{
      id: c.id,
      name: c.name,
      slug: c.slug,
      status: c.status,
      organization_id: c.organization_id,
      notes: c.notes,
      currency: c.currency,
      external_ids: c.external_ids
    }
  end
end
