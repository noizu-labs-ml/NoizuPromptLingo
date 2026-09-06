defmodule NoizuPromptLingua.MCP.VFS.Tickets do
  @moduledoc """
  The `tickets` group's file plane (Wave 2) — MCP-VFS-GROUP-MOUNTS.md §2.8.

  Namespace, under `/tobor/{org}/tickets`:

      /tobor/{org}/tickets                     → readdir = TicketList (paged)
      /tobor/{org}/tickets/_all                → full cursor-paginated set (§3.2)
      /tobor/{org}/tickets/_new/record.json    → TicketCreate target (server assigns KEY)
      /tobor/{org}/tickets/{KEY}/record.json   → canonical ticket doc (TicketGet/Update)
      /tobor/{org}/tickets/{KEY}/fields/{slug}.json   → custom_fields projection
      /tobor/{org}/tickets/{KEY}/comments/…    → TicketComment (append-as-create)
      /tobor/{org}/tickets/{KEY}/attachments/… → TicketAttach (metadata per §3.3)
      /tobor/{org}/tickets/{KEY}/watchers.json → TicketWatch
      /tobor/{org}/tickets/{KEY}/links.json    → TicketLink/Unlink/LinkEntity/UnlinkEntity
      /tobor/{org}/tickets/{KEY}/feed.log/     → TicketFeed (readdir)
      /tobor/{org}/tickets/_queues/{slug}.json         → QueueCreate/Get
      /tobor/{org}/tickets/_queues/{slug}.feed.log/    → QueueFeed (readdir)
      /tobor/{org}/tickets/_types/{slug}.json  → DefinitionCreate/Get/Update/Delete
      /tobor/{org}/tickets/_fields/{slug}.json → FieldDefinitionCreate/Update/Delete

  ## Semantics

    * `record.json` is the only canonical write target (§3.4). A write merges
      the supplied top-level fields into the ticket (last-write-wins; absent
      fields untouched) — status transitions ride this as plain edits, and
      there is deliberately no server-side CAS (§0.1).
    * `fields/{slug}.json` is a writable projection of `custom_fields`: read
      renders the value, write merges the parsed JSON as the value.
    * Server-assigned identity: `TicketCreate` writes to `_new/record.json`
      (the KEY does not exist yet); comments and attachments accept any
      filesystem-safe file name but the **canonical** node name is assigned by
      the server (`{ts}-{short8}.json`) and returned in the created node's
      `xattrs["path"]` / `xattrs["name"]` — the same convention as the KEY.
    * Feeds are read-only projections synthesized from real activity (comments,
      attachments, created/updated); each entry is one file, sorted newest
      first, so plain readdir does what `tail` would.
    * Attachments store metadata only (§3.3: no binary pass-through until B1);
      the create payload is the attachment descriptor JSON.
    * Ticket deletion is unexposed (§3.5): `remove/2` only serves
      `_types/{slug}.json` and `_fields/{slug}.json` (the `DefinitionDelete` /
      `FieldDefinitionDelete` mappings); every other removal is `:enosys`.
    * Gate order (§1.3): org not visible or `tickets` group excluded/hidden →
      `:enoent` for the whole subtree (no existence leak); group included but
      disabled → nodes list with `writable: false` and mutations → `:eacces`.

  The behaviour callbacks address full paths and exist so the backend is
  independently conformance-testable; the composed Router's prefix dispatch
  calls the exported `dispatch_*` functions with the org slug and the
  segments below `tickets` directly.
  """

  use Noizu.MCP.VFS

  alias Noizu.MCP.Server.Features.Pagination
  alias Noizu.MCP.VFS
  alias NoizuPromptLingua.Domains.{Links, Tickets}
  alias NoizuPromptLingua.Domains.Tickets.{Definitions, Queues}
  alias NoizuPromptLingua.MCP.Resolve
  alias NoizuPromptLingua.MCP.VFS.Principal
  alias NoizuPromptLingua.Services.{Attach, Comment, Watch}

  @group "tickets"
  @orgs_root "tobor"

  # §3.2: the top-level listing carries a bounded recent window; `_all/` opts
  # into the full set. Both are cursor-paginated on the wire.
  @window 500

  # Same grammar as `NoizuPromptLingua.Domains.Tickets` — a ticket path
  # segment must be a human key so reserved `_`-names never collide.
  @key_format ~r/^[A-Za-z0-9]{2,6}-\d{3,}$/

  @typedoc "Org slug carved out of the path."
  @type org_slug :: String.t()

  # ── full-path behaviour callbacks (conformance surface) ───────────────────

  @impl true
  def stat(path, ctx) do
    case split(path) do
      {:ok, [@orgs_root, org, @group | rest]} -> dispatch_stat(rest, org, ctx)
      _ -> {:error, :enoent}
    end
  end

  @impl true
  def list(path, cursor, ctx) do
    case split(path) do
      {:ok, [@orgs_root, org, @group | rest]} -> dispatch_list(rest, cursor, org, ctx)
      _ -> {:error, :enoent}
    end
  end

  @impl true
  def read(path, ctx) do
    case split(path) do
      {:ok, [@orgs_root, org, @group | rest]} -> dispatch_read(rest, org, ctx)
      _ -> {:error, :enoent}
    end
  end

  @impl true
  def write(path, data, ctx) do
    case split(path) do
      {:ok, [@orgs_root, org, @group | rest]} -> dispatch_write(rest, data, org, ctx)
      err -> err
    end
  end

  @impl true
  def create(path, data, ctx) do
    case split(path) do
      {:ok, [@orgs_root, org, @group | rest]} -> dispatch_create(rest, data, org, ctx)
      err -> err
    end
  end

  @impl true
  def remove(path, ctx) do
    case split(path) do
      {:ok, [@orgs_root, org, @group | rest]} -> dispatch_remove(rest, org, ctx)
      err -> err
    end
  end

  @impl true
  def xattr(path, ctx) do
    case split(path) do
      {:ok, [@orgs_root, org, @group | rest]} -> dispatch_xattr(rest, org, ctx)
      _ -> {:ok, %{}}
    end
  end

  # ── exported dispatch (Router / Root prefix wiring) ───────────────────────

  def dispatch_stat(segments, org, ctx) do
    gate(ctx, org, fn _gate -> stat_segments(segments, org, ctx) end)
  end

  def dispatch_list(segments, cursor, org, ctx) do
    gate(ctx, org, fn _gate -> list_segments(segments, cursor, org, ctx) end)
  end

  def dispatch_read(segments, org, ctx) do
    gate(ctx, org, fn _gate -> read_segments(segments, org, ctx) end)
  end

  def dispatch_write(segments, data, org, ctx) do
    writable(ctx, org, fn -> write_segments(segments, data, org, ctx) end)
  end

  def dispatch_create(segments, data, org, ctx) do
    writable(ctx, org, fn -> create_segments(segments, data, org, ctx) end)
  end

  def dispatch_remove(segments, org, ctx) do
    writable(ctx, org, fn -> remove_segments(segments, org, ctx) end)
  end

  def dispatch_xattr(segments, org, ctx) do
    gate(ctx, org, fn _gate -> xattr_segments(segments, org, ctx) end)
  end

  # ── path model ────────────────────────────────────────────────────────────

  defp split("/" <> rest), do: split(rest)

  defp split(path) when is_binary(path) do
    segments =
      path
      |> String.trim_trailing("/")
      |> String.split("/", trim: true)

    if Enum.any?(segments, &(&1 in [".", ".."])), do: {:error, :enoent}, else: {:ok, segments}
  end

  defp split(_), do: {:error, :enoent}

  # ── gates ─────────────────────────────────────────────────────────────────

  defp gate(ctx, org, fun) do
    if Principal.org_visible?(ctx, org) do
      with :ok <- Principal.group_gate(ctx, @group) do
        fun.(Principal.groups(ctx)[@group])
      else
        err -> err
      end
    else
      {:error, :enoent}
    end
  end

  defp writable(ctx, org, fun) do
    gate(ctx, org, fn
      %{writable: true} -> fun.()
      _ -> {:error, :eacces}
    end)
  end

  defp with_org(org, fun) do
    case Resolve.organization_id(org) do
      nil -> {:error, :enoent}
      org_id -> fun.(org_id)
    end
  end

  defp org_id!(org) do
    case Resolve.organization_id(org) do
      nil -> {:error, :enoent}
      org_id -> {:ok, org_id}
    end
  end

  defp ticket!(org_id, key) do
    case ticket(org_id, key) do
      nil -> {:error, :enoent}
      item -> {:ok, item}
    end
  end

  defp ticket(org_id, key) do
    case Tickets.get_by_key(org_id, String.upcase(key)) do
      item when is_map(item) -> item
      _ -> nil
    end
  end

  defp ticket_key?(seg), do: Regex.match?(@key_format, seg)

  # Run `fun` with the ticket when `{org}/{key}` resolves; :enoent otherwise.
  defp ticket_file(key, org, fun) do
    with_org(org, fn org_id ->
      case ticket!(org_id, key) do
        {:ok, item} -> fun.(item)
        err -> err
      end
    end)
  end

  defp ticket_dir(key, org, fun), do: ticket_file(key, org, fun)

  defp with_items(org, fun) do
    with_org(org, fn org_id ->
      case Tickets.list(organization_id: org_id, sort: :updated_at, dir: :desc) do
        rows when is_list(rows) -> fun.(rows)
        _ -> {:error, :eio}
      end
    end)
  end

  defp with_slug(file, org, fun) do
    case slug_part(file) do
      nil -> {:error, :enoent}
      slug -> with_org(org, fn org_id -> fun.(org_id, slug) end)
    end
  end

  # ── stat ──────────────────────────────────────────────────────────────────

  defp stat_segments([], _org, _ctx), do: {:ok, dir_node()}

  defp stat_segments(["_all"], _org, _ctx), do: {:ok, dir_node()}
  defp stat_segments(["_queues"], _org, _ctx), do: {:ok, dir_node()}
  defp stat_segments(["_types"], _org, _ctx), do: {:ok, dir_node()}
  defp stat_segments(["_fields"], _org, _ctx), do: {:ok, dir_node()}

  defp stat_segments(["_queues", name], org, _ctx) when is_binary(name) do
    with_org(org, fn org_id ->
      cond do
        queue_file?(name) ->
          queue_node(name, org_id)

        queue_feed?(name) ->
          if(queue_exists?(name, org_id), do: {:ok, dir_node()}, else: {:error, :enoent})

        true ->
          {:error, :enoent}
      end
    end)
  end

  defp stat_segments(["_types", file], org, _ctx) when is_binary(file) do
    with_slug(file, org, fn org_id, slug ->
      if Definitions.resolve_type(org_id, nil, slug),
        do: {:ok, file_node(0)},
        else: {:error, :enoent}
    end)
  end

  defp stat_segments(["_fields", file], org, _ctx) when is_binary(file) do
    with_slug(file, org, fn org_id, slug ->
      if Definitions.resolve_field(org_id, nil, slug),
        do: {:ok, file_node(0)},
        else: {:error, :enoent}
    end)
  end

  defp stat_segments([key], org, _ctx) do
    if ticket_key?(key) do
      ticket_file(key, org, fn item -> {:ok, %{dir_node() | xattrs: ticket_xattrs(item)}} end)
    else
      {:error, :enoent}
    end
  end

  defp stat_segments([key, "record.json"], org, _ctx) do
    ticket_file(key, org, fn item ->
      {:ok, file_node(byte_size(record_json(item)), ticket_mtime(item))}
    end)
  end

  defp stat_segments([key, "watchers.json"], org, _ctx),
    do: ticket_file(key, org, fn _item -> {:ok, file_node(0)} end)

  defp stat_segments([key, "links.json"], org, _ctx),
    do: ticket_file(key, org, fn _item -> {:ok, file_node(0)} end)

  defp stat_segments([key, child], org, _ctx)
       when child in ~w(comments attachments fields feed.log),
       do: ticket_file(key, org, fn _item -> {:ok, dir_node()} end)

  defp stat_segments([key, "comments", name], org, _ctx) when is_binary(name) do
    ticket_file(key, org, fn item ->
      if comment_by_name(item.id, name), do: {:ok, file_node(0)}, else: {:error, :enoent}
    end)
  end

  defp stat_segments([key, "attachments", name], org, _ctx) when is_binary(name) do
    ticket_file(key, org, fn item ->
      if attachment_by_name(item.id, name), do: {:ok, file_node(0)}, else: {:error, :enoent}
    end)
  end

  defp stat_segments([key, "fields", file], org, _ctx) when is_binary(file) do
    ticket_file(key, org, fn item ->
      if field_value(item, file), do: {:ok, file_node(0)}, else: {:error, :enoent}
    end)
  end

  defp stat_segments([key, "feed.log", name], org, _ctx) when is_binary(name) do
    ticket_file(key, org, fn item ->
      if feed_entry(ticket_feed(item), name), do: {:ok, file_node(0)}, else: {:error, :enoent}
    end)
  end

  defp stat_segments(_, _org, _ctx), do: {:error, :enoent}

  # ── list ──────────────────────────────────────────────────────────────────

  defp list_segments([], cursor, org, _ctx) do
    with_items(org, fn items ->
      reserved = Enum.map(~w(_all _fields _queues _types), &dir_entry/1)
      tickets = items |> Enum.take(@window) |> Enum.map(&key_entry/1)
      paginate(reserved ++ tickets, cursor)
    end)
  end

  defp list_segments(["_all"], cursor, org, _ctx) do
    with_items(org, fn items -> paginate(Enum.map(items, &key_entry/1), cursor) end)
  end

  defp list_segments(["_queues"], cursor, org, _ctx) do
    with_org(org, fn org_id ->
      entries =
        Queues.list(org_id, nil)
        |> Enum.flat_map(fn q ->
          [file_entry(q.slug <> ".json"), dir_entry(q.slug <> ".feed.log")]
        end)
        |> Enum.sort_by(& &1.name)

      paginate(entries, cursor)
    end)
  end

  defp list_segments(["_types"], cursor, org, _ctx) do
    with_org(org, fn org_id ->
      entries =
        org_id
        |> Definitions.list_types(nil)
        |> Enum.map(&file_entry(&1.slug <> ".json"))
        |> Enum.sort_by(& &1.name)

      paginate(entries, cursor)
    end)
  end

  defp list_segments(["_fields"], cursor, org, _ctx) do
    with_org(org, fn org_id ->
      entries =
        org_id
        |> Definitions.list_fields(nil)
        |> Enum.map(&file_entry(&1.slug <> ".json"))
        |> Enum.sort_by(& &1.name)

      paginate(entries, cursor)
    end)
  end

  defp list_segments([key], cursor, org, _ctx) do
    ticket_dir(key, org, fn _item ->
      entries = [
        file_entry("record.json"),
        dir_entry("comments"),
        dir_entry("attachments"),
        dir_entry("fields"),
        file_entry("watchers.json"),
        file_entry("links.json"),
        dir_entry("feed.log")
      ]

      paginate(entries, cursor)
    end)
  end

  defp list_segments([key, "comments"], cursor, org, _ctx) do
    ticket_dir(key, org, fn item ->
      entries =
        Comment.list("ticket", item.id)
        |> rows_or_empty()
        |> Enum.map(&file_entry(comment_name(&1)))
        |> Enum.sort_by(& &1.name, :desc)

      paginate(entries, cursor)
    end)
  end

  defp list_segments([key, "attachments"], cursor, org, _ctx) do
    ticket_dir(key, org, fn item ->
      entries =
        Attach.list("ticket", item.id)
        |> rows_or_empty()
        |> Enum.map(&file_entry(attachment_name(&1)))
        |> Enum.sort_by(& &1.name)

      paginate(entries, cursor)
    end)
  end

  defp list_segments([key, "fields"], cursor, org, _ctx) do
    ticket_dir(key, org, fn item ->
      entries =
        item
        |> custom_fields()
        |> Map.keys()
        |> Enum.sort()
        |> Enum.map(&file_entry(&1 <> ".json"))

      paginate(entries, cursor)
    end)
  end

  defp list_segments([key, "feed.log"], cursor, org, _ctx) do
    ticket_dir(key, org, fn item ->
      entries = item |> ticket_feed() |> Enum.map(&file_entry(&1.name))
      paginate(entries, cursor)
    end)
  end

  defp list_segments(["_queues", name], cursor, org, _ctx) when is_binary(name) do
    cond do
      queue_feed?(name) ->
        with_org(org, fn org_id ->
          if queue_exists?(name, org_id) do
            board = Queues.get(queue_slug(name, ".feed.log"), org_id, nil)
            entries = board |> queue_feed() |> Enum.map(&file_entry(&1.name))
            paginate(entries, cursor)
          else
            {:error, :enoent}
          end
        end)

      queue_file?(name) ->
        {:error, :enotdir}

      true ->
        {:error, :enoent}
    end
  end

  defp list_segments([_key, "comments", _name], _cursor, _org, _ctx), do: {:error, :enotdir}
  defp list_segments([_key, "attachments", _name], _cursor, _org, _ctx), do: {:error, :enotdir}
  defp list_segments([_key, "fields", _name], _cursor, _org, _ctx), do: {:error, :enotdir}
  defp list_segments([_key, "feed.log", _name], _cursor, _org, _ctx), do: {:error, :enotdir}
  defp list_segments(["_types", _file], _cursor, _org, _ctx), do: {:error, :enotdir}
  defp list_segments(["_fields", _file], _cursor, _org, _ctx), do: {:error, :enotdir}

  defp list_segments(_, _cursor, _org, _ctx), do: {:error, :enoent}

  # The lib's opaque offset cursors — invalid cursors surface as
  # `Noizu.MCP.Error` (invalid params), matching the Root/backend convention.
  defp paginate(entries, cursor), do: Pagination.paginate(entries, cursor)

  # ── read ──────────────────────────────────────────────────────────────────

  defp read_segments([key, "record.json"], org, _ctx) do
    ticket_file(key, org, fn item -> {:ok, record_json(item), version()} end)
  end

  defp read_segments([key, "watchers.json"], org, _ctx) do
    ticket_file(key, org, fn item -> {:ok, Jason.encode!(watchers_doc(item.id)), version()} end)
  end

  defp read_segments([key, "links.json"], org, _ctx) do
    ticket_file(key, org, fn item -> {:ok, Jason.encode!(links_doc(item)), version()} end)
  end

  defp read_segments([key, "comments", name], org, _ctx) when is_binary(name) do
    ticket_file(key, org, fn item ->
      case comment_by_name(item.id, name) do
        nil -> {:error, :enoent}
        comment -> {:ok, Jason.encode!(comment_doc(comment)), version()}
      end
    end)
  end

  defp read_segments([key, "attachments", name], org, _ctx) when is_binary(name) do
    ticket_file(key, org, fn item ->
      case attachment_by_name(item.id, name) do
        nil -> {:error, :enoent}
        att -> {:ok, Jason.encode!(attachment_doc(att)), version()}
      end
    end)
  end

  defp read_segments([key, "fields", file], org, _ctx) when is_binary(file) do
    ticket_file(key, org, fn item ->
      case field_value(item, file) do
        nil -> {:error, :enoent}
        value -> {:ok, Jason.encode!(value), version()}
      end
    end)
  end

  defp read_segments([key, "feed.log", name], org, _ctx) when is_binary(name) do
    ticket_file(key, org, fn item ->
      case feed_entry(ticket_feed(item), name) do
        nil -> {:error, :enoent}
        event -> {:ok, Jason.encode!(feed_doc(event)), version()}
      end
    end)
  end

  defp read_segments(["_queues", name], org, _ctx) when is_binary(name) do
    cond do
      queue_file?(name) ->
        with_org(org, fn org_id ->
          if queue_exists?(name, org_id) do
            {:ok, Jason.encode!(Queues.get(queue_slug(name, ".json"), org_id, nil)), version()}
          else
            {:error, :enoent}
          end
        end)

      queue_feed?(name) ->
        {:error, :eisdir}

      true ->
        {:error, :enoent}
    end
  end

  defp read_segments(["_queues", name, entry], org, _ctx)
       when is_binary(name) and is_binary(entry) do
    with_org(org, fn org_id ->
      if queue_exists?(name, org_id) do
        board = Queues.get(queue_slug(name, ".feed.log"), org_id, nil)

        case feed_entry(queue_feed(board), entry) do
          nil -> {:error, :enoent}
          event -> {:ok, Jason.encode!(feed_doc(event)), version()}
        end
      else
        {:error, :enoent}
      end
    end)
  end

  defp read_segments(["_types", file], org, _ctx) when is_binary(file) do
    with_slug(file, org, fn org_id, slug ->
      case Definitions.resolve_type(org_id, nil, slug) do
        nil -> {:error, :enoent}
        type -> {:ok, Jason.encode!(type), version()}
      end
    end)
  end

  defp read_segments(["_fields", file], org, _ctx) when is_binary(file) do
    with_slug(file, org, fn org_id, slug ->
      case Definitions.resolve_field(org_id, nil, slug) do
        nil -> {:error, :enoent}
        field -> {:ok, Jason.encode!(field), version()}
      end
    end)
  end

  defp read_segments([key], org, _ctx),
    do: ticket_dir(key, org, fn _item -> {:error, :eisdir} end)

  defp read_segments([key, dir], org, _ctx) when dir in ~w(comments attachments fields feed.log),
    do: ticket_dir(key, org, fn _item -> {:error, :eisdir} end)

  defp read_segments(_, _org, _ctx), do: {:error, :enoent}

  # ── write ─────────────────────────────────────────────────────────────────

  defp write_segments([key, "record.json"], data, org, _ctx) when is_binary(data) do
    ticket_file(key, org, fn item ->
      with {:ok, doc} <- decode(data) do
        case Tickets.update(item.id, record_attrs(doc, org)) do
          {:ok, updated} ->
            {:ok, file_node(byte_size(record_json(updated)), ticket_mtime(updated))}

          {:error, _} ->
            {:error, :eio}
        end
      end
    end)
  end

  defp write_segments([key, "fields", file], data, org, _ctx)
       when is_binary(data) and is_binary(file) do
    ticket_file(key, org, fn item ->
      with {:ok, value} <- decode_value(data) do
        slug = slug_of(file)
        current = custom_fields(item)

        case Tickets.update(item.id, %{custom_fields: Map.put(current, slug, value)}) do
          {:ok, updated} -> {:ok, file_node(0, ticket_mtime(updated))}
          {:error, _} -> {:error, :eio}
        end
      end
    end)
  end

  defp write_segments([key, "watchers.json"], data, org, _ctx) when is_binary(data) do
    ticket_file(key, org, fn item ->
      with {:ok, doc} <- decode(data),
           :ok <- apply_watch_ops(item.id, doc) do
        {:ok, file_node(byte_size(Jason.encode!(watchers_doc(item.id))))}
      end
    end)
  end

  defp write_segments([key, "links.json"], data, org, _ctx) when is_binary(data) do
    ticket_file(key, org, fn item ->
      with {:ok, doc} <- decode(data),
           {:ok, org_id} <- org_id!(org),
           :ok <- apply_link_ops(item, doc, org_id) do
        {:ok, file_node(byte_size(Jason.encode!(links_doc(item))))}
      end
    end)
  end

  defp write_segments(["_types", file], data, org, _ctx)
       when is_binary(data) and is_binary(file) do
    with_slug(file, org, fn org_id, slug ->
      case Definitions.resolve_type(org_id, nil, slug) do
        nil ->
          {:error, :enoent}

        type ->
          with {:ok, doc} <- decode(data) do
            attrs = definition_attrs(doc, ~w(name description icon status_workflow disabled))

            case Definitions.update_type(type.id, attrs) do
              {:ok, _updated} -> {:ok, file_node(0)}
              {:error, _} -> {:error, :eio}
            end
          end
      end
    end)
  end

  defp write_segments(["_fields", file], data, org, _ctx)
       when is_binary(data) and is_binary(file) do
    with_slug(file, org, fn org_id, slug ->
      case Definitions.resolve_field(org_id, nil, slug) do
        nil ->
          {:error, :enoent}

        field ->
          with {:ok, doc} <- decode(data) do
            attrs =
              definition_attrs(
                doc,
                ~w(label field_type options default_value description disabled)
              )

            case Definitions.update_field(field.id, attrs) do
              {:ok, _updated} -> {:ok, file_node(0)}
              {:error, _} -> {:error, :eio}
            end
          end
      end
    end)
  end

  defp write_segments([key], _data, org, _ctx),
    do: ticket_dir(key, org, fn _item -> {:error, :eisdir} end)

  defp write_segments([key, dir], _data, org, _ctx)
       when dir in ~w(comments attachments fields feed.log),
       do: ticket_dir(key, org, fn _item -> {:error, :eisdir} end)

  # Unmapped write targets (comments, attachments, feed entries, queues, …)
  # are structurally server-authored — not :enoent, simply not writable.
  defp write_segments(_, _data, _org, _ctx), do: {:error, :enosys}

  # ── create ────────────────────────────────────────────────────────────────

  # TicketCreate: the KEY is assigned by the server; the created node's real
  # path rides the returned node's xattrs (§2.8).
  defp create_segments(["_new", "record.json"], data, org, _ctx) when is_binary(data) do
    with {:ok, doc} <- decode(data),
         true <- valid_title?(doc) || {:error, :eio},
         {:ok, org_id} <- org_id!(org),
         {:ok, item} <- create_ticket(ticket_attrs(doc, org_id)) do
      path = "/#{@orgs_root}/#{org}/#{@group}/#{item.key}/record.json"

      {:ok,
       %{
         file_node(byte_size(record_json(item)), ticket_mtime(item))
         | xattrs: %{"path" => path, "key" => item.key, "id" => item.id}
       }}
    end
  end

  defp create_segments(["_new", _other], _data, _org, _ctx), do: {:error, :enoent}

  defp create_segments([key, "comments", name], data, org, _ctx)
       when is_binary(data) and is_binary(name) do
    if safe_name?(name) do
      ticket_file(key, org, fn item ->
        with {:ok, doc} <- decode(data),
             true <- (is_binary(doc["content"]) && doc["content"] != "") || {:error, :eio},
             {:ok, comment} <-
               Comment.add("ticket", item.id, %{
                 content: doc["content"],
                 author: doc["author"],
                 reply_to_id: doc["reply_to_id"]
               }) do
          create_node(
            comment.id,
            "#{@group}/#{item.key}/comments/#{comment_name(comment)}",
            comment_name(comment)
          )
        end
      end)
    else
      {:error, :enoent}
    end
  end

  # Attachments are metadata-only until binary pass-through (§3.3 / B1): the
  # create payload is the attachment descriptor JSON; the canonical name is
  # server-assigned and returned in xattrs.
  defp create_segments([key, "attachments", name], data, org, _ctx)
       when is_binary(data) and is_binary(name) do
    if safe_name?(name) do
      ticket_file(key, org, fn item ->
        with {:ok, doc} <- decode(data),
             true <-
               (is_binary(doc["artifact_type"]) && doc["artifact_type"] != "") || {:error, :eio},
             {:ok, att} <-
               Attach.add("ticket", item.id, %{
                 artifact_type: doc["artifact_type"],
                 url: doc["url"],
                 git_branch: doc["git_branch"],
                 description: doc["description"],
                 created_by: doc["created_by"]
               }) do
          create_node(
            att.id,
            "#{@group}/#{item.key}/attachments/#{attachment_name(att)}",
            attachment_name(att)
          )
        end
      end)
    else
      {:error, :enoent}
    end
  end

  defp create_segments(["_queues", file], data, org, _ctx)
       when is_binary(data) and is_binary(file) do
    with_slug(file, org, fn org_id, slug ->
      if Queues.get(slug, org_id, nil) do
        {:error, :eexist}
      else
        with {:ok, doc} <- decode(data) do
          attrs = %{
            name: doc["name"] || slug,
            slug: slug,
            methodology: doc["methodology"] || "kanban",
            description: doc["description"],
            organization_id: org_id,
            project_id: nil
          }

          case Queues.create(attrs) do
            {:ok, board} ->
              {:ok,
               %{
                 file_node(0)
                 | xattrs: %{"path" => "#{@group}/_queues/#{board.slug}.json", "id" => board.id}
               }}

            {:error, _} ->
              {:error, :eio}
          end
        end
      end
    end)
  end

  defp create_segments(["_types", file], data, org, _ctx)
       when is_binary(data) and is_binary(file) do
    with_slug(file, org, fn org_id, slug ->
      if Definitions.resolve_type(org_id, nil, slug) do
        {:error, :eexist}
      else
        with {:ok, doc} <- decode(data),
             true <- valid_name?(doc) || {:error, :eio} do
          attrs =
            definition_attrs(doc, ~w(name description icon status_workflow))
            |> Map.merge(%{slug: slug, organization_id: org_id, project_id: nil})

          case Definitions.create_type(attrs) do
            {:ok, type} ->
              {:ok,
               %{
                 file_node(0)
                 | xattrs: %{"path" => "#{@group}/_types/#{type.slug}.json", "id" => type.id}
               }}

            {:error, _} ->
              {:error, :eio}
          end
        end
      end
    end)
  end

  defp create_segments(["_fields", file], data, org, _ctx)
       when is_binary(data) and is_binary(file) do
    with_slug(file, org, fn org_id, slug ->
      if Definitions.resolve_field(org_id, nil, slug) do
        {:error, :eexist}
      else
        with {:ok, doc} <- decode(data) do
          attrs =
            definition_attrs(doc, ~w(label field_type options default_value description))
            |> Map.merge(%{slug: slug, organization_id: org_id, project_id: nil})

          case Definitions.create_field(attrs) do
            {:ok, field} ->
              {:ok,
               %{
                 file_node(0)
                 | xattrs: %{"path" => "#{@group}/_fields/#{field.slug}.json", "id" => field.id}
               }}

            {:error, _} ->
              {:error, :eio}
          end
        end
      end
    end)
  end

  defp create_segments([key, "record.json"], _data, org, _ctx),
    do: ticket_file(key, org, fn _item -> {:error, :eexist} end)

  defp create_segments([key], _data, org, _ctx),
    do: ticket_file(key, org, fn _item -> {:error, :eexist} end)

  defp create_segments(_, _data, _org, _ctx), do: {:error, :enosys}

  # ── remove ────────────────────────────────────────────────────────────────

  defp remove_segments(["_types", file], org, _ctx) when is_binary(file) do
    with_slug(file, org, fn org_id, slug ->
      case Definitions.resolve_type(org_id, nil, slug) do
        nil -> {:error, :enoent}
        type -> remove_definition(Definitions.delete_type(type.id))
      end
    end)
  end

  defp remove_segments(["_fields", file], org, _ctx) when is_binary(file) do
    with_slug(file, org, fn org_id, slug ->
      case Definitions.resolve_field(org_id, nil, slug) do
        nil -> {:error, :enoent}
        field -> remove_definition(Definitions.delete_field(field.id))
      end
    end)
  end

  # §3.5: ticket deletion is absent from the tool surface and stays unexposed —
  # record.json, projections, comments, attachments, feeds, queues: all :enosys.
  defp remove_segments(_, _org, _ctx), do: {:error, :enosys}

  defp remove_definition({:ok, _}), do: :ok
  defp remove_definition({:error, _}), do: {:error, :eio}

  # ── xattr ─────────────────────────────────────────────────────────────────

  defp xattr_segments([key], org, _ctx) do
    if ticket_key?(key) do
      ticket_file(key, org, fn item -> {:ok, ticket_xattrs(item)} end)
    else
      {:ok, %{}}
    end
  end

  defp xattr_segments([key, "record.json"], org, _ctx) do
    ticket_file(key, org, fn item -> {:ok, ticket_xattrs(item)} end)
  end

  defp xattr_segments(_, _org, _ctx), do: {:ok, %{}}

  # ── projections: feeds ────────────────────────────────────────────────────

  defp ticket_feed(item) do
    comments = comment_rows(item.id)
    attachments = attachment_rows(item.id)
    created_at = ts_ms(item.inserted_at)
    updated_at = ts_ms(item.updated_at)

    events =
      [created_event(item, created_at)] ++
        if(updated_at != created_at,
          do: [
            %{
              at: updated_at,
              kind: "ticket.updated",
              actor: Map.get(item, :assignee),
              ref: item.key,
              summary: item.title,
              id: item.id
            }
          ],
          else: []
        ) ++
        Enum.map(comments, fn c ->
          %{
            at: ts_ms(c.inserted_at),
            kind: "comment.created",
            actor: c.author,
            ref: comment_name(c),
            summary: first_line(c.content),
            id: c.id
          }
        end) ++
        Enum.map(attachments, fn a ->
          %{
            at: ts_ms(a.inserted_at),
            kind: "attachment.added",
            actor: Map.get(a, :created_by),
            ref: attachment_name(a),
            summary: a.description || a.artifact_type,
            id: a.id
          }
        end)

    events
    |> Enum.sort_by(& &1.at, :desc)
    |> assign_feed_names()
  end

  defp created_event(item, at) do
    %{
      at: at,
      kind: "ticket.created",
      actor: Map.get(item, :reporter),
      ref: item.key,
      summary: item.title,
      id: item.id
    }
  end

  # A queue's feed is the recent-activity projection over its tickets.
  defp queue_feed(nil), do: []

  defp queue_feed(board) do
    rows =
      Tickets.list(
        organization_id: board.organization_id,
        queue_id: board.id,
        sort: :updated_at,
        dir: :desc
      )
      |> rows_or_empty()

    rows
    |> Enum.map(fn item ->
      %{
        at: ts_ms(item.updated_at),
        kind: "ticket.updated",
        actor: Map.get(item, :assignee),
        ref: item.key,
        summary: item.title,
        id: item.id
      }
    end)
    |> Enum.sort_by(& &1.at, :desc)
    |> assign_feed_names()
  end

  # Stable, unique `{ts}-{short8}.json` names (§1.1 filesystem-safe ts).
  defp assign_feed_names(events) do
    {named, _} =
      Enum.map_reduce(events, MapSet.new(), fn event, used ->
        base = "#{ts_safe(ms_to_dt(event.at))}-#{short8(event.id)}"
        name = free_name(used, base, 0)
        {Map.put(event, :name, name <> ".json"), MapSet.put(used, name)}
      end)

    named
  end

  defp free_name(used, base, n) do
    candidate = if n == 0, do: base, else: "#{base}-#{n}"

    if MapSet.member?(used, candidate) do
      free_name(used, base, n + 1)
    else
      candidate
    end
  end

  defp feed_entry(events, name) do
    Enum.find(events, &(&1.name == name))
  end

  defp feed_doc(event) do
    %{
      "kind" => event.kind,
      "at" => ts_iso(ms_to_dt(event.at)),
      "actor" => event.actor,
      "ref" => event.ref,
      "summary" => event.summary
    }
  end

  # TRP-backed list helpers return `{:error, _}` (or nil) on backend trouble —
  # feeds and listings degrade to an empty projection instead of crashing.
  defp rows_or_empty(rows) when is_list(rows), do: rows
  defp rows_or_empty(_), do: []

  # ── projections: doc builders ─────────────────────────────────────────────

  defp record_json(item), do: Jason.encode!(item)

  defp watchers_doc(ticket_id) do
    %{"personas" => watcher_map(ticket_id)}
  end

  defp watcher_map(ticket_id) do
    ticket_id
    |> watchers_with_filter()
    |> Map.new(fn {persona, filter} -> {persona, %{"filter" => filter}} end)
  end

  defp links_doc(item) do
    links = Tickets.get_links(item.id)

    %{
      "outgoing" =>
        Enum.map(links.outgoing, fn l ->
          %{"target" => peer_ref(l.target_ticket, l.target_ticket_id), "type" => l.link_type}
        end),
      "incoming" =>
        Enum.map(links.incoming, fn l ->
          %{"source" => peer_ref(l.source_ticket, l.source_ticket_id), "type" => l.link_type}
        end),
      "entities" =>
        item.id
        |> Links.get_entity_links()
        |> rows_or_empty()
        |> Enum.map(fn l ->
          %{
            "entity_type" => l.entity_type,
            "entity_id" => l.entity_id,
            "link_type" => l.link_type
          }
        end)
    }
  end

  # Prefer the human key from the preloaded ticket; tickets live on TRP now,
  # so the local-table preload often misses — fall back to the raw id.
  defp peer_ref(%{key: key}, _id) when is_binary(key), do: key
  defp peer_ref(%{id: id}, _id), do: id
  defp peer_ref(_preloaded, id), do: id

  defp comment_doc(c) do
    %{
      "id" => c.id,
      "content" => c.content,
      "author" => c.author,
      "reply_to_id" => c.reply_to_id,
      "created_at" => ts_iso(c.inserted_at)
    }
  end

  defp attachment_doc(a) do
    %{
      "id" => a.id,
      "artifact_type" => a.artifact_type,
      "url" => a.url,
      "git_branch" => a.git_branch,
      "description" => a.description,
      "created_by" => a.created_by,
      "created_at" => ts_iso(a.inserted_at)
    }
  end

  defp create_node(id, path, name) do
    {:ok, %{file_node(0) | xattrs: %{"path" => path, "name" => name, "id" => id}}}
  end

  # ── write semantics: watchers / links ─────────────────────────────────────

  # Accepted shapes (§3.4 read-modify-write projections):
  #   {"personas": ["a", "b"]}                        → reconcile the full set
  #   {"personas": {"a": {"filter": …}, "b": null}}   → reconcile, with filters
  #   {"persona": "a", "action": "watch"|"unwatch", "filter": …} → single op
  defp apply_watch_ops(ticket_id, %{"personas" => list}) when is_list(list) do
    reconcile_watchers(ticket_id, Map.new(list, &{to_string(&1), nil}))
  end

  defp apply_watch_ops(ticket_id, %{"personas" => map}) when is_map(map) do
    desired =
      Map.new(map, fn
        {persona, %{"filter" => filter}} -> {persona, filter}
        {persona, %{filter: filter}} -> {persona, filter}
        {persona, _} -> {persona, nil}
      end)

    reconcile_watchers(ticket_id, desired)
  end

  defp apply_watch_ops(ticket_id, %{"persona" => persona} = doc) when is_binary(persona) do
    case doc["action"] do
      "unwatch" ->
        case Watch.unwatch("ticket", ticket_id, persona) do
          {:ok, _} -> :ok
          {:error, :not_found} -> :ok
          {:error, _} -> {:error, :eio}
        end

      _ ->
        watch(ticket_id, persona, doc["filter"])
    end
  end

  defp apply_watch_ops(_ticket_id, _doc), do: {:error, :eio}

  defp reconcile_watchers(ticket_id, desired) do
    current = watcher_map_raw(ticket_id)

    changes =
      Enum.concat(
        # new watches + filter updates on existing watches
        desired
        |> Enum.filter(fn {persona, filter} ->
          not Map.has_key?(current, persona) or
            (filter != nil and Map.fetch!(current, persona) != filter)
        end),
        # removals
        current
        |> Map.keys()
        |> Enum.reject(&Map.has_key?(desired, &1))
        |> Enum.map(&{&1, :unwatch})
      )

    changes
    |> Enum.reduce_while(:ok, fn
      {persona, :unwatch}, :ok ->
        case Watch.unwatch("ticket", ticket_id, persona) do
          {:ok, _} -> {:cont, :ok}
          {:error, _} -> {:halt, {:error, :eio}}
        end

      {persona, filter}, :ok ->
        case watch(ticket_id, persona, filter) do
          :ok -> {:cont, :ok}
          err -> {:halt, err}
        end
    end)
  end

  defp watch_filter(nil), do: nil
  defp watch_filter(f) when is_binary(f), do: %{"type" => "substring", "value" => f}
  defp watch_filter(f), do: f

  defp watchers_with_filter(ticket_id),
    do: rows_or_empty(Watch.watchers_with_filter("ticket", ticket_id))

  defp watcher_map_raw(ticket_id) do
    ticket_id
    |> watchers_with_filter()
    |> Map.new(fn {persona, filter} -> {persona, filter} end)
  end

  # The schema stores filters as jsonb objects; a bare string means substring.
  defp watch(ticket_id, persona, filter) do
    filter = watch_filter(filter)

    case Watch.watch("ticket", ticket_id, persona, filter) do
      {:ok, _} -> :ok
      {:error, _} -> {:error, :eio}
    end
  end

  # Accepted shapes:
  #   {"link": {"target": "KEY|uuid", "type": "blocks"}}           (+ "links": […])
  #   {"unlink": {"target": …, "type": …}}                         (+ "unlinks": […])
  #   {"link_entity": {"entity_type": …, "entity_id": …, "link_type": …, "metadata": …}}
  #   {"unlink_entity": {"entity_type": …, "entity_id": …, "link_type": …}}
  #     (+ "link_entities" / "unlink_entities" plurals)
  defp apply_link_ops(item, doc, org_id) do
    with :ok <- each_op(ops(doc, "link", "links"), &apply_ticket_link(item, org_id, &1)),
         :ok <- each_op(ops(doc, "unlink", "unlinks"), &apply_ticket_unlink(item, org_id, &1)),
         :ok <- each_op(ops(doc, "link_entity", "link_entities"), &apply_entity_link(item, &1)),
         :ok <-
           each_op(ops(doc, "unlink_entity", "unlink_entities"), &apply_entity_unlink(item, &1)) do
      :ok
    end
  end

  defp ops(doc, single, plural), do: List.wrap(doc[single]) ++ List.wrap(doc[plural])

  defp each_op([], _fun), do: :ok

  defp each_op(ops, fun) do
    Enum.reduce_while(ops, :ok, fn op, :ok ->
      case fun.(op) do
        :ok -> {:cont, :ok}
        err -> {:halt, err}
      end
    end)
  end

  defp apply_ticket_link(item, org_id, %{"target" => ref} = op) when is_binary(ref) do
    with {:ok, target} <- resolve_ticket_ref(ref, org_id) do
      case Tickets.link(item.id, target.id, op["type"] || "relates_to") do
        {:ok, _} -> :ok
        {:error, %Ecto.Changeset{}} -> {:error, :eexist}
        {:error, _} -> {:error, :eio}
      end
    end
  rescue
    # The domain declares the uniqueness under Ecto's default index name,
    # which doesn't match the migrated `idx_ticket_links_unique` — a dup
    # raises instead of returning a changeset. Translate it here.
    Ecto.ConstraintError -> {:error, :eexist}
  end

  defp apply_ticket_link(_item, _org_id, _op), do: {:error, :eio}

  defp apply_ticket_unlink(item, org_id, %{"target" => ref} = op) when is_binary(ref) do
    with {:ok, target} <- resolve_ticket_ref(ref, org_id) do
      case Tickets.unlink(item.id, target.id, op["type"] || "relates_to") do
        {:ok, _} -> :ok
        {:error, :not_found} -> {:error, :enoent}
        {:error, _} -> {:error, :eio}
      end
    end
  end

  defp apply_ticket_unlink(_item, _org_id, _op), do: {:error, :eio}

  defp apply_entity_link(item, %{"entity_type" => et, "entity_id" => eid} = op)
       when is_binary(et) and is_binary(eid) do
    opts = [
      link_type: op["link_type"] || "relates_to",
      metadata: op["metadata"] || %{}
    ]

    case Links.link_entity(item.id, et, eid, opts) do
      {:ok, _} -> :ok
      {:error, %Ecto.Changeset{}} -> {:error, :eexist}
      {:error, _} -> {:error, :eio}
    end
  end

  defp apply_entity_link(_item, _op), do: {:error, :eio}

  defp apply_entity_unlink(item, %{"entity_type" => et, "entity_id" => eid} = op)
       when is_binary(et) and is_binary(eid) do
    opts = [link_type: op["link_type"] || "relates_to"]

    case Links.unlink_entity(item.id, et, eid, opts) do
      {:ok, _} -> :ok
      {:error, :not_found} -> {:error, :enoent}
      {:error, _} -> {:error, :eio}
    end
  end

  defp apply_entity_unlink(_item, _op), do: {:error, :eio}

  defp resolve_ticket_ref(ref, org_id) do
    case Tickets.get_by_ref(ref, org_id) do
      {:ok, item} -> {:ok, item}
      _ -> {:error, :enoent}
    end
  end

  # ── payload shaping ───────────────────────────────────────────────────────

  defp decode(data) do
    case Jason.decode(data) do
      {:ok, doc} when is_map(doc) -> {:ok, doc}
      _ -> {:error, :eio}
    end
  end

  # Field projections accept ANY JSON value (scalar, array, object).
  defp decode_value(data) do
    case Jason.decode(data) do
      {:ok, value} -> {:ok, value}
      _ -> {:error, :eio}
    end
  end

  defp valid_title?(doc), do: is_binary(doc["title"]) and doc["title"] != ""
  defp valid_name?(doc), do: is_binary(doc["name"]) and doc["name"] != ""

  defp ticket_attrs(doc, org_id) do
    doc
    |> take(
      ~w(title description ticket_type status priority assignee reporter queue_id parent_id project_id custom_fields tags)
    )
    |> Map.put("organization_id", org_id)
    |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
    |> Map.put_new(:ticket_type, "task")
  end

  # record.json is the canonical write target; a write merges the supplied
  # top-level fields (absent fields untouched, §3.4).
  defp record_attrs(doc, org) do
    doc
    |> take(
      ~w(title description status priority assignee reporter queue_id parent_id stage_id iteration_id custom_fields tags)
    )
    |> Map.put("organization_id", org_id!(org) |> elem(1))
    |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp definition_attrs(doc, keys) do
    doc |> take(keys) |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp take(doc, keys) do
    doc |> Map.take(keys) |> Enum.reject(fn {_k, v} -> is_nil(v) end) |> Map.new()
  end

  defp create_ticket(attrs) do
    case Tickets.create(attrs) do
      {:ok, item} -> {:ok, item}
      {:error, _} -> {:error, :eio}
    end
  end

  # ── node helpers ──────────────────────────────────────────────────────────

  defp queue_file?(name), do: is_binary(name) and String.ends_with?(name, ".json")
  defp queue_feed?(name), do: is_binary(name) and String.ends_with?(name, ".feed.log")

  defp queue_slug(name, suffix), do: binary_part(name, 0, byte_size(name) - byte_size(suffix))

  defp queue_exists?(name, org_id),
    do:
      not is_nil(
        Queues.get(
          queue_slug(name, if(queue_file?(name), do: ".json", else: ".feed.log")),
          org_id,
          nil
        )
      )

  defp queue_node(name, org_id) do
    if queue_exists?(name, org_id), do: {:ok, file_node(0)}, else: {:error, :enoent}
  end

  defp slug_part(file) do
    case String.split(file, ".json") do
      [slug, ""] when byte_size(slug) > 0 -> slug
      _ -> nil
    end
  end

  defp slug_of(file), do: slug_part(file) || file

  defp safe_name?(name) do
    String.match?(name, ~r/^[A-Za-z0-9][A-Za-z0-9._-]*$/) and not String.contains?(name, "..")
  end

  defp field_value(item, file) do
    case slug_part(file) do
      nil -> nil
      slug -> custom_fields(item)[slug]
    end
  end

  defp custom_fields(item), do: Map.get(item, :custom_fields) || %{}

  defp comment_by_name(ticket_id, name) do
    comment_rows(ticket_id)
    |> Enum.find(&(comment_name(&1) == name))
  end

  defp comment_rows(ticket_id), do: rows_or_empty(Comment.list("ticket", ticket_id))

  defp attachment_by_name(ticket_id, name) do
    attachment_rows(ticket_id)
    |> Enum.find(&(attachment_name(&1) == name))
  end

  defp attachment_rows(ticket_id), do: rows_or_empty(Attach.list("ticket", ticket_id))

  # Canonical server-assigned node names (`{ts}-{short8}.json`, §1.1).
  defp comment_name(c), do: "#{ts_safe(c.inserted_at)}-#{short8(c.id)}.json"

  defp attachment_name(a),
    do: "#{sanitize(Map.get(a, :artifact_type) || "file")}-#{short8(a.id)}.json"

  defp sanitize(bin), do: String.replace(String.downcase(bin), ~r/[^a-z0-9]+/, "_")

  defp ticket_xattrs(item) do
    %{
      "key" => item.key,
      "id" => item.id,
      "item_type" => Map.get(item, :item_type),
      "status" => Map.get(item, :status)
    }
  end

  # Entries are wire-shaped (no xattrs — stat carries those).
  defp key_entry(item), do: dir_entry(item.key)

  defp dir_entry(name),
    do: %{name: name, type: :dir, size: 0, mtime: now_ms(), version: version()}

  defp file_entry(name),
    do: %{name: name, type: :file, size: 0, mtime: now_ms(), version: version()}

  defp dir_node, do: %VFS{type: :dir, mtime: now_ms(), version: version()}

  defp file_node(size, mtime \\ nil),
    do: %VFS{
      type: :file,
      size: size,
      mtime: mtime || now_ms(),
      version: version(),
      writable: true
    }

  defp ticket_mtime(item), do: ts_ms(Map.get(item, :updated_at) || Map.get(item, :inserted_at))

  # Content versions are flat; the dispatcher stamps its cache generation on
  # top (Root's Wave-0 pattern — out-of-band mutations ride the TTL).
  defp version, do: 1
  defp now_ms, do: System.os_time(:millisecond)

  # ── time helpers ──────────────────────────────────────────────────────────

  defp ts_ms(%DateTime{} = dt), do: DateTime.to_unix(dt, :millisecond)
  defp ts_ms(_), do: now_ms()

  defp ms_to_dt(ms), do: DateTime.from_unix!(ms, :millisecond)

  # `2026-09-05T12-00-01Z` — filesystem-safe (no colons), per §1.1.
  defp ts_safe(%DateTime{} = dt) do
    dt
    |> DateTime.truncate(:second)
    |> DateTime.to_iso8601()
    |> String.replace(":", "-")
  end

  defp ts_iso(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp ts_iso(other), do: other

  defp short8(id) when is_binary(id) and byte_size(id) >= 8, do: binary_part(id, 0, 8)
  defp short8(id) when is_binary(id), do: id
  defp short8(other), do: other

  defp first_line(nil), do: nil

  defp first_line(text) when is_binary(text) do
    text
    |> String.split("\n", parts: 2)
    |> List.first()
    |> String.slice(0, 120)
  end
end
