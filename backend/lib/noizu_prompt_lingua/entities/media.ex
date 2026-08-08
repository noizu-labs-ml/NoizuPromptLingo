defmodule NoizuPromptLingua.Media do
  alias NoizuPromptLingua.Media.Asset, as: Entity
  alias NoizuPromptLingua.Schema.Media.Asset, as: Schema
  use Noizu.Repo
  def_repo(entity: Entity)

  def list(context, options \\ []) do
    settings = Noizu.Entity.Meta.persistence(Entity) |> hd

    NoizuPromptLingua.Repo.all(Schema)
    |> Enum.map(fn record ->
      {:ok, entity} = Entity.from_record(record, settings, context, options)
      {:ok, entity} = __after_get__(entity, context, options)
      entity
    end)
  end

  def get_media_asset(id, context, options \\ []), do: get(id, context, options)

  # `super`, not `create` — a self-call lands back in this same clause and
  # change/2's `Enum.map(attrs, ...)` crashes on the non-enumerable it is
  # handed (Protocol.UndefinedError). A pre-built entity or changeset — what
  # `EntityRepo.create/2` dispatches here — skips change/2 entirely.
  def create(media_asset, context, options \\ [])

  def create(%Entity{} = media_asset, context, options), do: super(media_asset, context, options)

  def create(%Ecto.Changeset{} = changeset, context, options),
    do: super(changeset, context, options)

  def create(attrs, context, options) do
    %Entity{}
    |> change(attrs)
    |> super(context, options)
  end

  # Arity 4 only — an `options \\ []` default would also define update/3 and
  # shadow the def_repo-generated update/3 that this body calls.
  def update(%Entity{} = media_asset, attrs, context, options) do
    media_asset
    |> change(attrs)
    |> update(context, options)
  end

  def delete(%Entity{} = media_asset, context, options \\ []) do
    # A bare `delete(media_asset, context, options)` is this very clause — unbounded
    # recursion. `super` reaches the def_repo-generated delete/3.
    super(media_asset, context, options)
  end

  def change(%Entity{} = media_asset, attrs \\ %{}) do
    attrs =
      Enum.map(attrs, fn
        {"media_type", value} -> {:media_type, String.to_existing_atom(value)}
        {"file_type", value} -> {:file_type, String.to_existing_atom(value)}
        {"file", value} -> {:file, value}
        {"flagged", value} -> {:flagged, value}
        {"settings", value} -> {:settings, value}
        {"id", value} -> {:id, value}
        {k, v} when is_atom(k) -> {k, v}
        _ -> nil
      end)
      |> Enum.reject(&is_nil/1)

    Ecto.Changeset.change({media_asset, Noizu.Entity.Meta.meta(Entity)[:changeset_fields]}, attrs)
  end

  def get_by_short_id(short_id) do
    import Ecto.Query

    NoizuPromptLingua.Repo.one(
      from a in Schema,
        where: a.short_id == ^short_id and is_nil(a.deleted_at)
    )
  end

  def get_cached_variant(media_id, canonical_params) do
    import Ecto.Query

    NoizuPromptLingua.Repo.one(
      from v in NoizuPromptLingua.Schema.Media.Variant,
        where: v.media_id == ^media_id and v.params == ^canonical_params
    )
  end

  def cache_variant(attrs) do
    %NoizuPromptLingua.Schema.Media.Variant{}
    |> NoizuPromptLingua.Schema.Media.Variant.changeset(attrs)
    |> NoizuPromptLingua.Repo.insert(on_conflict: :nothing)
  end

  def fetch_from_s3(key) do
    config = Application.get_env(:noizu_prompt_lingua, NoizuPromptLingua.Storage, [])

    case ExAws.S3.get_object(config[:bucket], key) |> ExAws.request(config) do
      {:ok, %{body: body}} -> {:ok, body}
      error -> error
    end
  end

  def upload_variant_to_s3(key, binary, content_type) do
    config = Application.get_env(:noizu_prompt_lingua, NoizuPromptLingua.Storage, [])

    ExAws.S3.put_object(config[:bucket], key, binary, content_type: content_type)
    |> ExAws.request(config)
  end

  def get_or_create_variant(media, transform_params) do
    canonical = NoizuPromptLingua.Media.Transform.canonical_params(transform_params)

    case get_cached_variant(media.id, canonical) do
      %{variant_key: key, content_type: ct} ->
        {:ok, key, ct}

      nil ->
        with {:ok, original_binary} <- fetch_from_s3(media.file),
             {:ok, transformed, content_type} <-
               NoizuPromptLingua.Media.Transform.transform(original_binary, transform_params) do
          variant_key =
            NoizuPromptLingua.Media.Transform.variant_s3_key(media.file, transform_params)

          {:ok, _} = upload_variant_to_s3(variant_key, transformed, content_type)

          {:ok, _} =
            cache_variant(%{
              media_id: media.id,
              variant_key: variant_key,
              params: canonical,
              file_size: byte_size(transformed),
              content_type: content_type
            })

          {:ok, variant_key, content_type}
        end
    end
  end

  def register_asset(attrs) do
    %Schema{}
    |> Schema.changeset(attrs)
    |> NoizuPromptLingua.Repo.insert()
  end
end
