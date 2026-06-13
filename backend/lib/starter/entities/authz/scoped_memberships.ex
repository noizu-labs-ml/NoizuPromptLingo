defmodule Starter.Authz.ScopedMemberships do
  alias Starter.Authz.ScopedMemberships.ScopedMembership, as: Entity
  alias Starter.Schema.Authz.ScopedMembership, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)

  import Ecto.Query

  def add_member(resource_type, resource_id, user_id, role_name, added_by \\ nil) do
    sql = "SELECT * FROM add_scoped_member($1, $2::uuid, $3::uuid, $4, $5::uuid)"
    params = [resource_type, uuid_to_bin(resource_id), uuid_to_bin(user_id), role_name, uuid_to_bin(added_by)]

    case Ecto.Adapters.SQL.query(Starter.Repo, sql, params) do
      {:ok, %{rows: [row], columns: cols}} ->
        {:ok, Enum.zip(cols, row) |> Map.new()}
      {:error, %Postgrex.Error{postgres: %{code: :raise_exception, message: msg}}} ->
        {:error, parse_error(msg)}
    end
  end

  def update_role(resource_type, resource_id, user_id, new_role_name) do
    sql = "SELECT * FROM update_scoped_member_role($1, $2::uuid, $3::uuid, $4)"
    params = [resource_type, uuid_to_bin(resource_id), uuid_to_bin(user_id), new_role_name]

    case Ecto.Adapters.SQL.query(Starter.Repo, sql, params) do
      {:ok, %{rows: [row], columns: cols}} ->
        {:ok, Enum.zip(cols, row) |> Map.new()}
      {:error, %Postgrex.Error{postgres: %{code: :raise_exception, message: msg}}} ->
        {:error, parse_error(msg)}
    end
  end

  def remove_member(resource_type, resource_id, user_id) do
    sql = "SELECT * FROM remove_scoped_member_safe($1, $2::uuid, $3::uuid)"
    params = [resource_type, uuid_to_bin(resource_id), uuid_to_bin(user_id)]

    case Ecto.Adapters.SQL.query(Starter.Repo, sql, params) do
      {:ok, %{rows: [row], columns: cols}} ->
        {:ok, Enum.zip(cols, row) |> Map.new()}
      {:error, %Postgrex.Error{postgres: %{code: :raise_exception, message: msg}}} ->
        {:error, parse_error(msg)}
    end
  end

  def list_for_resource(resource_type, resource_id) do
    from(sm in Schema,
      join: g in Starter.Schema.Authz.Group, on: g.id == sm.group_id,
      join: u in Starter.Schema.Users.User, on: u.id == sm.member_id,
      where: sm.resource_type == ^resource_type and sm.resource_id == ^resource_id and sm.member_type == "user",
      where: is_nil(sm.expires_at) or sm.expires_at > ^DateTime.utc_now(),
      select: %{
        id: sm.id,
        user_id: u.id,
        email: u.email,
        user_name: u.user_name,
        role: g.name,
        joined_at: sm.created_at,
        expires_at: sm.expires_at
      }
    )
    |> Starter.Repo.all()
  end

  def list_for_user(user_id) do
    from(sm in Schema,
      join: g in Starter.Schema.Authz.Group, on: g.id == sm.group_id,
      where: sm.member_type == "user" and sm.member_id == ^user_id,
      where: is_nil(sm.expires_at) or sm.expires_at > ^DateTime.utc_now(),
      select: %{
        id: sm.id,
        resource_type: sm.resource_type,
        resource_id: sm.resource_id,
        role: g.name,
        joined_at: sm.created_at,
        expires_at: sm.expires_at
      }
    )
    |> Starter.Repo.all()
  end

  defp parse_error(msg) do
    cond do
      String.contains?(msg, "invalid_role") -> :invalid_role
      String.contains?(msg, "already_member") -> :already_member
      String.contains?(msg, "not_found") -> :not_found
      String.contains?(msg, "sole_owner") -> :sole_owner
      true -> {:unknown, msg}
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
