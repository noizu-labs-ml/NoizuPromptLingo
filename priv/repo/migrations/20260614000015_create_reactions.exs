defmodule NoizuPromptLingua.Repo.Migrations.CreateReactions do
  use Ecto.Migration

  def change do
    create table(:npl_reactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :entity_type, :string, null: false
      add :entity_id, :binary_id, null: false
      add :persona, :string, null: false
      add :emoji, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:npl_reactions, [:entity_type, :entity_id, :persona, :emoji])
  end
end
