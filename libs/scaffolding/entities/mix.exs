defmodule Noizu.Entities.MixProject do
  use Mix.Project

  def project do
    [
      app: :noizu_labs_entities,
      name: "NoizuLabs Entities",
      version: "0.3.1",
      elixir: "~> 1.14",
      package: package(),
      description: description(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      dialyzer: dialyzer(),
      test_coverage: test_coverage(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def docs() do
    [
      main: "Noizu",
      extras: ["README.md", "CHANGELOG.md", "CONTRIBUTING.md", "LICENSE"]
    ]
  end

  def dialyzer() do
    [
      plt_file: {:no_warn, "priv/plts/project.plt"},
      exclude: ["lib/mix/tasks/*"]
    ]
  end

  defp test_coverage() do
    [
      summary: [
        threshold: 40
      ],
      ignore_modules: []
    ]
  end

  defp description() do
    "Elixir Entities (Structs with MetaData and Noizu EntityReference Protocol support from noizu-labs-scaffolding/core built in."
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{
        project: "https://github.com/noizu-labs-scaffolding/entities",
        developer: "https://github.com/noizu"
      }
    ]
  end

  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # @TODO - prepare hex releases (or abandon) jason and amnesi
      {:ex_doc, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:mimic, "~> 1.0.0", only: :test},
      {:ecto_sql, "~> 3.6"},
      {:nuamnesia, "~> 0.3.0", optional: true},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.0", runtime: false},
      {:junit_formatter, "~> 3.4", only: [:test]},
      {:shortuuid, "~> 4.0"},
      {:elixir_uuid, "~> 1.2", optional: true},
      {:inflex28, "~> 2.1.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
    |> then(fn deps ->
      if Application.get_env(:noizu_labs_entities, :umbrella) do
        deps ++ [{:noizu_labs_core, in_umbrella: true}]
      else
        deps ++
          [
            {:noizu_labs_core, "~> 0.1.8"}
            # {:noizu_labs_core,            github: "noizu-labs-scaffolding/core", branch: "develop", override: true},
          ]
      end
    end)
  end
end
