defmodule NoizuPromptLingua.MediaContextTest do
  use NoizuPromptLingua.DataCase

  @moduledoc """
  Media context (entities/media.ex): asset registration, short-id lookup,
  variant caching, the Noizu.Repo create/update/delete paths, and change/2
  attribute mapping. S3 I/O (fetch_from_s3 / upload_variant_to_s3 /
  get_or_create_variant's miss path) needs a bucket and stays out of scope.
  """

  alias NoizuPromptLingua.Media
  alias NoizuPromptLingua.Repo
  alias NoizuPromptLingua.Schema.Media.Asset, as: AssetSchema

  @ctx Noizu.Context.system()

  defp insert_asset!(overrides \\ %{}) do
    n = System.unique_integer([:positive])

    %AssetSchema{
      media_type: :image,
      file_type: :png,
      file: "uploads/test-#{n}.png",
      short_id: "sh#{n}"
    }
    |> Map.merge(overrides)
    |> Repo.insert!()
  end

  # ── register_asset / short-id lookup ─────────────────────────────

  test "register_asset persists via the schema changeset" do
    n = System.unique_integer([:positive])

    assert {:ok, asset} =
             Media.register_asset(%{
               media_type: :image,
               file_type: :png,
               file: "uploads/reg-#{n}.png",
               short_id: "rg#{n}",
               visibility: "public"
             })

    assert asset.visibility == "public"
  end

  test "get_by_short_id finds live rows only" do
    asset = insert_asset!()

    assert Media.get_by_short_id(asset.short_id).id == asset.id
    assert Media.get_by_short_id("missing-#{System.unique_integer([:positive])}") == nil

    asset
    |> Ecto.Changeset.change(deleted_at: DateTime.utc_now())
    |> Repo.update!()

    assert Media.get_by_short_id(asset.short_id) == nil
  end

  # ── variant cache ────────────────────────────────────────────────

  test "cache_variant + get_cached_variant round-trip canonical params" do
    asset = insert_asset!()
    params = "w=512,q=80"

    assert Media.get_cached_variant(asset.id, params) == nil

    assert {:ok, variant} =
             Media.cache_variant(%{
               media_id: asset.id,
               variant_key: "variants/#{asset.short_id}-512.png",
               params: params,
               file_size: 1234,
               content_type: "image/png"
             })

    assert variant.media_id == asset.id
    assert Media.get_cached_variant(asset.id, params).id == variant.id
  end

  # ── Noizu.Repo paths ─────────────────────────────────────────────

  test "create/3 accepts attrs, an entity, or a changeset" do
    n = System.unique_integer([:positive])

    # attrs path (routes through change/2)
    assert {:ok, via_attrs} =
             Media.create(
               %{
                 "media_type" => "image",
                 "file_type" => "png",
                 "file" => "uploads/attrs-#{n}.png",
                 "short_id" => "at#{n}",
                 "unknown_key" => "dropped",
                 :visibility => "org"
               },
               @ctx
             )

    assert via_attrs.media_type == :image
    assert via_attrs.visibility == "org"

    # entity path
    entity = %NoizuPromptLingua.Media.Asset{
      media_type: :image,
      file_type: :png,
      file: "uploads/entity-#{n}.png",
      short_id: "en#{n}"
    }

    assert {:ok, via_entity} = Media.create(entity, @ctx)
    assert via_entity.id

    # changeset path (change/2 is how changesets are built for Noizu entities;
    # the entity path does not autogenerate ids, so supply one)
    cs =
      Media.change(%NoizuPromptLingua.Media.Asset{}, %{
        "id" => Ecto.UUID.generate(),
        "media_type" => "audio",
        "file_type" => "mp3",
        "file" => "uploads/cs-#{n}.mp3",
        "short_id" => "cs#{n}"
      })

    assert {:ok, via_cs} = Media.create(cs, @ctx)
    assert via_cs.media_type == :audio
  end

  defp create_entity!(overrides \\ %{}) do
    n = System.unique_integer([:positive])

    base = %{
      "media_type" => "image",
      "file_type" => "png",
      "file" => "uploads/e-#{n}.png",
      "short_id" => "ce#{n}"
    }

    {:ok, entity} = Media.create(Map.merge(base, overrides), @ctx)
    entity
  end

  test "update/4 applies changes through change/2" do
    n = System.unique_integer([:positive])

    # Build the entity WITH its short_id: create/3's returned entity does not
    # carry it back, and an update re-encodes every field (a nil short_id
    # trips the DB not-null guard) — pinned current behavior.
    entity = %NoizuPromptLingua.Media.Asset{
      id: Ecto.UUID.generate(),
      media_type: :image,
      file_type: :png,
      file: "uploads/upd-#{n}.png",
      short_id: "up#{n}"
    }

    assert {:ok, _} = Media.create(entity, @ctx)

    # string-key "visibility" is NOT in change/2's mapping (dropped); the atom
    # passthrough is the way to change it.
    assert {:ok, updated} =
             Media.update(
               entity,
               %{"flagged" => true, "unknown" => "gone", :visibility => "public"},
               @ctx,
               []
             )

    assert updated.flagged == true
    assert updated.visibility == "public"
  end

  test "delete/3 delegates to the generated delete and list/2 returns entities" do
    entity = create_entity!()

    assert {:ok, _} = Media.delete(entity, @ctx)

    assert entities = Media.list(@ctx)
    refute Enum.any?(entities, &(&1.id == entity.id))
  end

  test "change/2 maps string keys and drops unknowns" do
    entity = %NoizuPromptLingua.Media.Asset{}

    cs =
      Media.change(entity, %{
        "media_type" => "video",
        "file_type" => "mp4",
        "file" => "x.mp4",
        "flagged" => true,
        "settings" => %{"k" => "v"},
        "id" => Ecto.UUID.generate(),
        :visibility => "private",
        "nope" => 1
      })

    assert %Ecto.Changeset{} = cs
    assert cs.changes.media_type == :video
    assert cs.changes.file_type == :mp4
    assert cs.changes.flagged == true
    assert cs.changes.settings == %{"k" => "v"}
    refute Map.has_key?(cs.changes, :nope)
  end
end
