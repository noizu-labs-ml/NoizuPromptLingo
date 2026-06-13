defmodule TheRobotWars.Projects do
  alias TheRobotWars.Projects.Project, as: Entity
  alias TheRobotWars.Schema.Projects.Project, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)

  import Ecto.Query

  def create_with_owner(attrs, user_id, context \\ Noizu.Context.system()) do
    TheRobotWars.Repo.transaction(fn ->
      with {:ok, project} <- %Schema{} |> Schema.changeset(Map.put(attrs, :created_by, user_id)) |> TheRobotWars.Repo.insert(),
           {:ok, _membership} <- TheRobotWars.Authz.ScopedMemberships.add_member("project", project.id, user_id, "owner") do
        project
      else
        {:error, reason} -> TheRobotWars.Repo.rollback(reason)
      end
    end)
  end

  def list_for_user(user_id, organization_id \\ nil) do
    sql = "SELECT * FROM list_user_accessible_projects($1::uuid, $2::uuid)"
    params = [user_id, organization_id]

    case Ecto.Adapters.SQL.query(TheRobotWars.Repo, sql, params) do
      {:ok, %{rows: rows, columns: cols}} ->
        Enum.map(rows, fn row -> Enum.zip(cols, row) |> Map.new() end)
      _ -> []
    end
  end

  def get_project(id) do
    TheRobotWars.Repo.get(Schema, id)
  end

  def update_project(id, attrs) do
    case TheRobotWars.Repo.get(Schema, id) do
      nil -> {:error, :not_found}
      project -> project |> Schema.changeset(attrs) |> TheRobotWars.Repo.update()
    end
  end

  def archive(id) do
    case TheRobotWars.Repo.get(Schema, id) do
      nil -> {:error, :not_found}
      project ->
        project
        |> Schema.changeset(%{status: "archived", archived_at: DateTime.utc_now()})
        |> TheRobotWars.Repo.update()
    end
  end

  def unarchive(id) do
    case TheRobotWars.Repo.get(Schema, id) do
      nil -> {:error, :not_found}
      project ->
        project
        |> Schema.changeset(%{status: "active", archived_at: nil})
        |> TheRobotWars.Repo.update()
    end
  end

  def delete_project(id) do
    case TheRobotWars.Repo.get(Schema, id) do
      nil -> {:error, :not_found}
      project ->
        project
        |> Schema.changeset(%{status: "deleted"})
        |> TheRobotWars.Repo.update()
    end
  end

  def list_members(project_id) do
    TheRobotWars.Authz.ScopedMemberships.list_for_resource("project", project_id)
  end
end
