defmodule CodefreshWeb.WebhookControllerTest do
  use CodefreshWeb.ConnCase, async: true
  import Codefresh.Fixtures

  alias Codefresh.Webhooks

  describe "POST /api/v1/organizations/:id/webhooks (US-144)" do
    test "admin creates webhook; secret shown once", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      conn = auth_conn(conn, owner)

      conn =
        post(conn, ~p"/api/v1/organizations/#{org.id}/webhooks", %{
          "webhook" => %{
            "name" => "slack-ping",
            "endpoint_url" => "https://hooks.example.com/slack",
            "event_filters" => ["run.completed", "run.errored"]
          }
        })

      resp = json_response(conn, 201)
      assert resp["webhook"]["name"] == "slack-ping"
      assert resp["webhook"]["event_filters"] == ["run.completed", "run.errored"]
      assert is_binary(resp["secret"]) and String.length(resp["secret"]) > 20
      refute Map.has_key?(resp["webhook"], "secret")
    end

    test "editor cannot create (403)", %{conn: conn} do
      %{organization: org} = org_with_owner()
      editor = user_fixture()
      membership_fixture(editor, org, "editor")
      conn = auth_conn(conn, editor)

      conn =
        post(conn, ~p"/api/v1/organizations/#{org.id}/webhooks", %{
          "webhook" => %{"name" => "x", "endpoint_url" => "https://e.com/h"}
        })

      assert response(conn, 403)
    end

    test "rejects unknown event filter (422)", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()
      conn = auth_conn(conn, owner)

      conn =
        post(conn, ~p"/api/v1/organizations/#{org.id}/webhooks", %{
          "webhook" => %{
            "name" => "bad",
            "endpoint_url" => "https://e.com/h",
            "event_filters" => ["not.a.real.event"]
          }
        })

      assert %{"errors" => %{"event_filters" => _}} = json_response(conn, 422)
    end
  end

  describe "GET /api/v1/organizations/:id/webhooks" do
    test "lists webhooks; never exposes secret", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()

      {:ok, _} =
        Webhooks.create_webhook(%{
          "organization_id" => org.id,
          "name" => "a",
          "endpoint_url" => "https://e.com/a",
          "event_filters" => ["run.completed"]
        })

      conn =
        conn
        |> auth_conn(owner)
        |> get(~p"/api/v1/organizations/#{org.id}/webhooks")

      %{"webhooks" => [wh]} = json_response(conn, 200)
      refute Map.has_key?(wh, "secret")
      assert wh["name"] == "a"
    end

    test "cross-org isolation: member of org A cannot list org B webhooks", %{conn: conn} do
      %{organization: org_a} = org_with_owner()
      %{user: owner_b} = org_with_owner()

      conn = auth_conn(conn, owner_b)
      resp = get(conn, ~p"/api/v1/organizations/#{org_a.id}/webhooks")
      assert response(resp, 404)
    end
  end

  describe "PATCH /api/v1/organizations/:id/webhooks/:id" do
    test "admin toggles active", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()

      {:ok, w} =
        Webhooks.create_webhook(%{
          "organization_id" => org.id,
          "name" => "toggleme",
          "endpoint_url" => "https://e.com/t",
          "event_filters" => ["run.completed"]
        })

      conn =
        conn
        |> auth_conn(owner)
        |> patch(~p"/api/v1/organizations/#{org.id}/webhooks/#{w.id}", %{
          "webhook" => %{"active" => false}
        })

      assert %{"webhook" => %{"active" => false}} = json_response(conn, 200)
    end
  end

  describe "DELETE /api/v1/organizations/:id/webhooks/:id" do
    test "admin deletes webhook", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()

      {:ok, w} =
        Webhooks.create_webhook(%{
          "organization_id" => org.id,
          "name" => "delme",
          "endpoint_url" => "https://e.com/d",
          "event_filters" => ["run.completed"]
        })

      conn =
        conn
        |> auth_conn(owner)
        |> delete(~p"/api/v1/organizations/#{org.id}/webhooks/#{w.id}")

      assert response(conn, 204)
      assert Webhooks.list_webhooks(org.id) == []
    end
  end

  describe "GET /api/v1/organizations/:id/webhook-deliveries (US-095)" do
    test "returns delivery rows without payload bodies leaking", %{conn: conn} do
      %{user: owner, organization: org} = org_with_owner()

      {:ok, _} =
        Webhooks.create_webhook(%{
          "organization_id" => org.id,
          "name" => "audit",
          "endpoint_url" => "https://e.com/a",
          "event_filters" => ["run.completed"]
        })

      {:ok, _} = Webhooks.fire_event(org.id, "run.completed", %{"run_id" => "abc"})

      conn =
        conn
        |> auth_conn(owner)
        |> get(~p"/api/v1/organizations/#{org.id}/webhook-deliveries")

      %{"deliveries" => [d]} = json_response(conn, 200)
      assert d["event_type"] == "run.completed"
      assert d["sent_at"] == nil
      assert d["retry_count"] == 0
      # Payload not leaked to index endpoint by default
      refute Map.has_key?(d, "event_payload")
    end
  end
end
