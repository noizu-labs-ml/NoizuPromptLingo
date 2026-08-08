defmodule NoizuPromptLinguaWeb.GroupControllerTest do
  @moduledoc """
  `GET /api/v1/groups/:id` accepts either a group UUID or a role name, and the
  two are told apart by a UUID discriminator. This file exists because that
  discriminator is a known trap and this endpoint had no coverage at all.

  `groups.name` is the Postgres enum `role_name_enum` (Liquibase 014, plus
  'lead' from 053), which makes the *hidden-record* form of the 16-character
  bug unreachable here: no group named `sixteen-char-abc` can exist, because
  the database itself rejects the insert. That is a schema fact, not an
  application one — `Group.changeset/2` also screens the value, but a seed
  script or direct SQL bypasses the changeset and still cannot create one.

  It does not make the endpoint uninteresting, because the enum cuts the other
  way on reads: comparing the column to a value outside the enum does not
  return zero rows, it **raises**. So an unknown name is a 500 unless something
  screens it first. These tests pin the not-found contract the controller
  already assumes (`nil -> 404`) across every shape of bad input.
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Authz.Groups

  setup %{conn: conn} do
    %{access_token: token} = setup_user_and_token()
    {:ok, conn: authenticated_conn(conn, token)}
  end

  describe "GET /api/v1/groups/:id by role name" do
    test "resolves a real role name", %{conn: conn} do
      body = json_response(get(conn, "/api/v1/groups/admin"), 200)
      assert body["group"]["name"] == "admin"
    end

    test "a 16-character name is 404, not 500", %{conn: conn} do
      # The discriminator case. Before the UUID fix this was classified as a
      # UUID and answered 404 by accident, via the id branch; routing it to the
      # name branch is only safe because get_by_name/1 screens the enum.
      assert byte_size("sixteen-char-abc") == 16
      assert json_response(get(conn, "/api/v1/groups/sixteen-char-abc"), 404)
    end

    test "unknown names of other lengths are 404, not 500", %{conn: conn} do
      # These never went near the UUID branch, and each one raised
      # `invalid input value for enum role_name_enum` before the screen.
      for name <- ["nonexistent", "nope", "not-a-role-at-all", "Admin"] do
        assert json_response(get(conn, "/api/v1/groups/#{name}"), 404),
               "expected 404 for #{name}"
      end
    end
  end

  describe "GET /api/v1/groups/:id by uuid" do
    test "resolves a real group by its uuid", %{conn: conn} do
      group = Groups.get_by_name("admin")
      body = json_response(get(conn, "/api/v1/groups/#{group.id}"), 200)
      assert body["group"]["id"] == group.id
      assert body["group"]["name"] == "admin"
    end

    test "an unknown but well-formed uuid is 404", %{conn: conn} do
      assert json_response(get(conn, "/api/v1/groups/#{Ecto.UUID.generate()}"), 404)
    end
  end

  describe "Groups.get_by_name/1 directly" do
    test "returns the group for every legal role name" do
      for name <- NoizuPromptLingua.Schema.Authz.Group.role_names() do
        assert %{name: ^name} = Groups.get_by_name(name)
      end
    end

    test "returns nil rather than raising for values outside the enum" do
      # Unscreened, each of these raises Postgrex invalid-enum-input.
      assert Groups.get_by_name("sixteen-char-abc") == nil
      assert Groups.get_by_name("nonexistent") == nil
      assert Groups.get_by_name("") == nil
      assert Groups.get_by_name(Ecto.UUID.generate()) == nil
    end
  end
end
