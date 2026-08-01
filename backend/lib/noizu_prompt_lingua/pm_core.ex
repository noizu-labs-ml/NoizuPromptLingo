defmodule NoizuPromptLingua.PMCore do
  @moduledoc """
  Shared `pm_core` data layer (`:noizu_labs_pm`).

  **Always-on mode** until `pm_core` is extracted as a microservice.
  Domain code for orgs/projects/items/authz reads and writes via `Noizu.PM.Repo`.
  Local app DB remains for NPL-only tables (sessions, chat, memory, …).

  Emergency opt-out only: `PM_CORE_ENABLED=0` (or `false`). Prefer fixing the
  shared DB over running legacy split-brain.

  See monorepo `docs/pm-core-cutover.md`.
  """

  @doc """
  Whether domain code should read/write via `Noizu.PM.Repo`.

  Defaults to **true**. Set `PM_CORE_ENABLED` / config `:enabled` to `false` only
  for emergency rollback.
  """
  def enabled? do
    case Application.get_env(:noizu_prompt_lingua, :pm_core, [])[:enabled] do
      false -> false
      "false" -> false
      "0" -> false
      0 -> false
      _ -> true
    end
  end

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
  Run `fun` against shared PM when enabled and configured.

  Returns `{:legacy, reason}` only when disabled or unconfigured (dev without
  `PM_CORE_DATABASE_URL`, or emergency opt-out).
  """
  def with_pm(fun) when is_function(fun, 0) do
    cond do
      not enabled?() ->
        {:legacy, :pm_core_disabled}

      not repo_configured?() ->
        {:legacy, :pm_core_unconfigured}

      true ->
        fun.()
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
