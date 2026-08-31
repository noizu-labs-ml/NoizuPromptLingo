defmodule NoizuPromptLinguaWeb.ComponentController do
  @moduledoc """
  Keyed Lit component registry endpoints (W7).

  Auth: `McpKeyAuth` (require mode) — raw MCP API key or minted MCP JWT.
  Per-key visibility: the key's `toolset_config` governs the `components`
  group exactly like MCP tools (W5 machinery):

    * `hidden: true`  — omitted from the listing AND fetch answers 404
      (no existence disclosure; hidden wins over disabled).
    * `disabled: true` — still listed, but fetch answers 403 (discovery ok,
      delivery blocked).

  Config shape (absent field = inherit = unrestricted):

      %{"groups" => %{"components" => %{
           "hidden" => true,
           "tools" => %{"npl-queue-board" => %{"disabled" => true}}}}}
  """

  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Components
  alias NoizuPromptLingua.MCP.KeyToolsets
  alias NoizuPromptLingua.Schema.McpApiKey

  @toolset_group "components"

  # GET /api/v1/components
  def index(conn, _params) do
    config = toolset_config(conn)

    components =
      Components.list()
      |> Enum.reject(fn component ->
        KeyToolsets.state_from_config(config, @toolset_group, component.name).hidden
      end)
      |> Enum.map(fn component ->
        %{
          name: component.name,
          version: component.version,
          description: component.description,
          bundle_url: ~p"/api/v1/components/#{component.name}/bundle"
        }
      end)

    json(conn, %{components: components})
  end

  # GET /api/v1/components/:name/bundle
  def bundle(conn, %{"name" => name}) do
    component = Components.get(name)
    state = KeyToolsets.state_from_config(toolset_config(conn), @toolset_group, name)

    cond do
      # Unknown or hidden: 404 — do not disclose existence to this key.
      is_nil(component) or state.hidden ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "not found"})

      state.disabled ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "forbidden", reason: "component_disabled"})

      true ->
        serve_bundle(conn, component)
    end
  end

  defp serve_bundle(conn, component) do
    case Components.bundle(component) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "not found"})

      body ->
        conn
        |> put_resp_content_type(component.content_type)
        |> put_resp_header("cache-control", "public, max-age=31536000, immutable")
        |> send_resp(200, body)
    end
  end

  defp toolset_config(conn) do
    case conn.assigns[:mcp_api_key] do
      %McpApiKey{toolset_config: config} when is_map(config) -> config
      _ -> %{}
    end
  end
end
