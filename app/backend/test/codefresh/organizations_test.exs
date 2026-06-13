defmodule Codefresh.OrganizationsTest do
  use Codefresh.DataCase, async: true

  alias Codefresh.Organizations
  import Codefresh.Fixtures

  describe "create_organization_with_owner/2" do
    test "creates org + owner membership atomically" do
      user = user_fixture()

      assert {:ok, %{organization: org, membership: m}} =
               Organizations.create_organization_with_owner(
                 %{"slug" => "atomic", "name" => "Atomic"},
                 user
               )

      assert org.slug == "atomic"
      assert m.role == "owner"
      assert m.user_id == user.id
    end

    test "rolls back when slug collides" do
      user = user_fixture()
      _ = org_with_owner(%{slug: "dup", name: "First"})

      assert {:error, %Ecto.Changeset{}} =
               Organizations.create_organization_with_owner(
                 %{"slug" => "dup", "name" => "Second"},
                 user
               )
    end
  end

  describe "authorize/3" do
    test "grants at-or-above role" do
      %{user: owner, organization: org} = org_with_owner()
      assert {:ok, "owner"} = Organizations.authorize(owner, org.id, "admin")
      assert {:ok, "owner"} = Organizations.authorize(owner, org.id, "owner")
    end

    test "denies below required role" do
      %{user: _owner, organization: org} = org_with_owner()
      viewer = user_fixture()
      membership_fixture(viewer, org, "viewer")
      assert {:error, :forbidden} = Organizations.authorize(viewer, org.id, "admin")
    end

    test "reports not-a-member" do
      %{user: _owner, organization: org} = org_with_owner()
      stranger = user_fixture()
      assert {:error, :not_a_member} = Organizations.authorize(stranger, org.id, "viewer")
    end
  end
end
