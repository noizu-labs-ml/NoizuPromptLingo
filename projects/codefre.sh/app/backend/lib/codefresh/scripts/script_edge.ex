defmodule Codefresh.Scripts.ScriptEdge do
  @moduledoc """
  Directed edge between two nodes in the same script_version. `match_method`
  drives how the runner decides whether to follow the edge. Self-loops are
  only allowed when `match_method = 'always'` (enforced at DB level via CHECK
  constraint `script_edges_no_self_loop`).
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @match_methods ~w(regex semantic lm_judge structural always freeball)

  schema "script_edges" do
    field :priority, :integer, default: 0
    field :match_method, :string
    field :match_config, :map, default: %{}
    field :label, :string

    belongs_to :script_version, Codefresh.Scripts.ScriptVersion
    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :from_node, Codefresh.Scripts.ScriptNode, foreign_key: :from_node_id
    belongs_to :to_node, Codefresh.Scripts.ScriptNode, foreign_key: :to_node_id

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def create_changeset(edge, attrs) do
    edge
    |> cast(attrs, [
      :script_version_id,
      :organization_id,
      :from_node_id,
      :to_node_id,
      :priority,
      :match_method,
      :match_config,
      :label
    ])
    |> validate_required([
      :script_version_id,
      :organization_id,
      :from_node_id,
      :to_node_id,
      :match_method
    ])
    |> validate_inclusion(:match_method, @match_methods)
    |> validate_self_loop()
    |> foreign_key_constraint(:script_version_id)
    |> foreign_key_constraint(:from_node_id)
    |> foreign_key_constraint(:to_node_id)
    |> check_constraint(:from_node_id, name: :script_edges_no_self_loop)
  end

  defp validate_self_loop(cs) do
    from_id = get_field(cs, :from_node_id)
    to_id = get_field(cs, :to_node_id)
    method = get_field(cs, :match_method)

    if from_id && to_id && from_id == to_id && method != "always" do
      add_error(cs, :from_node_id, "self-loop edges require match_method='always'")
    else
      cs
    end
  end
end
