defmodule NoizuPromptLingua.Projects do
  alias NoizuPromptLingua.Projects.Project, as: Entity
  alias NoizuPromptLingua.Schema.Projects.Project, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)

  import Ecto.Query

  def create_with_owner(attrs, user_id, _context \\ Noizu.Context.system()) do
    case NoizuPromptLingua.PMCore.with_pm(fn ->
           Noizu.PM.Projects.create_with_owner(attrs, user_id,
             ensure_user: pm_user_snapshot(user_id),
             ensure_org: pm_org_snapshot(attrs)
           )
         end) do
      {:legacy, _} -> create_with_owner_legacy(attrs, user_id)
      other -> other
    end
  end

  # Wire identity spine onto pm_core before project insert (FK + membership).
  defp pm_user_snapshot(user_id) do
    case NoizuPromptLingua.Repo.get(NoizuPromptLingua.Schema.Users.User, user_id) do
      nil -> %{id: user_id, email: "user-#{user_id}@tobor.locker"}
      u ->
        %{
          id: u.id,
          email: u.email,
          user_name: u.user_name,
          handle: u.handle,
          status: u.status,
          role: u.role,
          verified: u.verified,
          bio: u.bio
        }
    end
  end

  defp pm_org_snapshot(attrs) do
    org_id = Map.get(attrs, :organization_id) || Map.get(attrs, "organization_id")

    case org_id && NoizuPromptLingua.Repo.get(NoizuPromptLingua.Schema.Organizations.Organization, org_id) do
      nil when is_binary(org_id) -> %{id: org_id}
      nil -> nil
      o -> %{id: o.id, slug: o.slug, name: o.name, settings: o.settings, key_prefix: Map.get(o, :key_prefix)}
    end
  end

  defp create_with_owner_legacy(attrs, user_id) do
    NoizuPromptLingua.Repo.transaction(fn ->
      with {:ok, project} <-
             %Schema{}
             |> Schema.changeset(Map.put(attrs, :created_by, user_id))
             |> NoizuPromptLingua.Repo.insert(),
           {:ok, _membership} <-
             NoizuPromptLingua.Authz.ScopedMemberships.add_member(
               "project",
               project.id,
               user_id,
               "owner"
             ) do
        project
      else
        {:error, reason} -> NoizuPromptLingua.Repo.rollback(reason)
      end
    end)
  end

  def list_for_user(user_id, organization_id \\ nil) do
    case NoizuPromptLingua.PMCore.with_pm(fn ->
           Noizu.PM.Projects.list_for_user(user_id, organization_id)
         end) do
      {:legacy, _} -> list_for_user_legacy(user_id, organization_id)
      rows when is_list(rows) -> rows
      _ -> []
    end
  end

  defp list_for_user_legacy(user_id, organization_id) do
    sql = "SELECT * FROM list_user_accessible_projects($1::uuid, $2::uuid)"
    params = [uuid_to_bin(user_id), uuid_to_bin(organization_id)]

    case Ecto.Adapters.SQL.query(NoizuPromptLingua.Repo, sql, params) do
      {:ok, %{rows: rows, columns: cols}} ->
        Enum.map(rows, fn row ->
          Enum.zip(cols, row)
          |> Enum.map(fn {col, val} -> {col, decode_uuid(col, val)} end)
          |> Map.new()
        end)

      _ ->
        []
    end
  end

  @uuid_columns ~w(id organization_id)
  defp decode_uuid(col, val) when col in @uuid_columns, do: decode_value(val)
  defp decode_uuid(_col, val), do: val

  defp decode_value(nil), do: nil

  defp decode_value(<<_::binary-16>> = bin) do
    case Ecto.UUID.load(bin) do
      {:ok, uuid} -> uuid
      :error -> bin
    end
  end

  defp decode_value(val), do: val

  defp uuid_to_bin(nil), do: nil

  defp uuid_to_bin(uuid) when is_binary(uuid) do
    case Ecto.UUID.dump(uuid) do
      {:ok, bin} -> bin
      :error -> uuid
    end
  end

  def get_project(id) do
    case NoizuPromptLingua.PMCore.with_pm(fn -> Noizu.PM.Projects.get_project(id) end) do
      {:legacy, _} -> NoizuPromptLingua.Repo.get(Schema, id)
      other -> other
    end
  end

  def update_project(id, attrs) do
    case NoizuPromptLingua.PMCore.with_pm(fn -> Noizu.PM.Projects.update_project(id, attrs) end) do
      {:legacy, _} ->
        case NoizuPromptLingua.Repo.get(Schema, id) do
          nil -> {:error, :not_found}
          project -> project |> Schema.changeset(attrs) |> NoizuPromptLingua.Repo.update()
        end

      other ->
        other
    end
  end

  def archive(id) do
    case NoizuPromptLingua.PMCore.with_pm(fn -> Noizu.PM.Projects.archive(id) end) do
      {:legacy, _} ->
        case NoizuPromptLingua.Repo.get(Schema, id) do
          nil ->
            {:error, :not_found}

          project ->
            project
            |> Schema.changeset(%{status: "archived", archived_at: DateTime.utc_now()})
            |> NoizuPromptLingua.Repo.update()
        end

      other ->
        other
    end
  end

  def unarchive(id) do
    case NoizuPromptLingua.PMCore.with_pm(fn -> Noizu.PM.Projects.unarchive(id) end) do
      {:legacy, _} ->
        case NoizuPromptLingua.Repo.get(Schema, id) do
          nil ->
            {:error, :not_found}

          project ->
            project
            |> Schema.changeset(%{status: "active", archived_at: nil})
            |> NoizuPromptLingua.Repo.update()
        end

      other ->
        other
    end
  end

  def delete_project(id) do
    case NoizuPromptLingua.PMCore.with_pm(fn -> Noizu.PM.Projects.soft_delete(id) end) do
      {:legacy, _} ->
        case NoizuPromptLingua.Repo.get(Schema, id) do
          nil ->
            {:error, :not_found}

          project ->
            project
            |> Schema.changeset(%{status: "deleted"})
            |> NoizuPromptLingua.Repo.update()
        end

      other ->
        other
    end
  end

  def list_members(project_id) do
    case NoizuPromptLingua.PMCore.with_pm(fn ->
           Noizu.PM.Projects.list_members(project_id)
         end) do
      {:legacy, _} ->
        NoizuPromptLingua.Authz.ScopedMemberships.list_for_resource("project", project_id)

      other ->
        other
    end
  end
end
