defmodule NoizuPromptLingua.Projects do
  alias NoizuPromptLingua.Projects.Project, as: Entity

  use Noizu.Repo
  def_repo(entity: Entity)

  def create_with_owner(attrs, user_id, _context \\ Noizu.Context.system()) do
    NoizuPromptLingua.PMCore.with_pm(fn ->
      Noizu.PM.Projects.create_with_owner(attrs, user_id,
        ensure_user: pm_user_snapshot(user_id),
        ensure_org: pm_org_snapshot(attrs)
      )
    end)
  end

  # Wire identity spine onto pm_core before project insert (FK + membership).
  defp pm_user_snapshot(user_id) do
    case NoizuPromptLingua.Repo.get(NoizuPromptLingua.Schema.Users.User, user_id) do
      nil ->
        %{id: user_id, email: "user-#{user_id}@tobor.locker"}

      u ->
        %{
          id: u.id,
          email: u.email,
          user_name: u.user_name,
          handle: u.handle,
          status: u.status,
          role: u.role,
          verified: u.verified,
          bio: u.bio
        }
    end
  end

  defp pm_org_snapshot(attrs) do
    org_id = Map.get(attrs, :organization_id) || Map.get(attrs, "organization_id")

    # Shared orgs live on pm_core only; fall back to bare id for ensure/1.
    o =
      if is_binary(org_id) do
        Noizu.PM.Repo.get(Noizu.PM.Schema.Organizations.Organization, org_id)
      end

    case o do
      nil when is_binary(org_id) -> %{id: org_id}
      nil -> nil
      org ->
        %{
          id: org.id,
          slug: org.slug,
          name: org.name,
          settings: org.settings,
          key_prefix: Map.get(org, :key_prefix)
        }
    end
  end

  def list_for_user(user_id, organization_id \\ nil) do
    case NoizuPromptLingua.PMCore.with_pm(fn ->
           Noizu.PM.Projects.list_for_user(user_id, organization_id)
         end) do
      rows when is_list(rows) -> rows
      _ -> []
    end
  end

  def get_project(id) do
    NoizuPromptLingua.PMCore.with_pm(fn -> Noizu.PM.Projects.get_project(id) end)
  end

  def update_project(id, attrs) do
    NoizuPromptLingua.PMCore.with_pm(fn -> Noizu.PM.Projects.update_project(id, attrs) end)
  end

  def archive(id) do
    NoizuPromptLingua.PMCore.with_pm(fn -> Noizu.PM.Projects.archive(id) end)
  end

  def unarchive(id) do
    NoizuPromptLingua.PMCore.with_pm(fn -> Noizu.PM.Projects.unarchive(id) end)
  end

  def delete_project(id) do
    NoizuPromptLingua.PMCore.with_pm(fn -> Noizu.PM.Projects.soft_delete(id) end)
  end

  def list_members(project_id) do
    NoizuPromptLingua.PMCore.with_pm(fn -> Noizu.PM.Projects.list_members(project_id) end)
  end
end
