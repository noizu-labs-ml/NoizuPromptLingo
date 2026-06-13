defmodule Codefresh.WebhooksTest do
  use Codefresh.DataCase, async: true

  import Codefresh.Fixtures

  alias Codefresh.Webhooks
  alias Codefresh.Webhooks.{Webhook, WebhookDelivery, Worker}

  describe "create_webhook/1 (US-144)" do
    test "creates a webhook with auto-generated secret when none supplied" do
      %{user: user, organization: org} = org_with_owner()

      assert {:ok, %Webhook{} = w} =
               Webhooks.create_webhook(%{
                 "organization_id" => org.id,
                 "created_by_user_id" => user.id,
                 "name" => "slack-relay",
                 "endpoint_url" => "https://example.com/hook",
                 "event_filters" => ["run.completed"]
               })

      assert w.name == "slack-relay"
      assert is_binary(w.secret) and byte_size(w.secret) >= 32
      assert w.active == true
    end

    test "rejects unknown event type" do
      %{organization: org} = org_with_owner()

      assert {:error, cs} =
               Webhooks.create_webhook(%{
                 "organization_id" => org.id,
                 "name" => "bad",
                 "endpoint_url" => "https://example.com/hook",
                 "event_filters" => ["definitely.not.a.thing"]
               })

      refute cs.valid?
      assert %{event_filters: [msg]} = Ecto.Changeset.traverse_errors(cs, fn {m, _} -> m end)
      assert msg =~ "unknown event type"
    end

    test "rejects non-http URL" do
      %{organization: org} = org_with_owner()

      assert {:error, cs} =
               Webhooks.create_webhook(%{
                 "organization_id" => org.id,
                 "name" => "bad-proto",
                 "endpoint_url" => "ftp://example.com/x"
               })

      refute cs.valid?
    end
  end

  describe "fire_event/3 (US-145)" do
    test "matches active webhooks with the event in their filter list" do
      %{user: user, organization: org} = org_with_owner()

      {:ok, matcher} =
        Webhooks.create_webhook(%{
          "organization_id" => org.id,
          "created_by_user_id" => user.id,
          "name" => "match",
          "endpoint_url" => "https://example.com/a",
          "event_filters" => ["run.completed", "run.errored"]
        })

      {:ok, _non_matcher} =
        Webhooks.create_webhook(%{
          "organization_id" => org.id,
          "created_by_user_id" => user.id,
          "name" => "miss",
          "endpoint_url" => "https://example.com/b",
          "event_filters" => ["review_item.created"]
        })

      {:ok, deliveries} =
        Webhooks.fire_event(org.id, "run.completed", %{"run_id" => "abc"})

      assert length(deliveries) == 1
      assert hd(deliveries).webhook_id == matcher.id
      assert hd(deliveries).sent_at == nil
    end

    test "ignores inactive webhooks" do
      %{organization: org} = org_with_owner()

      {:ok, w} =
        Webhooks.create_webhook(%{
          "organization_id" => org.id,
          "name" => "paused",
          "endpoint_url" => "https://example.com/c",
          "event_filters" => ["run.completed"]
        })

      {:ok, _} = Webhooks.update_webhook(w, %{"active" => false})

      assert {:ok, []} = Webhooks.fire_event(org.id, "run.completed", %{})
    end

    test "returns empty list when no webhook matches — no error" do
      %{organization: org} = org_with_owner()
      assert {:ok, []} = Webhooks.fire_event(org.id, "run.completed", %{})
    end
  end

  describe "Worker.deliver/1 (US-145 stub + US-095 audit)" do
    test "stub marks delivery sent with 204 and sets sent_at" do
      %{organization: org} = org_with_owner()

      {:ok, _w} =
        Webhooks.create_webhook(%{
          "organization_id" => org.id,
          "name" => "log-only",
          "endpoint_url" => "https://example.com/z",
          "event_filters" => ["run.completed"]
        })

      {:ok, [delivery]} =
        Webhooks.fire_event(org.id, "run.completed", %{"run_id" => "r1"})

      assert {:ok, updated} = Worker.deliver(delivery.id)
      assert updated.http_status == 204
      assert %DateTime{} = updated.sent_at
      # Error fields cleared on success
      assert updated.error_message == nil
      assert updated.next_retry_at == nil
    end

    test "is idempotent when delivery already sent" do
      %{organization: org} = org_with_owner()

      {:ok, _} =
        Webhooks.create_webhook(%{
          "organization_id" => org.id,
          "name" => "twice",
          "endpoint_url" => "https://example.com/y",
          "event_filters" => ["run.completed"]
        })

      {:ok, [d]} = Webhooks.fire_event(org.id, "run.completed", %{})

      {:ok, _} = Worker.deliver(d.id)
      {:ok, again} = Worker.deliver(d.id)
      # http_status set once; second call is a no-op
      assert again.http_status == 204
    end

    test "disabling webhook between enqueue and deliver dead-letters the row (US-146)" do
      %{organization: org} = org_with_owner()

      {:ok, w} =
        Webhooks.create_webhook(%{
          "organization_id" => org.id,
          "name" => "race",
          "endpoint_url" => "https://example.com/r",
          "event_filters" => ["run.completed"]
        })

      {:ok, [d]} = Webhooks.fire_event(org.id, "run.completed", %{})
      {:ok, _} = Webhooks.update_webhook(w, %{"active" => false})

      {:ok, updated} = Worker.deliver(d.id)
      assert updated.sent_at == nil
      assert WebhookDelivery.dead_lettered?(updated)
      assert updated.error_message =~ "disabled"
    end
  end

  describe "sign_payload/2 (US-144)" do
    test "emits sha256=<hex> HMAC" do
      sig = Webhooks.sign_payload("secret-1", ~s({"hello":"world"}))
      assert "sha256=" <> hex = sig
      assert String.length(hex) == 64
      assert Regex.match?(~r/^[0-9a-f]+$/, hex)
    end

    test "different secrets produce different signatures" do
      a = Webhooks.sign_payload("secret-a", "body")
      b = Webhooks.sign_payload("secret-b", "body")
      refute a == b
    end
  end

  describe "WebhookDelivery.failure_changeset/3 backoff schedule (US-146)" do
    test "schedules next_retry_at per backoff table" do
      %{organization: org} = org_with_owner()

      {:ok, _w} =
        Webhooks.create_webhook(%{
          "organization_id" => org.id,
          "name" => "retry",
          "endpoint_url" => "https://example.com/bk",
          "event_filters" => ["run.completed"]
        })

      {:ok, [d]} = Webhooks.fire_event(org.id, "run.completed", %{})

      cs = WebhookDelivery.failure_changeset(d, 500, "boom")
      updated = Ecto.Changeset.apply_changes(cs)

      assert updated.retry_count == 1
      assert %DateTime{} = updated.next_retry_at

      # After exhausting the schedule, next_retry_at is nil (dead-letter).
      last = %{d | retry_count: WebhookDelivery.max_retries()}
      cs = WebhookDelivery.failure_changeset(last, 500, "boom")
      updated = Ecto.Changeset.apply_changes(cs)
      assert updated.next_retry_at == nil
      assert WebhookDelivery.dead_lettered?(updated)
    end
  end
end
