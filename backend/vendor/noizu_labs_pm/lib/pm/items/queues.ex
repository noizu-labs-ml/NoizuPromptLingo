defmodule Noizu.PM.Items.Queues do
  @moduledoc """
  Board (item_queue) provision on pm_core — used by therobotplans dual-path.
  """
  alias Noizu.PM.Schema.Items.{ItemQueue, BoardStage, BoardIteration}
  import Ecto.Query

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

  def create(attrs) do
    methodology = Map.get(attrs, :methodology) || Map.get(attrs, "methodology") || "kanban"

    Noizu.PM.Repo.transaction(fn ->
      with {:ok, board} <-
             %ItemQueue{}
             |> ItemQueue.changeset(attrs)
             |> Noizu.PM.Repo.insert() do
        stages = Map.get(@default_stages, methodology, @default_stages["kanban"])

        stages
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
          |> Noizu.PM.Repo.insert!()
        end)

        get_board(board.id)
      else
        {:error, changeset} -> Noizu.PM.Repo.rollback(changeset)
      end
    end)
  end

  def get_board(id) do
    ItemQueue
    |> preload(
      stages: ^from(s in BoardStage, order_by: s.position),
      iterations: ^from(i in BoardIteration, order_by: i.sequence)
    )
    |> Noizu.PM.Repo.get(id)
  end

  def add_iteration(attrs) do
    %BoardIteration{}
    |> BoardIteration.changeset(attrs)
    |> Noizu.PM.Repo.insert()
  end
end
