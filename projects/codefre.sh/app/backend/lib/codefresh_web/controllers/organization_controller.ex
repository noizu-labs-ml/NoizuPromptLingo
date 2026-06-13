defmodule CodefreshWeb.OrganizationController do
  use CodefreshWeb, :controller

  alias Codefresh.Organizations
  alias Codefresh.Guardian

  action_fallback CodefreshWeb.FallbackController

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    orgs = Organizations.list_user_organizations(user)

    json(conn, %{
      organizations:
        Enum.map(orgs, fn %{organization: o, role: role} ->
          %{id: o.id, slug: o.slug, name: o.name, role: role}
        end)
    })
  end

  def create(conn, %{"organization" => org_params}) do
    user = Guardian.Plug.current_resource(conn)
    attrs = derive_slug_if_missing(org_params)

    case Organizations.create_organization_with_owner(attrs, user) do
      {:ok, %{organization: org}} ->
        conn
        |> put_status(:created)
        |> json(%{organization: %{id: org.id, slug: org.slug, name: org.name, role: "owner"}})

      {:error, %Ecto.Changeset{} = cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: CodefreshWeb.ChangesetJSON.errors(cs)})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Expected {organization: {name, slug?}}"})
  end

  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, role} <- Organizations.authorize(user, id, "viewer"),
         org when not is_nil(org) <- Organizations.get_organization(id) do
      json(conn, %{organization: %{id: org.id, slug: org.slug, name: org.name, role: role}})
    else
      nil -> send_resp(conn, 404, "")
      {:error, :not_a_member} -> send_resp(conn, 404, "")
      {:error, :forbidden} -> send_resp(conn, 403, "")
    end
  end

  defp derive_slug_if_missing(%{"slug" => s} = attrs) when is_binary(s) and s != "", do: attrs

  defp derive_slug_if_missing(attrs) do
    name = attrs["name"] || ""

    slug =
      name
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9]+/, "-")
      |> String.trim("-")

    Map.put(attrs, "slug", slug)
  end
end
