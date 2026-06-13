defmodule Codefresh.Repo.Migrations.AddScriptNodesSwitchPersona do
  use Ecto.Migration

  def change do
    alter table(:script_nodes) do
      add :switch_persona_to, references(:persona_versions, type: :uuid, on_delete: :restrict)
    end

    create index(:script_nodes, [:switch_persona_to])
  end
end
