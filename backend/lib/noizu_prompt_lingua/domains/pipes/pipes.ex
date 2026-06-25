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

  @doc """
  Upsert a pipe entry. `attrs` requires `:organization_id`, `:sender_handle`,
  `:message_name`, `:body`; `:target_agent_handle` and `:target_group` are
  optional (blank = broadcast).
  """
  def push(attrs) do
    attrs =
      attrs
      |> Map.put_new(:target_agent_handle, "")
      |> Map.put_new(:target_group, "")

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
  end

  @doc """
  Pull entries addressed to `agent_handle` within `organization_id`.

  Options:
    * `:cursor` — integer; only entries with `seq > cursor`. Default 0 (all).
    * `:groups` — list of group names the agent belongs to (matches target_group).
    * `:since` — `DateTime`; only entries updated at or after this time (legacy filter).
    * `:message_names` — list of message names to keep.
    * `:include_broadcast` — default true; include entries with no target.

  Entries are returned in `seq ASC` order so the caller can take the last
  `seq` as its next cursor.
  """
  def pull(organization_id, agent_handle, opts \\ []) do
    groups = opts[:groups] || []
    include_broadcast = Keyword.get(opts, :include_broadcast, true)
    cursor = opts[:cursor] || 0

    query =
      from(e in AgentPipeEntry,
        where: e.organization_id == ^organization_id and e.seq > ^cursor,
        order_by: [asc: e.seq]
      )

    query =
      query
      |> filter_addressed(agent_handle, groups, include_broadcast)
      |> maybe_since(opts[:since])
      |> maybe_messages(opts[:message_names])

    Repo.all(query)
  end

  defp filter_addressed(query, agent_handle, groups, include_broadcast) do
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
