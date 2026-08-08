defmodule NoizuPromptLinguaWeb.NPLController do
  @moduledoc """
  Read-only REST API for browsing NPL (Noizu Prompt Lingua) conventions.

  Unlike the MCP NPLSpec/NPLLoad tools (which return formatted markdown for
  agents), these endpoints return the raw convention structure as JSON so the
  web UI can browse, filter, and search.
  """

  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.NPL.Reader

  # GET /api/v1/npl/sections
  def index_sections(conn, _params) do
    case Reader.sections() do
      {:ok, sections} ->
        json(conn, %{sections: sections})

      {:error, reason} ->
        conn |> put_status(:internal_server_error) |> json(%{error: reason})
    end
  end

  # GET /api/v1/npl/conventions?section=syntax
  def index_conventions(conn, params) do
    section = Map.get(params, "section")

    case Reader.components(section) do
      {:ok, conventions} ->
        json(conn, %{conventions: conventions, count: length(conventions)})

      {:error, reason} ->
        conn |> put_status(:internal_server_error) |> json(%{error: reason})
    end
  end

  # GET /api/v1/npl/conventions/:section/:slug
  def show_convention(conn, %{"section" => section, "slug" => slug}) do
    case Reader.component(section, slug) do
      {:ok, convention} ->
        json(conn, %{convention: convention})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Convention '#{slug}' not found in section '#{section}'"})

      {:error, reason} ->
        conn |> put_status(:internal_server_error) |> json(%{error: reason})
    end
  end

  # GET /api/v1/npl/labels
  def index_labels(conn, _params) do
    case Reader.labels() do
      {:ok, taxonomy} ->
        json(conn, %{labels: taxonomy})

      {:error, reason} ->
        conn |> put_status(:internal_server_error) |> json(%{error: reason})
    end
  end

  # POST /api/v1/npl/spec — generate a formatted NPL spec.
  #
  # Thin REST wrapper over the NPLSpec MCP tool logic (same engine, single
  # source of truth) so the web UI's "Generate NPL spec" panel can produce
  # formatted output without speaking MCP JSON-RPC. Body mirrors NPLSpec input:
  #   { "components": [{"spec": "pumps:chain-of-thought"}], "component_priority": 0,
  #     "example_priority": 0, "extension": false, "concise": true, "xml": false }
  def generate_spec(conn, params) do
    opts = spec_opts_from_params(params || %{})

    case NoizuPromptLingua.NPL.Definition.new() do
      {:ok, defn} ->
        result = NoizuPromptLingua.NPL.Definition.format(defn, opts)
        json(conn, %{spec: result, length: String.length(result)})

      {:error, reason} ->
        conn |> put_status(:internal_server_error) |> json(%{error: reason})
    end
  end

  defp spec_opts_from_params(params) do
    components = normalize_specs(Map.get(params, "components"))
    rendered = normalize_specs(Map.get(params, "rendered"))

    [
      components: (components == [] && nil) || components,
      rendered: (rendered == [] && nil) || rendered,
      component_priority: Map.get(params, "component_priority", 0),
      example_priority: Map.get(params, "example_priority", 0),
      extension: Map.get(params, "extension", false),
      flags: %{
        concise: Map.get(params, "concise", true),
        xml: Map.get(params, "xml", false)
      }
    ]
  end

  defp normalize_specs(nil), do: []

  defp normalize_specs(specs) when is_list(specs) do
    Enum.map(specs, fn
      %{"spec" => spec} = s ->
        %{
          spec: spec,
          component_priority: Map.get(s, "component_priority", 0),
          example_priority: Map.get(s, "example_priority", 0)
        }

      spec when is_binary(spec) ->
        spec

      other ->
        other
    end)
  end

  defp normalize_specs(_), do: []
end
