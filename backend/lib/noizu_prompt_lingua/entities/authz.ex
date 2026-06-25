defmodule NoizuPromptLingua.Authz do
  # Ordinal role ladder (lower = higher privilege). 'lead' sits between admin and
  # member (ADR-015). MUST stay in sync with the role_name_enum DB values — see
  # role_ranks/0 + the authz_role_ranks_test sync guard.
  @role_ranks %{"owner" => 0, "admin" => 1, "lead" => 2, "member" => 3, "viewer" => 4}

  @doc "The ordinal role ladder map (role name => rank; lower = higher privilege)."
  def role_ranks, do: @role_ranks

  def check_permission(user_id, resource_type, resource_id, action) do
    sql = "SELECT check_user_permission($1::uuid, $2, $3::uuid, $4)"
    params = [uuid_to_bin(user_id), resource_type, uuid_to_bin(resource_id), action]

    case Ecto.Adapters.SQL.query(NoizuPromptLingua.Repo, sql, params) do
      {:ok, %{rows: [[result]]}} -> result == true
      _ -> false
    end
  end

  def get_user_role(user_id, resource_type, resource_id) do
    sql = "SELECT get_user_role_in_resource($1::uuid, $2, $3::uuid)"
    params = [uuid_to_bin(user_id), resource_type, uuid_to_bin(resource_id)]

    case Ecto.Adapters.SQL.query(NoizuPromptLingua.Repo, sql, params) do
      {:ok, %{rows: [[role]]}} -> role
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

  def explain_permission(user_id, resource_type, resource_id, action) do
    role = get_user_role(user_id, resource_type, resource_id)

    if is_nil(role) do
      %{allowed: false, reason: :not_a_member, matching_statements: []}
    else
      policies = get_effective_policies(user_id, resource_type, resource_id)
      NoizuPromptLingua.Authz.PolicyEvaluator.evaluate(
        policies, action, resource_type, resource_id, role,
        %{user_id: user_id}
      )
    end
  end

  defp get_effective_policies(user_id, resource_type, resource_id) do
    sql = """
    SELECT p.id, p.name, p.description, p.policy_document, p.is_system, gp.priority
    FROM scoped_memberships sm
    JOIN group_policies gp ON gp.group_id = sm.group_id
    JOIN policies p ON p.id = gp.policy_id AND p.is_active = true
    WHERE sm.member_type = 'user'
      AND sm.member_id = $1
      AND sm.resource_type = $2::resource_type_enum
      AND sm.resource_id = $3
      AND (sm.expires_at IS NULL OR sm.expires_at > NOW())
    ORDER BY gp.priority ASC
    """

    case Ecto.Adapters.SQL.query(NoizuPromptLingua.Repo, sql, [uuid_to_bin(user_id), resource_type, uuid_to_bin(resource_id)]) do
      {:ok, %{rows: rows, columns: cols}} ->
        Enum.map(rows, fn row -> Enum.zip(cols, row) |> Map.new() end)
      _ -> []
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
