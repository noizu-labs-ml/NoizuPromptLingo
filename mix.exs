#-------------------------------------------------------------------------------
# Author: Keith Brings
# Copyright (C) 2018 Noizu Labs, Inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Noizu.Scaffolding.Mixfile do
  use Mix.Project

  def project do
    [app: :noizu_scaffolding,
     version: "1.2.10",
     elixir: "~> 1.13",
     package: package(),
     deps: deps(),
     elixirc_paths: elixirc_paths(Mix.env),
     description: "Noizu Scaffolding",
     docs: docs()
   ]
  end # end project

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/fixtures"]
  defp elixirc_paths(_),     do: ["lib"]

  defp package do
    [
      maintainers: ["noizu"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/noizu/elixir_scaffolding"}
    ]
  end # end package

  def application do
    [ applications: [:logger],
      extra_applications: [:mnesia, :amnesia, :noizu_core, :noizu_mnesia_versioning, :plug, :poison, :redix, :fastglobal, :semaphore]
    ]
  end # end application

  defp deps do
    [
      {:amnesia, git: "https://github.com/noizu/amnesia.git", ref: "9266002", optional: true}, # Mnesia Wrapper
      {:ex_doc, "~> 0.28.3", only: [:dev], optional: true}, # Documentation Provider
      {:markdown, github: "devinus/markdown", only: [:dev], optional: true}, # Markdown processor for ex_doc
      {:noizu_core, github: "noizu/ElixirCore", tag: "1.0.17"},
      {:noizu_mnesia_versioning, github: "noizu/MnesiaVersioning", tag: "0.1.10"},
      {:redix, github: "whatyouhide/redix", tag: "v0.7.0", optional: true},
      {:poison, "~> 3.1.0", optional: true},
      {:fastglobal, "~> 1.0"}, # https://github.com/discordapp/fastglobal
      {:semaphore, "~> 1.0"}, # https://github.com/discordapp/semaphore
      {:plug, "~> 1.0", optional: true},
      {:elixir_uuid, "~> 1.2", only: :test, optional: true},
      {:telemetry, "~> 1.1.0", optional: true},
    ]
  end # end deps

  defp docs do
    [
      source_url_pattern: "https://github.com/noizu/ElixirScaffolding/blob/master/%{path}#L%{line}",
      extras: ["README.md", "markdown/sample_conventions_doc.md"]
    ]
  end # end docs

end # end defmodule
