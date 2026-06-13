defmodule TheRobotWars.Schema.Media.Asset do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "media" do
    field :media_type, Ecto.Enum, values: [:image, :video, :audio, :document, :other]
    field :file_type, Ecto.Enum,
      values: [
        :jpg, :jpeg, :png, :gif, :webp, :svg, :bmp, :ico, :tiff,
        :mp4, :avi, :mov, :webm,
        :mp3, :wav, :ogg,
        :pdf, :doc, :other
      ]
    field :file, :string
    field :short_id, :string
    field :visibility, :string, default: "private"
    field :owner_type, :string
    field :owner_id, Ecto.UUID
    field :flagged, :boolean, default: false
    field :settings, :map
    field :deleted_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(asset, attrs) do
    asset
    |> cast(attrs, [:media_type, :file_type, :file, :short_id, :visibility, :owner_type, :owner_id, :flagged, :settings])
    |> validate_required([:media_type, :file_type])
    |> validate_inclusion(:visibility, ["public", "private", "org"])
  end
end
