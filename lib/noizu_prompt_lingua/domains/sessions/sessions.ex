defmodule NoizuPromptLingua.Domains.Sessions do
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Session

  def create(attrs) do
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert()
  end

  def get(id) do
    Repo.get(Session, id)
  end

  def update(id, attrs) do
    case Repo.get(Session, id) do
      nil -> {:error, :not_found}
      session ->
        session
        |> Session.changeset(attrs)
        |> Repo.update()
    end
  end

  def list(opts \\ []) do
    status = Keyword.get(opts, :status)
    project_id = Keyword.get(opts, :project_id)
    limit = Keyword.get(opts, :limit, 50)
    offset = Keyword.get(opts, :offset, 0)

    Session
    |> maybe_filter_status(status)
    |> maybe_filter_project(project_id)
    |> order_by([s], desc: s.inserted_at)
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  def archive(id) do
    update(id, %{status: "archived"})
  end

  def count_active do
    Repo.aggregate(
      from(s in Session, where: s.status == "active"),
      :count
    )
  end

  def resolve_project_id(nil), do: {:ok, nil}
  def resolve_project_id(slug_or_id) do
    case NoizuPromptLingua.Domains.Projects.get(slug_or_id) do
      nil -> {:error, :project_not_found}
      project -> {:ok, project.id}
    end
  end

  defp maybe_filter_status(query, nil), do: query
  defp maybe_filter_status(query, status) do
    where(query, [s], s.status == ^status)
  end

  defp maybe_filter_project(query, nil), do: query
  defp maybe_filter_project(query, project_id) do
    where(query, [s], s.project_id == ^project_id)
  end
end
