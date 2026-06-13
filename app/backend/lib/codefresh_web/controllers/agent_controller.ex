defmodule CodefreshWeb.AgentController do
  use CodefreshWeb, :controller

  alias Codefresh.{Agents, Organizations}
  alias Codefresh.Guardian

  # ──────────────────────────────────────────────────────────────────────────
  # Library listing
  # ──────────────────────────────────────────────────────────────────────────

  def index(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      opts =
        []
        |> maybe_put(:search, params["q"])
        |> maybe_put(:include_archived, truthy?(params["include_archived"]))
        |> maybe_put(:only_published, truthy?(params["only_published"]))

      agents = Agents.list_agents(org_id, opts)
      json(conn, %{agents: Enum.map(agents, &render_agent/1)})
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-012 / US-061 / US-062 / US-063 — Create head (adapter chosen on publish)
  # US-064 — Cost governance fields accepted here
  # ──────────────────────────────────────────────────────────────────────────

  def create(conn, %{"organization_id" => org_id, "agent" => agent_params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor") do
      attrs =
        agent_params
        |> Map.put("organization_id", org_id)
        |> Map.put("created_by_user_id", user.id)

      case Agents.create_agent(attrs) do
        {:ok, agent} ->
          conn
          |> put_status(:created)
          |> json(%{agent: render_agent(agent)})

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

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      error:
        "Expected {agent: {name, description?, slug?, daily_cost_cap_usd?, rate_limit_per_min?}}"
    })
  end

  def show(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         agent when not is_nil(agent) <- safe_get(org_id, id) do
      versions = Agents.list_versions(agent)

      current =
        case agent.current_version_id do
          nil -> nil
          vid -> Enum.find(versions, &(&1.id == vid))
        end

      json(conn, %{
        agent: render_agent(agent),
        current_version: render_version(current),
        versions: Enum.map(versions, &render_version_summary/1)
      })
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def update(conn, %{"organization_id" => org_id, "id" => id, "agent" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         agent when not is_nil(agent) <- safe_get(org_id, id),
         {:ok, updated} <- Agents.update_agent(agent, params) do
      json(conn, %{agent: render_agent(updated)})
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

  def archive(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         agent when not is_nil(agent) <- safe_get(org_id, id),
         {:ok, _} <- Agents.archive_agent(agent) do
      send_resp(conn, 204, "")
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
      {:error, _} -> send_resp(conn, 422, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-014 — Publish version
  # ──────────────────────────────────────────────────────────────────────────

  def publish(conn, %{"organization_id" => org_id, "id" => id, "version" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         agent when not is_nil(agent) <- safe_get(org_id, id) do
      attrs = Map.put(params, "published_by_user_id", user.id)

      case Agents.publish_version(agent, attrs) do
        {:ok, :published, version} ->
          conn
          |> put_status(:created)
          |> json(%{version: render_version(version), status: "published"})

        {:ok, :noop, version} ->
          conn
          |> put_status(:ok)
          |> json(%{
            version: render_version(version),
            status: "noop",
            note: "identical config already published"
          })

        {:error, :unknown_adapter, adapter} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "unknown adapter", adapter: adapter})

        {:error, reason} when is_binary(reason) ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "invalid adapter config", reason: reason})

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

  def publish(conn, _) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Expected {version: {adapter, model?, auth_ref?, …}}"})
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-011-equivalent — current version resolver
  # ──────────────────────────────────────────────────────────────────────────

  def current_version(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      case Agents.resolve_current_version(org_id, id) do
        {:ok, version} ->
          json(conn, %{version: render_version(version)})

        {:error, :not_found} ->
          send_resp(conn, 404, "")

        {:error, :not_published} ->
          conn
          |> put_status(:conflict)
          |> json(%{error: "agent has no published version — publish before pinning"})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-013 — Health check (config-validation only; no network)
  # ──────────────────────────────────────────────────────────────────────────

  def health(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         agent when not is_nil(agent) <- safe_get(org_id, id) do
      case Agents.health_check(agent) do
        {:ok, :config_valid} ->
          json(conn, %{status: "ok", note: "config valid; network probe not performed"})

        {:ok, :not_implemented} ->
          json(conn, %{status: "not_implemented", note: "adapter stubbed; real probe post-MVP"})

        {:error, :not_published} ->
          conn |> put_status(:conflict) |> json(%{error: "agent has no published version"})

        {:error, :unknown_adapter, adapter} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "unknown adapter", adapter: adapter})

        {:error, reason} when is_binary(reason) ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "invalid adapter config", reason: reason})
      end
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Renderers
  # ──────────────────────────────────────────────────────────────────────────

  defp render_agent(a) do
    %{
      id: a.id,
      slug: a.slug,
      name: a.name,
      description: a.description,
      current_version_id: a.current_version_id,
      archived_at: a.archived_at,
      daily_cost_cap_usd: a.daily_cost_cap_usd,
      rate_limit_per_min: a.rate_limit_per_min,
      created_at: a.inserted_at,
      updated_at: a.updated_at
    }
  end

  defp render_version(nil), do: nil

  defp render_version(v) do
    %{
      id: v.id,
      version_number: v.version_number,
      adapter: v.adapter,
      config: %{
        model: v.model,
        base_url: v.endpoint_url,
        auth_ref: v.auth_ref,
        headers: v.headers,
        request_template: v.request_template,
        aws_region: get_in(v.request_template || %{}, ["aws_region"]),
        project_id: get_in(v.request_template || %{}, ["project_id"]),
        max_tokens: get_in(v.request_template || %{}, ["max_tokens"])
      },
      response_jsonpath: v.response_jsonpath,
      model_tier: v.model_tier,
      checksum: if(v.checksum, do: Base.encode16(v.checksum, case: :lower), else: nil),
      published_at: v.inserted_at,
      published_by_user_id: v.published_by_user_id
    }
  end

  defp render_version_summary(v) do
    %{
      id: v.id,
      version_number: v.version_number,
      adapter: v.adapter,
      checksum: Base.encode16(v.checksum, case: :lower),
      published_at: v.inserted_at,
      published_by_user_id: v.published_by_user_id
    }
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp safe_get(org_id, id) do
    Agents.get_agent(org_id, id)
  rescue
    Ecto.Query.CastError -> nil
  end

  defp maybe_put(opts, _k, nil), do: opts
  defp maybe_put(opts, _k, ""), do: opts
  defp maybe_put(opts, _k, false), do: opts
  defp maybe_put(opts, k, v), do: Keyword.put(opts, k, v)

  defp truthy?(v) when v in [true, "true", "1", 1], do: true
  defp truthy?(_), do: false
end
