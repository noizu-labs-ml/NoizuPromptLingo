defmodule NoizuPromptLingua.Domains.PubSub do
  @moduledoc """
  Named, org-scoped pubsub channels that agents publish to and follow.

  Distinct from the notifications inbox: this domain owns the durable channel
  message log. A followed channel surfaces an AVAILABILITY POINTER in each
  follower's notification inbox (kind `pubsub_available`, coalesced per channel
  via `dedup_key`) that remains until the messages are viewed/acked. The
  channel message log itself is fetched on demand via `fetch_channel/2` /
  `fetch_all/2`.

  Publishing appends a message (drawing a fresh `seq` from the dedicated
  sequence), emits/refreshes the availability pointer to every follower via
  `Notifications.notify/1`, and broadcasts a wake on the Phoenix.PubSub topic
  `pubsub:<channel_id>`. Acknowledging advances the follower's `last_acked_seq`
  and, when caught up, clears the availability pointer.
  """

  import Ecto.Query

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.PubSubChannel
  alias NoizuPromptLingua.Schema.PubSubMessage
  alias NoizuPromptLingua.Schema.PubSubFollow
  alias NoizuPromptLingua.Domains.Notifications

  # ── Channels ──────────────────────────────────────────────────────────────

  @doc """
  Create a channel. `attrs` requires `:organization_id`, `:slug`, `:name`;
  `:project_id` and `:settings` are optional.
  """
  def create_channel(attrs) do
    %PubSubChannel{}
    |> PubSubChannel.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Fetch a channel within an org by slug or UUID. Returns the record or nil."
  def get_channel(organization_id, ref) do
    case NoizuPromptLingua.UUID.cast(ref) do
      {:ok, uuid} ->
        Repo.get_by(PubSubChannel, id: uuid, organization_id: organization_id) ||
          Repo.get_by(PubSubChannel, slug: ref, organization_id: organization_id)

      :error ->
        Repo.get_by(PubSubChannel, slug: ref, organization_id: organization_id)
    end
  end

  @doc "List all channels for an organization (newest first)."
  def list_channels(organization_id) do
    from(c in PubSubChannel,
      where: c.organization_id == ^organization_id,
      order_by: [desc: c.inserted_at]
    )
    |> Repo.all()
  end

  # ── Publish ───────────────────────────────────────────────────────────────

  @doc """
  Append a message to a channel and resurface the availability pointer to every
  follower.

  `attrs` requires `:channel_id` (UUID), `:sender`, `:body`. Returns
  `{:ok, message}` (with the freshly assigned `seq`) or `{:error, changeset}`.
  """
  def publish(attrs) do
    attrs = normalize_keys(attrs)

    with {:ok, message} <-
           %PubSubMessage{}
           |> PubSubMessage.changeset(attrs)
           |> Repo.insert() do
      channel = Repo.get(PubSubChannel, message.channel_id)
      notify_followers(channel, message)
      broadcast_wake(message)
      {:ok, message}
    end
  end

  defp notify_followers(nil, _message), do: :ok

  defp notify_followers(%PubSubChannel{} = channel, %PubSubMessage{} = message) do
    for follow <- followers(channel.id) do
      unread = unread_count(channel.id, follow.last_acked_seq)

      Notifications.notify(%{
        organization_id: channel.organization_id,
        recipient: follow.persona,
        kind: "pubsub_available",
        subject_type: "pubsub_channel",
        subject_id: channel.id,
        dedup_key: dedup_key(channel.id),
        body: "New messages on ##{channel.slug}",
        payload: %{channel: channel.slug, unread: unread, seq: message.seq}
      })
    end

    :ok
  end

  defp broadcast_wake(%PubSubMessage{} = message) do
    Phoenix.PubSub.broadcast(
      NoizuPromptLingua.PubSub,
      "pubsub:#{message.channel_id}",
      {:pubsub_message, message}
    )
  end

  # ── Follow / Unfollow ─────────────────────────────────────────────────────

  @doc "Follow a channel as `persona` (idempotent upsert)."
  def follow(channel_id, persona) do
    %PubSubFollow{}
    |> PubSubFollow.changeset(%{channel_id: channel_id, persona: persona})
    |> Repo.insert(
      on_conflict: {:replace, [:updated_at]},
      conflict_target: [:channel_id, :persona]
    )
  end

  @doc "Stop following a channel. Returns `{:ok, count}`."
  def unfollow(channel_id, persona) do
    {count, _} =
      from(f in PubSubFollow,
        where: f.channel_id == ^channel_id and f.persona == ^persona
      )
      |> Repo.delete_all()

    {:ok, count}
  end

  # ── Ack / View ────────────────────────────────────────────────────────────

  @doc """
  Advance the follower's `last_acked_seq` to the channel head. When the follower
  is caught up, clear the `pubsub_available` availability pointer from their
  notification inbox.

  Returns `{:ok, %{last_acked_seq: seq}}` or `{:error, :not_following}`.
  """
  def ack(organization_id, channel_id, persona) do
    case Repo.get_by(PubSubFollow, channel_id: channel_id, persona: persona) do
      nil ->
        {:error, :not_following}

      %PubSubFollow{} = follow ->
        head = head_seq(channel_id)

        {:ok, updated} =
          follow
          |> PubSubFollow.changeset(%{last_acked_seq: head})
          |> Repo.update()

        clear_availability(organization_id, channel_id, persona)
        {:ok, %{last_acked_seq: updated.last_acked_seq}}
    end
  end

  @doc """
  Advance the follower's `last_viewed_seq` to the channel head.

  Returns `{:ok, %{last_viewed_seq: seq}}` or `{:error, :not_following}`.
  """
  def view(channel_id, persona) do
    case Repo.get_by(PubSubFollow, channel_id: channel_id, persona: persona) do
      nil ->
        {:error, :not_following}

      %PubSubFollow{} = follow ->
        head = head_seq(channel_id)

        {:ok, updated} =
          follow
          |> PubSubFollow.changeset(%{last_viewed_seq: head})
          |> Repo.update()

        {:ok, %{last_viewed_seq: updated.last_viewed_seq}}
    end
  end

  # ── Fetch ─────────────────────────────────────────────────────────────────

  @doc """
  Fetch messages for a channel in `seq` ASC order.

  Options:
    * `:limit` — max rows (default 50).
    * `:since` — only messages with `seq` greater than this cursor.
  """
  def fetch_channel(channel_id, opts \\ []) do
    limit = opts[:limit] || 50
    since = opts[:since]

    query =
      from(m in PubSubMessage,
        where: m.channel_id == ^channel_id,
        order_by: [asc: m.seq],
        limit: ^limit
      )

    query = if since, do: where(query, [m], m.seq > ^since), else: query
    Repo.all(query)
  end

  @doc """
  Fetch the most recent messages across all channels `persona` follows, newest
  first.

  Options:
    * `:limit` — max rows (default 50).
  """
  def fetch_all(persona, opts \\ []) do
    limit = opts[:limit] || 50

    from(m in PubSubMessage,
      join: f in PubSubFollow,
      on: f.channel_id == m.channel_id,
      where: f.persona == ^persona,
      order_by: [desc: m.seq],
      limit: ^limit
    )
    |> Repo.all()
  end

  # ── Internals ─────────────────────────────────────────────────────────────

  defp dedup_key(channel_id), do: "pubsub:#{channel_id}"

  defp followers(channel_id) do
    from(f in PubSubFollow, where: f.channel_id == ^channel_id)
    |> Repo.all()
  end

  defp head_seq(channel_id) do
    from(m in PubSubMessage,
      where: m.channel_id == ^channel_id,
      select: max(m.seq)
    )
    |> Repo.one() || 0
  end

  defp unread_count(channel_id, last_acked_seq) do
    from(m in PubSubMessage,
      where: m.channel_id == ^channel_id and m.seq > ^last_acked_seq,
      select: count(m.id)
    )
    |> Repo.one() || 0
  end

  # Clear the availability pointer from the follower's notification inbox.
  # Coordinates with Stream A's Notifications domain: resolves the coalesced
  # `pubsub_available` row(s) for this (org, recipient, dedup_key) and acks
  # them via `Notifications.ack/3`. Resilient — if Stream A does not (yet)
  # expose a dedup lookup, advancing the cursor still succeeds.
  defp clear_availability(organization_id, channel_id, persona) do
    key = dedup_key(channel_id)

    cond do
      function_exported?(Notifications, :ids_for_dedup, 3) ->
        ids = Notifications.ids_for_dedup(organization_id, persona, key)
        if ids != [], do: Notifications.ack(organization_id, persona, ids)
        :ok

      function_exported?(Notifications, :ack_dedup, 3) ->
        Notifications.ack_dedup(organization_id, persona, key)
        :ok

      true ->
        :ok
    end
  end

  defp normalize_keys(attrs) do
    Map.new(attrs, fn
      {k, v} when is_binary(k) -> {String.to_existing_atom(k), v}
      {k, v} -> {k, v}
    end)
  rescue
    ArgumentError -> attrs
  end
end
