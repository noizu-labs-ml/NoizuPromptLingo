defmodule Noizu.MCP.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/noizu-labs/noizu-mcp"

  def project do
    [
      app: :noizu_mcp,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      name: "Noizu MCP",
      description: description(),
      package: package(),
      docs: docs(),
      source_url: @source_url,
      dialyzer: [
        plt_add_apps: [:ex_unit, :mix],
        flags: [:error_handling],
        ignore_warnings: ".dialyzer_ignore.exs"
      ],
      test_coverage: [summary: [threshold: 0]]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:jsv, "~> 0.19"},
      {:telemetry, "~> 1.2"},
      # Streamable HTTP server transport (optional — stdio-only servers don't need it)
      {:plug, "~> 1.16", optional: true},
      {:bandit, "~> 1.5", optional: true},
      # Streamable HTTP client transport
      {:req, "~> 0.5", optional: true},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 1.1", only: [:dev, :test]}
    ]
  end

  defp description do
    """
    Model Context Protocol (MCP) for Elixir — server and client, full spec surface
    (tools, resources, prompts, sampling, elicitation, roots) over stdio and
    Streamable HTTP transports. Behaviour-driven core with an optional macro DSL.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Keith Brings"],
      links: %{
        "GitHub" => @source_url,
        "MCP Specification" => "https://modelcontextprotocol.io"
      },
      files: ~w(lib priv guides cheatsheets .formatter.exs mix.exs README* LICENSE* CHANGELOG*)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extras: [
        "README.md",
        "CHANGELOG.md",
        "guides/getting_started.md",
        "guides/tools.md",
        "guides/resources_and_prompts.md",
        "guides/handler_context.md",
        "guides/client.md",
        "guides/streamable_http.md",
        "guides/stdio.md",
        "guides/authentication.md",
        "guides/testing.md",
        "cheatsheets/mcp.cheatmd"
      ],
      groups_for_extras: [
        Guides: ~r/guides\/.*/,
        Cheatsheets: ~r/cheatsheets\/.*/
      ],
      groups_for_modules: [
        Server: ~r/Noizu\.MCP\.Server($|\.)/,
        Client: ~r/Noizu\.MCP\.Client($|\.)/,
        "Handler Context": [Noizu.MCP.Ctx],
        Types: ~r/Noizu\.MCP\.Types\./,
        Transports: ~r/Noizu\.MCP\.Transport($|\.)/,
        Authorization: ~r/Noizu\.MCP\.Auth($|\.)/,
        Testing: [Noizu.MCP.Test],
        Protocol: ~r/Noizu\.MCP\.(JsonRpc|Peer|Protocol|Schema|Error|UriTemplate)($|\.)/
      ]
    ]
  end
end
