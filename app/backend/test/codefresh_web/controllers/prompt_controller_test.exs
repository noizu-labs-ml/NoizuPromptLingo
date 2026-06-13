defmodule CodefreshWeb.PromptControllerTest do
  use CodefreshWeb.ConnCase, async: true
  import Codefresh.Fixtures

  defp setup_org(conn) do
    %{user: user, organization: org} = org_with_owner()
    {auth_conn(conn, user), user, org}
  end

  describe "POST /organizations/:id/prompts (US-009)" do
    test "creates a prompt with auto-slug", %{conn: conn} do
      {conn, _u, org} = setup_org(conn)

      conn =
        post(conn, ~p"/api/v1/organizations/#{org.id}/prompts", %{
          "prompt" => %{"name" => "Greeter Bot", "description" => "says hi"}
        })

      assert %{"prompt" => %{"slug" => "greeter-bot", "current_version_id" => nil}} =
               json_response(conn, 201)
    end

    test "viewer cannot create (403)", %{conn: conn} do
      {_, _u, org} = setup_org(conn)
      viewer = user_fixture()
      membership_fixture(viewer, org, "viewer")
      vconn = build_conn() |> auth_conn(viewer)

      resp =
        post(vconn, ~p"/api/v1/organizations/#{org.id}/prompts", %{"prompt" => %{"name" => "X"}})

      assert response(resp, 403)
    end

    test "rejects duplicate slug in org", %{conn: conn} do
      {conn, _u, org} = setup_org(conn)

      post(conn, ~p"/api/v1/organizations/#{org.id}/prompts", %{
        "prompt" => %{"name" => "First", "slug" => "dup"}
      })

      resp =
        post(conn, ~p"/api/v1/organizations/#{org.id}/prompts", %{
          "prompt" => %{"name" => "Second", "slug" => "dup"}
        })

      assert %{"errors" => %{"slug" => _}} = json_response(resp, 422)
    end
  end

  describe "POST /organizations/:id/prompts/:id/publish (US-010 + US-048)" do
    test "publishes v1 and advances current_version_id", %{conn: conn} do
      {conn, _u, org} = setup_org(conn)

      %{"prompt" => %{"id" => pid}} =
        post(conn, ~p"/api/v1/organizations/#{org.id}/prompts", %{"prompt" => %{"name" => "P"}})
        |> json_response(201)

      pub =
        post(conn, ~p"/api/v1/organizations/#{org.id}/prompts/#{pid}/publish", %{
          "version" => %{"body" => "hello"}
        })

      assert %{"version" => %{"version_number" => 1}, "status" => "published"} =
               json_response(pub, 201)
    end

    test "identical body → status=noop", %{conn: conn} do
      {conn, _u, org} = setup_org(conn)

      %{"prompt" => %{"id" => pid}} =
        post(conn, ~p"/api/v1/organizations/#{org.id}/prompts", %{"prompt" => %{"name" => "P"}})
        |> json_response(201)

      post(conn, ~p"/api/v1/organizations/#{org.id}/prompts/#{pid}/publish", %{
        "version" => %{"body" => "x"}
      })

      second =
        post(conn, ~p"/api/v1/organizations/#{org.id}/prompts/#{pid}/publish", %{
          "version" => %{"body" => "x"}
        })

      assert %{"status" => "noop", "version" => %{"version_number" => 1}} =
               json_response(second, 200)
    end

    test "undeclared template var is rejected (US-048)", %{conn: conn} do
      {conn, _u, org} = setup_org(conn)

      %{"prompt" => %{"id" => pid}} =
        post(conn, ~p"/api/v1/organizations/#{org.id}/prompts", %{"prompt" => %{"name" => "P"}})
        |> json_response(201)

      resp =
        post(conn, ~p"/api/v1/organizations/#{org.id}/prompts/#{pid}/publish", %{
          "version" => %{
            "body" => "Hi {{name}} from {{city}}",
            "template_vars" => %{"name" => %{}}
          }
        })

      assert %{"undeclared_vars" => ["city"]} = json_response(resp, 422)
    end

    test "declared vars stored with metadata (US-048)", %{conn: conn} do
      {conn, _u, org} = setup_org(conn)

      %{"prompt" => %{"id" => pid}} =
        post(conn, ~p"/api/v1/organizations/#{org.id}/prompts", %{"prompt" => %{"name" => "P"}})
        |> json_response(201)

      resp =
        post(conn, ~p"/api/v1/organizations/#{org.id}/prompts/#{pid}/publish", %{
          "version" => %{
            "body" => "Hi {{name}}",
            "template_vars" => %{"name" => %{"required" => true, "description" => "user"}}
          }
        })

      assert %{"version" => %{"template_vars" => %{"name" => %{"required" => true}}}} =
               json_response(resp, 201)
    end
  end

  describe "GET /organizations/:id/prompts/:id/current-version (US-011)" do
    test "409 when unpublished", %{conn: conn} do
      {conn, _u, org} = setup_org(conn)

      %{"prompt" => %{"id" => pid}} =
        post(conn, ~p"/api/v1/organizations/#{org.id}/prompts", %{"prompt" => %{"name" => "P"}})
        |> json_response(201)

      resp = get(conn, ~p"/api/v1/organizations/#{org.id}/prompts/#{pid}/current-version")
      assert %{"error" => _} = json_response(resp, 409)
    end

    test "returns pinned version after publish", %{conn: conn} do
      {conn, _u, org} = setup_org(conn)

      %{"prompt" => %{"id" => pid}} =
        post(conn, ~p"/api/v1/organizations/#{org.id}/prompts", %{"prompt" => %{"name" => "P"}})
        |> json_response(201)

      post(conn, ~p"/api/v1/organizations/#{org.id}/prompts/#{pid}/publish", %{
        "version" => %{"body" => "hi"}
      })

      resp = get(conn, ~p"/api/v1/organizations/#{org.id}/prompts/#{pid}/current-version")
      assert %{"version" => %{"version_number" => 1, "body" => "hi"}} = json_response(resp, 200)
    end

    test "404 across orgs", %{conn: conn} do
      {conn1, _u1, org1} = setup_org(conn)
      {_, _u2, org2} = setup_org(build_conn())

      %{"prompt" => %{"id" => pid}} =
        post(conn1, ~p"/api/v1/organizations/#{org1.id}/prompts", %{"prompt" => %{"name" => "P"}})
        |> json_response(201)

      user2 = user_fixture()
      membership_fixture(user2, org2, "owner")
      conn2 = build_conn() |> auth_conn(user2)
      resp = get(conn2, ~p"/api/v1/organizations/#{org2.id}/prompts/#{pid}/current-version")
      assert response(resp, 404)
    end
  end

  describe "GET /organizations/:id/prompts (US-050)" do
    test "lists with usage_count and supports search", %{conn: conn} do
      {conn, _u, org} = setup_org(conn)

      post(conn, ~p"/api/v1/organizations/#{org.id}/prompts", %{
        "prompt" => %{"name" => "Greeter"}
      })

      post(conn, ~p"/api/v1/organizations/#{org.id}/prompts", %{
        "prompt" => %{"name" => "Summarizer"}
      })

      all = get(conn, ~p"/api/v1/organizations/#{org.id}/prompts") |> json_response(200)
      assert length(all["prompts"]) == 2
      assert Enum.all?(all["prompts"], &(&1["usage_count"] == 0))

      filtered =
        get(conn, ~p"/api/v1/organizations/#{org.id}/prompts?q=sum") |> json_response(200)

      assert Enum.map(filtered["prompts"], & &1["name"]) == ["Summarizer"]
    end

    test "hides archived by default, exposes with include_archived", %{conn: conn} do
      {conn, _u, org} = setup_org(conn)

      %{"prompt" => %{"id" => pid}} =
        post(conn, ~p"/api/v1/organizations/#{org.id}/prompts", %{"prompt" => %{"name" => "Gone"}})
        |> json_response(201)

      delete(conn, ~p"/api/v1/organizations/#{org.id}/prompts/#{pid}")

      default = get(conn, ~p"/api/v1/organizations/#{org.id}/prompts") |> json_response(200)
      assert default["prompts"] == []

      with_archived =
        get(conn, ~p"/api/v1/organizations/#{org.id}/prompts?include_archived=true")
        |> json_response(200)

      assert length(with_archived["prompts"]) == 1
    end
  end
end
