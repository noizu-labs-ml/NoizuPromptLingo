defmodule NoizuPromptLingua.Domains.Memory.Weaver do
  @moduledoc """
  Builds the association graph. For a newly-formed memory it creates weighted edges across:

    * **emotional** — Weaviate `emotional` named-vector neighbors (resonance ≥ threshold)
    * **temporal**  — memories within a time window (proximity-weighted, PG)
    * **contextual**— shared domain (PG)
    * **tangent**   — embed the `tangent` text, link to what it most resonates with (Weaviate)
    * **semantic**  — content-vector neighbors (Weaviate)

  All similarity dimensions use Weaviate (the primary vector store); temporal/contextual are PG.
  Edges are directional rows inserted `on_conflict: :nothing`; reinforcement strengthens later.
  All neighbor lookups are confined to the memory's own scope.
  """
  import Ecto.Query

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Memory.{Memory, AssociationEdge}
  alias NoizuPromptLingua.Domains.Memory.{Emotion, Embeddings, VectorStore}

  @active [:active, :consolidating]

  def config, do: Application.get_env(:noizu_prompt_lingua, :weaver, [])
  defp emo_min, do: config()[:emotional_resonance_min] || 0.85
  defp emo_k, do: config()[:emotional_k] || 8
  defp temporal_window_s, do: config()[:temporal_window_s] || 3600
  defp max_per_dim, do: config()[:max_edges_per_dim] || 8
  defp w, do: config()[:weights] || %{emotional: 0.5, temporal: 0.4, contextual: 0.4, tangent: 0.6, semantic: 0.6}

  @doc "Create association edges for a memory id. Returns the count created/attempted."
  def link(memory_id) when is_binary(memory_id) do
    case Repo.get(Memory, memory_id) do
      nil -> {:ok, 0}
      mem -> {:ok, link_memory(mem)}
    end
  end

  defp link_memory(mem) do
    [
      emotional_edges(mem),
      temporal_edges(mem),
      contextual_edges(mem),
      tangent_edges(mem),
      semantic_edges(mem)
    ]
    |> List.flatten()
    |> Enum.sum()
  end

  # ── emotional (Weaviate "emotional" named vector) ───────────────
  defp emotional_edges(mem) do
    with true <- VectorStore.enabled?(),
         {mood, hormones} <- Emotion.from_row(mem),
         qvec = Emotion.build_vector(mood, hormones),
         {:ok, hits} <- VectorStore.search("emotional", qvec, limit: emo_k(), filters: mem_filters(mem)) do
      hits
      |> Enum.reject(&(&1.memory_id == mem.id))
      |> Enum.filter(&(&1.score >= emo_min()))
      |> Enum.reduce(0, fn h, acc ->
        acc + create_edge(mem.id, h.memory_id, :emotional, h.score, "emotional resonance #{Float.round(h.score, 2)}", %{emotional_similarity: h.score})
      end)
    else
      _ -> 0
    end
  end

  # ── temporal ────────────────────────────────────────────────────
  defp temporal_edges(%{occurred_at: nil}), do: 0

  defp temporal_edges(mem) do
    window = temporal_window_s()

    candidates =
      base(mem)
      |> where([m], fragment("abs(extract(epoch from (? - ?)))", m.occurred_at, ^mem.occurred_at) <= ^window)
      |> limit(^max_per_dim())
      |> select([m], %{id: m.id, occurred_at: m.occurred_at})
      |> Repo.all()

    for c <- candidates, reduce: 0 do
      acc ->
        prox = temporal_proximity(mem.occurred_at, c.occurred_at, window)
        acc + create_edge(mem.id, c.id, :temporal, w()[:temporal] * prox, "temporal proximity", %{temporal_proximity: prox})
    end
  end

  defp temporal_proximity(a, b, window) do
    delta = abs(DateTime.diff(a, b, :second))
    max(0.0, 1.0 - delta / window)
  end

  # ── contextual (shared domain) ──────────────────────────────────
  defp contextual_edges(%{domain: nil}), do: 0
  defp contextual_edges(%{domain: ""}), do: 0

  defp contextual_edges(mem) do
    candidates =
      base(mem)
      |> where([m], m.domain == ^mem.domain)
      |> limit(^max_per_dim())
      |> select([m], m.id)
      |> Repo.all()

    Enum.reduce(candidates, 0, fn id, acc ->
      acc + create_edge(mem.id, id, :contextual, w()[:contextual], "shared domain #{mem.domain}", %{})
    end)
  end

  # ── tangent-seeded (Weaviate) — the agent authoring a link ──────
  defp tangent_edges(%{tangent: t}) when not is_binary(t), do: 0
  defp tangent_edges(%{tangent: ""}), do: 0

  defp tangent_edges(mem) do
    with true <- VectorStore.enabled?() and Embeddings.configured?(),
         {:ok, tvec} <- Embeddings.embed_one(mem.tangent) do
      ["content", "reflection"]
      |> Enum.flat_map(fn nv ->
        case VectorStore.search(nv, tvec, limit: 3, filters: mem_filters(mem)) do
          {:ok, hits} -> hits
          _ -> []
        end
      end)
      |> Enum.map(& &1.memory_id)
      |> Enum.reject(&(&1 == mem.id))
      |> Enum.uniq()
      |> Enum.take(2)
      |> Enum.reduce(0, fn id, acc ->
        acc + create_edge(mem.id, id, :tangent, w()[:tangent], "tangent: #{String.slice(mem.tangent, 0, 80)}", %{})
      end)
    else
      _ -> 0
    end
  end

  # ── semantic (Weaviate content vector) ──────────────────────────
  defp semantic_edges(%{content: c}) when not is_binary(c), do: 0

  defp semantic_edges(mem) do
    with true <- VectorStore.enabled?() and Embeddings.configured?(),
         {:ok, cvec} <- Embeddings.embed_one(mem.content),
         {:ok, hits} <- VectorStore.search("content", cvec, limit: emo_k(), filters: mem_filters(mem)) do
      hits
      |> Enum.map(& &1.memory_id)
      |> Enum.reject(&(&1 == mem.id))
      |> Enum.uniq()
      |> Enum.take(max_per_dim())
      |> Enum.reduce(0, fn id, acc ->
        acc + create_edge(mem.id, id, :semantic, w()[:semantic], "semantic similarity", %{})
      end)
    else
      _ -> 0
    end
  end

  # ── edge insert (idempotent) ────────────────────────────────────
  defp create_edge(src, tgt, _type, _weight, _reason, _extra) when src == tgt, do: 0

  defp create_edge(src, tgt, type, weight, reason, extra) do
    attrs =
      Map.merge(
        %{
          source_memory_id: src,
          target_memory_id: tgt,
          edge_type: type,
          weight: clamp(weight),
          created_by: "weaver",
          reason: reason,
          last_reinforced_at: DateTime.utc_now()
        },
        extra
      )

    case %AssociationEdge{}
         |> AssociationEdge.changeset(attrs)
         |> Repo.insert(on_conflict: :nothing, conflict_target: [:source_memory_id, :target_memory_id, :edge_type]) do
      {:ok, _} -> 1
      _ -> 0
    end
  end

  defp base(mem) do
    from(m in Memory,
      where:
        m.state in @active and m.organization_id == ^mem.organization_id and
          m.scope_type == ^mem.scope_type and m.scope_id == ^mem.scope_id and m.id != ^mem.id
    )
  end

  defp mem_filters(mem) do
    %{
      "organization_id" => to_string(mem.organization_id),
      "scope_type" => to_string(mem.scope_type),
      "scope_id" => to_string(mem.scope_id)
    }
  end

  defp clamp(w), do: w |> max(0.05) |> min(1.0)
end
