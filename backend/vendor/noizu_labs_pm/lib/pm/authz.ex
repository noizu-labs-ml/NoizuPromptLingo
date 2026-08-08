defmodule Noizu.PM.Authz do
  @moduledoc """
  PBAC helpers against `Noizu.PM.Repo` (pm_core).
  Mirrors host-app Authz modules so dual-path can call one implementation.
  """

  @role_ranks %{
    "owner" => 0,
    "admin" => 1,
    "lead" => 2,
    "member" => 3,
    "viewer" => 4
  }

  def role_ranks, do: @role_ranks

  def check_permission(user_id, resource_type, resource_id, action) do
    sql = "SELECT check_user_permission($1::uuid, $2, $3::uuid, $4)"

    params = [
      uuid_to_bin(user_id),
      resource_type,
      uuid_to_bin(resource_id),
      action
    ]

    case Ecto.Adapters.SQL.query(Noizu.PM.Repo, sql, params) do
      {:ok, %{rows: [[result]]}} -> result == true
      _ -> false
    end
  end

  def get_user_role(user_id, resource_type, resource_id) do
    sql = "SELECT get_user_role_in_resource($1::uuid, $2, $3::uuid)"
    params = [uuid_to_bin(user_id), resource_type, uuid_to_bin(resource_id)]

    case Ecto.Adapters.SQL.query(Noizu.PM.Repo, sql, params) do
      {:ok, %{rows: [[role]]}} when is_binary(role) -> role
      {:ok, %{rows: [[role]]}} when not is_nil(role) -> to_string(role)
      _ -> nil
    end
  end

  def authorize(user_id, resource_type, resource_id, required_role) do
    case get_user_role(user_id, resource_type, resource_id) do
      nil ->
        {:error, :not_a_member}

      role ->
        if Map.get(@role_ranks, role, 99) <= Map.get(@role_ranks, required_role, 99) do
          {:ok, %{role: role, resource_type: resource_type, resource_id: resource_id}}
        else
          {:error, :insufficient_role}
        end
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
