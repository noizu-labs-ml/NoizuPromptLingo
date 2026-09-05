defmodule NoizuPromptLingua.Domains.Notifications.ShareFoldsTest do
  @moduledoc """
  Notifications.Share tool — argument-validation folds: org/project scope
  errors, source/target type validation, and unknown thread targets.

  The delivery happy path (attachment pointer + notify fan-out) is covered by
  the notifications domain suites. The project_not_in_org fold needs seeded
  TRP stub state and stays uncovered to avoid cross-suite stub pollution.
  """
  use NoizuPromptLingua.DataCase, async: false

  alias NoizuPromptLingua.Domains.Notifications.Tools.Share
  alias NoizuPromptLingua.Schema.Organizations.Organization

  setup do
    suffix = Ecto.UUID.generate() |> binary_part(0, 8)
    org = Repo.insert!(%Organization{name: "Share Org", slug: "share-org-#{suffix}"})

    %{org: org}
  end

  defp args(overrides) do
    Map.merge(
      %{
        "organization" => nil,
        "sender" => "agent-1",
        "subject_type" => "artifact",
        "subject_id" => Ecto.UUID.generate(),
        "target_type" => "dm",
        "target" => "someone"
      },
      overrides
    )
  end

  test "unknown organization fold", %{} do
    a = args(%{"organization" => "ghost-org"})

    assert {:error, "Organization 'ghost-org' not found"} = Share.call(a, %{})
  end

  test "unknown project fold", %{org: org} do
    a = args(%{"organization" => org.id, "project" => "ghost-project"})

    assert {:error, "Project 'ghost-project' not found"} = Share.call(a, %{})
  end

  test "invalid subject_type fold", %{org: org} do
    a = args(%{"organization" => org.id, "subject_type" => "carrier_pigeon"})

    assert {:error, "subject_type must be one of: artifact, chat_message, chat_room, asset, wiki_page"} =
             Share.call(a, %{})
  end

  test "invalid target_type fold", %{org: org} do
    a = args(%{"organization" => org.id, "target_type" => "fax"})

    assert {:error, "target_type must be one of: chat_room, thread, dm"} = Share.call(a, %{})
  end

  test "unknown thread target fold", %{org: org} do
    missing = Ecto.UUID.generate()
    a = args(%{"organization" => org.id, "target_type" => "thread", "target" => missing})

    assert {:error, msg} = Share.call(a, %{})
    assert msg == "Target '#{missing}' not found"
  end
end
