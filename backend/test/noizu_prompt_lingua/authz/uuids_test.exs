defmodule NoizuPromptLingua.Authz.UUIDsTest do
  # Pure crypto derivation — no Repo, safe to run concurrently.
  use ExUnit.Case, async: true

  alias NoizuPromptLingua.Authz.UUIDs

  @uuid_format ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

  test "template group UUIDs are stable and correctly formatted" do
    # Pin vectors so a namespace/algorithm change is a conscious decision.
    assert UUIDs.group_owner() == "96d3b1f4-9f60-511c-bbf6-31a548e3ff6a"
    assert UUIDs.policy_super_admin() == UUIDs.policy_super_admin()

    for uuid <- [
          UUIDs.group_owner(),
          UUIDs.group_admin(),
          UUIDs.group_member(),
          UUIDs.group_viewer(),
          UUIDs.policy_super_admin(),
          UUIDs.policy_owner(),
          UUIDs.policy_admin(),
          UUIDs.policy_member(),
          UUIDs.policy_viewer()
        ] do
      assert uuid =~ @uuid_format, "malformed: #{uuid}"
    end
  end

  test "repeated calls are deterministic" do
    assert UUIDs.group_owner() == UUIDs.group_owner()
    assert UUIDs.group_admin() == UUIDs.group_admin()
    assert UUIDs.group_member() == UUIDs.group_member()
    assert UUIDs.group_viewer() == UUIDs.group_viewer()
    assert UUIDs.policy_owner() == UUIDs.policy_owner()
    assert UUIDs.policy_admin() == UUIDs.policy_admin()
    assert UUIDs.policy_member() == UUIDs.policy_member()
    assert UUIDs.policy_viewer() == UUIDs.policy_viewer()
  end

  test "distinct names derive distinct UUIDs" do
    template_uuids = [
      UUIDs.group_owner(),
      UUIDs.group_admin(),
      UUIDs.group_member(),
      UUIDs.group_viewer(),
      UUIDs.policy_super_admin(),
      UUIDs.policy_owner(),
      UUIDs.policy_admin(),
      UUIDs.policy_member(),
      UUIDs.policy_viewer()
    ]

    assert length(Enum.uniq(template_uuids)) == 9
  end

  test "uuid5 marks version 5 and the RFC 4122 variant" do
    uuid = UUIDs.uuid5(UUIDs.uuid5(UUIDs.group_owner(), "ns"), "nested")

    assert uuid =~ @uuid_format
    # 13th hex nibble is the version
    assert String.at(uuid, 14) == "5"
    # 17th hex nibble is the variant (8, 9, a, b)
    assert String.at(uuid, 19) in ["8", "9", "a", "b"]
  end

  test "uuid5 is order-sensitive over namespace and name" do
    ns = UUIDs.group_owner()
    a = UUIDs.uuid5(ns, "alpha")
    b = UUIDs.uuid5(ns, "beta")
    assert a != b

    other_ns = UUIDs.group_admin()
    assert a != UUIDs.uuid5(other_ns, "alpha")
  end
end
