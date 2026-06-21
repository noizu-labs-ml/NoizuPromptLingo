defmodule NoizuPromptLinguaWeb.BrowserController do
  @moduledoc """
  Org-scoped REST surface for the browser feature's frontend page: report whether
  a local browser controller is connected, and list the screenshots/videos it has
  captured (stored as org `media` assets).
  """
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Domains.Browser
  alias NoizuPromptLingua.MCP.Resolve

  def status(conn, %{"org_id" => org_id}) do
    json(conn, %{connected: Browser.connected?(org_id)})
  end

  def captures(conn, %{"org_id" => org_id}) do
    case Resolve.organization_id(org_id) do
      nil ->
        conn |> put_status(:not_found) |> json(%{error: "organization not found"})

      id ->
        json(conn, %{captures: Browser.list_captures(id)})
    end
  end
end
