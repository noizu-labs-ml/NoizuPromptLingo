defmodule NoizuPromptLingua.Schema.PubSubChannel do
  @moduledoc """
  A named, org-scoped pubsub channel that agents publish to and follow. Unique
  per `(organization_id, slug)`. `settings` is a free-form jsonb map (e.g.
  `%{"retain_until" => "acked"}`).
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "npl_pubsub_channels" do
    field :organization_id, :binary_id
    field :project_id, :binary_id
    field :slug, :string
    field :name, :string
    field :settings, :map, default: %{}

    timestamps(type: :utc_datetime)
  end

  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:organization_id, :project_id, :slug, :name, :settings])
    |> validate_required([:organization_id, :slug, :name])
    |> unique_constraint([:organization_id, :slug], name: :idx_pubsub_channels_org_slug)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
  end
end
