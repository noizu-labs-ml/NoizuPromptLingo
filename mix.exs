defmodule NoizuPromptLingua.MixProject do
  use Mix.Project

  def project do
    [
      app: :noizu_prompt_lingua,
      version: "0.1.0",
      elixir: "~> 1.18 or ~> 1.20",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {NoizuPromptLingua.Application, []}
    ]
  end

  defp deps do
    [
      {:noizu_mcp, "~> 0.1.3"},
      {:plug, "~> 1.16"},
      {:bandit, "~> 1.5"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.4"},
      {:bcrypt_elixir, "~> 3.0"},
      {:jose, "~> 1.11"},
      {:yaml_elixir, "~> 2.11"}
    ]
  end
end
