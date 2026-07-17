defmodule NoizuPromptLingua.Domains.MCPOverview.Service do
  @moduledoc """
  `mcp_overview` flow (design spec §5):

    1. Embed the `task` (shared OpenAI 1536-d path, `Domains.Memory.Embeddings`).
    2. pgvector nearest-neighbor over `mcp_overviews` for the scope — a hit within
       the cosine-distance threshold returns the CACHED overview (approved preferred).
    3. Miss → (best-effort) refresh the scope's tool vectors, generate a focused
       overview, persist it as `status: "generated"` (pending review), and return it
       flagged `generated: true`.

  When embeddings are unconfigured the flow still works: it generates an UNFOCUSED
  overview (no proximity ranking), stores it without a task embedding (so it is not
  recall-matchable), and returns it flagged generated.
  """
  require Logger
  alias NoizuPromptLingua.Domains.Memory.Embeddings
  alias NoizuPromptLingua.Domains.MCPOverview.{Store, Indexer, Generator}

  @doc """
  Produce an overview for `scope_slug` given the agent's `task` and the scope's
  `specs` (catalog entries: `:name`, `:category`, `:description`). `opts`:
  `:focus`, `:verbosity`, `:runner`, `:model`, `:threshold`.

  Returns `{:ok, %{overview_md, generated, cached, status, id}}` | `{:error, term}`.
  """
  def overview(scope_slug, task, specs, opts \\ []) do
    case embed(task) do
      {:ok, vec} ->
        case Store.nearest_overview(scope_slug, vec, opts) do
          {:ok, hit} -> {:ok, cached_result(hit)}
          :miss -> generate_and_store(scope_slug, task, vec, specs, opts)
        end

      {:error, :not_configured} ->
        generate_and_store(scope_slug, task, nil, specs, opts)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp embed(task) do
    if Embeddings.configured?() do
      Embeddings.embed_one(task)
    else
      {:error, :not_configured}
    end
  end

  defp generate_and_store(scope_slug, task, vec, specs, opts) do
    # Focus needs the scope's per-tool vectors; refresh them best-effort (no-op when
    # embeddings unconfigured or vec is nil).
    if vec, do: Indexer.refresh(scope_slug, specs, opts)

    case Generator.build(scope_slug, task, vec, specs, opts) do
      {:ok, md} ->
        attrs = %{
          scope_slug: scope_slug,
          task_text: task,
          task_embedding: vec,
          overview_md: md,
          runner: opts[:runner],
          model: opts[:model],
          verbosity: opts[:verbosity],
          status: "generated"
        }

        id =
          case Store.insert_overview(attrs) do
            {:ok, row} ->
              row.id

            {:error, reason} ->
              Logger.warning("[MCPOverview.Service] persist failed: #{inspect(reason)}")
              nil
          end

        {:ok, %{overview_md: md, generated: true, cached: false, status: "generated", id: id}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp cached_result(hit) do
    %{overview_md: hit.overview_md, generated: false, cached: true, status: hit.status, id: hit.id}
  end
end
