defmodule NoizuPromptLingua.Domains.Tickets.PMBridge do
  @moduledoc """
  Bridge from NPL `Ticket` domain → the TRP shared-key items API
  (`/api/v1/organizations/:org_id/items`, docs/api/shared-key-api.md §4.3).

  One data path: TRP over `NoizuPromptLingua.TRP` (client + ETS cache,
  write-bust). `ticket_type` stays an alias of `item_type` for MCP/HTTP
  compatibility (W0 spec §4.3 — aliasing is an NPL-side concern).
  """

  alias NoizuPromptLingua.TRP

  @fetch_cap 1000

  @doc "Create via TRP. Requires `:organization_id` (TRP items are org-scoped by path)."
  def create(attrs) when is_map(attrs) do
    org(attrs) |> do_create(attrs)
  end

  @doc "Get via TRP (UUID or human key). The org is resolved from the TRP key scope."
  def get(id) when is_binary(id) do
    with_org(fn org -> TRP.get_item(org, id) end)
  end

  @doc "Get by human key (org-scoped) via TRP."
  def get_by_key(org_id, key) when is_binary(org_id) and is_binary(key) do
    case TRP.get_item(org_id, key) do
      map when is_map(map) -> map
      nil -> nil
      {:error, _} = err -> err
    end
  end

  @doc "Update via TRP. Org from attrs or the TRP key scope (legacy bare-id callers)."
  def update(id, attrs) when is_binary(id) and is_map(attrs) do
    case org(attrs) do
      nil -> with_org(fn o -> do_update(o, id, attrs) end)
      org_id -> do_update(org_id, id, attrs)
    end
  end

  @doc """
  List via TRP. Maps ticket_type filter → item_type; org from opts or key scope.

  TRP v1's filter contract is scalar-only, so several facets apply client-side
  over the fetched page (3c2d6bbe semantics preserved: OR within facet, AND
  across facets):
    * list-valued opts (`status: ["open", "closed"]`) — `in` filter;
    * `:tag` (scalar or list) — membership in the item's `tags`;
    * `:updated_after` / `:updated_before` (ISO8601 binary or DateTime) —
      inclusive range on `updated_at`;
    * `:sort` (updated_at|created_at|priority|status|title|id) + `:dir`
      (:asc | :desc, default :desc).

  W6 cache rule: whenever any client-side post-filter/sort is in play, the
  fetch bypasses the 30s ETS cache (`TRP.list_items(..., cache: false)`) and
  windows with an internal fetch cap instead of the caller's limit/offset —
  the caller's page is sliced AFTER filtering/sorting, and never over a stale
  shard. Plain scalar-only queries keep the cached server-side path unchanged.
  """
  def list(opts) when is_list(opts) do
    opts =
      case Keyword.pop(opts, :ticket_type) do
        {nil, o} -> o
        {type, o} -> Keyword.put(o, :item_type, type)
      end

    # NB: pop W6 opts BEFORE the list-facet split — a list-valued `:tag` is a
    # tag facet, not a row-field facet (fields are matched via Map.get).
    {tag, opts} = Keyword.pop(opts, :tag)
    {after_ts, opts} = Keyword.pop(opts, :updated_after)
    {before_ts, opts} = Keyword.pop(opts, :updated_before)
    {sort, opts} = Keyword.pop(opts, :sort)
    {dir, opts} = Keyword.pop(opts, :dir)
    # `:sort_dir` is the tool-layer spelling of `:dir` — accept either.
    {sort_dir, opts} = Keyword.pop(opts, :sort_dir)
    dir = dir || sort_dir

    # Client-side ops (list facets + W6 tag/date/sort) vs server-side passthrough.
    {list_filters, opts} = Enum.split_with(opts, fn {_k, v} -> is_list(v) end)
    {org_id, opts} = Keyword.pop(opts, :organization_id)

    client_side? =
      list_filters != [] or not is_nil(tag) or not is_nil(after_ts) or
        not is_nil(before_ts) or not is_nil(sort)

    with_org(org_id, fn org ->
      if client_side? do
        # Server window would truncate before our filter — fetch a full capped
        # page fresh, post-process, then slice the caller's page client-side.
        offset = Keyword.get(opts, :offset) || 0
        limit = Keyword.get(opts, :limit) || @fetch_cap

        opts =
          opts
          |> Keyword.drop([:limit, :offset])
          |> Keyword.put(:limit, @fetch_cap)
          |> Keyword.put(:cache, false)

        case TRP.list_items(org, opts) do
          rows when is_list(rows) ->
            rows
            |> apply_list_filters(list_filters)
            |> apply_tag_filter(tag)
            |> apply_date_range(after_ts, before_ts)
            |> apply_sort(sort, dir)
            |> Enum.drop(offset)
            |> Enum.take(limit)

          {:error, _} = err ->
            err
        end
      else
        case TRP.list_items(org, opts) do
          rows when is_list(rows) -> rows
          {:error, _} = err -> err
        end
      end
    end)
  end

  defp apply_list_filters(rows, []), do: rows

  defp apply_list_filters(rows, [{facet, values} | rest]) do
    if values == [] do
      # empty list is a no-op (not match-nothing)
      apply_list_filters(rows, rest)
    else
      rows
      |> Enum.filter(&(Map.get(&1, facet) in values))
      |> apply_list_filters(rest)
    end
  end

  # ── W6 client-side ops ────────────────────────────────────────

  # `:tag` — scalar or list; a comma-separated scalar ("a,b") expands to OR.
  # Membership in the item's tags; blank = no-op.
  defp apply_tag_filter(rows, nil), do: rows
  defp apply_tag_filter(rows, []), do: rows
  defp apply_tag_filter(rows, ""), do: rows

  defp apply_tag_filter(rows, tag) when is_binary(tag) do
    tags =
      tag
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1)

    apply_tag_filter(rows, tags)
  end

  defp apply_tag_filter(rows, tags) when is_list(tags) do
    Enum.filter(rows, fn row ->
      row_tags = Map.get(row, :tags) || []
      Enum.any?(tags, &(&1 in row_tags))
    end)
  end

  # Inclusive updated_at range; either bound optional. Accepts ISO8601
  # binaries (wire shape) and DateTime structs (stub/decode shapes).
  defp apply_date_range(rows, nil, nil), do: rows

  defp apply_date_range(rows, after_ts, before_ts) do
    lo = parse_dt(after_ts)
    hi = parse_dt(before_ts)

    Enum.filter(rows, fn row ->
      ts = parse_dt(Map.get(row, :updated_at))

      ts != nil and (lo == nil or DateTime.compare(ts, lo) != :lt) and
        (hi == nil or DateTime.compare(ts, hi) != :gt)
    end)
  end

  defp parse_dt(%DateTime{} = dt), do: dt
  defp parse_dt(nil), do: nil

  defp parse_dt(bin) when is_binary(bin) do
    case DateTime.from_iso8601(bin) do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end

  defp parse_dt(_), do: nil

  @sort_fields [:updated_at, :created_at, :inserted_at, :priority, :status, :title, :id]

  # Sort client-side. Unknown/blank field = no-op (caller keeps the facade's
  # inserted_at desc). `dir` accepts :asc/:desc or "asc"/"desc" (default desc).
  defp apply_sort(rows, nil, _dir), do: rows
  defp apply_sort(rows, "", _dir), do: rows

  defp apply_sort(rows, sort, dir) when is_binary(sort),
    do: apply_sort(rows, safe_atom(sort), dir)

  defp apply_sort(rows, field, dir) when field in @sort_fields do
    # Default direction is desc (matches the facade's legacy inserted_at desc).
    descending = dir not in [:asc, "asc"]
    # Unset values sort last regardless of direction (epoch key for datetimes,
    # "" for strings) so pages stay stable across asc/desc.
    keyfn = fn row ->
      case Map.get(row, field) do
        %DateTime{} = dt -> DateTime.to_unix(dt)
        nil -> if field in [:updated_at, :created_at, :inserted_at], do: 0, else: ""
        v -> v
      end
    end

    Enum.sort_by(rows, keyfn, if(descending, do: :desc, else: :asc))
  end

  defp apply_sort(rows, _unknown, _dir), do: rows

  defp safe_atom(bin) do
    String.to_existing_atom(bin)
  rescue
    ArgumentError -> nil
  end

  # ── internals ─────────────────────────────────────────────────

  defp do_create({:error, _} = err, _attrs), do: err

  defp do_create(org_id, attrs) do
    item_attrs =
      attrs
      |> drop_keys([:ticket_type, "ticket_type"])
      |> Map.put(:item_type, ticket_type(attrs))
      |> drop_keys([:organization_id, "organization_id"])

    case TRP.create_item(org_id, item_attrs) do
      {:ok, ticket} -> {:ok, ticket}
      {:error, _} = err -> err
    end
  end

  defp do_update({:error, _} = err, _id, _attrs), do: err

  defp do_update(org_id, id, attrs) do
    item_attrs =
      attrs
      |> drop_keys([:ticket_type, "ticket_type"])
      |> Map.put(:item_type, ticket_type(attrs))
      |> drop_keys([:organization_id, "organization_id"])

    case TRP.update_item(org_id, id, item_attrs) do
      {:ok, ticket} -> {:ok, ticket}
      {:error, _} = err -> err
    end
  end

  defp ticket_type(attrs) do
    Map.get(attrs, :ticket_type) || Map.get(attrs, "ticket_type") ||
      Map.get(attrs, :item_type) || Map.get(attrs, "item_type") || "task"
  end

  defp org(attrs) do
    Map.get(attrs, :organization_id) || Map.get(attrs, "organization_id")
  end

  # Run when the org is known; falls back to the TRP key-scope org list.
  defp with_org(fun) when is_function(fun, 1), do: with_org(nil, fun)

  # NB: a single `and` — two `when`s would be guard ALTERNATION (or), silently
  # ignoring the caller's org for every non-nil org_id.
  defp with_org(org_id, fun) when is_function(fun, 1) and org_id in [nil, ""] do
    case key_scope_orgs() do
      {:error, _} = err -> err
      orgs -> first_ok(orgs, fun)
    end
  end

  defp with_org(org_id, fun) when is_function(fun, 1), do: fun.(org_id)

  # Legacy pm_bridge resolved items globally; TRP scopes items by org path, so
  # org-less reads walk the key scope. Cached (30s) and bounded in practice.
  defp key_scope_orgs do
    case TRP.list_organizations() do
      list when is_list(list) -> Enum.map(list, & &1.id)
      {:error, _} = err -> err
      # TRP fail-softs to nil (404-mapped org list, or transport failure with no
      # stale cache) — surface backend-down instead of crashing the callers'
      # case/reduce with a CaseClauseError 500 (fix/error-family).
      _ -> {:error, :trp_not_configured}
    end
  end

  defp first_ok(orgs, fun) do
    Enum.reduce_while(orgs, nil, fn org, _acc ->
      case fun.(org) do
        nil -> {:cont, nil}
        {:error, %NoizuPromptLingua.TRP.Error{status: 404}} -> {:cont, nil}
        value -> {:halt, value}
      end
    end)
  end

  defp drop_keys(map, keys), do: Map.drop(map, keys)
end
