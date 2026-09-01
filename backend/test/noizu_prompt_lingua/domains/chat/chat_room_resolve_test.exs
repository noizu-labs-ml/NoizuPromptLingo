defmodule NoizuPromptLingua.Domains.Chat.RoomResolveTest do
  @moduledoc """
  Slug-based room addressing for Chat.* tools: `Chat.resolve_room/2` keeps the
  legacy UUID id lookup and adds slug lookup scoped to the (org, project) bucket
  (ADR-013 A3), requiring org scope for slug args. Tool wiring is verified via
  Chat.GetRoom (RoomResolver + optional `organization` arg).
  """
  use NoizuPromptLingua.DataCase, async: false
  import Ecto.Query

  alias NoizuPromptLingua.Domains.Chat

  setup do
    org_id = insert_org()
    other_org_id = insert_org()

    {:ok, room} =
      Chat.create_room(%{organization_id: org_id, name: "Resolve Target"})

    {:ok, org_id: org_id, other_org_id: other_org_id, room: room}
  end

  defp fetch_slug(repo, org_id) do
    %{rows: [[slug]]} =
      repo.query!("SELECT slug FROM organizations WHERE id = $1", [Ecto.UUID.dump!(org_id)])

    slug
  end

  # ── fixtures (raw SQL; we only need real org rows) ──
  # Post-TRP-cutover the slug→UUID resolver reads the TRP org inventory (the
  # stub in tests — spec §4.1), so seed the stub with the same id/slug the
  # app-DB organizations row carries; `resolve_room/2` itself is app-DB-only.

  defp insert_org do
    uuid = Ecto.UUID.generate()
    slug = "resolverg-#{System.unique_integer([:positive])}"

    NoizuPromptLingua.TRP.TestStub.seed_org(uuid, slug)

    Repo.query!(
      "INSERT INTO organizations (id, slug, name, inserted_at, updated_at) " <>
        "VALUES ($1, $2, $3, now(), now())",
      [Ecto.UUID.dump!(uuid), slug, "Room Resolve Test Org"]
    )

    uuid
  end

  # ── Chat.resolve_room/2 ───────────────────────────────────────

  test "a UUID arg resolves by id (legacy path)", %{room: room} do
    assert {:ok, ^room} = Chat.resolve_room(room.id)
  end

  test "a slug arg resolves within the org bucket", %{org_id: org_id, room: room} do
    assert {:ok, room} == Chat.resolve_room(room.slug, org_id)
  end

  test "a slug arg without org scope is rejected", %{room: room} do
    assert {:error, :organization_required} = Chat.resolve_room(room.slug)
  end

  test "a slug arg with the wrong org is not found", %{other_org_id: other_org_id, room: room} do
    assert {:error, :not_found} = Chat.resolve_room(room.slug, other_org_id)
  end

  test "an unknown UUID is not found" do
    assert {:error, :not_found} = Chat.resolve_room(Ecto.UUID.generate())
  end

  # ── tool wiring (Chat.GetRoom) ────────────────────────────────

  test "GetRoom accepts room slug + organization", %{org_id: org_id, room: room} do
    org_slug = fetch_slug(Repo, org_id)

    assert {:ok, %{id: id, slug: slug}} =
             Chat.Tools.GetRoom.call(%{room_id: room.slug, organization: org_slug}, %{})

    assert id == room.id
    assert slug == room.slug
  end

  test "GetRoom slug without organization errors; UUID still works", %{room: room} do
    assert {:error, "organization is required when the room is addressed by slug"} =
             Chat.Tools.GetRoom.call(%{room_id: room.slug}, %{})

    assert {:ok, %{id: id}} = Chat.Tools.GetRoom.call(%{room_id: room.id}, %{})
    assert id == room.id
  end
end
