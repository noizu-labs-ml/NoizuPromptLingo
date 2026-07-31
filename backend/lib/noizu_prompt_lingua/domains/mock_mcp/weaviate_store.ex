defmodule NoizuPromptLingua.Domains.MockMCP.WeaviateStore do
  @moduledoc """
  Per-mock Weaviate backing store. Each mock MCP gets its own prefixed
  collection(s) — `Mockmcp<Slug><Name>` (GraphQL-safe PascalCase) — designed by
  the generation agent (`schema_json["weaviate"]`) and created at provision time.

  Vectors are BYO (`vectorizer: none`): text is embedded through the app's
  existing OpenAI embedding path (`Memory.Embeddings`, 1536-d), matching the
  memory engine. Reuses `noizu_weaviate` via `Noizu.Weaviate.api_call/5`, which
  decodes responses with atom keys (incl. the class name as a dynamic atom).

  Isolation is by class name: ops only ever touch classes prefixed for the given
  mock, so one mock can never read or write another's collections.
  """
  require Logger

  alias NoizuPromptLingua.Domains.Memory.Embeddings

  @prefix "Mockmcp"

  defp base, do: Noizu.Weaviate.api_base()

  defp call(method, path, body),
    do: Noizu.Weaviate.api_call(method, base() <> path, body, :json, %{})

  @doc "GraphQL-safe class name for a mock's collection (PascalCase, prefixed)."
  def class_name(slug, name), do: @prefix <> pascal(slug) <> pascal(name)

  defp pascal(s) do
    s
    |> to_string()
    |> String.split(~r/[^A-Za-z0-9]+/, trim: true)
    |> Enum.map_join("", fn w ->
      String.upcase(String.first(w)) <> (String.slice(w, 1..-1//1) || "")
    end)
  end

  # ── Provisioning ─────────────────────────────────────────────

  @doc """
  Create the mock's designed collections if absent (idempotent). `classes` is the
  `schema_json["weaviate"]` list. Returns `{:ok, [class_name]}` or `{:error, _}`.
  """
  def ensure_classes(%{slug: slug}, classes) when is_list(classes) do
    Enum.reduce_while(classes, {:ok, []}, fn c, {:ok, acc} ->
      case class_def_name(c) do
        nil ->
          {:cont, {:ok, acc}}

        name ->
          cls = class_name(slug, name)

          case ensure_class(cls, c) do
            :ok -> {:cont, {:ok, [cls | acc]}}
            {:error, e} -> {:halt, {:error, e}}
          end
      end
    end)
    |> case do
      {:ok, names} -> {:ok, Enum.reverse(names)}
      other -> other
    end
  end

  def ensure_classes(_def, _classes), do: {:ok, []}

  defp ensure_class(cls, c) do
    case call(:get, "v1/schema/#{cls}", nil) do
      {:ok, %{class: _}} -> :ok
      _ -> create_class(cls, c)
    end
  end

  defp create_class(cls, c) do
    # Always declare a "text" property: `add/4` stores the embedded source text
    # under it and `query/4` selects it back. Dedupe in case the design names it too.
    designed = Enum.map(props(c), &property/1)
    properties = [%{name: "text", dataType: ["text"]} | designed] |> Enum.uniq_by(& &1.name)

    body = %{
      class: cls,
      description: string_field(c, "description"),
      vectorizer: "none",
      properties: properties
    }

    case call(:post, "v1/schema", body) do
      {:ok, _} -> :ok
      other -> log_err("create_class #{cls}", other)
    end
  end

  defp property(p) do
    %{
      name: string_field(p, "name") || "value",
      dataType: [data_type(string_field(p, "dataType"))]
    }
  end

  defp data_type(t) when t in ~w(text string), do: "text"
  defp data_type(t) when t in ~w(int integer), do: "int"
  defp data_type(t) when t in ~w(number float double numeric), do: "number"
  defp data_type(t) when t in ~w(bool boolean), do: "boolean"
  defp data_type(_), do: "text"

  @doc "Drop all of a mock's collections (teardown). Best-effort."
  def delete_classes(%{slug: slug, schema_json: %{"weaviate" => classes}})
      when is_list(classes) do
    Enum.each(classes, fn c ->
      case class_def_name(c) do
        nil -> :ok
        name -> call(:delete, "v1/schema/#{class_name(slug, name)}", nil)
      end
    end)

    :ok
  end

  def delete_classes(_def), do: :ok

  # ── Serve-time ops (used by the mock agent's internal weaviate_* ops) ──

  @doc """
  Embed `text` and store an object (with optional extra `props`) in the mock's
  `name` collection. Returns `{:ok, %{id: id}}` or `{:error, message}`.
  """
  def add(def_, name, text, props \\ %{}) when is_binary(text) do
    with {:ok, cls} <- resolve_class(def_, name),
         {:ok, vec} <- embed(text) do
      body = %{
        class: cls,
        properties: Map.merge(stringify(props), %{"text" => text}),
        vector: vec
      }

      case call(:post, "v1/objects", body) do
        {:ok, %{id: id}} -> {:ok, %{id: id}}
        {:ok, _} -> {:ok, %{id: nil}}
        other -> {:error, err_msg(other)}
      end
    end
  end

  @doc """
  Semantic search: embed `query` and return the nearest objects in the mock's
  `name` collection. Returns `{:ok, [%{id, score, properties}]}`.
  """
  def query(def_, name, query, opts \\ []) when is_binary(query) do
    with {:ok, cls} <- resolve_class(def_, name),
         {:ok, qvec} <- embed(query) do
      limit = opts[:limit] || 10
      fields = (prop_names(def_, name) ++ ["text"]) |> Enum.uniq() |> Enum.join(" ")

      gql =
        "{ Get { #{cls}(limit: #{limit}, nearVector: {vector: #{Jason.encode!(qvec)}}) " <>
          "{ #{fields} _additional { id distance } } } }"

      case call(:post, "v1/graphql", %{query: gql}) do
        {:ok, %{data: %{Get: get}}} when is_map(get) ->
          rows = Map.get(get, String.to_atom(cls), []) || []
          {:ok, Enum.map(rows, &row_to_match/1)}

        other ->
          {:error, err_msg(other)}
      end
    end
  end

  defp row_to_match(r) do
    add_ = r[:_additional] || %{}
    dist = add_[:distance] || 1.0
    props = r |> Map.delete(:_additional) |> Map.new(fn {k, v} -> {to_string(k), v} end)
    %{id: add_[:id], score: 1.0 - dist, properties: props}
  end

  # ── Helpers ──────────────────────────────────────────────────

  # Only allow ops against a collection the mock actually designed.
  defp resolve_class(%{slug: slug} = def_, name) do
    designed =
      def_
      |> designed_classes()
      |> Enum.map(&class_def_name/1)
      |> Enum.reject(&is_nil/1)

    target = pascal(name)

    if Enum.any?(designed, fn n -> pascal(n) == target end) do
      {:ok, class_name(slug, name)}
    else
      {:error,
       "unknown collection '#{name}' — declared collections: #{Enum.join(designed, ", ")}"}
    end
  end

  defp designed_classes(%{schema_json: %{"weaviate" => c}}) when is_list(c), do: c
  defp designed_classes(_), do: []

  defp prop_names(def_, name) do
    target = pascal(name)

    def_
    |> designed_classes()
    |> Enum.find(fn c -> pascal(class_def_name(c) || "") == target end)
    |> case do
      %{} = c -> props(c) |> Enum.map(&string_field(&1, "name")) |> Enum.reject(&is_nil/1)
      _ -> []
    end
  end

  defp embed(text) do
    case Embeddings.embed_one(text) do
      {:ok, vec} -> {:ok, vec}
      {:error, reason} -> {:error, "embedding failed: #{inspect(reason)}"}
    end
  end

  defp class_def_name(c) do
    case string_field(c, "name") do
      n when is_binary(n) and n != "" -> n
      _ -> nil
    end
  end

  defp props(c) do
    case c["properties"] || c[:properties] do
      l when is_list(l) -> l
      _ -> []
    end
  end

  defp string_field(m, key) when is_map(m), do: m[key] || m[String.to_atom(key)]
  defp string_field(_, _), do: nil

  defp stringify(m) when is_map(m), do: Map.new(m, fn {k, v} -> {to_string(k), v} end)
  defp stringify(_), do: %{}

  defp err_msg(other), do: inspect(other)

  defp log_err(op, other) do
    Logger.warning("[MockMCP.WeaviateStore] #{op} failed: #{inspect(other)}")
    {:error, err_msg(other)}
  end
end
