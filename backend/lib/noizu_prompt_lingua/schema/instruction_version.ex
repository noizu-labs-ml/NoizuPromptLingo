defmodule NoizuPromptLingua.Schema.InstructionVersion do
  @moduledoc """
  An immutable version of an instruction's body. New edits create a new version
  (number = previous + 1) rather than mutating in place; the parent's
  `active_version` selects which one is served.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "instruction_versions" do
    field :instruction_id, :binary_id
    field :version, :integer
    field :body, :string
    field :change_note, :string

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(version, attrs) do
    version
    |> cast(attrs, [:instruction_id, :version, :body, :change_note])
    |> validate_required([:instruction_id, :version, :body])
    |> foreign_key_constraint(:instruction_id)
    |> unique_constraint([:instruction_id, :version], name: :idx_instruction_versions_unique)
  end
end
