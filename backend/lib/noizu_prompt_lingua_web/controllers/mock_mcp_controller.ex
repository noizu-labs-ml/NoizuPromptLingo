defmodule NoizuPromptLinguaWeb.MockMCPController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.MockMCP
  alias NoizuPromptLingua.Domains.MockMCP.{Agent, Models, DataStore}
  alias NoizuPromptLingua.Authz

  # GET /api/v1/organizations/:org_id/mock-mcp
  def index(conn, %{"org_id" => org_id} = params) do
    with_org(conn, org_id, "viewer", fn resolved_org_id ->
      opts =
        [organization_id: resolved_org_id]
        |> maybe_opt(:status, params["status"])
        |> maybe_opt(:project_id, params["project_id"])

      definitions = MockMCP.list(opts)
      json(conn, %{definitions: Enum.map(definitions, &definition_json/1)})
    end)
  end

  # GET /api/v1/organizations/:org_id/mock-mcp/:slug
  def show(conn, %{"org_id" => org_id, "slug" => slug}) do
    with_org_definition(conn, org_id, slug, "viewer", fn def_ ->
      json(conn, %{definition: definition_json(def_)})
    end)
  end

  # POST /api/v1/organizations/:org_id/mock-mcp
  def create(conn, %{"org_id" => org_id} = params) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, "member"),
         {:ok, project_id} <- validate_project(params["project_id"], resolved_org_id),
         {:ok, active_llm_id} <- validate_llm(params["active_llm_id"], resolved_org_id) do
      attrs = %{
        organization_id: resolved_org_id,
        slug: params["slug"],
        title: params["title"],
        prompt: params["prompt"],
        active_llm_id: active_llm_id,
        created_by: user_id,
        project_id: project_id
      }

      case MockMCP.create(attrs) do
        {:ok, def_} ->
          if params["auto_generate_tools"] != false do
            Task.start(fn -> generate_and_save_tools(def_) end)
          end
          conn |> put_status(:created) |> json(%{definition: definition_json(def_)})
        {:error, cs} ->
          conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
      end
    else
      err -> handle_error(conn, err)
    end
  end

  # PUT/PATCH /api/v1/organizations/:org_id/mock-mcp/:slug
  def update(conn, %{"org_id" => org_id, "slug" => slug} = params) do
    with_org_definition(conn, org_id, slug, "member", fn def_ ->
      with {:ok, _} <- validate_llm(params["active_llm_id"], def_.organization_id) do
        attrs =
          params
          |> Map.take(~w(title prompt status active_llm_id tools_json schema_sql))
          |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)

        case MockMCP.update(slug, attrs) do
          {:ok, updated} ->
            if Map.has_key?(params, "prompt") && params["auto_generate_tools"] != false do
              Task.start(fn -> generate_and_save_tools(updated) end)
            end
            json(conn, %{definition: definition_json(updated)})
          {:error, :not_found} ->
            conn |> put_status(:not_found) |> json(%{error: "not_found"})
          {:error, cs} ->
            conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
        end
      else
        err -> handle_error(conn, err)
      end
    end)
  end

  # DELETE /api/v1/organizations/:org_id/mock-mcp/:slug
  def delete(conn, %{"org_id" => org_id, "slug" => slug}) do
    with_org_definition(conn, org_id, slug, "member", fn _def_ ->
      case MockMCP.delete(slug) do
        {:ok, _} -> json(conn, %{deleted: true})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "not_found"})
      end
    end)
  end

  # POST /api/v1/organizations/:org_id/mock-mcp/:slug/activate
  def activate(conn, %{"org_id" => org_id, "slug" => slug}) do
    with_org_definition(conn, org_id, slug, "member", fn _def_ ->
      case MockMCP.activate(slug) do
        {:ok, def_} -> json(conn, %{definition: definition_json(def_)})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "not_found"})
      end
    end)
  end

  # POST /api/v1/organizations/:org_id/mock-mcp/:slug/generate-tools
  # Generates the full MCP surface (tools + resources + prompts) from the prompt.
  def generate_tools(conn, %{"org_id" => org_id, "slug" => slug}) do
    with_org_definition(conn, org_id, slug, "member", fn def_ ->
      opts = MockMCP.active_llm_opts(def_)

      case Agent.generate_surface(def_.prompt, opts) do
        {:ok, surface} ->
          {:ok, updated} = MockMCP.set_surface(def_.id, surface)
          json(conn, %{
            tools: updated.tools_json,
            resources: updated.resources_json,
            prompts: updated.prompts_json
          })
        {:error, :invalid_surface_json, raw} ->
          conn |> put_status(:unprocessable_entity) |> json(%{error: "LLM returned invalid surface JSON", raw: raw})
        {:error, reason} ->
          conn |> put_status(:bad_gateway) |> json(%{error: "LLM call failed", detail: inspect(reason)})
      end
    end)
  end

  # POST /api/v1/organizations/:org_id/mock-mcp/:slug/provision-db
  def provision_db(conn, %{"org_id" => org_id, "slug" => slug}) do
    with_org_definition(conn, org_id, slug, "member", fn _def_ ->
      case MockMCP.provision_db(slug) do
        {:ok, def_} -> json(conn, %{db_name: def_.db_name, provisioned: true})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "not_found"})
        {:error, reason} -> conn |> put_status(:internal_server_error) |> json(%{error: inspect(reason)})
      end
    end)
  end

  # GET /api/v1/organizations/:org_id/mock-mcp/:slug/calls
  def calls(conn, %{"org_id" => org_id, "slug" => slug}) do
    with_org_definition(conn, org_id, slug, "viewer", fn def_ ->
      logs = MockMCP.list_calls(def_.id)
      json(conn, %{calls: Enum.map(logs, fn l ->
        %{id: l.id, method: l.method, tool_name: l.tool_name,
          arguments: l.arguments, response: l.response,
          latency_ms: l.latency_ms, error: l.error, at: l.inserted_at}
      end)})
    end)
  end

  # GET /api/v1/organizations/:org_id/mock-mcp-models
  # Curated quick-pick of provider/model pairs for the "new LLM connection" form.
  def models(conn, %{"org_id" => org_id}) do
    with_org(conn, org_id, "viewer", fn _resolved_org_id ->
      json(conn, %{models: Models.all(), default: Models.default_id()})
    end)
  end

  # ── State browser (owner-facing; the agent's private datastore) ──

  # GET /api/v1/organizations/:org_id/mock-mcp/:slug/state/db/tables
  def state_db_tables(conn, %{"org_id" => org_id, "slug" => slug}) do
    with_org_definition(conn, org_id, slug, "viewer", fn def_ ->
      case DataStore.list_tables(def_) do
        {:ok, tables} -> json(conn, %{tables: tables})
        {:error, msg} -> conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(msg)})
      end
    end)
  end

  # POST /api/v1/organizations/:org_id/mock-mcp/:slug/state/db/query  {sql}
  def state_db_query(conn, %{"org_id" => org_id, "slug" => slug, "sql" => sql}) do
    with_org_definition(conn, org_id, slug, "member", fn def_ ->
      case DataStore.db_query(def_, sql) do
        {:ok, %{columns: cols, rows: rows}} -> json(conn, %{columns: cols, rows: rows})
        {:error, msg} -> conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(msg)})
      end
    end)
  end

  def state_db_query(conn, _), do: conn |> put_status(:bad_request) |> json(%{error: "missing 'sql'"})

  # GET /api/v1/organizations/:org_id/mock-mcp/:slug/state/redis?pattern=*
  def state_redis(conn, %{"org_id" => org_id, "slug" => slug} = params) do
    with_org_definition(conn, org_id, slug, "viewer", fn def_ ->
      case DataStore.redis_dump(def_, params["pattern"] || "*") do
        {:ok, entries} -> json(conn, %{entries: entries})
        {:error, msg} -> conn |> put_status(:unprocessable_entity) |> json(%{error: to_string(msg)})
      end
    end)
  end

  # POST /api/v1/organizations/:org_id/mock-mcp/:slug/invoke  {tool, arguments}
  # Playground: invoke a generated tool from the UI without an MCP client.
  def invoke(conn, %{"org_id" => org_id, "slug" => slug, "tool" => tool_name} = params) do
    arguments = params["arguments"] || %{}

    with_org_definition(conn, org_id, slug, "member", fn def_ ->
      case find_tool(def_.tools_json, tool_name) do
        nil ->
          conn |> put_status(:not_found) |> json(%{error: "Unknown tool: #{tool_name}"})

        tool ->
          opts = MockMCP.active_llm_opts(def_)

          case Agent.handle_tool_call(def_, tool_name, arguments, tool["handler"], opts) do
            {:ok, content, latency, trace} ->
              MockMCP.log_call(def_.id, %{method: "invoke", tool_name: tool_name,
                arguments: arguments, response: %{content: content, trace: trace}, latency_ms: latency})
              json(conn, %{content: content, trace: trace, latency_ms: latency})

            {:error, reason, latency, trace} ->
              MockMCP.log_call(def_.id, %{method: "invoke", tool_name: tool_name,
                arguments: arguments, error: inspect(reason), response: %{trace: trace}, latency_ms: latency})
              conn |> put_status(:bad_gateway) |> json(%{error: inspect(reason), trace: trace})
          end
      end
    end)
  end

  def invoke(conn, _), do: conn |> put_status(:bad_request) |> json(%{error: "missing 'tool'"})

  defp find_tool(nil, _name), do: nil
  defp find_tool(tools, name), do: Enum.find(tools, &(&1["name"] == name))

  # ── LLM connection pool (org-scoped) ─────────────────────────

  # GET /api/v1/organizations/:org_id/mock-mcp-llms
  def list_llms(conn, %{"org_id" => org_id}) do
    with_org(conn, org_id, "viewer", fn resolved_org_id ->
      json(conn, %{llms: Enum.map(MockMCP.list_llms(resolved_org_id), &llm_json/1)})
    end)
  end

  # POST /api/v1/organizations/:org_id/mock-mcp-llms
  def create_llm(conn, %{"org_id" => org_id} = params) do
    with_org(conn, org_id, "member", fn resolved_org_id ->
      attrs = %{
        organization_id: resolved_org_id,
        label: params["label"],
        provider: params["provider"],
        model: params["model"],
        endpoint: params["endpoint"],
        api_key: params["api_key"]
      }

      case MockMCP.create_llm(attrs) do
        {:ok, llm} -> conn |> put_status(:created) |> json(%{llm: llm_json(llm)})
        {:error, cs} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
      end
    end)
  end

  # PUT /api/v1/organizations/:org_id/mock-mcp-llms/:id
  def update_llm(conn, %{"org_id" => org_id, "id" => id} = params) do
    with_org_llm(conn, org_id, id, "member", fn _llm ->
      attrs =
        params
        |> Map.take(~w(label provider model endpoint api_key))
        # Blank api key = leave unchanged (the secret is never echoed back).
        |> Map.reject(fn {k, v} -> k == "api_key" and v in [nil, ""] end)
        |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)

      case MockMCP.update_llm(id, attrs) do
        {:ok, llm} -> json(conn, %{llm: llm_json(llm)})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "not_found"})
        {:error, cs} -> conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(cs)})
      end
    end)
  end

  # DELETE /api/v1/organizations/:org_id/mock-mcp-llms/:id
  def delete_llm(conn, %{"org_id" => org_id, "id" => id}) do
    with_org_llm(conn, org_id, id, "member", fn _llm ->
      case MockMCP.delete_llm(id) do
        {:ok, _} -> json(conn, %{deleted: true})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "not_found"})
      end
    end)
  end

  # ── helpers ──────────────────────────────────────────────────

  defp generate_and_save_tools(def_) do
    case Agent.generate_surface(def_.prompt, MockMCP.active_llm_opts(def_)) do
      {:ok, surface} -> MockMCP.set_surface(def_.id, surface)
      _ -> :ok
    end
  end

  # Resolve org + authorize, then run fun with the resolved org id.
  defp with_org(conn, org_id, role, fun) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, role) do
      fun.(resolved_org_id)
    else
      err -> handle_error(conn, err)
    end
  end

  # Resolve org, authorize, load the LLM connection, and ensure it's in the org.
  defp with_org_llm(conn, org_id, id, role, fun) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, role),
         llm when not is_nil(llm) <- MockMCP.get_llm(id),
         true <- llm.organization_id == resolved_org_id do
      fun.(llm)
    else
      nil -> conn |> put_status(:not_found) |> json(%{error: "LLM connection not found"})
      false -> conn |> put_status(:not_found) |> json(%{error: "LLM connection not found"})
      err -> handle_error(conn, err)
    end
  end

  # Resolve org, authorize, load the definition, and ensure it belongs to the org.
  defp with_org_definition(conn, org_id, slug, role, fun) do
    user_id = get_user_id(conn)

    with {:ok, resolved_org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_id),
         {:ok, _} <- Authz.authorize(user_id, "organization", resolved_org_id, role),
         def_ when not is_nil(def_) <- MockMCP.get(slug),
         true <- def_.organization_id == resolved_org_id do
      fun.(def_)
    else
      nil -> conn |> put_status(:not_found) |> json(%{error: "Mock MCP not found"})
      false -> conn |> put_status(:not_found) |> json(%{error: "Mock MCP not found"})
      err -> handle_error(conn, err)
    end
  end

  defp definition_json(d) do
    # tools/resources/prompts include their private "handler" here (owner-facing
    # management API); the MCP gateway strips handlers before clients see them.
    %{id: d.id, slug: d.slug, title: d.title, prompt: d.prompt,
      status: d.status, tools_json: d.tools_json, resources_json: d.resources_json,
      prompts_json: d.prompts_json, schema_sql: d.schema_sql,
      active_llm_id: d.active_llm_id,
      active_llm: d.active_llm_id && llm_json(MockMCP.get_llm(d.active_llm_id)),
      organization_id: d.organization_id, db_name: d.db_name, db_provisioned: d.db_provisioned,
      created_by: d.created_by, project_id: d.project_id,
      tool_count: length(d.tools_json || []),
      resource_count: length(d.resources_json || []),
      prompt_count: length(d.prompts_json || []),
      created_at: d.inserted_at, updated_at: d.updated_at}
  end

  defp llm_json(nil), do: nil
  defp llm_json(l) do
    %{id: l.id, label: l.label, provider: l.provider, model: l.model,
      endpoint: l.endpoint, api_key_set: present?(l.api_key),
      created_at: l.inserted_at, updated_at: l.updated_at}
  end

  # An active LLM is optional; when given it must belong to the org.
  defp validate_llm(nil, _org_id), do: {:ok, nil}
  defp validate_llm("", _org_id), do: {:ok, nil}
  defp validate_llm(llm_id, org_id) do
    case MockMCP.get_llm(llm_id) do
      %{organization_id: ^org_id} -> {:ok, llm_id}
      _ -> {:error, :llm_not_in_org}
    end
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
      {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "Organization not found"})
      {:error, :not_a_member} -> conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})
      {:error, :project_not_in_org} -> conn |> put_status(:unprocessable_entity) |> json(%{error: "Project does not belong to this organization"})
      {:error, :llm_not_in_org} -> conn |> put_status(:unprocessable_entity) |> json(%{error: "LLM connection does not belong to this organization"})
      _ -> conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  defp present?(nil), do: false
  defp present?(""), do: false
  defp present?(_), do: true

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
