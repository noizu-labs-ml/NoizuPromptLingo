defmodule TheRobotWars.Schema.Versioned.Strings.String do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "versioned_strings" do
    field :content, :string
    field :deleted_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(string, attrs) do
    string
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
