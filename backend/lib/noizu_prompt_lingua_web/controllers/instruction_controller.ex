defmodule NoizuPromptLinguaWeb.InstructionController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.Instructions
  alias NoizuPromptLingua.Authz

  # GET /api/v1/organizations/:org_id/instructions
  def index(conn, %{"org_id" => org_id} = params) do
    with_org(conn, org_id, "viewer", fn resolved_org_id ->
      opts =
        [organization_id: resolved_org_id]
        |> maybe_opt(:project_id, params["project_id"])
        |> maybe_opt(:status, params["status"])
        |> maybe_opt(:tag, params["tag"])
        |> maybe_opt(:query, params["query"])

      instructions = Instructions.list(opts)
      json(conn, %{instructions: Enum.map(instructions, &instruction_json/1)})
    end)
  end

  # POST /api/v1/organizations/:org_id/instructions
  def create(conn, %{"org_id" => org_id, "instruction" => params}) do
    with_org(conn, org_id, "member", fn resolved_org_id ->
      with {:ok, project_id} <- validate_project(params["project_id"], resolved_org_id) do
        attrs = take_attrs(params) |> Map.merge(%{organization_id: resolved_org_id, project_id: project_id})

        case Instructions.create(attrs, body: params["body"]) do
          {:ok, i} -> conn |> put_status(:created) |> json(%{instruction: instruction_json(i)})
          {:error, cs} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
        end
      else
        {:error, :project_not_in_org} -> conn |> put_status(:unprocessable_entity) |> json(%{error: "Project does not belong to this organization"})
      end
    end)
  end

  # GET /api/v1/organizations/:org_id/instructions/:id
  def show(conn, %{"org_id" => org_id, "id" => id} = params) do
    with_owned(conn, org_id, id, "viewer", fn i ->
      ver = Instructions.get_version(i.id, parse_version(params["version"]))
      json(conn, %{
        instruction: instruction_json(i),
        version: ver && ver.version,
        body: ver && ver.body,
        versions: Enum.map(Instructions.list_versions(i.id), &version_json(&1, i.active_version))
      })
    end)
  end

  # PUT /api/v1/organizations/:org_id/instructions/:id
  def update(conn, %{"org_id" => org_id, "id" => id, "instruction" => params}) do
    with_owned(conn, org_id, id, "member", fn _i ->
      case Instructions.update(id, take_attrs(params), body: params["body"], change_note: params["change_note"]) do
        {:ok, i} -> json(conn, %{instruction: instruction_json(i)})
        {:error, :not_found} -> not_found(conn)
        {:error, cs} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
      end
    end)
  end

  # DELETE /api/v1/organizations/:org_id/instructions/:id
  def delete(conn, %{"org_id" => org_id, "id" => id}) do
    with_owned(conn, org_id, id, "member", fn _i ->
      case Instructions.delete(id) do
        {:ok, _} -> json(conn, %{message: "Instruction deleted"})
        {:error, :not_found} -> not_found(conn)
      end
    end)
  end

  # GET /api/v1/organizations/:org_id/instructions/:instruction_id/versions
  def versions(conn, %{"org_id" => org_id, "instruction_id" => id}) do
    with_owned(conn, org_id, id, "viewer", fn i ->
      json(conn, %{versions: Enum.map(Instructions.list_versions(i.id), &version_json(&1, i.active_version))})
    end)
  end

  # POST /api/v1/organizations/:org_id/instructions/:instruction_id/active-version
  def set_active_version(conn, %{"org_id" => org_id, "instruction_id" => id, "version" => version}) do
    with_owned(conn, org_id, id, "member", fn _i ->
      case Instructions.set_active_version(id, parse_version(version)) do
        {:ok, i} -> json(conn, %{instruction: instruction_json(i)})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Version not found"})
        {:error, cs} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
      end
    end)
  end

  # POST /api/v1/organizations/:org_id/instructions/:instruction_id/render
  def render_instruction(conn, %{"org_id" => org_id, "instruction_id" => id} = params) do
    with_owned(conn, org_id, id, "viewer", fn i ->
      opts = if v = parse_version(params["version"]), do: [version: v], else: []

      case Instructions.render(i, params["params"] || %{}, opts) do
        {:ok, rendered} -> json(conn, %{rendered: rendered})
        {:error, :version_not_found} -> conn |> put_status(:not_found) |> json(%{error: "Version not found"})
        {:error, {:missing_params, missing}} -> conn |> put_status(:unprocessable_entity) |> json(%{error: "Missing required params", missing: missing})
      end
    end)
  end

  # ── JSON ──────────────────────────────────────────────────────

  defp instruction_json(i) do
    %{id: i.id, organization_id: i.organization_id, project_id: i.project_id,
      slug: i.slug, title: i.title, description: i.description, tags: i.tags,
      parameters: i.parameters, status: i.status, active_version: i.active_version,
      inserted_at: i.inserted_at, updated_at: i.updated_at}
  end

  defp version_json(v, active),
    do: %{version: v.version, change_note: v.change_note, inserted_at: v.inserted_at, active: v.version == active}

  defp take_attrs(params) do
    params
    |> Map.take(~w(slug title description tags parameters status))
    |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)
  end

  defp parse_version(nil), do: nil
  defp parse_version(""), do: nil
  defp parse_version(v) when is_integer(v), do: v
  defp parse_version(v) when is_binary(v), do: String.to_integer(v)

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
      case Instructions.get(id) do
        nil -> not_found(conn)
        %{organization_id: ^resolved_org_id} = i -> fun.(i)
        _ -> not_found(conn)
      end
    end)
  end

  defp not_found(conn), do: conn |> put_status(:not_found) |> json(%{error: "Instruction not found"})

  defp maybe_opt(opts, _key, nil), do: opts
  defp maybe_opt(opts, _key, ""), do: opts
  defp maybe_opt(opts, key, val), do: Keyword.put(opts, key, val)

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
