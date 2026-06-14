defmodule NPLWeb.API.MockMCPAPIController do
  use NPLWeb, :controller

  alias NoizuPromptLingua.Domains.MockMCP
  alias NoizuPromptLingua.Domains.MockMCP.Agent

  def index(conn, params) do
    opts = Enum.reduce([:status, :project_id], [], fn k, acc ->
      case params[Atom.to_string(k)] do
        nil -> acc
        v -> [{k, v} | acc]
      end
    end)
    definitions = MockMCP.list(opts)
    json(conn, %{definitions: Enum.map(definitions, &definition_json/1)})
  end

  def show(conn, %{"slug" => slug}) do
    case MockMCP.get(slug) do
      nil -> conn |> put_status(404) |> json(%{error: "not_found"})
      def_ -> json(conn, %{definition: definition_json(def_)})
    end
  end

  def create(conn, params) do
    attrs = %{
      slug: params["slug"],
      title: params["title"],
      prompt: params["prompt"],
      llm_provider: params["llm_provider"],
      llm_model: params["llm_model"],
      llm_endpoint: params["llm_endpoint"],
      created_by: params["created_by"],
      project_id: params["project_id"]
    }

    case MockMCP.create(attrs) do
      {:ok, def_} ->
        if params["auto_generate_tools"] != false do
          spawn(fn -> generate_and_save_tools(def_) end)
        end
        conn |> put_status(201) |> json(%{definition: definition_json(def_)})
      {:error, cs} ->
        conn |> put_status(422) |> json(%{errors: format_errors(cs)})
    end
  end

  def update(conn, %{"slug" => slug} = params) do
    attrs = Map.take(params, ~w(title prompt status llm_provider llm_model llm_endpoint tools_json schema_sql))
    |> Map.new(fn {k, v} -> {String.to_existing_atom(k), v} end)

    case MockMCP.update(slug, attrs) do
      {:ok, def_} ->
        if Map.has_key?(params, "prompt") && params["auto_generate_tools"] != false do
          spawn(fn -> generate_and_save_tools(def_) end)
        end
        json(conn, %{definition: definition_json(def_)})
      {:error, :not_found} ->
        conn |> put_status(404) |> json(%{error: "not_found"})
      {:error, cs} ->
        conn |> put_status(422) |> json(%{errors: format_errors(cs)})
    end
  end

  def delete(conn, %{"slug" => slug}) do
    case MockMCP.delete(slug) do
      {:ok, _} -> json(conn, %{deleted: true})
      {:error, :not_found} -> conn |> put_status(404) |> json(%{error: "not_found"})
    end
  end

  def activate(conn, %{"slug" => slug}) do
    case MockMCP.activate(slug) do
      {:ok, def_} -> json(conn, %{definition: definition_json(def_)})
      {:error, :not_found} -> conn |> put_status(404) |> json(%{error: "not_found"})
    end
  end

  def generate_tools(conn, %{"slug" => slug}) do
    case MockMCP.get(slug) do
      nil -> conn |> put_status(404) |> json(%{error: "not_found"})
      def_ ->
        opts = [provider: def_.llm_provider, model: def_.llm_model, endpoint: def_.llm_endpoint]
        case Agent.generate_tools(def_.prompt, opts) do
          {:ok, tools} ->
            {:ok, updated} = MockMCP.set_tools(def_.id, tools)
            json(conn, %{tools: updated.tools_json})
          {:error, :invalid_tool_json, raw} ->
            conn |> put_status(422) |> json(%{error: "LLM returned invalid tool JSON", raw: raw})
          {:error, reason} ->
            conn |> put_status(502) |> json(%{error: "LLM call failed", detail: inspect(reason)})
        end
    end
  end

  def calls(conn, %{"slug" => slug}) do
    case MockMCP.get(slug) do
      nil -> conn |> put_status(404) |> json(%{error: "not_found"})
      def_ ->
        logs = MockMCP.list_calls(def_.id)
        json(conn, %{calls: Enum.map(logs, fn l ->
          %{id: l.id, method: l.method, tool_name: l.tool_name,
            arguments: l.arguments, response: l.response,
            latency_ms: l.latency_ms, error: l.error, at: l.inserted_at}
        end)})
    end
  end

  def provision_db(conn, %{"slug" => slug}) do
    case MockMCP.provision_db(slug) do
      {:ok, def_} -> json(conn, %{db_name: def_.db_name, provisioned: true})
      {:error, :not_found} -> conn |> put_status(404) |> json(%{error: "not_found"})
      {:error, reason} -> conn |> put_status(500) |> json(%{error: inspect(reason)})
    end
  end

  defp generate_and_save_tools(def_) do
    opts = [provider: def_.llm_provider, model: def_.llm_model, endpoint: def_.llm_endpoint]
    case Agent.generate_tools(def_.prompt, opts) do
      {:ok, tools} -> MockMCP.set_tools(def_.id, tools)
      _ -> :ok
    end
  end

  defp definition_json(d) do
    %{id: d.id, slug: d.slug, title: d.title, prompt: d.prompt,
      status: d.status, tools_json: d.tools_json, schema_sql: d.schema_sql,
      llm_provider: d.llm_provider, llm_model: d.llm_model,
      db_name: d.db_name, db_provisioned: d.db_provisioned,
      created_by: d.created_by, project_id: d.project_id,
      tool_count: length(d.tools_json || []),
      created_at: d.inserted_at, updated_at: d.updated_at}
  end

  defp format_errors(%Ecto.Changeset{} = cs) do
    Ecto.Changeset.traverse_errors(cs, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
  defp format_errors(other), do: inspect(other)
end
