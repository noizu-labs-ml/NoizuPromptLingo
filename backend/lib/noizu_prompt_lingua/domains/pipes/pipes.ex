defmodule NoizuPromptLingua.Domains.Pipes do
  @moduledoc """
  Agent-to-agent message bus (ports the deprecated pipes feature).

  An agent publishes a payload under a `message_name` to a target — a specific
  agent handle, a named group, or a broadcast (both blank) — via `push/1`. The
  latest payload for a (sender, message_name, target) tuple is retained (upsert).
  An agent pulls everything addressed to it via `pull/3` using an opaque,
  monotonically-increasing `seq` cursor. All entries are scoped to an
  organization.
  """

  import Ecto.Query
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Pipes.AgentPipeEntry

  @pubsub NoizuPromptLingua.PubSub
  # Hard ceiling for a long-poll hold. The Streamable-HTTP transport severs a
  # request that has no handler response within `request_timeout` (300_000 ms),
  # so we stay safely under it and return our own clean empty result first.
  @max_wait_ms 290_000
  # Backstop re-poll cadence: even if a PubSub wake is missed (e.g. a publish
  # that raced the subscribe, or a cross-node delivery hiccup), a waiter re-checks
  # the DB at least this often, capping worst-case latency.
  @backstop_ms 5_000

  @doc """
  Upsert a pipe entry. `attrs` requires `:organization_id`, `:sender_handle`,
  `:message_name`, `:body`; `:target_agent_handle` and `:target_group` are
  optional (blank = broadcast).

  On a successful insert/upsert, broadcasts `{:pipe_entry, seq}` on the org's
  topic so any `pull_wait/3` long-poller for that org wakes immediately.
  """
  def push(attrs) do
    attrs =
      attrs
      |> Map.put_new(:target_agent_handle, "")
      |> Map.put_new(:target_group, "")

    result =
      %AgentPipeEntry{}
      |> AgentPipeEntry.changeset(attrs)
      |> Repo.insert(
        # On conflict, replace the payload AND draw a fresh seq so an updated
        # entry resurfaces past every reader's cursor (floats to the head of the
        # feed). Fresh inserts get seq from the column DEFAULT nextval(...).
        on_conflict:
          from(e in AgentPipeEntry,
            update: [
              set: [
                body: fragment("EXCLUDED.body"),
                updated_at: fragment("EXCLUDED.updated_at"),
                seq: fragment("nextval('npl_agent_pipe_entries_seq')")
              ]
            ]
          ),
        conflict_target: [
          :organization_id,
          :sender_handle,
          :message_name,
          :target_agent_handle,
          :target_group
        ],
        returning: [:seq]
      )

    with {:ok, %AgentPipeEntry{organization_id: org_id, seq: seq}} <- result do
      # Wake any long-poller for this org. Best-effort fan-out; waiters re-query
      # with their own (agent/groups/scope) filters, so a wake that isn't for
      # them simply re-blocks.
      Phoenix.PubSub.broadcast(@pubsub, topic(org_id), {:pipe_entry, seq})
    end

    result
  end

  @doc """
  Pull entries addressed to `agent_handle` within `organization_id`.

  Options:
    * `:cursor` — integer; only entries with `seq > cursor`. Default 0 (all).
    * `:groups` — list of group names the agent belongs to (matches target_group).
    * `:since` — `DateTime`; only entries updated at or after this time (legacy filter).
    * `:message_names` — list of message names to keep.
    * `:include_broadcast` — default true; include entries with no target.
    * `:scope` — `:all` (default) | `:direct` | `:group` | `:broadcast`. Restrict
      to a single addressing scope. `:all` keeps the legacy inclusive union
      (direct OR group OR broadcast, honoring `:groups`/`:include_broadcast`);
      `:direct` returns ONLY messages addressed to this agent handle, `:group`
      only group traffic (requires `:groups`), `:broadcast` only untargeted
      entries. Lets a caller isolate direct messages from group/broadcast noise.

  Entries are returned in `seq ASC` order so the caller can take the last
  `seq` as its next cursor.
  """
  def pull(organization_id, agent_handle, opts \\ []) do
    groups = opts[:groups] || []
    include_broadcast = Keyword.get(opts, :include_broadcast, true)
    cursor = opts[:cursor] || 0
    scope = normalize_scope(opts[:scope])

    query =
      from(e in AgentPipeEntry,
        where: e.organization_id == ^organization_id and e.seq > ^cursor,
        order_by: [asc: e.seq]
      )

    query =
      query
      |> filter_addressed(agent_handle, groups, include_broadcast, scope)
      |> maybe_since(opts[:since])
      |> maybe_messages(opts[:message_names])

    Repo.all(query)
  end

  @doc """
  Long-polling variant of `pull/3`: if nothing is newer than the cursor, block
  until a matching entry is published or `:wait_ms` elapses, then return.

  Same `opts` as `pull/3`, plus:
    * `:wait_ms` — max time to hold the request, in ms. `<= 0` (or absent) falls
      straight through to an immediate `pull/3`. Clamped to `#{@max_wait_ms}` ms
      so the hold returns before the Streamable-HTTP transport's `request_timeout`
      (300 s) would sever it.

  Mechanics: subscribes to the org's pipe topic FIRST (closing the
  publish-between-pull-and-subscribe race), does an immediate `pull`, and if that
  is empty waits — woken instantly by a `push/1` broadcast, with a `#{@backstop_ms}`-ms
  backstop re-poll as a safety net. No DB connection is held across the wait
  (each re-check is a fresh `pull`). Returns the same entry list shape as `pull/3`
  (possibly empty on timeout). Intended to run in the per-call Task the MCP
  transport spawns, so blocking here does not stall the session.
  """
  def pull_wait(organization_id, agent_handle, opts \\ []) do
    wait_ms = clamp_wait_ms(opts[:wait_ms])

    if wait_ms <= 0 do
      pull(organization_id, agent_handle, opts)
    else
      Phoenix.PubSub.subscribe(@pubsub, topic(organization_id))

      try do
        case pull(organization_id, agent_handle, opts) do
          [] ->
            deadline = System.monotonic_time(:millisecond) + wait_ms
            wait_loop(organization_id, agent_handle, opts, deadline)

          entries ->
            entries
        end
      after
        Phoenix.PubSub.unsubscribe(@pubsub, topic(organization_id))
      end
    end
  end

  defp wait_loop(organization_id, agent_handle, opts, deadline) do
    remaining = deadline - System.monotonic_time(:millisecond)

    if remaining <= 0 do
      pull(organization_id, agent_handle, opts)
    else
      # Wake on the next publish for this org, or fall through on the backstop
      # interval; either way re-check the DB with this caller's own filters.
      receive do
        {:pipe_entry, _seq} -> :woke
      after
        min(remaining, @backstop_ms) -> :timeout
      end

      case pull(organization_id, agent_handle, opts) do
        [] -> wait_loop(organization_id, agent_handle, opts, deadline)
        entries -> entries
      end
    end
  end

  defp clamp_wait_ms(ms) when is_integer(ms) and ms > 0, do: min(ms, @max_wait_ms)
  defp clamp_wait_ms(_), do: 0

  defp topic(organization_id), do: "agent_pipes:" <> to_string(organization_id)

  @doc """
  Classify an entry's addressing scope for callers/UI. A specific
  `target_agent_handle` wins over a `target_group` (a message can carry both);
  with neither it is a broadcast.
  """
  def scope_of(%AgentPipeEntry{target_agent_handle: a, target_group: g}), do: scope_of(a, g)
  def scope_of(%{target_agent_handle: a, target_group: g}), do: scope_of(a, g)
  defp scope_of(agent, _group) when agent not in [nil, ""], do: :direct
  defp scope_of(_agent, group) when group not in [nil, ""], do: :group
  defp scope_of(_agent, _group), do: :broadcast

  defp normalize_scope(nil), do: :all
  defp normalize_scope(s) when s in [:all, :direct, :group, :broadcast], do: s
  defp normalize_scope(s) when is_binary(s) do
    case String.downcase(s) do
      "direct" -> :direct
      "group" -> :group
      "broadcast" -> :broadcast
      _ -> :all
    end
  end

  defp normalize_scope(_), do: :all

  # :all — legacy inclusive union (direct OR group[if groups] OR broadcast[if requested]).
  defp filter_addressed(query, agent_handle, groups, include_broadcast, :all) do
    base =
      dynamic([e], e.target_agent_handle == ^agent_handle)

    base =
      if groups == [] do
        base
      else
        dynamic([e], ^base or (e.target_group != "" and e.target_group in ^groups))
      end

    base =
      if include_broadcast do
        dynamic([e], ^base or (e.target_agent_handle == "" and e.target_group == ""))
      else
        base
      end

    where(query, ^base)
  end

  # :direct — only messages addressed to this agent handle.
  defp filter_addressed(query, agent_handle, _groups, _include_broadcast, :direct),
    do: where(query, [e], e.target_agent_handle == ^agent_handle)

  # :group — only group traffic for the agent's groups. No groups → nothing.
  defp filter_addressed(query, _agent_handle, [], _include_broadcast, :group),
    do: where(query, [e], false)

  defp filter_addressed(query, _agent_handle, groups, _include_broadcast, :group),
    do: where(query, [e], e.target_group != "" and e.target_group in ^groups)

  # :broadcast — only untargeted entries.
  defp filter_addressed(query, _agent_handle, _groups, _include_broadcast, :broadcast),
    do: where(query, [e], e.target_agent_handle == "" and e.target_group == "")

  defp maybe_since(query, nil), do: query
  defp maybe_since(query, %DateTime{} = since), do: where(query, [e], e.updated_at >= ^since)

  defp maybe_messages(query, nil), do: query
  defp maybe_messages(query, []), do: query
  defp maybe_messages(query, names), do: where(query, [e], e.message_name in ^names)

  @doc "Count distinct senders + entries addressed to an agent, for overviews."
  def stats(organization_id) do
    total = Repo.aggregate(from(e in AgentPipeEntry, where: e.organization_id == ^organization_id), :count, :id)
    %{entries: total}
  end
end
