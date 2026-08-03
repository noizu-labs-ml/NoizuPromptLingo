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
    # MCP field DSL has no free-form :map; accept JSON object as string.
    field :external_ids, :string, description: "JSON object of external system ids (merged)"
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
      |> decode_external_ids()

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

  defp decode_external_ids(%{external_ids: raw} = attrs) when is_binary(raw) do
    case Jason.decode(raw) do
      {:ok, map} when is_map(map) -> Map.put(attrs, :external_ids, map)
      _ -> attrs
    end
  end

  defp decode_external_ids(%{"external_ids" => raw} = attrs) when is_binary(raw) do
    case Jason.decode(raw) do
      {:ok, map} when is_map(map) -> Map.put(attrs, "external_ids", map)
      _ -> attrs
    end
  end

  defp decode_external_ids(attrs), do: attrs
end
