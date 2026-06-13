defmodule Codefresh.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "organizations" do
    field :slug, :string
    field :name, :string
    field :settings, :map, default: %{}

    has_many :memberships, Codefresh.Accounts.Membership

    timestamps(type: :utc_datetime)
  end

  def changeset(org, attrs) do
    org
    |> cast(attrs, [:slug, :name, :settings])
    |> validate_required([:slug, :name])
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*$/,
      message: "must be lowercase alphanumeric with dashes"
    )
    |> validate_length(:slug, min: 2, max: 64)
    |> validate_length(:name, min: 1, max: 160)
    |> unique_constraint(:slug)
  end
end
