defmodule NoizuPromptLingua.Schema.MockMCPDefinition do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @statuses ~w(draft active archived)

  schema "mock_mcp_definitions" do
    field :slug, :string
    field :title, :string
    field :prompt, :string
    field :status, :string, default: "draft"
    field :tools_json, {:array, :map}, default: []
    field :schema_sql, :string
    field :llm_provider, :string, default: "openai"
    field :llm_model, :string
    field :llm_endpoint, :string
    field :db_name, :string
    field :db_provisioned, :boolean, default: false
    field :created_by, :string
    field :project_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  def changeset(definition, attrs) do
    definition
    |> cast(attrs, [:slug, :title, :prompt, :status, :tools_json, :schema_sql,
                     :llm_provider, :llm_model, :llm_endpoint, :db_name,
                     :db_provisioned, :created_by, :project_id])
    |> validate_required([:slug, :title, :prompt])
    |> validate_inclusion(:status, @statuses)
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*[a-z0-9]$/)
    |> unique_constraint(:slug)
  end
end
