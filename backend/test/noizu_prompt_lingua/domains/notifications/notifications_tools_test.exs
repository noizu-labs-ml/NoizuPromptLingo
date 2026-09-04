defmodule NoizuPromptLingua.Domains.Notifications.ToolsTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.Notifications
  alias NoizuPromptLingua.Domains.Notifications.Tools.{
    Ack,
    Clear,
    Format,
    FollowUp,
    Get,
    MarkRead,
    MarkSeen,
    Notify,
    Overview,
    Poll,
    Share,
    Watch
  }

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Notification
  alias NoizuPromptLingua.Schema.Organizations.Organization

  setup do
    org_id = insert_org()
    org_slug = Repo.get!(Organization, org_id).slug
    {:ok, org_id: org_id, org_slug: org_slug}
  end

  defp unique(suffix), do: "#{suffix}-#{System.unique_integer([:positive])}"

  defp notify_one(org_id, recipient) do
    {:ok, [row]} =
      Notifications.notify(%{
        organization_id: org_id,
        sender: "sender-bot",
        kind: "dm",
        recipient: recipient,
        body: "hello #{recipient}"
      })

    row
  end

  # ── Notify ─────────────────────────────────────────────────────────

  test "Notify dm delivers to a single recipient", %{org_slug: org_slug} do
    assert {:ok, %{kind: "dm", delivered: 1, recipients: [r], ids: [id]}} =
             Notify.call(
               %{
                 "organization" => org_slug,
                 "sender" => "alice",
                 "recipient" => unique("bob"),
                 "body" => "ping text"
               },
               %{}
             )

    assert String.starts_with?(r, "bob-")
    assert [%Notification{}] = Repo.all(from n in Notification, where: n.id == ^id)
  end

  test "Notify validation and fan-out paths", %{org_slug: org_slug} do
    assert {:error, "body is required for a dm"} =
             Notify.call(%{"organization" => org_slug, "sender" => "a", "recipient" => "b"}, %{})

    assert {:error, "body exceeds 128 characters"} =
             Notify.call(
               %{
                 "organization" => org_slug,
                 "sender" => "a",
                 "recipient" => "b",
                 "body" => String.duplicate("x", 129)
               },
               %{}
             )

    assert {:ok, %{delivered: 2}} =
             Notify.call(
               %{
                 "organization" => org_slug,
                 "sender" => "a",
                 "recipients" => [unique("r1"), unique("r2")],
                 "body" => "hi"
               },
               %{}
             )

    assert {:ok, %{kind: "ping"}} =
             Notify.call(
               %{"organization" => org_slug, "sender" => "a", "recipient" => unique("p"), "ping" => true},
               %{}
             )

    assert {:ok, %{kind: "pong"}} =
             Notify.call(
               %{
                 "organization" => org_slug,
                 "sender" => "a",
                 "recipient" => unique("p"),
                 "pong_to" => Ecto.UUID.generate()
               },
               %{}
             )

    assert {:error, "No recipients resolved — provide recipient/recipients or a group with members"} =
             Notify.call(%{"organization" => org_slug, "sender" => "a", "body" => "hi"}, %{})

    assert {:error, "Organization 'nope-missing' not found"} =
             Notify.call(%{"organization" => "nope-missing", "sender" => "a", "recipient" => "b", "body" => "hi"}, %{})
  end

  # ── FollowUp ───────────────────────────────────────────────────────

  test "FollowUp schedules with in_minutes / at and rejects bad timing", %{org_slug: org_slug} do
    recipient = unique("later")

    assert {:ok, %{kind: "follow_up", deliver_after: iso}} =
             FollowUp.call(
               %{
                 "organization" => org_slug,
                 "sender" => "s",
                 "persona" => recipient,
                 "body" => "later",
                 "in_minutes" => 5
               },
               %{}
             )

    assert {:ok, _, _} = DateTime.from_iso8601(iso)

    assert {:ok, %{recipient: ^recipient = r2}} =
             FollowUp.call(
               %{
                 "organization" => org_slug,
                 "sender" => "s",
                 "persona" => recipient,
                 "body" => "later",
                 "at" => "2030-01-01T00:00:00Z"
               },
               %{}
             )

    assert r2 == recipient

    assert {:error, "`at` is not a valid ISO-8601 instant"} =
             FollowUp.call(
               %{"organization" => org_slug, "sender" => "s", "body" => "x", "at" => "not-a-date"},
               %{}
             )

    assert {:error, "Provide in_minutes, in_hours, or an ISO-8601 `at` instant"} =
             FollowUp.call(%{"organization" => org_slug, "sender" => "s", "body" => "x"}, %{})

    assert {:error, "Organization 'nope-2' not found"} =
             FollowUp.call(%{"organization" => "nope-2", "sender" => "s", "body" => "x", "in_minutes" => 1}, %{})
  end

  # ── Share ──────────────────────────────────────────────────────────

  test "Share to a dm records the notification and skips attachment", %{org_slug: org_slug} do
    target = unique("dm-target")

    assert {:ok, %{shared: "artifact", target_type: "dm", notified: [^target], attachment_id: nil}} =
             Share.call(
               %{
                 "organization" => org_slug,
                 "sender" => "alice",
                 "subject_type" => "artifact",
                 "subject_id" => Ecto.UUID.generate(),
                 "target_type" => "dm",
                 "target" => target,
                 "note" => "take a look"
               },
               %{}
             )
  end

  test "Share validation errors", %{org_slug: org_slug} do
    base = %{"organization" => org_slug, "sender" => "alice", "subject_id" => Ecto.UUID.generate()}

    assert {:error, "subject_type must be one of: artifact, chat_message, chat_room, asset, wiki_page"} =
             Share.call(Map.merge(base, %{"subject_type" => "nope", "target_type" => "dm", "target" => "x"}), %{})

    assert {:error, "target_type must be one of: chat_room, thread, dm"} =
             Share.call(
               Map.merge(base, %{"subject_type" => "artifact", "target_type" => "carrier_pigeon", "target" => "x"}),
               %{}
             )

    assert {:error, "Target 'missing-room' not found"} =
             Share.call(
               Map.merge(base, %{"subject_type" => "artifact", "target_type" => "chat_room", "target" => "missing-room"}),
               %{}
             )

    assert {:error, "Target 'missing-msg' not found"} =
             Share.call(
               Map.merge(base, %{"subject_type" => "artifact", "target_type" => "thread", "target" => "missing-msg"}),
               %{}
             )

    assert {:error, "Organization 'nope-3' not found"} =
             Share.call(
               %{
                 "organization" => "nope-3",
                 "sender" => "alice",
                 "subject_type" => "artifact",
                 "subject_id" => "x",
                 "target_type" => "dm",
                 "target" => "y"
               },
               %{}
             )
  end

  # ── Watch ──────────────────────────────────────────────────────────

  test "Watch registers, refuses unknown, and unregisters", %{org_slug: org_slug} do
    persona = unique("watcher")
    entity_id = Ecto.UUID.generate()

    assert {:ok,
            %{
              action: "watch",
              entity_type: "ticket",
              entity_id: ^entity_id,
              persona: ^persona,
              filter: %{"type" => "regex", "pattern" => "open"}
            }} =
             Watch.call(
               %{
                 "organization" => org_slug,
                 "persona" => persona,
                 "entity_type" => "ticket",
                 "entity_id" => entity_id,
                 "filter" => ~s({"type": "regex", "pattern": "open"})
               },
               %{}
             )

    assert {:error, "persona is required"} = Watch.call(%{"organization" => org_slug}, %{})

    assert {:error, "entity_type and entity_id are required"} =
             Watch.call(%{"organization" => org_slug, "persona" => persona}, %{})

    assert {:error, "Not currently watching that entity"} =
             Watch.call(
               %{
                 "organization" => org_slug,
                 "action" => "unwatch",
                 "persona" => unique("never-watched"),
                 "entity_type" => "ticket",
                 "entity_id" => Ecto.UUID.generate()
               },
               %{}
             )

    assert {:ok, %{action: "unwatch", persona: ^persona}} =
             Watch.call(
               %{
                 "organization" => org_slug,
                 "action" => "unwatch",
                 "persona" => persona,
                 "entity_type" => "ticket",
                 "entity_id" => entity_id
               },
               %{}
             )
  end

  # ── Format helpers ─────────────────────────────────────────────────

  test "Format.prepare resolves the org and builds opts", %{org_id: org_id, org_slug: org_slug} do
    assert {:ok, ^org_id, "bob", opts} =
             Format.prepare(%{"organization" => org_slug, "recipient" => "bob", "max" => 5, "kinds" => ["dm"]})

    assert opts[:max] == 5
    assert opts[:kinds] == ["dm"]
    assert opts[:auto_read] == false

    assert {:error, "Organization 'nope-4' not found"} =
             Format.prepare(%{"organization" => "nope-4", "recipient" => "bob"})
  end

  test "Format.response projects rows and advances the cursor" do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    rows = [
      %Notification{
        id: Ecto.UUID.generate(),
        seq: 7,
        kind: "dm",
        sender: "s",
        body: "b",
        seen: false,
        read: false,
        inserted_at: now
      },
      %Notification{
        id: Ecto.UUID.generate(),
        seq: 8,
        kind: "dm",
        sender: "s",
        body: "b2",
        seen: true,
        read: true,
        inserted_at: now
      }
    ]

    assert {:ok, %{count: 2, next_cursor: 8, throttled: false, notifications: [first | _]}} =
             Format.response({:ok, rows}, "bob", 0)

    assert %{id: _, seq: 7, kind: "dm", sender: "s", subject_type: nil, payload: %{}} = first

    assert {:ok, %{count: 0, next_cursor: 3}} = Format.response({:ok, []}, "bob", 3)
  end

  # ── Get / Poll / Mark* / Ack / Clear / Overview ────────────────────

  test "Get returns delivered notifications for a fresh recipient", %{org_id: org_id, org_slug: org_slug} do
    recipient = unique("getter")
    notify_one(org_id, recipient)

    assert {:ok, %{count: 1, recipient: ^recipient, notifications: [n]}} =
             Get.call(%{"organization" => org_slug, "recipient" => recipient}, %{})

    assert n.body == "hello #{recipient}"
  end

  test "Poll returns a batch and Mark*/Ack/Clear update state", %{org_id: org_id, org_slug: org_slug} do
    recipient = unique("poller")
    n = notify_one(org_id, recipient)

    assert {:ok, %{count: 1}} = Poll.call(%{"organization" => org_slug, "recipient" => recipient}, %{})

    assert {:ok, %{marked_read: 1}} = MarkRead.call(%{"organization" => org_slug, "recipient" => recipient}, %{})

    assert {:ok, %{marked_seen: 1}} =
             MarkSeen.call(%{"organization" => org_slug, "recipient" => recipient, "ids" => [n.id]}, %{})

    assert {:ok, %{acked: 1}} = Ack.call(%{"organization" => org_slug, "recipient" => recipient}, %{})

    assert {:ok, %{cleared: 1}} =
             Clear.call(%{"organization" => org_slug, "recipient" => recipient, "ids" => [n.id]}, %{})

    assert {:error, "Organization 'nope-5' not found"} =
             MarkRead.call(%{"organization" => "nope-5", "recipient" => "x"}, %{})

    assert {:error, "Organization 'nope-6' not found"} =
             Overview.call(%{"organization" => "nope-6"}, %{})
  end

  # ── helpers ────────────────────────────────────────────────────────

  defp insert_org do
    slug = "notif-org-#{System.unique_integer([:positive])}"

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "Notifications Tools Test Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
