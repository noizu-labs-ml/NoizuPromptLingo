defmodule HttpKitchenSink.MixProject do
  use Mix.Project

  def project do
    [
      app: :http_kitchen_sink,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {HttpKitchenSink.Application, []}
    ]
  end

  defp deps do
    [
      {:noizu_mcp, path: "../.."},
      {:plug, "~> 1.16"},
      {:bandit, "~> 1.5"}
    ]
  end
end
