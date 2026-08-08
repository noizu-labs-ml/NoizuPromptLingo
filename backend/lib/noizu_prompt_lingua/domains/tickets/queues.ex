defmodule NoizuPromptLingua.Domains.Tickets.Queues do
  @moduledoc """
  Boards (formerly "queues") and their stages and iterations. A board carries a
  `methodology` (kanban | scrum | waterfall | spiral) and is seeded with that
  methodology's default stage set on creation. Boards are tri-scoped
  (global / org / project); a project sees global ∪ org ∪ project boards.
  """
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{TicketQueue, BoardStage, BoardIteration, Ticket}

  # ── Default stage sets per methodology ────────────────────────
  @default_stages %{
    "kanban" => [
      {"todo", "To Do", "todo"},
      {"in_progress", "In Progress", "in_progress"},
      {"done", "Done", "done"}
    ],
    "scrum" => [
      {"todo", "To Do", "todo"},
      {"in_progress", "In Progress", "in_progress"},
      {"in_review", "In Review", "in_review"},
      {"done", "Done", "done"}
    ],
    "waterfall" => [
      {"requirements", "Requirements", "phase"},
      {"design", "Design", "phase"},
      {"implementation", "Implementation", "phase"},
      {"verification", "Verification", "phase"},
      {"maintenance", "Maintenance", "phase"}
    ],
    "spiral" => [
      {"planning", "Planning", "phase"},
      {"risk_analysis", "Risk Analysis", "phase"},
      {"engineering", "Engineering", "phase"},
      {"evaluation", "Evaluation", "phase"}
    ]
  }

  def default_stages(methodology),
    do: Map.get(@default_stages, methodology, @default_stages["kanban"])

  # ── Boards ────────────────────────────────────────────────────

  @doc "Create a board and seed its methodology's default stages."
  def create(attrs) do
    Repo.transaction(fn ->
      with {:ok, board} <- %TicketQueue{} |> TicketQueue.changeset(attrs) |> Repo.insert() do
        default_stages(board.methodology)
        |> Enum.with_index()
        |> Enum.each(fn {{slug, name, kind}, idx} ->
          %BoardStage{}
          |> BoardStage.changeset(%{
            queue_id: board.id,
            slug: slug,
            name: name,
            kind: kind,
            position: idx
          })
          |> Repo.insert!()
        end)

        get_board(board.id)
      else
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  def get_board(id) do
    TicketQueue
    |> preload(
      stages: ^from(s in BoardStage, order_by: s.position),
      iterations: ^from(i in BoardIteration, order_by: i.sequence)
    )
    |> Repo.get(id)
  end

  # Slug lookup within a context — first visible board with that slug.
  def get(slug, org_id \\ nil, project_id \\ nil) when is_binary(slug) do
    TicketQueue
    |> where([q], q.slug == ^slug)
    |> where(^visible_scope(org_id, project_id))
    |> preload(
      stages: ^from(s in BoardStage, order_by: s.position),
      iterations: ^from(i in BoardIteration, order_by: i.sequence)
    )
    |> Repo.all()
    |> List.first()
  end

  def get_by_id(id), do: get_board(id)

  def list(org_id \\ nil, project_id \\ nil) do
    TicketQueue
    |> where(^visible_scope(org_id, project_id))
    |> order_by([q], asc: q.name)
    |> Repo.all()
  end

  def update_board(id, attrs) do
    case Repo.get(TicketQueue, id) do
      nil ->
        {:error, :not_found}

      # methodology is immutable after creation (stages depend on it).
      board ->
        board
        |> TicketQueue.changeset(Map.drop(attrs, [:methodology, "methodology"]))
        |> Repo.update()
    end
  end

  def delete_board(id) do
    case Repo.get(TicketQueue, id) do
      nil -> {:error, :not_found}
      board -> Repo.delete(board)
    end
  end

  def status_counts(queue_id) do
    Ticket
    |> where([t], t.queue_id == ^queue_id)
    |> group_by([t], t.status)
    |> select([t], {t.status, count(t.id)})
    |> Repo.all()
    |> Map.new()
  end

  # ── Stages ────────────────────────────────────────────────────

  def add_stage(attrs), do: %BoardStage{} |> BoardStage.changeset(attrs) |> Repo.insert()

  def update_stage(id, attrs) do
    case Repo.get(BoardStage, id) do
      nil -> {:error, :not_found}
      stage -> stage |> BoardStage.changeset(attrs) |> Repo.update()
    end
  end

  def delete_stage(id) do
    case Repo.get(BoardStage, id) do
      nil -> {:error, :not_found}
      stage -> Repo.delete(stage)
    end
  end

  def list_stages(queue_id) do
    BoardStage
    |> where([s], s.queue_id == ^queue_id)
    |> order_by([s], asc: s.position)
    |> Repo.all()
  end

  # ── Iterations (sprints / cycles) ─────────────────────────────

  def add_iteration(attrs),
    do: %BoardIteration{} |> BoardIteration.changeset(attrs) |> Repo.insert()

  def update_iteration(id, attrs) do
    case Repo.get(BoardIteration, id) do
      nil -> {:error, :not_found}
      it -> it |> BoardIteration.changeset(attrs) |> Repo.update()
    end
  end

  def delete_iteration(id) do
    case Repo.get(BoardIteration, id) do
      nil -> {:error, :not_found}
      it -> Repo.delete(it)
    end
  end

  def list_iterations(queue_id) do
    BoardIteration
    |> where([i], i.queue_id == ^queue_id)
    |> order_by([i], asc: i.sequence)
    |> Repo.all()
  end

  # ── Internals ─────────────────────────────────────────────────

  defp visible_scope(nil, _project_id),
    do: dynamic([q], is_nil(q.organization_id) and is_nil(q.project_id))

  defp visible_scope(org_id, nil) do
    dynamic(
      [q],
      (is_nil(q.organization_id) and is_nil(q.project_id)) or
        (q.organization_id == ^org_id and is_nil(q.project_id))
    )
  end

  defp visible_scope(org_id, project_id) do
    dynamic(
      [q],
      (is_nil(q.organization_id) and is_nil(q.project_id)) or
        (q.organization_id == ^org_id and is_nil(q.project_id)) or
        (q.organization_id == ^org_id and q.project_id == ^project_id)
    )
  end
end
