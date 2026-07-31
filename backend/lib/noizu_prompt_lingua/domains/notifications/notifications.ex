defmodule NoizuPromptLingua.Domains.Notifications do
  @moduledoc """
  Per-recipient notification inbox — the Notify/Notifications system that
  replaces the agent pipe bus.

  `notify/1` resolves a target (one or more handles and/or groups) to a concrete
  set of recipients and inserts one row per recipient, so read/seen/ack state is
  genuinely per-recipient. A `:dedup_key` collapses repeating items (a chat
  digest, a pubsub availability pointer) into one still-unread row that resurfaces
  with a fresh `seq` instead of piling up.

  `get/3` is a cursor pull (lifted from the pipe bus): rows with `seq > cursor`,
  due (`deliver_after` null or past), not acked, ordered `seq ASC`. `poll/3` is
  the Monitor/long-poll variant — it blocks until a matching row is published or
  `:wait_ms` elapses. Both apply a hardcoded per-recipient delivery rate-limit
  (one non-empty batch per `@rate_limit_ms`); while throttled, inbound items are
  simply queued (the Monitor re-blocks) until the window elapses.

  All rows are organization-scoped. A publish broadcasts `{:notification, seq}`
  on `notifications:<org>` so a waiting `poll/3` wakes immediately.
  """

  import Ecto.Query
  require Logger
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Notification

  @pubsub NoizuPromptLingua.PubSub
  # Hold ceiling for a long-poll, staying under the Streamable-HTTP transport's
  # 300 s request_timeout (mirrors the pipe bus).
  @max_wait_ms 290_000
  # Backstop re-poll cadence: re-check the DB at least this often even if a
  # PubSub wake is missed; also how a newly-due `deliver_after` row or an expired
  # rate-limit window gets surfaced within a held poll.
  @backstop_ms 5_000
  # Get rate-limit, expressed as a (count, span) window: at most @rate_limit_count
  # non-empty deliveries per recipient per @rate_limit_span_ms. Hardcoded to 1 per
  # 5 min for now; this is the same (count, span) shape the future websocket push
  # will accept to queue events exceeding `count` within `now - span` (see plan
  # tnote). count=1 collapses to the single-key PTTL check below; raising count
  # later means swapping that for a windowed counter.
  @rate_limit_count 1
  @rate_limit_span_ms 300_000
  @rate_limit_ms @rate_limit_span_ms

  # ── Publish ───────────────────────────────────────────────────

  @doc """
  Create notification(s). `attrs` is a map describing one logical notification;
  it is fanned out to every resolved recipient.

  Recipient resolution draws from, in union:
    * `:recipient` (a single handle) and/or `:recipients` (a list of handles)
    * `:group` (a single group name) and/or `:groups` (a list) — each resolved to
      its member handles via `resolve_group/3`

  Required: `:organization_id`, `:kind`, and at least one resolved recipient.
  Optional: `:project_id`, `:sender`, `:subject_type`, `:subject_id`, `:body`,
  `:payload`, `:deliver_after`, `:dedup_key`.

  When `:dedup_key` is set the insert upserts against the partial unique index
  (one still-unread row per recipient+dedup_key), bumping `seq` and incrementing
  `payload.count` so the item resurfaces rather than duplicating.

  Returns `{:ok, [%Notification{}]}` (the inserted/updated rows) or
  `{:error, reason}` if no recipient resolved.
  """
  def notify(attrs) do
    org_id = attrs[:organization_id]
    recipients = resolve_recipients(attrs)

    cond do
      is_nil(org_id) -> {:error, :organization_required}
      recipients == [] -> {:error, :no_recipients}
      true -> {:ok, Enum.flat_map(recipients, &insert_for(attrs, &1, org_id))}
    end
  end

  defp insert_for(attrs, recipient, org_id) do
    base =
      attrs
      |> Map.take([
        :project_id,
        :sender,
        :kind,
        :subject_type,
        :subject_id,
        :body,
        :payload,
        :deliver_after,
        :dedup_key
      ])
      |> Map.put(:organization_id, org_id)
      |> Map.put(:recipient, recipient)

    case do_insert(base) do
      {:ok, row} ->
        Phoenix.PubSub.broadcast(@pubsub, topic(org_id), {:notification, row.seq})
        [row]

      {:error, changeset} ->
        Logger.error("notify insert for #{recipient} failed: #{inspect(changeset.errors)}")
        []
    end
  end

  defp do_insert(%{dedup_key: key} = attrs) when is_binary(key) and key != "" do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert(
      # Coalesce onto the still-unread row for this (org, recipient, dedup_key):
      # replace the surface fields, KEEP the original deliver_after (so a digest
      # fires a fixed window after the FIRST item, not pushed forward), bump seq
      # so it resurfaces past the reader's cursor, and increment payload.count.
      on_conflict:
        from(n in Notification,
          update: [
            set: [
              body: fragment("EXCLUDED.body"),
              sender: fragment("EXCLUDED.sender"),
              subject_type: fragment("EXCLUDED.subject_type"),
              subject_id: fragment("EXCLUDED.subject_id"),
              updated_at: fragment("now()"),
              seq: fragment("nextval('npl_notifications_seq')"),
              payload:
                fragment(
                  "jsonb_set(COALESCE(?, '{}'::jsonb), '{count}', to_jsonb(COALESCE((?->>'count')::int, 1) + 1))",
                  n.payload,
                  n.payload
                )
            ]
          ]
        ),
      conflict_target:
        {:unsafe_fragment,
         ~s|("organization_id", "recipient", "dedup_key") WHERE read = false AND dedup_key IS NOT NULL|},
      returning: true
    )
  end

  defp do_insert(attrs) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert(returning: true)
  end

  # ── Recipient resolution ──────────────────────────────────────

  defp resolve_recipients(attrs) do
    org_id = attrs[:organization_id]
    project_id = attrs[:project_id]

    explicit = List.wrap(attrs[:recipient]) ++ List.wrap(attrs[:recipients])

    grouped =
      (List.wrap(attrs[:group]) ++ List.wrap(attrs[:groups]))
      |> Enum.flat_map(&resolve_group(org_id, project_id, &1))

    (explicit ++ grouped)
    |> Enum.map(&to_string/1)
    |> Enum.reject(&(&1 in [nil, ""]))
    |> Enum.uniq()
  end

  @doc """
  Resolve a group name to member handles. A group is a chat room (by slug) within
  the org — project-scoped first, then the org-level (NULL-project) bucket; the
  room's members are the recipients. Best-effort: unknown group → `[]`.
  """
  def resolve_group(org_id, project_id, group) when is_binary(group) and group != "" do
    chat = NoizuPromptLingua.Domains.Chat

    room =
      (project_id && chat.get_room_by_slug(org_id, project_id, group)) ||
        chat.get_room_by_slug(org_id, nil, group)

    case room do
      %{id: room_id} -> room_id |> chat.list_members() |> Enum.map(& &1.persona)
      _ -> []
    end
  rescue
    _ -> []
  end

  def resolve_group(_org_id, _project_id, _group), do: []

  # ── Read (cursor pull + Monitor) ──────────────────────────────

  @doc """
  Cursor pull for a recipient. Opts:
    * `:cursor` — only rows with `seq > cursor` (default 0).
    * `:max` — page size (default 50).
    * `:kinds` — keep only these kinds.
    * `:include_future` — include not-yet-due rows (default false).
    * `:auto_read` — mark returned rows read (default false).

  Applies the per-recipient delivery rate-limit: if a non-empty batch was
  delivered within the last window, returns `{:throttled, retry_after_ms}` with
  no rows. On a non-empty delivery, stamps the window.
  """
  def get(org_id, recipient, opts \\ []) do
    deliver(org_id, recipient, opts)
  end

  @doc """
  Monitor variant of `get/3`: if nothing is deliverable now, block until a row is
  published (woken by `notify/1`) or `:wait_ms` elapses, then return. Honors the
  same rate-limit — a throttled poll simply holds until the window elapses (or
  `:wait_ms`), naturally queuing inbound items.
  """
  def poll(org_id, recipient, opts \\ []) do
    wait_ms = clamp_wait_ms(opts[:wait_ms])

    if wait_ms <= 0 do
      deliver(org_id, recipient, opts)
    else
      Phoenix.PubSub.subscribe(@pubsub, topic(org_id))

      try do
        case deliver(org_id, recipient, opts) do
          {:ok, []} ->
            deadline = System.monotonic_time(:millisecond) + wait_ms
            wait_loop(org_id, recipient, opts, deadline)

          # Throttled or has rows → return immediately; the Monitor re-polls.
          other ->
            other
        end
      after
        Phoenix.PubSub.unsubscribe(@pubsub, topic(org_id))
      end
    end
  end

  defp wait_loop(org_id, recipient, opts, deadline) do
    remaining = deadline - System.monotonic_time(:millisecond)

    if remaining <= 0 do
      deliver(org_id, recipient, opts)
    else
      receive do
        {:notification, _seq} -> :woke
      after
        min(remaining, @backstop_ms) -> :timeout
      end

      case deliver(org_id, recipient, opts) do
        {:ok, []} -> wait_loop(org_id, recipient, opts, deadline)
        other -> other
      end
    end
  end

  # Rate-limited delivery shared by get/poll. Returns {:ok, rows} | {:throttled, ms}.
  defp deliver(org_id, recipient, opts) do
    # An agent calling get/poll is "online" — refresh its presence (best-effort).
    touch_presence(org_id, recipient)

    case rate_limit_remaining(org_id, recipient) do
      ms when ms > 0 ->
        {:throttled, ms}

      _ ->
        rows = pull_rows(org_id, recipient, opts)

        if rows != [] do
          stamp_delivery(org_id, recipient)
          if opts[:auto_read], do: mark_read(org_id, recipient, Enum.map(rows, & &1.id))
        end

        {:ok, rows}
    end
  end

  defp pull_rows(org_id, recipient, opts) do
    cursor = opts[:cursor] || 0
    max = opts[:max] || 50

    query =
      from(n in Notification,
        where:
          n.organization_id == ^org_id and n.recipient == ^recipient and
            n.seq > ^cursor and n.acked == false,
        order_by: [asc: n.seq],
        limit: ^max
      )

    query
    |> maybe_due(opts[:include_future])
    |> maybe_kinds(opts[:kinds])
    |> Repo.all()
  end

  defp maybe_due(query, true), do: query

  defp maybe_due(query, _) do
    now = DateTime.utc_now()
    where(query, [n], is_nil(n.deliver_after) or n.deliver_after <= ^now)
  end

  defp maybe_kinds(query, nil), do: query
  defp maybe_kinds(query, []), do: query
  defp maybe_kinds(query, kinds), do: where(query, [n], n.kind in ^kinds)

  # ── Lifecycle (read / seen / ack / clear) ─────────────────────

  @doc "Mark rows read for a recipient. `ids` is a list of ids, or `:all`."
  def mark_read(org_id, recipient, ids \\ :all),
    do: set_flags(org_id, recipient, ids, read: true, read_at: now())

  @doc "Mark rows seen for a recipient. `ids` is a list of ids, or `:all`."
  def mark_seen(org_id, recipient, ids \\ :all),
    do: set_flags(org_id, recipient, ids, seen: true, seen_at: now())

  @doc "Ack (dismiss) rows for a recipient — removes them from future deliveries."
  def ack(org_id, recipient, ids \\ :all),
    do: set_flags(org_id, recipient, ids, acked: true, acked_at: now())

  @doc "Clear (mark read) rows for a recipient. `ids` is a list of ids, or `:all`."
  def clear(org_id, recipient, ids \\ :all), do: mark_read(org_id, recipient, ids)

  @doc """
  Ack every still-unread row matching a `dedup_key` for a recipient — used by the
  PubSub domain to clear an availability pointer once the follower is caught up
  (it doesn't hold the notification id). Returns `{:ok, count}`.
  """
  @doc "Notification ids of still-unread rows matching a dedup_key for a recipient."
  def ids_for_dedup(org_id, recipient, dedup_key) do
    from(n in Notification,
      where:
        n.organization_id == ^org_id and n.recipient == ^recipient and
          n.dedup_key == ^dedup_key and n.acked == false,
      select: n.id
    )
    |> Repo.all()
  end

  def ack_dedup(org_id, recipient, dedup_key) do
    {count, _} =
      from(n in Notification,
        where:
          n.organization_id == ^org_id and n.recipient == ^recipient and
            n.dedup_key == ^dedup_key and n.acked == false
      )
      |> Repo.update_all(set: [acked: true, acked_at: now()])

    {:ok, count}
  end

  @doc """
  Note a recipient as active (best-effort). Delegates to the Presence tracker,
  which is a no-op if it isn't running. Called from `deliver/3` so any get/poll
  refreshes the caller's presence.
  """
  def touch_presence(org_id, recipient) do
    NoizuPromptLingua.Domains.Notifications.Presence.touch(org_id, recipient)
  rescue
    _ -> :ok
  end

  defp set_flags(org_id, recipient, ids, sets) do
    base =
      from(n in Notification,
        where: n.organization_id == ^org_id and n.recipient == ^recipient
      )

    query = if ids == :all, do: base, else: where(base, [n], n.id in ^List.wrap(ids))
    {count, _} = Repo.update_all(query, set: sets)
    {:ok, count}
  end

  @doc "Count unread, due notifications for a recipient."
  def count(org_id, recipient) do
    now = DateTime.utc_now()

    Repo.aggregate(
      from(n in Notification,
        where:
          n.organization_id == ^org_id and n.recipient == ^recipient and
            n.read == false and n.acked == false and
            (is_nil(n.deliver_after) or n.deliver_after <= ^now)
      ),
      :count,
      :id
    )
  end

  @doc "Total notification rows for an organization (overview stat)."
  def stats(org_id) do
    %{
      notifications:
        Repo.aggregate(from(n in Notification, where: n.organization_id == ^org_id), :count, :id)
    }
  end

  # ── Rate-limit (Redis) ────────────────────────────────────────

  defp rate_limit_remaining(org_id, recipient) do
    case NoizuPromptLingua.Redis.command([
           "PTTL",
           NoizuPromptLingua.Redis.prefix(rl_key(org_id, recipient))
         ]) do
      {:ok, ms} when is_integer(ms) and ms > 0 -> ms
      _ -> 0
    end
  rescue
    _ -> 0
  end

  defp stamp_delivery(org_id, recipient) do
    NoizuPromptLingua.Redis.set(rl_key(org_id, recipient), "1", px: @rate_limit_ms)
  rescue
    _ -> :ok
  end

  defp rl_key(org_id, recipient), do: "notif_rl:#{org_id}:#{recipient}"

  # ── Helpers ───────────────────────────────────────────────────

  defp topic(org_id), do: "notifications:" <> to_string(org_id)

  defp clamp_wait_ms(ms) when is_integer(ms) and ms > 0, do: min(ms, @max_wait_ms)
  defp clamp_wait_ms(_), do: 0

  defp now, do: DateTime.utc_now() |> DateTime.truncate(:second)

  @doc "Rate-limit window in ms (exposed for tooling/tests)."
  def rate_limit_ms, do: @rate_limit_ms

  @doc "Rate-limit as a {count, span_ms} window (exposed for tooling/tests)."
  def rate_limit, do: {@rate_limit_count, @rate_limit_span_ms}
end
