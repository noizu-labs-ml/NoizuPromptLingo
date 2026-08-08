defmodule NoizuPromptLinguaWeb.ArtifactController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.Artifacts
  alias NoizuPromptLingua.Authz

  # GET /api/v1/organizations/:org_id/artifacts
  def index(conn, %{"org_id" => org_id} = params) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "viewer") do
      opts =
        [organization_id: resolved_org_id]
        |> maybe_opt(:project_id, params["project_id"])
        |> maybe_opt(:kind, params["kind"])
        |> maybe_opt(:search, params["search"])

      artifacts = Artifacts.list(opts)
      json(conn, %{artifacts: Enum.map(artifacts, &artifact_to_json/1)})
    else
      err -> handle_error(conn, err)
    end
  end

  # POST /api/v1/organizations/:org_id/artifacts
  def create(conn, %{"org_id" => org_id, "artifact" => artifact_params}) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "member"),
         {:ok, project_id} <- validate_project(artifact_params["project_id"], resolved_org_id) do
      attrs = %{
        organization_id: resolved_org_id,
        project_id: project_id,
        kind: artifact_params["kind"],
        title: artifact_params["title"],
        mime_type: artifact_params["mime_type"],
        content: artifact_params["content"]
      }

      case Artifacts.create(attrs) do
        {:ok, artifact} ->
          rev = List.first(artifact.revisions)

          conn
          |> put_status(:created)
          |> json(%{artifact: Map.put(artifact_to_json(artifact), :revision_id, rev && rev.id)})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    else
      err -> handle_error(conn, err)
    end
  end

  # GET /api/v1/organizations/:org_id/artifacts/:id
  def show(conn, %{"org_id" => org_id, "id" => id} = params) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "viewer"),
         {artifact, revision} when not is_nil(artifact) <-
           Artifacts.get(id, params["revision_id"]) || :missing,
         true <- artifact.organization_id == resolved_org_id do
      body =
        artifact_to_json(artifact)
        |> Map.put(:content, revision && revision.content)
        |> Map.put(:revision_id, revision && revision.id)
        |> Map.put(:revision_number, revision && revision.revision_number)

      json(conn, %{artifact: body})
    else
      :missing -> conn |> put_status(:not_found) |> json(%{error: "Artifact not found"})
      false -> conn |> put_status(:not_found) |> json(%{error: "Artifact not found"})
      err -> handle_error(conn, err)
    end
  end

  # GET /api/v1/organizations/:org_id/artifacts/:artifact_id/revisions
  #
  # Revision/lineage history for the artifact viewer (newest first). Metadata only —
  # `content` is NOT included here (the viewer fetches a chosen revision's body via
  # `show` with `?revision_id=`); keeps the history list cheap on large artifacts.
  def index_revisions(conn, %{"org_id" => org_id, "artifact_id" => artifact_id}) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "viewer"),
         {artifact, _revision} when not is_nil(artifact) <- Artifacts.get(artifact_id) || :missing,
         true <- artifact.organization_id == resolved_org_id do
      json(conn, %{revisions: Artifacts.list_revisions(artifact.id)})
    else
      :missing -> conn |> put_status(:not_found) |> json(%{error: "Artifact not found"})
      false -> conn |> put_status(:not_found) |> json(%{error: "Artifact not found"})
      err -> handle_error(conn, err)
    end
  end

  # POST /api/v1/organizations/:org_id/artifacts/:artifact_id/revisions  body {content, note?}
  #
  # Edit = APPEND a new revision (history-preserving), not a destructive PUT-in-place
  # (priya seq443 + the revisions viewer). `Artifacts.add_revision/3` auto-increments the
  # revision number; we return the artifact with its new current revision so the editor
  # reconciles in one round-trip. member role; org-scoped + artifact-belongs-to-org guard.
  def create_revision(conn, %{"org_id" => org_id, "artifact_id" => artifact_id} = params) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "member"),
         {artifact, _revision} when not is_nil(artifact) <- Artifacts.get(artifact_id) || :missing,
         true <- artifact.organization_id == resolved_org_id do
      case Artifacts.add_revision(artifact.id, params["content"], params["note"]) do
        {:ok, rev} ->
          body =
            artifact_to_json(artifact)
            |> Map.put(:content, rev.content)
            |> Map.put(:revision_id, rev.id)
            |> Map.put(:revision_number, rev.revision_number)

          conn |> put_status(:created) |> json(%{artifact: body})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    else
      :missing -> conn |> put_status(:not_found) |> json(%{error: "Artifact not found"})
      false -> conn |> put_status(:not_found) |> json(%{error: "Artifact not found"})
      err -> handle_error(conn, err)
    end
  end

  defp artifact_to_json(artifact) do
    %{
      id: artifact.id,
      organization_id: artifact.organization_id,
      project_id: artifact.project_id,
      kind: artifact.kind,
      title: artifact.title,
      mime_type: artifact.mime_type,
      inserted_at: artifact.inserted_at,
      updated_at: artifact.updated_at
    }
  end

  defp validate_project(nil, _org_id), do: {:ok, nil}
  defp validate_project("", _org_id), do: {:ok, nil}

  defp validate_project(project_id, org_id) do
    case NoizuPromptLingua.Projects.get_project(project_id) do
      nil -> {:error, :project_not_in_org}
      %{organization_id: ^org_id} -> {:ok, project_id}
      _ -> {:error, :project_not_in_org}
    end
  end

  defp handle_error(conn, err) do
    case err do
      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

      {:error, :not_a_member} ->
        conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})

      {:error, :project_not_in_org} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Project does not belong to this organization"})

      _ ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  defp maybe_opt(opts, _key, nil), do: opts
  defp maybe_opt(opts, _key, ""), do: opts
  defp maybe_opt(opts, key, val), do: Keyword.put(opts, key, val)

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
