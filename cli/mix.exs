defmodule CodefreshCli.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :codefresh_cli,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      description: "Codefresh command-line client",
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :inets, :ssl, :public_key, :crypto]
    ]
  end

  defp escript do
    [
      main_module: CodefreshCli,
      name: "codefresh",
      app: nil
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:req, "~> 0.5"},
      {:yaml_elixir, "~> 2.9"}
    ]
  end

  defp package do
    [
      maintainers: ["Codefresh"],
      licenses: ["Apache-2.0"]
    ]
  end
end
