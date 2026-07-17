defmodule NoizuPromptLingua.Domains.MCPOverview.Indexer do
  @moduledoc """
  Builds/refreshes the per-tool description vectors (`mcp_tool_vectors`) for a
  scope. Each tool's `"<category> / <name>: <description>"` text is embedded (via
  the shared `Domains.Memory.Embeddings` OpenAI 1536-d path) and stored keyed by a
  `description_hash`; a tool whose hash is unchanged is **skipped** (no re-embed).

  Embeddings follow the app's config gating: when the embedder is not configured
  (`{:error, :not_configured}`), refresh is a no-op that reports `configured: false`
  so the generator degrades to an unfocused overview.
  """
  require Logger
  alias NoizuPromptLingua.Domains.Memory.Embeddings
  alias NoizuPromptLingua.Domains.MCPOverview.Store

  @type spec :: %{required(:name) => String.t(), optional(any) => any}

  @doc """
  Refresh tool vectors for `scope_slug` from `specs` (catalog entries with
  `:name`, `:category`, `:description`). Returns a summary map:
  `%{configured: bool, skipped: n, embedded: n, changed: [tool_name]}`.
  """
  @spec refresh(String.t(), [spec()], keyword()) :: map()
  def refresh(scope_slug, specs, _opts \\ []) do
    if Embeddings.configured?() do
      do_refresh(scope_slug, specs)
    else
      %{configured: false, skipped: length(specs), embedded: 0, changed: []}
    end
  end

  defp do_refresh(scope_slug, specs) do
    # Partition into unchanged (hash matches stored) vs needing (re)embed.
    {changed, skipped} =
      Enum.split_with(specs, fn spec ->
        hash = description_hash(text_for(spec))

        case Store.get_tool_vector(scope_slug, spec.name) do
          %{description_hash: ^hash} -> false
          _ -> true
        end
      end)

    embedded = embed_and_store(scope_slug, changed)

    %{
      configured: true,
      skipped: length(skipped),
      embedded: embedded,
      changed: Enum.map(changed, & &1.name)
    }
  end

  defp embed_and_store(_scope_slug, []), do: 0

  defp embed_and_store(scope_slug, specs) do
    texts = Enum.map(specs, &text_for/1)

    case Embeddings.embed(texts) do
      {:ok, vectors} ->
        specs
        |> Enum.zip(vectors)
        |> Enum.reduce(0, fn {spec, vec}, acc ->
          attrs = %{
            scope_slug: scope_slug,
            group_id: group_id_for(spec),
            tool_name: spec.name,
            description_hash: description_hash(text_for(spec)),
            embedding: vec
          }

          case Store.put_tool_vector(attrs) do
            {:ok, _} -> acc + 1
            {:error, reason} ->
              Logger.warning("[MCPOverview.Indexer] store failed for #{spec.name}: #{inspect(reason)}")
              acc
          end
        end)

      {:error, reason} ->
        Logger.warning("[MCPOverview.Indexer] embed failed: #{inspect(reason)}")
        0
    end
  end

  @doc "Embeddable text for a tool spec."
  def text_for(spec) do
    "#{group_id_for(spec)} / #{spec.name}: #{Map.get(spec, :description) || ""}"
  end

  @doc "SHA-256 (hex) of a tool's description text; the change-detection key."
  def description_hash(text) do
    :crypto.hash(:sha256, text) |> Base.encode16(case: :lower)
  end

  defp group_id_for(spec), do: Map.get(spec, :category) || "Uncategorized"
end
