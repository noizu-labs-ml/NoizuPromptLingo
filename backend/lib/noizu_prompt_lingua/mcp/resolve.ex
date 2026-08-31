defmodule NoizuPromptLingua.MCP.Resolve do
  @moduledoc """
  Reference resolution helpers shared by MCP tools. Accepts either a UUID or a
  human-friendly slug and returns the corresponding schema record (or nil).

  Shared PM data (orgs/projects) resolves via the TRP shared-key plane.
  """

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

  @doc "Resolve an organization ref to its TRP org map (id/slug/name), or nil."
  def organization(nil), do: nil

  def organization(ref) do
    case organization_id(ref) do
      nil -> nil
      id -> NoizuPromptLingua.TRP.get_organization(id)
    end
  end

  @doc "Resolve a project ref (slug or UUID) to its TRP project map, or nil."
  def project(nil), do: nil

  def project(ref) do
    case project_across_scope(ref) do
      {:error, _} -> nil
      other -> other
    end
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
    # Direct org-scoped lookup (NOT project/1 — that scans every scope org and
    # would recurse back through here).
    case NoizuPromptLingua.UUID.cast(ref) do
      {:ok, uuid} ->
        case NoizuPromptLingua.TRP.get_project(org_id, uuid) do
          %{} = project -> {:ok, project.id}
          nil -> {:error, :project_not_found}
          {:error, _} -> {:error, :project_not_found}
        end

      :error ->
        case NoizuPromptLingua.TRP.list_projects(org_id) do
          rows when is_list(rows) ->
            case Enum.find(rows, &(&1.slug == ref)) do
              nil -> {:error, :project_not_found}
              project -> {:ok, project.id}
            end

          {:error, _} ->
            {:error, :project_not_found}
        end
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

  # TRP is org-pathed; a bare ref is searched across the cached key scope.
  defp project_across_scope(ref) do
    orgs =
      case NoizuPromptLingua.TRP.list_organizations() do
        list when is_list(list) -> list
        {:error, _} = err -> err
      end

    orgs = if is_list(orgs), do: orgs, else: []

    Enum.reduce_while(orgs, nil, fn org, _acc ->
      case project_in_org(ref, org.id) do
        {:ok, nil} -> {:cont, nil}
        {:ok, project_id} -> {:halt, NoizuPromptLingua.TRP.get_project(org.id, project_id)}
        {:error, :project_not_found} -> {:cont, nil}
        {:error, _} = err -> {:halt, err}
      end
    end)
  end
end
