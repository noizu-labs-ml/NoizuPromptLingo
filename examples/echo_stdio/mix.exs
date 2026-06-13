defmodule EchoStdio.MixProject do
  use Mix.Project

  def project do
    [
      app: :echo_stdio,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {EchoStdio.Application, []}
    ]
  end

  defp deps do
    [
      {:noizu_mcp, path: "../.."}
    ]
  end
end
