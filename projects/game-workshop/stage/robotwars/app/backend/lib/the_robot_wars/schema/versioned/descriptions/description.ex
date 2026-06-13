defmodule TheRobotWars.Schema.Versioned.Descriptions.Description do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "versioned_descriptions" do
    field :title, :string
    field :body, :string
    field :deleted_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(description, attrs) do
    description
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
  end
end
