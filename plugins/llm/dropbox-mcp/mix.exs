defmodule DropboxMCP.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/noizu-labs/dropbox-mcp"

  def project do
    [
      app: :dropbox_mcp,
      name: "Dropbox MCP",
      description: description(),
      version: @version,
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      source_url: @source_url,
      homepage_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {DropboxMCP.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:noizu_mcp, "~> 0.1.5"},
      {:noizu_dropbox, "~> 0.1.0"},
      {:jason, "~> 1.4"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    MCP server for Dropbox filesystem operations — list, read, write, move,
    copy, delete, search, and share — built on Noizu.MCP and Noizu.Dropbox.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Keith Brings"],
      links: %{
        "GitHub" => @source_url,
        "Noizu MCP" => "https://github.com/noizu-labs/noizu-mcp",
        "Dropbox API" =>
          "https://www.dropbox.com/developers/documentation/http/documentation"
      },
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"]
    ]
  end
end
