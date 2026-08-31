defmodule Noizu.Google.MCP do
  @moduledoc """
  MCP server for Google marketing APIs (Search Console, GA4, AdSense, Ads).

  Speaks MCP over **stdio** when started via the application (`mix run --no-halt`).

  Auth: set `GOOGLE_ACCESS_TOKEN`, a service-account JSON path
  (`GOOGLE_APPLICATION_CREDENTIALS`), or the OAuth refresh trio
  (`GOOGLE_REFRESH_TOKEN` + `GOOGLE_CLIENT_ID` + `GOOGLE_CLIENT_SECRET`).
  `GOOGLE_MARKETING_*` aliases are accepted for the user-OAuth keys.

  See the [README](readme.html) for the tool table, client install, and
  `start_stdio` embedding notes.

  Read tools are granted by default. Write tools require `GOOGLE_MCP_WRITES=1`.
  Ads mutates still default to `dry_run` and need `confirm=true` for live applies.
  """

  use Noizu.MCP.Server,
    name: "noizu_google",
    version: "0.1.1",
    instructions: """
    Manage and query Google marketing products via the Noizu Google client.

    Read tools are granted by default. Write tools (Search Console add/delete
    site or sitemap, Ads mutate / create conversion action) are listed and
    callable only when GOOGLE_MCP_WRITES=1. Ads live applies still need
    dry_run=false and confirm=true.

    Search Console tools (category SearchConsole):
    - SearchConsole.SitesList / SitesGet — list or get a property
    - SearchConsole.SearchAnalyticsQuery — performance report
    - SearchConsole.SitemapsList — list submitted sitemaps

    Analytics tools (category Analytics):
    - Analytics.PropertiesList / PropertiesGet — GA4 Admin properties
    - Analytics.DataStreamsList — streams for a property
    - Analytics.RunReport — GA4 Data API report

    Prefer read-only tools unless the user explicitly asks to mutate.
    Credentials come from process environment / application config.
    """

  tool(Noizu.Google.MCP.Tools.SearchConsole.SitesList, category: "SearchConsole")
  tool(Noizu.Google.MCP.Tools.SearchConsole.SitesGet, category: "SearchConsole")
  tool(Noizu.Google.MCP.Tools.SearchConsole.SitesAdd, category: "SearchConsole")
  tool(Noizu.Google.MCP.Tools.SearchConsole.SitesDelete, category: "SearchConsole")
  tool(Noizu.Google.MCP.Tools.SearchConsole.SearchAnalyticsQuery, category: "SearchConsole")
  tool(Noizu.Google.MCP.Tools.SearchConsole.SitemapsList, category: "SearchConsole")
  tool(Noizu.Google.MCP.Tools.SearchConsole.SitemapsSubmit, category: "SearchConsole")
  tool(Noizu.Google.MCP.Tools.SearchConsole.SitemapsDelete, category: "SearchConsole")

  tool(Noizu.Google.MCP.Tools.Analytics.PropertiesList, category: "Analytics")
  tool(Noizu.Google.MCP.Tools.Analytics.PropertiesGet, category: "Analytics")
  tool(Noizu.Google.MCP.Tools.Analytics.DataStreamsList, category: "Analytics")
  tool(Noizu.Google.MCP.Tools.Analytics.RunReport, category: "Analytics")

  tool(Noizu.Google.MCP.Tools.AdSense.AccountsList, category: "AdSense")
  tool(Noizu.Google.MCP.Tools.AdSense.AdUnitsList, category: "AdSense")
  tool(Noizu.Google.MCP.Tools.AdSense.ReportsGenerate, category: "AdSense")

  tool(Noizu.Google.MCP.Tools.Ads.ListCampaigns, category: "Ads")
  tool(Noizu.Google.MCP.Tools.Ads.ListConversionActions, category: "Ads")
  tool(Noizu.Google.MCP.Tools.Ads.Mutate, category: "Ads")
  tool(Noizu.Google.MCP.Tools.Ads.CreateConversionAction, category: "Ads")

  @impl true
  def handle_list_tools(cursor, _ctx) do
    Noizu.MCP.Server.Features.Tools.list_registered(visible_tools(), cursor)
  end

  @impl true
  def handle_call_tool(name, args, ctx) do
    if not Noizu.Google.MCP.Writes.enabled?() and Noizu.Google.MCP.Writes.write_tool?(name) do
      {:error, Noizu.Google.MCP.Writes.disabled_message(name)}
    else
      Noizu.MCP.Server.Features.Tools.dispatch(__mcp__(:tools), name, args, ctx)
    end
  end

  defp visible_tools do
    tools = __mcp__(:tools)

    if Noizu.Google.MCP.Writes.enabled?() do
      tools
    else
      Enum.reject(tools, fn {mod, _opts} -> Noizu.Google.MCP.Writes.write_module?(mod) end)
    end
  end
end
