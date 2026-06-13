defmodule Codefresh.Repo.Migrations.AddAgentVersionsCostGovernance do
  use Ecto.Migration

  def change do
    # Governance fields live on the agent HEAD (not version) so they can be adjusted
    # without republishing. The data-model (§14.13) spec was ambiguous; head is the
    # right home — governance is about live control, not run-pinned config.
    alter table(:agents) do
      add :daily_cost_cap_usd, :decimal, precision: 10, scale: 4
      add :rate_limit_per_min, :integer
    end

    # model_tier IS version-pinned — different versions may declare different tiers
    alter table(:agent_versions) do
      add :model_tier, :string
    end
  end
end
