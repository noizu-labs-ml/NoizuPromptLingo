defmodule DirenvConfig.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :direnv_config,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: "Elixir SDK for direnv-config (dc) — read and write YAML-backed directory configuration",
      source_url: "https://github.com/noizu/direnv-config",
      docs: [
        main: "readme",
        extras: ["README.md", "LICENSE"]
      ]
    ]
  end

  def application do
    [extra_applications: [:logger, :crypto]]
  end

  defp deps do
    [
      {:yaml_elixir, "~> 2.9"},
      {:ymlr, "~> 5.0"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      name: "direnv_config",
      maintainers: ["Keith Brings"],
      licenses: ["MIT"],
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE),
      links: %{
        "GitHub" => "https://github.com/noizu/direnv-config",
        "Changelog" => "https://github.com/noizu/direnv-config/blob/main/CHANGELOG.md"
      }
    ]
  end
end
