defmodule TheRobotWarsWeb.PolicyController do
  use TheRobotWarsWeb, :controller

  alias TheRobotWars.Authz
  alias TheRobotWars.Authz.Policies

  def index(conn, params) do
    opts = if params["system_only"] == "true", do: [system_only: true], else: []
    policies = Policies.list_active(opts)
    json(conn, %{policies: Enum.map(policies, &policy_to_json/1)})
  end

  def create(conn, %{"policy" => attrs}) do
    case Policies.create_policy(attrs) do
      {:ok, policy} ->
        conn |> put_status(:created) |> json(%{policy: policy_to_json(policy)})
      {:error, changeset} when is_struct(changeset, Ecto.Changeset) ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  def show(conn, %{"id" => id}) do
    case TheRobotWars.Repo.get(TheRobotWars.Schema.Authz.Policy, id) do
      nil -> conn |> put_status(:not_found) |> json(%{error: "Policy not found"})
      policy -> json(conn, %{policy: policy_to_json(policy)})
    end
  end

  def update(conn, %{"id" => id, "policy" => attrs}) do
    case Policies.update_policy(id, attrs) do
      {:ok, policy} -> json(conn, %{policy: policy_to_json(policy)})
      {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Policy not found"})
      {:error, :cannot_modify_system_policy} -> conn |> put_status(:forbidden) |> json(%{error: "Cannot modify system policy"})
      {:error, changeset} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    case Policies.delete_policy(id) do
      {:ok, _} -> json(conn, %{message: "Policy deleted"})
      {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Policy not found"})
      {:error, :cannot_delete_system_policy} -> conn |> put_status(:forbidden) |> json(%{error: "Cannot delete system policy"})
    end
  end

  def check(conn, %{"resource_type" => resource_type, "resource_id" => resource_id, "action" => action}) do
    user_id = get_user_id(conn)
    allowed = Authz.check_permission(user_id, resource_type, resource_id, action)
    json(conn, %{allowed: allowed, action: action, resource_type: resource_type, resource_id: resource_id})
  end

  def explain(conn, %{"resource_type" => resource_type, "resource_id" => resource_id, "action" => action}) do
    user_id = get_user_id(conn)
    result = Authz.explain_permission(user_id, resource_type, resource_id, action)
    json(conn, result)
  end

  def my_policies(conn, _params) do
    user_id = get_user_id(conn)
    policies = Policies.list_user_policies(user_id)
    json(conn, %{policies: policies})
  end

  def attach_to_user(conn, %{"user_id" => target_user_id, "policy_id" => policy_id} = params) do
    opts = [
      resource_type: params["resource_type"],
      resource_id: params["resource_id"],
      priority: params["priority"] || 0
    ]

    case Policies.attach_to_user(target_user_id, policy_id, opts) do
      {:ok, _} -> conn |> put_status(:created) |> json(%{message: "Policy attached"})
      {:error, changeset} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  def detach_from_user(conn, %{"user_id" => target_user_id, "policy_id" => policy_id}) do
    case Policies.detach_from_user(target_user_id, policy_id) do
      {:ok, _} -> json(conn, %{message: "Policy detached"})
      {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Policy attachment not found"})
    end
  end

  defp get_user_id(conn) do
    case TheRobotWars.Guardian.Plug.current_resource(conn) do
      %TheRobotWars.Users.Sessions.UserSession{user: {:ref, _, id}} -> id
      %TheRobotWars.Users.Sessions.UserSession{user: %{id: id}} -> id
      _ -> nil
    end
  end

  defp policy_to_json(policy) do
    %{
      id: policy.id,
      name: policy.name,
      description: policy.description,
      policy_document: policy.policy_document,
      is_system: policy.is_system,
      is_active: policy.is_active
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
