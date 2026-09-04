defmodule NoizuPromptLingua.UsersMediaSessionsTest do
  use NoizuPromptLingua.DataCase

  @moduledoc """
  Users.Media and Users.Sessions entity contexts (entities/users/media.ex,
  entities/users/sessions.ex): reference-backed entity create/update/delete,
  list/list_for_user, change/2 mapping. Reference fields use the
  `{:ref, Module, id}` tuple form (house idiom, cf. api_key_auth fixtures).
  """

  @ctx Noizu.Context.system()

  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Media.Asset, as: AssetSchema
  alias NoizuPromptLingua.Schema.Users.User, as: UserSchema

  setup do
    n = System.unique_integer([:positive])

    user =
      %UserSchema{
        email: "um-#{n}@example.com",
        user_name: "um_user#{n}",
        handle: "um_h#{n}",
        status: :active
      }
      |> Repo.insert!()

    asset =
      %AssetSchema{
        media_type: :image,
        file_type: :png,
        file: "uploads/um-#{n}.png",
        short_id: "um#{n}"
      }
      |> Repo.insert!()

    %{user: user, asset: asset}
  end

  # ── Users.Media ──────────────────────────────────────────────────

  test "user media create/list/list_for_user/update/delete", %{user: user, asset: asset} do
    alias NoizuPromptLingua.Users.Media

    entity = %NoizuPromptLingua.Users.Media.Asset{
      id: Ecto.UUID.generate(),
      user: {:ref, NoizuPromptLingua.Users.User, user.id},
      media: {:ref, NoizuPromptLingua.Media.Asset, asset.id},
      # NOTE (pinned bug): the Ecto.Enum here declares [:profile, :cover,
      # :gallery, :other], but the DB column uses the shared media_type_enum
      # (image/video/audio/document/other) — every value except "other"
      # fails on insert. :other is the only round-trippable value; flagged.
      media_type: :other,
      settings: %{"alt" => "pic"}
    }

    assert {:ok, created} = Media.create(entity, @ctx)
    assert created.id == entity.id

    listed = Media.list(@ctx)
    assert Enum.any?(listed, &(&1.id == entity.id))

    for_user = Media.list_for_user(user.id, @ctx)
    assert Enum.any?(for_user, &(&1.id == entity.id))

    assert {:ok, updated} =
             Media.update(entity, %{"settings" => %{"alt" => "clip"}}, @ctx, [])

    assert updated.media_type == :other
    assert updated.settings == %{"alt" => "clip"}

    assert {:ok, _} = Media.get_user_media(created.id, @ctx)

    assert {:ok, _} = Media.delete(updated, @ctx)
    refute Enum.any?(Media.list(@ctx), &(&1.id == entity.id))
  end

  test "user media change/2 maps string keys and drops unknowns" do
    alias NoizuPromptLingua.Users.Media

    cs =
      Media.change(%NoizuPromptLingua.Users.Media.Asset{}, %{
        "user_id" => Ecto.UUID.generate(),
        "media_id" => Ecto.UUID.generate(),
        "media_type" => "other",
        "settings" => %{"a" => 1},
        "id" => Ecto.UUID.generate(),
        "junk" => :dropped
      })

    assert %Ecto.Changeset{} = cs
    assert cs.changes.media_type == :other
    assert cs.changes.settings == %{"a" => 1}
    refute Map.has_key?(cs.changes, :junk)
  end

  # ── Users.Sessions ───────────────────────────────────────────────

  test "user session create/get/list/delete + change mapping", %{user: user} do
    alias NoizuPromptLingua.Users.Sessions

    # create/3 takes an ATTRS MAP (change/2 Enum.map's its input — passing an
    # entity struct raises Enumerable/not-implemented; pinned current behavior)
    attrs = %{
      "id" => Ecto.UUID.generate(),
      "user" => {:ref, NoizuPromptLingua.Users.User, user.id},
      "status" => "active",
      "details" => %{"ip" => "127.0.0.1"}
    }

    assert {:ok, created} = Sessions.create(attrs, @ctx)
    assert created.id == attrs["id"]

    assert {:ok, fetched} = Sessions.get_session(created.id, @ctx)
    assert fetched.id == created.id

    assert Enum.any?(Sessions.list(@ctx), &(&1.id == created.id))

    assert {:ok, _} = Sessions.delete(created, @ctx)
    refute Enum.any?(Sessions.list(@ctx), &(&1.id == created.id))

    cs =
      Sessions.change(%NoizuPromptLingua.Users.Sessions.UserSession{}, %{
        "user" => Ecto.UUID.generate(),
        "status" => "active",
        "details" => %{"k" => "v"},
        "id" => Ecto.UUID.generate(),
        "junk" => 1
      })

    assert %Ecto.Changeset{} = cs
    assert cs.changes.status == :active
    assert cs.changes.details == %{"k" => "v"}
    refute Map.has_key?(cs.changes, :junk)
  end
end
