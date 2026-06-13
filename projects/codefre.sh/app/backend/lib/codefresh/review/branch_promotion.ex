defmodule Codefresh.Review.BranchPromotion do
  @moduledoc """
  A record of a freeball chain promoted into a new authored script version
  (US-090) or persona version (US-139). `node_mapping` holds the freeball→new
  script_node id map; `edge_additions` records the edges injected to splice
  the promoted chain into the parent graph.

  Mirrors:
    * `priv/repo/migrations/20260421000017_create_branch_promotions.exs`
    * `priv/repo/migrations/20260421000044_add_branch_promotions_target_kind.exs`
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @target_kinds ~w(script_version persona_version)

  schema "branch_promotions" do
    field :node_mapping, :map, default: %{}
    field :edge_additions, :map, default: %{}
    field :notes, :string
    field :target_kind, :string, default: "script_version"
    field :inserted_at, :utc_datetime, virtual: false

    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :source_freeball_node, Codefresh.Runs.FreeballNode
    belongs_to :source_script_version, Codefresh.Scripts.ScriptVersion
    belongs_to :target_script_version, Codefresh.Scripts.ScriptVersion
    belongs_to :promoted_by_user, Codefresh.Accounts.User, foreign_key: :promoted_by_user_id
  end

  def target_kinds, do: @target_kinds

  def create_changeset(promo, attrs) do
    promo
    |> cast(attrs, [
      :organization_id,
      :source_freeball_node_id,
      :source_script_version_id,
      :target_script_version_id,
      :promoted_by_user_id,
      :node_mapping,
      :edge_additions,
      :notes,
      :target_kind,
      :inserted_at
    ])
    |> validate_required([
      :organization_id,
      :source_freeball_node_id,
      :source_script_version_id,
      :target_script_version_id
    ])
    |> validate_inclusion(:target_kind, @target_kinds)
    |> unique_constraint(:source_freeball_node_id)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:source_freeball_node_id)
    |> foreign_key_constraint(:source_script_version_id)
    |> foreign_key_constraint(:target_script_version_id)
  end
end
