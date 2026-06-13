defmodule Codefresh.Repo.Migrations.CreateObanJobs do
  use Ecto.Migration

  def up, do: Oban.Migration.up(version: 12)
  def down, do: Oban.Migration.down()
end
