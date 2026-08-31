defmodule NoizuPromptLingua.Projects do
  @moduledoc """
  Projects via the TRP shared-key plane (`/api/v1/organizations/:org_id/projects`,
  spec §4.2) through `NoizuPromptLingua.TRP` (read-through cache, write-bust).

  Identity note (spec gap): TRP v1 has no user-identity/membership surface for
  shared keys — the former `pm_user_snapshot`/`pm_org_snapshot` spine and
  per-user `role_name` have no counterpart. Writes are audited against the TRP
  service user; `list_for_user` returns key-scope projects with nil roles.
  """

  alias NoizuPromptLingua.TRP

  def create_with_owner(attrs, _user_id, _context \\ Noizu.Context.system()) do
    org_id = Map.get(attrs, :organization_id) || Map.get(attrs, "organization_id")
    do_create(org_id, attrs)
  end

  defp do_create({:error, _} = err, _attrs), do: err

  defp do_create(org_id, attrs) when is_binary(org_id) do
    attrs = Map.drop(attrs, [:organization_id, "organization_id"])

    case TRP.create_project(org_id, attrs) do
      {:ok, _} = ok -> ok
      {:error, _} = err -> err
    end
  end

  defp do_create(nil, _attrs), do: {:error, :trp_org_required}

  @doc """
  Projects visible to the caller. With an org, that org's project list; without,
  the union over the TRP key scope (spec §1.4 — the shared-key plane has no
  per-user filtering). Rows keep the legacy STRING-keyed shape.
  """
  def list_for_user(_user_id, organization_id \\ nil) do
    orgs =
      case organization_id do
        nil ->
          case TRP.list_organizations() do
            list when is_list(list) -> Enum.map(list, & &1.id)
            {:error, _} -> []
          end

        org_id ->
          [org_id]
      end

    orgs
    |> Enum.flat_map(fn org ->
      case TRP.list_projects(org) do
        rows when is_list(rows) -> Enum.map(rows, &TRP.Shapes.project_for_user/1)
        {:error, _} -> []
      end
    end)
  end

  def get_project(id), do: scan_orgs(fn org -> TRP.get_project(org, id) end)

  def update_project(id, attrs) do
    scan_orgs(fn org ->
      case TRP.update_project(org, id, attrs) do
        {:error, %NoizuPromptLingua.TRP.Error{status: 404}} -> {:error, :not_found}
        {:ok, _} = ok -> ok
        {:error, _} = err -> err
      end
    end)
  end

  # SPEC GAP (W0 §4.2): archive/unarchive are JWT-only on TRP v1 — no shared-key
  # surface. Explicit error; surfaced to callers as unsupported until W8/W9.
  def archive(_id), do: {:error, :trp_unsupported_shared_key}
  def unarchive(_id), do: {:error, :trp_unsupported_shared_key}

  def delete_project(id) do
    scan_orgs(fn org ->
      case TRP.delete_project(org, id) do
        {:ok, _} -> {:ok, nil}
        {:error, :not_found} -> {:error, :not_found}
        {:error, _} = err -> err
      end
    end)
  end

  # SPEC GAP (W0 §4.2): project members endpoints are JWT-only on TRP v1.
  # Memberships remain the app-DB scoped_memberships surface (local, DB-independent).
  def list_members(project_id) do
    NoizuPromptLingua.Authz.ScopedMemberships.list_for_resource("project", project_id)
  end

  defp scan_orgs(fun) do
    case TRP.list_organizations() do
      {:error, _} = err ->
        err

      orgs ->
        orgs
        |> Enum.reduce_while(nil, fn org, _acc ->
          case fun.(org.id) do
            nil -> {:cont, nil}
            {:error, %NoizuPromptLingua.TRP.Error{status: 404}} -> {:cont, nil}
            value -> {:halt, value}
          end
        end)
    end
  end
end
