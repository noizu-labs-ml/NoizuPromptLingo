defmodule Codefresh.Repo.Migrations.AddFreeballNodesAdaptiveFields do
  use Ecto.Migration

  def change do
    alter table(:freeball_nodes) do
      add :adaptive_depth_policy, :string
      add :learning_examples, :map
    end
  end
end
