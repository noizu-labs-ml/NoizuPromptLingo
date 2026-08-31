defmodule Noizu.Google.MCP.Writes do
  @moduledoc """
  Gate for mutating MCP tools.

  Read tools are granted by default. Write tools are listed and callable
  only when `GOOGLE_MCP_WRITES=1`. Ads mutates still default to `dry_run`
  and require `confirm=true` for live applies.
  """

  @write_modules [
    Noizu.Google.MCP.Tools.SearchConsole.SitesAdd,
    Noizu.Google.MCP.Tools.SearchConsole.SitesDelete,
    Noizu.Google.MCP.Tools.SearchConsole.SitemapsSubmit,
    Noizu.Google.MCP.Tools.SearchConsole.SitemapsDelete,
    Noizu.Google.MCP.Tools.Ads.Mutate,
    Noizu.Google.MCP.Tools.Ads.CreateConversionAction
  ]

  @write_names MapSet.new([
                 "SearchConsole.SitesAdd",
                 "SearchConsole.SitesDelete",
                 "SearchConsole.SitemapsSubmit",
                 "SearchConsole.SitemapsDelete",
                 "Ads.Mutate",
                 "Ads.CreateConversionAction"
               ])

  @doc "True when `GOOGLE_MCP_WRITES` is `1` / `true` / `yes`."
  @spec enabled?() :: boolean()
  def enabled? do
    case System.get_env("GOOGLE_MCP_WRITES") do
      v when v in ["1", "true", "TRUE", "yes", "YES"] -> true
      _ -> false
    end
  end

  @doc "True when `name` is a write tool."
  @spec write_tool?(String.t()) :: boolean()
  def write_tool?(name) when is_binary(name), do: MapSet.member?(@write_names, name)

  @doc "True when `module` implements a write tool."
  @spec write_module?(module()) :: boolean()
  def write_module?(module) when is_atom(module), do: module in @write_modules

  @doc "Error text when a write tool is called with writes disabled."
  @spec disabled_message(String.t()) :: String.t()
  def disabled_message(name) when is_binary(name) do
    "write tool #{name} is disabled; set GOOGLE_MCP_WRITES=1 to enable writes"
  end
end
