defmodule NoizuPromptLingua.Schema.Events.Webhook do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "webhooks" do
    field :url, :string
    field :secret, :string
    field :events, {:array, :string}, default: []
    field :active, :boolean, default: true
    field :organization_id, :binary_id

    timestamps()
  end

  def changeset(webhook, attrs) do
    webhook
    |> cast(attrs, [:url, :secret, :events, :active, :organization_id])
    |> validate_required([:url, :events])
    |> validate_format(:url, ~r/^https?:\/\//)
  end
end
