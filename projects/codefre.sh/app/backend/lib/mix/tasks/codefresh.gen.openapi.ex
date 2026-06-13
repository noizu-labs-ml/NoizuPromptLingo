defmodule Mix.Tasks.Codefresh.Gen.Openapi do
  @moduledoc """
  Emit the OpenAPI spec as JSON to `docs/openapi.json`.

  Used by the Stage 0 contract-freeze CI step (diff against committed snapshot).

      mix codefresh.gen.openapi
  """

  use Mix.Task
  @shortdoc "Dump OpenAPI spec to docs/openapi.json"

  @target "docs/openapi.json"

  @impl true
  def run(_args) do
    Mix.Task.run("app.start")

    json =
      CodefreshWeb.ApiSpec.spec()
      |> OpenApiSpex.OpenApi.json_encoder().encode!(pretty: true)

    File.mkdir_p!(Path.dirname(@target))
    File.write!(@target, json <> "\n")
    Mix.shell().info("wrote #{@target}")
  end
end
