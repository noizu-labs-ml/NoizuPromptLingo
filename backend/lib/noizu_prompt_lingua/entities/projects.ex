defmodule NoizuPromptLingua.Projects do
  alias NoizuPromptLingua.Projects.Project, as: Entity
  alias NoizuPromptLingua.Schema.Projects.Project, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)

  import Ecto.Query

  def create_with_owner(attrs, user_id, context \\ Noizu.Context.system()) do
    NoizuPromptLingua.Repo.transaction(fn ->
      with {:ok, project} <- %Schema{} |> Schema.changeset(Map.put(attrs, :created_by, user_id)) |> NoizuPromptLingua.Repo.insert(),
           {:ok, _membership} <- NoizuPromptLingua.Authz.ScopedMemberships.add_member("project", project.id, user_id, "owner") do
        project
      else
        {:error, reason} -> NoizuPromptLingua.Repo.rollback(reason)
      end
    end)
  end

  def list_for_user(user_id, organization_id \\ nil) do
    sql = "SELECT * FROM list_user_accessible_projects($1::uuid, $2::uuid)"
    params = [user_id, organization_id]

    case Ecto.Adapters.SQL.query(NoizuPromptLingua.Repo, sql, params) do
      {:ok, %{rows: rows, columns: cols}} ->
        Enum.map(rows, fn row -> Enum.zip(cols, row) |> Map.new() end)
      _ -> []
    end
  end

  def get_project(id) do
    NoizuPromptLingua.Repo.get(Schema, id)
  end

  def update_project(id, attrs) do
    case NoizuPromptLingua.Repo.get(Schema, id) do
      nil -> {:error, :not_found}
      project -> project |> Schema.changeset(attrs) |> NoizuPromptLingua.Repo.update()
    end
  end

  def archive(id) do
    case NoizuPromptLingua.Repo.get(Schema, id) do
      nil -> {:error, :not_found}
      project ->
        project
        |> Schema.changeset(%{status: "archived", archived_at: DateTime.utc_now()})
        |> NoizuPromptLingua.Repo.update()
    end
  end

  def unarchive(id) do
    case NoizuPromptLingua.Repo.get(Schema, id) do
      nil -> {:error, :not_found}
      project ->
        project
        |> Schema.changeset(%{status: "active", archived_at: nil})
        |> NoizuPromptLingua.Repo.update()
    end
  end

  def delete_project(id) do
    case NoizuPromptLingua.Repo.get(Schema, id) do
      nil -> {:error, :not_found}
      project ->
        project
        |> Schema.changeset(%{status: "deleted"})
        |> NoizuPromptLingua.Repo.update()
    end
  end

  def list_members(project_id) do
    NoizuPromptLingua.Authz.ScopedMemberships.list_for_resource("project", project_id)
  end
end
