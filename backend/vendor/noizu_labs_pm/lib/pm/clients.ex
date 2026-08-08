defmodule Noizu.PM.Clients do
  @moduledoc """
  Shared client domain on `Noizu.PM.Repo` (pm_core).
  Clients nest under organizations; projects optionally under clients.
  """
  alias Noizu.PM.Schema.Clients.Client, as: Schema
  import Ecto.Query

  def get(id), do: Noizu.PM.Repo.get(Schema, id)

  def create(attrs, user_id \\ nil) do
    attrs =
      attrs
      |> stringify_keys_if_needed()
      |> maybe_put_created_by(user_id)

    %Schema{}
    |> Schema.changeset(attrs)
    |> Noizu.PM.Repo.insert()
  end

  def create_with_owner(attrs, user_id) do
    create(attrs, user_id)
  end

  def update_client(id, attrs) do
    case get(id) do
      nil ->
        {:error, :not_found}

      client ->
        client
        |> Schema.changeset(attrs)
        |> Noizu.PM.Repo.update()
    end
  end

  # Alias kept for host call sites.
  def update(id, attrs), do: update_client(id, attrs)

  def archive(id) do
    update_client(id, %{status: "archived", archived_at: DateTime.utc_now()})
  end

  def unarchive(id) do
    update_client(id, %{status: "active", archived_at: nil})
  end

  def soft_delete(id) do
    update_client(id, %{status: "deleted"})
  end

  def list_for_org(organization_id, opts \\ []) do
    status = Keyword.get(opts, :status, "active")

    q =
      from(c in Schema,
        where: c.organization_id == ^organization_id,
        order_by: [desc: c.inserted_at]
      )

    q =
      if status in [nil, "", "all"] do
        q
      else
        from(c in q, where: c.status == ^status)
      end

    Noizu.PM.Repo.all(q)
  end

  def get_id_by_slug(organization_id, slug) when is_binary(slug) do
    from(c in Schema,
      where: c.organization_id == ^organization_id and c.slug == ^slug,
      select: c.id
    )
    |> Noizu.PM.Repo.one()
  end

  def resolve(organization_id, slug_or_uuid) do
    cond do
      is_nil(slug_or_uuid) ->
        nil

      uuid?(slug_or_uuid) ->
        get(slug_or_uuid)

      is_binary(slug_or_uuid) ->
        case get_id_by_slug(organization_id, slug_or_uuid) do
          nil -> nil
          id -> get(id)
        end

      true ->
        nil
    end
  end

  defp maybe_put_created_by(attrs, nil), do: attrs

  defp maybe_put_created_by(attrs, user_id) do
    Map.put_new(attrs, :created_by, user_id)
  end

  defp stringify_keys_if_needed(attrs) when is_map(attrs) do
    # Accept string or atom keys for MCP/HTTP edges.
    Map.new(attrs, fn
      {k, v} when is_binary(k) ->
        try do
          {String.to_existing_atom(k), v}
        rescue
          ArgumentError -> {k, v}
        end

      {k, v} ->
        {k, v}
    end)
  end

  defp uuid?(s) when is_binary(s) do
    case Ecto.UUID.cast(s) do
      {:ok, _} -> true
      :error -> false
    end
  end

  defp uuid?(_), do: false
end
