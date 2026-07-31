defmodule NoizuPromptLingua.Schema.AssetOutput do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "asset_outputs" do
    belongs_to :entry, NoizuPromptLingua.Schema.AssetEntry
    field :artifact_id, :binary_id
    field :provider, :string
    field :model, :string
    field :variant_number, :integer, default: 1
    field :eval_score, :float
    field :eval_details, :map
    field :eval_status, :string, default: "pending"
    field :status, :string, default: "generated"

    timestamps(type: :utc_datetime)
  end

  def changeset(output, attrs) do
    output
    |> cast(attrs, [
      :entry_id,
      :artifact_id,
      :provider,
      :model,
      :variant_number,
      :eval_score,
      :eval_details,
      :eval_status,
      :status
    ])
    |> validate_required([:entry_id])
    |> validate_inclusion(:eval_status, ~w(pending passed failed skipped))
    |> validate_inclusion(:status, ~w(generated accepted rejected))
    |> foreign_key_constraint(:entry_id)
  end
end
