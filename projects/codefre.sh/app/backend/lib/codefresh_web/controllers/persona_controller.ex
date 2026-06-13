defmodule CodefreshWeb.PersonaController do
  use CodefreshWeb, :controller

  alias Codefresh.{Personas, Organizations}
  alias Codefresh.Personas.StarterLibrary
  alias Codefresh.Guardian

  # ──────────────────────────────────────────────────────────────────────────
  # Head CRUD (US-035)
  # ──────────────────────────────────────────────────────────────────────────

  def index(conn, %{"organization_id" => org_id} = params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      opts =
        []
        |> maybe_put(:search, params["q"])
        |> maybe_put(:tone, params["tone"])
        |> maybe_put(:include_archived, truthy?(params["include_archived"]))

      rows = Personas.list_personas(org_id, opts)
      json(conn, %{personas: Enum.map(rows, &render_persona/1)})
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def create(conn, %{"organization_id" => org_id, "persona" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor") do
      attrs =
        params
        |> Map.put("organization_id", org_id)
        |> Map.put("created_by_user_id", user.id)

      case Personas.create_persona(attrs) do
        {:ok, p} ->
          conn |> put_status(:created) |> json(%{persona: render_persona(p)})

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

  def create(conn, _), do: bad_request(conn, "Expected {persona: {name, slug?, description?}}")

  def show(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         p when not is_nil(p) <- safe_get(org_id, id) do
      versions = Personas.list_versions(p)

      current =
        case p.current_version_id do
          nil -> nil
          vid -> Enum.find(versions, &(&1.id == vid))
        end

      json(conn, %{
        persona: render_persona(p),
        current_version: render_version(current),
        versions: Enum.map(versions, &render_version_summary/1)
      })
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def update(conn, %{"organization_id" => org_id, "id" => id, "persona" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         p when not is_nil(p) <- safe_get(org_id, id),
         {:ok, updated} <- Personas.update_persona(p, params) do
      json(conn, %{persona: render_persona(updated)})
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
         p when not is_nil(p) <- safe_get(org_id, id),
         {:ok, _} <- Personas.archive_persona(p) do
      send_resp(conn, 204, "")
    else
      nil -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
      {:error, _} -> send_resp(conn, 422, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Publish version (US-035 + US-053)
  # ──────────────────────────────────────────────────────────────────────────

  def publish(conn, %{"organization_id" => org_id, "id" => id, "version" => params}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor"),
         p when not is_nil(p) <- safe_get(org_id, id) do
      attrs = Map.put(params, "published_by_user_id", user.id)

      case Personas.publish_version(p, attrs) do
        {:ok, :published, v} ->
          conn
          |> put_status(:created)
          |> json(%{version: render_version(v), status: "published"})

        {:ok, :noop, v} ->
          conn
          |> put_status(:ok)
          |> json(%{
            version: render_version(v),
            status: "noop",
            note: "identical body already published"
          })

        {:error, :preamble_not_pinnable} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "system_prompt_version_id must resolve to a prompt in this org"})

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

  def publish(conn, _),
    do: bad_request(conn, "Expected {version: {tone?, description?, system_prompt_version_id?}}")

  def current_version(conn, %{"organization_id" => org_id, "id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer") do
      case Personas.resolve_current_version(org_id, id) do
        {:ok, v} ->
          json(conn, %{version: render_version(v)})

        {:error, :not_found} ->
          send_resp(conn, 404, "")

        {:error, :not_published} ->
          conn
          |> put_status(:conflict)
          |> json(%{error: "persona has no published version — publish before pinning"})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Starter library (US-055)
  # ──────────────────────────────────────────────────────────────────────────

  def starters_index(conn, _params) do
    # Starter catalog is not org-scoped — any authenticated user may browse.
    json(conn, %{starters: StarterLibrary.list()})
  end

  def import_starter(conn, %{"organization_id" => org_id, "starter_slug" => slug}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor") do
      case Personas.import_from_starter(org_id, slug, imported_by_user_id: user.id) do
        {:ok, %{persona: p, version: v}} ->
          conn
          |> put_status(:created)
          |> json(%{persona: render_persona(p), version: render_version(v)})

        {:error, :not_found} ->
          conn |> put_status(:not_found) |> json(%{error: "starter not found", slug: slug})

        {:error, reason} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "import failed", reason: inspect(reason)})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Persona expectations (US-051)
  # ──────────────────────────────────────────────────────────────────────────

  def list_expectations(conn, %{
        "organization_id" => org_id,
        "id" => _persona_id,
        "version_id" => version_id
      }) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "viewer"),
         true <- Personas.pinnable?(org_id, version_id) || :not_in_org do
      rows = Personas.list_persona_expectations(version_id)
      json(conn, %{expectations: Enum.map(rows, &render_expectation/1)})
    else
      :not_in_org -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  def create_expectation(conn, %{
        "organization_id" => org_id,
        "id" => _persona_id,
        "version_id" => version_id,
        "expectation" => params
      }) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor") do
      attrs =
        params
        |> Map.put("persona_version_id", version_id)
        |> Map.put("organization_id", org_id)

      case Personas.create_persona_expectation(attrs) do
        {:ok, pe} ->
          conn
          |> put_status(:created)
          |> json(%{expectation: render_expectation(pe)})

        {:error, reason} when reason in [:persona_not_in_org, :script_node_not_in_org] ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: to_string(reason)})

        {:error, :rubric_required} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "rubric_version_id required when scoring_method is 'rubric'"})

        {:error, :rubric_not_pinnable} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "rubric_version_id must resolve to a rubric in this org"})

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
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Attach to run (US-036)
  # ──────────────────────────────────────────────────────────────────────────

  def attach_to_run(conn, %{
        "organization_id" => org_id,
        "run_id" => run_id,
        "persona_version_id" => pvid
      }) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, _} <- Organizations.authorize(user, org_id, "editor") do
      case Personas.attach_to_run(run_id, pvid, org_id) do
        {:ok, row} ->
          conn
          |> put_status(:created)
          |> json(%{
            run_persona: %{
              id: row.id,
              run_id: row.run_id,
              persona_version_id: row.persona_version_id
            }
          })

        {:error, :persona_not_pinnable} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "persona_version_id must resolve to a persona in this org"})

        {:error, reason} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: inspect(reason)})
      end
    else
      {:error, :forbidden} -> send_resp(conn, 403, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
    end
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Renderers
  # ──────────────────────────────────────────────────────────────────────────

  defp render_persona(p) do
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
  end

  defp render_version(nil), do: nil

  defp render_version(v) do
    %{
      id: v.id,
      version_number: v.version_number,
      tone: v.tone,
      description: v.description,
      metadata: v.metadata,
      system_prompt_version_id: v.system_prompt_version_id,
      checksum: Base.encode16(v.checksum, case: :lower),
      published_at: v.inserted_at,
      published_by_user_id: v.published_by_user_id
    }
  end

  defp render_version_summary(v) do
    %{
      id: v.id,
      version_number: v.version_number,
      tone: v.tone,
      checksum: Base.encode16(v.checksum, case: :lower),
      published_at: v.inserted_at
    }
  end

  defp render_expectation(pe) do
    %{
      id: pe.id,
      persona_version_id: pe.persona_version_id,
      script_node_id: pe.script_node_id,
      label: pe.label,
      weight: if(is_struct(pe.weight, Decimal), do: Decimal.to_float(pe.weight), else: pe.weight),
      direction: case pe.direction do
        "positive" -> "pass"
        "negative" -> "fail"
        other -> other
      end,
      scoring_method: pe.scoring_method,
      config: pe.config,
      rubric_version_id: pe.rubric_version_id,
      inserted_at: pe.inserted_at
    }
  end

  # ──────────────────────────────────────────────────────────────────────────
  # Helpers
  # ──────────────────────────────────────────────────────────────────────────

  defp safe_get(org_id, id) do
    Personas.get_persona(org_id, id)
  rescue
    Ecto.Query.CastError -> nil
  end

  defp bad_request(conn, msg), do: conn |> put_status(:bad_request) |> json(%{error: msg})

  defp maybe_put(opts, _k, nil), do: opts
  defp maybe_put(opts, _k, ""), do: opts
  defp maybe_put(opts, _k, false), do: opts
  defp maybe_put(opts, k, v), do: Keyword.put(opts, k, v)

  defp truthy?(v) when v in [true, "true", "1", 1], do: true
  defp truthy?(_), do: false
end
