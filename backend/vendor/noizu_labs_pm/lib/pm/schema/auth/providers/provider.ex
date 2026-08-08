defmodule Noizu.PM.Schema.Auth.Providers.Provider do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "auth_providers" do
    field :title, :string
    field :description, :string
    field :settings, Noizu.PM.Ecto.SerializedTerm
    field :deleted_at, :utc_datetime_usec
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(provider, attrs) do
    provider
    |> cast(attrs, [:title, :description, :settings])
    |> validate_required([:title])
  end
end
