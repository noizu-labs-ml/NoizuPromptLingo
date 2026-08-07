defmodule NoizuPromptLingua.Authz.Pdp.Local do
  @moduledoc """
  In-process three-axis PDP (SpiceDB schema semantics without the network).

  ## Axes

  1. **User entitlements** — `Authz.authorize/4` when resource + required_role given
  2. **Client capability** — OAuth client must be `active` (axis 2 stub; full
     per-server allow lists land with catalog seed)
  3. **Pairing grant** — `grant_id` active, or active grant for `(user, client, resource)`
  """

  @behaviour NoizuPromptLingua.Authz.Pdp

  alias NoizuPromptLingua.Authz
  alias NoizuPromptLingua.OAuth.{Clients, Grants}

  @impl true
  def check(req) when is_map(req) do
    with :ok <- axis_client(req),
         :ok <- axis_grant(req),
         :ok <- axis_user(req) do
      :ok
    end
  end

  # Axis 2 — client registration active
  defp axis_client(%{client_id: client_id}) when is_binary(client_id) and client_id != "" do
    case Clients.get_active(client_id) do
      nil -> {:error, :client_not_allowed}
      _ -> :ok
    end
  end

  # Legacy API-key JWTs have no client_id — synthetic full access
  defp axis_client(_), do: :ok

  # Axis 3 — pairing grant
  defp axis_grant(%{grant_id: grant_id}) when is_binary(grant_id) and grant_id != "" do
    case Grants.get_active(grant_id) do
      nil -> {:error, :grant_revoked}
      _ -> :ok
    end
  end

  defp axis_grant(%{user_id: user_id, client_id: client_id, resource: resource})
       when is_binary(user_id) and is_binary(client_id) and is_binary(resource) and
              resource != "" do
    case Grants.find_active(user_id, client_id, resource) do
      nil ->
        # OAuth without stored grant yet: allow if client is first-party OR
        # there is any active grant for this client+user (resource expansion).
        case Grants.list_for_user(user_id) do
          grants ->
            if Enum.any?(grants, &(&1.client_id == client_id)) do
              :ok
            else
              # Token exchange / code flow always creates grants; missing grant = deny
              # for OAuth clients. API-key path has no client_id (handled above).
              {:error, :no_pairing_grant}
            end
        end

      _ ->
        :ok
    end
  end

  # No grant context (pure API-key JWT) — axis 3 N/A
  defp axis_grant(_), do: :ok

  # Axis 1 — user role on resource
  defp axis_user(%{user_id: user_id, resource_type: rtype, resource_id: rid, required_role: role})
       when is_binary(user_id) and not is_nil(rtype) and is_binary(rid) and rid != "" do
    rtype_atom = to_resource_type(rtype)
    role_atom = to_role(role)

    case Authz.authorize(user_id, rtype_atom, rid, role_atom) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  defp axis_user(%{user_id: user_id}) when is_binary(user_id), do: :ok
  defp axis_user(_), do: {:error, :no_identity}

  defp to_resource_type(t) when is_atom(t), do: t
  defp to_resource_type("organization"), do: :organization
  defp to_resource_type("project"), do: :project
  defp to_resource_type(t) when is_binary(t), do: String.to_existing_atom(t)
  defp to_resource_type(_), do: :organization

  defp to_role(r) when is_atom(r), do: r
  defp to_role("viewer"), do: :viewer
  defp to_role("member"), do: :member
  defp to_role("lead"), do: :lead
  defp to_role("admin"), do: :admin
  defp to_role("owner"), do: :owner
  defp to_role(_), do: :member
end
