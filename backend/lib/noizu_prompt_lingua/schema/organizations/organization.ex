defmodule NoizuPromptLingua.Schema.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "organizations" do
    field :slug, :string
    field :name, :string
    field :settings, :map, default: %{}
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(org, attrs) do
    org
    |> cast(attrs, [:slug, :name, :settings])
    |> validate_required([:slug, :name])
    |> unique_constraint(:slug)
  end
end
