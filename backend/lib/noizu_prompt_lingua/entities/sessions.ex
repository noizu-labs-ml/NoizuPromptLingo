defmodule NoizuPromptLingua.Sessions do
  alias NoizuPromptLingua.Sessions.Session, as: Entity
  alias NoizuPromptLingua.Schema.Sessions.Session, as: Schema

  use Noizu.Repo
  def_repo(entity: Entity)

  import Ecto.Query
  require Logger

  @moduledoc """
  Work sessions group chat rooms and memories under a shared context.

  ## Activity tracking

  `last_activity_at` drives the inactivity sweep (`SessionInactivityWorker`
  flips `active` → `inactive` after a configurable window, default 24h, env
  `NPL_SESSION_INACTIVITY_HOURS`). An "event" is any of:

    * session creation (initialized to the insert time)
    * an explicit session write via `update_session/2`, `archive/1`,
      `unarchive/1` (so manual reactivation `inactive` → `active` resets the
      clock and is not immediately re-swept)
    * a read by id (`get_session/1`) — the REST show + MCP Session.Get path
    * a chat message posted to any room linked to the session
    * a memory write carrying the session's id

  Touches are best-effort: a failed `touch_activity/1` logs and never fails
  the parent operation.
  """

  @doc """
  Create a work session. `organization_id` is required; `project_id` is
  optional. `created_by` records the authoring user.
  """
  def create(attrs, user_id \\ nil) do
    attrs =
      attrs
      |> Map.put(:last_activity_at, DateTime.utc_now())
      |> then(&if user_id, do: Map.put(&1, :created_by, user_id), else: &1)

    %Schema{}
    |> Schema.changeset(attrs)
    |> NoizuPromptLingua.Repo.insert()
  end

  def get_session(id) do
    case NoizuPromptLingua.Repo.get(Schema, id) do
      nil ->
        nil

      session ->
        touch_activity(session.id)
        session
    end
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

  # Every explicit write resets the activity clock — this is what makes a
  # manual reactivation (inactive → active) durable against the sweep.
  def update_session(id, attrs) do
    attrs = Map.put(attrs, :last_activity_at, DateTime.utc_now())

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
        |> Schema.changeset(%{
          status: "archived",
          archived_at: DateTime.utc_now(),
          last_activity_at: DateTime.utc_now()
        })
        |> NoizuPromptLingua.Repo.update()
    end
  end

  def unarchive(id) do
    case NoizuPromptLingua.Repo.get(Schema, id) do
      nil ->
        {:error, :not_found}

      session ->
        session
        |> Schema.changeset(%{
          status: "active",
          archived_at: nil,
          last_activity_at: DateTime.utc_now()
        })
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

  @doc """
  Best-effort activity touch: a single UPDATE bumping `last_activity_at`.
  Never raises and never fails the caller — on error it logs and returns :ok.
  """
  def touch_activity(session_id) when is_binary(session_id) do
    from(s in Schema, where: s.id == ^session_id)
    |> NoizuPromptLingua.Repo.update_all(set: [last_activity_at: DateTime.utc_now()])

    :ok
  rescue
    e ->
      Logger.warning("[Sessions] activity touch failed for #{session_id}: #{inspect(e)}")
      :ok
  catch
    :exit, reason ->
      Logger.warning("[Sessions] activity touch exit for #{session_id}: #{inspect(reason)}")
      :ok
  end

  def touch_activity(_), do: :ok
end
