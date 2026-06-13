defmodule CodefreshWeb.CaptureController do
  @moduledoc """
  Stage 9 flagged-captures controller. Covers:
    * Manual flag (US-106)
    * Browse library w/ filters + typeahead (US-107)
    * Promote to script node (US-108)
    * Promote to dataset entry — including bug-negative mode (US-109)

  Auto-flagging rules (US-147) surface manually here via the `auto_rule_id`
  payload field — the engine itself is wired downstream in the webhooks +
  runs pipeline.
  """

  use CodefreshWeb, :controller

  alias Codefresh.{Datasets, Organizations}
  alias Codefresh.Guardian

  # ──────────────────────────────────────────────────────────────────────────
  # Flag (US-106)
  # ──────────────────────────────────────────────────────────────────────────

  def create(conn, %{"organization_id" => org_id, "capture" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor") do
      attrs =
        params
        |> Map.put("organization_id", org_id)
        |> Map.put("flagged_by_user_id", user.id)

      case Datasets.flag_capture(attrs) do
        {:ok, c} ->
          conn |> put_status(:created) |> json(%{capture: render_capture(c)})

        {:error, cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def create(conn, _), do: bad_request(conn, "Expected {capture: {title, reason, input, ...}}")

  # ──────────────────────────────────────────────────────────────────────────
  # Browse (US-107)
  # ──────────────────────────────────────────────────────────────────────────

  def index(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      opts =
        []
        |> maybe_put(:reason, params["reason"])
        |> maybe_put(:flagged_by_user_id, params["flagged_by"])
        |> maybe_put(:tag, params["tag"])
        |> maybe_put(:q, params["q"])
        |> maybe_put(:promoted, promoted_filter(params["promoted"]))
        |> maybe_put(:since, parse_iso8601(params["since"]))
        |> maybe_put(:until, parse_iso8601(params["until"]))

      rows = Datasets.list_captures(org_id, opts)
      json(conn, %{captures: Enum.map(rows, &render_capture/1)})
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def show(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         c when not is_nil(c) <- Datasets.get_capture(org_id, id) do
      json(conn, %{capture: render_capture(c)})
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Promote to script node (US-108)
  # ──────────────────────────────────────────────────────────────────────────

  def promote_to_script_node(conn, %{
        "organization_id" => org_id,
        "id" => id,
        "script_node_id" => node_id
      }) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         c when not is_nil(c) <- Datasets.get_capture(org_id, id),
         {:ok, updated} <- Datasets.promote_to_script_node(c, node_id) do
      json(conn, %{capture: render_capture(updated)})
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")

      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Promote to dataset entry (US-109)
  # ──────────────────────────────────────────────────────────────────────────

  def promote_to_dataset_entry(conn, %{
        "organization_id" => org_id,
        "id" => id,
        "dataset_id" => dataset_id
      } = params) do
    user = Guardian.Plug.current_resource(conn)
    negative? = truthy?(params["negative"])
    extra_tags = params["extra_tags"] || []

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         c when not is_nil(c) <- Datasets.get_capture(org_id, id),
         d when not is_nil(d) <- Datasets.get_dataset(org_id, dataset_id),
         {:ok, %{capture: cap, entry: entry}} <-
           Datasets.promote_to_dataset_entry(c, d, negative?: negative?, extra_tags: extra_tags) do
      conn
      |> put_status(:created)
      |> json(%{
        capture: render_capture(cap),
        entry: %{
          id: entry.id,
          entry_key: entry.entry_key,
          dataset_version_id: entry.dataset_version_id,
          tags: entry.tags
        }
      })
    else
      nil ->
        send_resp(conn, 404, "")

      {:error, :forbidden} ->
        send_resp(conn, 403, "")

      {:error, :not_a_member} ->
        send_resp(conn, 404, "")

      {:error, :cross_org_promotion} ->
        send_resp(conn, 404, "")

      {:error, cs} when is_struct(cs, Ecto.Changeset) ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})

      {:error, reason} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Renderers
  # ──────────────────────────────────────────────────────────────────────────

  defp render_capture(c) do
    %{
      id: c.id,
      title: c.title,
      notes: c.notes,
      tags: c.tags,
      reason: c.reason,
      source_trace_id: c.source_trace_id,
      source_span_id: c.source_span_id,
      source_run_step_id: c.source_run_step_id,
      input: c.input,
      agent_response: c.agent_response,
      captured_attributes: c.captured_attributes,
      auto_rule_id: c.auto_rule_id,
      promoted_to_script_node_id: c.promoted_to_script_node_id,
      promoted_to_dataset_entry_id: c.promoted_to_dataset_entry_id,
      flagged_by_user_id: c.flagged_by_user_id,
      inserted_at: c.inserted_at,
      updated_at: c.updated_at
    }
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp promoted_filter(nil), do: nil
  defp promoted_filter(""), do: nil
  defp promoted_filter("any"), do: :any
  defp promoted_filter("unpromoted"), do: :unpromoted
  defp promoted_filter("to_script"), do: :to_script
  defp promoted_filter("to_dataset"), do: :to_dataset
  defp promoted_filter(_), do: nil

  defp parse_iso8601(nil), do: nil
  defp parse_iso8601(""), do: nil

  defp parse_iso8601(s) do
    case DateTime.from_iso8601(s) do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end

  defp bad_request(conn, msg), do: conn |> put_status(:bad_request) |> json(%{error: msg})

  defp maybe_put(opts, _k, nil), do: opts
  defp maybe_put(opts, _k, ""), do: opts
  defp maybe_put(opts, _k, false), do: opts
  defp maybe_put(opts, k, v), do: Keyword.put(opts, k, v)

  defp truthy?(v) when v in [true, "true", "1", 1], do: true
  defp truthy?(_), do: false
end
