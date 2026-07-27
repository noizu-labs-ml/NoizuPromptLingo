defmodule NoizuPromptLingua.Domains.MockMCP do
  @moduledoc """
  Mock MCP domain: LLM-inference-driven pseudo/fake MCP servers.

  A definition stores a prose `prompt` describing what an MCP server should do.
  An LLM generates the tool definitions from that prompt (see `Agent`), and the
  generated server is served live via the JSON-RPC gateway — each tool call is
  proxied to the LLM and logged here.
  """
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{MockMCPDefinition, MockMCPCallLog, MockMCPLLM}
  alias NoizuPromptLingua.Domains.MockMCP.WeaviateStore

  # ── Definition CRUD ──────────────────────────────────────────

  def create(attrs) do
    %MockMCPDefinition{}
    |> MockMCPDefinition.changeset(attrs)
    |> Repo.insert()
  end

  def get(slug_or_id) do
    case NoizuPromptLingua.UUID.cast(slug_or_id) do
      {:ok, _} ->
        MockMCPDefinition
        |> where([d], d.id == ^slug_or_id or d.slug == ^slug_or_id)
        |> Repo.one()
      :error ->
        Repo.get_by(MockMCPDefinition, slug: slug_or_id)
    end
  end

  def get_active(slug) do
    MockMCPDefinition
    |> where([d], d.slug == ^slug and d.status == "active")
    |> Repo.one()
  end

  def update(slug_or_id, attrs) do
    case get(slug_or_id) do
      nil -> {:error, :not_found}
      definition ->
        definition
        |> MockMCPDefinition.changeset(attrs)
        |> Repo.update()
    end
  end

  def delete(slug_or_id) do
    case get(slug_or_id) do
      nil -> {:error, :not_found}
      definition -> Repo.delete(definition)
    end
  end

  def activate(slug_or_id) do
    update(slug_or_id, %{status: "active"})
  end

  def archive(slug_or_id) do
    update(slug_or_id, %{status: "archived"})
  end

  def list(opts \\ []) do
    MockMCPDefinition
    |> maybe_filter(:organization_id, opts[:organization_id])
    |> maybe_filter(:status, opts[:status])
    |> maybe_filter(:project_id, opts[:project_id])
    |> order_by([d], desc: d.updated_at)
    |> limit(^(opts[:limit] || 50))
    |> Repo.all()
  end

  # ── Tool Definitions ─────────────────────────────────────────

  def set_tools(slug_or_id, tools_json) when is_list(tools_json) do
    update(slug_or_id, %{tools_json: tools_json})
  end

  @doc """
  Store a generated surface (tools + resources + prompts) on a definition. When
  the agent also designed a backing schema (`"schema"` → postgres DDL + weaviate
  classes), it is persisted to `schema_json` for the provisioner to apply.
  """
  def set_surface(slug_or_id, %{} = surface) do
    base = %{
      tools_json: Map.get(surface, "tools", []),
      resources_json: Map.get(surface, "resources", []),
      prompts_json: Map.get(surface, "prompts", [])
    }

    attrs =
      case Map.get(surface, "schema") do
        %{} = schema -> Map.put(base, :schema_json, schema)
        _ -> base
      end

    update(slug_or_id, attrs)
  end

  @doc "Persist generated module implementations ([%{tool, module, function, source, status}])."
  def set_modules(slug_or_id, modules) when is_list(modules) do
    update(slug_or_id, %{modules_json: modules})
  end

  @doc "Find a single module entry by tool name."
  def get_module(def_, tool_name) do
    Enum.find(def_.modules_json || [], fn m -> (m["tool"] || m[:tool]) == tool_name end)
  end

  @doc "Insert or replace (by tool name) one module entry, preserving the rest."
  def put_module(slug_or_id, %{"tool" => tool} = entry) do
    case get(slug_or_id) do
      nil -> {:error, :not_found}
      def_ ->
        kept = Enum.reject(def_.modules_json || [], fn m -> (m["tool"] || m[:tool]) == tool end)
        set_modules(def_.id, kept ++ [entry])
    end
  end

  @doc "Remove a module entry (reverts the tool to LLM serving)."
  def delete_module(slug_or_id, tool_name) do
    case get(slug_or_id) do
      nil -> {:error, :not_found}
      def_ ->
        kept = Enum.reject(def_.modules_json || [], fn m -> (m["tool"] || m[:tool]) == tool_name end)
        set_modules(def_.id, kept)
    end
  end

  def get_tools(slug) do
    case get_active(slug) do
      nil -> []
      def_ -> def_.tools_json || []
    end
  end

  # ── LLM connection pool (org-scoped, reusable) ───────────────

  def list_llms(org_id) do
    MockMCPLLM
    |> where([l], l.organization_id == ^org_id)
    |> order_by([l], asc: l.label)
    |> Repo.all()
  end

  def get_llm(id), do: Repo.get(MockMCPLLM, id)

  def create_llm(attrs) do
    %MockMCPLLM{}
    |> MockMCPLLM.changeset(attrs)
    |> Repo.insert()
  end

  def update_llm(id, attrs) do
    case get_llm(id) do
      nil -> {:error, :not_found}
      llm -> llm |> MockMCPLLM.changeset(attrs) |> Repo.update()
    end
  end

  def delete_llm(id) do
    case get_llm(id) do
      nil -> {:error, :not_found}
      llm -> Repo.delete(llm)
    end
  end

  @doc """
  Resolve a definition's active LLM into agent options
  (`provider`/`model`/`endpoint`/`api_key`). Returns `[]` when no active LLM is
  set, so inference falls back to the app-configured provider/model.
  """
  def active_llm_opts(%MockMCPDefinition{active_llm_id: nil}), do: []
  def active_llm_opts(%MockMCPDefinition{active_llm_id: llm_id}) do
    case get_llm(llm_id) do
      nil -> []
      llm ->
        [provider: llm.provider, model: llm.model, endpoint: llm.endpoint, api_key: llm.api_key]
    end
  end

  # ── Call Logging ─────────────────────────────────────────────

  def log_call(definition_id, attrs) do
    %MockMCPCallLog{}
    |> MockMCPCallLog.changeset(Map.put(attrs, :definition_id, definition_id))
    |> Repo.insert()
  end

  def list_calls(definition_id, opts \\ []) do
    MockMCPCallLog
    |> where([l], l.definition_id == ^definition_id)
    |> order_by([l], desc: l.inserted_at)
    |> limit(^(opts[:limit] || 100))
    |> Repo.all()
  end

  # ── DB Provisioning ─────────────────────────────────────────

  # Per-mock isolation is a dedicated Postgres SCHEMA (`mockmcp_<slug>`) in the
  # app's own database — NOT a separate database. This needs no CREATEDB/
  # CREATEROLE privilege (a role can create schemas in a DB it can connect to),
  # so it works on managed/cloud Postgres. `DataStore` scopes every mock query
  # to this schema via `SET LOCAL search_path`. The schema name is persisted in
  # the (historically named) `db_name` field.
  def provision_db(slug_or_id) do
    case get(slug_or_id) do
      nil -> {:error, :not_found}
      %{db_provisioned: true} = def_ -> {:ok, def_}
      def_ ->
        schema = schema_name(def_.slug)

        with :ok <- create_schema(schema),
             :ok <- apply_postgres_design(schema, def_),
             {:ok, _classes} <- WeaviateStore.ensure_classes(def_, weaviate_design(def_)) do
          def_
          |> MockMCPDefinition.changeset(%{db_name: schema, db_provisioned: true})
          |> Repo.update()
        else
          {:error, reason} -> {:error, reason}
        end
    end
  end

  defp postgres_design(%{schema_json: %{"postgres" => ddl}}) when is_list(ddl), do: ddl
  defp postgres_design(_), do: []

  defp weaviate_design(%{schema_json: %{"weaviate" => classes}}) when is_list(classes), do: classes
  defp weaviate_design(_), do: []

  # Run the agent-designed DDL (plus any free-text schema_sql) inside the mock's
  # schema via a transaction-local search_path, so unqualified tables land there.
  defp apply_postgres_design(schema, def_) do
    statements = postgres_design(def_) ++ List.wrap(blank_to_nil(def_.schema_sql))

    case statements do
      [] ->
        :ok

      stmts ->
        safe = String.replace(schema, ~r/[^a-z0-9_]/, "")

        Repo.transaction(fn ->
          Ecto.Adapters.SQL.query!(Repo, ~s(SET LOCAL search_path TO "#{safe}"), [])
          Enum.each(stmts, fn sql -> Ecto.Adapters.SQL.query!(Repo, sql, []) end)
        end)
        |> case do
          {:ok, _} -> :ok
          {:error, e} -> {:error, "schema DDL failed: #{inspect(e)}"}
        end
    end
  end

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(v), do: v

  @doc "Schema name backing a mock slug (also used by DataStore for search_path)."
  def schema_name(slug) do
    cleaned = slug |> to_string() |> String.downcase() |> String.replace(~r/[^a-z0-9]+/, "_")
    "mockmcp_#{cleaned}"
  end

  defp create_schema(schema) do
    safe = String.replace(schema, ~r/[^a-z0-9_]/, "")
    try do
      Ecto.Adapters.SQL.query!(Repo, ~s(CREATE SCHEMA IF NOT EXISTS "#{safe}"), [])
      :ok
    rescue
      e -> {:error, inspect(e)}
    end
  end

  # ── Private ─────────────────────────────────────────────────

  defp maybe_filter(q, _field, nil), do: q
  defp maybe_filter(q, :organization_id, v), do: where(q, [d], d.organization_id == ^v)
  defp maybe_filter(q, :status, v), do: where(q, [d], d.status == ^v)
  defp maybe_filter(q, :project_id, v), do: where(q, [d], d.project_id == ^v)
end
