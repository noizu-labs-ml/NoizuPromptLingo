defmodule NoizuPromptLinguaWeb.TypeDefinitionController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.Tickets.Definitions
  alias NoizuPromptLingua.Authz

  # GET /api/v1/organizations/:org_id/ticket-type-definitions[?project_id=]
  def index(conn, %{"org_id" => org_id} = params) do
    with_org(conn, org_id, "viewer", fn resolved_org_id ->
      project_id = blank_to_nil(params["project_id"])
      types = Definitions.list_types(resolved_org_id, project_id)
      json(conn, %{type_definitions: Enum.map(types, &detail_json/1)})
    end)
  end

  # POST /api/v1/organizations/:org_id/ticket-type-definitions
  def create(conn, %{"org_id" => org_id, "type_definition" => params}) do
    with_org(conn, org_id, "member", fn resolved_org_id ->
      with {:ok, project_id} <-
             scope_project(params["scope"], params["project_id"], resolved_org_id) do
        attrs =
          take_attrs(params)
          |> Map.merge(%{organization_id: resolved_org_id, project_id: project_id})

        case Definitions.create_type(attrs) do
          {:ok, type_def} ->
            assign_fields(type_def.id, params["fields"] || [])

            conn
            |> put_status(:created)
            |> json(%{type_definition: detail_json(Definitions.get_type(type_def.id))})

          {:error, changeset} ->
            conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
        end
      else
        {:error, :project_not_in_org} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "Project does not belong to this organization"})

        {:error, :global_forbidden} ->
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Global types are system-managed and cannot be created here"})
      end
    end)
  end

  # GET /api/v1/organizations/:org_id/ticket-type-definitions/:id
  def show(conn, %{"org_id" => org_id, "id" => id}) do
    with_org(conn, org_id, "viewer", fn _resolved_org_id ->
      case Definitions.get_type(id) do
        nil -> conn |> put_status(:not_found) |> json(%{error: "Type not found"})
        type_def -> json(conn, %{type_definition: detail_json(type_def)})
      end
    end)
  end

  # PUT /api/v1/organizations/:org_id/ticket-type-definitions/:id
  def update(conn, %{"org_id" => org_id, "id" => id, "type_definition" => params}) do
    with_owned_type(conn, org_id, id, fn _type_def ->
      case Definitions.update_type(id, take_attrs(params)) do
        {:ok, _} ->
          if is_list(params["fields"]), do: replace_fields(id, params["fields"])
          json(conn, %{type_definition: detail_json(Definitions.get_type(id))})

        {:error, changeset} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
      end
    end)
  end

  # DELETE /api/v1/organizations/:org_id/ticket-type-definitions/:id
  def delete(conn, %{"org_id" => org_id, "id" => id}) do
    with_owned_type(conn, org_id, id, fn _type_def ->
      case Definitions.delete_type(id) do
        {:ok, _} -> json(conn, %{message: "Type deleted"})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Type not found"})
      end
    end)
  end

  defp with_owned_type(conn, org_id, id, fun) do
    with_org(conn, org_id, "member", fn resolved_org_id ->
      case Definitions.get_type(id) do
        nil ->
          conn |> put_status(:not_found) |> json(%{error: "Type not found"})

        %{organization_id: ^resolved_org_id} = type_def ->
          fun.(type_def)

        _ ->
          conn
          |> put_status(:forbidden)
          |> json(%{error: "This type is not managed by your organization"})
      end
    end)
  end

  # Reconcile a type's field set with the supplied list of {id, required}.
  defp replace_fields(type_id, specs) do
    type_def = Definitions.get_type(type_id)
    current = Definitions.type_field_list(type_def) |> Enum.map(& &1.id)
    desired = Enum.map(specs, fn s -> s["id"] end) |> Enum.reject(&is_nil/1)

    Enum.each(current -- desired, fn fid -> Definitions.remove_field_from_type(type_id, fid) end)
    assign_fields(type_id, specs)
  end

  defp assign_fields(type_id, specs) do
    specs
    |> Enum.with_index()
    |> Enum.each(fn {spec, idx} ->
      if fid = spec["id"] do
        Definitions.add_field_to_type(type_id, fid,
          required: spec["required"] || false,
          position: idx
        )
      end
    end)
  end

  defp take_attrs(params) do
    params
    |> Map.take(~w(slug name description icon status_workflow disabled))
    |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)
  end

  defp detail_json(type_def) do
    %{
      id: type_def.id,
      scope: Atom.to_string(Definitions.scope_of(type_def)),
      organization_id: type_def.organization_id,
      project_id: type_def.project_id,
      slug: type_def.slug,
      name: type_def.name,
      description: type_def.description,
      icon: type_def.icon,
      status_workflow: type_def.status_workflow,
      disabled: type_def.disabled,
      fields: Definitions.type_field_list(type_def),
      inserted_at: type_def.inserted_at,
      updated_at: type_def.updated_at
    }
  end

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
      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

      {:error, :not_a_member} ->
        conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})

      {:error, _} ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
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
