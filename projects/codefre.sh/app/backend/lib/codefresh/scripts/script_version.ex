defmodule Codefresh.Scripts.ScriptVersion do
  @moduledoc """
  Script version row. v1 is auto-created as an editable draft when a script is
  created; subsequent versions are created by publishing (US-006). Draft
  versions allow in-place edits to nodes/edges/expectations; published
  versions are treated as immutable by downstream consumers.

  `root_node_id` is set when the first `user_turn` node is added (US-002).
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "script_versions" do
    field :version_number, :integer
    field :description, :string
    field :yaml_source, :string
    field :checksum, :binary

    belongs_to :script, Codefresh.Scripts.Script
    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :root_node, Codefresh.Scripts.ScriptNode, foreign_key: :root_node_id
    belongs_to :published_by, Codefresh.Accounts.User, foreign_key: :published_by_user_id

    belongs_to :parent_version, Codefresh.Scripts.ScriptVersion, foreign_key: :parent_version_id

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def create_changeset(sv, attrs) do
    sv
    |> cast(attrs, [
      :script_id,
      :organization_id,
      :version_number,
      :description,
      :yaml_source,
      :checksum,
      :published_by_user_id,
      :parent_version_id,
      :root_node_id
    ])
    |> validate_required([:script_id, :organization_id, :version_number, :checksum])
    |> validate_number(:version_number, greater_than: 0)
    |> unique_constraint([:script_id, :version_number])
    |> unique_constraint([:script_id, :checksum])
    |> foreign_key_constraint(:script_id)
    |> foreign_key_constraint(:organization_id)
  end

  def set_root_changeset(sv, node_id), do: change(sv, root_node_id: node_id)

  @doc """
  Empty-body checksum placeholder used for brand-new draft versions. Real
  checksums are computed at publish time over the node/edge/expectation graph.
  """
  def empty_checksum, do: :crypto.hash(:sha256, "empty-draft")
end
