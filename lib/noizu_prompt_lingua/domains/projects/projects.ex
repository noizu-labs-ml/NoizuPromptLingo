defmodule NoizuPromptLingua.Domains.Projects do
  import Ecto.Query, except: [update: 2]
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.{Project, ProjectMember, User}

  # ── Project CRUD ──────────────────────────────────────────────

  def create(attrs) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  def get(slug_or_id) do
    case Ecto.UUID.cast(slug_or_id) do
      {:ok, uuid} ->
        Project
        |> where([p], p.id == ^uuid or p.slug == ^slug_or_id)
        |> Repo.one()
      :error ->
        Repo.get_by(Project, slug: slug_or_id)
    end
  end

  def update(slug_or_id, attrs) do
    case get(slug_or_id) do
      nil -> {:error, :not_found}
      project ->
        project
        |> Project.changeset(attrs)
        |> Repo.update()
    end
  end

  def archive(slug_or_id) do
    update(slug_or_id, %{status: "archived"})
  end

  def list(opts \\ []) do
    Project
    |> maybe_filter_status(opts[:status])
    |> order_by([p], desc: p.inserted_at)
    |> limit(^(opts[:limit] || 50))
    |> offset(^(opts[:offset] || 0))
    |> Repo.all()
  end

  def count_active do
    Repo.aggregate(from(p in Project, where: p.status == "active"), :count)
  end

  # ── Membership ────────────────────────────────────────────────

  def invite(project_id, email, opts \\ []) do
    role = Keyword.get(opts, :role, "member")
    invited_by = Keyword.get(opts, :invited_by)

    case Repo.get_by(User, email: email) do
      nil ->
        {:error, :user_not_found}

      user ->
        %ProjectMember{}
        |> ProjectMember.changeset(%{
          project_id: project_id,
          user_id: user.id,
          role: role,
          invited_by: invited_by,
          invited_at: DateTime.utc_now(),
          status: "pending"
        })
        |> Repo.insert()
    end
  end

  def accept_invite(project_id, user_id) do
    case get_membership(project_id, user_id) do
      nil -> {:error, :not_found}
      %{status: "pending"} = member ->
        member
        |> ProjectMember.changeset(%{status: "active", accepted_at: DateTime.utc_now()})
        |> Repo.update()
      %{status: "active"} -> {:error, :already_active}
      _ -> {:error, :invalid_status}
    end
  end

  def update_role(project_id, user_id, role) do
    case get_membership(project_id, user_id) do
      nil -> {:error, :not_found}
      member ->
        member
        |> ProjectMember.changeset(%{role: role})
        |> Repo.update()
    end
  end

  def remove_member(project_id, user_id) do
    case get_membership(project_id, user_id) do
      nil -> {:error, :not_found}
      member ->
        member
        |> ProjectMember.changeset(%{status: "removed"})
        |> Repo.update()
    end
  end

  def list_members(project_id, opts \\ []) do
    ProjectMember
    |> where([m], m.project_id == ^project_id)
    |> maybe_filter_member_status(opts[:status])
    |> preload(:user)
    |> order_by([m], asc: m.inserted_at)
    |> Repo.all()
  end

  def get_membership(project_id, user_id) do
    Repo.get_by(ProjectMember, project_id: project_id, user_id: user_id)
  end

  # ── Private ───────────────────────────────────────────────────

  defp maybe_filter_status(query, nil), do: query
  defp maybe_filter_status(query, status), do: where(query, [p], p.status == ^status)

  defp maybe_filter_member_status(query, nil), do: where(query, [m], m.status != "removed")
  defp maybe_filter_member_status(query, status), do: where(query, [m], m.status == ^status)
end
