defmodule Derobot.Repo.Migrations.CreateSeedHelperTables do
  use Ecto.Migration

  def up do
    SeedHelper.Migration.up(1)
  end

  def down do
    SeedHelper.Migration.down(1)
  end
end
