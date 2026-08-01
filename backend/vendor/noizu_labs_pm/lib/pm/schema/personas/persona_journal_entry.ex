defmodule Noizu.PM.Schema.Personas.PersonaJournalEntry do
  @moduledoc """
  A work-log / journal entry for a persona. Append-only narrative of work done,
  reflections, or decisions. `category` lets the same log hold distinct streams
  (work_log, reflection, decision, note).
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @categories ~w(work_log reflection decision note)

  schema "persona_journal_entries" do
    field :persona_id, :binary_id
    field :category, :string, default: "work_log"
    field :title, :string
    field :body, :string
    field :tags, {:array, :string}, default: []
    field :metadata, :map, default: %{}
    field :actor, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:persona_id, :category, :title, :body, :tags, :metadata, :actor])
    |> validate_required([:persona_id, :body])
    |> validate_inclusion(:category, @categories)
    |> foreign_key_constraint(:persona_id)
  end

  def categories, do: @categories
end
