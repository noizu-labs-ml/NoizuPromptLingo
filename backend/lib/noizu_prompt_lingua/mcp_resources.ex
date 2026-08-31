defmodule NoizuPromptLingua.MCPResources do
  @moduledoc """
  CRUD for MCP resource entries + resource templates (W4). Rows are scoped
  (global / org / project); scoped rows shadow global ones.
  """

  import Ecto.Query
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.MCP.{McpResource, McpResourceTemplate}

  # ── resources ─────────────────────────────────────────────────────────────

  def list_resources(opts \\ []) do
    McpResource
    |> org_scope(opts)
    |> project_scope(opts)
    |> order_by([r], asc: r.uri)
    |> Repo.all()
  end

  def get_resource(id), do: Repo.get(McpResource, id)

  @doc "Effective resolution by URI: project → org → global, most specific wins."
  def find_resource_by_uri(uri, org_id \\ nil, project_id \\ nil) when is_binary(uri) do
    candidates =
      McpResource
      |> org_scope_value(org_id)
      |> project_scope_value(project_id)
      |> where([r], r.uri == ^uri)
      |> Repo.all()

    specificity = fn r ->
      cond do
        is_binary(project_id) and r.project_id == project_id -> 0
        is_binary(org_id) and is_nil(r.project_id) and r.organization_id == org_id -> 1
        true -> 2
      end
    end

    candidates
    |> Enum.sort_by(specificity)
    |> List.first()
  end

  def create_resource(attrs) do
    %McpResource{}
    |> McpResource.changeset(attrs)
    |> Repo.insert()
  end

  def update_resource(%McpResource{} = resource, attrs) do
    resource
    |> McpResource.changeset(attrs)
    |> Repo.update()
  end

  def update_resource(id, attrs) do
    case get_resource(id) do
      nil -> {:error, :not_found}
      resource -> update_resource(resource, attrs)
    end
  end

  def delete_resource(%McpResource{} = resource), do: Repo.delete(resource)

  def delete_resource(id) do
    case get_resource(id) do
      nil -> {:error, :not_found}
      resource -> delete_resource(resource)
    end
  end

  # ── resource templates ────────────────────────────────────────────────────

  def list_templates(opts \\ []) do
    McpResourceTemplate
    |> org_scope(opts)
    |> project_scope(opts)
    |> order_by([t], asc: t.uri_template)
    |> Repo.all()
  end

  def get_template(id), do: Repo.get(McpResourceTemplate, id)

  def create_template(attrs) do
    %McpResourceTemplate{}
    |> McpResourceTemplate.changeset(attrs)
    |> Repo.insert()
  end

  def update_template(%McpResourceTemplate{} = template, attrs) do
    template
    |> McpResourceTemplate.changeset(attrs)
    |> Repo.update()
  end

  def update_template(id, attrs) do
    case get_template(id) do
      nil -> {:error, :not_found}
      template -> update_template(template, attrs)
    end
  end

  def delete_template(%McpResourceTemplate{} = template), do: Repo.delete(template)

  def delete_template(id) do
    case get_template(id) do
      nil -> {:error, :not_found}
      template -> delete_template(template)
    end
  end

  # ── shared ────────────────────────────────────────────────────────────────

  # opts-key aware filtering: a present `:organization_id`/`:project_id` key
  # filters (explicit nil = globals only); an absent key = no filter (admin view).
  defp org_scope(query, opts) do
    if Keyword.has_key?(opts, :organization_id) do
      org_scope_value(query, opts[:organization_id])
    else
      query
    end
  end

  defp project_scope(query, opts) do
    if Keyword.has_key?(opts, :project_id) do
      project_scope_value(query, opts[:project_id])
    else
      query
    end
  end

  # Explicit nil = globals only (the calling scope itself has no org/project);
  # a value = globals + rows bound to that scope.
  defp org_scope_value(query, nil), do: where(query, [t], is_nil(t.organization_id))

  defp org_scope_value(query, org_id) when is_binary(org_id) do
    where(query, [t], is_nil(t.organization_id) or t.organization_id == ^org_id)
  end

  defp project_scope_value(query, nil), do: query

  defp project_scope_value(query, project_id) when is_binary(project_id) do
    where(query, [t], is_nil(t.project_id) or t.project_id == ^project_id)
  end

  @doc "JSON shapes for admin endpoints."
  def resource_json(%McpResource{} = r) do
    %{
      id: r.id,
      uri: r.uri,
      name: r.name,
      description: r.description,
      mime_type: r.mime_type,
      content: r.content,
      organization_id: r.organization_id,
      project_id: r.project_id,
      inserted_at: r.inserted_at
    }
  end

  def template_json(%McpResourceTemplate{} = t) do
    %{
      id: t.id,
      uri_template: t.uri_template,
      name: t.name,
      description: t.description,
      mime_type: t.mime_type,
      organization_id: t.organization_id,
      project_id: t.project_id,
      inserted_at: t.inserted_at
    }
  end
end
