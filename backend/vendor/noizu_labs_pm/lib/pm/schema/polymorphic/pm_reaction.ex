defmodule Noizu.PM.Schema.Polymorphic.PmReaction do
  @moduledoc """
  Generic per-entity reaction keyed by (entity_type, entity_id). Consolidates
  npl's `npl_reactions` and trp's `trp_reactions` into `pm_reactions`. `persona`
  is the reactor (a user id).
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "pm_reactions" do
    field :entity_type, :string
    field :entity_id, :binary_id
    field :persona, :string
    field :emoji, :string

    timestamps(type: :utc_datetime)
  end

  # `emoji` accepts a unicode emoji OR a shortcode (e.g. ":+1:"), so we don't enforce
  # emoji-ness — but we cap length so an arbitrary multi-KB string can't be stored as
  # a "reaction". A complex ZWJ/flag emoji is a handful of graphemes; 64 is generous.
  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:entity_type, :entity_id, :persona, :emoji])
    |> validate_required([:entity_type, :entity_id, :persona, :emoji])
    |> validate_length(:emoji, max: 64)
    |> unique_constraint([:entity_type, :entity_id, :persona, :emoji],
      name: :idx_pm_reactions_unique
    )
  end
end
