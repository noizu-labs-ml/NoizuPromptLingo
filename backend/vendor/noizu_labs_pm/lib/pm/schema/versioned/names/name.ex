defmodule Noizu.PM.Schema.Versioned.Names.Name do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "versioned_names" do
    field :first, :string
    field :middle, {:array, :string}, default: []
    field :last, :string
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(name, attrs) do
    name
    |> cast(attrs, [:first, :middle, :last])
  end
end
