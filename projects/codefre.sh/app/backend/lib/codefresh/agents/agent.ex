defmodule Codefresh.Agents.Agent do
  @moduledoc """
  Head entity for an agent connector. Immutable adapter configs live on
  `AgentVersion`. An agent is unpublished until at least one `AgentVersion`
  exists and `current_version_id` is set.

  Governance fields (`daily_cost_cap_usd`, `rate_limit_per_min`) live on the
  head so operators can adjust live controls without republishing (US-064).
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "agents" do
    field :slug, :string
    field :name, :string
    field :description, :string
    field :archived_at, :utc_datetime
    field :daily_cost_cap_usd, :decimal
    field :rate_limit_per_min, :integer

    belongs_to :organization, Codefresh.Organizations.Organization
    belongs_to :current_version, Codefresh.Agents.AgentVersion, foreign_key: :current_version_id
    belongs_to :created_by, Codefresh.Accounts.User, foreign_key: :created_by_user_id

    has_many :versions, Codefresh.Agents.AgentVersion

    timestamps(type: :utc_datetime)
  end

  def create_changeset(agent, attrs) do
    agent
    |> cast(attrs, [
      :slug,
      :name,
      :description,
      :organization_id,
      :created_by_user_id,
      :daily_cost_cap_usd,
      :rate_limit_per_min
    ])
    |> validate_required([:name, :organization_id])
    |> validate_length(:name, min: 1, max: 200)
    |> validate_length(:description, max: 4_000)
    |> validate_governance()
    |> maybe_derive_slug()
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*$/,
      message: "must be lowercase alphanumeric with dashes"
    )
    |> validate_length(:slug, min: 1, max: 120)
    |> unique_constraint(:slug, name: :agents_organization_id_slug_index)
    |> foreign_key_constraint(:organization_id)
  end

  def update_changeset(agent, attrs) do
    agent
    |> cast(attrs, [:name, :description, :slug, :daily_cost_cap_usd, :rate_limit_per_min])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 200)
    |> validate_length(:description, max: 4_000)
    |> validate_governance()
    |> validate_format(:slug, ~r/^[a-z0-9][a-z0-9-]*$/,
      message: "must be lowercase alphanumeric with dashes"
    )
    |> unique_constraint(:slug, name: :agents_organization_id_slug_index)
  end

  def advance_current_version_changeset(agent, version_id) do
    change(agent, current_version_id: version_id)
  end

  def archive_changeset(agent) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(agent, archived_at: now)
  end

  def unarchive_changeset(agent), do: change(agent, archived_at: nil)

  defp validate_governance(cs) do
    cs
    |> validate_number(:rate_limit_per_min, greater_than: 0)
    |> validate_cost_cap()
  end

  defp validate_cost_cap(cs) do
    case get_field(cs, :daily_cost_cap_usd) do
      nil ->
        cs

      %Decimal{} = d ->
        if Decimal.compare(d, Decimal.new(0)) == :gt,
          do: cs,
          else: add_error(cs, :daily_cost_cap_usd, "must be greater than 0")

      _ ->
        add_error(cs, :daily_cost_cap_usd, "must be a decimal")
    end
  end

  defp maybe_derive_slug(changeset) do
    case {get_change(changeset, :slug), get_field(changeset, :slug), get_change(changeset, :name)} do
      {nil, nil, name} when is_binary(name) -> put_change(changeset, :slug, derive_slug(name))
      _ -> changeset
    end
  end

  def derive_slug(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end
end
