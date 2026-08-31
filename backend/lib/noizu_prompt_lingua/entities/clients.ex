defmodule NoizuPromptLingua.Clients do
  @moduledoc """
  Clients — LOCAL app-DB shim (spec gap: TRP v1 has no clients endpoints; the
  former pm_core `clients` table is mirrored 1:1 into the NPL app DB by
  migration 20260831000000_create_clients). Facade API unchanged — when TRP
  grows a clients surface, this module is the switch point (reported to Loom).
  """

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Clients.Client

  import Ecto.Query

  def get(id), do: Repo.get(Client, id)

  def create(attrs, user_id \\ nil) do
    attrs = stringify(attrs)
    attrs = if user_id, do: Map.put(attrs, "created_by", user_id), else: attrs

    %Client{}
    |> Client.changeset(attrs)
    |> Repo.insert()
  end

  def update(id, attrs) do
    case Repo.get(Client, id) do
      nil ->
        {:error, :not_found}

      client ->
        client |> Client.changeset(stringify(attrs)) |> Repo.update()
    end
  end

  def list_for_org(organization_id, opts \\ []) do
    status = Keyword.get(opts, :status, "active")
    status = if status in [nil, "", "all"], do: nil, else: status

    from(c in Client,
      where: c.organization_id == ^organization_id,
      order_by: [asc: c.inserted_at]
    )
    |> then(fn q ->
      if status, do: where(q, [c], c.status == ^status), else: q
    end)
    |> Repo.all()
    |> case do
      list when is_list(list) -> list
      _ -> []
    end
  end

  def resolve(organization_id, slug_or_uuid) do
    case NoizuPromptLingua.UUID.cast(slug_or_uuid) do
      {:ok, uuid} -> Repo.get_by(Client, id: uuid, organization_id: organization_id)
      :error -> Repo.get_by(Client, slug: slug_or_uuid, organization_id: organization_id)
    end
  end

  def archive(id) do
    case Repo.get(Client, id) do
      nil ->
        {:error, :not_found}

      client ->
        client
        |> Client.changeset(%{status: "archived", archived_at: DateTime.utc_now()})
        |> Repo.update()
    end
  end

  defp stringify(attrs) when is_map(attrs) do
    Map.new(attrs, fn {k, v} -> {to_string(k), v} end)
  end
end
