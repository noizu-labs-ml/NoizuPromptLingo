defmodule NPLWeb.API.ProjectsAPIController do
  use NPLWeb, :controller

  alias NoizuPromptLingua.Domains.Projects

  def index(conn, _params) do
    projects = Projects.list()
    json(conn, %{
      projects: Enum.map(projects, fn p ->
        %{id: p.id, name: p.name, slug: p.slug, description: p.description,
          status: p.status, created_at: p.inserted_at}
      end)
    })
  end

  def show(conn, %{"id" => id}) do
    case Projects.get(id) do
      nil -> conn |> put_status(404) |> json(%{error: "not_found"})
      project ->
        members = Projects.list_members(project.id)
        json(conn, %{
          project: %{id: project.id, name: project.name, slug: project.slug,
                     description: project.description, status: project.status},
          members: Enum.map(members, fn m ->
            %{id: m.id, user_id: m.user_id, role: m.role, status: m.status}
          end)
        })
    end
  end
end
