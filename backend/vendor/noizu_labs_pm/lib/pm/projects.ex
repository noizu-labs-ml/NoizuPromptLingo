defmodule Noizu.PM.Projects do
  @moduledoc """
  Shared project domain operations on `Noizu.PM.Repo` (pm_core).
  Host apps dual-path create/list/archive through this module when `PM_CORE_ENABLED`.
  """
  alias Noizu.PM.Projects.Project, as: Entity
  alias Noizu.PM.Schema.Projects.Project, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)

  @doc """
  Insert a project and grant the creating user owner membership (same txn).

  Optional `opts`:
  - `:ensure_user` — map of user attrs (`:id` required) to upsert on pm_core first
  - `:ensure_org` — map of org attrs (`:id` required) to upsert on pm_core first
  """
  def create_with_owner(attrs, user_id, opts \\ []) do
    Noizu.PM.Repo.transaction(fn ->
      with :ok <- maybe_ensure_user(opts[:ensure_user]),
           :ok <- maybe_ensure_org(opts[:ensure_org]),
           {:ok, project} <-
             %Schema{}
             |> Schema.changeset(Map.put(attrs, :created_by, user_id))
             |> Noizu.PM.Repo.insert(),
           {:ok, _membership} <-
             Noizu.PM.Authz.ScopedMemberships.add_member(
               "project",
               project.id,
               user_id,
               "owner"
             ) do
        project
      else
        {:error, reason} -> Noizu.PM.Repo.rollback(reason)
      end
    end)
  end

  defp maybe_ensure_user(nil), do: :ok

  defp maybe_ensure_user(attrs) when is_map(attrs) do
    case Noizu.PM.Users.ensure(attrs) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  defp maybe_ensure_org(nil), do: :ok

  defp maybe_ensure_org(attrs) when is_map(attrs) do
    case Noizu.PM.Organizations.ensure(attrs) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end


  def get_project(id), do: Noizu.PM.Repo.get(Schema, id)

  def update_project(id, attrs) do
    case Noizu.PM.Repo.get(Schema, id) do
      nil ->
        {:error, :not_found}

      project ->
        project
        |> Schema.changeset(attrs)
        |> Noizu.PM.Repo.update()
    end
  end

  def archive(id) do
    update_project(id, %{status: "archived", archived_at: DateTime.utc_now()})
  end

  def unarchive(id) do
    update_project(id, %{status: "active", archived_at: nil})
  end

  def soft_delete(id) do
    update_project(id, %{status: "deleted"})
  end

  @doc """
  List projects accessible to the user (direct or org-inherited membership).
  Returns maps with string keys matching host list_for_user consumers.
  """
  def list_for_user(user_id, organization_id \\ nil) do
    sql = """
    SELECT id::text AS id,
           organization_id::text AS organization_id,
           name, slug, description, status,
           created_at, role_name, inherited_from_org,
           default_methodology, key_prefix
    FROM list_user_accessible_projects($1::uuid, $2::uuid)
    """

    params = [uuid_to_bin(user_id), uuid_to_bin(organization_id)]

    case Ecto.Adapters.SQL.query(Noizu.PM.Repo, sql, params) do
      {:ok, %{rows: rows, columns: cols}} ->
        Enum.map(rows, fn row ->
          Enum.zip(cols, row) |> Map.new()
        end)

      _ ->
        []
    end
  end

  def list_members(project_id) do
    Noizu.PM.Authz.ScopedMemberships.list_for_resource("project", project_id)
  end

  defp uuid_to_bin(nil), do: nil

  defp uuid_to_bin(uuid) when is_binary(uuid) do
    case Ecto.UUID.dump(uuid) do
      {:ok, bin} -> bin
      :error -> uuid
    end
  end
end
