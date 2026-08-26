defmodule NoizuPromptLingua.Domains.Tickets.PMBridge do
  @moduledoc """
  Bridge from NPL `Ticket` domain → shared `Noizu.PM.Items`.

  Always uses pm_core (`Noizu.PM.Repo`). There is no app-DB legacy path for tickets.

  - `create/1` → `Noizu.PM.Items.create/1` with `ticket_type` mapped to `item_type`
  - `get/1`, `update/2`, `list/2` similarly
  - MCP tools keep names `Ticket.*`; responses may still expose `ticket_type`
    as an alias of `item_type` for agent compatibility
  """

  alias NoizuPromptLingua.PMCore

  @doc "Create via pm_core."
  def create(attrs) when is_map(attrs) do
    PMCore.with_pm(fn ->
      item_attrs = PMCore.ticket_attrs_to_item(attrs)

      case Noizu.PM.Items.create(item_attrs) do
        {:ok, item} -> {:ok, item_to_ticket_shape(item)}
        other -> other
      end
    end)
  end

  @doc "Get via pm_core."
  def get(id) when is_binary(id) do
    PMCore.with_pm(fn ->
      case Noizu.PM.Items.get(id) do
        nil -> nil
        item -> item_to_ticket_shape(item)
      end
    end)
  end

  @doc "Get by human key (org-scoped) via pm_core."
  def get_by_key(org_id, key) when is_binary(org_id) and is_binary(key) do
    PMCore.with_pm(fn ->
      case Noizu.PM.Items.get_by_key(org_id, key) do
        nil -> nil
        item -> item_to_ticket_shape(item)
      end
    end)
  end

  @doc "Update via pm_core."
  def update(id, attrs) when is_binary(id) and is_map(attrs) do
    PMCore.with_pm(fn ->
      item_attrs = PMCore.ticket_attrs_to_item(attrs)

      case Noizu.PM.Items.update(id, item_attrs) do
        {:ok, item} -> {:ok, item_to_ticket_shape(item)}
        other -> other
      end
    end)
  end

  @doc "List via pm_core. Maps ticket_type filter → item_type."
  def list(opts) when is_list(opts) do
    PMCore.with_pm(fn ->
      opts =
        case Keyword.pop(opts, :ticket_type) do
          {nil, o} -> o
          {type, o} -> Keyword.put(o, :item_type, type)
        end

      Noizu.PM.Items.list(opts)
      |> Enum.map(&item_to_ticket_shape/1)
    end)
  end

  # Present shared items with ticket-oriented field names for MCP/HTTP callers.
  defp item_to_ticket_shape(%{__struct__: _} = item) do
    item
    |> Map.from_struct()
    |> Map.drop([:__meta__])
    |> then(fn m ->
      type = Map.get(m, :item_type)

      m
      |> Map.put(:ticket_type, type)
      |> Map.put(:item_type, type)
    end)
  end

  defp item_to_ticket_shape(item) when is_map(item) do
    type = Map.get(item, :item_type) || Map.get(item, "item_type")

    item
    |> Map.put(:ticket_type, type)
    |> Map.put("ticket_type", type)
  end
end
