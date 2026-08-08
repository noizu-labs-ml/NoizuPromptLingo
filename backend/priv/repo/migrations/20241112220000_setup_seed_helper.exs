defmodule NoizuPromptLingua.Repo.Migrations.SetupSeedHelper do
  use Ecto.Migration

  def up, do: SeedHelper.Migration.up(1)
  def down, do: SeedHelper.Migration.down(1)
end
