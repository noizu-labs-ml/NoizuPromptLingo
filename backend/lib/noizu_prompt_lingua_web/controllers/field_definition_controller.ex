defmodule NoizuPromptLinguaWeb.FieldDefinitionController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.Tickets.Definitions
  alias NoizuPromptLingua.Schema.TicketFieldDefinition
  alias NoizuPromptLingua.Authz

  # GET /api/v1/organizations/:org_id/ticket-field-definitions[?project_id=]
  # Returns every field visible in the (org, project) context — global,
  # org-level, and (when project_id given) project-level — each tagged with its
  # scope and disabled flag.
  def index(conn, %{"org_id" => org_id} = params) do
    with_org(conn, org_id, "viewer", fn resolved_org_id ->
      project_id = blank_to_nil(params["project_id"])
      fields = Definitions.list_fields(resolved_org_id, project_id)
      json(conn, %{field_definitions: Enum.map(fields, &field_to_json/1), field_types: TicketFieldDefinition.field_types()})
    end)
  end

  # GET /api/v1/organizations/:org_id/ticket-field-definitions/:id
  # Fetch a single field definition visible in this org context: a global
  # (system) field or one owned by this org (org- or project-scoped under it).
  # A field belonging to another org returns 404 (no cross-org existence leak).
  def show(conn, %{"org_id" => org_id, "id" => id}) do
    with_org(conn, org_id, "viewer", fn resolved_org_id ->
      case Definitions.get_field(id) do
        nil -> conn |> put_status(:not_found) |> json(%{error: "Field not found"})
        %{organization_id: nil} = field -> json(conn, %{field_definition: field_to_json(field)})
        %{organization_id: ^resolved_org_id} = field -> json(conn, %{field_definition: field_to_json(field)})
        _ -> conn |> put_status(:not_found) |> json(%{error: "Field not found"})
      end
    end)
  end

  # POST /api/v1/organizations/:org_id/ticket-field-definitions
  def create(conn, %{"org_id" => org_id, "field_definition" => params}) do
    with_org(conn, org_id, "member", fn resolved_org_id ->
      with {:ok, project_id} <- scope_project(params["scope"], params["project_id"], resolved_org_id) do
        attrs =
          take_attrs(params)
          |> Map.merge(%{organization_id: resolved_org_id, project_id: project_id})

        case Definitions.create_field(attrs) do
          {:ok, field} -> conn |> put_status(:created) |> json(%{field_definition: field_to_json(field)})
          {:error, changeset} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
        end
      else
        {:error, :project_not_in_org} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: "Project does not belong to this organization"})

        {:error, :global_forbidden} ->
          conn |> put_status(:forbidden) |> json(%{error: "Global definitions are system-managed and cannot be created here"})
      end
    end)
  end

  # PUT /api/v1/organizations/:org_id/ticket-field-definitions/:id
  def update(conn, %{"org_id" => org_id, "id" => id, "field_definition" => params}) do
    with_owned_field(conn, org_id, id, fn _field ->
      case Definitions.update_field(id, take_attrs(params)) do
        {:ok, field} -> json(conn, %{field_definition: field_to_json(field)})
        {:error, changeset} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    end)
  end

  # DELETE /api/v1/organizations/:org_id/ticket-field-definitions/:id
  def delete(conn, %{"org_id" => org_id, "id" => id}) do
    with_owned_field(conn, org_id, id, fn _field ->
      case Definitions.delete_field(id) do
        {:ok, _} -> json(conn, %{message: "Field deleted"})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Field not found"})
      end
    end)
  end

  # Load a field by id and ensure it is owned by this org (org- or project-scoped
  # under it). Global rows (organization_id nil) are read-only here.
  defp with_owned_field(conn, org_id, id, fun) do
    with_org(conn, org_id, "member", fn resolved_org_id ->
      case Definitions.get_field(id) do
        nil -> conn |> put_status(:not_found) |> json(%{error: "Field not found"})
        %{organization_id: ^resolved_org_id} = field -> fun.(field)
        _ -> conn |> put_status(:forbidden) |> json(%{error: "This definition is not managed by your organization"})
      end
    end)
  end

  defp take_attrs(params) do
    params
    |> Map.take(~w(slug label field_type options default_value description disabled))
    |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)
  end

  defp field_to_json(f) do
    %{
      id: f.id,
      scope: Atom.to_string(Definitions.scope_of(f)),
      organization_id: f.organization_id,
      project_id: f.project_id,
      slug: f.slug,
      label: f.label,
      field_type: f.field_type,
      options: f.options,
      default_value: f.default_value,
      description: f.description,
      disabled: f.disabled,
      inserted_at: f.inserted_at,
      updated_at: f.updated_at
    }
  end

  # Resolve the target scope's project_id. Only org/project scopes are allowed
  # through this org-scoped controller.
  defp scope_project("project", project_id, org_id) do
    case NoizuPromptLingua.Projects.get_project(project_id) do
      %{organization_id: ^org_id} -> {:ok, project_id}
      _ -> {:error, :project_not_in_org}
    end
  end

  defp scope_project("global", _project_id, _org_id), do: {:error, :global_forbidden}
  defp scope_project(_org_scope, _project_id, _org_id), do: {:ok, nil}

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(v), do: v

  defp with_org(conn, org_id, role, fun) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, role) do
      fun.(resolved_org_id)
    else
      {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Organization not found"})
      {:error, :not_a_member} -> conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})
      {:error, _} -> conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

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
