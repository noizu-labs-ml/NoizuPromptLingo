defmodule NoizuPromptLingua.Domains.Tickets.PMBridge do
  @moduledoc """
  Optional bridge from NPL `Ticket` domain → shared `Noizu.PM.Items`.

  Active only when `NoizuPromptLingua.PMCore.enabled?/0`. Until cutover, every
  public function returns `:legacy` and the caller uses local `tickets` tables.

  Shape after cutover:
  - `create/1` → `Noizu.PM.Items.create/1` with `ticket_type` mapped to `item_type`
  - `get/1`, `update/2`, `list/2` similarly
  - MCP tools keep names `Ticket.*`; responses may still expose `ticket_type`
    as an alias of `item_type` for agent compatibility
  """

  alias NoizuPromptLingua.PMCore

  @doc "Create via pm_core or `:legacy`."
  def create(attrs) when is_map(attrs) do
    PMCore.with_pm(fn ->
      item_attrs = PMCore.ticket_attrs_to_item(attrs)

      case Noizu.PM.Items.create(item_attrs) do
        {:ok, item} -> {:ok, item_to_ticket_shape(item)}
        other -> other
      end
    end)
  end

  @doc "Get via pm_core or `:legacy`."
  def get(id) when is_binary(id) do
    PMCore.with_pm(fn ->
      case Noizu.PM.Items.get(id) do
        nil -> nil
        item -> item_to_ticket_shape(item)
      end
    end)
  end

  @doc "Update via pm_core or `:legacy`."
  def update(id, attrs) when is_binary(id) and is_map(attrs) do
    PMCore.with_pm(fn ->
      item_attrs = PMCore.ticket_attrs_to_item(attrs)

      case Noizu.PM.Items.update(id, item_attrs) do
        {:ok, item} -> {:ok, item_to_ticket_shape(item)}
        other -> other
      end
    end)
  end

  @doc "List via pm_core or `:legacy`. Maps ticket_type filter → item_type."
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
