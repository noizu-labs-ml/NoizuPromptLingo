defmodule Codefresh.Scripts.ScriptNode do
  @moduledoc """
  A node in a script's conversation graph (`user_turn`, `system`,
  `assistant_turn`, `terminal`, `freeball_anchor`). The prompt reference
  (`prompt_version_id`) is optional until the node is configured.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @kinds ~w(user_turn system assistant_turn terminal freeball_anchor)
  @freeball_policies ~w(allow deny anchor)

  schema "script_nodes" do
    field :node_key, :string
    field :kind, :string, default: "user_turn"
    field :tone, :string
    field :eval_tags, {:array, :string}, default: []
    field :freeball_policy, :string, default: "allow"
    field :position, :map, default: %{}
    field :metadata, :map, default: %{}

    belongs_to :script_version, Codefresh.Scripts.ScriptVersion
    belongs_to :organization, Codefresh.Organizations.Organization

    belongs_to :prompt_version, Codefresh.Prompts.PromptVersion, foreign_key: :prompt_version_id

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def create_changeset(node, attrs) do
    node
    |> cast(attrs, [
      :script_version_id,
      :organization_id,
      :node_key,
      :kind,
      :tone,
      :eval_tags,
      :freeball_policy,
      :position,
      :metadata,
      :prompt_version_id
    ])
    |> validate_required([:script_version_id, :organization_id, :node_key, :kind])
    |> validate_inclusion(:kind, @kinds)
    |> validate_inclusion(:freeball_policy, @freeball_policies)
    |> validate_format(:node_key, ~r/^[a-z0-9][a-z0-9_-]*$/,
      message: "must be lowercase alphanumeric with underscores or dashes"
    )
    |> validate_length(:node_key, min: 1, max: 120)
    |> unique_constraint([:script_version_id, :node_key])
    |> foreign_key_constraint(:script_version_id)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:prompt_version_id)
  end

  def update_changeset(node, attrs) do
    node
    |> cast(attrs, [
      :kind,
      :tone,
      :eval_tags,
      :freeball_policy,
      :position,
      :metadata,
      :prompt_version_id
    ])
    |> validate_inclusion(:kind, @kinds)
    |> validate_inclusion(:freeball_policy, @freeball_policies)
    |> foreign_key_constraint(:prompt_version_id)
  end
end
