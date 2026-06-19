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

  def create(conn, params) do
    attrs = Map.take(params, ~w(name slug description status))
    case Projects.create(attrs) do
      {:ok, project} ->
        conn |> put_status(201) |> json(%{project: project_json(project)})
      {:error, cs} ->
        conn |> put_status(422) |> json(%{errors: format_errors(cs)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    attrs = Map.take(params, ~w(name slug description status))
    case Projects.update(id, attrs) do
      {:ok, project} ->
        json(conn, %{project: project_json(project)})
      {:error, :not_found} ->
        conn |> put_status(404) |> json(%{error: "not_found"})
      {:error, cs} ->
        conn |> put_status(422) |> json(%{errors: format_errors(cs)})
    end
  end

  def delete(conn, %{"id" => id}) do
    case Projects.archive(id) do
      {:ok, _} -> json(conn, %{ok: true})
      {:error, :not_found} -> conn |> put_status(404) |> json(%{error: "not_found"})
    end
  end

  defp project_json(p) do
    %{id: p.id, name: p.name, slug: p.slug, description: p.description,
      status: p.status, created_at: p.inserted_at, updated_at: p.updated_at}
  end

  defp format_errors(%Ecto.Changeset{} = cs) do
    Ecto.Changeset.traverse_errors(cs, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
  defp format_errors(other), do: inspect(other)
end
