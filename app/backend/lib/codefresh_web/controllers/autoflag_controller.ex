defmodule CodefreshWeb.AutoflagController do
  @moduledoc """
  CRUD for auto-flagging rules (US-147). Rules are org-scoped; viewers can
  list, editors can create/update, admins can soft-delete.

  The actual eval pipeline lives in `Codefresh.AutoFlag.Worker` and runs
  after a run finalizes — this controller only manages rule definitions.
  """

  use CodefreshWeb, :controller

  alias Codefresh.{AutoFlag, Organizations}
  alias Codefresh.Guardian

  # ──────────────────────────────────────────────────────────────────────────
  # List / Show
  # ──────────────────────────────────────────────────────────────────────────

  def index(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      opts =
        []
        |> maybe_put(:include_deleted, truthy?(params["include_deleted"]))
        |> maybe_put(:only_enabled, truthy?(params["only_enabled"]))

      rules = AutoFlag.list_rules(org_id, opts)
      json(conn, %{rules: Enum.map(rules, &render_rule/1)})
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def show(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         rule when not is_nil(rule) <- AutoFlag.get_rule(org_id, id) do
      json(conn, %{rule: render_rule(rule)})
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Create / Update / Soft-delete
  # ──────────────────────────────────────────────────────────────────────────

  def create(conn, %{"organization_id" => org_id, "rule" => params}) when is_map(params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor") do
      case AutoFlag.create_rule(org_id, params) do
        {:ok, rule} ->
          conn |> put_status(:created) |> json(%{rule: render_rule(rule)})

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

  def create(conn, _),
    do: bad_request(conn, "Expected {rule: {name, rule_type, config, default_reason, ...}}")

  def update(conn, %{"organization_id" => org_id, "id" => id, "rule" => params})
      when is_map(params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         rule when not is_nil(rule) <- AutoFlag.get_rule(org_id, id),
         {:ok, updated} <- AutoFlag.update_rule(rule, params) do
      json(conn, %{rule: render_rule(updated)})
    else
      nil ->
        send_resp(conn, 404, "")

      {:error, :forbidden} ->
        send_resp(conn, 403, "")

      {:error, :not_a_member} ->
        send_resp(conn, 404, "")

      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
    end
  end

  def update(conn, _), do: bad_request(conn, "Expected {rule: {...}}")

  def delete(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "admin"),
         rule when not is_nil(rule) <- AutoFlag.get_rule(org_id, id),
         {:ok, _} <- AutoFlag.soft_delete_rule(rule) do
      send_resp(conn, 204, "")
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
      {:error, _} -> send_resp(conn, 422, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Rendering / helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp render_rule(r) do
    %{
      id: r.id,
      name: r.name,
      rule_type: r.rule_type,
      config: r.config,
      default_reason: r.default_reason,
      default_tags: r.default_tags,
      enabled: r.enabled,
      match_count: r.match_count,
      soft_deleted_at: r.soft_deleted_at,
      inserted_at: r.inserted_at,
      updated_at: r.updated_at
    }
  end

  defp maybe_put(opts, _k, false), do: opts
  defp maybe_put(opts, k, v), do: Keyword.put(opts, k, v)

  defp bad_request(conn, msg), do: conn |> put_status(:bad_request) |> json(%{error: msg})

  defp truthy?(v) when v in [true, "true", "1", 1], do: true
  defp truthy?(_), do: false
end
