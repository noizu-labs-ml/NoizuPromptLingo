defmodule Noizu.Core.MixProject do
  use Mix.Project
  
  def project do
    [
      app: :noizu_labs_core,
      name: "Noizu Core",
      version: "0.1.8",
      package: package(),
      description: description(),
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end
  
  defp description() do
    "Core Noizu Scaffolding libraries"
  end
  
  defp package() do
    [
      licenses: ["MIT"],
      links: %{
        project: "https://github.com/noizu-labs-scaffolding/core",
        noizu_labs: "https://github.com/noizu-labs",
        developer: "https://github.com/noizu"
      }
    ]
  end
  
  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
  
  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # applications: [:noizu_labs_erp],
      extra_applications: [:logger]
    ]
  end
  
  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7.12", runtime: false},
      {:ex_doc, "~> 0.35", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end