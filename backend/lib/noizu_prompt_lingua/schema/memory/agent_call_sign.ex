defmodule NoizuPromptLingua.Schema.Memory.AgentCallSign do
  @moduledoc """
  Registry of memory-owning agent identities for the weego (orchestrator) and ephemeral
  team-member sub-agents. Provides the stable, org-unique `call_sign` (and `id` used as the
  memory `scope_id`) for the `weego`/`team_member` scopes. Personas own memory directly via
  `personas.id`, so they are not registered here.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "agent_call_signs" do
    field :organization_id, Ecto.UUID
    field :kind, Ecto.Enum, values: [:weego, :team_member]
    field :call_sign, :string
    field :display_name, :string
    field :persona_id, Ecto.UUID
    field :status, :string, default: "active"
    field :metadata, :map, default: %{}

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(cs, attrs) do
    cs
    |> cast(attrs, ~w(organization_id kind call_sign display_name persona_id status metadata)a)
    |> validate_required([:organization_id, :kind, :call_sign])
    |> validate_format(:call_sign, ~r/^[a-z0-9][a-z0-9\-_]{0,62}$/,
      message: "must be lowercase alphanumeric with - or _"
    )
    |> unique_constraint([:organization_id, :call_sign], name: :idx_agent_call_signs_org_callsign)
  end
end
