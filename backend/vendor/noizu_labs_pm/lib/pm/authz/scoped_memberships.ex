defmodule Noizu.PM.Authz.ScopedMemberships do
  @moduledoc """
  Scoped membership operations on `Noizu.PM.Repo` (pm_core).
  Uses the same stored procedures as NPL/TRP app DBs (`add_scoped_member`, etc.).
  """
  alias Noizu.PM.Authz.ScopedMemberships.ScopedMembership, as: Entity
  alias Noizu.PM.Schema.Authz.ScopedMembership, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)

  import Ecto.Query

  @member_roles ~w(owner admin lead member viewer)

  def add_member(resource_type, resource_id, user_id, role_name, added_by \\ nil) do
    sql = "SELECT * FROM add_scoped_member($1, $2::uuid, $3::uuid, $4, $5::uuid)"

    params = [
      resource_type,
      uuid_to_bin(resource_id),
      uuid_to_bin(user_id),
      role_name,
      uuid_to_bin(added_by)
    ]

    case Ecto.Adapters.SQL.query(Noizu.PM.Repo, sql, params) do
      {:ok, %{rows: [row], columns: cols}} ->
        {:ok, Enum.zip(cols, row) |> Map.new()}

      {:error, %Postgrex.Error{postgres: %{code: :raise_exception, message: msg}}} ->
        {:error, parse_error(msg)}

      {:error, other} ->
        {:error, other}
    end
  end

  def update_role(resource_type, resource_id, user_id, new_role_name) do
    sql = "SELECT * FROM update_scoped_member_role($1, $2::uuid, $3::uuid, $4)"
    params = [resource_type, uuid_to_bin(resource_id), uuid_to_bin(user_id), new_role_name]

    case Ecto.Adapters.SQL.query(Noizu.PM.Repo, sql, params) do
      {:ok, %{rows: [row], columns: cols}} ->
        {:ok, Enum.zip(cols, row) |> Map.new()}

      {:error, %Postgrex.Error{postgres: %{code: :raise_exception, message: msg}}} ->
        {:error, parse_error(msg)}

      {:error, other} ->
        {:error, other}
    end
  end

  def remove_member(resource_type, resource_id, user_id) do
    sql = "SELECT * FROM remove_scoped_member_safe($1, $2::uuid, $3::uuid)"
    params = [resource_type, uuid_to_bin(resource_id), uuid_to_bin(user_id)]

    case Ecto.Adapters.SQL.query(Noizu.PM.Repo, sql, params) do
      {:ok, %{rows: [row], columns: cols}} ->
        {:ok, Enum.zip(cols, row) |> Map.new()}

      {:error, %Postgrex.Error{postgres: %{code: :raise_exception, message: msg}}} ->
        {:error, parse_error(msg)}

      {:error, other} ->
        {:error, other}
    end
  end

  def list_for_resource(resource_type, resource_id, opts \\ []) do
    from(sm in Schema,
      join: g in Noizu.PM.Schema.Authz.Group,
      on: g.id == sm.group_id,
      left_join: u in Noizu.PM.Schema.Users.User,
      on: sm.member_type == "user" and u.id == sm.member_id,
      where: sm.resource_type == ^resource_type and sm.resource_id == ^resource_id,
      where: sm.member_type == "user",
      where: is_nil(sm.expires_at) or sm.expires_at > ^DateTime.utc_now(),
      select: %{
        id: sm.id,
        member_type: sm.member_type,
        member_id: sm.member_id,
        user_id: u.id,
        email: u.email,
        user_name: u.user_name,
        display_name: fragment("coalesce(?, ?)", u.user_name, u.email),
        role: g.name,
        resource_type: sm.resource_type,
        resource_id: sm.resource_id,
        joined_at: sm.created_at,
        expires_at: sm.expires_at
      }
    )
    |> maybe_role_filter(opts[:role])
    |> Noizu.PM.Repo.all()
  end

  def member_roles, do: @member_roles

  defp maybe_role_filter(query, nil), do: query

  defp maybe_role_filter(query, role) when is_binary(role) do
    from([sm, g, u] in query, where: g.name == ^role)
  end

  defp maybe_role_filter(query, roles) when is_list(roles) do
    from([sm, g, u] in query, where: g.name in ^roles)
  end

  defp maybe_role_filter(query, _), do: query

  defp parse_error(msg) when is_binary(msg) do
    cond do
      String.contains?(msg, "invalid_role") -> :invalid_role
      String.contains?(msg, "already_member") -> :already_member
      String.contains?(msg, "not_a_member") -> :not_a_member
      String.contains?(msg, "sole_owner") -> :sole_owner
      true -> {:postgres, msg}
    end
  end

  defp uuid_to_bin(nil), do: nil

  defp uuid_to_bin(uuid) when is_binary(uuid) do
    case Ecto.UUID.dump(uuid) do
      {:ok, bin} -> bin
      :error -> uuid
    end
  end
end
