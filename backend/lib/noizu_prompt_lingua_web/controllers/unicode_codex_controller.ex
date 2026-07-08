defmodule NoizuPromptLinguaWeb.UnicodeCodexController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Authz
  alias NoizuPromptLingua.Domains.UnicodeCodex
  alias NoizuPromptLingua.MCP.Resolve

  # GET /api/v1/organizations/:org_id/unicode/elements
  def index_elements(conn, %{"org_id" => org_ref} = params) do
    with_scope(conn, org_ref, params, fn org_id, project_id ->
      opts = opts_from_params(params, org_id, project_id)
      json(conn, UnicodeCodex.list_elements(opts))
    end)
  end

  # GET /api/v1/organizations/:org_id/unicode/elements/:slug
  def show_element(conn, %{"org_id" => org_ref, "slug" => slug} = params) do
    with_scope(conn, org_ref, params, fn org_id, project_id ->
      case UnicodeCodex.get_element(slug, opts_from_params(params, org_id, project_id)) do
        {:ok, result} ->
          json(conn, result)

        {:error, :not_found} ->
          conn |> put_status(:not_found) |> json(%{error: "Unicode element not found"})
      end
    end)
  end

  # GET /api/v1/organizations/:org_id/unicode/elements/:slug/relations
  def relations(conn, %{"org_id" => org_ref, "slug" => slug} = params) do
    with_scope(conn, org_ref, params, fn org_id, project_id ->
      case UnicodeCodex.related(slug, opts_from_params(params, org_id, project_id)) do
        {:ok, result} ->
          json(conn, result)

        {:error, :not_found} ->
          conn |> put_status(:not_found) |> json(%{error: "Unicode element not found"})
      end
    end)
  end

  # GET /api/v1/organizations/:org_id/unicode/special-usages
  def index_special_usages(conn, %{"org_id" => org_ref} = params) do
    with_scope(conn, org_ref, params, fn org_id, project_id ->
      json(conn, UnicodeCodex.list_special_usages(opts_from_params(params, org_id, project_id)))
    end)
  end

  # GET /api/v1/organizations/:org_id/unicode/special-usages/:slug
  def show_special_usage(conn, %{"org_id" => org_ref, "slug" => slug} = params) do
    with_scope(conn, org_ref, params, fn org_id, project_id ->
      case UnicodeCodex.get_special_usage(slug, opts_from_params(params, org_id, project_id)) do
        {:ok, result} ->
          json(conn, result)

        {:error, :not_found} ->
          conn |> put_status(:not_found) |> json(%{error: "Unicode special usage not found"})
      end
    end)
  end

  defp opts_from_params(params, org_id, project_id) do
    [
      organization_id: org_id,
      project_id: project_id,
      q: params["q"] || params["query"],
      topic: params["topic"],
      flag: params["flag"],
      sentiment: params["sentiment"],
      usage: params["usage"],
      printable: params["printable"],
      visibility: params["visibility"],
      include_shadowed: params["include_shadowed"],
      limit: params["limit"],
      offset: params["offset"]
    ]
  end

  defp with_scope(conn, org_ref, params, fun) do
    user_id = get_user_id(conn)

    with {:ok, org_id} <- NoizuPromptLingua.Organizations.resolve_org_id(org_ref),
         {:ok, _} <- Authz.authorize(user_id, "organization", org_id, "viewer"),
         {:ok, project_id} <-
           Resolve.project_in_org(params["project_id"] || params["project"], org_id) do
      fun.(org_id, project_id)
    else
      {:error, :not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Organization not found"})

      {:error, :project_not_found} ->
        conn |> put_status(:not_found) |> json(%{error: "Project not found"})

      {:error, :project_not_in_org} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Project does not belong to this organization"})

      {:error, :not_a_member} ->
        conn |> put_status(:forbidden) |> json(%{error: "Not a member of this organization"})

      {:error, _} ->
        conn |> put_status(:forbidden) |> json(%{error: "Insufficient permissions"})
    end
  end

  defp get_user_id(conn) do
    case NoizuPromptLingua.Guardian.Plug.current_resource(conn) do
      %NoizuPromptLingua.Users.Sessions.UserSession{user: {:ref, _, id}} -> id
      %NoizuPromptLingua.Users.Sessions.UserSession{user: %{id: id}} -> id
      _ -> nil
    end
  end
end
