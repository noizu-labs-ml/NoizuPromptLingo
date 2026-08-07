defmodule NoizuPromptLingua.MCP.Resolve do
  @moduledoc """
  Reference resolution helpers shared by MCP tools. Accepts either a UUID or a
  human-friendly slug and returns the corresponding schema record (or nil).

  Shared PM data (orgs/projects) resolves exclusively via `Noizu.PM.Repo`.
  """

  alias NoizuPromptLingua.PMCore

  @doc """
  Extract the authenticated caller's user UUID from a tool `ctx`.

  The MCP transport verifies the bearer token and stows the JWT claims at
  `ctx.assigns[:auth_claims]`; the `"sub"` claim holds the user UUID. Returns
  the UUID string, or nil when there are no claims (e.g. unauthenticated calls).
  """
  def current_user_id(ctx) do
    case ctx do
      %{assigns: %{auth_claims: claims}} when is_map(claims) ->
        normalize_user_id(claims)

      _ ->
        nil
    end
  end

  @doc "Normalize JWT identity claims to a bare user UUID."
  def normalize_user_id(%{"user_id" => id}) when is_binary(id) and id != "", do: id

  def normalize_user_id(%{"sub" => "user:" <> id}) when id != "", do: id

  def normalize_user_id(%{"sub" => sub}) when is_binary(sub) and sub != "" do
    # Legacy API-key JWTs use bare UUID; ignore non-user principals (svc:, client:)
    if String.contains?(sub, ":"), do: nil, else: sub
  end

  def normalize_user_id(_), do: nil

  @doc "Resolve an organization ref (slug or UUID) to its UUID, or nil."
  def organization_id(nil), do: nil

  def organization_id(ref) do
    case NoizuPromptLingua.Organizations.resolve_org_id(ref) do
      {:ok, id} -> id
      _ -> nil
    end
  end

  @doc "Resolve an organization ref to its PM schema record, or nil."
  def organization(nil), do: nil

  def organization(ref) do
    case organization_id(ref) do
      nil ->
        nil

      id ->
        PMCore.with_pm(fn ->
          Noizu.PM.Repo.get(Noizu.PM.Schema.Organizations.Organization, id)
        end)
    end
  end

  @doc "Resolve a project ref (slug or UUID) to its PM schema record, or nil."
  def project(nil), do: nil

  def project(ref) do
    PMCore.with_pm(fn ->
      case NoizuPromptLingua.UUID.cast(ref) do
        {:ok, uuid} ->
          Noizu.PM.Repo.get(Noizu.PM.Schema.Projects.Project, uuid)

        :error ->
          Noizu.PM.Repo.get_by(Noizu.PM.Schema.Projects.Project, slug: ref)
      end
    end)
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
  def scope(org_ref, _project_ref) when org_ref in [nil, ""], do: {:ok, nil, nil}

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
