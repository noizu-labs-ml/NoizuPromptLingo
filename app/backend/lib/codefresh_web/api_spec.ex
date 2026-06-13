defmodule CodefreshWeb.ApiSpec do
  @moduledoc """
  OpenAPI spec root for the Codefresh HTTP API (US-0.5 contract freeze).

  Controllers declare operations via `open_api_spex` and are pulled in by the
  router. The generated spec is diffed against the committed snapshot on every
  PR (see `.github/workflows/backend.yml`) — additions and deprecations pass;
  breaking changes must be explicitly promoted.
  """

  alias OpenApiSpex.{Info, OpenApi, Paths, Server, SecurityScheme, Components}

  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [
        %Server{url: "http://localhost:4000", description: "local dev"},
        %Server{url: "https://codefre.sh", description: "production"}
      ],
      info: %Info{
        title: "Codefresh API",
        version: "0.1.0",
        description: """
        Behavioral testing framework for AI agents.

        All `/api/v1/organizations/:organization_id/*` endpoints require a
        Bearer JWT (`Guardian` access token) and cross-tenant requests return
        404 (never 403, to avoid confirming resource existence across orgs).
        """
      },
      components: %Components{
        securitySchemes: %{
          "bearerAuth" => %SecurityScheme{
            type: "http",
            scheme: "bearer",
            bearerFormat: "JWT"
          },
          "apiToken" => %SecurityScheme{
            type: "http",
            scheme: "bearer",
            bearerFormat: "ct_XXXX..."
          }
        }
      },
      security: [%{"bearerAuth" => []}],
      paths: Paths.from_router(CodefreshWeb.Router)
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
