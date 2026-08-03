defmodule NoizuPromptLingua.MCP.Resolve do
  @moduledoc """
  Reference resolution helpers shared by MCP tools. Accepts either a UUID or a
  human-friendly slug and returns the corresponding schema record (or nil).

  When `PMCore` is enabled, project resolution prefers `Noizu.PM.Repo`
  (same store `Projects.create_with_owner/2` writes to), with legacy app-local
  fallback for transition / emergency opt-out.
  """

  alias NoizuPromptLingua.Schema.Organizations.Organization, as: OrgSchema
  alias NoizuPromptLingua.Schema.Projects.Project, as: ProjectSchema

  @doc """
  Extract the authenticated caller's user UUID from a tool `ctx`.

  The MCP transport verifies the bearer token and stows the JWT claims at
  `ctx.assigns[:auth_claims]`; the `"sub"` claim holds the user UUID. Returns
  the UUID string, or nil when there are no claims (e.g. unauthenticated calls).
  """
  def current_user_id(ctx) do
    case ctx do
      %{assigns: %{auth_claims: %{"sub" => sub}}} when is_binary(sub) and sub != "" -> sub
      _ -> nil
    end
  end

  @doc "Resolve an organization ref (slug or UUID) to its UUID, or nil."
  def organization_id(nil), do: nil

  def organization_id(ref) do
    case NoizuPromptLingua.Organizations.resolve_org_id(ref) do
      {:ok, id} -> id
      _ -> nil
    end
  end

  @doc "Resolve an organization ref to its schema record, or nil."
  def organization(nil), do: nil

  def organization(ref) do
    case organization_id(ref) do
      nil -> nil
      id -> NoizuPromptLingua.Repo.get(OrgSchema, id)
    end
  end

  @doc "Resolve a project ref (slug or UUID) to its schema record, or nil."
  def project(nil), do: nil

  def project(ref) do
    case NoizuPromptLingua.UUID.cast(ref) do
      {:ok, uuid} ->
        pm_get_project(uuid) ||
          NoizuPromptLingua.Repo.get(ProjectSchema, uuid) ||
          NoizuPromptLingua.Repo.get_by(ProjectSchema, slug: ref)

      :error ->
        pm_get_project_by_slug(ref) ||
          NoizuPromptLingua.Repo.get_by(ProjectSchema, slug: ref)
    end
  end

  defp pm_get_project(id) do
    if NoizuPromptLingua.PMCore.enabled?() and NoizuPromptLingua.PMCore.repo_configured?() do
      Noizu.PM.Repo.get(Noizu.PM.Schema.Projects.Project, id)
    end
  rescue
    _ -> nil
  end

  defp pm_get_project_by_slug(slug) do
    if NoizuPromptLingua.PMCore.enabled?() and NoizuPromptLingua.PMCore.repo_configured?() do
      Noizu.PM.Repo.get_by(Noizu.PM.Schema.Projects.Project, slug: slug)
    end
  rescue
    _ -> nil
  end

  @doc """
  Resolve an optional project ref, verifying it belongs to `org_id`.

  Returns `{:ok, nil}` when no project is supplied, `{:ok, project_id}` when it
  resolves and belongs to the org, or `{:error, :project_not_found}` /
  `{:error, :project_not_in_org}`.
  """
  def project_in_org(nil, _org_id), do: {:ok, nil}
  def project_in_org("", _org_id), do: {:ok, nil}

  def project_in_org(ref, org_id) do
    case project(ref) do
      nil -> {:error, :project_not_found}
      %{organization_id: ^org_id} = project -> {:ok, project.id}
      _ -> {:error, :project_not_in_org}
    end
  end

  @doc """
  Resolve a definition scope from optional org/project refs:

    * no org → `{:ok, nil, nil}` (global)
    * org only → `{:ok, org_id, nil}` (organization scope)
    * org + project → `{:ok, org_id, project_id}` (project scope)

  Returns `{:error, :org_not_found}` / `{:error, :project_not_found}` /
  `{:error, :project_not_in_org}` on failure.
  """
  def scope(org_ref, project_ref) when org_ref in [nil, ""], do: {:ok, nil, nil}

  def scope(org_ref, project_ref) do
    case organization_id(org_ref) do
      nil ->
        {:error, :org_not_found}

      org_id ->
        case project_in_org(project_ref, org_id) do
          {:ok, project_id} -> {:ok, org_id, project_id}
          err -> err
        end
    end
  end
end
