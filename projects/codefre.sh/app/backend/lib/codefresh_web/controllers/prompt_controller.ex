defmodule CodefreshWeb.PromptController do
  use CodefreshWeb, :controller

  alias Codefresh.{Prompts, Organizations}
  alias Codefresh.Guardian

  # ──────────────────────────────────────────────────────────────────────────
  # US-050 — Library listing
  # ──────────────────────────────────────────────────────────────────────────

  def index(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      opts =
        []
        |> maybe_put(:search, params["q"])
        |> maybe_put(:include_archived, truthy?(params["include_archived"]))
        |> maybe_put(:only_published, truthy?(params["only_published"]))

      rows = Prompts.list_prompts(org_id, opts)

      json(conn, %{
        prompts: Enum.map(rows, &render_library_row/1)
      })
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-009 — Create
  # ──────────────────────────────────────────────────────────────────────────

  def create(conn, %{"organization_id" => org_id, "prompt" => prompt_params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor") do
      attrs =
        prompt_params
        |> Map.put("organization_id", org_id)
        |> Map.put("created_by_user_id", user.id)

      case Prompts.create_prompt(attrs) do
        {:ok, prompt} ->
          conn
          |> put_status(:created)
          |> json(%{prompt: render_prompt(prompt, usage_count: 0)})

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
    |> json(%{error: "Expected {prompt: {name, description?, slug?}}"})
  end

  def show(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         prompt when not is_nil(prompt) <- safe_get(org_id, id) do
      versions = Prompts.list_versions(prompt)

      current =
        case prompt.current_version_id do
          nil -> nil
          vid -> Enum.find(versions, &(&1.id == vid))
        end

      json(conn, %{
        prompt: render_prompt(prompt),
        current_version: render_version(current),
        versions: Enum.map(versions, &render_version_summary/1)
      })
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def update(conn, %{"organization_id" => org_id, "id" => id, "prompt" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         prompt when not is_nil(prompt) <- safe_get(org_id, id),
         {:ok, updated} <- Prompts.update_prompt(prompt, params) do
      json(conn, %{prompt: render_prompt(updated)})
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
         prompt when not is_nil(prompt) <- safe_get(org_id, id),
         {:ok, _} <- Prompts.archive_prompt(prompt) do
      send_resp(conn, 204, "")
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
      {:error, _} -> send_resp(conn, 422, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-010 — Publish version; US-048 — Template variables
  # ──────────────────────────────────────────────────────────────────────────

  def publish(conn, %{"organization_id" => org_id, "id" => id, "version" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         prompt when not is_nil(prompt) <- safe_get(org_id, id) do
      attrs = Map.put(params, "published_by_user_id", user.id)

      case Prompts.publish_version(prompt, attrs) do
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
            note: "identical body already published"
          })

        {:error, :undeclared_vars, vars} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{
            error: "body references undeclared template variables",
            undeclared_vars: vars
          })

        {:error, :invalid_tool_defs, reason} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "invalid tool_defs", reason: inspect(reason)})

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
    |> json(%{error: "Expected {version: {body, template_vars?, tool_defs?, metadata?}}"})
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-114 — Sandbox render (LLM execution deferred to Stage 4)
  # ──────────────────────────────────────────────────────────────────────────

  def sandbox(conn, %{"organization_id" => org_id, "id" => id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor") do
      attrs =
        case params["version"] do
          nil ->
            # Draft sandbox — use submitted body/template_vars/tool_defs directly
            params["sandbox"] || %{}

          "current" ->
            # Resolve current published version
            resolve_version_attrs(org_id, id)

          version_id when is_binary(version_id) ->
            resolve_version_by_id(org_id, id, version_id)
        end

      case attrs do
        {:error, reason} ->
          conn |> put_status(:not_found) |> json(%{error: to_string(reason)})

        _ ->
          bindings = params["bindings"] || %{}
          merged = Map.put(attrs, "bindings", bindings)

          case Prompts.sandbox_render(merged) do
            {:ok, result} ->
              json(conn, %{
                rendered: result.rendered,
                tool_names: result.tool_names,
                mode: result.mode,
                note: "LLM execution deferred to Stage 4 (Agents); this is a render-only preview"
              })

            {:error, {:undeclared_vars, vars}} ->
              conn
              |> put_status(:unprocessable_entity)
              |> json(%{error: "undeclared vars", undeclared_vars: vars})

            {:error, {:missing_required_vars, vars}} ->
              conn
              |> put_status(:unprocessable_entity)
              |> json(%{error: "missing required var bindings", missing: vars})

            {:error, reason} ->
              conn
              |> put_status(:unprocessable_entity)
              |> json(%{error: inspect(reason)})
          end
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  defp resolve_version_attrs(org_id, prompt_id) do
    case Prompts.resolve_current_version(org_id, prompt_id) do
      {:ok, v} ->
        %{"body" => v.body, "template_vars" => v.template_vars, "tool_defs" => v.tool_defs}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp resolve_version_by_id(org_id, prompt_id, version_id) do
    case safe_get(org_id, prompt_id) do
      nil ->
        {:error, :not_found}

      _prompt ->
        case Codefresh.Repo.get(Codefresh.Prompts.PromptVersion, version_id) do
          %{organization_id: ^org_id} = v ->
            %{"body" => v.body, "template_vars" => v.template_vars, "tool_defs" => v.tool_defs}

          _ ->
            {:error, :not_found}
        end
    end
  rescue
    Ecto.Query.CastError -> {:error, :not_found}
  end

  # ──────────────────────────────────────────────────────────────────────────
  # US-011 — Resolve current version for pinning
  # ──────────────────────────────────────────────────────────────────────────

  def current_version(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      case Prompts.resolve_current_version(org_id, id) do
        {:ok, version} ->
          json(conn, %{version: render_version(version)})

        {:error, :not_found} ->
          send_resp(conn, 404, "")

        {:error, :not_published} ->
          conn
          |> put_status(:conflict)
          |> json(%{error: "prompt has no published version — publish before pinning"})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Renderers
  # ──────────────────────────────────────────────────────────────────────────

  defp render_library_row(%{prompt: p, usage_count: uc}), do: render_prompt(p, usage_count: uc)

  defp render_prompt(p, extra \\ []) do
    %{
      id: p.id,
      slug: p.slug,
      name: p.name,
      description: p.description,
      current_version_id: p.current_version_id,
      archived_at: p.archived_at,
      created_at: p.inserted_at,
      updated_at: p.updated_at
    }
    |> Map.merge(Map.new(extra))
  end

  defp render_version(nil), do: nil

  defp render_version(v) do
    %{
      id: v.id,
      version_number: v.version_number,
      body: v.body,
      template_vars: v.template_vars,
      tool_defs: v.tool_defs,
      metadata: v.metadata,
      checksum: Base.encode16(v.checksum, case: :lower),
      published_at: v.inserted_at,
      published_by_user_id: v.published_by_user_id
    }
  end

  defp render_version_summary(v) do
    %{
      id: v.id,
      version_number: v.version_number,
      checksum: Base.encode16(v.checksum, case: :lower),
      published_at: v.inserted_at,
      published_by_user_id: v.published_by_user_id
    }
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp safe_get(org_id, id) do
    Prompts.get_prompt(org_id, id)
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
