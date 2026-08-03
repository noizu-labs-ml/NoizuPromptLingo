defmodule NoizuPromptLingua.PMCore do
  @moduledoc """
  Shared pm_core data layer. Shared orgs/projects/items/authz ALWAYS use Noizu.PM.Repo.
  No legacy app-DB dual-path. Misconfig (missing PM_CORE_DATABASE_URL) is a hard error.
  NPL-local tables (sessions, chat, memory, …) stay on the app Repo.

  See monorepo `docs/pm-core-cutover.md`.
  """

  @doc """
  Shared PM is always on. There is no opt-out / legacy mode.
  """
  def enabled?, do: true

  @doc "Whether the shared repo process is expected to be running."
  def repo_configured? do
    case System.get_env("PM_CORE_DATABASE_URL") do
      url when is_binary(url) and url != "" ->
        true

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
  Run `fun` against shared PM. Raises if `PM_CORE_DATABASE_URL` / repo config is missing.
  """
  def with_pm(fun) when is_function(fun, 0) do
    unless repo_configured?() do
      raise """
      PM_CORE_DATABASE_URL is required. Shared PM data has no legacy mode.
      Set PM_CORE_DATABASE_URL to the pm_core database.
      """
    end

    fun.()
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
