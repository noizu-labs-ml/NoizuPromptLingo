defmodule CodefreshWeb.ReviewController do
  @moduledoc """
  HTTP surface for Stage 8 (Review + Promotion).

  Endpoints (all scoped under `/organizations/:organization_id/`):

    * `GET    /review`                      — list queue (US-088, US-140, US-141)
    * `POST   /review/:id/claim`            — claim an item (US-089)
    * `POST   /review/:id/resolve`          — approve / reject / dismiss (US-089, US-137)
    * `POST   /review/:id/assign`           — assign to user / unassign (US-140)
    * `POST   /review/:id/promote`          — promote to script or persona (US-090, US-139)
    * `POST   /review/bulk`                 — bulk actions (US-138)

  Cross-org access returns 404 (not 403) — precedent set by
  `CodefreshWeb.AgentController.safe_get/2`.
  """

  use CodefreshWeb, :controller

  alias Codefresh.{Review, Organizations}
  alias Codefresh.Guardian

  # ---------------------------------------------------------------------------
  # GET /review — queue listing (US-088, US-140, US-141)
  # ---------------------------------------------------------------------------

  def index(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      opts =
        []
        |> maybe_put(:status, param_statuses(params["status"]))
        |> maybe_put(:assigned_to_user_id, param_uuid(params["assigned_to_user_id"]))
        |> maybe_put(:min_priority, param_int(params["min_priority"]))
        |> maybe_put(:max_priority, param_int(params["max_priority"]))
        |> maybe_put(:limit, param_int(params["limit"]))
        |> maybe_put(:offset, param_int(params["offset"]))
        |> maybe_put(:sort, param_sort(params["sort"]))
        |> maybe_put(:assigned_to_user_id, my_queue_user(params, user))

      items = Review.list_queue(org_id, opts)
      total = Review.count_queue(org_id, opts)

      json(conn, %{
        items: Enum.map(items, &render_item/1),
        total: total
      })
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ---------------------------------------------------------------------------
  # POST /review/:id/claim (US-089)
  # ---------------------------------------------------------------------------

  def claim(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         item when not is_nil(item) <- Review.get_item(org_id, id) do
      case Review.claim_item(item, user.id) do
        {:ok, updated} ->
          json(conn, %{item: render_item(updated)})

        {:error, :not_claimable} ->
          conn |> put_status(:conflict) |> json(%{error: "item not claimable"})

        {:error, cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ---------------------------------------------------------------------------
  # POST /review/:id/resolve (US-089, US-137)
  # body: {"action": "approve" | "reject" | "dismiss",
  #        "resolution_notes": "…",
  #        "flag_regression": true}
  # ---------------------------------------------------------------------------

  def resolve(conn, %{"organization_id" => org_id, "id" => id} = params) do
    user = Guardian.Plug.current_resource(conn)
    action = Map.get(params, "action")
    attrs = atomize_attrs(params)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         item when not is_nil(item) <- Review.get_item(org_id, id),
         {:ok, updated} <- dispatch_resolve(item, user.id, action, attrs) do
      json(conn, %{item: render_item(updated)})
    else
      nil ->
        send_resp(conn, 404, "")

      {:error, :forbidden} ->
        send_resp(conn, 403, "")

      {:error, :not_a_member} ->
        send_resp(conn, 404, "")

      {:error, :unknown_action} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "action must be approve | reject | dismiss"})

      {:error, :resolution_notes_required} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "resolution_notes required for reject and dismiss"})

      {:error, :already_resolved} ->
        conn
        |> put_status(:conflict)
        |> json(%{error: "item already resolved"})

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: inspect(reason)})
    end
  end

  defp dispatch_resolve(item, actor_id, "approve", attrs), do: Review.approve(item, actor_id, attrs)
  defp dispatch_resolve(item, actor_id, "reject", attrs), do: Review.reject(item, actor_id, attrs)
  defp dispatch_resolve(item, actor_id, "dismiss", attrs), do: Review.dismiss(item, actor_id, attrs)
  defp dispatch_resolve(_item, _actor_id, _other, _attrs), do: {:error, :unknown_action}

  # ---------------------------------------------------------------------------
  # POST /review/:id/assign (US-140)
  # body: {"assignee_user_id": "…" | null}
  # ---------------------------------------------------------------------------

  def assign(conn, %{"organization_id" => org_id, "id" => id} = params) do
    user = Guardian.Plug.current_resource(conn)
    assignee = param_uuid(Map.get(params, "assignee_user_id"))

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         item when not is_nil(item) <- Review.get_item(org_id, id),
         {:ok, updated} <- Review.assign(item, user.id, assignee) do
      json(conn, %{item: render_item(updated)})
    else
      nil ->
        send_resp(conn, 404, "")

      {:error, :forbidden} ->
        send_resp(conn, 403, "")

      {:error, :not_a_member} ->
        send_resp(conn, 404, "")

      {:error, :not_assignable} ->
        conn |> put_status(:conflict) |> json(%{error: "item is already resolved"})

      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
    end
  end

  # ---------------------------------------------------------------------------
  # POST /review/:id/promote (US-090, US-139)
  # body: {"target_kind": "script_version" | "persona_version",
  #        "target_script_version_id": "…",   # for persona variant
  #        "notes": "…"}
  # ---------------------------------------------------------------------------

  def promote(conn, %{"organization_id" => org_id, "id" => id} = params) do
    user = Guardian.Plug.current_resource(conn)

    opts =
      []
      |> Keyword.put(:target_kind, Map.get(params, "target_kind", "script_version"))
      |> maybe_put(:target_script_version_id, param_uuid(Map.get(params, "target_script_version_id")))
      |> maybe_put(:notes, Map.get(params, "notes"))

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         item when not is_nil(item) <- Review.get_item(org_id, id),
         {:ok, result} <- Review.create_promotion(item, user.id, opts) do
      conn
      |> put_status(:created)
      |> json(%{
        item: render_item(result.item),
        promotion: render_promotion(result.promotion),
        extra: result.extra
      })
    else
      nil ->
        send_resp(conn, 404, "")

      {:error, :forbidden} ->
        send_resp(conn, 403, "")

      {:error, :not_a_member} ->
        send_resp(conn, 404, "")

      {:error, :item_not_approved} ->
        conn
        |> put_status(:conflict)
        |> json(%{error: "item must be in 'approved' state before promotion"})

      {:error, :persona_version_id_required} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "target_script_version_id required for persona_version promotion"})

      {:error, :unknown_target_kind} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "target_kind must be script_version | persona_version"})

      {:error, :source_graph_not_found} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "source script graph for freeball could not be resolved"})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
    end
  end

  # ---------------------------------------------------------------------------
  # POST /review/bulk (US-138)
  # body: {"action": "approve" | "reject" | "dismiss" | "claim" | "assign",
  #        "item_ids": ["…"],
  #        "resolution_notes": "…",
  #        "assignee_user_id": "…",
  #        "flag_regression": true}
  # ---------------------------------------------------------------------------

  def bulk(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)
    action = Map.get(params, "action")
    ids = Map.get(params, "item_ids", []) |> List.wrap()

    opts =
      []
      |> maybe_put(:resolution_notes, Map.get(params, "resolution_notes"))
      |> maybe_put(:assignee_user_id, param_uuid(Map.get(params, "assignee_user_id")))
      |> maybe_put(:flag_regression, Map.get(params, "flag_regression"))

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         true <- action in ~w(claim approve reject dismiss assign) do
      result = Review.bulk_action(org_id, user.id, action, ids, opts)

      json(conn, %{
        ok: Enum.map(result.ok, &render_item/1),
        skipped:
          Enum.map(result.skipped, fn {id, reason} ->
            %{id: id, reason: inspect(reason)}
          end),
        total_requested: length(ids),
        total_applied: length(result.ok)
      })
    else
      false ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "action must be one of claim|approve|reject|dismiss|assign"})

      {:error, :forbidden} ->
        send_resp(conn, 403, "")

      {:error, :not_a_member} ->
        send_resp(conn, 404, "")
    end
  end

  # ---------------------------------------------------------------------------
  # Renderers
  # ---------------------------------------------------------------------------

  defp render_item(%Codefresh.Review.ReviewItem{} = ri) do
    %{
      id: ri.id,
      organization_id: ri.organization_id,
      freeball_node_id: ri.freeball_node_id,
      run_id: if(ri.freeball_node && ri.freeball_node != %Ecto.Association.NotLoaded{}, do: ri.freeball_node.run_id, else: nil),
      status: case ri.status do
        s when s in ["approved", "rejected", "promoted"] -> "resolved"
        other -> other
      end,
      priority: ri.priority,
      assignee_id: ri.assigned_to_user_id,
      assignee_email: if(ri.assigned_to_user && ri.assigned_to_user != %Ecto.Association.NotLoaded{}, do: ri.assigned_to_user.email, else: nil),
      claimed_at: ri.claimed_at,
      resolved_at: ri.resolved_at,
      notes: ri.resolution_notes,
      assigned_at: ri.assigned_at,
      sla_warning_sent_at: ri.sla_warning_sent_at,
      inserted_at: ri.inserted_at,
      age_days: Review.age_days(ri)
    }
  end

  defp render_promotion(%Codefresh.Review.BranchPromotion{} = p) do
    %{
      id: p.id,
      organization_id: p.organization_id,
      source_freeball_node_id: p.source_freeball_node_id,
      source_script_version_id: p.source_script_version_id,
      target_script_version_id: p.target_script_version_id,
      target_kind: p.target_kind,
      promoted_by_user_id: p.promoted_by_user_id,
      node_mapping: p.node_mapping,
      edge_additions: p.edge_additions,
      notes: p.notes,
      inserted_at: p.inserted_at
    }
  end

  # ---------------------------------------------------------------------------
  # Param helpers
  # ---------------------------------------------------------------------------

  defp maybe_put(opts, _k, nil), do: opts
  defp maybe_put(opts, _k, ""), do: opts
  defp maybe_put(opts, _k, []), do: opts
  defp maybe_put(opts, k, v), do: Keyword.put(opts, k, v)

  defp atomize_attrs(params) do
    %{
      resolution_notes: Map.get(params, "resolution_notes"),
      flag_regression: Map.get(params, "flag_regression")
    }
  end

  defp param_int(nil), do: nil
  defp param_int(""), do: nil
  defp param_int(v) when is_integer(v), do: v

  defp param_int(v) when is_binary(v) do
    case Integer.parse(v) do
      {n, _} -> n
      :error -> nil
    end
  end

  defp param_int(_), do: nil

  defp param_uuid(nil), do: nil
  defp param_uuid(""), do: nil
  defp param_uuid(v) when is_binary(v), do: v
  defp param_uuid(_), do: nil

  defp param_sort("oldest_first"), do: :oldest_first
  defp param_sort("oldest"), do: :oldest_first
  defp param_sort("priority_desc"), do: :priority_desc
  defp param_sort(_), do: nil

  defp param_statuses(nil), do: nil
  defp param_statuses(""), do: nil

  defp param_statuses(v) when is_binary(v) do
    v
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&(&1 != ""))
    |> case do
      [] -> nil
      list -> list
    end
  end

  defp param_statuses(v) when is_list(v), do: v
  defp param_statuses(_), do: nil

  defp my_queue_user(%{"mine" => mine}, user) when mine in [true, "true", "1", 1] do
    user.id
  end

  defp my_queue_user(_params, _user), do: nil
end
