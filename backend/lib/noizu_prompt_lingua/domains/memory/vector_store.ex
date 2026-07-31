defmodule NoizuPromptLingua.Domains.Memory.VectorStore do
  @moduledoc """
  Weaviate-backed store for the five named vectors per memory: the four text vectors
  (`content`/`context`/`reflection`/`tangent`, 1536-d) plus the pre-weighted 7-d `emotional`
  vector — all BYO (`vectorizer: none`). This is the PRIMARY vector store for memory; there is
  no pgvector fallback.

  Uses **`noizu_weaviate`** via its public `Noizu.Weaviate.api_call/5`. Named-vector bodies are
  sent as raw maps (the high-level `DataObject` models only a single vector). `noizu_weaviate`
  decodes responses with **atom keys** (incl. the class name as a dynamic atom).

  Config:
    * endpoint — `config :noizu_weaviate, endpoint: "…/"` (compile-time in `noizu_weaviate`)
    * api key  — `config :noizu_weaviate, weaviate_api_key: …` (runtime)
    * gate     — `config :noizu_prompt_lingua, :memory_weaviate, enabled: true, class: "NplMemory"`
  """
  require Logger

  @text_vectors ~w(content context reflection tangent)
  @named_vectors @text_vectors ++ ["emotional"]

  def text_vectors, do: @text_vectors
  def named_vectors, do: @named_vectors

  def config, do: Application.get_env(:noizu_prompt_lingua, :memory_weaviate, [])
  def class, do: config()[:class] || "NplMemory"
  def enabled?, do: config()[:enabled] == true
  def configured?, do: enabled?()

  defp base, do: Noizu.Weaviate.api_base()

  defp call(method, path, body),
    do: Noizu.Weaviate.api_call(method, base() <> path, body, :json, %{})

  @doc "Create the class with five named BYO vectors if absent. Idempotent."
  def ensure_class do
    if enabled?() do
      case call(:get, "v1/schema/#{class()}", nil) do
        {:ok, %{class: _}} -> :ok
        _ -> create_class()
      end
    else
      {:error, :disabled}
    end
  end

  defp create_class do
    vector_config =
      Map.new(@named_vectors, fn n ->
        {n, %{vectorizer: %{none: %{}}, vectorIndexType: "hnsw"}}
      end)

    body = %{
      class: class(),
      vectorConfig: vector_config,
      properties: [
        %{name: "memory_id", dataType: ["text"]},
        %{name: "organization_id", dataType: ["text"]},
        %{name: "scope_type", dataType: ["text"]},
        %{name: "scope_id", dataType: ["text"]},
        %{name: "compartment", dataType: ["text"]},
        %{name: "classification", dataType: ["text"]},
        %{name: "content_type", dataType: ["text"]}
      ]
    }

    case call(:post, "v1/schema", body) do
      {:ok, _} -> :ok
      other -> log_err("create_class", other)
    end
  end

  @doc "Upsert a memory's named vectors + filter props. `vectors`: `%{\"content\" => [...], \"emotional\" => [...]}`."
  def upsert(memory_id, vectors, props) when is_map(vectors) and is_map(props) do
    if enabled?() do
      body = %{
        class: class(),
        id: memory_id,
        properties: Map.put(props, "memory_id", memory_id),
        vectors: vectors
      }

      case call(:post, "v1/objects", body) do
        {:ok, _} -> :ok
        other -> log_err("upsert", other)
      end
    else
      {:error, :disabled}
    end
  end

  @doc "Search one named vector. Returns `{:ok, [%{memory_id, score}]}` (score = 1 - distance)."
  def search(named_vector, query_vec, opts \\ []) when named_vector in @named_vectors do
    if enabled?() do
      limit = opts[:limit] || 50
      where = build_where(opts[:filters] || %{})

      gql =
        "{ Get { #{class()}(limit: #{limit}, " <>
          "nearVector: {vector: #{Jason.encode!(query_vec)}, targetVectors: [\"#{named_vector}\"]}" <>
          where <> ") { memory_id _additional { distance } } } }"

      case call(:post, "v1/graphql", %{query: gql}) do
        {:ok, %{data: %{Get: get}}} when is_map(get) ->
          rows = Map.get(get, String.to_atom(class()), []) || []

          {:ok,
           Enum.map(rows, fn r ->
             dist = get_in(r, [:_additional, :distance]) || 1.0
             %{memory_id: r[:memory_id], score: 1.0 - dist}
           end)}

        other ->
          log_err("search", other)
      end
    else
      {:error, :disabled}
    end
  end

  def delete(memory_id) do
    if enabled?(), do: call(:delete, "v1/objects/#{class()}/#{memory_id}", nil)
    :ok
  end

  @doc "Delete the whole class (all objects) — clean re-population / test teardown."
  def delete_class do
    if enabled?(), do: call(:delete, "v1/schema/#{class()}", nil)
    :ok
  end

  @doc "Count objects in the class via GraphQL Aggregate (verification)."
  def count do
    if enabled?() do
      case call(:post, "v1/graphql", %{query: "{ Aggregate { #{class()} { meta { count } } } }"}) do
        {:ok, %{data: %{Aggregate: agg}}} when is_map(agg) ->
          case Map.get(agg, String.to_atom(class()), []) do
            [%{meta: %{count: c}} | _] -> {:ok, c}
            _ -> {:ok, 0}
          end

        other ->
          other
      end
    else
      {:error, :disabled}
    end
  end

  defp build_where(filters) when map_size(filters) == 0, do: ""

  defp build_where(filters) do
    operands =
      Enum.map(filters, fn {k, v} ->
        "{path: [\"#{k}\"], operator: Equal, valueText: #{Jason.encode!(to_string(v))}}"
      end)

    ", where: {operator: And, operands: [#{Enum.join(operands, ", ")}]}"
  end

  defp log_err(op, other) do
    Logger.warning("[Memory.VectorStore] #{op} failed: #{inspect(other)}")
    {:error, other}
  end
end
