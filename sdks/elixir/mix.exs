defmodule CodefreshSdk.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/codefre-sh/sdk-elixir"

  def project do
    [
      app: :codefresh_sdk,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: @source_url,
      docs: [main: "CodefreshSdk", extras: ["README.md"]]
    ]
  end

  def application do
    [extra_applications: [:logger, :crypto]]
  end

  defp deps do
    [
      {:req, "~> 0.5"},
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Elixir SDK for the CodeFresh eval platform (https://codefre.sh)."
  end

  defp package do
    [
      name: "codefresh_sdk",
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url, "Website" => "https://codefre.sh"},
      maintainers: ["CodeFresh"]
    ]
  end
end
