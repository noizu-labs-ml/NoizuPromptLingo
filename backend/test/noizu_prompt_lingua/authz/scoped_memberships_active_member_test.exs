defmodule NoizuPromptLingua.Authz.ScopedMembershipsActiveMemberTest do
  use NoizuPromptLingua.DataCase, async: true

  @moduledoc """
  PRD-N3 FR-3-8 / AC-N3-6 — the `active_member?/4` matrix: active user /
  expired user / persona member / absent, plus the group_id role binding the
  group-set gate relies on.
  """

  alias NoizuPromptLingua.Authz.ScopedMemberships

  setup do
    org_id = Ecto.UUID.generate()
    user_id = Ecto.UUID.generate()
    persona_id = Ecto.UUID.generate()

    {:ok, _} = ScopedMemberships.add_member("organization", org_id, user_id, "member")
    {:ok, _} = ScopedMemberships.add_persona_member("organization", org_id, persona_id, "member")

    %{org_id: org_id, user_id: user_id, persona_id: persona_id}
  end

  test "active user ⇒ true", %{org_id: org_id, user_id: user_id} do
    assert ScopedMemberships.active_member?("organization", org_id, %{type: :user, id: user_id})
  end

  test "bare binary id is treated as a user ref", %{org_id: org_id, user_id: user_id} do
    assert ScopedMemberships.active_member?("organization", org_id, user_id)
  end

  test "persona member ⇒ true", %{org_id: org_id, persona_id: persona_id} do
    assert ScopedMemberships.active_member?("organization", org_id, %{
             type: :persona,
             id: persona_id
           })
  end

  test "expired membership ⇒ false", %{org_id: org_id, user_id: user_id} do
    membership =
      NoizuPromptLingua.Repo.get_by!(
        NoizuPromptLingua.Schema.Authz.ScopedMembership,
        resource_type: "organization",
        resource_id: org_id,
        member_type: "user",
        member_id: user_id
      )

    past = DateTime.add(DateTime.utc_now(), -60, :second)

    membership
    |> Ecto.Changeset.change(%{expires_at: past})
    |> NoizuPromptLingua.Repo.update!()

    refute ScopedMemberships.active_member?("organization", org_id, %{type: :user, id: user_id})
  end

  test "absent row ⇒ false", %{org_id: org_id} do
    refute ScopedMemberships.active_member?("organization", org_id, %{
             type: :user,
             id: Ecto.UUID.generate()
           })

    refute ScopedMemberships.active_member?("organization", Ecto.UUID.generate(), %{
             type: :persona,
             id: Ecto.UUID.generate()
           })
  end

  test "group_id binding: membership carries the role group ⇒ true, otherwise false", %{
    org_id: org_id,
    user_id: user_id
  } do
    member_group =
      NoizuPromptLingua.Repo.get_by!(NoizuPromptLingua.Schema.Authz.Group, name: "member")

    admin_group =
      NoizuPromptLingua.Repo.get_by!(NoizuPromptLingua.Schema.Authz.Group, name: "admin")

    ref = %{type: :user, id: user_id}

    assert ScopedMemberships.active_member?("organization", org_id, ref,
             group_id: member_group.id
           )

    refute ScopedMemberships.active_member?("organization", org_id, ref, group_id: admin_group.id)
  end

  test "other resources stay isolated", %{org_id: _org_id, user_id: user_id} do
    refute ScopedMemberships.active_member?("project", Ecto.UUID.generate(), %{
             type: :user,
             id: user_id
           })
  end
end
