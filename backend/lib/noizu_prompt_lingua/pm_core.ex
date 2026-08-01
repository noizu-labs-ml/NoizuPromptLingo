defmodule NoizuPromptLingua.PMCore do
  @moduledoc """
  Feature gate for the shared `pm_core` data layer (`:noizu_labs_pm`).

  When `enabled?/0` is false (default), tickets/projects/orgs stay on
  `NoizuPromptLingua.Repo`. When true, domains should map ticket_type→item_type
  and call `Noizu.PM.Items` (MCP `Ticket.*` names remain as aliases).

  See monorepo `docs/pm-core-cutover.md`.
  """

  @doc "Whether domain code should read/write via `Noizu.PM.Repo`."
  def enabled? do
    Application.get_env(:noizu_prompt_lingua, :pm_core, [])[:enabled] == true
  end

  @doc "Whether the shared repo process is expected to be running."
  def repo_configured? do
    case System.get_env("PM_CORE_DATABASE_URL") do
      url when is_binary(url) and url != "" -> true
      _ ->
        case Application.get_env(:noizu_labs_pm, Noizu.PM.Repo) do
          conf when is_list(conf) ->
            Keyword.has_key?(conf, :url) or Keyword.has_key?(conf, :database)

          _ ->
            false
        end
    end
  end

  @doc """
  Run `fun` against shared PM when enabled; otherwise return `{:legacy, reason}`.
  """
  def with_pm(fun) when is_function(fun, 0) do
    if enabled?() and repo_configured?() do
      fun.()
    else
      {:legacy, :pm_core_disabled}
    end
  end

  @doc """
  Map ticket-oriented attrs to item attrs for `Noizu.PM.Items`.
  `ticket_type` → `item_type` (default `task`).
  """
  def ticket_attrs_to_item(attrs) when is_map(attrs) do
    type =
      Map.get(attrs, :ticket_type) ||
        Map.get(attrs, "ticket_type") ||
        Map.get(attrs, :item_type) ||
        Map.get(attrs, "item_type") ||
        "task"

    attrs
    |> stringify_or_atom_drop([:ticket_type, "ticket_type"])
    |> Map.put(:item_type, type)
  end

  defp stringify_or_atom_drop(map, keys) do
    Enum.reduce(keys, map, fn k, acc -> Map.delete(acc, k) end)
  end
end
