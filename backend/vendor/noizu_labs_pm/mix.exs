defmodule Noizu.PM.MixProject do
  use Mix.Project

  def project do
    [
      app: :noizu_labs_pm,
      name: "Noizu PM",
      version: "0.1.0",
      package: package(),
      description: description(),
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  defp description() do
    "Shared project-management data layer (Noizu.PM.Repo / pm_core) for npl-mcp and therobotplans."
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{
        project: "https://github.com/noizu-labs-scaffolding/pm",
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
      # The Repo process is started by the host application's supervision tree
      # (each app lists :noizu_labs_pm in its extra_applications and starts
      # Noizu.PM.Repo itself). This library therefore registers no own
      # top-level supervisor, mirroring how :noizu_labs_core stays inert.
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:noizu_labs_entities, "~> 0.3.0"},
      {:jason, "~> 1.2"},
      {:credo, "~> 1.7.12", runtime: false},
      {:ex_doc, "~> 0.35", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      test: ["test"]
    ]
  end
end
