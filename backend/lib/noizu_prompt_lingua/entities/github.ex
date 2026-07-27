defmodule NoizuPromptLingua.Github do
  @moduledoc """
  Context for org-scoped GitHub integration configuration: raw PAT tokens and
  the repos mapped to them (one token : many repos). There is no GitHub API
  integration yet — these are raw text values the admin manages.

  Repo access control (ACL):
    * `default_acl` (on the repo) sets the org-wide baseline:
        private   — invisible to org members unless granted via a group
        org_read  — org members can view (read PRs, comment, read code)
        org_write — org members can edit (create/edit PRs, edit code)
    * Group read/write grants reuse scoped_memberships with
      resource_type = 'github_repo', member_type = 'group'. The linked role
      group encodes the permission: viewer = read, member = write. A user
      benefits from a grant if they are a member of the granted group within
      the repo's org.
  """

  alias NoizuPromptLingua.Schema.GithubToken, as: TokenSchema
  alias NoizuPromptLingua.Schema.GithubRepo, as: RepoSchema
  alias NoizuPromptLingua.Schema.Authz.ScopedMembership, as: MembershipSchema
  alias NoizuPromptLingua.Schema.Authz.Group, as: GroupSchema

  import Ecto.Query

  @read_groups ["viewer", "member", "admin", "owner"]
  @write_groups ["member", "admin", "owner"]

  # ── Tokens ───────────────────────────────────────────────────────────────

  def list_tokens(organization_id) do
    from(t in TokenSchema,
      where: t.organization_id == ^organization_id,
      order_by: [asc: t.label]
    )
    |> NoizuPromptLingua.Repo.all()
  end

  def get_token(id) do
    NoizuPromptLingua.Repo.get(TokenSchema, id)
  end

  def create_token(attrs) do
    %TokenSchema{}
    |> TokenSchema.changeset(attrs)
    |> NoizuPromptLingua.Repo.insert()
  end

  def delete_token(id) do
    case NoizuPromptLingua.Repo.get(TokenSchema, id) do
      nil -> {:error, :not_found}
      token -> NoizuPromptLingua.Repo.delete(token)
    end
  end

  # ── Repos ────────────────────────────────────────────────────────────────

  def list_repos(organization_id) do
    from(r in RepoSchema,
      left_join: t in assoc(r, :token),
      where: r.organization_id == ^organization_id,
      order_by: [asc: r.repo_full_name],
      preload: [token: t],
      select: r
    )
    |> NoizuPromptLingua.Repo.all()
  end

  @doc """
  Get a single repo by UUID or repo_full_name within an organization.
  Preloads the mapped token. Returns nil if not found.
  """
  def get_repo(organization_id, repo_id_or_full_name) do
    case NoizuPromptLingua.UUID.cast(repo_id_or_full_name) do
      {:ok, uuid} ->
        RepoSchema
        |> where([r], r.organization_id == ^organization_id and r.id == ^uuid)
        |> preload([:token])
        |> NoizuPromptLingua.Repo.one()

      :error ->
        RepoSchema
        |> where([r], r.organization_id == ^organization_id and r.repo_full_name == ^repo_id_or_full_name)
        |> preload([:token])
        |> NoizuPromptLingua.Repo.one()
    end
  end

  def create_repo(attrs) do
    %RepoSchema{}
    |> RepoSchema.changeset(attrs)
    |> NoizuPromptLingua.Repo.insert()
  end

  def update_repo_token(repo_id, token_id) do
    update_repo(repo_id, %{token_id: token_id})
  end

  def update_repo(repo_id, attrs) do
    case NoizuPromptLingua.Repo.get(RepoSchema, repo_id) do
      nil ->
        {:error, :not_found}

      repo ->
        updates =
          attrs
          |> Map.take([:token_id, :default_acl, "token_id", "default_acl"])
          |> Enum.into(%{}, fn
            {k, v} when is_atom(k) -> {k, v}
            {k, v} -> {String.to_existing_atom(k), v}
          end)

        repo |> RepoSchema.changeset(updates) |> NoizuPromptLingua.Repo.update()
    end
  end

  def delete_repo(id) do
    case NoizuPromptLingua.Repo.get(RepoSchema, id) do
      nil -> {:error, :not_found}
      repo -> NoizuPromptLingua.Repo.delete(repo)
    end
  end

  # ── ACL: group grants ────────────────────────────────────────────────────

  @doc """
  Lists the group grants on a repo: the role groups linked via
  scoped_memberships (resource_type='github_repo', member_type='group').
  The group's `name` is the granted permission (viewer = read, member = write).
  """
  def list_repo_grants(repo_id) do
    from(sm in MembershipSchema,
      join: g in GroupSchema, on: g.id == sm.group_id,
      where:
        sm.resource_type == "github_repo" and
          sm.resource_id == ^repo_id and
          sm.member_type == "group",
      select: %{id: sm.id, group_id: g.id, group_name: g.name, display_name: g.display_name}
    )
    |> NoizuPromptLingua.Repo.all()
  end

  @doc """
  Grants a group access to a repo. `level` is `:read` or `:write`. The grant is
  a scoped_membership row: `member_id` is the group being granted access, and
  `group_id` is the system role group (viewer/member) whose name records the
  permission level.
  """
  def grant_repo_access(repo_id, group_id, level) when level in [:read, :write] do
    case permission_group_id(level) do
      nil ->
        {:error, :unknown_role_group}

      permission_group_id ->
        attrs = %{
          resource_type: "github_repo",
          resource_id: repo_id,
          member_type: "group",
          member_id: group_id,
          group_id: permission_group_id
        }

        %MembershipSchema{}
        |> MembershipSchema.changeset(attrs)
        |> NoizuPromptLingua.Repo.insert()
    end
  end

  @doc "Revokes a group grant by its scoped_membership id."
  def revoke_repo_grant(grant_id) do
    case NoizuPromptLingua.Repo.get(MembershipSchema, grant_id) do
      nil -> {:error, :not_found}
      membership -> NoizuPromptLingua.Repo.delete(membership)
    end
  end

  @doc """
  Resolves whether `user_id` has `:read` or `:write` access to `repo`.

  * `org_write`  → org members get read + write
  * `org_read`   → org members get read
  * `private`    → org membership alone grants nothing
  * Any level    → a group grant (read/write) the user is a member of adds the
    corresponding permission on top.
  """
  def can_access?(user_id, %RepoSchema{} = repo, level) when level in [:read, :write] do
    org_member? = org_member?(user_id, repo.organization_id)

    from_org =
      cond do
        repo.default_acl == "org_write" -> org_member?
        repo.default_acl == "org_read" -> org_member? && level == :read
        true -> false
      end

    from_org || group_grant?(user_id, repo.id, level)
  end

  defp group_grant?(user_id, repo_id, level) do
    allowed_roles = if level == :read, do: @read_groups, else: @write_groups

    # Collect the (target group, permission) pairs granted on this repo.
    grants =
      from(sm in MembershipSchema,
        join: g in GroupSchema, on: g.id == sm.group_id,
        where:
          sm.resource_type == "github_repo" and
            sm.resource_id == ^repo_id and
            sm.member_type == "group",
        select: {sm.member_id, g.name}
      )
      |> NoizuPromptLingua.Repo.all()

    grants
    |> Enum.filter(fn {_granted_group_id, permission_role} ->
      permission_role in allowed_roles
    end)
    |> Enum.any?(fn {granted_group_id, _} ->
      user_in_group?(user_id, granted_group_id)
    end)
  end

  # Is the user a member of a given group (via any of their scoped_memberships)?
  defp user_in_group?(user_id, group_id) do
    from(sm in MembershipSchema,
      where:
        sm.member_type == "user" and sm.member_id == ^user_id and
          sm.group_id == ^group_id
    )
    |> NoizuPromptLingua.Repo.exists?()
  end

  defp org_member?(user_id, org_id) do
    from(sm in MembershipSchema,
      where:
        sm.member_type == "user" and sm.member_id == ^user_id and
          sm.resource_type == "organization" and sm.resource_id == ^org_id
    )
    |> NoizuPromptLingua.Repo.exists?()
  end

  defp role_group_id(name) do
    from(g in GroupSchema, where: g.name == ^name and g.is_system == true, select: g.id)
    |> NoizuPromptLingua.Repo.one()
  end

  # The permission group_id stored on a grant: viewer for read, member for write.
  defp permission_group_id(:read), do: role_group_id("viewer")
  defp permission_group_id(:write), do: role_group_id("member")
end
