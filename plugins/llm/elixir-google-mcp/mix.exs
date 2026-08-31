defmodule Noizu.Google.MCP.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/noizu-labs/elixir-google-mcp"
  @hexdocs_url "https://hexdocs.pm/noizu_google_mcp"

  def project do
    [
      app: :noizu_google_mcp,
      name: "Noizu Google MCP",
      description: description(),
      package: package(),
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      source_url: @source_url,
      homepage_url: @hexdocs_url,
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [summary: [threshold: 0]]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Noizu.Google.MCP.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp noizu_google_dep do
    sibling = Path.expand("../../api/elixir-google", __DIR__)

    if File.dir?(Path.join(sibling, "lib")) do
      {:noizu_google, path: sibling, override: true}
    else
      {:noizu_google, "~> 0.2.4"}
    end
  end

  defp deps do
    [
      {:noizu_mcp, "~> 0.1.5"},
      noizu_google_dep(),
      {:jason, "~> 1.4"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  # Hex.pm description: a short paragraph, max 300 characters.
  defp description do
    """
    MCP server for Google marketing APIs. Stdio Model Context Protocol tools for Search Console, GA4 Admin/Data, AdSense, and Google Ads, backed by :noizu_google.
    """
    |> String.trim()
  end

  defp package do
    [
      name: "noizu_google_mcp",
      licenses: ["MIT"],
      maintainers: ["Keith Brings"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md",
        "HexDocs" => @hexdocs_url,
        "MCP Specification" => "https://modelcontextprotocol.io",
        "Noizu Google" => "https://hex.pm/packages/noizu_google",
        "Noizu MCP" => "https://hex.pm/packages/noizu_mcp",
        "Search Console API" => "https://developers.google.com/webmaster-tools",
        "Analytics Admin API" =>
          "https://developers.google.com/analytics/devguides/config/admin/v1",
        "Analytics Data API" =>
          "https://developers.google.com/analytics/devguides/reporting/data/v1",
        "AdSense Management API" => "https://developers.google.com/adsense/management",
        "Google Ads API" => "https://developers.google.com/google-ads/api/docs/start",
        "Noizu Labs" => "https://github.com/noizu-labs"
      },
      files: ~w(
        lib
        bin
        .formatter.exs
        .mcp.json.example
        mix.exs
        README.md
        LICENSE
        CHANGELOG.md
      )
    ]
  end

  defp docs do
    [
      main: "readme",
      authors: ["Keith Brings"],
      source_ref: "v#{@version}",
      source_url: @source_url,
      homepage_url: @hexdocs_url,
      extras: [
        "README.md",
        "CHANGELOG.md"
      ],
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"],
      nest_modules_by_prefix: [
        Noizu.Google.MCP.Tools.SearchConsole,
        Noizu.Google.MCP.Tools.Analytics,
        Noizu.Google.MCP.Tools.AdSense,
        Noizu.Google.MCP.Tools.Ads
      ],
      groups_for_modules: [
        Core: [
          Noizu.Google.MCP,
          Noizu.Google.MCP.Application,
          Noizu.Google.MCP.Auth,
          Noizu.Google.MCP.Writes
        ],
        "Tools — Search Console": [
          Noizu.Google.MCP.Tools.SearchConsole.SitesList,
          Noizu.Google.MCP.Tools.SearchConsole.SitesGet,
          Noizu.Google.MCP.Tools.SearchConsole.SitesAdd,
          Noizu.Google.MCP.Tools.SearchConsole.SitesDelete,
          Noizu.Google.MCP.Tools.SearchConsole.SearchAnalyticsQuery,
          Noizu.Google.MCP.Tools.SearchConsole.SitemapsList,
          Noizu.Google.MCP.Tools.SearchConsole.SitemapsSubmit,
          Noizu.Google.MCP.Tools.SearchConsole.SitemapsDelete
        ],
        "Tools — Analytics (GA4)": [
          Noizu.Google.MCP.Tools.Analytics.PropertiesList,
          Noizu.Google.MCP.Tools.Analytics.PropertiesGet,
          Noizu.Google.MCP.Tools.Analytics.DataStreamsList,
          Noizu.Google.MCP.Tools.Analytics.RunReport
        ],
        "Tools — AdSense": [
          Noizu.Google.MCP.Tools.AdSense.AccountsList,
          Noizu.Google.MCP.Tools.AdSense.AdUnitsList,
          Noizu.Google.MCP.Tools.AdSense.ReportsGenerate
        ],
        "Tools — Google Ads": [
          Noizu.Google.MCP.Tools.Ads.ListCampaigns,
          Noizu.Google.MCP.Tools.Ads.ListConversionActions,
          Noizu.Google.MCP.Tools.Ads.Mutate,
          Noizu.Google.MCP.Tools.Ads.CreateConversionAction
        ]
      ]
    ]
  end
end
