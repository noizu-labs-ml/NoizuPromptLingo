defmodule NoizuPromptLinguaWeb.ReviewController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.Reviews
  alias NoizuPromptLingua.Authz

  # GET /api/v1/organizations/:org_id/reviews
  def index(conn, %{"org_id" => org_id} = params) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "viewer") do
      opts =
        [organization_id: resolved_org_id]
        |> maybe_opt(:project_id, params["project_id"])
        |> maybe_opt(:artifact_id, params["artifact_id"])
        |> maybe_opt(:status, params["status"])

      reviews = Reviews.list(opts)
      json(conn, %{reviews: Enum.map(reviews, &review_to_json/1)})
    else
      err -> handle_error(conn, err)
    end
  end

  # POST /api/v1/organizations/:org_id/reviews
  def create(conn, %{"org_id" => org_id, "review" => review_params}) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "member"),
         {:ok, project_id} <- validate_project(review_params["project_id"], resolved_org_id),
         :ok <- validate_artifact(review_params["artifact_id"], resolved_org_id) do
      attrs = %{
        organization_id: resolved_org_id,
        project_id: project_id,
        artifact_id: review_params["artifact_id"],
        revision_id: review_params["revision_id"],
        reviewer_persona: review_params["reviewer_persona"],
        title: review_params["title"]
      }

      case Reviews.create(attrs) do
        {:ok, review} ->
          conn |> put_status(:created) |> json(%{review: review_to_json(review)})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    else
      err -> handle_error(conn, err)
    end
  end

  # GET /api/v1/organizations/:org_id/reviews/:id
  def show(conn, %{"org_id" => org_id, "id" => id}) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "viewer"),
         {review, comments, overlays} when not is_nil(review) <- Reviews.get(id) || :missing,
         true <- review.organization_id == resolved_org_id do
      json(conn, %{
        review: review_to_json(review),
        comments: comments,
        overlays: Enum.map(overlays, &overlay_to_json/1)
      })
    else
      :missing -> conn |> put_status(:not_found) |> json(%{error: "Review not found"})
      false -> conn |> put_status(:not_found) |> json(%{error: "Review not found"})
      err -> handle_error(conn, err)
    end
  end

  # PUT /api/v1/organizations/:org_id/reviews/:id
  # Update a review's mutable metadata (title/reviewer_persona/summary/verdict
  # and open<->in_progress status). Identity/lineage is immutable; a completed
  # review is frozen (409); finalize via the /complete endpoint.
  def update(conn, %{"org_id" => org_id, "id" => id, "review" => review_params}) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "member"),
         {review, _comments, _overlays} when not is_nil(review) <- Reviews.get(id) || :missing,
         true <- review.organization_id == resolved_org_id do
      case Reviews.update(id, review_params) do
        {:ok, review} ->
          json(conn, %{review: review_to_json(review)})

        {:error, :not_found} ->
          conn |> put_status(:not_found) |> json(%{error: "Review not found"})

        {:error, :completed} ->
          conn |> put_status(:conflict) |> json(%{error: "Review is completed and immutable"})

        {:error, :use_complete} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "Use the complete endpoint to finalize a review"})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    else
      :missing -> conn |> put_status(:not_found) |> json(%{error: "Review not found"})
      false -> conn |> put_status(:not_found) |> json(%{error: "Review not found"})
      err -> handle_error(conn, err)
    end
  end

  # POST /api/v1/organizations/:org_id/reviews/:review_id/complete
  def complete(conn, %{"org_id" => org_id, "review_id" => id} = params) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "member"),
         {review, _comments, _overlays} when not is_nil(review) <- Reviews.get(id) || :missing,
         true <- review.organization_id == resolved_org_id do
      attrs = Map.take(params, ["summary", "verdict"])

      case Reviews.complete(id, attrs) do
        {:ok, review} ->
          json(conn, %{review: review_to_json(review)})

        {:error, :not_found} ->
          conn |> put_status(:not_found) |> json(%{error: "Review not found"})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    else
      :missing -> conn |> put_status(:not_found) |> json(%{error: "Review not found"})
      false -> conn |> put_status(:not_found) |> json(%{error: "Review not found"})
      err -> handle_error(conn, err)
    end
  end

  defp review_to_json(review) do
    %{
      id: review.id,
      organization_id: review.organization_id,
      project_id: review.project_id,
      artifact_id: review.artifact_id,
      revision_id: review.revision_id,
      reviewer_persona: review.reviewer_persona,
      title: review.title,
      status: review.status,
      summary: review.summary,
      verdict: review.verdict,
      inserted_at: review.inserted_at,
      updated_at: review.updated_at
    }
  end

  defp overlay_to_json(o) do
    %{
      id: o.id,
      x: o.x,
      y: o.y,
      width: o.width,
      height: o.height,
      comment: o.comment,
      persona: o.persona
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

  # The artifact under review must belong to the same organization.
  defp validate_artifact(artifact_id, org_id) do
    case NoizuPromptLingua.Repo.get(NoizuPromptLingua.Schema.Artifact, artifact_id) do
      nil -> {:error, :artifact_not_in_org}
      %{organization_id: ^org_id} -> :ok
      _ -> {:error, :artifact_not_in_org}
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

      {:error, :artifact_not_in_org} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Artifact does not belong to this organization"})

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
