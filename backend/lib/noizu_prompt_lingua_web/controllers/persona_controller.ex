defmodule NoizuPromptLinguaWeb.PersonaController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.Personas
  alias NoizuPromptLingua.Authz

  # GET /api/v1/organizations/:org_id/personas
  def index(conn, %{"org_id" => org_id} = params) do
    with_org(conn, org_id, "viewer", fn resolved_org_id ->
      # With a project, return the effective list: project personas + org-level.
      opts =
        [organization_id: resolved_org_id]
        |> maybe_opt(:project_id, params["project_id"])
        |> maybe_effective(params["project_id"])
        |> maybe_opt(:status, params["status"])
        |> maybe_opt(:tag, params["tag"])

      personas = Personas.list(opts)

      json(conn, %{
        personas: Enum.map(personas, &persona_json/1),
        statuses: NoizuPromptLingua.Schema.Persona.statuses()
      })
    end)
  end

  # POST /api/v1/organizations/:org_id/personas
  def create(conn, %{"org_id" => org_id, "persona" => params}) do
    with_org(conn, org_id, "member", fn resolved_org_id ->
      with {:ok, project_id} <- validate_project(params["project_id"], resolved_org_id) do
        attrs =
          take_attrs(params)
          |> Map.merge(%{organization_id: resolved_org_id, project_id: project_id})

        case Personas.create(attrs) do
          {:ok, p} ->
            conn |> put_status(:created) |> json(%{persona: persona_json(p)})

          {:error, cs} ->
            conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
        end
      else
        {:error, :project_not_in_org} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "Project does not belong to this organization"})
      end
    end)
  end

  # GET /api/v1/organizations/:org_id/personas/:id
  def show(conn, %{"org_id" => org_id, "id" => id}) do
    with_owned(conn, org_id, id, "viewer", fn p ->
      json(conn, %{
        persona: persona_json(p),
        journal: Enum.map(Personas.list_journal(p.id, limit: 50), &journal_json/1),
        knowledge_base: Enum.map(Personas.list_knowledge(p.id), &kb_json/1)
      })
    end)
  end

  # PUT /api/v1/organizations/:org_id/personas/:id
  def update(conn, %{"org_id" => org_id, "id" => id, "persona" => params}) do
    with_owned(conn, org_id, id, "member", fn _p ->
      case Personas.update(id, take_attrs(params)) do
        {:ok, p} ->
          json(conn, %{persona: persona_json(p)})

        {:error, :not_found} ->
          not_found(conn)

        {:error, cs} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
      end
    end)
  end

  # DELETE /api/v1/organizations/:org_id/personas/:id
  def delete(conn, %{"org_id" => org_id, "id" => id}) do
    with_owned(conn, org_id, id, "member", fn _p ->
      case Personas.delete(id) do
        {:ok, _} -> json(conn, %{message: "Persona deleted"})
        {:error, :not_found} -> not_found(conn)
      end
    end)
  end

  # ── Journal ───────────────────────────────────────────────────

  # GET /api/v1/organizations/:org_id/personas/:persona_id/journal
  def journal(conn, %{"org_id" => org_id, "persona_id" => id} = params) do
    with_owned(conn, org_id, id, "viewer", fn _p ->
      opts = [] |> maybe_opt(:category, params["category"])
      json(conn, %{journal: Enum.map(Personas.list_journal(id, opts), &journal_json/1)})
    end)
  end

  # POST /api/v1/organizations/:org_id/personas/:persona_id/journal
  def add_journal(conn, %{"org_id" => org_id, "persona_id" => id, "entry" => params}) do
    with_owned(conn, org_id, id, "member", fn _p ->
      attrs = Map.merge(take_journal(params), %{actor: actor(conn)})

      case Personas.add_journal_entry(id, attrs) do
        {:ok, j} ->
          conn |> put_status(:created) |> json(%{entry: journal_json(j)})

        {:error, cs} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
      end
    end)
  end

  # DELETE /api/v1/organizations/:org_id/personas/:persona_id/journal/:entry_id
  def delete_journal(conn, %{"org_id" => org_id, "persona_id" => id, "entry_id" => entry_id}) do
    with_owned(conn, org_id, id, "member", fn _p ->
      case Personas.delete_journal_entry(entry_id) do
        {:ok, _} -> json(conn, %{message: "Entry deleted"})
        {:error, :not_found} -> not_found(conn)
      end
    end)
  end

  # ── Knowledge base ────────────────────────────────────────────

  # GET /api/v1/organizations/:org_id/personas/:persona_id/knowledge
  def knowledge(conn, %{"org_id" => org_id, "persona_id" => id} = params) do
    with_owned(conn, org_id, id, "viewer", fn _p ->
      opts = [] |> maybe_opt(:tag, params["tag"])
      json(conn, %{knowledge_base: Enum.map(Personas.list_knowledge(id, opts), &kb_full_json/1)})
    end)
  end

  # POST /api/v1/organizations/:org_id/personas/:persona_id/knowledge
  def add_knowledge(conn, %{"org_id" => org_id, "persona_id" => id, "entry" => params}) do
    with_owned(conn, org_id, id, "member", fn _p ->
      case Personas.add_knowledge(id, take_kb(params)) do
        {:ok, k} ->
          conn |> put_status(:created) |> json(%{entry: kb_full_json(k)})

        {:error, cs} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
      end
    end)
  end

  # PUT /api/v1/organizations/:org_id/personas/:persona_id/knowledge/:entry_id
  def update_knowledge(conn, %{
        "org_id" => org_id,
        "persona_id" => id,
        "entry_id" => entry_id,
        "entry" => params
      }) do
    with_owned(conn, org_id, id, "member", fn _p ->
      case Personas.update_knowledge(entry_id, take_kb(params)) do
        {:ok, k} ->
          json(conn, %{entry: kb_full_json(k)})

        {:error, :not_found} ->
          not_found(conn)

        {:error, cs} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
      end
    end)
  end

  # DELETE /api/v1/organizations/:org_id/personas/:persona_id/knowledge/:entry_id
  def delete_knowledge(conn, %{"org_id" => org_id, "persona_id" => id, "entry_id" => entry_id}) do
    with_owned(conn, org_id, id, "member", fn _p ->
      case Personas.delete_knowledge(entry_id) do
        {:ok, _} -> json(conn, %{message: "Entry deleted"})
        {:error, :not_found} -> not_found(conn)
      end
    end)
  end

  # ── JSON ──────────────────────────────────────────────────────

  defp persona_json(p) do
    %{
      id: p.id,
      organization_id: p.organization_id,
      project_id: p.project_id,
      slug: p.slug,
      name: p.name,
      role: p.role,
      bio: p.bio,
      avatar: p.avatar,
      tags: p.tags,
      status: p.status,
      inserted_at: p.inserted_at,
      updated_at: p.updated_at
    }
  end

  defp journal_json(j) do
    %{
      id: j.id,
      category: j.category,
      title: j.title,
      body: j.body,
      actor: j.actor,
      tags: j.tags,
      inserted_at: j.inserted_at
    }
  end

  defp kb_json(k), do: %{id: k.id, slug: k.slug, title: k.title, tags: k.tags, source: k.source}

  defp kb_full_json(k) do
    %{
      id: k.id,
      slug: k.slug,
      title: k.title,
      body: k.body,
      tags: k.tags,
      source: k.source,
      inserted_at: k.inserted_at,
      updated_at: k.updated_at
    }
  end

  defp take_attrs(params) do
    params |> Map.take(~w(slug name role bio avatar tags status)) |> atomize()
  end

  defp take_journal(params) do
    params |> Map.take(~w(category title body tags)) |> atomize()
  end

  defp take_kb(params) do
    params |> Map.take(~w(slug title body tags source)) |> atomize()
  end

  defp atomize(map), do: Map.new(map, fn {k, v} -> {String.to_existing_atom(k), v} end)

  defp validate_project(nil, _org_id), do: {:ok, nil}
  defp validate_project("", _org_id), do: {:ok, nil}

  defp validate_project(project_id, org_id) do
    case NoizuPromptLingua.Projects.get_project(project_id) do
      %{organization_id: ^org_id} -> {:ok, project_id}
      _ -> {:error, :project_not_in_org}
    end
  end

  defp with_owned(conn, org_id, id, role, fun) do
    with_org(conn, org_id, role, fn resolved_org_id ->
      case Personas.get(id) do
        nil -> not_found(conn)
        %{organization_id: ^resolved_org_id} = p -> fun.(p)
        _ -> not_found(conn)
      end
    end)
  end

  defp not_found(conn), do: conn |> put_status(:not_found) |> json(%{error: "Persona not found"})

  defp maybe_opt(opts, _key, nil), do: opts
  defp maybe_opt(opts, _key, ""), do: opts
  defp maybe_opt(opts, key, val), do: Keyword.put(opts, key, val)

  # Fold org-level personas into a project-scoped listing (effective list).
  defp maybe_effective(opts, project_id) when project_id in [nil, ""], do: opts
  defp maybe_effective(opts, _project_id), do: Keyword.put(opts, :include_org_level, true)

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

  defp actor(conn), do: get_user_id(conn)

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
