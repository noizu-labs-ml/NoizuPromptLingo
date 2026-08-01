defmodule NoizuPromptLingua.MCP.Clients.Tools.ClientUpdate do
  use Noizu.MCP.Server.Tool,
    name: "Client.Update",
    description: "Update a client by UUID.",
    hidden: true,
    category: "Clients"

  alias NoizuPromptLingua.MCP.Args

  input do
    field :id, :string, required: true, description: "Client UUID"
    field :name, :string
    field :slug, :string
    field :notes, :string
    field :status, :string, description: "active|archived|deleted"
    field :currency, :string
    field :default_hourly_rate_cents, :integer
    field :external_ids, :map, description: "Merge map of external system ids"
  end

  @impl true
  def call(args, _ctx) do
    id = Args.get(args, :id)

    attrs =
      args
      |> Args.take([
        :name,
        :slug,
        :notes,
        :status,
        :currency,
        :default_hourly_rate_cents,
        :external_ids
      ])
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Map.new()

    case NoizuPromptLingua.Clients.update(id, attrs) do
      {:ok, client} ->
        {:ok,
         %{
           id: client.id,
           name: client.name,
           slug: client.slug,
           status: client.status,
           organization_id: client.organization_id,
           external_ids: client.external_ids
         }}

      {:error, :not_found} ->
        {:error, "Client not found"}

      {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
        {:error, "Failed: #{inspect(changeset.errors)}"}

      {:error, reason} ->
        {:error, "Failed: #{inspect(reason)}"}
    end
  end
end
