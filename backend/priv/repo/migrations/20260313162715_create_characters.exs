defmodule Boe.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :race, :string, null: false
      add :character_class, :string, null: false
      add :level, :integer, null: false, default: 1
      add :xp, :integer, null: false, default: 0
      add :xp_next, :integer, null: false, default: 100
      add :hp, :integer, null: false
      add :max_hp, :integer, null: false
      add :energy, :integer, null: false
      add :max_energy, :integer, null: false
      add :gold, :integer, null: false, default: 50
      add :weapon, :string, null: false
      add :armor, :string, null: false
      add :location, :string, null: false, default: "Rune — Town Square"
      add :effects, {:array, :string}, null: false, default: []
      add :strength, :integer, null: false
      add :dexterity, :integer, null: false
      add :constitution, :integer, null: false
      add :intelligence, :integer, null: false
      add :wisdom, :integer, null: false
      add :charisma, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:characters, [:user_id])
    create unique_index(:characters, [:name])
  end
end
