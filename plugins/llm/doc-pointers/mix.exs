defmodule DocPointers.MixProject do
  use Mix.Project

  def project do
    [
      app: :doc_pointers,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {DocPointers.Application, []}
    ]
  end

  defp deps do
    [
      {:noizu_mcp, "~> 0.1.3"},
      {:yaml_elixir, "~> 2.11"},
      {:ymlr, "~> 5.0"},
      {:jason, "~> 1.4"},
      {:bandit, "~> 1.6"},
      {:plug, "~> 1.16"}
    ]
  end
end
