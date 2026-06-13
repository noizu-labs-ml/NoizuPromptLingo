defmodule Starter.Repo.Migrations.SetupSmartToken do
  use Ecto.Migration

  def up, do: SmartToken.Migration.up(1)
  def down, do: SmartToken.Migration.down(1)
end
