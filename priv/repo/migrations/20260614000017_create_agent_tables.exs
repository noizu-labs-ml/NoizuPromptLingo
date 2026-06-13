defmodule NoizuPromptLingua.Repo.Migrations.CreateAgentTables do
  use Ecto.Migration

  def change do
    create table(:agent_pipe_messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :target, :string, null: false
      add :sender, :string, null: false
      add :content, :text, null: false
      add :priority, :string, null: false, default: "normal"
      add :consumed, :boolean, null: false, default: false

      timestamps(type: :utc_datetime)
    end

    create index(:agent_pipe_messages, [:target, :consumed])

    create table(:agent_instructions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :content, :text, null: false
      add :tags, {:array, :string}, default: []
      add :session_id, :binary_id
      add :version, :integer, null: false, default: 1

      timestamps(type: :utc_datetime)
    end

    create index(:agent_instructions, [:tags], using: :gin)
    create index(:agent_instructions, [:session_id])

    create table(:agent_orchestrations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :pipeline, :string, null: false
      add :status, :string, null: false, default: "pending"
      add :context, :map
      add :session_id, :binary_id
      add :result, :map

      timestamps(type: :utc_datetime)
    end

    create index(:agent_orchestrations, [:pipeline])
    create index(:agent_orchestrations, [:status])
  end
end
