defmodule NoizuPromptLingua.Domains.Tickets.PMBridge do
  @moduledoc """
  Bridge from NPL `Ticket` domain → the TRP shared-key items API
  (`/api/v1/organizations/:org_id/items`, docs/api/shared-key-api.md §4.3).

  One data path: TRP over `NoizuPromptLingua.TRP` (client + ETS cache,
  write-bust). `ticket_type` stays an alias of `item_type` for MCP/HTTP
  compatibility (W0 spec §4.3 — aliasing is an NPL-side concern).
  """

  alias NoizuPromptLingua.TRP

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

  @doc "List via TRP. Maps ticket_type filter → item_type; org from opts or key scope."
  def list(opts) when is_list(opts) do
    opts =
      case Keyword.pop(opts, :ticket_type) do
        {nil, o} -> o
        {type, o} -> Keyword.put(o, :item_type, type)
      end

    {org_id, opts} = Keyword.pop(opts, :organization_id)

    # TRP v1's filter contract is scalar-only; multi-select list facets
    # (["open", "closed"]) are applied client-side over the fetched page
    # (3c2d6bbe semantics preserved: OR within facet, AND across facets).
    {list_filters, opts} = Enum.split_with(opts, fn {_k, v} -> is_list(v) end)

    with_org(org_id, fn org ->
      case TRP.list_items(org, opts) do
        rows when is_list(rows) -> apply_list_filters(rows, list_filters)
        {:error, _} = err -> err
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
