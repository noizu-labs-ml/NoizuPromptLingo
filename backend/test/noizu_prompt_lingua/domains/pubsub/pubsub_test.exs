defmodule NoizuPromptLingua.Domains.PubSubTest do
  @moduledoc """
  Stream F (tests): `Domains.PubSub` — named, org-scoped channels with an
  availability pointer surfaced into each follower's notification inbox.

    * create_channel / follow / publish
    * publish → every follower gets a coalesced `pubsub_available` notification
    * fetch_channel(limit) returns the message log in seq order
    * ack advances `last_acked_seq` AND clears the availability pointer
      (`Notifications.ids_for_dedup/3` goes empty once acked)
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.{PubSub, Notifications}
  alias NoizuPromptLingua.Schema.PubSubFollow

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["psorg-#{System.unique_integer([:positive])}", "PubSub Test Org"]
      )

    Ecto.UUID.load!(raw)
  end

  setup do
    org_id = insert_org()
    slug = "chan-#{System.unique_integer([:positive])}"

    {:ok, channel} =
      PubSub.create_channel(%{organization_id: org_id, slug: slug, name: "Channel #{slug}"})

    {:ok, org_id: org_id, channel: channel}
  end

  test "create_channel + get_channel round-trips by slug and by UUID", %{
    org_id: org_id,
    channel: channel
  } do
    assert PubSub.get_channel(org_id, channel.slug).id == channel.id
    assert PubSub.get_channel(org_id, channel.id).id == channel.id
  end

  test "follow is an idempotent upsert", %{channel: channel} do
    {:ok, _} = PubSub.follow(channel.id, "bob")
    {:ok, _} = PubSub.follow(channel.id, "bob")

    follows =
      Repo.all(from(f in PubSubFollow, where: f.channel_id == ^channel.id and f.persona == "bob"))

    assert length(follows) == 1
  end

  test "publish surfaces a pubsub_available pointer to each follower", %{
    org_id: org_id,
    channel: channel
  } do
    {:ok, _} = PubSub.follow(channel.id, "bob")
    {:ok, _} = PubSub.follow(channel.id, "carol")

    {:ok, message} =
      PubSub.publish(%{channel_id: channel.id, sender: "alice", body: "hello channel"})

    assert is_integer(message.seq)

    for persona <- ~w(bob carol) do
      {:ok, [notif]} = Notifications.get(org_id, persona)
      assert notif.kind == "pubsub_available"
      assert notif.dedup_key == "pubsub:#{channel.id}"
      assert notif.payload["channel"] == channel.slug
    end
  end

  test "repeated publishes coalesce the availability pointer (one unread row)", %{
    org_id: org_id,
    channel: channel
  } do
    {:ok, _} = PubSub.follow(channel.id, "bob")
    {:ok, _} = PubSub.publish(%{channel_id: channel.id, sender: "alice", body: "one"})
    {:ok, _} = PubSub.publish(%{channel_id: channel.id, sender: "alice", body: "two"})

    ids = Notifications.ids_for_dedup(org_id, "bob", "pubsub:#{channel.id}")
    assert length(ids) == 1
  end

  test "fetch_channel returns the log in seq order, honouring :limit and :since", %{
    channel: channel
  } do
    {:ok, m1} = PubSub.publish(%{channel_id: channel.id, sender: "alice", body: "1"})
    {:ok, m2} = PubSub.publish(%{channel_id: channel.id, sender: "alice", body: "2"})
    {:ok, m3} = PubSub.publish(%{channel_id: channel.id, sender: "alice", body: "3"})

    all = PubSub.fetch_channel(channel.id)
    assert Enum.map(all, & &1.id) == [m1.id, m2.id, m3.id]

    assert [first] = PubSub.fetch_channel(channel.id, limit: 1)
    assert first.id == m1.id

    since = PubSub.fetch_channel(channel.id, since: m1.seq)
    assert Enum.map(since, & &1.id) == [m2.id, m3.id]
  end

  test "ack advances last_acked_seq and clears the availability pointer", %{
    org_id: org_id,
    channel: channel
  } do
    {:ok, _} = PubSub.follow(channel.id, "bob")
    {:ok, message} = PubSub.publish(%{channel_id: channel.id, sender: "alice", body: "hi"})

    # pointer present before ack
    assert Notifications.ids_for_dedup(org_id, "bob", "pubsub:#{channel.id}") != []

    {:ok, %{last_acked_seq: acked}} = PubSub.ack(org_id, channel.id, "bob")
    assert acked == message.seq

    follow = Repo.get_by(PubSubFollow, channel_id: channel.id, persona: "bob")
    assert follow.last_acked_seq == message.seq

    # pointer cleared (acked) after catch-up
    assert Notifications.ids_for_dedup(org_id, "bob", "pubsub:#{channel.id}") == []
  end

  test "ack on a non-follower returns :not_following", %{org_id: org_id, channel: channel} do
    assert {:error, :not_following} = PubSub.ack(org_id, channel.id, "nobody")
  end
end
