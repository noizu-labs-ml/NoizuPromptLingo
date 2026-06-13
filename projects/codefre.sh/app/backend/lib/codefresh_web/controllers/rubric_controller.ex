defmodule CodefreshWeb.RubricController do
  use CodefreshWeb, :controller

  alias Codefresh.{Rubrics, Organizations}
  alias Codefresh.Guardian

  def index(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      opts =
        []
        |> maybe_put(:search, params["q"])
        |> maybe_put(:include_archived, truthy?(params["include_archived"]))
        |> maybe_put(:only_published, truthy?(params["only_published"]))

      rows = Rubrics.list_rubrics(org_id, opts)
      json(conn, %{rubrics: Enum.map(rows, &render_rubric/1)})
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def create(conn, %{"organization_id" => org_id, "rubric" => rubric_params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor") do
      attrs =
        rubric_params
        |> Map.put("organization_id", org_id)
        |> Map.put("created_by_user_id", user.id)

      case Rubrics.create_rubric(attrs) do
        {:ok, r} ->
          conn |> put_status(:created) |> json(%{rubric: render_rubric(r)})

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
    do:
      conn
      |> put_status(:bad_request)
      |> json(%{error: "Expected {rubric: {name, description?, slug?}}"})

  def show(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         r when not is_nil(r) <- safe_get(org_id, id) do
      versions = Rubrics.list_versions(r)
      current = Enum.find(versions, &(&1.id == r.current_version_id))

      json(conn, %{
        rubric: render_rubric(r),
        current_version: render_version(current),
        versions: Enum.map(versions, &render_version_summary/1)
      })
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def update(conn, %{"organization_id" => org_id, "id" => id, "rubric" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         r when not is_nil(r) <- safe_get(org_id, id),
         {:ok, updated} <- Rubrics.update_rubric(r, params) do
      json(conn, %{rubric: render_rubric(updated)})
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
         r when not is_nil(r) <- safe_get(org_id, id),
         {:ok, _} <- Rubrics.archive_rubric(r) do
      send_resp(conn, 204, "")
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
      {:error, _} -> send_resp(conn, 422, "")
    end
  end

  def publish(conn, %{"organization_id" => org_id, "id" => id, "version" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         r when not is_nil(r) <- safe_get(org_id, id) do
      attrs = Map.put(params, "published_by_user_id", user.id)

      case Rubrics.publish_version(r, attrs) do
        {:ok, :published, v} ->
          conn |> put_status(:created) |> json(%{version: render_version(v), status: "published"})

        {:ok, :noop, v} ->
          conn
          |> put_status(:ok)
          |> json(%{
            version: render_version(v),
            status: "noop",
            note: "identical config already published"
          })

        {:error, :judge_prompt_not_pinnable} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "judge_prompt_version_id must refer to a PromptVersion in this org"})

        {:error, {:required, field}} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "missing required field", field: to_string(field)})

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
    |> json(%{
      error: "Expected {version: {judge_prompt_version_id, judge_model, scale?, criteria?}}"
    })
  end

  # US-058 — Preview rubric by rendering judge prompt against a sample (no LLM call)
  def preview(conn, %{"organization_id" => org_id, "id" => id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor") do
      sample = params["sample"] || %{}

      case Rubrics.preview_render(org_id, id, sample) do
        {:ok, result} ->
          json(conn, Map.put(result, :note, "LLM execution deferred to Stage 4 (Agents)"))

        {:error, :not_found} ->
          send_resp(conn, 404, "")

        {:error, :not_published} ->
          conn
          |> put_status(:conflict)
          |> json(%{error: "rubric has no published version"})

        {:error, {:undeclared_vars, vars}} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "judge prompt has undeclared vars", undeclared_vars: vars})

        {:error, reason} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: inspect(reason)})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def current_version(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      case Rubrics.resolve_current_version(org_id, id) do
        {:ok, v} ->
          json(conn, %{version: render_version(v)})

        {:error, :not_found} ->
          send_resp(conn, 404, "")

        {:error, :not_published} ->
          conn
          |> put_status(:conflict)
          |> json(%{
            error: "rubric has no published version — publish before attaching to an expectation"
          })
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  defp render_rubric(r) do
    %{
      id: r.id,
      slug: r.slug,
      name: r.name,
      description: r.description,
      current_version_id: r.current_version_id,
      archived_at: r.archived_at,
      created_at: r.inserted_at,
      updated_at: r.updated_at
    }
  end

  defp render_version(nil), do: nil

  defp render_version(v) do
    %{
      id: v.id,
      version_number: v.version_number,
      judge_prompt_version_id: v.judge_prompt_version_id,
      judge_model: v.judge_model,
      scale: v.scale,
      criteria: v.criteria,
      n_samples: v.n_samples,
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

  defp safe_get(org_id, id) do
    Rubrics.get_rubric(org_id, id)
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
