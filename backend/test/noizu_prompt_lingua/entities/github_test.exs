defmodule NoizuPromptLingua.GithubTest do
  use NoizuPromptLingua.DataCase

  @moduledoc """
  Org-scoped GitHub integration context (entities/github.ex): token and repo
  CRUD, repo lookup by UUID or full name, group grants via scoped_memberships,
  and the can_access? ACL matrix (org defaults × group grants).
  """

  alias NoizuPromptLingua.Github
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Authz.Group
  alias NoizuPromptLingua.Schema.Authz.ScopedMembership
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema

  setup do
    n = System.unique_integer([:positive])

    org =
      %NoizuPromptLingua.Schema.Organizations.Organization{
        name: "GH Org #{n}",
        slug: "gh-org-#{n}"
      }
      |> Repo.insert!()

    user =
      %UserSchema{
        email: "gh-#{n}@example.com",
        user_name: "gh_user#{n}",
        handle: "gh_h#{n}",
        status: :active
      }
      |> Repo.insert!()

    %{org: org, user: user}
  end

  # groups.name is the role_name_enum — only seeded role names are insertable.
  @role_names ["owner", "admin", "lead", "member", "viewer"]

  defp ensure_system_group!(name) when name in @role_names do
    case Repo.one(from g in Group, where: g.name == ^name and g.is_system == true) do
      nil -> Repo.insert!(%Group{name: name, display_name: name, is_system: true})
      group -> group
    end
  end

  defp create_token!(org_id, label) do
    {:ok, token} =
      Github.create_token(%{organization_id: org_id, label: label, token: "ghp_" <> label})

    token
  end

  defp create_repo!(org_id, full_name, attrs \\ %{}) do
    {:ok, repo} =
      Github.create_repo(Map.merge(%{organization_id: org_id, repo_full_name: full_name}, attrs))

    repo
  end

  defp add_member!(resource_type, resource_id, member_type, member_id, group) do
    %ScopedMembership{
      resource_type: resource_type,
      resource_id: resource_id,
      member_type: member_type,
      member_id: member_id,
      group_id: group.id
    }
    |> Repo.insert!()
  end

  # ── tokens ───────────────────────────────────────────────────────

  test "token CRUD round-trips and delete reports not_found", %{org: org} do
    t1 = create_token!(org.id, "b-token")
    create_token!(org.id, "a-token")

    listed = Github.list_tokens(org.id)
    assert Enum.map(listed, & &1.label) == ["a-token", "b-token"]

    assert %{} = t1
    assert Github.get_token(t1.id).id == t1.id
    assert Github.get_token(Ecto.UUID.generate()) == nil

    assert {:ok, _} = Github.delete_token(t1.id)
    assert {:error, :not_found} = Github.delete_token(t1.id)
  end

  # ── repos ────────────────────────────────────────────────────────

  test "get_repo resolves by UUID and by full_name, with token preload", %{org: org} do
    token = create_token!(org.id, "repo-token")
    repo = create_repo!(org.id, "org/alpha", %{token_id: token.id})

    by_uuid = Github.get_repo(org.id, repo.id)
    assert by_uuid.id == repo.id
    assert by_uuid.token.id == token.id

    by_name = Github.get_repo(org.id, "org/alpha")
    assert by_name.id == repo.id
    assert by_name.token.label == "repo-token"

    assert Github.get_repo(org.id, "org/missing") == nil
    assert Github.get_repo(Ecto.UUID.generate(), repo.id) == nil
  end

  test "update_repo changes token and acl; unknown repo is not_found", %{org: org} do
    repo = create_repo!(org.id, "org/beta")
    token = create_token!(org.id, "new-token")

    assert {:ok, updated} =
             Github.update_repo(repo.id, %{"token_id" => token.id, "default_acl" => "org_read"})

    assert updated.token_id == token.id
    assert updated.default_acl == "org_read"

    assert {:ok, updated2} = Github.update_repo(repo.id, %{default_acl: "private"})
    assert updated2.default_acl == "private"

    assert {:error, :not_found} =
             Github.update_repo(Ecto.UUID.generate(), %{default_acl: "org_write"})
  end

  test "update_repo_token delegates to update_repo", %{org: org} do
    repo = create_repo!(org.id, "org/gamma")
    token = create_token!(org.id, "delegate-token")

    assert {:ok, updated} = Github.update_repo_token(repo.id, token.id)
    assert updated.token_id == token.id
  end

  test "delete_repo removes and then reports not_found", %{org: org} do
    repo = create_repo!(org.id, "org/delta")

    assert {:ok, _} = Github.delete_repo(repo.id)
    assert {:error, :not_found} = Github.delete_repo(repo.id)
  end

  # ── ACL matrix ───────────────────────────────────────────────────

  test "can_access? honors org default ACLs for org members", %{org: org, user: user} do
    viewer = ensure_system_group!("viewer")
    add_member!("organization", org.id, "user", user.id, viewer)

    write_repo = create_repo!(org.id, "org/w", %{default_acl: "org_write"})
    read_repo = create_repo!(org.id, "org/r", %{default_acl: "org_read"})
    private_repo = create_repo!(org.id, "org/p", %{default_acl: "private"})

    assert Github.can_access?(user.id, write_repo, :read)
    assert Github.can_access?(user.id, write_repo, :write)
    assert Github.can_access?(user.id, read_repo, :read)
    refute Github.can_access?(user.id, read_repo, :write)
    refute Github.can_access?(user.id, private_repo, :read)

    # a non-member gets nothing from org defaults
    outsider = Ecto.UUID.generate()
    refute Github.can_access?(outsider, write_repo, :read)
    refute Github.can_access?(outsider, read_repo, :read)
  end

  test "group grants add access on top of private defaults", %{org: org, user: user} do
    viewer = ensure_system_group!("viewer")
    member = ensure_system_group!("member")
    lead = ensure_system_group!("lead")
    repo = create_repo!(org.id, "org/grant", %{default_acl: "private"})

    # an invalid level never reaches the body — the guard raises
    assert_raise FunctionClauseError, fn ->
      Github.grant_repo_access(repo.id, lead.id, :bogus)
    end

    assert {:ok, read_grant} = Github.grant_repo_access(repo.id, lead.id, :read)
    assert {:ok, write_grant} = Github.grant_repo_access(repo.id, member.id, :write)

    grants = Github.list_repo_grants(repo.id)
    assert length(grants) == 2
    assert Enum.any?(grants, &(&1.group_name == "viewer"))

    # before the user is in any granted group, a private repo grants nothing
    refute Github.can_access?(user.id, repo, :read)
    refute Github.can_access?(user.id, repo, :write)

    # user joins the lead-granted group (one membership per resource+member)
    membership = add_member!("github_repo", repo.id, "user", user.id, lead)
    assert Github.can_access?(user.id, repo, :read)
    # lead is not a write-capable role
    refute Github.can_access?(user.id, repo, :write)

    # move the membership to the member-granted group ⇒ write unlocks
    membership |> Ecto.Changeset.change(group_id: member.id) |> Repo.update!()
    assert Github.can_access?(user.id, repo, :read)
    assert Github.can_access?(user.id, repo, :write)

    # revoking the write grant removes write; read goes too — the user MOVED
    # out of the lead group earlier, and the lead grant no longer matches them
    assert {:ok, _} = Github.revoke_repo_grant(write_grant.id)
    assert {:error, :not_found} = Github.revoke_repo_grant(write_grant.id)
    refute Github.can_access?(user.id, repo, :read)
    refute Github.can_access?(user.id, repo, :write)

    assert {:ok, _} = Github.revoke_repo_grant(read_grant.id)
    assert length(Github.list_repo_grants(repo.id)) == 0
    refute Github.can_access?(user.id, repo, :read)

    # viewer group is referenced by the grants query shape; keep it alive
    assert viewer.id
  end

  test "can_access? denies everything for private repos without grants", %{org: org} do
    repo = create_repo!(org.id, "org/locked", %{default_acl: "private"})
    outsider = Ecto.UUID.generate()

    refute Github.can_access?(outsider, repo, :read)
    refute Github.can_access?(outsider, repo, :write)
  end
end
