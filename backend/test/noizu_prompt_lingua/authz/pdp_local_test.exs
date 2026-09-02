defmodule NoizuPromptLingua.Authz.Pdp.LocalTest do
  # Local.check/1 queries OAuth Clients/Grants on the app repo — needs sandbox checkout
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Authz.Pdp.Local
  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLingua.OAuth.Clients
  alias NoizuPromptLingua.OAuth.Grants
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Users.User

  setup do
    NoizuPromptLingua.OAuthTestSchema.ensure!()

    uniq = System.unique_integer([:positive])

    user =
      %User{
        id: Ecto.UUID.generate(),
        email: "pdp-#{uniq}@example.com",
        user_name: "pdp#{uniq}",
        handle: "pdp#{uniq}",
        status: :active,
        verified: true,
        flagged: false
      }
      |> Repo.insert!()

    org_id = Ecto.UUID.generate()
    project_id = Ecto.UUID.generate()

    %{user: user, org_id: org_id, project_id: project_id}
  end

  # ── Baseline (pre-existing) ─────────────────────────────────────

  test "API-key style request (no client_id) with user_id allows" do
    assert :ok =
             Local.check(%{
               user_id: Ecto.UUID.generate()
             })
  end

  test "unknown client_id denies" do
    assert {:error, :client_not_allowed} =
             Local.check(%{
               user_id: Ecto.UUID.generate(),
               client_id: "dcr_does_not_exist_xyz"
             })
  end

  test "revoked grant_id denies when grant missing" do
    assert {:error, :grant_revoked} =
             Local.check(%{
               user_id: Ecto.UUID.generate(),
               grant_id: "pg_missing_grant_xyz"
             })
  end

  # ── Axis 2: client capability ────────────────────────────────────

  test "registered active client passes the client axis", %{user: user} do
    {:ok, reg} = register_client("pdp-cli")

    assert :ok = Local.check(%{user_id: user.id, client_id: reg["client_id"]})
  end

  test "revoked client denies", %{user: user} do
    {:ok, reg} = register_client("pdp-dead")

    client = Repo.get_by!(NoizuPromptLingua.Schema.OAuthClient, client_id: reg["client_id"])

    client
    |> Ecto.Changeset.change(%{status: "revoked"})
    |> Repo.update!()

    assert {:error, :client_not_allowed} =
             Local.check(%{user_id: user.id, client_id: reg["client_id"]})
  end

  # ── Axis 3: pairing grant ────────────────────────────────────────

  test "explicit active grant_id allows", %{user: user} do
    grant = Grants.approve!(user.id, "dcr_grant_axis", "https://r.example/mcp")
    assert :ok = Local.check(%{user_id: user.id, grant_id: grant.grant_id})
  end

  test "revoked grant_id denies with :grant_revoked", %{user: user} do
    grant = Grants.approve!(user.id, "dcr_revoke_axis", "https://r.example/mcp")
    Grants.revoke!(grant.grant_id)

    assert {:error, :grant_revoked} = Local.check(%{user_id: user.id, grant_id: grant.grant_id})
  end

  test "exact user+client+resource grant allows without grant_id", %{user: user} do
    {:ok, reg} = register_client("dcr_exact")
    resource = "https://exact.example/mcp"
    Grants.approve!(user.id, reg["client_id"], resource)

    assert :ok =
             Local.check(%{user_id: user.id, client_id: reg["client_id"], resource: resource})
  end

  test "any active grant for the user+client expands to other resources", %{user: user} do
    {:ok, reg} = register_client("dcr_expand")
    Grants.approve!(user.id, reg["client_id"], "https://known.example/mcp")

    assert :ok =
             Local.check(%{
               user_id: user.id,
               client_id: reg["client_id"],
               resource: "https://other.example/mcp"
             })
  end

  test "oauth client with no grants for the user denies :no_pairing_grant", %{user: user} do
    {:ok, reg} = register_client("pdp-nogrant")

    assert {:error, :no_pairing_grant} =
             Local.check(%{
               user_id: user.id,
               client_id: reg["client_id"],
               resource: "https://x.example/mcp"
             })
  end

  test "empty-string grant_id falls through to the no-grant-context path" do
    assert :ok = Local.check(%{user_id: Ecto.UUID.generate(), grant_id: ""})
  end

  # ── Axis 1: user role on resource ────────────────────────────────

  test "viewer membership satisfies viewer requirement (atom + binary forms)", %{
    user: user,
    project_id: project_id
  } do
    ScopedMemberships.add_member("project", project_id, user.id, "viewer")

    assert :ok =
             Local.check(%{
               user_id: user.id,
               resource_type: :project,
               resource_id: project_id,
               required_role: :viewer
             })

    assert :ok =
             Local.check(%{
               user_id: user.id,
               resource_type: "project",
               resource_id: project_id,
               required_role: "viewer"
             })
  end

  test "viewer membership denies member requirement with :insufficient_role", %{
    user: user,
    org_id: org_id
  } do
    ScopedMemberships.add_member("organization", org_id, user.id, "viewer")

    assert {:error, :insufficient_role} =
             Local.check(%{
               user_id: user.id,
               resource_type: "organization",
               resource_id: org_id,
               required_role: "member"
             })
  end

  test "lead membership satisfies member/lead requirements via rank ladder", %{
    user: user,
    org_id: org_id
  } do
    # Ranks descend with privilege (viewer < member < lead < admin < owner), so
    # a lead can act at member level but not at admin level.
    ScopedMemberships.add_member("organization", org_id, user.id, "lead")

    assert :ok =
             Local.check(%{
               user_id: user.id,
               resource_type: "organization",
               resource_id: org_id,
               required_role: "member"
             })

    assert {:error, :insufficient_role} =
             Local.check(%{
               user_id: user.id,
               resource_type: "organization",
               resource_id: org_id,
               required_role: "admin"
             })
  end

  test "non-member denies with :not_a_member" do
    assert {:error, :not_a_member} =
             Local.check(%{
               user_id: Ecto.UUID.generate(),
               resource_type: :project,
               resource_id: Ecto.UUID.generate(),
               required_role: :viewer
             })
  end

  test "unknown binary resource_type fails closed instead of crashing" do
    # Regression: String.to_existing_atom raised ArgumentError on unseen atoms.
    assert {:error, :not_a_member} =
             Local.check(%{
               user_id: Ecto.UUID.generate(),
               resource_type: "definitely_not_an_atom_xyz",
               resource_id: Ecto.UUID.generate(),
               required_role: :viewer
             })
  end

  test "non-binary user_id denies :no_identity" do
    assert {:error, :no_identity} =
             Local.check(%{user_id: 12_345, resource_type: :project, resource_id: "x", required_role: :viewer})
  end

  defp register_client(name) do
    Clients.register(%{
      "client_name" => name,
      "redirect_uris" => ["http://127.0.0.1:9876/callback"],
      "token_endpoint_auth_method" => "none"
    })
  end
end
