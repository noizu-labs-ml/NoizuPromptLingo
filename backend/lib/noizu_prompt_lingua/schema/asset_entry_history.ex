defmodule NoizuPromptLingua.Schema.AssetEntryHistory do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "asset_entry_history" do
    belongs_to :entry, NoizuPromptLingua.Schema.AssetEntry
    field :action, :string
    field :actor, :string
    field :details, :map

    timestamps(type: :utc_datetime)
  end

  def changeset(history, attrs) do
    history
    |> cast(attrs, [:entry_id, :action, :actor, :details])
    |> validate_required([:entry_id, :action])
    |> foreign_key_constraint(:entry_id)
  end
end
