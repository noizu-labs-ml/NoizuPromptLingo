defmodule NoizuPromptLingua.Authz.ExplainRoleLadderTest do
  @moduledoc """
  Regression + RULING (fix/error-family B6, probe rows 343/344): the live probe
  showed `/policies/check` answering allowed:true while `/policies/explain`
  answered allowed:false, reason implicit_deny for the SAME input — the two
  endpoints ran two different engines (role ladder vs policy documents).

  Ruling: policy documents OVERLAY the role ladder. An explicit policy allow or
  deny wins; an IMPLICIT policy deny (no statement matched) defers to the role
  ladder — the same engine `check/4` uses — so check and explain can never
  diverge. When the ladder allows, explain reports reason `:role_allow`.

  KNOWN REMAINING GAP (flagged for lead review, out of scope here):
  `check/4` itself never consults policy documents, so an explicit policy DENY
  flips `explain` to false while `check` still answers true. Unifying check
  onto the overlay model is a semantic change to every controller gate and
  needs an explicit ruling.
  """

  use NoizuPromptLingua.DataCase

  alias NoizuPromptLingua.Authz
  alias NoizuPromptLingua.Authz.ScopedMemberships
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Authz.{GroupPolicy, Policy}

  setup do
    owner_id = insert_user()
    viewer_id = insert_user()
    org_id = Ecto.UUID.generate()

    # added_by must reference a real user (scoped_memberships_added_by_fkey).
    {:ok, _} = ScopedMemberships.add_member("organization", org_id, owner_id, "owner", owner_id)

    %{owner_id: owner_id, viewer_id: viewer_id, org_id: org_id}
  end

  defp insert_user do
    uniq = System.unique_integer([:positive])

    %NoizuPromptLingua.Schema.Users.User{
      id: Ecto.UUID.generate(),
      email: "pbac-#{uniq}@example.com",
      user_name: "pbac#{uniq}",
      handle: "pbac#{uniq}",
      status: :active,
      verified: false,
      flagged: false
    }
    |> Repo.insert!()
    |> Map.fetch!(:id)
  end

  test "owner + no matching deny: check true AND explain true — no divergence", %{
    owner_id: owner_id,
    org_id: org_id
  } do
    check = Authz.check_permission(owner_id, "organization", org_id, "projects:read")
    explain = Authz.explain_permission(owner_id, "organization", org_id, "projects:read")

    assert check
    # Owner's group carries the seeded system:owner policy, whose statements
    # match, so the honest reason is :explicit_allow; :role_allow fires only
    # when no statement matched and the ladder decided. Either way it must
    # AGREE with check (the probe divergence is the regression).
    assert explain.allowed == check
    assert explain.reason in [:role_allow, :explicit_allow]
  end

  test "member + unlisted action: ladder allows, no statement matches → explain true :role_allow",
       %{
         owner_id: owner_id,
         org_id: org_id
       } do
    member_user_id = insert_user()

    {:ok, _} =
      ScopedMemberships.add_member("organization", org_id, member_user_id, "member", owner_id)

    # "projects:create" (plural, as the REST surface sends it) matches NO
    # system:member statement (that policy lists singular "project:create" and
    # "*:view"/"*:list"), so evaluation lands on implicit_deny and the ladder
    # (member floor ≤ member rank) decides → explain must report :role_allow.
    action = "projects:create"

    check = Authz.check_permission(member_user_id, "organization", org_id, action)
    explain = Authz.explain_permission(member_user_id, "organization", org_id, action)

    assert check
    assert explain.allowed
    assert explain.reason == :role_allow
  end

  test "explicit policy deny still wins over the role ladder in explain", %{
    owner_id: owner_id,
    org_id: org_id
  } do
    {:ok, policy} =
      Repo.insert(%Policy{
        name: "deny-all-#{System.unique_integer([:positive])}",
        policy_document: %{
          "statements" => [
            %{"effect" => "deny", "actions" => ["*"], "resources" => ["*"]}
          ]
        }
      })

    group_id = group_id_for(owner_id, org_id)
    Repo.insert(%GroupPolicy{group_id: group_id, policy_id: policy.id, priority: 0})

    explain = Authz.explain_permission(owner_id, "organization", org_id, "projects:read")
    refute explain.allowed
    assert explain.reason == :explicit_deny
  end

  test "explicit policy allow is preserved (:explicit_allow)", %{
    owner_id: owner_id,
    org_id: org_id
  } do
    {:ok, policy} =
      Repo.insert(%Policy{
        name: "allow-read-#{System.unique_integer([:positive])}",
        policy_document: %{
          "statements" => [
            %{
              "effect" => "allow",
              "actions" => ["projects:read"],
              "resources" => ["organization:#{org_id}"]
            }
          ]
        }
      })

    group_id = group_id_for(owner_id, org_id)
    Repo.insert(%GroupPolicy{group_id: group_id, policy_id: policy.id, priority: 0})

    explain = Authz.explain_permission(owner_id, "organization", org_id, "projects:read")
    assert explain.allowed
    assert explain.reason == :explicit_allow
  end

  test "member whose ladder rank denies the action: check false AND explain false", %{
    owner_id: owner_id,
    viewer_id: viewer_id,
    org_id: org_id
  } do
    {:ok, _} = ScopedMemberships.add_member("organization", org_id, viewer_id, "viewer", owner_id)

    refute Authz.check_permission(viewer_id, "organization", org_id, "projects:delete")

    explain = Authz.explain_permission(viewer_id, "organization", org_id, "projects:delete")
    refute explain.allowed
    assert explain.reason == :implicit_deny
  end

  test "non-member: check false AND explain :not_a_member", %{org_id: org_id} do
    outsider = insert_user()

    refute Authz.check_permission(outsider, "organization", org_id, "projects:read")

    explain = Authz.explain_permission(outsider, "organization", org_id, "projects:read")
    refute explain.allowed
    assert explain.reason == :not_a_member
  end

  defp group_id_for(owner_id, org_id) do
    from = NoizuPromptLingua.Schema.Authz.ScopedMembership

    Repo.one!(
      from(sm in from,
        where:
          sm.member_type == "user" and sm.member_id == ^owner_id and
            sm.resource_type == "organization" and sm.resource_id == ^org_id,
        select: sm.group_id
      )
    )
  end
end
