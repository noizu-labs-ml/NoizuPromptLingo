defmodule NoizuPromptLingua.Repo.Migrations.CreateMCPCustomScopes do
  use Ecto.Migration

  def change do
    create table(:mcp_custom_scopes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :slug, :string, null: false
      add :name, :string, null: false
      add :description, :text
      add :config, :map, null: false, default: %{}

      timestamps(type: :utc_datetime)
    end

    create unique_index(:mcp_custom_scopes, [:slug], name: :uq_mcp_custom_scopes_slug)
  end
end
