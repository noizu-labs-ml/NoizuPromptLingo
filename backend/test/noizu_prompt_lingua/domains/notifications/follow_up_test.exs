defmodule NoizuPromptLingua.Domains.Notifications.FollowUpTest do
  @moduledoc """
  Stream F (tests): the `Notifications.FollowUp` MCP tool.

  FollowUp queues a `follow_up` notification with a future `deliver_after`, so it
  is invisible to a normal `get/3` until it is due. We schedule one, confirm it is
  hidden, then push its `deliver_after` into the past and confirm it surfaces.

  The org ref is passed as a UUID so `Resolve.scope/2` resolves without the
  Redis-backed slug cache.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Notifications
  alias NoizuPromptLingua.Domains.Notifications.Tools.FollowUp
  alias NoizuPromptLingua.Schema.Notification

  defp insert_org do
    %{rows: [[raw]]} =
      Repo.query!(
        "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
          "VALUES (gen_random_uuid(), $1, $2, now(), now()) RETURNING id",
        ["fuorg-#{System.unique_integer([:positive])}", "FollowUp Test Org"]
      )

    Ecto.UUID.load!(raw)
  end

  setup do
    {:ok, org_id: insert_org()}
  end

  test "FollowUp schedules a future follow_up that is hidden until due", %{org_id: org_id} do
    sender = "agent-#{System.unique_integer([:positive])}"

    {:ok, result} =
      FollowUp.call(
        %{organization: org_id, sender: sender, body: "revisit the spec", in_minutes: 30},
        %{}
      )

    assert result.kind == "follow_up"
    assert result.recipient == sender
    assert [id] = result.ids

    row = Repo.get(Notification, id)
    assert row.kind == "follow_up"
    assert row.recipient == sender
    refute is_nil(row.deliver_after)
    assert DateTime.compare(row.deliver_after, DateTime.utc_now()) == :gt

    # Hidden from a normal pull while the deliver_after is in the future.
    assert {:ok, []} = Notifications.get(org_id, sender)

    # Push it into the past → it becomes due and surfaces.
    past = DateTime.utc_now() |> DateTime.add(-60, :second) |> DateTime.truncate(:second)

    Repo.update_all(
      from(n in Notification, where: n.id == ^id),
      set: [deliver_after: past]
    )

    assert {:ok, [due]} = Notifications.get(org_id, sender)
    assert due.id == id
  end

  test "FollowUp defaults the recipient to the sender (note-to-self)", %{org_id: org_id} do
    sender = "selfnote-#{System.unique_integer([:positive])}"

    {:ok, result} =
      FollowUp.call(%{organization: org_id, sender: sender, body: "ping me", in_hours: 1}, %{})

    assert result.recipient == sender
  end

  test "FollowUp requires a duration", %{org_id: org_id} do
    assert {:error, msg} =
             FollowUp.call(%{organization: org_id, sender: "x", body: "no when"}, %{})

    assert msg =~ "in_minutes"
  end
end
