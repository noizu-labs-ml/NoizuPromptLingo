defmodule NoizuPromptLingua.Domains.Pipes do
  @moduledoc """
  Agent-to-agent message bus (ports the deprecated pipes feature).

  An agent publishes a payload under a `message_name` to a target — a specific
  agent handle, a named group, or a broadcast (both blank) — via `push/1`. The
  latest payload for a (sender, message_name, target) tuple is retained (upsert).
  An agent pulls everything addressed to it via `pull/2`, optionally filtered by
  time and message name. All entries are scoped to an organization.
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
      on_conflict: {:replace, [:body, :updated_at]},
      conflict_target: [
        :organization_id,
        :sender_handle,
        :message_name,
        :target_agent_handle,
        :target_group
      ]
    )
  end

  @doc """
  Pull entries addressed to `agent_handle` within `organization_id`.

  Options:
    * `:groups` — list of group names the agent belongs to (matches target_group).
    * `:since` — `DateTime`; only entries updated at or after this time.
    * `:message_names` — list of message names to keep.
    * `:include_broadcast` — default true; include entries with no target.
  """
  def pull(organization_id, agent_handle, opts \\ []) do
    groups = opts[:groups] || []
    include_broadcast = Keyword.get(opts, :include_broadcast, true)

    query =
      from(e in AgentPipeEntry,
        where: e.organization_id == ^organization_id,
        order_by: [desc: e.updated_at]
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
