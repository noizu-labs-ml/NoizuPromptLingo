defmodule Noizu.PM.Schema.Versioned.Descriptions.Description do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "versioned_descriptions" do
    field :title, :string
    field :body, :string
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(description, attrs) do
    description
    |> cast(attrs, [:title, :body])
  end
end
