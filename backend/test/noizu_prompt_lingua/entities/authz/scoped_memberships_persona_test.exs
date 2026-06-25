defmodule NoizuPromptLingua.Authz.ScopedMembershipsPersonaTest do
  @moduledoc """
  Persona-as-member (ccaf5684 / ADR-017): a persona can be a resource member, listed +
  role-assigned alongside users on the PBAC scoped_memberships path. v1 = data + display;
  sole-owner/cascade + authz-actor stay user-scoped (not exercised here).
  """
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Authz.ScopedMemberships

  setup do
    org_id = insert_org()
    {:ok, org_id: org_id, persona_id: insert_persona(org_id)}
  end

  test "add_persona_member + list_for_resource shows the persona row", %{org_id: org, persona_id: pid} do
    {:ok, _} = ScopedMemberships.add_persona_member("organization", org, pid, "member")

    row = "organization" |> ScopedMemberships.list_for_resource(org) |> Enum.find(&(&1.member_type == "persona"))
    assert row
    assert row.member_id == pid
    assert row.persona_id == pid
    assert row.persona_slug =~ "persona-"
    assert row.display_name == "Test Persona"
    assert row.role == "member"
    assert row.resource_type == "organization"
    # user-only fields are nil for a persona row
    assert row.user_id == nil
  end

  test "add_persona_member is idempotent (re-add keeps one row)", %{org_id: org, persona_id: pid} do
    {:ok, a} = ScopedMemberships.add_persona_member("organization", org, pid, "member")
    {:ok, b} = ScopedMemberships.add_persona_member("organization", org, pid, "member")
    assert a.id == b.id
  end

  test "add_persona_member rejects an unknown role", %{org_id: org, persona_id: pid} do
    assert {:error, :invalid_role} = ScopedMemberships.add_persona_member("organization", org, pid, "wizard")
  end

  test "get_membership returns the persona membership", %{org_id: org, persona_id: pid} do
    {:ok, m} = ScopedMemberships.add_persona_member("organization", org, pid, "member")
    got = ScopedMemberships.get_membership(m.id)
    assert got.member_type == "persona"
    assert got.persona_id == pid
    assert got.role == "member"
  end

  test "update_persona_role reassigns the role", %{org_id: org, persona_id: pid} do
    {:ok, _} = ScopedMemberships.add_persona_member("organization", org, pid, "member")
    {:ok, _} = ScopedMemberships.update_persona_role("organization", org, pid, "lead")

    row = "organization" |> ScopedMemberships.list_for_resource(org) |> Enum.find(&(&1.member_type == "persona"))
    assert row.role == "lead"
  end

  test "update_persona_role 404 when the persona isn't a member", %{org_id: org, persona_id: pid} do
    assert {:error, :not_found} = ScopedMemberships.update_persona_role("organization", org, pid, "lead")
  end

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["pmorg-#{System.unique_integer([:positive])}", "Persona Member Org"]
      )

    Ecto.UUID.load!(raw)
  end

  defp insert_persona(org_id) do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO personas (id, organization_id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1::uuid, $2, $3, now(), now()) RETURNING id",
        [Ecto.UUID.dump!(org_id), "persona-#{System.unique_integer([:positive])}", "Test Persona"]
      )

    Ecto.UUID.load!(raw)
  end
end
