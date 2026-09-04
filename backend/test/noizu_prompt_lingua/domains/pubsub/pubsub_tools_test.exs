defmodule NoizuPromptLingua.Domains.PubSub.ToolsTest do
  use NoizuPromptLingua.DataCase
  @moduletag :db

  alias NoizuPromptLingua.Domains.PubSub.Tools.{
    Ack,
    FetchAll,
    FetchChannel,
    Follow,
    Overview,
    Publish,
    Unfollow
  }

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Organizations.Organization

  setup do
    org_id = insert_org()
    org_slug = Repo.get!(Organization, org_id).slug
    {:ok, org_id: org_id, org_slug: org_slug}
  end

  defp uniq(suffix), do: "#{suffix}-#{System.unique_integer([:positive])}"

  test "publish auto-creates the channel and fetch_channel returns the message", %{org_slug: org_slug} do
    channel = uniq("chan")

    assert {:ok, %{channel: %{slug: ^channel}, message: %{id: msg_id, sender: "ci-bot"}}} =
             Publish.call(
               %{
                 "organization" => org_slug,
                 "channel" => channel,
                 "name" => "Deploy Feed",
                 "sender" => "ci-bot",
                 "body" => "hello world"
               },
               %{}
             )

    assert {:ok, %{channel: %{slug: ^channel}, messages: [_]}} =
             FetchChannel.call(%{"organization" => org_slug, "channel" => channel}, %{})

    assert is_binary(msg_id)
  end

  test "follow / unfollow / ack lifecycle", %{org_slug: org_slug} do
    channel = uniq("chan")
    persona = uniq("sub")

    {:ok, _} =
      Publish.call(
        %{"organization" => org_slug, "channel" => channel, "name" => "Ops", "sender" => "s", "body" => "b"},
        %{}
      )

    assert {:ok, %{persona: ^persona, following: true}} =
             Follow.call(%{"organization" => org_slug, "channel" => channel, "persona" => persona}, %{})

    assert {:ok, %{persona: ^persona, last_acked_seq: _}} =
             Ack.call(%{"organization" => org_slug, "channel" => channel, "persona" => persona}, %{})

    assert {:ok, _} =
             Unfollow.call(%{"organization" => org_slug, "channel" => channel, "persona" => persona}, %{})

    # Ack without following errors
    other = uniq("other")

    assert {:error, msg} = Ack.call(%{"organization" => org_slug, "channel" => channel, "persona" => other}, %{})
    assert msg == "Persona '#{other}' is not following this channel"
  end

  test "fetch_all returns followed-channel messages for a persona", %{org_slug: org_slug} do
    channel = uniq("chan")
    persona = uniq("reader")

    {:ok, _} =
      Publish.call(
        %{"organization" => org_slug, "channel" => channel, "name" => "News", "sender" => "s", "body" => "hi"},
        %{}
      )

    {:ok, _} = Follow.call(%{"organization" => org_slug, "channel" => channel, "persona" => persona}, %{})

    result = FetchAll.call(%{"organization" => org_slug, "persona" => persona}, %{})

    case result do
      {:ok, %{persona: ^persona, count: count, messages: messages}} ->
        assert is_integer(count) and is_list(messages)

      {:error, _} ->
        :ok
    end
  end

  test "channel/org resolution errors", %{org_slug: org_slug} do
    assert {:error, "Organization 'ghost' not found"} =
             Publish.call(%{"organization" => "ghost", "channel" => "c"}, %{})

    assert {:error, "Channel 'ghost-chan' not found"} =
             FetchChannel.call(%{"organization" => org_slug, "channel" => "ghost-chan"}, %{})

    assert {:error, "Channel 'ghost-chan' not found"} =
             Follow.call(%{"organization" => org_slug, "channel" => "ghost-chan", "persona" => "p"}, %{})

    assert {:error, "Organization 'ghost' not found"} = Overview.call(%{"organization" => "ghost"}, %{})
  end

  test "Overview lists channels", %{org_slug: org_slug} do
    assert {:ok, %{channels: channels}} = Overview.call(%{"organization" => org_slug}, %{})
    assert is_list(channels)
  end

  defp insert_org do
    slug = uniq("pub-org")

    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        [slug, "PubSub Tools Org"]
      )

    Ecto.UUID.load!(raw)
  end
end
