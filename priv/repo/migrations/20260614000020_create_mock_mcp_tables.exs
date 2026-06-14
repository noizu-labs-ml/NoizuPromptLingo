defmodule NoizuPromptLingua.Repo.Migrations.CreateMockMCPTables do
  use Ecto.Migration

  def change do
    create table(:mock_mcp_definitions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :slug, :string, null: false
      add :title, :string, null: false
      add :prompt, :text, null: false
      add :status, :string, null: false, default: "draft"
      add :tools_json, :jsonb, null: false, default: "[]"
      add :schema_sql, :text
      add :llm_provider, :string, default: "openai"
      add :llm_model, :string
      add :llm_endpoint, :string
      add :db_name, :string
      add :db_provisioned, :boolean, default: false
      add :created_by, :string
      add :project_id, references(:projects, type: :binary_id, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:mock_mcp_definitions, [:slug])
    create index(:mock_mcp_definitions, [:status])
    create index(:mock_mcp_definitions, [:project_id])

    create table(:mock_mcp_call_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :definition_id, references(:mock_mcp_definitions, type: :binary_id, on_delete: :delete_all), null: false
      add :session_id, :string
      add :method, :string, null: false
      add :tool_name, :string
      add :arguments, :jsonb
      add :response, :jsonb
      add :latency_ms, :integer
      add :error, :text

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:mock_mcp_call_logs, [:definition_id])
    create index(:mock_mcp_call_logs, [:inserted_at])
  end
end
