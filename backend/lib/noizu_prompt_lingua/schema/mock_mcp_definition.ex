defmodule NoizuPromptLingua.Schema.MockMCPDefinition do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @statuses ~w(draft active archived)

  schema "mock_mcp_definitions" do
    field :organization_id, :binary_id
    field :slug, :string
    field :title, :string
    field :prompt, :string
    field :status, :string, default: "draft"
    field :tools_json, {:array, :map}, default: []
    field :resources_json, {:array, :map}, default: []
    field :prompts_json, {:array, :map}, default: []
    field :schema_sql, :string
    # Agent-designed backing schema: %{"postgres" => [ddl, ...], "weaviate" => [class_def, ...]}.
    field :schema_json, :map
    # Generated module implementations: [%{"tool", "module", "function", "source"}].
    field :modules_json, {:array, :map}, default: []
    field :active_llm_id, :binary_id
    field :db_name, :string
    field :db_provisioned, :boolean, default: false
    field :created_by, :string
    field :project_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  def changeset(definition, attrs) do
    definition
    |> cast(attrs, [
      :organization_id,
      :slug,
      :title,
      :prompt,
      :status,
      :tools_json,
      :resources_json,
      :prompts_json,
      :schema_sql,
      :schema_json,
      :modules_json,
      :active_llm_id,
      :db_name,
      :db_provisioned,
      :created_by,
      :project_id
    ])
    |> validate_required([:organization_id, :slug, :title, :prompt])
    |> validate_inclusion(:status, @statuses)
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*[a-z0-9]$/)
    |> unique_constraint(:slug)
    |> foreign_key_constraint(:organization_id)
    |> foreign_key_constraint(:project_id)
    |> foreign_key_constraint(:active_llm_id)
  end

  def statuses, do: @statuses
end
