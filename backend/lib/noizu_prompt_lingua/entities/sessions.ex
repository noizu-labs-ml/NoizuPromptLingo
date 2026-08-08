defmodule NoizuPromptLingua.Sessions do
  alias NoizuPromptLingua.Sessions.Session, as: Entity
  alias NoizuPromptLingua.Schema.Sessions.Session, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)

  import Ecto.Query

  @doc """
  Create a work session. `organization_id` is required; `project_id` is
  optional. `created_by` records the authoring user.
  """
  def create(attrs, user_id \\ nil) do
    attrs = if user_id, do: Map.put(attrs, :created_by, user_id), else: attrs

    %Schema{}
    |> Schema.changeset(attrs)
    |> NoizuPromptLingua.Repo.insert()
  end

  def get_session(id) do
    NoizuPromptLingua.Repo.get(Schema, id)
  end

  @doc """
  List sessions for an organization, newest first. Optionally filter by
  `:project_id` and/or `:status`.
  """
  def list_for_org(organization_id, opts \\ []) do
    status = Keyword.get(opts, :status)
    project_id = Keyword.get(opts, :project_id)
    limit = Keyword.get(opts, :limit, 50)
    offset = Keyword.get(opts, :offset, 0)

    Schema
    |> where([s], s.organization_id == ^organization_id)
    |> maybe_filter_status(status)
    |> maybe_filter_project(project_id)
    |> order_by([s], desc: s.inserted_at)
    |> limit(^limit)
    |> offset(^offset)
    |> NoizuPromptLingua.Repo.all()
  end

  def update_session(id, attrs) do
    case NoizuPromptLingua.Repo.get(Schema, id) do
      nil -> {:error, :not_found}
      session -> session |> Schema.changeset(attrs) |> NoizuPromptLingua.Repo.update()
    end
  end

  def archive(id) do
    case NoizuPromptLingua.Repo.get(Schema, id) do
      nil ->
        {:error, :not_found}

      session ->
        session
        |> Schema.changeset(%{status: "archived", archived_at: DateTime.utc_now()})
        |> NoizuPromptLingua.Repo.update()
    end
  end

  def unarchive(id) do
    case NoizuPromptLingua.Repo.get(Schema, id) do
      nil ->
        {:error, :not_found}

      session ->
        session
        |> Schema.changeset(%{status: "active", archived_at: nil})
        |> NoizuPromptLingua.Repo.update()
    end
  end

  def delete_session(id) do
    case NoizuPromptLingua.Repo.get(Schema, id) do
      nil -> {:error, :not_found}
      session -> NoizuPromptLingua.Repo.delete(session)
    end
  end

  defp maybe_filter_status(query, nil), do: query
  defp maybe_filter_status(query, status), do: where(query, [s], s.status == ^status)

  defp maybe_filter_project(query, nil), do: query
  defp maybe_filter_project(query, project_id), do: where(query, [s], s.project_id == ^project_id)
end
