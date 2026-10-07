defmodule NoizuPromptLinguaWeb.PolicyControllerTest do
  @moduledoc """
  /api/v1/policies admin CRUD (RequireAdmin pipeline, system-policy guard,
  404/422 arms) plus the authenticated policy surface: check, explain,
  my_policies, and attach/detach.
  """
  use NoizuPromptLinguaWeb.ConnCase

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Authz.Policy
  alias NoizuPromptLingua.Schema.Users.User

  setup %{conn: conn} do
    %{user: user, access_token: token} = setup_user_and_token()

    Repo.get!(User, user.id) |> Ecto.Changeset.change(role: :admin) |> Repo.update!()

    auth = authenticated_conn(conn, token)
    %{access_token: outsider_token} = setup_user_and_token()

    {:ok, auth: auth, user: user, outsider_token: outsider_token}
  end

  defp pname, do: "pol-#{System.unique_integer([:positive])}"

  defp policy_attrs(name) do
    %{
      "name" => name,
      "description" => "test policy",
      "policy_document" => %{
        "statements" => [%{"effect" => "allow", "actions" => ["ticket:read"]}]
      }
    }
  end

  defp make_system!(id) do
    Repo.get!(Policy, id) |> Ecto.Changeset.change(is_system: true) |> Repo.update!()
  end

  # ── admin CRUD ────────────────────────────────────────────────────────────

  test "create → show → update → delete lifecycle", %{auth: auth} do
    name = pname()

    %{"policy" => %{"id" => id, "name" => ^name}} =
      auth |> post("/api/v1/policies", %{policy: policy_attrs(name)}) |> json_response(201)

    assert %{"policy" => %{"id" => ^id}} =
             auth |> get("/api/v1/policies/#{id}") |> json_response(200)

    assert %{"policy" => %{"description" => "renamed"}} =
             auth
             |> put("/api/v1/policies/#{id}", %{
               policy: %{"description" => "renamed"}
             })
             |> json_response(200)

    assert %{"message" => "Policy deleted"} =
             auth |> delete("/api/v1/policies/#{id}") |> json_response(200)

    assert %{"error" => "Policy not found"} =
             auth |> get("/api/v1/policies/#{id}") |> json_response(404)
  end

  test "create without a name → 422", %{auth: auth} do
    conn = post(auth, "/api/v1/policies", %{policy: %{"description" => "x"}})

    assert json_response(conn, 422) |> Map.has_key?("errors")
  end

  test "update unknown → 404; delete unknown → 404", %{auth: auth} do
    missing = Ecto.UUID.generate()

    assert %{"error" => "Policy not found"} =
             auth
             |> put("/api/v1/policies/#{missing}", %{policy: %{"description" => "x"}})
             |> json_response(404)

    assert %{"error" => "Policy not found"} =
             auth |> delete("/api/v1/policies/#{missing}") |> json_response(404)
  end

  test "system policies refuse update and delete → 403", %{auth: auth} do
    %{"policy" => %{"id" => id}} =
      auth |> post("/api/v1/policies", %{policy: policy_attrs(pname())}) |> json_response(201)

    make_system!(id)

    assert %{"error" => "Cannot modify system policy"} =
             auth
             |> put("/api/v1/policies/#{id}", %{policy: %{"description" => "x"}})
             |> json_response(403)

    assert %{"error" => "Cannot delete system policy"} =
             auth |> delete("/api/v1/policies/#{id}") |> json_response(403)
  end

  test "update with invalid attrs → 422", %{auth: auth} do
    %{"policy" => %{"id" => id}} =
      auth |> post("/api/v1/policies", %{policy: policy_attrs(pname())}) |> json_response(201)

    conn = put(auth, "/api/v1/policies/#{id}", %{policy: %{"name" => nil}})

    assert json_response(conn, 422) |> Map.has_key?("errors")
  end

  test "index supports the system_only filter", %{auth: auth} do
    %{"policy" => %{"id" => id}} =
      auth |> post("/api/v1/policies", %{policy: policy_attrs(pname())}) |> json_response(201)

    make_system!(id)

    assert %{"policies" => all} = auth |> get("/api/v1/policies") |> json_response(200)
    assert Enum.any?(all, &(&1["id"] == id))

    assert %{"policies" => system} =
             auth |> get("/api/v1/policies?system_only=true") |> json_response(200)

    assert Enum.any?(system, &(&1["id"] == id and &1["is_system"] == true))
  end

  test "non-admin is forbidden on the admin policy surface", %{auth: auth, outsider_token: t} do
    conn =
      auth
      |> authenticated_conn(t)
      |> get("/api/v1/policies")

    assert json_response(conn, 403)
  end

  # ── authenticated policy surface ──────────────────────────────────────────

  test "check returns the permission decision", %{auth: auth, user: user} do
    org_id = Ecto.UUID.generate()

    assert %{"allowed" => allowed, "action" => "ticket:read", "resource_type" => "organization"} =
             auth
             |> post("/api/v1/policies/check", %{
               "resource_type" => "organization",
               "resource_id" => org_id,
               "action" => "ticket:read"
             })
             |> json_response(200)

    assert is_boolean(allowed)
    assert user.id != nil
  end

  test "explain returns the decision explanation", %{auth: auth} do
    result =
      auth
      |> post("/api/v1/policies/explain", %{
        "resource_type" => "organization",
        "resource_id" => Ecto.UUID.generate(),
        "action" => "ticket:read"
      })
      |> json_response(200)

    assert is_map(result)
  end

  test "my_policies lists the caller's policies", %{auth: auth, user: user} do
    %{"policy" => %{"id" => id}} =
      auth |> post("/api/v1/policies", %{policy: policy_attrs(pname())}) |> json_response(201)

    assert %{"message" => "Policy attached"} =
             auth
             |> post("/api/v1/users/#{user.id}/policies", %{
               "policy_id" => id,
               "resource_type" => "organization",
               "resource_id" => Ecto.UUID.generate()
             })
             |> json_response(201)

    assert %{"policies" => mine} = auth |> get("/api/v1/policies/me") |> json_response(200)
    assert Enum.any?(mine, &(&1["policy_id"] == id))
  end

  test "attach_to_user then detach_from_user; re-detach → 404", %{auth: auth, user: user} do
    %{"policy" => %{"id" => id}} =
      auth |> post("/api/v1/policies", %{policy: policy_attrs(pname())}) |> json_response(201)

    assert %{"message" => "Policy attached"} =
             auth
             |> post("/api/v1/users/#{user.id}/policies", %{
               "policy_id" => id,
               "resource_type" => "organization",
               "resource_id" => Ecto.UUID.generate(),
               "priority" => 7
             })
             |> json_response(201)

    assert %{"message" => "Policy detached"} =
             auth |> delete("/api/v1/users/#{user.id}/policies/#{id}") |> json_response(200)

    assert %{"error" => "Policy attachment not found"} =
             auth |> delete("/api/v1/users/#{user.id}/policies/#{id}") |> json_response(404)
  end
end
