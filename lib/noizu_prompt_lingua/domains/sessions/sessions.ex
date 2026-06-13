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
    limit = Keyword.get(opts, :limit, 50)
    offset = Keyword.get(opts, :offset, 0)

    Session
    |> maybe_filter_status(status)
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

  defp maybe_filter_status(query, nil), do: query
  defp maybe_filter_status(query, status) do
    where(query, [s], s.status == ^status)
  end
end
