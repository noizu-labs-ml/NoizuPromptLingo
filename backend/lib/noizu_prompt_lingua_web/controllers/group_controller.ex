defmodule NoizuPromptLinguaWeb.GroupController do
  use NoizuPromptLinguaWeb, :controller

  alias NoizuPromptLingua.Authz.Groups

  def index(conn, _params) do
    groups = Groups.list_all()
    json(conn, %{groups: Enum.map(groups, &group_to_json/1)})
  end

  def show(conn, %{"id" => id}) do
    group = if NoizuPromptLingua.UUID.uuid?(id), do: NoizuPromptLingua.Repo.get(NoizuPromptLingua.Schema.Authz.Group, id), else: Groups.get_by_name(id)

    case group do
      nil -> conn |> put_status(:not_found) |> json(%{error: "Group not found"})
      g -> json(conn, %{group: group_to_json(g)})
    end
  end

  def policies(conn, %{"id" => id}) do
    group = if NoizuPromptLingua.UUID.uuid?(id), do: NoizuPromptLingua.Repo.get(NoizuPromptLingua.Schema.Authz.Group, id), else: Groups.get_by_name(id)

    case group do
      nil -> conn |> put_status(:not_found) |> json(%{error: "Group not found"})
      g ->
        policies = Groups.list_policies(g.id)
        json(conn, %{group: group_to_json(g), policies: policies})
    end
  end

  defp group_to_json(group) do
    %{
      id: group.id,
      name: group.name,
      display_name: group.display_name,
      description: group.description,
      is_system: group.is_system
    }
  end
end
