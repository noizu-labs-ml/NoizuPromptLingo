defmodule Noizu.Google.MCP.WritesTest do
  use ExUnit.Case, async: false
  import Noizu.MCP.Test

  alias Noizu.Google.MCP.Writes

  @read_tools [
    "SearchConsole.SitesList",
    "SearchConsole.SitesGet",
    "SearchConsole.SearchAnalyticsQuery",
    "SearchConsole.SitemapsList",
    "Analytics.PropertiesList",
    "Analytics.PropertiesGet",
    "Analytics.DataStreamsList",
    "Analytics.RunReport",
    "AdSense.AccountsList",
    "AdSense.AdUnitsList",
    "AdSense.ReportsGenerate",
    "Ads.ListCampaigns",
    "Ads.ListConversionActions"
  ]

  @write_tools [
    "SearchConsole.SitesAdd",
    "SearchConsole.SitesDelete",
    "SearchConsole.SitemapsSubmit",
    "SearchConsole.SitemapsDelete",
    "Ads.Mutate",
    "Ads.CreateConversionAction"
  ]

  setup do
    previous = System.get_env("GOOGLE_MCP_WRITES")
    System.delete_env("GOOGLE_MCP_WRITES")

    on_exit(fn ->
      if previous,
        do: System.put_env("GOOGLE_MCP_WRITES", previous),
        else: System.delete_env("GOOGLE_MCP_WRITES")
    end)

    :ok
  end

  test "enabled? is false unless GOOGLE_MCP_WRITES=1" do
    System.delete_env("GOOGLE_MCP_WRITES")
    refute Writes.enabled?()

    System.put_env("GOOGLE_MCP_WRITES", "0")
    refute Writes.enabled?()

    System.put_env("GOOGLE_MCP_WRITES", "1")
    assert Writes.enabled?()

    System.put_env("GOOGLE_MCP_WRITES", "true")
    assert Writes.enabled?()
  end

  test "lists only read tools by default" do
    client = connect(Noizu.Google.MCP)
    assert {:ok, tools} = list_tools(client)
    names = Enum.map(tools, & &1.name) |> Enum.sort()

    assert Enum.sort(@read_tools) == names

    for name <- @write_tools do
      refute name in names
    end
  end

  test "rejects write tools when the flag is off" do
    client = connect(Noizu.Google.MCP)

    assert {:ok, result} =
             call_tool(client, "SearchConsole.SitesAdd", %{"site_url" => "https://example.com/"})

    assert result.is_error
    assert [%{type: :text, text: text}] = result.content
    assert text =~ "GOOGLE_MCP_WRITES=1"
  end

  test "lists write tools when GOOGLE_MCP_WRITES=1" do
    System.put_env("GOOGLE_MCP_WRITES", "1")
    client = connect(Noizu.Google.MCP)
    assert {:ok, tools} = list_tools(client)
    names = Enum.map(tools, & &1.name)

    for name <- @read_tools ++ @write_tools do
      assert name in names
    end
  end

  test "Ads mutate still requires confirm for live applies when writes are on" do
    System.put_env("GOOGLE_MCP_WRITES", "1")
    client = connect(Noizu.Google.MCP)

    assert {:ok, result} =
             call_tool(client, "Ads.Mutate", %{
               "customer_id" => "123",
               "mutate_operations_json" => "[]",
               "dry_run" => false
             })

    assert result.is_error
    assert [%{type: :text, text: text}] = result.content
    assert text =~ "confirm=true"
  end
end
