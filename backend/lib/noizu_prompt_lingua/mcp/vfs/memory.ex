defmodule NoizuPromptLingua.MCP.VFS.Memory do
  @moduledoc """
  VFS backend for the `memory` group (MCP-VFS-GROUP-MOUNTS.md §2.12) —
  append-log journal + semantic query, wired to the
  `NoizuPromptLingua.Domains.Memory` engine. Full absolute paths,
  self-enforced §1.3 gates (via `NoizuPromptLingua.MCP.VFS.Scope`),
  independently conformance-testable.

      /tobor/{org}/memory                          → agent dirs (personas + call signs)
      /tobor/{org}/memory/overview.md              → Overview tool render
      /tobor/{org}/memory/agents/                  → call-sign registry (readdir)
      /tobor/{org}/memory/agents/{call-sign}.json  → AgentRegister record
      /tobor/{org}/memory/{agent}/journal/         → the agent's journal (readdir window)
      /tobor/{org}/memory/{agent}/journal/{id}.json → one memory (create/read/reinforce)
      /tobor/{org}/memory/{agent}/journal/{id}.links.json → association edges
      /tobor/{org}/memory/{agent}/_query           → control/query node (Recall)

  `{agent}` resolves through `Memory.Agents.resolve_agent/2` — an org call sign
  (weego / team_member), a persona slug/uuid, or the literal `weego` (the org's
  weego identity). Reserved names `agents` and `overview.md` are not addressable
  as agents.

  ## Tool mapping

    * **AgentRegister** → `create` of `agents/{call-sign}.json`; content is
      `{"kind": "weego"|"team_member", "display_name": …}` (plain text ⇒
      `team_member`). Duplicate call signs are `:eexist`.
    * **AgentList** → readdir `agents/`.
    * **Remember** → `create` of `journal/{name}.json`; content is a JSON
      object (`context`, `reflection`, `tangent`, `summary`, `content_type`,
      `domain`, `topic`, `mood{valence,arousal,dominance}`, …) or plain text
      (⇒ `content`). The memory id is server-generated and returned in
      `xattrs`; a `Sentinel.Guardian` quarantine still answers `:ok` with
      `xattrs.status = "quarantined"` and no id (the row exists, unreachable
      from recall).
    * **Memory.Reinforce / Denforce** → `write` of `journal/{id}.json` with
      `reinforce` / `denforce` (bare word or `{"reinforce": true}`).
    * **Memory.Associations** → read `{id}.links.json` (type/weight/reason
      edges, strongest first; scope-filtered).
    * **Recall / RecallByEmotion** → the `_query` control node, the canonical
      write-request/read-result pattern (§2.12): write
      `{"query": "…", "limit": n}` (active multi-path recall), a mood vector
      (`{"mood": {"valence": …, …}}` or flat `{"valence": …}` — emotional
      resonance), or a bare text (⇒ query); the next read consumes the ranked
      results (one-shot buffer, keyed per connection session). Reading with
      nothing buffered is `:enoent`. Semantic paths ride Weaviate when
      configured and degrade to the lexical `pg_trgm` path otherwise.

  Journal listings are bounded windows (500, cursor paginated); `remove` is
  `:enosys` (archive/restore stay on the MCP surface — no delete tools exist).
  """

  use Noizu.MCP.VFS

  import Ecto.Query

  alias Noizu.MCP.Server.Features.Pagination
  alias NoizuPromptLingua.Domains.Memory
  alias NoizuPromptLingua.Domains.Memory.Agents
  alias NoizuPromptLingua.Domains.Memory.Sentinel
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.VFS.{Overview, Scope}
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Memory.Memory, as: MemorySchema
  alias NoizuPromptLingua.Schema.Memory.AgentCallSign

  @group "memory"
  @fetch_ceiling 500
  @page_size 100
  @query_node "_query"

  @buffer :vfs_memory_query_buffer

  # ── stat/2 ────────────────────────────────────────────────────────────────

  @impl true
  def stat(path, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group) do
      stat_rest(org, rest, gate, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp stat_rest(_org, [], gate, _ctx), do: {:ok, %{Scope.dir_node() | writable: gate.writable}}

  defp stat_rest(_org, ["overview.md"], _gate, _ctx),
    do: {:ok, Scope.file_node(byte_size(Overview.md(overview_tool(), @group)))}

  defp stat_rest(_org, ["agents"], gate, _ctx),
    do: {:ok, %{Scope.dir_node() | writable: gate.writable}}

  defp stat_rest(org, ["agents", filename], _gate, _ctx) do
    with {:ok, agent} <- resolve_registered(org, filename) do
      {:ok, Scope.file_node(byte_size(agent_doc(agent)))}
    end
  end

  defp stat_rest(org, [agent], gate, ctx) do
    with {:ok, _scope} <- resolve_agent(org, agent, ctx) do
      {:ok, %{Scope.dir_node() | writable: gate.writable}}
    end
  end

  defp stat_rest(org, [agent, @query_node], _gate, ctx) do
    with {:ok, _scope} <- resolve_agent(org, agent, ctx) do
      {:ok, %{Scope.file_node(0) | type: :control, writable: true}}
    end
  end

  defp stat_rest(org, [agent, "journal"], gate, ctx) do
    with {:ok, _scope} <- resolve_agent(org, agent, ctx) do
      {:ok, %{Scope.dir_node() | writable: gate.writable}}
    end
  end

  defp stat_rest(org, [agent, "journal", filename], _gate, ctx) do
    with {:ok, scope} <- resolve_agent(org, agent, ctx),
         {:ok, memory} <- fetch_memory(scope, filename) do
      {:ok, Scope.file_node(byte_size(memory_doc(memory)))}
    end
  end

  defp stat_rest(_org, _rest, _gate, _ctx), do: {:error, :enoent}

  # ── list/3 ────────────────────────────────────────────────────────────────

  @impl true
  def list(path, cursor, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, _gate} <- Scope.gate(ctx, org, @group) do
      list_rest(org, rest, cursor, ctx)
    end
  end

  defp list_rest(org, [], cursor, _ctx) do
    org_id = org_id!(org)

    agent_dirs =
      (Enum.map(Agents.list(org_id, status: "active"), & &1.call_sign) ++
         Enum.map(personas(org_id), & &1.slug))
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.map(&Scope.dir_entry/1)

    entries = [Scope.file_entry("overview.md"), Scope.dir_entry("agents") | agent_dirs]
    paginate(entries, cursor)
  end

  defp list_rest(_org, ["overview.md"], _cursor, _ctx), do: {:error, :enotdir}

  defp list_rest(org, ["agents"], cursor, _ctx) do
    entries =
      org
      |> org_id!()
      |> Agents.list(status: "active")
      |> Enum.map(&Scope.file_entry("#{&1.call_sign}.json"))

    paginate(entries, cursor)
  end

  defp list_rest(_org, ["agents", _filename], _cursor, _ctx), do: {:error, :enotdir}

  defp list_rest(org, [agent], cursor, ctx) do
    with {:ok, _scope} <- resolve_agent(org, agent, ctx) do
      paginate([Scope.file_entry(@query_node), Scope.dir_entry("journal")], cursor)
    end
  end

  defp list_rest(_org, [_agent, @query_node], _cursor, _ctx), do: {:error, :enotdir}

  defp list_rest(org, [agent, "journal"], cursor, ctx) do
    with {:ok, scope} <- resolve_agent(org, agent, ctx),
         {:ok, %{results: rows}} <- Memory.recent([limit: @fetch_ceiling], context(scope)) do
      entries = Enum.map(rows, &Scope.file_entry("#{&1.id}.json"))
      paginate(entries, cursor)
    end
  end

  defp list_rest(_org, [_agent, "journal", _filename], _cursor, _ctx), do: {:error, :enotdir}
  defp list_rest(_org, _rest, _cursor, _ctx), do: {:error, :enoent}

  # ── read/2 ────────────────────────────────────────────────────────────────

  @impl true
  def read(path, ctx) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, _gate} <- Scope.gate(ctx, org, @group) do
      read_rest(org, rest, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enoent}
    end
  end

  defp read_rest(_org, [], _ctx), do: {:error, :eisdir}

  defp read_rest(_org, ["overview.md"], _ctx) do
    {:ok, Overview.md(overview_tool(), @group), Scope.version()}
  end

  defp read_rest(_org, ["agents"], _ctx), do: {:error, :eisdir}

  defp read_rest(org, ["agents", filename], _ctx) do
    with {:ok, agent} <- resolve_registered(org, filename) do
      {:ok, agent_doc(agent), Scope.version()}
    end
  end

  defp read_rest(org, [agent], ctx) do
    with {:ok, _scope} <- resolve_agent(org, agent, ctx) do
      {:error, :eisdir}
    end
  end

  # Control/query node: the consumed results of the buffered request.
  defp read_rest(org, [agent, @query_node], ctx) do
    with {:ok, _scope} <- resolve_agent(org, agent, ctx),
         {:ok, result} <- buffer_take(query_key(org, agent, ctx)) do
      {:ok, Jason.encode!(result), Scope.version()}
    end
  end

  defp read_rest(org, [agent, "journal"], ctx) do
    with {:ok, _scope} <- resolve_agent(org, agent, ctx) do
      {:error, :eisdir}
    end
  end

  defp read_rest(org, [agent, "journal", filename], ctx) do
    with {:ok, scope} <- resolve_agent(org, agent, ctx) do
      if String.ends_with?(filename, ".links.json") do
        read_links(scope, filename)
      else
        with {:ok, memory} <- fetch_memory(scope, filename) do
          {:ok, memory_doc(memory), Scope.version()}
        end
      end
    end
  end

  defp read_rest(_org, _rest, _ctx), do: {:error, :enoent}

  # Memory.Associations: the scope-filtered association edges.
  defp read_links(scope, filename) do
    with {:ok, memory} <- fetch_memory(scope, filename) do
      edges = Memory.associations(memory.id, context(scope))

      doc =
        Enum.map(edges, fn e ->
          %{
            "source_memory_id" => e.source_memory_id,
            "target_memory_id" => e.target_memory_id,
            "type" => e.edge_type && to_string(e.edge_type),
            "weight" => e.weight,
            "reason" => Map.get(e, :reason)
          }
        end)
        |> Jason.encode!()

      {:ok, doc, Scope.version()}
    end
  end

  # ── create/3 — AgentRegister + Remember ───────────────────────────────────

  @impl true
  def create(path, data, ctx) when is_binary(data) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate) do
      create_rest(org, rest, data, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enosys}
    end
  end

  def create(_path, _data, _ctx), do: {:error, :enosys}

  # AgentRegister: agents/{call-sign}.json, kind from the JSON body.
  defp create_rest(org, ["agents", filename], data, _ctx) do
    with {:ok, call_sign} <- call_sign_name(filename),
         {kind, display_name} <- parse_agent_body(data),
         nil <- Agents.resolve(org_id!(org), call_sign) do
      case Agents.register(org_id!(org), kind, call_sign: call_sign, display_name: display_name) do
        {:ok, agent} ->
          {:ok,
           %{
             Scope.file_node(byte_size(data))
             | xattrs: %{"id" => agent.id, "call_sign" => agent.call_sign}
           }}

        {:error, _changeset} ->
          {:error, :eio}
      end
    else
      :error -> {:error, :eio}
      %AgentCallSign{} -> {:error, :eexist}
      {:error, _} = error -> error
      _ -> {:error, :eio}
    end
  end

  # Remember: journal/{name}.json — JSON body or plain-text content.
  defp create_rest(org, [agent, "journal", filename], data, ctx) do
    with {:ok, scope} <- resolve_agent(org, agent, ctx),
         true <- String.ends_with?(filename, ".json") || {:error, :enosys} do
      attrs = remember_attrs(data)

      case Memory.remember(attrs, context(scope)) do
        {:ok, %{id: _id, status: :quarantined}} ->
          {:ok, %{Scope.file_node(byte_size(data)) | xattrs: %{"status" => "quarantined"}}}

        {:ok, %{id: id, status: status}} ->
          {:ok,
           %{
             Scope.file_node(byte_size(data))
             | xattrs: %{"id" => id, "status" => to_string(status)}
           }}

        {:error, _} ->
          {:error, :eio}
      end
    end
  end

  defp create_rest(_org, _rest, _data, _ctx), do: {:error, :enosys}

  # ── write/3 — Reinforce / Denforce + _query requests ──────────────────────

  @impl true
  def write(path, data, ctx) when is_binary(data) do
    with {:ok, [_tobor, org, @group | rest]} <- Scope.split_segments(path),
         {:ok, gate} <- Scope.gate(ctx, org, @group),
         :ok <- Scope.require_writable(gate) do
      write_rest(org, rest, data, ctx)
    else
      {:error, _} = error -> error
      _fallback -> {:error, :enosys}
    end
  end

  def write(_path, _data, _ctx), do: {:error, :enosys}

  # Recall/RecallByEmotion request: buffer the ranked results for the next
  # read of this node (per session).
  defp write_rest(org, [agent, @query_node], data, ctx) do
    with {:ok, scope} <- resolve_agent(org, agent, ctx),
         {:ok, request} <- parse_query_request(data) do
      result = run_query(request, scope)
      buffer_put(query_key(org, agent, ctx), result)
      {:ok, %{Scope.file_node(0) | type: :control}}
    end
  end

  # Memory.Reinforce / Denforce: the weight-field write.
  defp write_rest(org, [agent, "journal", filename], data, ctx) do
    with {:ok, scope} <- resolve_agent(org, agent, ctx),
         {:ok, memory} <- fetch_memory(scope, filename),
         {:ok, action} <- parse_weight(data) do
      result =
        case action do
          :reinforce -> Memory.reinforce(memory.id, context(scope))
          :denforce -> Memory.denforce(memory.id, context(scope))
        end

      case result do
        {:ok, _} -> {:ok, Scope.file_node(byte_size(data))}
        {:error, _} -> {:error, :eio}
      end
    end
  end

  defp write_rest(_org, _rest, _data, _ctx), do: {:error, :enosys}

  # Archive/restore stay on the MCP surface; nothing on the file plane removes.
  @impl true
  def remove(_path, _ctx), do: {:error, :enosys}

  # ── _query buffering (write-request / read-result, §2.12) ────────────────

  # {"query": "…", "limit": n} → active recall; a mood vector ({"mood": {…}} or
  # flat {"valence": …}) → recall_by_emotion; bare text ⇒ query shorthand.
  defp parse_query_request(data) do
    trimmed = String.trim(data)

    if String.starts_with?(trimmed, "{") do
      case Jason.decode(trimmed) do
        {:ok, %{"query" => query} = req} when is_binary(query) ->
          {:ok, {:recall, query, limit(req)}}

        {:ok, %{"mood" => mood} = req} when is_map(mood) ->
          {:ok, {:by_emotion, mood, limit(req)}}

        {:ok, %{"valence" => _} = flat} when is_map(flat) ->
          {:ok, {:by_emotion, Map.take(flat, ["valence", "arousal", "dominance"]), limit(flat)}}

        {:ok, _} ->
          {:error, :eio}

        _ ->
          {:error, :eio}
      end
    else
      if trimmed == "", do: {:error, :eio}, else: {:ok, {:recall, trimmed, nil}}
    end
  end

  defp limit(req) when is_map(req) do
    case req["limit"] do
      n when is_integer(n) and n > 0 -> n
      _ -> nil
    end
  end

  defp run_query({:recall, query, limit}, scope) do
    case Memory.recall(query, limit_opts(limit), context(scope)) do
      {:ok, %{mode: mode, results: rows}} ->
        %{mode: to_string(mode), results: Enum.map(rows, &memory_view/1), at: Scope.now_ms()}

      _ ->
        %{mode: "recall", results: [], at: Scope.now_ms()}
    end
  end

  defp run_query({:by_emotion, mood, limit}, scope) do
    state = normalize_mood(mood)

    case Memory.recall_by_emotion(state, limit_opts(limit), context(scope)) do
      {:ok, %{mode: mode, results: rows}} ->
        %{mode: to_string(mode), results: Enum.map(rows, &memory_view/1), at: Scope.now_ms()}

      _ ->
        %{mode: "by_emotion", results: [], at: Scope.now_ms()}
    end
  end

  defp limit_opts(nil), do: []
  defp limit_opts(n), do: [limit: n]

  defp normalize_mood(mood) when is_map(mood),
    do: %{"mood" => Map.new(mood, fn {k, v} -> {k, if(is_number(v), do: v * 1.0, else: v)} end)}

  defp buffer_put(key, value) do
    ensure_buffer()
    :ets.insert(@buffer, {key, value})
    :ok
  end

  # One-shot consume: the next read takes the results, later reads :enoent —
  # the write-request/read-result contract ("read-only after write-consume").
  defp buffer_take(key) do
    ensure_buffer()

    case :ets.take(@buffer, key) do
      [{^key, value}] -> {:ok, value}
      _ -> {:error, :enoent}
    end
  end

  defp ensure_buffer do
    if :ets.whereis(@buffer) == :undefined do
      # Named + public: the buffer outlives individual request processes and
      # mirrors the lib Control tree's per-connection result buffering.
      try do
        :ets.new(@buffer, [:named_table, :public, :set, read_concurrency: true])
      rescue
        ArgumentError -> :ok
      end
    end

    :ok
  end

  defp query_key(org, agent, ctx), do: {"memory_query", org, agent, session_key(ctx)}

  defp session_key(%Noizu.MCP.Ctx{session_id: id}) when is_binary(id), do: {:sid, id}
  defp session_key(%Noizu.MCP.Ctx{session: pid}) when is_pid(pid), do: {:pid, pid}
  defp session_key(_), do: :default

  # ── resolution ────────────────────────────────────────────────────────────

  defp overview_tool, do: NoizuPromptLingua.Domains.Memory.Tools.Overview

  defp org_id(org) do
    case Resolve.organization_id(org) do
      nil -> {:error, :enoent}
      id -> {:ok, id}
    end
  end

  defp org_id!(org) do
    {:ok, id} = org_id(org)
    id
  end

  defp resolve_registered(org, filename) do
    with {:ok, call_sign} <- call_sign_name(filename),
         %AgentCallSign{} = agent <- Agents.resolve(org_id!(org), call_sign) do
      {:ok, agent}
    else
      _ -> {:error, :enoent}
    end
  end

  defp call_sign_name(filename) do
    case String.split(filename, ".json") do
      [call_sign, ""] when byte_size(call_sign) > 0 -> {:ok, call_sign}
      _ -> {:error, :enoent}
    end
  end

  defp resolve_agent(org, agent, _ctx) do
    case Agents.resolve_agent(org_id!(org), agent) do
      {:ok, scope} -> {:ok, scope}
      _ -> {:error, :enoent}
    end
  end

  defp personas(org_id),
    do:
      NoizuPromptLingua.Domains.Personas.list(
        organization_id: org_id,
        status: "active",
        limit: @fetch_ceiling
      )

  # Scope-filtered, id-addressed memory lookup (journal/{id}.json and links).
  defp fetch_memory(scope, filename) do
    base = String.replace_suffix(filename, ".links.json", "")
    base = String.replace_suffix(base, ".json", "")

    case NoizuPromptLingua.UUID.cast(base) do
      {:ok, id} ->
        from(m in MemorySchema, where: m.id == ^id)
        |> Sentinel.scope_filter(scope)
        |> Repo.one()
        |> case do
          nil -> {:error, :enoent}
          memory -> {:ok, memory}
        end

      :error ->
        {:error, :enoent}
    end
  end

  defp context(scope),
    do: Map.merge(scope, %{requester_id: to_string(scope.scope_id), source_agent: "vfs"})

  # ── payload helpers ───────────────────────────────────────────────────────

  # {"kind": "weego"|"team_member", "display_name": …}; plain text or a JSON
  # object without a kind ⇒ team_member; an explicit unknown kind is refused.
  defp parse_agent_body(data) do
    case Jason.decode(String.trim(data)) do
      {:ok, %{"kind" => kind} = body} when kind in ["weego", "team_member"] ->
        {String.to_existing_atom(kind), body["display_name"]}

      {:ok, %{"kind" => _}} ->
        :error

      {:ok, body} when is_map(body) ->
        {:team_member, body["display_name"]}

      _ ->
        {:team_member, nil}
    end
  end

  defp remember_attrs(data) do
    case Jason.decode(String.trim(data)) do
      {:ok, body} when is_map(body) ->
        %{
          content: body["content"] || "",
          context: body["context"],
          reflection: body["reflection"],
          tangent: body["tangent"],
          summary: body["summary"],
          content_type: body["content_type"] || "episodic",
          domain: body["domain"],
          topic: body["topic"],
          collaborators: body["collaborators"],
          compartment: body["compartment"] || "default",
          classification: body["classification"] || "open",
          mood: mood(body["mood"])
        }

      _ ->
        %{content: String.trim_trailing(data), content_type: "episodic"}
    end
  end

  defp mood(mood) when is_map(mood) do
    [:valence, :arousal, :dominance]
    |> Enum.reduce(%{}, fn k, acc ->
      case mood[to_string(k)] do
        v when is_number(v) -> Map.put(acc, k, v * 1.0)
        _ -> acc
      end
    end)
    |> case do
      m when m == %{} -> nil
      m -> m
    end
  end

  defp mood(_), do: nil

  # `reinforce` / `denforce` — bare word or {"reinforce": true}.
  defp parse_weight(data) do
    trimmed = String.trim(data)

    cond do
      trimmed in ["reinforce", "denforce"] ->
        {:ok, String.to_existing_atom(trimmed)}

      String.starts_with?(trimmed, "{") ->
        case Jason.decode(trimmed) do
          {:ok, %{"reinforce" => true}} -> {:ok, :reinforce}
          {:ok, %{"denforce" => true}} -> {:ok, :denforce}
          _ -> {:error, :eio}
        end

      true ->
        {:error, :eio}
    end
  end

  defp agent_doc(agent) do
    %{
      "id" => agent.id,
      "call_sign" => agent.call_sign,
      "kind" => to_string(agent.kind),
      "display_name" => agent.display_name,
      "status" => agent.status,
      "persona_id" => agent.persona_id,
      "organization_id" => agent.organization_id,
      "created_at" => iso(agent.inserted_at)
    }
    |> Jason.encode!()
  end

  defp memory_doc(m) do
    %{
      "id" => m.id,
      "content" => m.content,
      "context" => m.context,
      "reflection" => m.reflection,
      "tangent" => m.tangent,
      "summary" => m.summary,
      "domain" => m.domain,
      "topic" => m.topic,
      "content_type" => m.content_type && to_string(m.content_type),
      "state" => m.state && to_string(m.state),
      "classification" => m.classification && to_string(m.classification),
      "occurred_at" => iso(m.occurred_at),
      "mood" => %{
        "valence" => m.valence,
        "arousal" => m.arousal,
        "dominance" => m.dominance
      },
      "salience" => m.salience,
      "decay_weight" => m.decay_weight,
      "recall_count" => m.recall_count,
      "created_at" => iso(m.inserted_at)
    }
    |> Jason.encode!()
  end

  # Recall results: ranked memories (score/resonance included when present).
  defp memory_view(m) do
    %{
      "id" => m.id,
      "content" => m.content,
      "summary" => m.summary,
      "domain" => m.domain,
      "topic" => m.topic,
      "occurred_at" => iso(m.occurred_at),
      "mood" => %{
        "valence" => m.valence,
        "arousal" => m.arousal,
        "dominance" => m.dominance
      },
      "score" => Map.get(m, :score),
      "resonance" => Map.get(m, :resonance)
    }
  end

  defp paginate(items, cursor) do
    cursor = if cursor == "", do: nil, else: cursor

    case Pagination.paginate(items, cursor, @page_size) do
      {:ok, page, next} -> {:ok, page, next}
      {:error, _} -> {:error, Noizu.MCP.Error.invalid_params("invalid cursor")}
    end
  end

  defp iso(nil), do: nil
  defp iso(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp iso(dt), do: to_string(dt)
end
