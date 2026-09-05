defmodule NoizuPromptLingua.Domains.Memory.Recall do
  @moduledoc """
  Retrieval. `by_emotion/3` is the emotional-resonance path — a Weaviate nearVector over the 7-d
  `emotional` named vector. `active/3` fuses the four Weaviate text named-vector searches (or a
  `pg_trgm` lexical fallback) + the emotional path + a recursive association-graph walk via
  Reciprocal Rank Fusion, then winnows and formats for context injection.

  Scope: `persona`/`team_member` see only their own memories; `weego` sees all memories in its
  org (see `Sentinel`).
  """
  require Logger
  import Ecto.Query

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Memory.Memory
  alias NoizuPromptLingua.Schema.Memory.RecallLog

  alias NoizuPromptLingua.Domains.Memory.{
    Emotion,
    Embeddings,
    VectorStore,
    Reinforcement,
    Monitor,
    Sentinel
  }

  @active_states [:active, :consolidating]
  @graph_max_hops 3
  @graph_min_weight 0.2
  # Per-node fan-out cap: the walk follows only the N strongest edges per node, bounding a dense
  # graph's recursive walk to ~N^hops paths (else it spills to disk and stalls).
  @graph_fanout 8

  def config, do: Application.get_env(:noizu_prompt_lingua, :memory_recall, [])

  defp vector_weights,
    do: config()[:vector_weights] || %{content: 1.0, context: 0.8, tangent: 0.8, reflection: 0.7}

  defp rrf_k, do: config()[:rrf_k] || 60
  defp cpp, do: config()[:candidates_per_path] || 50
  defp default_limit, do: config()[:default_limit] || 12

  # ── Emotional-resonance recall (Weaviate "emotional" vector) ────
  def by_emotion(emotional_state, opts \\ [], context \\ %{}) do
    started = System.monotonic_time(:millisecond)
    scope = Sentinel.scope(context)
    limit = opts[:limit] || default_limit()
    {mood, hormones} = split_state(emotional_state, scope)
    qvec = Emotion.build_vector(mood, hormones)

    hits = emotional_hits(qvec, scope, limit * 2)
    ids = Enum.map(hits, & &1.memory_id)
    score_by_id = Map.new(hits, &{&1.memory_id, &1.score})

    rows =
      ids
      |> hydrate(scope)
      |> Sentinel.authorize(context)
      |> reorder_by(ids)
      |> Enum.map(&Map.put(&1, :resonance, Map.get(score_by_id, &1.id)))
      |> Enum.take(limit)

    Reinforcement.on_recall(rows, context)
    log(:by_emotion, scope, context, nil, rows, started, %{path: "emotional"})
    {:ok, %{mode: :by_emotion, results: rows, xml: to_xml(rows, mode: "by_emotion")}}
  end

  # ── Active recall (multi-vector + emotional + graph, RRF-fused) ─
  def active(query, opts \\ [], context \\ %{}) when is_binary(query) do
    started = System.monotonic_time(:millisecond)
    scope = Sentinel.scope(context)
    limit = opts[:limit] || default_limit()

    semantic_lists = semantic_rank_lists(query, scope)
    emotional_list = emotional_rank_list(scope)

    seed_ids =
      (semantic_lists ++ emotional_list)
      |> Enum.flat_map(fn {_w, _s, ids} -> ids end)
      |> Enum.uniq()
      |> Enum.take(60)

    graph_list = graph_rank_list(scope, seed_ids)
    rank_lists = semantic_lists ++ emotional_list ++ graph_list

    fused = rrf(rank_lists, rrf_k())
    ids = fused |> Enum.map(&elem(&1, 0)) |> Enum.take(limit * 3)

    rows =
      ids
      |> hydrate(scope)
      |> Sentinel.authorize(context)
      |> reorder_by(ids)
      |> Enum.take(limit)

    breakdown = %{
      paths:
        Enum.map(rank_lists, fn {w, _, ids} -> %{weight: w, kind: :rank, count: length(ids)} end),
      semantic: if(semantic_lists == [], do: "none", else: "weaviate_or_lexical"),
      graph: graph_list != []
    }

    Reinforcement.on_recall(rows, context)
    log(:active, scope, context, query, rows, started, breakdown)
    {:ok, %{mode: :active, results: rows, xml: to_xml(rows, mode: "active", query: query)}}
  end

  # ── Recent memories for a scope (no query) ─────────────────────
  def recent(opts \\ [], context \\ %{}) do
    scope = Sentinel.scope(context)
    limit = opts[:limit] || default_limit()

    rows =
      base_scope(scope)
      |> order_by([m], desc: m.occurred_at, desc: m.id)
      |> limit(^limit)
      |> Repo.all()
      |> Sentinel.authorize(context)

    {:ok, %{mode: :recent, results: rows, xml: to_xml(rows, mode: "recent")}}
  end

  # ── emotional Weaviate search ──────────────────────────────────
  defp emotional_hits(qvec, scope, limit) do
    if VectorStore.enabled?() do
      case VectorStore.search("emotional", qvec,
             limit: limit,
             filters: Sentinel.weaviate_filters(scope)
           ) do
        {:ok, hits} -> hits
        _ -> []
      end
    else
      []
    end
  end

  # ── graph traversal (recursive CTE, fan-out capped) ─────────────
  defp graph_rank_list(_scope, []), do: []

  defp graph_rank_list(_scope, seed_ids) do
    sql = """
    WITH RECURSIVE walk(memory_id, depth, path_weight, path) AS (
      SELECT unnest(string_to_array($1, ',')::uuid[]), 0, 1.0::real, ARRAY[]::uuid[]
      UNION ALL
      SELECT nxt.memory_id, w.depth + 1, w.path_weight * nxt.weight, w.path || w.memory_id
      FROM walk w
      JOIN LATERAL (
        SELECT CASE WHEN e.source_memory_id = w.memory_id THEN e.target_memory_id ELSE e.source_memory_id END AS memory_id,
               e.weight
        FROM association_edges e
        WHERE (e.source_memory_id = w.memory_id OR e.target_memory_id = w.memory_id) AND e.weight >= $2
        ORDER BY e.weight DESC, e.id
        LIMIT $5
      ) nxt ON true
      WHERE w.depth < $3
        AND NOT (nxt.memory_id = ANY(w.path))
    )
    SELECT memory_id::text, MAX(path_weight) AS pw
    FROM walk WHERE depth > 0
    GROUP BY memory_id ORDER BY pw DESC, memory_id LIMIT $4
    """

    case Ecto.Adapters.SQL.query(Repo, sql, [
           Enum.join(seed_ids, ","),
           @graph_min_weight,
           @graph_max_hops,
           cpp(),
           @graph_fanout
         ]) do
      {:ok, %{rows: rows}} ->
        case Enum.map(rows, fn [id, _pw] -> id end) do
          [] -> []
          ids -> [{0.8, {:graph, :cte}, ids}]
        end

      _ ->
        []
    end
  end

  # ── semantic paths ─────────────────────────────────────────────
  defp semantic_rank_lists(query, scope) do
    cond do
      Embeddings.configured?() and VectorStore.configured?() ->
        case Embeddings.embed_one(query) do
          {:ok, qvec} ->
            lists = weaviate_lists(qvec, scope)

            # Weaviate configured but unreachable (CI runners / degraded
            # cluster): every search errors and collapses to empty ids. Don't
            # serve zero semantic signal — append the lexical arm (the
            # pg_trgm fallback this module's docs promise). No-op when
            # Weaviate returns real hits.
            if Enum.any?(lists, fn {_weight, _source, ids} -> ids != [] end) do
              lists
            else
              [lexical_list(query, scope) | lists]
            end

          _ ->
            [lexical_list(query, scope)]
        end

      true ->
        [lexical_list(query, scope)]
    end
  end

  defp weaviate_lists(qvec, scope) do
    filters = Sentinel.weaviate_filters(scope)

    for nv <- VectorStore.text_vectors() do
      weight = Map.get(vector_weights(), String.to_atom(nv), 0.7)

      ids =
        case VectorStore.search(nv, qvec, limit: cpp(), filters: filters) do
          {:ok, hits} -> Enum.map(hits, & &1.memory_id)
          _ -> []
        end

      {weight, {:weaviate, nv}, ids}
    end
  end

  defp lexical_list(query, scope) do
    # Only genuine trigram matches enter the lexical list; an explicit text query outweighs
    # ambient emotional resonance (weight 2.0) — the caller typed these words, honor them.
    ids =
      base_scope(scope)
      |> where([m], fragment("similarity(?, ?) > 0.03", m.content, ^query))
      |> order_by([m], desc: fragment("similarity(?, ?)", m.content, ^query), asc: m.id)
      |> limit(^cpp())
      |> select([m], m.id)
      |> Repo.all()

    {2.0, {:lexical, :content}, ids}
  end

  defp emotional_rank_list(scope) do
    %{mood: mood, hormones: hormones} = Monitor.current_emotional(scope)
    qvec = Emotion.build_vector(mood, hormones)
    ids = emotional_hits(qvec, scope, cpp()) |> Enum.map(& &1.memory_id)
    [{0.45, {:emotional, :vad}, ids}]
  end

  # ── Reciprocal Rank Fusion ─────────────────────────────────────
  defp rrf(rank_lists, k) do
    rank_lists
    |> Enum.reduce(%{}, fn {weight, _src, ids}, acc ->
      ids
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {id, idx}, a ->
        Map.update(a, id, weight / (k + idx + 1), &(&1 + weight / (k + idx + 1)))
      end)
    end)
    |> Enum.sort_by(fn {_id, s} -> -s end)
  end

  # ── query/hydration helpers ────────────────────────────────────
  defp base_scope(scope) do
    from(m in Memory, where: m.state in @active_states) |> Sentinel.scope_filter(scope)
  end

  defp hydrate([], _scope), do: []

  defp hydrate(ids, scope) do
    base_scope(scope) |> where([m], m.id in ^ids) |> Repo.all()
  end

  defp reorder_by(rows, ids) do
    by_id = Map.new(rows, &{&1.id, &1})
    ids |> Enum.map(&Map.get(by_id, &1)) |> Enum.reject(&is_nil/1)
  end

  defp split_state(%{mood: mood} = s, _scope), do: {mood, Map.get(s, :hormones, %{})}
  defp split_state(%{"mood" => mood} = s, _scope), do: {mood, Map.get(s, "hormones", %{})}

  defp split_state(flat, scope) when is_map(flat) and map_size(flat) > 0,
    do: {flat, Monitor.current_hormones(scope)}

  defp split_state(_, scope), do: {Emotion.neutral_mood(), Monitor.current_hormones(scope)}

  # ── context-injection formatting ───────────────────────────────
  def to_xml(rows, meta) do
    mode = meta[:mode] || "active"
    inner = Enum.map_join(rows, "\n", &memory_xml/1)
    "<memories recalled=\"#{length(rows)}\" mode=\"#{mode}\">\n" <> inner <> "\n</memories>"
  end

  defp memory_xml(mem) do
    res = if r = Map.get(mem, :resonance), do: " resonance=\"#{Float.round(r, 2)}\"", else: ""
    formed = if mem.occurred_at, do: DateTime.to_iso8601(mem.occurred_at), else: ""
    body = mem.summary || mem.content || ""

    "  <memory id=\"#{mem.id}\"#{res} mood=\"v#{fmt(mem.valence)} a#{fmt(mem.arousal)}\" " <>
      "formed=\"#{formed}\" domain=\"#{mem.domain || ""}\">\n" <>
      "    #{escape(body)}\n" <>
      tangent_line(mem) <>
      "  </memory>"
  end

  defp tangent_line(%{tangent: t}) when is_binary(t) and t != "",
    do: "    <tangent>#{escape(t)}</tangent>\n"

  defp tangent_line(_), do: ""

  defp fmt(n) when is_number(n), do: Float.round(n * 1.0, 2)
  defp fmt(_), do: 0.0

  defp escape(s) when is_binary(s) do
    s
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end

  defp escape(_), do: ""

  # ── recall_log (best-effort) ───────────────────────────────────
  defp log(mode, scope, context, query, rows, started, breakdown) do
    duration = System.monotonic_time(:millisecond) - started
    s = scope || %{}

    %RecallLog{}
    |> RecallLog.changeset(%{
      requester_id: context[:requester_id] || to_string(Map.get(s, :scope_id) || "anonymous"),
      organization_id: Map.get(s, :organization_id),
      scope_type: Map.get(s, :scope_type),
      scope_id: Map.get(s, :scope_id),
      mode: to_string(mode),
      query: query,
      total_candidates: length(rows),
      returned_count: length(rows),
      duration_ms: duration,
      result_memory_ids: Enum.map(rows, & &1.id),
      path_breakdown: breakdown,
      occurred_at: DateTime.utc_now()
    })
    |> Repo.insert()
  rescue
    e -> Logger.warning("[Memory.Recall] log failed: #{inspect(e)}")
  end
end
