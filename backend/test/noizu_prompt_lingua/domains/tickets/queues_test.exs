defmodule NoizuPromptLingua.Domains.Tickets.QueuesTest do
  @moduledoc """
  Board (queue) create-path persistence — ticket d4a8fd52. Confirms a project-scoped
  board persists its project_id (the data root behind project-scoped board views) and
  an org-scoped board carries no project_id, and that create seeds the methodology's
  default stages. Mirrors the chat_slug_test DataCase fixture pattern.
  """
  use NoizuPromptLingua.DataCase

  alias NoizuPromptLingua.Domains.Tickets.Queues

  @moduletag :db

  setup do
    org_id = insert_org()
    {:ok, org_id: org_id, project_id: insert_project(org_id)}
  end

  test "project-scoped board persists project_id + seeds kanban stages", ctx do
    {:ok, board} =
      Queues.create(%{
        organization_id: ctx.org_id,
        project_id: ctx.project_id,
        name: "Sprint Board",
        slug: uslug("sprint"),
        methodology: "kanban"
      })

    assert board.project_id == ctx.project_id
    assert board.organization_id == ctx.org_id
    # kanban seeds 3 default stages (todo / in_progress / done)
    assert length(board.stages) == 3
    assert Enum.map(board.stages, & &1.slug) == ["todo", "in_progress", "done"]
  end

  test "org-scoped board carries no project_id", ctx do
    {:ok, board} =
      Queues.create(%{
        organization_id: ctx.org_id,
        name: "Org Board",
        slug: uslug("org"),
        methodology: "kanban"
      })

    assert is_nil(board.project_id)
    assert board.organization_id == ctx.org_id
  end

  test "a project board with no organization_id is rejected (scope invariant)", ctx do
    assert {:error, changeset} =
             Queues.create(%{
               project_id: ctx.project_id,
               name: "Bad",
               slug: uslug("bad"),
               methodology: "kanban"
             })

    assert changeset.errors[:organization_id]
  end

  defp uslug(p), do: "#{p}-#{System.unique_integer([:positive])}"

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["boardtest-#{System.unique_integer([:positive])}", "Board Test Org"]
      )

    Ecto.UUID.load!(raw)
  end

  defp insert_project(org_id) do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO projects (id, organization_id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, $3, now(), now()) RETURNING id",
        [
          Ecto.UUID.dump!(org_id),
          "boardproj-#{System.unique_integer([:positive])}",
          "Board Test Project"
        ]
      )

    Ecto.UUID.load!(raw)
  end
end
