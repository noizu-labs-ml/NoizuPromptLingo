defmodule Noizu.PM.Users do
  @moduledoc """
  Shared users on `Noizu.PM.Repo`. Host apps call `ensure/1` so project/org
  membership FKs resolve when identity still lives primarily on the app DB.
  """
  alias Noizu.PM.Users.User, as: Entity
  alias Noizu.PM.Schema.Users.User, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)

  @doc """
  Ensure a user row exists on pm_core with the given UUID.

  `attrs` should include at least `:id` and `:email`. Extra fields (handle,
  user_name, status, role, …) are copied when present. Idempotent.
  """
  def ensure(attrs) when is_map(attrs) do
    id = fetch(attrs, :id)

    cond do
      is_nil(id) or id == "" ->
        {:error, :missing_id}

      true ->
        case Noizu.PM.Repo.get(Schema, id) do
          %Schema{} = user ->
            {:ok, user}

          nil ->
            params =
              %{
                email: fetch(attrs, :email) || "user-#{id}@pm-core.local",
                user_name: fetch(attrs, :user_name),
                handle: fetch(attrs, :handle),
                status: normalize_status(fetch(attrs, :status)),
                role: normalize_role(fetch(attrs, :role)),
                verified: fetch(attrs, :verified) || false,
                bio: fetch(attrs, :bio)
              }
              |> Enum.reject(fn {_k, v} -> is_nil(v) end)
              |> Map.new()

            %Schema{id: id}
            |> Schema.changeset(params)
            |> Noizu.PM.Repo.insert()
        end
    end
  end

  defp fetch(map, key) when is_atom(key) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key))
  end

  defp normalize_status(nil), do: :active
  defp normalize_status(s) when is_atom(s), do: s

  defp normalize_status(s) when is_binary(s) do
    try do
      String.to_existing_atom(s)
    rescue
      ArgumentError -> :active
    end
  end

  defp normalize_role(nil), do: :user
  defp normalize_role(r) when is_atom(r), do: r

  defp normalize_role(r) when is_binary(r) do
    try do
      String.to_existing_atom(r)
    rescue
      ArgumentError -> :user
    end
  end
end
