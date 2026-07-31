defmodule NoizuPromptLinguaWeb.BoardController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.Tickets.Queues
  alias NoizuPromptLingua.Schema.TicketQueue
  alias NoizuPromptLingua.Authz

  # GET /api/v1/organizations/:org_id/boards[?project_id=]
  def index(conn, %{"org_id" => org_id} = params) do
    with_org(conn, org_id, "viewer", fn resolved_org_id ->
      project_id = blank_to_nil(params["project_id"])
      boards = Queues.list(resolved_org_id, project_id)

      json(conn, %{
        boards: Enum.map(boards, &board_summary/1),
        methodologies: TicketQueue.methodologies()
      })
    end)
  end

  # POST /api/v1/organizations/:org_id/boards
  def create(conn, %{"org_id" => org_id, "board" => params}) do
    with_org(conn, org_id, "member", fn resolved_org_id ->
      with {:ok, project_id} <-
             scope_project(params["scope"], params["project_id"], resolved_org_id) do
        attrs = %{
          name: params["name"],
          slug: params["slug"],
          description: params["description"],
          methodology: params["methodology"] || "kanban",
          organization_id: resolved_org_id,
          project_id: project_id
        }

        case Queues.create(attrs) do
          {:ok, board} ->
            conn |> put_status(:created) |> json(%{board: board_detail(board)})

          {:error, changeset} ->
            conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
        end
      else
        {:error, :project_not_in_org} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "Project does not belong to this organization"})

        {:error, :global_forbidden} ->
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Global boards are system-managed and cannot be created here"})
      end
    end)
  end

  # GET /api/v1/organizations/:org_id/boards/:id
  def show(conn, %{"org_id" => org_id, "id" => id}) do
    with_visible_board(conn, org_id, id, fn board -> json(conn, %{board: board_detail(board)}) end)
  end

  # PUT /api/v1/organizations/:org_id/boards/:id
  def update(conn, %{"org_id" => org_id, "id" => id, "board" => params}) do
    with_owned_board(conn, org_id, id, fn _board ->
      attrs = Map.take(params, ~w(name slug description config))

      case Queues.update_board(id, attrs) do
        {:ok, _} ->
          json(conn, %{board: board_detail(Queues.get_board(id))})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    end)
  end

  # DELETE /api/v1/organizations/:org_id/boards/:id
  def delete(conn, %{"org_id" => org_id, "id" => id}) do
    with_owned_board(conn, org_id, id, fn _board ->
      case Queues.delete_board(id) do
        {:ok, _} -> json(conn, %{message: "Board deleted"})
        {:error, :not_found} -> not_found(conn, "Board")
      end
    end)
  end

  # ── Stages ────────────────────────────────────────────────────

  def add_stage(conn, %{"org_id" => org_id, "board_id" => board_id, "stage" => params}) do
    with_owned_board(conn, org_id, board_id, fn _board ->
      attrs = stage_attrs(params) |> Map.put(:queue_id, board_id)

      case Queues.add_stage(attrs) do
        {:ok, stage} ->
          conn |> put_status(:created) |> json(%{stage: stage_json(stage)})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    end)
  end

  def update_stage(conn, %{
        "org_id" => org_id,
        "board_id" => board_id,
        "stage_id" => sid,
        "stage" => params
      }) do
    with_owned_board(conn, org_id, board_id, fn _board ->
      case Queues.update_stage(sid, stage_attrs(params)) do
        {:ok, stage} ->
          json(conn, %{stage: stage_json(stage)})

        {:error, :not_found} ->
          not_found(conn, "Stage")

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    end)
  end

  def delete_stage(conn, %{"org_id" => org_id, "board_id" => board_id, "stage_id" => sid}) do
    with_owned_board(conn, org_id, board_id, fn _board ->
      case Queues.delete_stage(sid) do
        {:ok, _} -> json(conn, %{message: "Stage deleted"})
        {:error, :not_found} -> not_found(conn, "Stage")
      end
    end)
  end

  # ── Iterations ────────────────────────────────────────────────

  def add_iteration(conn, %{"org_id" => org_id, "board_id" => board_id, "iteration" => params}) do
    with_owned_board(conn, org_id, board_id, fn _board ->
      attrs = iteration_attrs(params) |> Map.put(:queue_id, board_id)

      case Queues.add_iteration(attrs) do
        {:ok, it} ->
          conn |> put_status(:created) |> json(%{iteration: iteration_json(it)})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    end)
  end

  def update_iteration(conn, %{
        "org_id" => org_id,
        "board_id" => board_id,
        "iteration_id" => iid,
        "iteration" => params
      }) do
    with_owned_board(conn, org_id, board_id, fn _board ->
      case Queues.update_iteration(iid, iteration_attrs(params)) do
        {:ok, it} ->
          json(conn, %{iteration: iteration_json(it)})

        {:error, :not_found} ->
          not_found(conn, "Iteration")

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    end)
  end

  def delete_iteration(conn, %{"org_id" => org_id, "board_id" => board_id, "iteration_id" => iid}) do
    with_owned_board(conn, org_id, board_id, fn _board ->
      case Queues.delete_iteration(iid) do
        {:ok, _} -> json(conn, %{message: "Iteration deleted"})
        {:error, :not_found} -> not_found(conn, "Iteration")
      end
    end)
  end

  # ── JSON ──────────────────────────────────────────────────────

  defp board_summary(b) do
    %{
      id: b.id,
      scope: scope_of(b),
      organization_id: b.organization_id,
      project_id: b.project_id,
      name: b.name,
      slug: b.slug,
      methodology: b.methodology,
      description: b.description
    }
  end

  defp board_detail(b) do
    board_summary(b)
    |> Map.merge(%{
      config: b.config,
      stages: Enum.map(b.stages, &stage_json/1),
      iterations: Enum.map(b.iterations, &iteration_json/1)
    })
  end

  defp stage_json(s),
    do: %{
      id: s.id,
      slug: s.slug,
      name: s.name,
      kind: s.kind,
      position: s.position,
      wip_limit: s.wip_limit,
      config: s.config
    }

  defp iteration_json(i),
    do: %{
      id: i.id,
      name: i.name,
      sequence: i.sequence,
      status: i.status,
      goal: i.goal,
      starts_on: i.starts_on,
      ends_on: i.ends_on
    }

  defp scope_of(%{project_id: p}) when not is_nil(p), do: "project"
  defp scope_of(%{organization_id: o}) when not is_nil(o), do: "org"
  defp scope_of(_), do: "global"

  defp stage_attrs(params) do
    params |> Map.take(~w(slug name kind position wip_limit config)) |> atomize()
  end

  defp iteration_attrs(params) do
    params |> Map.take(~w(name sequence status goal starts_on ends_on config)) |> atomize()
  end

  defp atomize(map), do: Map.new(map, fn {k, v} -> {String.to_existing_atom(k), v} end)

  # ── Authz / scope helpers ─────────────────────────────────────

  defp with_visible_board(conn, org_id, id, fun) do
    with_org(conn, org_id, "viewer", fn resolved_org_id ->
      case Queues.get_board(id) do
        nil ->
          not_found(conn, "Board")

        board ->
          if visible?(board, resolved_org_id), do: fun.(board), else: not_found(conn, "Board")
      end
    end)
  end

  defp with_owned_board(conn, org_id, id, fun) do
    with_org(conn, org_id, "member", fn resolved_org_id ->
      case Queues.get_board(id) do
        nil ->
          not_found(conn, "Board")

        %{organization_id: ^resolved_org_id} = board ->
          fun.(board)

        _ ->
          conn
          |> put_status(:forbidden)
          |> json(%{error: "This board is not managed by your organization"})
      end
    end)
  end

  # Visible = global, or owned by this org (org/project scope under it).
  defp visible?(%{organization_id: nil}, _org_id), do: true
  defp visible?(%{organization_id: oid}, org_id), do: oid == org_id

  # Resolve a board's project scope (d4a8fd52). A supplied project_id => PROJECT
  # board (validated ∈ org), whether or not scope was sent — this closes the
  # silent-org-default footgun where a client (MCP/curl, or an FE regression) sends
  # project_id WITHOUT scope:"project" and the board silently became org-level. No
  # project_id => org board. Explicit "global" is system-managed; explicit "project"
  # with no project_id is a client error (deny-safe, never a silent org fallback).
  defp scope_project("global", _project_id, _org_id), do: {:error, :global_forbidden}

  defp scope_project(scope, project_id, org_id) do
    case blank_to_nil(project_id) do
      nil when scope == "project" -> {:error, :project_not_in_org}
      nil -> {:ok, nil}
      pid -> validate_project_in_org(pid, org_id)
    end
  end

  defp validate_project_in_org(project_id, org_id) do
    case NoizuPromptLingua.Projects.get_project(project_id) do
      %{organization_id: ^org_id} -> {:ok, project_id}
      _ -> {:error, :project_not_in_org}
    end
  end

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(v), do: v

  defp not_found(conn, what),
    do: conn |> put_status(:not_found) |> json(%{error: "#{what} not found"})

  defp with_org(conn, org_id, role, fun) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, role) do
      fun.(resolved_org_id)
    else
      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

      {:error, :not_a_member} ->
        conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})

      {:error, _} ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  defp get_user_id(conn) do
    case NoizuPromptLingua.Guardian.Plug.current_resource(conn) do
      %NoizuPromptLingua.Users.Sessions.UserSession{user: {:ref, _, id}} -> id
      %NoizuPromptLingua.Users.Sessions.UserSession{user: %{id: id}} -> id
      _ -> nil
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
